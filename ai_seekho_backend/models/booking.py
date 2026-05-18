from pydantic import BaseModel, Field
from typing import Literal, Optional, Dict, Any
from datetime import datetime
from models.pricing import PriceBreakdown

class BookingLocation(BaseModel):
    address: str = Field(..., description="Target service address")
    lat: float = Field(..., description="Latitude coordinate")
    lng: float = Field(..., description="Longitude coordinate")

class BookingModel(BaseModel):
    bid: str = Field(..., description="Unique Booking ID")
    user_id: str = Field(..., description="Unique Firebase User ID")
    provider_id: str = Field(..., description="Unique Provider ID")
    service_type: str = Field(..., description="Service Category Tag")
    status: Literal["pending", "confirmed", "en_route", "in_progress", "completed", "disputed", "cancelled"] = Field(
        default="pending",
        description="Active state index of the lifecycle transaction"
    )
    scheduled_time: str = Field(..., description="ISO 8601 string indicating the requested appointment slot")
    location: BookingLocation = Field(..., description="Customer physical coordinates and address")
    price_quote: PriceBreakdown = Field(..., description="Final approved dynamic price breakdown")
    intent_raw: str = Field(..., description="Original customer input query")
    intent_parsed: Dict[str, Any] = Field(..., description="Parsed entities derived from intent parsing")
    agent_trace_id: Optional[str] = Field(default=None, description="Reference link to the ADK Agent Trace log")
    created_at: str = Field(..., description="Record creation ISO string")
    updated_at: str = Field(..., description="Record update ISO string")
