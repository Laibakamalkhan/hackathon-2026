from pydantic import BaseModel, Field
from typing import Optional

class PriceBreakdown(BaseModel):
    base_service_fee: int = Field(..., description="Provider's base category rate")
    visit_fee: int = Field(default=200, description="Fixed mobilization or visiting fee")
    distance_fee: int = Field(..., description="Additional charge based on travel mileage")
    urgency_surcharge: int = Field(..., description="Extra fee for high urgency speed execution")
    complexity_surcharge: int = Field(..., description="Extra charge for specific constraints or specialization")
    loyalty_discount: int = Field(..., description="Negative PKR value representing customer loyalty tier discount")
    surge_multiplier: float = Field(default=1.0, description="Demand pricing surge factor, e.g. 1.2")
    total_pkr: int = Field(..., description="Aggregated total computed service price")
    currency: str = Field(default="PKR", description="Currency standard (PKR)")
    breakdown_reasoning: str = Field(..., description="Human-readable breakdown summary in English or Urdu")

class BudgetAlternative(BaseModel):
    provider_id: str = Field(..., description="ID of the alternative budget technician")
    total_pkr: int = Field(..., description="Aggregated cost for the alternative choice")
    tradeoff: str = Field(..., description="Brief trade-off description, e.g. '15% lower rating, 30min later'")

class PriceQuoteResponse(BaseModel):
    provider_id: str = Field(..., description="Target provider for which the quote is computed")
    quote: PriceBreakdown = Field(..., description="Primary computed itemized price quote")
    budget_alternative: Optional[BudgetAlternative] = Field(default=None, description="Recommended lower-priced substitute if user is price sensitive")
