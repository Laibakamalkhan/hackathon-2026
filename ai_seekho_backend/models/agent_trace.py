from pydantic import BaseModel, Field
from typing import List, Optional, Any, Dict

class TraceStep(BaseModel):
    step: int = Field(..., description="Serial index of the processing sequence")
    agent: str = Field(..., description="Name of execution agent, e.g. IntentAgent")
    action: str = Field(..., description="Current tool invocation or sub-routine descriptor")
    reasoning: str = Field(..., description="Structured, explanatory trace text in Roman Urdu or Urdu")
    confidence: float = Field(default=1.0, ge=0.0, le=1.0, description="Agent confidence index")
    latency_ms: int = Field(..., description="Time taken to execute this processing step in milliseconds")
    tools_used: List[str] = Field(default=[], description="List of internal functions invoked")
    timestamp: str = Field(..., description="ISO 8601 creation timeline entry")

class AgentTraceModel(BaseModel):
    trace_id: str = Field(..., description="Unique Trace ID")
    booking_id: Optional[str] = Field(default=None, description="Linked booking ID if successfully completed")
    session_id: str = Field(..., description="Websocket and state stream session connection string")
    steps: List[TraceStep] = Field(default=[], description="Array of reasoning steps completed by sub-agents")
    total_latency_ms: int = Field(default=0, description="Accumulated latency of all sequenced sub-routine runs")
    status: str = Field(default="pending", description="Processing state: pending, completed, or failed")
    created_at: str = Field(..., description="Creation ISO time identifier")
