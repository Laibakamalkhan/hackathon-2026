from pydantic import BaseModel, Field
from typing import Literal, List, Optional

class IntentParseRequest(BaseModel):
    text: str = Field(..., description="The raw multilingual text message from the user")
    user_id: str = Field(..., description="Unique Firebase User ID")
    session_id: str = Field(..., description="Unique chat session ID for state preservation")
    context: List[dict] = Field(default=[], description="Previous conversation message context")

class IntentParseResponse(BaseModel):
    service_type: str = Field(..., description="Inferred category, e.g., ac_repair, plumbing, electrical, tutoring, beauty, driving, mechanics, general_home")
    location: str = Field(..., description="Target service area or specific coordinates text")
    time_preference: str = Field(..., description="Relative or absolute slot preference, e.g., tomorrow_morning, kal_dophar")
    urgency: Literal["low", "medium", "high", "emergency"] = Field(..., description="Urgency index of the request")
    budget_sensitivity: Literal["low", "medium", "high"] = Field(..., description="Inferred financial preference of the customer")
    constraints: List[str] = Field(default=[], description="Specific constraints like morning only, female technician only")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence score from 0.0 to 1.0")
    follow_up_question: Optional[str] = Field(default=None, description="Clarification question generated if confidence is below 0.7")
    detected_language: str = Field(..., description="Identified linguistic profile, e.g. roman_urdu, urdu, english, mixed")
    trace_step: Optional[dict] = Field(default=None, description="Reasoning trace snippet logged during this execution step")
