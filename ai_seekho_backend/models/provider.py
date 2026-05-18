from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class GeoLocation(BaseModel):
    area: str = Field(..., description="Service sector or region, e.g. G-13")
    lat: float = Field(..., description="Latitude coordinate")
    lng: float = Field(..., description="Longitude coordinate")

class Review(BaseModel):
    text: str = Field(..., description="Text content of the customer feedback")
    rating: int = Field(..., ge=1, le=5, description="Star rating from 1 to 5")
    date: str = Field(..., description="Date string when submitted")

class ProviderModel(BaseModel):
    pid: str = Field(..., description="Unique Provider ID")
    name: str = Field(..., description="Provider Full Name")
    phone: str = Field(..., description="Provider Contact Number")
    service_categories: List[str] = Field(..., description="List of primary category tags, e.g. ['ac_repair']")
    specializations: List[str] = Field(default=[], description="Sub-specialized domains, e.g. ['inverter_ac']")
    experience_years: int = Field(..., ge=0, description="Years in trade")
    rating: float = Field(..., ge=0.0, le=5.0, description="Average review score")
    rating_count: int = Field(default=0, ge=0, description="Total ratings received")
    on_time_score: float = Field(..., ge=0.0, le=1.0, description="On-time reliability index")
    cancellation_rate: float = Field(..., ge=0.0, le=1.0, description="cancellation penalty frequency")
    base_rate_pkr: int = Field(..., description="Flat base service fee in PKR")
    per_km_rate: int = Field(default=40, description="Additional charge per km traveled")
    location: GeoLocation = Field(..., description="Coordinates and base area mapping")
    availability_slots: List[str] = Field(default=[], description="List of ISO 8601 available time windows")
    verified: bool = Field(default=True, description="Verification badge status")
    risk_score: float = Field(default=0.0, ge=0.0, le=1.0, description="Fraud/dispute score index")
    recent_reviews: List[Review] = Field(default=[], description="List of recent customer comments")
