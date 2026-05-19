import math
import json
import logging
from typing import List, Dict, Any, Tuple, Optional
from pathlib import Path
from datetime import datetime, timedelta

from config.firebase_config import db
from models.provider import ProviderModel

logger = logging.getLogger("provider_service")

MOCK_FILE_PATH = Path(__file__).resolve().parent.parent / "data" / "providers_mock.json"

def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Computes physical travel distance in kilometers between two coordinates.
    """
    R = 6371.0  # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c

def get_all_providers() -> List[Dict[str, Any]]:
    """
    Retrieves all providers from Cloud Firestore.
    If Firestore is uninitialized or fails, falls back gracefully to providers_mock.json.
    """
    providers_list = []
    
    # 1. Attempt Firestore Retrieval
    if db:
        try:
            col_ref = db.collection("providers")
            docs = col_ref.stream()
            for doc in docs:
                providers_list.append(doc.to_dict())
            if providers_list:
                return providers_list
        except Exception as e:
            logger.warning(f"Failed to fetch from Firestore ({e}). Falling back to local dataset...")
            
    # 2. Local Fallback
    if MOCK_FILE_PATH.exists():
        try:
            with open(MOCK_FILE_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to read local mock file: {e}")
            
    return []

def calculate_match_score(
    provider: Dict[str, Any], 
    user_lat: float, 
    user_lng: float, 
    parsed_intent: Dict[str, Any]
) -> Tuple[float, Dict[str, float], float]:
    """
    Implements the 8-Factor Dynamic Match Scoring Algorithm.
    Returns: (final_score_0_to_100, itemized_factors_dict, distance_km)
    """
    service_type = parsed_intent.get("service_type", "").lower()
    urgency = parsed_intent.get("urgency", "standard").lower()
    specializations_needed = parsed_intent.get("specializations", [])
    budget_limit = parsed_intent.get("budget_limit", None)
    
    # Factor 1: Category Relevance (Strict Binary Filter)
    provider_cats = [c.lower() for c in provider.get("service_categories", [])]
    if service_type not in provider_cats:
        return 0.0, {}, 0.0
        
    p_lat = provider["location"]["lat"]
    p_lng = provider["location"]["lng"]
    dist_km = haversine_distance(user_lat, user_lng, p_lat, p_lng)
    
    # Factor 2: Proximity Score (Weight: 25%)
    # Under 2km = 100 pts. Drops linearly to 0 pts at 15km.
    if dist_km <= 2.0:
        proximity_pts = 100.0
    elif dist_km >= 15.0:
        proximity_pts = 0.0
    else:
        proximity_pts = 100.0 * (1.0 - (dist_km - 2.0) / 13.0)
        
    # Factor 3: Experience Score (Weight: 15%)
    # 15+ years = 100 pts, scaled linearly from 0 years.
    exp = provider.get("experience_years", 0)
    exp_pts = min(100.0, (exp / 15.0) * 100.0)
    
    # Factor 4: On-time Reliability Score (Weight: 15%)
    on_time = provider.get("on_time_score", 1.0)
    ontime_pts = on_time * 100.0
    
    # Factor 5: Average Rating Score (Weight: 15%)
    # Scale rating (normally 1-5 stars) to 0-100 pts.
    rating = provider.get("rating", 4.0)
    rating_pts = max(0.0, ((rating - 1.0) / 4.0) * 100.0)
    
    # Factor 6: Urgency & Slots Score (Weight: 10%)
    # High urgency checks if they have slots today or in the next 4 hours
    urgency_pts = 50.0 # base baseline
    if urgency == "high":
        # Check if slots are within 8 hours
        has_near_slot = False
        now = datetime.now()
        eight_hours_later = now + timedelta(hours=8)
        
        for slot_str in provider.get("availability_slots", []):
            try:
                slot_time = datetime.fromisoformat(slot_str)
                if now <= slot_time <= eight_hours_later:
                    has_near_slot = True
                    break
            except Exception:
                continue
        if has_near_slot:
            urgency_pts = 100.0
        else:
            urgency_pts = 30.0 # penalized if they have no immediate slots
            
    # Factor 7: Specialization Boost Score (Weight: 10%)
    # Matches provider's specialization array with parsed query specifications
    spec_matches = 0
    p_specs = [s.lower() for s in provider.get("specializations", [])]
    
    for s_need in specializations_needed:
        if s_need.lower() in p_specs:
            spec_matches += 1
            
    spec_pts = 100.0 if (specializations_needed and spec_matches > 0) else (50.0 if not specializations_needed else 20.0)
    
    # Factor 8: Price Sensitivity Match Score (Weight: 10%)
    # Score is high if provider is within budget, or matches budget expectations
    price_pts = 50.0
    p_rate = provider.get("base_rate_pkr", 500)
    if budget_limit:
        if p_rate <= budget_limit:
            # high score for budget compatibility
            price_pts = 100.0
        else:
            # penalize linear ratio
            price_pts = max(0.0, 100.0 - ((p_rate - budget_limit) / budget_limit) * 100.0)
    else:
        # Standard average baseline matching
        if p_rate <= 700:
            price_pts = 85.0
        else:
            price_pts = 60.0
            
    # Factor 7: Cancellation Penalty Score (Weight: 5%)
    cancel_rate = provider.get("cancellation_rate", 0.0)
    cancel_pts = max(0.0, (1.0 - cancel_rate) * 100.0)
    
    # Factor 8: Review Sentiment Score (Weight: 5%)
    reviews = provider.get("recent_reviews", [])
    sentiment_pts = 75.0  # baseline if no reviews
    if reviews:
        total_rating = 0
        positive_keywords = ["mahir", "acha", "badhiya", "neat", "clean", "satisfied", "highly professional", "recommended", "best", "skilled", "waqt per", "nice"]
        negative_keywords = ["cheated", "bad", "late", "waiting", "double bookings", "poor", "high price", "rude"]
        
        keyword_boost = 0.0
        for rev in reviews:
            text = rev.get("text", "").lower()
            total_rating += rev.get("rating", 4)
            for pk in positive_keywords:
                if pk in text:
                    keyword_boost += 5.0
            for nk in negative_keywords:
                if nk in text:
                    keyword_boost -= 5.0
                    
        avg_rev_rating = total_rating / len(reviews)
        rating_sentiment = max(0.0, ((avg_rev_rating - 1.0) / 4.0) * 100.0)
        sentiment_pts = min(100.0, max(0.0, rating_sentiment + keyword_boost))
        
    # Weights configuration
    weights = {
        "proximity": 0.20,
        "rating": 0.15,
        "on_time": 0.15,
        "experience": 0.10,
        "urgency": 0.10,
        "specialization": 0.10,
        "price": 0.10,
        "cancellation": 0.05,
        "sentiment": 0.05
    }
    
    # Combined Multi-Factor Formula
    final_score = (
        proximity_pts * weights["proximity"] +
        rating_pts * weights["rating"] +
        ontime_pts * weights["on_time"] +
        exp_pts * weights["experience"] +
        urgency_pts * weights["urgency"] +
        spec_pts * weights["specialization"] +
        price_pts * weights["price"] +
        cancel_pts * weights["cancellation"] +
        sentiment_pts * weights["sentiment"]
    )
    
    breakdown = {
        "proximity_pts": round(proximity_pts, 1),
        "rating_pts": round(rating_pts, 1),
        "on_time_pts": round(ontime_pts, 1),
        "experience_pts": round(exp_pts, 1),
        "urgency_pts": round(urgency_pts, 1),
        "specialization_pts": round(spec_pts, 1),
        "price_pts": round(price_pts, 1),
        "cancellation_pts": round(cancel_pts, 1),
        "sentiment_pts": round(sentiment_pts, 1)
    }
    
    return round(final_score, 2), breakdown, round(dist_km, 2)

def update_provider_rating_in_firestore(
    provider_id: str,
    new_rating: float,
    dispute_type: Optional[str] = None
) -> Dict[str, Any]:
    """
    Updates provider rating in Firestore with rolling average.
    Handles offense tracking for dispute penalties.
    Falls back silently if Firestore unavailable.

    Returns: { "updated_rating": float, "penalty_applied": bool, "action": str }
    """
    if not db:
        return {"updated_rating": new_rating, "penalty_applied": False, "action": "firestore_unavailable"}

    try:
        doc_ref = db.collection("providers").document(provider_id)
        doc = doc_ref.get()

        if not doc.exists:
            logger.warning(f"Provider {provider_id} not found in Firestore.")
            return {"updated_rating": new_rating, "penalty_applied": False, "action": "provider_not_found"}

        provider_data = doc.to_dict()
        old_avg = float(provider_data.get("rating", 4.0) or 4.0)
        old_count = int(provider_data.get("rating_count", 1) or 1)

        # Compute new rolling average
        new_avg = round((old_avg * old_count + new_rating) / (old_count + 1), 2)

        update_payload = {
            "rating": new_avg,
            "rating_count": old_count + 1,
            "updated_at": datetime.now().isoformat()
        }

        penalty_applied = False
        action = "rating_updated"

        # Offense tracking
        if dispute_type is not None:
            now = datetime.now()
            cutoff = (now - timedelta(days=30)).isoformat()

            existing_warnings = provider_data.get("warnings", [])
            # Count same-type warnings in last 30 days
            recent_same_type = [
                w for w in existing_warnings
                if w.get("dispute_type") == dispute_type
                and w.get("timestamp", "") >= cutoff
            ]
            offense_count = len(recent_same_type)

            # Log this warning
            warning_entry = {
                "dispute_type": dispute_type,
                "timestamp": now.isoformat(),
                "rating_impact": new_rating
            }
            existing_warnings.append(warning_entry)
            update_payload["warnings"] = existing_warnings

            all_warnings_count = len(provider_data.get("warnings", [])) + 1
            risk_score = float(provider_data.get("risk_score", 0.0) or 0.0)

            if offense_count >= 1:  # 2nd same offense in 30 days
                # Apply match score penalty for 30 days
                update_payload["ranking_penalty_until"] = (
                    now + timedelta(days=30)
                ).isoformat()
                update_payload["ranking_penalty_value"] = -0.15
                penalty_applied = True
                action = "ranking_penalty_applied"
                logger.warning(
                    f"Provider {provider_id}: 2nd {dispute_type} offense — ranking penalty applied."
                )

            if all_warnings_count >= 3 or risk_score > 0.7:
                # Flag provider — hidden from search
                update_payload["flagged"] = True
                action = "provider_flagged"
                logger.error(
                    f"Provider {provider_id}: Flagged after {all_warnings_count} warnings "
                    f"or risk_score={risk_score}. Hidden from search."
                )
            else:
                action = action if penalty_applied else "warning_logged"

        doc_ref.update(update_payload)
        logger.info(f"Provider {provider_id} rating updated: {old_avg} -> {new_avg}. Action: {action}")
        return {"updated_rating": new_avg, "penalty_applied": penalty_applied, "action": action}

    except Exception as e:
        logger.error(f"update_provider_rating_in_firestore failed for {provider_id}: {e}")
        return {"updated_rating": new_rating, "penalty_applied": False, "action": f"error: {str(e)}"}


def get_matching_providers(
    user_lat: float,
    user_lng: float,
    parsed_intent: Dict[str, Any],
    limit: int = 5
) -> List[Dict[str, Any]]:
    """
    Filters, scores, and ranks all service providers using the 9-Factor Match System.
    Automatically excludes flagged providers.
    """
    all_providers = get_all_providers()
    scored_list = []

    for p in all_providers:
        # Skip flagged providers — they are hidden from search
        if p.get("flagged", False):
            logger.debug(f"Skipping flagged provider: {p.get('pid', 'unknown')}")
            continue

        # Strict validation checks
        try:
            validated = ProviderModel(**p)
            p_dict = validated.model_dump()
        except Exception as e:
            logger.warning(f"Provider {p.get('pid', 'unknown')} failed model validation: {e}")
            p_dict = p

        score, factors, distance = calculate_match_score(p_dict, user_lat, user_lng, parsed_intent)
        if score > 0:
            p_dict["match_score"] = score
            p_dict["match_factors"] = factors
            p_dict["distance_km"] = distance
            scored_list.append(p_dict)

    # Rank descending by score
    scored_list.sort(key=lambda x: x["match_score"], reverse=True)
    return scored_list[:limit]
