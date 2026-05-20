# KARIGAR Platform — Architecture Reference

> **Last updated:** 2026-05-21  
> This document is the single source of truth for project structure, API contracts, data flow, and environment configuration.

---

## 1. Repository Layout

```
ai-seekho-hackathon-2026/
├── ai_seekho_backend/                  ← Python FastAPI backend (canonical)
│   ├── agents/                         ← CoordinatorAgent, ExecutorAgent, GuardianAgent
│   │   └── shared/                     ← state.py (CoordinatorState, AgentHandoff)
│   ├── config/                         ← settings.py, firebase_config.py
│   ├── data/                           ← provider_profiles.json, seed_firestore.py
│   ├── models/                         ← booking.py
│   ├── orchestrator/                   ← agent_coordinator.py (legacy orchestrator)
│   ├── services/                       ← provider_service.py, pricing_service.py, etc.
│   ├── tests/
│   ├── main.py                         ← FastAPI app entry point
│   ├── requirements.txt
│   └── .env.example                    ← environment template (no secrets)
│
├── kaarigar_frontend/                  ← CANONICAL FRONTEND (submission app)
│   └── ai_seekho_flutter_frontend/     ← Flutter package: ai_seekho
│       ├── lib/
│       │   ├── core/
│       │   │   ├── constants/
│       │   │   │   └── api_endpoints.dart   ← all URL constants
│       │   │   ├── network/
│       │   │   │   └── http_client.dart
│       │   │   └── theme/
│       │   ├── features/               ← feature-first modules
│       │   ├── models/
│       │   ├── routes/
│       │   ├── services/
│       │   ├── utils/
│       │   ├── widgets/
│       │   └── main.dart               ← KarigarApp entry point
│       └── pubspec.yaml
│
└── ai_seekho_flutter/                  ← LEGACY REFERENCE ONLY — not the submission app
```

> ⚠️ **`ai_seekho_flutter/` is legacy.** It is kept for reference. Do **not** run it as the primary app. The submission frontend is `kaarigar_frontend/ai_seekho_flutter_frontend/`.

---

## 2. Component Roles

| Component | Path | Role |
|-----------|------|------|
| **KARIGAR Frontend** | `kaarigar_frontend/ai_seekho_flutter_frontend/` | Canonical Flutter submission app (package: `ai_seekho`) |
| **FastAPI Backend** | `ai_seekho_backend/` | All API endpoints, agent orchestration, Firestore I/O |
| **CoordinatorAgent** | `agents/coordinator_agent.py` | Intent parsing → provider search → price quote |
| **ExecutorAgent** | `agents/executor_agent.py` | Slot lock → Firestore booking creation → reminders |
| **GuardianAgent** | `agents/guardian_agent.py` | Feedback collection → dispute resolution → reputation update |
| **Legacy Frontend** | `ai_seekho_flutter/` | Old prototype — reference only, do not run |

---

## 3. API Contract Table

### v1 Endpoints (canonical — used by KARIGAR frontend)

| Method | Path | Request Body / Params | Response Shape | Agent |
|--------|------|-----------------------|----------------|-------|
| `GET` | `/` | — | `{status, app, firebase_active, gemini_api_active}` | — |
| `POST` | `/api/v1/agent/coordinate` | `{query, lat, lng, session_id, conversation_history?}` | `{action, message, providers, quote, handoff, trace_events, confidence, trace_id, updated_state}` | CoordinatorAgent |
| `POST` | `/api/v1/agent/execute` | `{handoff: AgentHandoff}` | `{bid, status, scheduled_time, ...}` | ExecutorAgent |
| `POST` | `/api/v1/agent/resolve` | `{booking_id, dispute_type, description, user_id}` | `{dispute_id, resolution, refund_amount, ...}` | GuardianAgent |
| `POST` | `/api/v1/feedback/submit` | `{booking_id, rating, comment, user_id}` | `{saved, new_rating, ...}` | GuardianAgent |
| `GET` | `/api/v1/bookings` | `?user_id=<uid>` | `{bookings: [...], count}` | Firestore query |
| `PATCH` | `/api/v1/booking/{bid}/status` | `{status}` | `{bid, new_status, updated_at}` | Firestore update |
| `WS` | `/ws/agent-stream` | `{query, lat, lng, session_id, conversation_history?}` | Stream: `{event, content, timestamp}` + final `{event:"completed", providers, quote}` | CoordinatorAgent |

#### `AgentHandoff` required fields (from `agents/shared/state.py`)

```
provider_id, provider_name, service_type, scheduled_time,
location_address, lat, lng, price_quote, user_id, session_id
```

#### Valid booking statuses

```
pending | confirmed | en_route | in_progress | completed | cancelled | disputed
```

### Legacy Endpoints (do not use in new code)

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/api/match` | Old orchestrator, broadcasts over `/ws/trace/{session_id}` |
| `POST` | `/api/booking/create` | Pre-v1 booking creation |
| `POST` | `/api/dispute/create` | Pre-v1 dispute |
| `GET` | `/api/providers` | JSON file read, no Firestore |
| `WS` | `/ws/trace/{session_id}` | Legacy trace stream |

---

## 4. WebSocket Event Schema (`/ws/agent-stream`)

**Client → Server** (JSON, on each turn):
```json
{
  "query": "mera AC theek karo G-13 mein, jaldi",
  "lat": 33.649,
  "lng": 72.973,
  "session_id": "sess-abc123",
  "conversation_history": []
}
```

**Server → Client** (stream of events):

| `event` value | Meaning |
|---------------|---------|
| `thinking` | Agent reasoning step (THINK phase) |
| `tool_call` | Agent invoking a tool (ACT phase) |
| `tool_result` | Tool output received (OBSERVE phase) |
| `decision` | Agent made a routing decision |
| `completed` | Final result — includes `providers`, `quote`, `action`, `confidence` |
| `error` | Pipeline error — `content` has the message |

---

## 5. Data Flow Diagram

```
User (Flutter KARIGAR App)
        │
        │  [1] POST /api/v1/agent/coordinate
        │      { query, lat, lng, session_id }
        ▼
  FastAPI Backend (main.py)
        │
        ├─► CoordinatorAgent.run(CoordinatorState)
        │       │
        │       ├─► understand_request_tool   → parsed intent
        │       ├─► search_providers_tool     → ranked provider list
        │       └─► generate_price_quote_tool → price breakdown
        │
        │  [Response] { action, message, providers, quote, handoff }
        ▼
  Flutter UI — User confirms provider & slot
        │
        │  [2] POST /api/v1/agent/execute
        │      { handoff: AgentHandoff }
        ▼
  FastAPI Backend
        │
        ├─► ExecutorAgent.execute_booking(handoff)
        │       │
        │       ├─► validate_slot_tool        → conflict check
        │       ├─► create_booking_tool       → Firestore write (bookings/)
        │       └─► simulate_reminders()      → scheduled SMS (simulated)
        │
        │  [Response] { bid, status: "confirmed", ... }
        ▼
  Flutter UI — BookingHistory refreshed via GET /api/v1/bookings
        │
        │  [3] (Optional) POST /api/v1/feedback/submit
        │      or POST /api/v1/agent/resolve  (dispute)
        ▼
  GuardianAgent
        ├─► collect_feedback()                → rolling rating update
        └─► resolve_dispute()                 → refund table + Gemini reasoning


  Parallel: WS /ws/agent-stream
  ─────────────────────────────
  Flutter opens WebSocket → receives THINK/ACT/OBSERVE events in real-time
  Final "completed" event carries full result (mirrors HTTP response).
```

---

## 6. Environment Variables

All variables are loaded by `config/settings.py` from a `.env` file in `ai_seekho_backend/`.  
See `ai_seekho_backend/.env.example` for the full template.

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | ✅ Yes | Google AI Studio API key for Gemini 2.5 Flash |
| `MAPS_API_KEY` | ⚠️ Optional | Google Maps Platform key (distance matrix, geocoding) |
| `FIREBASE_CREDENTIALS_PATH` | ✅ Yes | Absolute or relative path to Firebase Admin SDK service-account JSON |
| `FIREBASE_PROJECT_ID` | ⚠️ Optional | Firestore project ID (auto-detected from credentials if omitted) |
| `LOG_LEVEL` | ⚠️ Optional | Python logging level; default `INFO` |

> 🔒 **Never commit `.env` or the Firebase Admin JSON.** Both are listed in `ai_seekho_backend/.gitignore`.

---

## 7. Frontend Environment / Dart-Define Flags

| Flag | Values | Effect |
|------|--------|--------|
| `ANDROID_EMULATOR` | `true` / `false` (default) | When `true`, backend host switches from `127.0.0.1` to `10.0.2.2` (Android emulator loopback) |

Pass via:
```bash
flutter run --dart-define=ANDROID_EMULATOR=true
```

---

## 8. Run Commands (quick reference)

### Backend
```bash
# Windows PowerShell
cd ai_seekho_backend
pip install -r requirements.txt
copy .env.example .env        # then fill in your keys
uvicorn main:app --reload --port 8000

# Verify
curl http://localhost:8000/
# → {"status":"online","app":"AI Seekho Engine",...}
```

### KARIGAR Frontend (canonical)
```bash
cd kaarigar_frontend/ai_seekho_flutter_frontend
flutter pub get
flutter run --dart-define=ANDROID_EMULATOR=true   # Android emulator
flutter run                                        # physical device / iOS sim
```

---

## 9. Firestore Collections

| Collection | Key Fields | Written By |
|------------|-----------|------------|
| `bookings` | `bid, user_id, provider_id, status, scheduled_time, price_quote` | ExecutorAgent via `create_booking_tool` |
| `agent_traces` | `trace_id, session_id, agent, query, trace_events` | CoordinatorAgent (after each coordinate call) |
| `providers` | `pid, name, service_category, rating, flagged, ...` | Seeded via `data/seed_firestore.py` |
| `feedback` | `bid, rating, comment, user_id` | GuardianAgent via `collect_feedback` |
| `disputes` | `dispute_id, booking_id, resolution, refund_amount` | GuardianAgent via `resolve_dispute` |

---

## 11. Coordinator Payload Normalisation

Both the HTTP response from `POST /api/v1/agent/coordinate` and the final
`completed` event from `WS /ws/agent-stream` are normalised by the **single**
private method `MatchingNotifier._applyCoordinatorPayload(Map raw)` in
`lib/features/matching/providers/matching_provider.dart`.

Neither `coordinate()` nor `storeCoordinatorResult()` contains its own parse
logic — both delegate to this method. This is the only place field aliasing
should be updated if the backend contract changes.

### Field Mapping Table

| `MatchingState` field | Primary key in payload  | Fallback key                          |
|-----------------------|-------------------------|---------------------------------------|
| `providers`           | `providers`             | `matching_providers`                  |
| `quote`               | `quote`                 | `price_quote`                         |
| `handoff`             | `handoff`               | *(none)*                              |
| `extractedFields`     | `extracted_fields`      | `updated_state.extracted_fields`      |
| `confidence`          | `confidence`            | `updated_state.confidence`            |
| `action`              | `action`                | *(none)*                              |
| `coordinatorResult`   | *(raw map stored as-is — downstream screens read from it directly)* | |

### Offline / WS-Failure Decision Tree

```
Chat initiated
  └─► _connectWebSocket()
        ├─ WS "completed" → storeCoordinatorResult() → _routeOnAction()
        └─ onError / onDone (stage < 4)
              └─► backendOnline?
                    ├─ YES → _retryViaHttp() (automatic, no user tap)
                    │          ├─ HTTP success → cancel timer, stage=4, _routeOnAction()
                    │          └─ HTTP failure → show error panel  [NO timer fallback]
                    └─ NO  → _fallbackToTimer()  (demo offline pipeline)
```

`BackendStatusBanner` (injected globally via `MaterialApp.router builder`) is
the only place that surfaces the offline state to the user; individual screens
do not need their own banners.

---

## 12. Updating This Document

**Always update ARCHITECTURE.md when:**
- A new API endpoint is added or removed
- A Dart-define flag is added or renamed
- A new Firestore collection is introduced
- The canonical frontend path changes
- The coordinator payload field mapping changes (update §11 table)

> This document is checked during PR review for the `ai-seekho-hackathon-2026` repo.
