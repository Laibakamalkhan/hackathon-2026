from pydantic import BaseModel, Field
from typing import Literal, List, Optional

class DisputeResolution(BaseModel):
    type: Literal["refund", "compensation", "rebook", "warning", "none"] = Field(
        default="none",
        description="Agreed dispute settlement method"
    )
    amount_pkr: int = Field(default=0, ge=0, description="Refund or compensation value in PKR")
    reasoning: str = Field(default="", description="ADK DisputeAgent resolution explanation")

class DisputeModel(BaseModel):
    dispute_id: str = Field(..., description="Unique Dispute ID")
    booking_id: str = Field(..., description="Target booking associated with this dispute")
    type: Literal["no_show", "quality", "price", "overrun", "cancellation"] = Field(
        ...,
        description="Category of customer complaint"
    )
    description: str = Field(..., description="Customer descriptive text of the issue")
    evidence: List[str] = Field(default=[], description="List of URL file strings representing visual photos/evidence")
    status: Literal["open", "under_review", "resolved", "escalated"] = Field(
        default="open",
        description="Dispute state lifecycle index"
    )
    resolution: Optional[DisputeResolution] = Field(default=None, description="Dispute settlement payload")
    created_at: str = Field(..., description="Dispute submission ISO string")
