import logging
from datetime import datetime, timedelta
from typing import List, Tuple, Dict, Any

from config.firebase_config import db

logger = logging.getLogger("scheduling_service")

def check_overlap(time1_str: str, time2_str: str, buffer_hours: float = 1.0) -> bool:
    """
    Checks if two slots overlap or fall within the specified travel buffer margin.
    """
    try:
        t1 = datetime.fromisoformat(time1_str)
        t2 = datetime.fromisoformat(time2_str)
        buffer = timedelta(hours=buffer_hours)
        return abs(t1 - t2) < buffer
    except Exception as e:
        logger.error(f"Error parsing date times for overlap calculation: {e}")
        return False

def validate_provider_schedule(
    provider_id: str,
    requested_time_str: str,
    provider_slots: List[str]
) -> Tuple[bool, str]:
    """
    Validates if a provider is available for the requested time.
    1. Checks if the requested slot matches the general availability window.
    2. Queries Firestore to prevent double bookings and enforce a 1-hour travel buffer.
    """
    try:
        requested_dt = datetime.fromisoformat(requested_time_str)
    except Exception:
        return False, "Invalid ISO 8601 date format for requested appointment time."

    # 1. Check general slot availability
    has_general_slot = False
    for slot in provider_slots:
        try:
            slot_dt = datetime.fromisoformat(slot)
            # Slot is match if it falls on the same day within a 2-hour window
            if abs(requested_dt - slot_dt) <= timedelta(hours=2):
                has_general_slot = True
                break
        except Exception:
            continue

    if not has_general_slot:
        return False, f"Provider is not scheduled to work around the requested slot: {requested_time_str}"

    # 2. Firestore Overlap Conflict Check
    if db:
        try:
            bookings_ref = db.collection("bookings")
            # Query confirmed or pending bookings for this provider
            query = bookings_ref.where("provider_id", "==", provider_id).stream()
            
            for doc in query:
                booking = doc.to_dict()
                status = booking.get("status", "pending").lower()
                if status in ["cancelled", "completed", "disputed"]:
                    continue # Skip cancelled or finished appointments
                
                booked_time = booking.get("scheduled_time")
                if not booked_time:
                    continue
                
                # Check for conflict inside the 1-hour buffer margin
                if check_overlap(requested_time_str, booked_time, buffer_hours=1.0):
                    return False, (
                        f"Schedule Conflict! Provider is already booked at {booked_time}. "
                        "A 1-hour travel buffer is required between jobs."
                    )
        except Exception as e:
            logger.warning(f"Firestore scheduling query failed ({e}). Reverting to default booking approval...")

    return True, "Schedule is clear. Booking is approved!"
