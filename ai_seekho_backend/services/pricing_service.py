import logging
from typing import Dict, Any, List, Optional
from datetime import datetime

from models.pricing import PriceBreakdown, BudgetAlternative, PriceQuoteResponse
from services.provider_service import haversine_distance, get_all_providers

logger = logging.getLogger("pricing_service")

def calculate_surge_multiplier(category: str) -> float:
    """
    Computes peak hours surge pricing.
    - Summer mid-day peak (June-September, 12:00 - 16:00) for ac_repair: 1.25x
    - Late night callouts (21:00 - 08:00) for all categories: 1.15x
    """
    now = datetime.now()
    hour = now.hour
    month = now.month
    
    # Summer mid-day peak for AC repair
    if category.lower() == "ac_repair" and 5 <= month <= 9 and 12 <= hour <= 16:
        return 1.25
        
    # Late night / early morning surge for all categories
    if hour >= 21 or hour < 8:
        return 1.15
        
    return 1.0

def generate_price_quote(
    provider: Dict[str, Any],
    distance_km: float,
    parsed_intent: Dict[str, Any]
) -> PriceQuoteResponse:
    """
    Implements the core dynamic pricing formula:
    Total PKR = ((Base + Urgency + Complexity) * Surge) + VisitFee + DistanceFee - LoyaltyDiscount
    """
    category = parsed_intent.get("service_type", "").lower()
    urgency = parsed_intent.get("urgency", "standard").lower()
    specializations = parsed_intent.get("specializations", [])
    loyalty_tier = parsed_intent.get("loyalty_tier", "regular").lower()
    
    base_fee = provider.get("base_rate_pkr", 500)
    per_km = provider.get("per_km_rate", 30)
    
    # 1. Distance Fee
    distance_fee = int(distance_km * per_km)
    
    # 2. Urgency Surcharge
    urgency_surcharge = 150 if urgency == "high" else 0
    
    # 3. Complexity Surcharge
    complexity_surcharge = 100 * len(specializations)
    
    # 4. Visit Fee
    visit_fee = 200
    
    # 5. Loyalty Discount
    loyalty_discount = 0
    if loyalty_tier == "gold":
        loyalty_discount = 150
    elif loyalty_tier == "silver":
        loyalty_discount = 75
        
    # 6. Surge Multiplier
    surge_multiplier = calculate_surge_multiplier(category)
    
    # Calculate Total
    subtotal = (base_fee + urgency_surcharge + complexity_surcharge) * surge_multiplier
    total = int(subtotal + visit_fee + distance_fee - loyalty_discount)
    total = max(300, total)  # Absolute minimum safety floor
    
    # Build Reasoning Text
    reasoning = (
        f"Base PKR {base_fee} ({category.replace('_', ' ').title()}) "
        f"+ Visit Fee PKR {visit_fee} "
        f"+ Distance Fee PKR {distance_fee} ({distance_km}km @ PKR {per_km}/km) "
    )
    if urgency_surcharge > 0:
        reasoning += f"+ Urgency PKR {urgency_surcharge} "
    if complexity_surcharge > 0:
        reasoning += f"+ Complexity PKR {complexity_surcharge} "
    if surge_multiplier > 1.0:
        reasoning += f"x Surge {surge_multiplier}x "
    if loyalty_discount > 0:
        reasoning += f"- Loyalty ({loyalty_tier.upper()}) PKR {loyalty_discount}"
        
    quote = PriceBreakdown(
        base_service_fee=base_fee,
        visit_fee=visit_fee,
        distance_fee=distance_fee,
        urgency_surcharge=urgency_surcharge,
        complexity_surcharge=complexity_surcharge,
        loyalty_discount=loyalty_discount,
        surge_multiplier=surge_multiplier,
        total_pkr=total,
        breakdown_reasoning=reasoning
    )
    
    # Find a cheaper budget alternative provider if possible
    budget_alt = find_budget_alternative(
        primary_pid=provider["pid"],
        primary_total=total,
        category=category,
        user_lat=provider["location"]["lat"], # use user coordinates from provider vicinity as baseline
        user_lng=provider["location"]["lng"],
        parsed_intent=parsed_intent
    )
    
    return PriceQuoteResponse(
        provider_id=provider["pid"],
        quote=quote,
        budget_alternative=budget_alt
    )

def find_budget_alternative(
    primary_pid: str,
    primary_total: int,
    category: str,
    user_lat: float,
    user_lng: float,
    parsed_intent: Dict[str, Any]
) -> Optional[BudgetAlternative]:
    """
    Scans other active providers in the category and identifies one with a significantly lower cost tradeoff.
    """
    all_providers = get_all_providers()
    cheaper_options = []
    
    for p in all_providers:
        if p["pid"] == primary_pid:
            continue
            
        p_cats = [c.lower() for c in p.get("service_categories", [])]
        if category not in p_cats:
            continue
            
        p_lat = p["location"]["lat"]
        p_lng = p["location"]["lng"]
        dist = haversine_distance(user_lat, user_lng, p_lat, p_lng)
        
        # Calculate their theoretical total price
        base_fee = p.get("base_rate_pkr", 500)
        p_per_km = p.get("per_km_rate", 30)
        dist_fee = int(dist * p_per_km)
        visit_fee = 200
        
        alt_total = base_fee + visit_fee + dist_fee
        
        # If the alternative is at least 15% cheaper
        if alt_total < (primary_total * 0.85):
            cheaper_options.append((p, alt_total))
            
    if not cheaper_options:
        return None
        
    # Pick the cheapest budget alternative
    cheaper_options.sort(key=lambda x: x[1])
    alt_prov, alt_cost = cheaper_options[0]
    
    # Describe tradeoffs (e.g. further distance or lower rating)
    trade_text = f"Save PKR {primary_total - alt_cost}! "
    if alt_prov.get("rating", 5.0) < 4.5:
        trade_text += "Traded with a slightly lower rating."
    else:
        trade_text += "Technician is slightly further away."
        
    return BudgetAlternative(
        provider_id=alt_prov["pid"],
        total_pkr=alt_cost,
        tradeoff=trade_text
    )
