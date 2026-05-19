# AI Seekho — Anti-Gravity Implementation Prompts + GitIgnore Audit
**Prepared for:** Anti-Gravity AI Coding Agent
**Project:** AI Seekho — Hackathon Challenge 2 (AI Service Orchestrator for Informal Economy)
**Stack:** Python 3.11 + FastAPI + Google ADK + Firebase Firestore + Flutter 3.11.5

---

# SECTION 1 — ANTI-GRAVITY IMPLEMENTATION PROMPTS

## Execution Strategy

The implementation is divided into **4 sequential phases**. Each phase is independently executable and leaves the system in a fully runnable state. Do NOT begin Phase 2 until Phase 1 passes its verification checklist.

**Ground rules for the agent:**
- Never delete existing files — rename or deprecate with a `_legacy` suffix
- All new endpoints must be versioned (`/api/v1/...`) and coexist with old ones until Phase 4
- All Firestore writes must be wrapped in try/except with graceful fallback
- All agent files must use `google-generativeai` with **function calling (tool use)** — this is the available ADK-equivalent pattern. Do NOT use LangChain or LangGraph.
- Use `gemini-2.5-flash` for all Gemini calls (already configured in `.env`)
- All prices are in **PKR (Pakistani Rupees)**
- All reasoning traces must be written in **Roman Urdu** with an English translation field

---

## PHASE 1 — Real Agent Layer (Backend Core)

### Context You Must Read First

Before writing any code, internalize these existing files:
- `ai_seekho_backend/agents/shared/prompts.py` — already has `MULTILINGUAL_PARSER_PROMPT` and `GUARDIAN_SYSTEM_PROMPT`; extend, do not overwrite
- `ai_seekho_backend/agents/shared/state.py` — already has `CoordinatorState` and `AgentHandoff`; extend, do not overwrite
- `ai_seekho_backend/orchestrator/agent_coordinator.py` — the existing sequential pipeline; agents must replace its functionality but keep it as fallback
- `ai_seekho_backend/services/intent_service.py` — working Gemini + heuristic NLP; call as a tool
- `ai_seekho_backend/services/provider_service.py` — working 9-factor matching algorithm; call as a tool
- `ai_seekho_backend/services/pricing_service.py` — working dynamic pricing engine; call as a tool
- `ai_seekho_backend/services/dispute_service.py` — working rule-based + Gemini dispute engine; call as a tool
- `ai_seekho_backend/services/scheduling_service.py` — working double-booking validator; call as a tool

### Task 1.1 — Implement `agents/shared/tools.py`

Create `ai_seekho_backend/agents/shared/tools.py`. This file defines all callable tools that agents will invoke via Gemini function calling.

Each tool must be defined as:
1. A regular Python function with type annotations and a docstring
2. A corresponding `genai.protos.FunctionDeclaration` for the Gemini API
3. A dispatcher that maps function name (string) to the actual function

Implement these tools by wrapping the existing service functions:

```python
# Tool: understand_request_tool
# Wraps: services/intent_service.parse_user_intent()
# Input: query (str)
# Output: dict with service_type, urgency, specializations, budget_limit,
#         location_mention, confidence, urdu_reasoning, english_reasoning,
#         follow_up_question (populated if confidence < 0.70)
# Special behavior: if confidence < 0.70, populate follow_up_question with
#   the single most important missing field as a polite Roman Urdu question.
#   Example: if location_mention is None → "Aap ka area ya sector kaunsa hai?"

# Tool: search_providers_tool
# Wraps: services/provider_service.get_matching_providers()
# Input: user_lat (float), user_lng (float), parsed_intent (dict), limit (int, default 5)
# Output: list of provider dicts with match_score, match_factors, distance_km appended

# Tool: generate_price_quote_tool
# Wraps: services/pricing_service.generate_price_quote()
# Input: provider (dict), distance_km (float), parsed_intent (dict)
# Output: PriceQuoteResponse serialized as dict

# Tool: validate_slot_tool
# Wraps: services/scheduling_service.validate_provider_schedule()
# Input: provider_id (str), requested_time (str ISO 8601), provider_slots (list[str])
# Output: dict { "available": bool, "message": str, "next_available_slot": str|None }
# Special behavior: if not available, compute and return the next available slot
#   by iterating provider_slots and finding the earliest that has no Firestore conflict.

# Tool: create_booking_tool
# Wraps: logic from main.py POST /api/booking/create
# Input: user_id, provider_id, service_type, scheduled_time, location_address,
#        lat, lng, price_quote (dict), intent_raw, intent_parsed (dict)
# Output: dict { "bid": str, "status": "pending", "booking": dict }
# Behavior: calls validate_slot_tool first; if conflict, returns
#   { "available": false, "suggested_slot": str } without creating a booking.

# Tool: compute_refund_amount_tool
# Logic: standalone, not a wrapper
# Input: dispute_type (str), total_paid (int), base_fee (int)
# Output: dict { "resolution_type": str, "amount_pkr": int, "reasoning": str }
# Implement the refund table:
#   no_show      → 100% of total_paid + PKR 100 inconvenience credit
#   overrun      → 20% of total_paid
#   quality      → 30–50% based on description keyword severity
#   price        → exact overcharge (total_paid - original_quote) or 30% flat if unknown
#   cancellation → PKR 150 travel allowance to provider

# Tool: update_provider_reputation_tool
# Wraps: new Firestore logic (implement inline)
# Input: provider_id (str), new_rating (float 1-5), dispute_type (str|None),
#        offense_count (int)
# Output: dict { "updated_rating": float, "penalty_applied": bool, "action": str }
# Behavior:
#   - Read current provider from Firestore providers collection
#   - Compute new rolling average: new_avg = (old_avg * old_count + new_rating) / (old_count + 1)
#   - Update rating and rating_count in Firestore
#   - If dispute_type is not None:
#       1st offense → log warning in provider doc (warnings array)
#       2nd same offense in 30 days → apply match_score_penalty: -0.15 for 30 days
#       3rd offense or fraud → set provider.flagged = true (hidden from search)
#   - Falls back gracefully if Firestore unavailable
```

**Dispatcher function signature:**

```python
def execute_tool(tool_name: str, tool_args: dict) -> dict:
    """
    Central dispatcher. Called by agent run loops to execute tool calls
    returned by the Gemini API function calling response.
    Maps tool_name string → actual function call → returns result dict.
    Wraps all calls in try/except and returns {"error": str} on failure.
    """
```

**Function declarations for Gemini API:**
Create a list `ALL_TOOL_DECLARATIONS: list[genai.protos.FunctionDeclaration]` containing properly typed declarations for all 7 tools above. Use `genai.protos.Schema` with correct `type_` values. This list is passed to `GenerativeModel(tools=ALL_TOOL_DECLARATIONS)`.

---

### Task 1.2 — Implement `agents/coordinator_agent.py`

Create `ai_seekho_backend/agents/coordinator_agent.py`.

**Class: `CoordinatorAgent`**

```python
class CoordinatorAgent:
    """
    Agent 1: The Coordinator.
    Goal: Understand exactly what the user needs, find the best provider,
    reason transparently about tradeoffs, and get user confirmation.
    
    Reasoning loop: THINK → ACT (tool call) → OBSERVE → THINK → ACT → PAUSE (human)
    """
    
    def __init__(self):
        # Initialize Gemini model with ALL_TOOL_DECLARATIONS
        # System prompt: use MULTILINGUAL_PARSER_PROMPT from shared/prompts.py
        # Add to it: "You are the Coordinator Agent. You reason step-by-step.
        #   You call tools to gather information. You never hallucinate provider data.
        #   When confidence is below 0.70, you ask ONE clarifying question before proceeding.
        #   You always present tradeoffs honestly to the user."
    
    def run(self, state: CoordinatorState) -> dict:
        """
        Main entry point. Takes a CoordinatorState and returns:
        {
          "action": "ask_clarification" | "show_providers" | "show_quote" | "confirm_booking",
          "message": str,                    # Roman Urdu message for the user
          "message_en": str,                 # English equivalent
          "providers": list[dict] | None,    # populated on show_providers
          "quote": dict | None,              # populated on show_quote
          "trace_events": list[dict],        # all THINK/ACT/OBSERVE events
          "confidence": float,
          "updated_state": CoordinatorState
        }
        """
```

**The run() loop must:**
1. Build a Gemini conversation from `state.messages`
2. Send to Gemini with tool declarations
3. If Gemini returns a `FunctionCall` → call `execute_tool(name, args)` → append result as `FunctionResponse` → loop
4. If Gemini returns text → this is the agent's decision or message to the user
5. Each loop iteration appends a trace event: `{"type": "think"|"act"|"observe", "content": str, "timestamp": ISO}`
6. Stop conditions:
   - Confidence < 0.70 → return `action: "ask_clarification"` with the follow_up_question
   - Providers found + quote computed → return `action: "show_providers"` with ranked list and primary quote
   - User sent confirmation (detected by message content) → return `action: "confirm_booking"`
7. Maximum 8 tool call iterations per run() call to prevent infinite loops

**Agent handoff:**
When `action == "confirm_booking"`, create and return an `AgentHandoff` object:
```python
AgentHandoff(
    from_agent="CoordinatorAgent",
    to_agent="ExecutorAgent",
    reason="User confirmed booking",
    full_context={...all state...},
    urgency=state.extracted_fields.get("urgency", "normal")
)
```

---

### Task 1.3 — Implement `agents/executor_agent.py`

Create `ai_seekho_backend/agents/executor_agent.py`.

**Class: `ExecutorAgent`**

```python
class ExecutorAgent:
    """
    Agent 2: The Executor.
    Goal: Make the booking real. Lock slots atomically. Send confirmations.
    Schedule reminders. Watch for provider no-shows. Handle cancellations.
    
    Reasoning loop: ACT → OBSERVE → DECIDE (escalate or proceed)
    """
    
    def execute_booking(self, handoff: AgentHandoff) -> dict:
        """
        Called after user confirms a booking from CoordinatorAgent.
        Returns:
        {
          "status": "booked" | "conflict" | "failed",
          "booking": dict | None,
          "bid": str | None,
          "confirmation_message": str,           # Roman Urdu
          "confirmation_message_en": str,        # English
          "reminders_scheduled": list[str],      # ISO timestamps for reminders
          "trace_events": list[dict],
          "escalation_needed": bool,
          "escalation_reason": str | None
        }
        """
    
    def handle_provider_cancellation(self, bid: str, provider_id: str) -> dict:
        """
        Called when a provider cancels after confirmation.
        1. Updates booking status to 'cancelled' in Firestore
        2. Re-runs coordinator search for alternative provider (calls search_providers_tool)
        3. Returns alternative provider and new slot suggestion
        4. Sets escalation_needed=True if no alternative found within 10km
        Returns: { "alternative_provider": dict|None, "new_slot": str|None, 
                   "user_message": str, "escalation_needed": bool }
        """
    
    def simulate_reminders(self, bid: str, scheduled_time: str) -> list[dict]:
        """
        Generates a list of reminder payloads (not actually sent via SMS — simulated).
        Returns list of { "reminder_type": str, "trigger_at": ISO str, "message": str }
        Reminders:
          - 24 hours before: "Kal aap ki service hai..."
          - 1 hour before: "1 ghante mein technician pahunche ga..."  
          - Provider en-route (simulated, 30 min before): "Technician raste mein hai..."
        """
```

**execute_booking() must:**
1. Extract `provider_id`, `scheduled_time`, `price_quote`, `lat`, `lng`, `service_type`, `user_id` from `handoff.full_context`
2. Call `validate_slot_tool` — if conflict, return `status: "conflict"` with `suggested_slot`
3. Call `create_booking_tool` — store in Firestore
4. Call `simulate_reminders()` and include in response
5. Generate bilingual confirmation message
6. Append trace events for each step
7. Update Firestore booking doc with `agent_trace_id` reference

---

### Task 1.4 — Implement `agents/guardian_agent.py`

Create `ai_seekho_backend/agents/guardian_agent.py`.

**Class: `GuardianAgent`**

```python
class GuardianAgent:
    """
    Agent 3: The Guardian.
    Goal: Make sure the user got what they paid for.
    Collects feedback, resolves disputes fairly, updates provider reputation.
    
    Fairness principle: "Would a reasonable senior operations manager make this call?"
    Escalate to human when: refund > PKR 2000, or evidence is contradictory,
    or user says 'manager se baat karni hai'.
    """
    
    def collect_feedback(self, bid: str, rating: float, comment: str, user_id: str) -> dict:
        """
        Saves feedback to Firestore feedback collection.
        Calls update_provider_reputation_tool to update provider's rating.
        Returns: { "saved": bool, "new_provider_rating": float, "message": str }
        """
    
    def resolve_dispute(self, dispute_id: str, booking_id: str, 
                       dispute_type: str, description: str) -> dict:
        """
        Uses Gemini + GUARDIAN_SYSTEM_PROMPT to reason through the dispute.
        1. Fetch booking from Firestore (get original quote, provider_id, scheduled_time)
        2. Fetch provider history (cancellation_rate, risk_score, past disputes count)
        3. Call compute_refund_amount_tool with enriched context
        4. If refund > PKR 2000 → set escalation_needed=True, don't auto-resolve
        5. If description contains 'manager se baat' or 'manager chahiye' → escalate
        6. Call update_provider_reputation_tool with offense data
        7. Write dispute resolution to Firestore disputes collection
        8. Return resolution with bilingual explanation
        Returns:
        {
          "resolved": bool,
          "escalation_needed": bool,
          "escalation_reason": str | None,
          "resolution": { "type": str, "amount_pkr": int, "reasoning": str },
          "provider_action": str,
          "user_message_urdu": str,
          "user_message_en": str,
          "trace_events": list[dict]
        }
        """
```

**resolve_dispute() Gemini call:**
- Use `GUARDIAN_SYSTEM_PROMPT` from `shared/prompts.py` as system instruction
- Pass booking data, provider history, and user description to Gemini
- Ask Gemini to reason through the 4-step process defined in the prompt
- Use `compute_refund_amount_tool` and `update_provider_reputation_tool` as function calls
- Do NOT use Gemini to determine the refund amount directly — use the tool for that (keeps logic deterministic and auditable)

---

### Task 1.5 — New Backend Endpoints in `main.py`

Add these endpoints to `ai_seekho_backend/main.py`. **Do NOT remove or modify existing endpoints.**

```python
# POST /api/v1/agent/coordinate
# Body: { "query": str, "lat": float, "lng": float, "session_id": str,
#         "conversation_history": list[dict] }  # optional, for multi-turn
# Returns: CoordinatorAgent.run() result dict
# Side effect: writes trace to Firestore agent_traces collection

# POST /api/v1/agent/execute  
# Body: { "handoff": dict }  # serialized AgentHandoff
# Returns: ExecutorAgent.execute_booking() result dict

# POST /api/v1/agent/resolve
# Body: { "booking_id": str, "dispute_type": str, "description": str, "user_id": str }
# Returns: GuardianAgent.resolve_dispute() result dict

# POST /api/v1/feedback/submit
# Body: { "booking_id": str, "rating": float, "comment": str, "user_id": str }
# Returns: GuardianAgent.collect_feedback() result dict

# GET /api/v1/bookings
# Query params: user_id (str)
# Returns: list of booking dicts from Firestore bookings collection filtered by user_id
# Fallback: returns empty list if Firestore unavailable

# PATCH /api/v1/booking/{bid}/status
# Body: { "status": str }  # one of: confirmed, en_route, in_progress, completed, cancelled
# Returns: { "bid": str, "new_status": str, "updated_at": str }

# Also update: POST /ws/agent-stream (new WebSocket path, keep old /ws/trace/{session_id})
# The new WebSocket accepts { query, lat, lng, session_id, conversation_history }
# It yields the CoordinatorAgent trace events in real-time using yield_orchestrated_matching pattern
# Each yield is { "event": "thinking"|"tool_call"|"tool_result"|"decision"|"completed",
#                 "content": str, "timestamp": str }
```

---

### Phase 1 Verification Checklist

Before moving to Phase 2, verify:
- [ ] `uvicorn main:app --reload` starts without import errors
- [ ] `GET /` returns `{ "status": "online" }` 
- [ ] `POST /api/v1/agent/coordinate` with body `{"query": "AC kharab hai G-13 mein", "lat": 33.649, "lng": 72.973, "session_id": "test-001"}` returns a response with `action` field
- [ ] Response contains `trace_events` array with at least 2 entries
- [ ] `POST /api/v1/agent/resolve` with a test dispute returns a `resolution` with `amount_pkr > 0`
- [ ] `POST /api/v1/feedback/submit` returns `{ "saved": true }`
- [ ] Old endpoints `POST /api/match` and `POST /api/booking/create` still work unchanged
- [ ] `python tests/test_runner.py` still passes all existing tests

---

## PHASE 2 — Bug Fixes + Missing Backend Logic

This phase fixes all bugs and missing logic identified in the gap analysis. It does not touch the Flutter app.

### Task 2.1 — Fix Coordinate Bug in `pricing_service.py`

In `ai_seekho_backend/services/pricing_service.py`, fix the `find_budget_alternative` function:

**Current broken code:**
```python
budget_alt = find_budget_alternative(
    primary_pid=provider["pid"],
    primary_total=total,
    category=category,
    user_lat=provider["location"]["lat"],   # BUG: uses provider coords, not user coords
    user_lng=provider["location"]["lng"],   # BUG
    parsed_intent=parsed_intent
)
```

**Fix:** Add `user_lat: float` and `user_lng: float` as parameters to both `generate_price_quote()` and `find_budget_alternative()`. Update all callers (orchestrator, agents) to pass actual user coordinates. The signature becomes:

```python
def generate_price_quote(
    provider: dict,
    distance_km: float,
    parsed_intent: dict,
    user_lat: float,       # ADD THIS
    user_lng: float        # ADD THIS
) -> PriceQuoteResponse:
```

### Task 2.2 — Real Confidence Scoring in `intent_service.py`

In `ai_seekho_backend/services/intent_service.py`, replace the hardcoded confidence values:

**Current broken pattern in `orchestrator/agent_coordinator.py`:**
```python
confidence=0.95 if "Heuristic" not in intent_parsed.get("urdu_reasoning", "") else 0.80
```

**Fix:** Make `parse_user_intent()` compute actual confidence:
- If Gemini is available and returned all required fields: derive confidence from field completeness
  - All 5 fields present (service_type, urgency, location_mention, budget_limit, specializations): 0.95
  - 4 of 5 fields: 0.80
  - 3 of 5 fields: 0.65 → trigger `follow_up_question`
  - Heuristic fallback used: 0.70
- Add `confidence` and `follow_up_question` to the returned dict from `parse_user_intent()`
- `follow_up_question` should be a polite Roman Urdu string asking for the single most important missing field:
  - `location_mention` is None → `"Aap ka ghar kaunse sector mein hai? (maslan G-13, F-10)"`
  - `budget_limit` is None and urgency is standard → `"Aap ka approximate budget kya hai?"`
  - `service_type` is `general_home` and no specializations → `"Aap ko exactly kya kaam karwana hai?"`

### Task 2.3 — Provider Reputation Persistence

In `ai_seekho_backend/services/provider_service.py`, add a new function:

```python
def update_provider_rating_in_firestore(
    provider_id: str, 
    new_rating: float,
    dispute_type: Optional[str] = None
) -> dict:
    """
    Updates provider rating in Firestore with rolling average.
    Handles offense tracking for dispute penalties.
    Falls back silently if Firestore unavailable.
    """
```

This function should:
1. Read the provider document from Firestore `providers` collection by `pid`
2. Compute rolling average: `new_avg = (old_rating * old_count + new_rating) / (old_count + 1)`
3. Update `rating`, `rating_count`, `updated_at` in Firestore
4. If `dispute_type` is not None, append to `warnings` array in provider doc
5. Count warnings of same type in last 30 days — if >= 2, set `ranking_penalty_until` to 30 days from now
6. If warnings count >= 3 or `risk_score > 0.7`, set `flagged: true`
7. Return `{ "updated_rating": float, "penalty_applied": bool, "action": str }`

Also update `get_matching_providers()` to filter out providers where `flagged == true`.

### Task 2.4 — Scheduling: Return Next Available Slot

In `ai_seekho_backend/services/scheduling_service.py`, update `validate_provider_schedule()`:

Current return: `(bool, str)`
New return: `(bool, str, Optional[str])` where the third value is the next available slot ISO string.

Logic for finding next available slot:
- If the requested time is unavailable, iterate through `provider_slots`
- For each slot, call `check_overlap` against all confirmed Firestore bookings for that provider
- Return the first slot that has no overlap as `next_available_slot`
- If no slots are free, return `None`

### Task 2.5 — Add `.env.example` File

Create `ai_seekho_backend/.env.example`:
```
GEMINI_API_KEY=your_gemini_api_key_here
MAPS_API_KEY=your_google_maps_api_key_here
FIREBASE_CREDENTIALS_PATH=../your-firebase-adminsdk-credentials.json
```

This is the safe version of `.env` with no real credentials.

### Task 2.6 — Update `requirements.txt`

Update `ai_seekho_backend/requirements.txt`:
```
fastapi>=0.111.0
uvicorn[standard]>=0.30.1
google-generativeai>=0.8.0
firebase-admin>=6.5.0
python-dotenv>=1.0.1
pydantic>=2.9.0
pydantic-settings>=2.5.0
websockets>=12.0
httpx>=0.27.0
```

Remove: `langchain>=0.2.0`, `langchain-google-genai>=1.0.0`, `langgraph>=0.1.0` — these are unused and create 300MB of dead dependencies.

---

### Phase 2 Verification Checklist

- [ ] `POST /api/v1/agent/coordinate` query with missing location returns `action: "ask_clarification"` and a `follow_up_question` in Roman Urdu
- [ ] Budget alternative pricing now uses actual user coordinates (not provider coordinates)
- [ ] `validate_provider_schedule()` returns a tuple of 3 values; conflict response includes `next_available_slot`
- [ ] `POST /api/v1/feedback/submit` updates provider rating in Firestore
- [ ] A provider with 3 disputes of same type gets `flagged: true` in Firestore
- [ ] Flagged providers do not appear in matching results

---

## PHASE 3 — Flutter App: Wire Up Missing Flows

This phase connects the Flutter app to the new backend endpoints. All screens that currently use hardcoded mock data will be replaced with real API calls.

### Context You Must Read First

- `ai_seekho_flutter/lib/core/network/api_service.dart` — existing API service; extend it
- `ai_seekho_flutter/lib/core/constants/api_endpoints.dart` — add new endpoint constants here
- `ai_seekho_flutter/lib/features/chat/screens/intent_confirm_screen.dart` — this already calls the backend via WebSocket and HTTP; use it as the model for how other screens should work

### Task 3.1 — Update API Layer

**File: `lib/core/constants/api_endpoints.dart`**

Add:
```dart
static const String agentCoordinate = '/api/v1/agent/coordinate';
static const String agentExecute    = '/api/v1/agent/execute';
static const String agentResolve    = '/api/v1/agent/resolve';
static const String feedbackSubmit  = '/api/v1/feedback/submit';
static const String getBookings     = '/api/v1/bookings';
static const String updateBooking   = '/api/v1/booking';    // + /{bid}/status
static const String wsAgentStream   = '/ws/agent-stream';
```

**File: `lib/core/network/api_service.dart`**

Add methods:
```dart
Future<Map<String, dynamic>> coordinateRequest({
  required String query,
  required double lat,
  required double lng,
  required String sessionId,
  List<Map<String, dynamic>>? conversationHistory,
});

Future<Map<String, dynamic>> executeBooking(Map<String, dynamic> handoff);

Future<Map<String, dynamic>> resolveDispute({
  required String bookingId,
  required String disputeType,
  required String description,
  required String userId,
});

Future<Map<String, dynamic>> submitFeedback({
  required String bookingId,
  required double rating,
  required String comment,
  required String userId,
});

Future<List<Map<String, dynamic>>> getUserBookings(String userId);

Future<Map<String, dynamic>> updateBookingStatus(String bid, String status);

Stream<Map<String, dynamic>> connectAgentStream(String sessionId);
```

**URL configuration fix** — add platform-aware base URL:
```dart
static String get baseUrl {
  // For Android emulator use 10.0.2.2, others use 127.0.0.1
  // In production, replace with your deployed backend URL
  const bool isAndroidEmulator = bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: false);
  return isAndroidEmulator 
    ? 'http://10.0.2.2:8000' 
    : 'http://127.0.0.1:8000';
}
```

### Task 3.2 — Update `intent_confirm_screen.dart` to Use New Endpoint

In `lib/features/chat/screens/intent_confirm_screen.dart`:

Currently calls `POST /api/match`. Change to call `POST /api/v1/agent/coordinate`.

New response shape (from Phase 1):
```json
{
  "action": "ask_clarification" | "show_providers" | "show_quote",
  "message": "Roman Urdu message",
  "message_en": "English message",
  "providers": [...],
  "quote": {...},
  "trace_events": [...],
  "confidence": 0.95,
  "updated_state": {...}
}
```

Handle each `action` value:
- `ask_clarification` → show a dialog or inline message with `response["message"]`, let user reply, then re-call `coordinateRequest` with the updated conversation history appended
- `show_providers` → navigate to `/provider-ranking` passing `response["providers"]` as extra
- `show_quote` → navigate to `/price-breakdown` with quote data

Show `response["confidence"]` in the existing `ConfidenceBadge` widget.

### Task 3.3 — Wire `booking_history_screen.dart` to Real Data

**File: `lib/features/bookings/screens/booking_history_screen.dart`**

Remove the hardcoded `_activeBookings` and `_pastBookings` lists.

Add state management:
```dart
// Use Riverpod FutureProvider or StatefulWidget with initState
// Call: apiService.getUserBookings(currentUserId)
// Where currentUserId comes from a simple shared preference or hardcode 'user_demo_001'
//   (since Firebase Auth is not fully implemented)

// Map response fields to UI:
// bid → booking ID display
// provider_id → show as provider name (you may need to fetch provider name from providers list)
// service_type → capitalize and display
// scheduled_time → format as "Today, 2:30 PM" or "14 May 2026"
// status → map to color: pending=AppColors.lavender, completed=AppColors.success,
//           disputed=AppColors.warning, cancelled=AppColors.error

// Show loading indicator while fetching
// Show "Koi booking nahi mili" (no bookings found) empty state if list is empty
```

### Task 3.4 — Wire `feedback_screen.dart` to Real API

**File: `lib/features/bookings/screens/feedback_screen.dart`**

The star rating UI already exists. Add submission logic:

```dart
// On "Submit Feedback" button press:
// Call: apiService.submitFeedback(
//   bookingId: widget.bookingId,
//   rating: _selectedRating.toDouble(),
//   comment: _commentController.text,
//   userId: 'user_demo_001'  // or real user ID when auth is implemented
// )
// On success: show SnackBar "Shukriya! Aap ka feedback submit ho gaya" then pop
// On error: show SnackBar "Kuch masla hua, dobara koshish karein"
```

### Task 3.5 — Wire `dispute_screen.dart` to Real API

**File: `lib/features/bookings/screens/dispute_screen.dart`**

Currently submitting goes nowhere. Add:

```dart
// On "Submit Dispute" press:
// Call: apiService.resolveDispute(
//   bookingId: widget.bookingId,
//   disputeType: _selectedCategory,  // no_show | quality | price | overrun | cancellation
//   description: _descriptionController.text,
//   userId: 'user_demo_001'
// )
// On success: navigate to /dispute-resolution with the resolution data as extra
// Pass: resolution["resolution"]["type"], resolution["resolution"]["amount_pkr"],
//       resolution["user_message_urdu"], resolution["escalation_needed"]

// Remove the mock photo attachment SnackBar and replace with:
// If user taps "Add Evidence": show a bottom sheet with a placeholder message
// "Photo evidence feature agle update mein aa raha hai" (coming in next update)
// This is honest placeholder behavior, not a fake success message
```

### Task 3.6 — Update `dispute_resolution_screen.dart`

**File: `lib/features/bookings/screens/dispute_resolution_screen.dart`**

Currently uses hardcoded UI. Make it accept data from navigation extras:

```dart
// Accept via GoRouter state.extra as Map<String, dynamic>:
// {
//   "resolution_type": "refund" | "compensation" | "warning" | "none",
//   "amount_pkr": int,
//   "user_message_urdu": str,
//   "user_message_en": str,
//   "escalation_needed": bool
// }

// Display:
// - If escalation_needed: show "Aap ka case human reviewer ko bheja ja raha hai"
//   with a warning icon (AppColors.warning)
// - If refund/compensation: show PKR amount prominently with AppColors.success
// - Show user_message_urdu as the primary message
// - Show user_message_en as smaller subtitle
```

### Task 3.7 — Fix `chat_active_screen.dart` Duplication

**File: `lib/features/chat/screens/chat_active_screen.dart`**

This screen has hardcoded trace steps animated with a Timer. This duplicates `intent_confirm_screen.dart`. Fix:

Option A (recommended): Delete the hardcoded steps. Make `ChatActiveScreen` a simple transition/loading screen that immediately calls `IntentConfirmScreen`'s logic (or just navigate to `/intent-confirm?query=...`). The Timer-animated trace should only live in one place.

Option B: If `ChatActiveScreen` is the entry point (it receives the query), move all WebSocket logic from `intent_confirm_screen.dart` into `chat_active_screen.dart` and make `intent_confirm_screen.dart` a detail-only display. Only do this if the router requires both.

Either way: **Remove the Timer-based hardcoded trace steps**. Real trace steps come from the WebSocket.

### Task 3.8 — Provider Dashboard: Accept/Reject Flow

**File: `lib/features/provider/screens/provider_dashboard_screen.dart`**

Add a "Pending Requests" section that:
1. Calls `apiService.getUserBookings('provider_demo_001')` — same endpoint, different user_id prefix convention
2. Shows bookings with status `pending` as incoming requests
3. Provides "Qabool Karein" (Accept) and "Maafi Chahta Hun" (Decline) buttons
4. Accept → calls `apiService.updateBookingStatus(bid, 'confirmed')`
5. Decline → calls `apiService.updateBookingStatus(bid, 'cancelled')`
6. Shows a count badge on the "Pending" tab

---

### Phase 3 Verification Checklist

- [ ] `intent_confirm_screen.dart` calls `/api/v1/agent/coordinate` and handles all 3 action types
- [ ] Low-confidence query shows clarification dialog in Roman Urdu
- [ ] `booking_history_screen.dart` fetches real data from `/api/v1/bookings?user_id=user_demo_001`
- [ ] `feedback_screen.dart` POST to `/api/v1/feedback/submit` updates provider rating in Firestore
- [ ] `dispute_screen.dart` calls `/api/v1/agent/resolve` and passes response to dispute resolution screen
- [ ] `dispute_resolution_screen.dart` shows escalation state when `escalation_needed: true`
- [ ] Chat active screen does NOT use hardcoded Timer steps
- [ ] Provider dashboard shows and allows action on pending bookings

---

## PHASE 4 — README + Cleanup + Demo Readiness

This phase prepares the project for submission.

### Task 4.1 — Write Complete `README.md`

Create `ai-seekho-hackathon-2026-main/README.md` (replace the current 1-line placeholder).

**Required sections:**

```markdown
# AI Seekho — Hackathon Submission

## Architecture Overview
[Describe the 3-agent system: Coordinator → Executor → Guardian]
[Include ASCII or text diagram showing the flow]
[Describe FastAPI + Firebase + Gemini ADK + Flutter Mobile stack]

## Google ADK Integration
[Explain how CoordinatorAgent, ExecutorAgent, GuardianAgent use Gemini function calling]
[Show a sample agent trace JSON from a real run]
[Explain the THINK→ACT→OBSERVE loop]

## Provider Dataset Schema
[Document every field in providers_mock.json with type and description]
[State: 20 mock providers across 8 service categories, Islamabad coordinates]

## 9-Factor Matching Algorithm
[Document all 9 factors with weights: proximity (20%), rating (15%), on_time (15%), 
 experience (10%), urgency (10%), specialization (10%), price (10%), 
 cancellation (5%), sentiment (5%)]
[Explain the Haversine distance formula used]

## Dynamic Pricing Formula
[Document: Total = ((Base + Urgency + Complexity) × Surge) + VisitFee + DistanceFee − Loyalty]
[List all surge conditions: summer AC peak 1.25×, late night 1.15×]

## API Endpoints Reference
[Table: Method | Path | Description | Request Body | Response]

## Multilingual Support
[Languages: Urdu, Roman Urdu, English, code-switched mixed]
[Mechanism: Gemini 2.5 Flash primary + keyword heuristic fallback]
[Supported queries: AC repair, plumbing, electrical, tutoring, beauty, driving, 
 mechanics, general_home]

## How to Run
[Backend setup steps]
[Flutter setup steps]
[Environment variables]

## Stress Test Scenarios
[Document all 5 stress tests from challenge spec and how system handles each]

## Assumptions and Limitations
[Firebase Auth OTP is simulated]
[SMS/WhatsApp notifications are simulated (payloads generated, not sent)]
[Provider locations are mock data for Islamabad sectors]
[Photo evidence upload is placeholder]

## Cost and Latency Analysis
[Estimate Gemini API cost per request]
[Estimate typical p50/p95 response latency]

## Privacy Note
[No real personal data used]
[All provider data is synthetic]
[Firebase credentials should be rotated after hackathon]
```

### Task 4.2 — Remove Orphaned Placeholder Files

Remove or clearly mark these files as legacy (add `// LEGACY — see features/bookings/` comment at top):
- `lib/features/booking/views/booking_placeholder_screen.dart` (19KB orphan)
- `lib/features/dispute/views/dispute_placeholder_screen.dart` (19KB orphan)
- `lib/features/matching/views/matching_placeholder_screen.dart` (42KB orphan)

These files are not referenced by the router and create confusion. If removal risks breaking anything, add `// NOT USED — superseded by features/bookings/` at the top of each file.

### Task 4.3 — Final Demo Route Setup

In `lib/core/router/app_router.dart`, change `initialLocation` temporarily to `/home` for demo purposes:

```dart
// DEMO MODE: Skip auth for hackathon demo
// Change back to '/' for production
initialLocation: '/home',
```

Add a comment so it's obvious this is a demo-only change.

### Task 4.4 — Seed Firestore Script Documentation

Add a comment block at the top of `ai_seekho_backend/data/seed_firestore.py`:

```python
"""
SETUP STEP: Run this script ONCE before starting the backend server.
It seeds 20 mock providers into your Firestore 'providers' collection.

Usage: python data/seed_firestore.py

Prerequisites:
- FIREBASE_CREDENTIALS_PATH must point to a valid service account JSON
- The Firestore database must exist in your Firebase project
- Firestore rules must allow write access for the service account

If this fails, the backend falls back to providers_mock.json automatically.
"""
```

---

### Phase 4 Verification Checklist (Final Submission Checklist)

- [ ] README.md is complete with all required sections
- [ ] `GET /` returns online with `gemini_api_active: true`
- [ ] Full end-to-end flow works: query → intent → providers → price → book → feedback
- [ ] Low-confidence query triggers clarification question in Roman Urdu
- [ ] Dispute flow resolves with correct PKR amount and bilingual explanation
- [ ] Provider ranking shows 9-factor match scores
- [ ] Booking history shows real Firestore data
- [ ] Agent trace panel shows real trace events (not hardcoded timer steps)
- [ ] Provider dashboard shows pending bookings with accept/reject
- [ ] `python tests/test_runner.py` passes all tests
- [ ] No import errors in Flutter: `flutter analyze` returns 0 errors
- [ ] Orphaned placeholder screens are removed or marked
- [ ] `.gitignore` is updated (see Section 2 below)
- [ ] `requirements.txt` has no unused packages

---

## Summary of All Files to Create/Modify

| File | Operation | Phase |
|---|---|---|
| `agents/shared/tools.py` | CREATE (was empty) | 1 |
| `agents/coordinator_agent.py` | CREATE (was empty) | 1 |
| `agents/executor_agent.py` | CREATE (was empty) | 1 |
| `agents/guardian_agent.py` | CREATE (was empty) | 1 |
| `agents/shared/prompts.py` | EXTEND (has content) | 1 |
| `agents/shared/state.py` | EXTEND (has content) | 1 |
| `main.py` | ADD new endpoints only | 1 |
| `services/pricing_service.py` | FIX coordinate bug | 2 |
| `services/intent_service.py` | ADD real confidence + follow_up_question | 2 |
| `services/provider_service.py` | ADD reputation update function | 2 |
| `services/scheduling_service.py` | ADD next_slot return value | 2 |
| `.env.example` | CREATE | 2 |
| `requirements.txt` | REMOVE unused packages | 2 |
| `lib/core/constants/api_endpoints.dart` | ADD new endpoints | 3 |
| `lib/core/network/api_service.dart` | ADD new methods + URL fix | 3 |
| `lib/features/chat/screens/intent_confirm_screen.dart` | UPDATE to new endpoint | 3 |
| `lib/features/bookings/screens/booking_history_screen.dart` | WIRE to real API | 3 |
| `lib/features/bookings/screens/feedback_screen.dart` | WIRE to real API | 3 |
| `lib/features/bookings/screens/dispute_screen.dart` | WIRE to real API | 3 |
| `lib/features/bookings/screens/dispute_resolution_screen.dart` | ACCEPT dynamic data | 3 |
| `lib/features/chat/screens/chat_active_screen.dart` | REMOVE hardcoded timer | 3 |
| `lib/features/provider/screens/provider_dashboard_screen.dart` | ADD accept/reject | 3 |
| `README.md` | CREATE (was 1 line) | 4 |
| `ai_seekho_backend/.env.example` | CREATE | 4 |
| `data/seed_firestore.py` | ADD documentation comment | 4 |
| 3× placeholder `_screen.dart` files | MARK as legacy | 4 |
| `lib/core/router/app_router.dart` | CHANGE initialLocation for demo | 4 |

---

---

# SECTION 2 — GITIGNORE / SECRET FILES AUDIT

## Executive Summary

There is **no `.gitignore` at the repository root**, and **no `.gitignore` in the backend directory** at all. There is only one `.gitignore` in the Flutter subdirectory (which is the Flutter default, not customized). This means **extremely sensitive credentials have been committed to version control**, including a live Firebase private key and live Google API keys.

---

## Critical Security Violations

### 🔴 SEVERITY: CRITICAL — Exposed Live Private Key

**File:** `ai-seekho--01-firebase-adminsdk-fbsvc-ff54490668.json`
**Location:** Root of the repository (`ai-seekho-hackathon-2026-main/`)

**What it contains:**
- `type: service_account` — full admin access to the Firebase project
- `private_key` — RSA 2048-bit private key (begins `-----BEGIN PRIVATE KEY-----`)
- `private_key_id: ff54490668...` — key identifier
- `client_email` — service account email address
- `project_id: ai-seekho--01`

**Risk:** Anyone with this file has full admin read/write access to your Firestore database, Firebase Auth user database, Firebase Storage, and all other Firebase services in project `ai-seekho--01`. This key can be used to read all user data, delete all bookings, and impersonate the app indefinitely.

**Action required:** 
1. Add to `.gitignore` immediately
2. **Revoke and rotate this key** in Firebase Console → Project Settings → Service Accounts → Generate new private key → Delete old key. Rotating is mandatory because the key is already in Git history.

---

### 🔴 SEVERITY: CRITICAL — Live API Keys in `.env`

**File:** `ai_seekho_backend/.env`

**Contents exposed:**
- `GEMINI_API_KEY=AIzaSyAIjjajr2BCCy7XISistc9g1XjZVxMS1HM` — live Google AI API key
- `MAPS_API_KEY=AIzaSyBQbngOuuLaHjLKvcC0h5Czy6Qj3hdBTUs` — live Google Maps/Places API key

**Risk:** 
- Gemini API key → anyone can run unlimited AI generation requests billed to your Google account
- Maps API key → anyone can make unlimited Maps, Places, and Directions API calls billed to your account
- Both keys are valid credentials that will continue to work until rotated

**Action required:**
1. Add `.env` to `.gitignore` 
2. **Restrict and rotate both API keys** in Google Cloud Console → APIs & Services → Credentials. At minimum, add HTTP referrer restrictions to the Maps key and IP restrictions to the Gemini key.

---

### 🔴 SEVERITY: CRITICAL — Firebase Android Credentials

**File:** `google-services.json`
**Location:** Root of the repository

**What it contains:**
- `project_id: ai-seekho--01`
- `mobilesdk_app_id` — Android app identifier
- `api_key` (Firebase web/Android API key)
- `storage_bucket`, `project_number`

**Risk:** Exposes Firebase project identifiers and Android API key. While this key has lower privileges than the Admin SDK key, it can be used to make Firebase REST API calls, access Firestore (if rules are open), and Firebase Storage.

**Action required:** Add to `.gitignore`. For production apps this file has some risk, but for a hackathon demo the main concern is Firestore rules being open.

---

## High Severity — Should Not Be Committed

### 🟠 Python Bytecode Cache Directories

**Files:**
- `ai_seekho_backend/__pycache__/` (all `.pyc` files)
- `ai_seekho_backend/config/__pycache__/`
- `ai_seekho_backend/services/__pycache__/`
- `ai_seekho_backend/models/__pycache__/`
- `ai_seekho_backend/orchestrator/__pycache__/`
- `ai_seekho_backend/data/__pycache__/`

**Why problematic:**
- Compiled bytecode is CPU-architecture and Python-version specific — it will be wrong for anyone running a different Python version
- These files are 10–14KB each (total ~80KB of junk in the repo)
- They regenerate automatically on first `python` invocation
- They can contain absolute path information from the developer's machine, which is an information disclosure issue
- They inflate the repo size and make PRs noisy

---

### 🟠 Flutter Lock File (Opinion: Should Stay)

**File:** `ai_seekho_flutter/pubspec.lock`

**Context:** This is debated. For application projects (not libraries), `pubspec.lock` should be committed — it ensures reproducible builds. The Flutter `.gitignore` default also keeps it.

**Recommendation:** Keep this file committed. It is correct to have it. No action needed.

---

## Medium Severity — Clutter and Maintenance Risk

### 🟡 Empty Agent Files Committed

**Files:**
- `ai_seekho_backend/agents/coordinator_agent.py` (0 bytes)
- `ai_seekho_backend/agents/executor_agent.py` (0 bytes)
- `ai_seekho_backend/agents/guardian_agent.py` (0 bytes)
- `ai_seekho_backend/agents/shared/tools.py` (0 bytes)

**Why problematic:** Empty files committed to version control look like unfinished work to judges and reviewers. They cause confusion — is this intentional? Is it broken? These will be filled in Phase 1, but as-is they are a signal of incomplete implementation.

**Recommendation:** Either fill these files (via the Phase 1 implementation) or add a `# TODO: Implement — see AI_agent_implementation_plan` comment at minimum. Do not leave 0-byte Python files.

---

### 🟡 Orphaned Placeholder Screens

**Files:**
- `lib/features/booking/views/booking_placeholder_screen.dart` (19KB)
- `lib/features/dispute/views/dispute_placeholder_screen.dart` (19KB)
- `lib/features/matching/views/matching_placeholder_screen.dart` (42KB)

Not sensitive, but they inflate the repo (80KB total), confuse code reviewers, and duplicate functionality now handled by `features/bookings/`. These should be deleted or clearly marked.

---

### 🟡 `.env` Not in `.gitignore` (Backend Has No `.gitignore` At All)

The entire `ai_seekho_backend/` directory has no `.gitignore`. This allowed `.env` and `__pycache__/` to be committed.

---

## The Fix — Complete `.gitignore` Files

### Root-Level `.gitignore` (CREATE THIS FILE)

Create `ai-seekho-hackathon-2026-main/.gitignore`:

```gitignore
# ============================================================
# ROOT .gitignore — AI Seekho Hackathon Project
# ============================================================

# -----------------------------------------------
# CRITICAL: Firebase Service Account Credentials
# NEVER commit these — they grant full Firebase admin access
# -----------------------------------------------
*-firebase-adminsdk-*.json
firebase-adminsdk-*.json
service-account*.json
service_account*.json

# Android Firebase config (contains API keys)
google-services.json

# iOS Firebase config (if present)
GoogleService-Info.plist

# -----------------------------------------------
# Python Backend
# -----------------------------------------------
ai_seekho_backend/.env
ai_seekho_backend/__pycache__/
ai_seekho_backend/**/__pycache__/
ai_seekho_backend/**/*.pyc
ai_seekho_backend/**/*.pyo
ai_seekho_backend/**/*.pyd
ai_seekho_backend/.venv/
ai_seekho_backend/venv/
ai_seekho_backend/env/
ai_seekho_backend/*.egg-info/
ai_seekho_backend/dist/
ai_seekho_backend/build/
ai_seekho_backend/.pytest_cache/
ai_seekho_backend/.coverage
ai_seekho_backend/htmlcov/
ai_seekho_backend/*.log

# -----------------------------------------------
# IDE / Editor
# -----------------------------------------------
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# -----------------------------------------------
# OS artifacts
# -----------------------------------------------
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Desktop.ini
```

---

### Backend-Level `.gitignore` (CREATE THIS FILE)

Create `ai_seekho_backend/.gitignore`:

```gitignore
# ============================================================
# BACKEND .gitignore — ai_seekho_backend
# ============================================================

# Environment variables — NEVER commit real credentials
.env
.env.local
.env.production
.env.staging

# Firebase credentials — NEVER commit
*-firebase-adminsdk-*.json
*.json.key

# Python compiled files
__pycache__/
*.py[cod]
*$py.class
*.pyc
*.pyo
*.pyd

# Virtual environments
.venv/
venv/
env/
ENV/
.env/

# Distribution / packaging
.eggs/
*.egg-info/
dist/
build/
*.egg
MANIFEST

# Testing
.pytest_cache/
.coverage
.coverage.*
htmlcov/
.tox/
.nox/
coverage.xml
*.cover
*.py,cover

# Logging
*.log
logs/

# Type checking
.mypy_cache/
.dmypy.json
dmypy.json
.pytype/

# Jupyter notebooks (if any)
.ipynb_checkpoints/

# Profiling
*.prof
```

---

### Update Flutter `.gitignore` (MODIFY EXISTING)

The Flutter `.gitignore` at `ai_seekho_flutter/.gitignore` is mostly good (it's the Flutter default). Add these lines at the bottom:

```gitignore
# ============================================================
# AI Seekho — Additional Flutter .gitignore entries
# ============================================================

# Firebase Android config — already at root level but protect here too
android/app/google-services.json

# Firebase iOS config
ios/Runner/GoogleService-Info.plist

# Generated files
lib/generated_plugin_registrant.dart

# Dart generated code
*.g.dart
*.freezed.dart

# Build outputs
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
```

---

## Complete File Risk Summary

| File | Severity | Risk Type | Action |
|---|---|---|---|
| `ai-seekho--01-firebase-adminsdk-*.json` | 🔴 CRITICAL | Live private key — full Firebase admin access | Delete from repo, rotate key, add to root .gitignore |
| `ai_seekho_backend/.env` | 🔴 CRITICAL | Live Gemini + Maps API keys | Delete from repo, rotate keys, add to backend .gitignore |
| `google-services.json` | 🔴 CRITICAL | Firebase Android API key + project config | Add to root .gitignore, evaluate necessity |
| `ai_seekho_backend/**/__pycache__/` | 🟠 HIGH | Compiled bytecode, path leakage, repo bloat | Add `**/__pycache__/` to backend .gitignore |
| Empty agent `.py` files (0 bytes) | 🟡 MEDIUM | Signals incomplete work to judges | Implement (Phase 1) or add TODO comment |
| 3× `*_placeholder_screen.dart` | 🟡 MEDIUM | Repo bloat, code confusion | Delete or mark legacy (Phase 4) |
| Missing root `.gitignore` | 🟡 MEDIUM | All future secrets will be committed by default | Create root .gitignore immediately |
| Missing backend `.gitignore` | 🟡 MEDIUM | `.env` and `__pycache__` will keep being committed | Create backend .gitignore immediately |

---

## Immediate Actions Required (Before Any Further Commits)

1. **Run this now:**
   ```bash
   # Remove sensitive files from Git tracking (they stay on disk)
   git rm --cached ai-seekho--01-firebase-adminsdk-fbsvc-ff54490668.json
   git rm --cached google-services.json
   git rm --cached ai_seekho_backend/.env
   git rm -r --cached ai_seekho_backend/__pycache__/
   find ai_seekho_backend -name "__pycache__" -exec git rm -r --cached {} + 2>/dev/null
   ```

2. **Create all three `.gitignore` files** as defined above

3. **Rotate credentials** in:
   - Firebase Console → Project Settings → Service Accounts → Generate new key → Delete old
   - Google Cloud Console → APIs & Services → Credentials → Regenerate Gemini and Maps keys

4. **Commit the `.gitignore` changes** before committing any new Phase 1–4 code

> ⚠️ **Note:** Removing files from Git tracking with `git rm --cached` only stops future commits — the credentials are still in the Git history. If this is a public repository, the keys must be rotated even if the files are removed, because anyone who cloned the repo before removal already has the credentials.
