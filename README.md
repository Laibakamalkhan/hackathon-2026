# AI Seekho — Xidmat Agents Platform

> **Pakistan's first AI-powered informal economy service marketplace** — connecting seekers with skilled artisans via a 3-agent Gemini-powered orchestration layer.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Google ADK Integration](#2-google-adk-integration)
3. [Provider Schema](#3-provider-schema)
4. [9-Factor Matching Algorithm](#4-9-factor-matching-algorithm)
5. [Dynamic Pricing Formula](#5-dynamic-pricing-formula)
6. [API Reference](#6-api-reference)
7. [Multilingual Support](#7-multilingual-support)
8. [How to Run](#8-how-to-run)
9. [Stress Test Results](#9-stress-test-results)
10. [Assumptions & Constraints](#10-assumptions--constraints)
11. [Cost & Latency Budget](#11-cost--latency-budget)
12. [Privacy Note](#12-privacy-note)

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Frontend (Dart)                    │
│  ChatHomeScreen → IntentConfirmScreen → ProviderRanking     │
│  BookingHistory → FeedbackScreen → DisputeResolution        │
└───────────────────────┬─────────────────────────────────────┘
                        │ HTTP / WebSocket
┌───────────────────────▼─────────────────────────────────────┐
│              FastAPI Backend (Python 3.11+)                  │
│                                                              │
│  POST /api/v1/agent/coordinate   ← CoordinatorAgent         │
│  POST /api/v1/agent/execute      ← ExecutorAgent            │
│  POST /api/v1/agent/resolve      ← GuardianAgent            │
│  POST /api/v1/feedback/submit    ← GuardianAgent            │
│  GET  /api/v1/bookings           ← Firestore query          │
│  PATCH /api/v1/booking/{bid}/status ← Firestore update      │
│  WS   /ws/agent-stream           ← Real-time trace stream   │
└───────┬───────────────────────────────────────┬─────────────┘
        │ Gemini 2.5 Flash                      │ Firebase Admin SDK
┌───────▼────────────┐              ┌────────────▼────────────┐
│  Google AI Studio  │              │   Cloud Firestore        │
│  Function Calling  │              │  /bookings /providers   │
│  (7 tools)         │              │  /feedback  /disputes   │
└────────────────────┘              └─────────────────────────┘
```

### 3-Agent System

| Agent | File | Responsibility |
|-------|------|----------------|
| **CoordinatorAgent** | `agents/coordinator_agent.py` | Understand → Search → Quote → Confirm |
| **ExecutorAgent** | `agents/executor_agent.py` | Lock slot → Create booking → Schedule reminders |
| **GuardianAgent** | `agents/guardian_agent.py` | Collect feedback → Resolve disputes → Update reputation |

---

## 2. Google ADK Integration

The system uses **Gemini 2.5 Flash** with **function calling** (Google AI Python SDK ≥ 0.8.0). All 7 tools are declared as `genai.protos.FunctionDeclaration` objects and passed to `GenerativeModel(tools=ALL_TOOL_DECLARATIONS)`.

### Tool Registry (`agents/shared/tools.py`)

| Tool | Purpose |
|------|---------|
| `understand_request_tool` | Parses Urdu/Roman Urdu/English queries → structured intent |
| `search_providers_tool` | 9-factor ranked provider search (excludes flagged) |
| `generate_price_quote_tool` | Dynamic pricing formula + budget alternative |
| `validate_slot_tool` | Firestore conflict detection + next available slot |
| `create_booking_tool` | Atomic booking creation with slot validation |
| `compute_refund_amount_tool` | Deterministic refund table (no hallucination) |
| `update_provider_reputation_tool` | Rolling average + offense tracking + flagging |

### Reasoning Loop (CoordinatorAgent)
```
THINK → ACT (tool_call) → OBSERVE (tool_result) → THINK → ACT → PAUSE (human-in-loop)
Max 8 tool calls per turn. Fallback to direct tool execution if Gemini unavailable.
```

---

## 3. Provider Schema

```json
{
  "pid": "P-001",
  "name": "Kamran Khan",
  "service_category": "ac_repair",
  "location": { "lat": 33.6844, "lng": 72.9747 },
  "availability_slots": ["2026-05-20T09:00:00", "2026-05-20T14:00:00"],
  "base_rate_pkr": 800,
  "per_km_rate": 25,
  "visit_fee_pkr": 150,
  "rating": 4.7,
  "rating_count": 43,
  "jobs_completed": 312,
  "years_experience": 8,
  "verified": true,
  "flagged": false,
  "specializations": ["inverter_ac", "gas_refilling"],
  "languages": ["urdu", "punjabi"],
  "warnings": [],
  "risk_score": 0.05
}
```

---

## 4. 9-Factor Matching Algorithm

**File:** `services/provider_service.py → calculate_match_score()`

| Factor | Max Weight | Logic |
|--------|-----------|-------|
| Service Category Match | 30 pts | Exact: 30, Partial: 15, None: 0 |
| Distance Score | 25 pts | `25 × (1 − d/10)` capped at 10km |
| Rating Score | 15 pts | `15 × (rating/5)` |
| Experience Score | 10 pts | `2 pts/year` capped at 10 |
| Availability Score | 5 pts | Slot within 2 hours: 5, today: 3, week: 1 |
| Verified Badge | 5 pts | `verified == true` |
| Urgency Match | 5 pts | High urgency + high rating: 5 |
| Specialization Match | 5 pts | `2 pts/matched spec` capped at 5 |
| Reputation Penalty | −5 to 0 | Applied 30-day window after 2nd offense |

**Total: 100 points. Flagged providers are excluded entirely.**

---

## 5. Dynamic Pricing Formula

**File:** `services/pricing_service.py`

```
Total PKR = ((Base + Urgency + Complexity) × Surge) + VisitFee + DistanceFee − LoyaltyDiscount
```

| Variable | Value |
|----------|-------|
| `Base` | Provider's `base_rate_pkr` |
| `Urgency` | High: +PKR 300, Standard: +PKR 0 |
| `Complexity` | Specialization detected: +PKR 200 |
| `Surge` | Time-of-day multiplier (1.0–1.4×) |
| `VisitFee` | Fixed `visit_fee_pkr` |
| `DistanceFee` | `distance_km × per_km_rate` |
| `LoyaltyDiscount` | Rating ≥ 4.8: −PKR 50 |

---

## 6. API Reference

### New v1 Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/agent/coordinate` | Run CoordinatorAgent (intent → providers → quote) |
| `POST` | `/api/v1/agent/execute` | Run ExecutorAgent (lock slot + create booking) |
| `POST` | `/api/v1/agent/resolve` | Run GuardianAgent (dispute resolution) |
| `POST` | `/api/v1/feedback/submit` | Submit feedback + update provider reputation |
| `GET` | `/api/v1/bookings?user_id=X` | Get all bookings for user |
| `PATCH` | `/api/v1/booking/{bid}/status` | Update booking status |
| `WS` | `/ws/agent-stream` | Real-time agent trace stream |

### Legacy Endpoints (unchanged)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/match` | Legacy orchestrated matching |
| `POST` | `/api/booking/create` | Legacy booking creation |
| `POST` | `/api/dispute/create` | Legacy dispute |
| `GET` | `/api/providers` | All providers list |
| `WS` | `/ws/trace/{session_id}` | Legacy trace stream |

---

## 7. Multilingual Support

The platform supports **3 languages simultaneously**:

| Language | Usage |
|----------|-------|
| **Urdu (Roman)** | Primary user queries, agent messages, follow-up questions |
| **Urdu (Nastaleeq)** | UI labels, bilingual headings |
| **English** | Technical logs, API responses, fallback |

**Examples:**
- Query: `"mera AC theek karo G-13 mein, jaldi"`
- Follow-up: `"Aap ka budget kya hai? (maslan PKR 1000-2000)"`
- Confirmation: `"Bohat acha! Aap ki booking confirm ho rahi hai!"`

---

## 8. How to Run

> ⚠️ **Submission app:** `kaarigar_frontend/ai_seekho_flutter_frontend/`  
> The folder `ai_seekho_flutter/` is a **legacy prototype** — it is **NOT** the submission app. Do not run it as the primary frontend.

### Backend

```bash
# Windows PowerShell
cd ai_seekho_backend

# Install dependencies
pip install -r requirements.txt

# Create .env from template (Windows)
copy .env.example .env
# Linux/Mac: cp .env.example .env
# Fill in: GEMINI_API_KEY, MAPS_API_KEY, FIREBASE_CREDENTIALS_PATH

# Seed Firestore with provider profiles (optional but recommended)
python data/seed_firestore.py

# Start server
uvicorn main:app --reload --port 8000

# Verify backend is live
curl http://localhost:8000/
# → {"status": "online", "app": "AI Seekho Engine", ...}
```

### KARIGAR Frontend — Android Emulator

```bash
cd kaarigar_frontend/ai_seekho_flutter_frontend
flutter pub get
flutter run --dart-define=ANDROID_EMULATOR=true
```

The `--dart-define=ANDROID_EMULATOR=true` flag switches the backend host from `127.0.0.1:8000` to `10.0.2.2:8000` (Android emulator loopback). Omit the flag when running on a physical device or iOS simulator.

### KARIGAR Frontend — Physical Device / iOS Simulator

```bash
cd kaarigar_frontend/ai_seekho_flutter_frontend
flutter pub get
flutter run
```

### Full architecture and API contract details

See [ARCHITECTURE.md](./ARCHITECTURE.md).

---

## 9. Stress Test Results

| Endpoint | Avg Latency | P95 | Notes |
|----------|------------|-----|-------|
| `POST /api/v1/agent/coordinate` | 1.2s | 2.8s | Gemini API call + 2 tool calls |
| `POST /api/v1/agent/resolve` | 1.8s | 3.5s | Gemini reasoning + Firestore write |
| `GET /api/v1/bookings` | 180ms | 420ms | Firestore query |
| `POST /api/v1/feedback/submit` | 220ms | 380ms | Firestore write + rating update |
| `GET /api/providers` | 45ms | 90ms | JSON file read (no DB) |

*Tested with 50 concurrent requests via httpx async client. Gemini latencies subject to API rate limits.*

---

## 10. Assumptions & Constraints

- **Location**: Demo coordinates fixed at Islamabad (lat: 33.649, lng: 72.973). GPS integration is a future milestone.
- **Payments**: No real payment processing — price quotes are informational only.
- **SMS Reminders**: Simulated via `executor_agent.simulate_reminders()` — not actually sent.
- **Photo Evidence**: Dispute photo upload is a placeholder (bottom sheet shown).
- **Authentication**: Demo uses `user_demo_001` and `provider_demo_001` hardcoded IDs. Firebase Auth is wired but not enforced in demo mode.
- **Provider Data**: Seeded from `data/provider_profiles.json`. Real providers would self-register.

---

## 11. Cost & Latency Budget

| Resource | Est. Cost (per 1000 requests) |
|----------|------------------------------|
| Gemini 2.5 Flash (input) | ~$0.075 (300K tokens) |
| Gemini 2.5 Flash (output) | ~$0.30 (100K tokens) |
| Cloud Firestore reads | ~$0.06 (200K reads) |
| Cloud Firestore writes | ~$0.18 (60K writes) |
| **Total** | **~$0.615 / 1000 sessions** |

Target end-to-end latency: **< 3 seconds** for coordinate endpoint.

---

## 12. Privacy Note

- All provider data is **mock/seed data** — no real personal information.
- Firebase Admin SDK credentials are **never committed** to this repository (covered by `.gitignore`).
- User queries are processed by Google Gemini API — subject to [Google's Privacy Policy](https://policies.google.com/privacy).
- Location data is not stored persistently — used only for real-time matching.
- All Firestore data is stored in `asia-south1` (Mumbai) region for Pakistan proximity.

---

*Built for AI Seekho Hackathon 2026 — Islamabad, Pakistan 🇵🇰*