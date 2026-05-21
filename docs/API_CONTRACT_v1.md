# API Contract v1 (frozen)

Canonical backend: `ai_seekho_backend/` (FastAPI). Canonical consumer app: `kaarigar_frontend/ai_seekho_flutter_frontend/`.

This document freezes field names used in P0–P2 integration. Do not rename without updating both sides and this file.

---

## Agent coordinate

**POST** `/api/v1/agent/coordinate`

Request:
```json
{
  "query": "AC repair chahiye",
  "lat": 33.649,
  "lng": 72.973,
  "session_id": "session-abc",
  "conversation_history": []
}
```

Response (success path, abbreviated):
```json
{
  "action": "show_providers",
  "confidence": 0.91,
  "message": "…",
  "providers": [ { "pid": "P-001", "name": "Ali AC", "match_breakdown": {} } ],
  "quote": { "quote": { "total_pkr": 1200, "currency": "PKR" } },
  "handoff": { "from_agent": "CoordinatorAgent", "to_agent": "ExecutorAgent", "full_context": {} },
  "extracted_fields": { "service_type": "ac_repair", "location_mention": "Bahria Town" },
  "trace_events": [ { "type": "think", "content": "…", "timestamp": "…" } ]
}
```

**`action` values:** `show_providers` | `ask_clarification` | (empty → client infers from `providers` length)

---

## Agent execute

**POST** `/api/v1/agent/execute`

Request:
```json
{
  "handoff": {
    "from_agent": "CoordinatorAgent",
    "to_agent": "ExecutorAgent",
    "reason": "providers_ready_for_user_confirmation",
    "full_context": {
      "provider_id": "P-001",
      "provider": { "pid": "P-001", "name": "Ali AC Services" },
      "parsed_intent": { "service_type": "ac_repair", "user_id": "user_demo_001" },
      "user_lat": 33.649,
      "user_lng": 72.973,
      "scheduled_time": "2026-05-21T10:00:00",
      "service_type": "ac_repair",
      "location_address": "Bahria Town Phase 7",
      "price_quote": { "quote": { "total_pkr": 1200 } }
    },
    "urgency": "standard"
  }
}
```

Response:
```json
{
  "status": "booked",
  "bid": "BK-A1B2C3",
  "booking": {
    "bid": "BK-A1B2C3",
    "provider_id": "P-001",
    "provider_name": "Ali AC Services",
    "service_type": "ac_repair",
    "status": "confirmed",
    "scheduled_time": "2026-05-21T10:00:00",
    "location": { "address": "…", "lat": 33.649, "lng": 72.973 },
    "price_quote": {}
  }
}
```

**Frozen booking fields (Firestore + GET list):** `bid`, `user_id`, `provider_id`, `provider_name`, `service_type`, `status`, `scheduled_time`, `location`, `price_quote`, `created_at`, `updated_at`.

---

## WebSocket agent stream

**WS** `/ws/agent-stream`

Client sends:
```json
{
  "query": "Plumber chahiye",
  "lat": 33.649,
  "lng": 72.973,
  "session_id": "session-abc",
  "conversation_history": []
}
```

Intermediate events: `thinking`, `tool_call`, `tool_result`, `decision` (each with `content`, `timestamp`).

**Completed payload (frozen):**
```json
{
  "event": "completed",
  "content": "…",
  "action": "show_providers",
  "confidence": 0.88,
  "providers": [],
  "quote": {},
  "handoff": {},
  "extracted_fields": {},
  "trace_events": [],
  "timestamp": "2026-05-20T12:00:00"
}
```

Flutter normaliser accepts `event` or `type` = `completed` / `orchestration_completed`.

---

## Bookings

| Method | Path | Body / query |
|--------|------|----------------|
| GET | `/api/v1/bookings?user_id=user_demo_001` | — |
| PATCH | `/api/v1/booking/{bid}/status` | `{ "status"?: string, "scheduled_time"?: ISO8601 }` — at least one required |

**Status values:** `pending`, `confirmed`, `en_route`, `in_progress`, `completed`, `cancelled`, `disputed`

---

## Dispute resolve

**POST** `/api/v1/agent/resolve`

Request:
```json
{
  "booking_id": "BK-A1B2C3",
  "dispute_type": "quality",
  "description": "AC still not cooling",
  "user_id": "user_demo_001"
}
```

**Backend-normalized `dispute_type`:** `no_show` | `quality` | `price` | `overrun` | `cancellation`

**Flutter UI → API mapping** (`dispute_types.dart`):

| UI label | `apiValue` sent |
|----------|-----------------|
| Poor service | `quality` |
| No show | `no_show` |
| Overcharged | `price` |
| Other | `quality` |

Aliases accepted by backend: `poor_service`, `poor service`, `overcharged`, `no show`, etc.

---

## Feedback

**POST** `/api/v1/feedback/submit` — `booking_id`, `rating`, `comment`, `user_id`

---

## Providers list

**GET** `/api/providers` — returns `{ "providers": [ { "pid", "name", "service_categories", … } ] }`

Provider id field for matching/handoff: **`pid`** (Flutter also accepts `id`, `provider_id` defensively).
