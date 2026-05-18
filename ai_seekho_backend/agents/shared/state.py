from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field

class AgentHandoff(BaseModel):
    from_agent: str
    to_agent: str
    reason: str
    booking_id: Optional[str] = None
    full_context: Dict[str, Any] = Field(default_factory=dict)
    urgency: str = "normal"
    user_message: Optional[str] = None

class CoordinatorState(BaseModel):
    messages: List[Dict[str, Any]]
    session_id: str
    user_lat: float
    user_lng: float
    confidence: float = 0.0
    extracted_fields: Dict[str, Any] = Field(default_factory=dict)
    missing_fields: List[str] = Field(default_factory=list)
    shortlisted_providers: List[Dict[str, Any]] = Field(default_factory=list)
    current_step: str = "understanding"
    trace_events: List[Dict[str, Any]] = Field(default_factory=list)
