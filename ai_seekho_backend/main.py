import os
import json
import logging
from typing import Dict, Any, List, Optional
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uuid
from datetime import datetime

# Local imports
from config.settings import settings
from config.firebase_config import db
from orchestrator.agent_coordinator import run_orchestrated_matching, yield_orchestrated_matching
from services.provider_service import get_all_providers
from services.dispute_service import mediate_dispute
from services.scheduling_service import validate_provider_schedule
from models.booking import BookingModel

# Setup Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("ai_seekho_main")

app = FastAPI(
    title="AI Seekho Backend Engine",
    description="Multi-Agent Local Services Marketplace Orchestrated with Google ADK Logic",
    version="1.0.0"
)

# Enable CORS for frontend integrations (Flutter, React, etc.)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Active WebSocket connections registry
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, session_id: str, websocket: WebSocket):
        await websocket.accept()
        if session_id not in self.active_connections:
            self.active_connections[session_id] = []
        self.active_connections[session_id].append(websocket)
        logger.info(f"WebSocket client registered for session: {session_id}")

    def disconnect(self, session_id: str, websocket: WebSocket):
        if session_id in self.active_connections:
            self.active_connections[session_id].remove(websocket)
            if not self.active_connections[session_id]:
                del self.active_connections[session_id]
        logger.info(f"WebSocket client disconnected from session: {session_id}")

    async def send_personal_message(self, message: Dict[str, Any], websocket: WebSocket):
        await websocket.send_json(message)

    async def broadcast_to_session(self, session_id: str, message: Dict[str, Any]):
        if session_id in self.active_connections:
            for connection in self.active_connections[session_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Failed to send broadcast websocket packet: {e}")

manager = ConnectionManager()

# ----------------------------------------------------
# Request Schemas
# ----------------------------------------------------
class MatchRequest(BaseModel):
    query: str
    lat: float
    lng: float
    session_id: Optional[str] = "session-default"

class BookingCreateRequest(BaseModel):
    user_id: str
    provider_id: str
    service_type: str
    scheduled_time: str
    location_address: str
    lat: float
    lng: float
    price_quote: Dict[str, Any]
    intent_raw: str
    intent_parsed: Dict[str, Any]

class DisputeCreateRequest(BaseModel):
    booking_id: str
    type: str
    description: str

# ----------------------------------------------------
# HTTP API Endpoints
# ----------------------------------------------------
@app.get("/")
def read_root():
    return {
        "status": "online",
        "app": "AI Seekho Engine",
        "firebase_active": db is not None,
        "gemini_api_active": bool(settings.GEMINI_API_KEY)
    }

@app.post("/api/match")
async def match_technicians(req: MatchRequest):
    """
    HTTP endpoint to trigger the multi-factor agentic matchmaking process.
    Also broadcasts real-time updates over active WebSockets matching the session_id.
    """
    logger.info(f"Received matching request: Query='{req.query}' @ ({req.lat}, {req.lng})")
    
    # Run orchestrator
    try:
        # Broadcast initiation
        await manager.broadcast_to_session(req.session_id, {
            "event": "orchestration_started",
            "message": "Initializing AI Seekho Agent Orchestrator..."
        })
        
        result = run_orchestrated_matching(
            query=req.query,
            user_lat=req.lat,
            user_lng=req.lng,
            session_id=req.session_id
        )
        
        # Broadcast final result
        await manager.broadcast_to_session(req.session_id, {
            "event": "orchestration_completed",
            "trace_id": result["trace_id"],
            "steps": result["steps"]
        })
        
        return result
    except Exception as e:
        logger.error(f"Error in matchmaking: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/providers")
def get_providers():
    """
    Fetches the loaded service provider records.
    """
    providers = get_all_providers()
    return {"count": len(providers), "providers": providers}

@app.post("/api/booking/create")
def create_booking(req: BookingCreateRequest):
    """
    Creates a physical booking record inside Firestore.
    """
    # 1. Fetch provider details to validate availability slots
    providers = get_all_providers()
    provider_slots = []
    provider_found = False
    for p in providers:
        if p.get("pid") == req.provider_id:
            provider_slots = p.get("availability_slots", [])
            provider_found = True
            break
            
    if not provider_found:
        raise HTTPException(status_code=404, detail=f"Provider with ID '{req.provider_id}' not found.")
        
    # 2. Run schedule & double-booking validation
    is_available, msg = validate_provider_schedule(req.provider_id, req.scheduled_time, provider_slots)
    if not is_available:
        raise HTTPException(status_code=400, detail=msg)
        
    bid = f"BK-{uuid.uuid4().hex[:6].upper()}"
    
    booking_payload = {
        "bid": bid,
        "user_id": req.user_id,
        "provider_id": req.provider_id,
        "service_type": req.service_type,
        "status": "pending",
        "scheduled_time": req.scheduled_time,
        "location": {
            "address": req.location_address,
            "lat": req.lat,
            "lng": req.lng
        },
        "price_quote": req.price_quote,
        "intent_raw": req.intent_raw,
        "intent_parsed": req.intent_parsed,
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat()
    }
    
    if db:
        try:
            db.collection("bookings").document(bid).set(booking_payload)
            logger.info(f"Successfully posted Booking '{bid}' to Firestore.")
        except Exception as e:
            logger.error(f"Failed to post Booking to Firestore: {e}")
            raise HTTPException(status_code=500, detail="Firestore database failure")
            
    return {"status": "success", "booking": booking_payload}

@app.post("/api/dispute/create")
def create_dispute(req: DisputeCreateRequest):
    """
    Submits and mediations a customer service dispute.
    """
    dispute_id = f"DS-{uuid.uuid4().hex[:6].upper()}"
    try:
        payload = mediate_dispute(
            dispute_id=dispute_id,
            booking_id=req.booking_id,
            dispute_type=req.type,
            description=req.description
        )
        return {"status": "success", "dispute": payload}
    except Exception as e:
        logger.error(f"Error mediating dispute: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/trace/{trace_id}")
def get_trace(trace_id: str):
    """
    Retrieves the logical agent tracing timeline for a given ID.
    """
    if db:
        try:
            ref = db.collection("agent_traces").document(trace_id).get()
            if ref.exists:
                return ref.to_dict()
        except Exception as e:
            logger.error(f"Failed to read trace from Firestore: {e}")
            
    raise HTTPException(status_code=404, detail="Trace record not found")

# ----------------------------------------------------
# WebSocket Reasoning Stream Endpoint
# ----------------------------------------------------
@app.websocket("/ws/trace/{session_id}")
async def websocket_trace_endpoint(websocket: WebSocket, session_id: str):
    """
    Real-time WebSocket endpoint. Clients connect to listen for orchestrator timelines.
    """
    await manager.connect(session_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            try:
                payload = json.loads(data)
                query = payload.get("query", "")
                lat = payload.get("lat", 33.649)
                lng = payload.get("lng", 72.973)
                
                await websocket.send_json({
                    "event": "orchestration_started",
                    "message": "Initializing AI Seekho Agent Orchestrator..."
                })
                
                # Execute pipeline progressively and yield traces in real-time
                for step_update in yield_orchestrated_matching(
                    query=query,
                    user_lat=lat,
                    user_lng=lng,
                    session_id=session_id
                ):
                    event_type = step_update.get("event")
                    if event_type == "step_completed":
                        await websocket.send_json({
                            "event": "step_completed",
                            "step": step_update["step"]
                        })
                    elif event_type == "orchestration_completed":
                        result = step_update["result"]
                        await websocket.send_json({
                            "event": "orchestration_completed",
                            "trace_id": result["trace_id"],
                            "matching_providers": result["matching_providers"][:3],
                            "primary_quote": result["primary_quote"],
                            "steps": result["steps"]
                        })
                
            except Exception as e:
                await websocket.send_json({
                    "event": "error",
                    "message": f"Pipeline failure: {str(e)}"
                })
                
    except WebSocketDisconnect:
        manager.disconnect(session_id, websocket)
