"""Simulated SMS / WhatsApp notification payloads for booking lifecycle."""
from datetime import datetime
from typing import Any, Dict, List


def simulate_booking_notifications(
    bid: str,
    provider_name: str,
    scheduled_time: str,
    total_pkr: Any,
    phone: str = "+923001234567",
) -> List[Dict[str, Any]]:
    """Returns channel payloads that would be sent in production."""
    total = total_pkr if total_pkr is not None else "—"
    ts = datetime.now().isoformat()
    return [
        {
            "channel": "sms",
            "status": "simulated_sent",
            "to": phone,
            "sent_at": ts,
            "body": (
                f"AI Seekho: Booking {bid} confirmed. {provider_name} "
                f"scheduled {scheduled_time[:16]}. Total PKR {total}."
            ),
        },
        {
            "channel": "whatsapp",
            "status": "simulated_sent",
            "to": phone,
            "sent_at": ts,
            "body": (
                f"✅ *Booking Confirmed*\nID: {bid}\nProvider: {provider_name}\n"
                f"Time: {scheduled_time}\nTotal: PKR {total}\n"
                f"Reminder 1hr pehle bheja jayega."
            ),
        },
    ]
