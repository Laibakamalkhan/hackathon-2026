# 🤖 AI Seekho — Engineering Blueprint
### AI Service Orchestrator for Pakistan's Informal Economy
**Stack: Flutter · FastAPI · Google ADK · Firebase**

---

> **Challenge**: AI Service Orchestrator for Informal Economy (Challenge 2)  
> **Hackathon**: AI Seekho  
> **Team Mandate**: Build an agentic MVP that automates the full service lifecycle — from Urdu/Roman Urdu voice/text intent to booking, follow-up, and dispute resolution.

---

## TABLE OF CONTENTS

1. [Product Requirements Document (PRD)](#1-product-requirements-document)
2. [System Architecture Document](#2-system-architecture-document)
3. [Agentic AI System Design (Google ADK)](#3-agentic-ai-system-design)
4. [User Flow + UX Document](#4-user-flow--ux-document)
5. [Implementation Roadmap](#5-implementation-roadmap)
6. [AI Coding Execution Document](#6-ai-coding-execution-document)
7. [Security + Safety Document](#7-security--safety-document)
8. [README / Submission Documentation](#8-readme--submission-documentation)
9. [💡 WOW Factor Features](#9-wow-factor-features)

---

# 1. PRODUCT REQUIREMENTS DOCUMENT

## 1.1 Product Vision

**AI Seekho** is an agentic AI platform that digitizes and automates Pakistan's ₨2.5 trillion informal service economy. A user can send a broken Urdu WhatsApp-style message like *"AC bilkul kaam nahi kar raha G-13 kal subah"* and within seconds receive a ranked list of vetted technicians, a transparent price quote, a confirmed booking, automated reminders, and a post-service quality loop — all orchestrated by an autonomous multi-agent system built on Google ADK.

## 1.2 Problem Definition

Pakistan's informal service economy (plumbers, electricians, AC technicians, tutors, beauticians, drivers, mechanics) operates through:

| Pain Point | Impact |
|---|---|
| Discovery via WhatsApp + word-of-mouth | 60%+ of requests go unmatched |
| No standardized pricing | Price disputes in 35% of jobs |
| No scheduling system | Double bookings, no-shows ~20% |
| No trust/reputation layer | Users accept risky unknown providers |
| Urdu/Roman Urdu barrier for apps | 70% of service seekers cannot use English apps |
| Zero post-service accountability | No feedback loop, quality stagnates |

## 1.3 Target Users

**Primary Users (Service Seekers)**
- Urban Pakistani households aged 25–55
- Comfortable with WhatsApp but not formal apps
- Bilingual (Urdu + broken English / Roman Urdu)
- Pain: finding reliable, fairly priced help fast

**Secondary Users (Service Providers)**
- Local tradespeople, technicians, tutors
- Basic smartphone users
- Pain: inconsistent workload, no digital presence, payment uncertainty

## 1.4 User Personas

### Persona A — Ayesha (Service Seeker)
- 34 yo, housewife in G-13, Islamabad
- AC broke on a hot day, needs someone ASAP
- Types in Roman Urdu, expects WhatsApp-level UX
- Budget-conscious, trusts reviews

### Persona B — Tariq (Service Provider)
- 42 yo, AC technician, self-employed
- Gets work via referrals only
- Wants steady bookings, fair rates
- Has Android phone, limited technical skill

### Persona C — Bilal (Power User)
- 28 yo, renting in Karachi, handles all home maintenance
- Needs multiple service types per month
- Values speed and reliability over price

## 1.5 Core Pain Points

1. Language barrier — apps don't understand Roman Urdu / code-switching
2. Trust deficit — no reliable reputation system in informal economy
3. Price opacity — no way to estimate fair cost before commitment
4. Scheduling chaos — no automated double-booking prevention
5. Zero follow-up — no reminders, no accountability post-service
6. No dispute path — unresolved quality/price complaints destroy trust

## 1.6 Solution Strategy

Multi-agent system orchestrated by Google ADK that:
1. Accepts natural language input in any Pakistani language variant
2. Extracts structured intent using LLM + custom NLP
3. Queries provider database with 8+ matching factors
4. Generates dynamic, transparent price quotes
5. Simulates full booking lifecycle with confirmations + calendar
6. Automates follow-up reminders and service quality collection
7. Handles disputes through escalation workflows

## 1.7 Key Differentiators

| Feature | Competitors | AI Seekho |
|---|---|---|
| Language | English only | Urdu / Roman Urdu / English / code-switch |
| Matching | Distance only | 8-factor AI matching with reasoning trace |
| Pricing | Fixed/manual | Dynamic AI-generated transparent quotes |
| Scheduling | Manual | AI-prevented double booking + travel buffers |
| Follow-up | None | Automated reminders + quality feedback loop |
| Disputes | WhatsApp complaint | Structured AI-mediated escalation workflow |
| Transparency | None | Full ADK reasoning trace shown to user |

## 1.8 Success Metrics

| Metric | Target |
|---|---|
| Intent extraction accuracy | > 90% on test corpus |
| Provider match relevance score | > 85% top-3 accuracy |
| Booking simulation completion rate | 100% (demo day) |
| Language handling (Urdu/Roman Urdu/mixed) | > 85% correct parse |
| Dispute workflow coverage | All 6 scenarios handled |
| ADK reasoning trace completeness | 100% logged |
| Demo flow end-to-end latency | < 8 seconds |

## 1.9 Functional Requirements

### FR-1: Intent Understanding
- Accept text input in Urdu, Roman Urdu, English, mixed
- Extract: service_type, location, time_preference, urgency, budget_sensitivity, constraints
- Return confidence score (0–1)
- Ask confirmation questions if confidence < 0.7

### FR-2: Provider Discovery
- Query mock provider dataset (min 50 providers, 8 service categories)
- Optional: Google Maps Places API integration
- Filter by: city, service_type, availability window

### FR-3: Multi-Factor Matching
Rank providers using all 8 factors:
1. Distance / travel time
2. Availability (no conflicts in time window)
3. Rating (0–5 stars, weighted by recency)
4. On-time reliability score
5. Skill specialization match
6. Price vs user budget sensitivity
7. Cancellation rate (penalty)
8. Review sentiment (NLP on recent reviews)

### FR-4: Dynamic Pricing
- Calculate: base_rate + distance_fee + urgency_multiplier + complexity_surcharge - loyalty_discount
- Show itemized breakdown to user
- Apply surge pricing if demand > threshold
- Offer budget-friendly alternative if user is price-sensitive

### FR-5: Booking Simulation
- Confirm slot in calendar (mock or Google Calendar)
- Send WhatsApp/SMS confirmation (simulated)
- Write booking record to Firestore
- Generate booking receipt (PDF or structured message)
- Schedule reminders at T-24h and T-1h

### FR-6: Service Quality Loop
- Simulate en-route status update
- Service completion checklist (provider side)
- Customer feedback collection (1–5 stars + comment)
- Reputation score recalculation
- Match impact update in provider profile

### FR-7: Dispute Handling
Scenarios covered:
- No-show → auto-reschedule or refund simulation
- Cancellation after confirmation → waitlist activation
- Quality complaint → provider review + compensation simulation
- Price disagreement → audit trail review
- Overrun → overtime charge negotiation
- Human escalation → ticket creation + admin notification

## 1.10 Non-Functional Requirements

| NFR | Requirement |
|---|---|
| Response latency | < 3s for intent extraction, < 5s for full match |
| Concurrent users | 100 simultaneous (MVP) |
| Uptime | 99% during demo window |
| Data privacy | No real PII in demo; mock data only |
| Offline handling | Graceful error with retry |
| Accessibility | Readable font sizes, contrast AA |

## 1.11 Edge Cases

1. No provider available in requested window → suggest next available slot + waitlist
2. Provider cancels after confirmation → auto-assign next-best + notify user
3. Ambiguous location (G-13 vs G-13/1, G-13/2) → ask clarifying question
4. Conflicting time request → detect conflict, suggest alternatives
5. Extremely low confidence parse (< 0.4) → ask user to rephrase with example
6. Two users book same provider → second gets waitlisted with ETA
7. Provider with high rating but recent negative reviews → penalize recency-weighted score, surface warning

## 1.12 User Stories

```
US-01: As Ayesha, I want to type my request in Roman Urdu so that I don't have to switch to English.
US-02: As Ayesha, I want to see why a provider was selected so I can trust the recommendation.
US-03: As Ayesha, I want a price breakdown before I confirm so I'm not surprised.
US-04: As Tariq, I want to see my upcoming bookings so I can plan my day.
US-05: As Bilal, I want reminders so I don't miss the technician's arrival window.
US-06: As Ayesha, I want a clear path to dispute if the job quality was poor.
```

## 1.13 Feature Prioritization (MoSCoW)

| Feature | Priority |
|---|---|
| Multilingual intent extraction | Must Have |
| Multi-factor provider matching | Must Have |
| Dynamic pricing with breakdown | Must Have |
| Booking simulation end-to-end | Must Have |
| ADK reasoning traces | Must Have |
| Dispute workflow | Must Have |
| Follow-up / reminders | Should Have |
| Provider workload balancing | Should Have |
| Google Maps integration | Could Have |
| Real WhatsApp notifications | Could Have |
| Provider mobile app | Won't Have (MVP) |

---

# 2. SYSTEM ARCHITECTURE DOCUMENT

## 2.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER MOBILE APP                        │
│  Chat Interface · Booking UI · Provider Cards · Dispute Flow    │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTPS / REST + WebSocket
┌──────────────────────────▼──────────────────────────────────────┐
│                    FASTAPI BACKEND (Python)                       │
│  /api/v1/intent · /api/v1/match · /api/v1/book · /api/v1/agent  │
└─────┬───────────────────┬──────────────────────┬────────────────┘
      │                   │                      │
┌─────▼──────┐   ┌────────▼──────────┐  ┌───────▼────────────────┐
│ GOOGLE ADK │   │    FIREBASE       │  │  EXTERNAL SERVICES      │
│ Agent      │   │  Auth + Firestore │  │  Google Maps Places     │
│ Orchestrat.│   │  + Storage        │  │  Gemini 1.5 Flash       │
│ Traces     │   │  Realtime DB      │  │  SMS/WhatsApp Mock      │
└────────────┘   └───────────────────┘  └────────────────────────┘
```

## 2.2 Frontend Architecture (Flutter)

### Tech Stack
- Flutter 3.x (Dart)
- State management: Riverpod 2.x
- HTTP client: Dio with interceptors
- Local storage: Hive (for caching)
- Chat UI: Custom bubbles + flutter_chat_ui
- Maps: google_maps_flutter
- Push notifications: Firebase Messaging

### Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp + theme
│   ├── router.dart                 # GoRouter config
│   └── theme.dart                  # Colors, typography
├── core/
│   ├── api/
│   │   ├── api_client.dart         # Dio singleton
│   │   ├── api_endpoints.dart      # URL constants
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── error_interceptor.dart
│   ├── firebase/
│   │   ├── firebase_options.dart
│   │   └── firestore_service.dart
│   └── utils/
│       ├── language_detector.dart
│       └── date_formatter.dart
├── features/
│   ├── auth/
│   │   ├── screens/login_screen.dart
│   │   ├── screens/onboarding_screen.dart
│   │   └── providers/auth_provider.dart
│   ├── chat/
│   │   ├── screens/chat_screen.dart    # Main conversation UI
│   │   ├── widgets/
│   │   │   ├── message_bubble.dart
│   │   │   ├── agent_trace_panel.dart  # ADK reasoning view
│   │   │   ├── provider_card.dart
│   │   │   └── booking_confirmation.dart
│   │   └── providers/
│   │       ├── chat_provider.dart
│   │       └── intent_provider.dart
│   ├── booking/
│   │   ├── screens/
│   │   │   ├── booking_detail_screen.dart
│   │   │   ├── booking_history_screen.dart
│   │   │   └── dispute_screen.dart
│   │   └── providers/booking_provider.dart
│   ├── providers_list/
│   │   ├── screens/provider_search_screen.dart
│   │   └── widgets/provider_map_view.dart
│   └── profile/
│       └── screens/profile_screen.dart
├── models/
│   ├── intent_model.dart
│   ├── provider_model.dart
│   ├── booking_model.dart
│   ├── price_quote_model.dart
│   └── agent_trace_model.dart
└── shared/
    ├── widgets/
    │   ├── confidence_badge.dart
    │   ├── price_breakdown_card.dart
    │   └── reasoning_trace_view.dart
    └── constants/
        └── app_constants.dart
```

## 2.3 Backend Architecture (FastAPI)

### Tech Stack
- Python 3.11+
- FastAPI with async/await
- Google ADK (Agent Development Kit)
- Pydantic v2 for validation
- Firebase Admin SDK
- Redis for caching + sessions
- Uvicorn + Gunicorn

### Folder Structure

```
backend/
├── main.py                         # FastAPI app entry
├── requirements.txt
├── .env.example
├── config/
│   ├── settings.py                 # Pydantic Settings
│   └── firebase_config.py
├── api/
│   ├── v1/
│   │   ├── router.py               # APIRouter aggregator
│   │   ├── intent.py               # POST /intent/parse
│   │   ├── match.py                # POST /match/providers
│   │   ├── pricing.py              # POST /pricing/quote
│   │   ├── booking.py              # POST /booking/confirm
│   │   ├── followup.py             # POST /followup/trigger
│   │   └── dispute.py              # POST /dispute/create
│   └── websocket.py                # WS /ws/agent-stream
├── agents/
│   ├── orchestrator.py             # Root ADK agent
│   ├── intent_agent.py             # Language + intent parsing
│   ├── matching_agent.py           # Provider ranking
│   ├── pricing_agent.py            # Dynamic price calculation
│   ├── booking_agent.py            # Booking simulation
│   ├── followup_agent.py           # Reminders + status
│   └── dispute_agent.py            # Dispute resolution
├── services/
│   ├── provider_service.py         # Provider DB queries
│   ├── scheduling_service.py       # Calendar + conflict check
│   ├── notification_service.py     # SMS/WhatsApp mock
│   ├── maps_service.py             # Google Maps integration
│   └── reputation_service.py       # Score calculation
├── models/
│   ├── intent.py
│   ├── provider.py
│   ├── booking.py
│   ├── pricing.py
│   └── dispute.py
├── data/
│   ├── providers_mock.json         # 50+ mock providers
│   └── seed_firestore.py
└── tests/
    ├── test_intent.py
    ├── test_matching.py
    └── test_booking.py
```

## 2.4 Database Design (Firestore)

### Collections

**`users`**
```json
{
  "uid": "string (Firebase Auth UID)",
  "name": "string",
  "phone": "string",
  "location": { "city": "string", "area": "string", "lat": 0.0, "lng": 0.0 },
  "language_preference": "urdu | roman_urdu | english",
  "booking_count": 0,
  "loyalty_tier": "bronze | silver | gold",
  "created_at": "timestamp"
}
```

**`providers`**
```json
{
  "pid": "string",
  "name": "string",
  "phone": "string",
  "service_categories": ["ac_repair", "plumbing"],
  "specializations": ["inverter_ac", "central_ac"],
  "experience_years": 8,
  "rating": 4.6,
  "rating_count": 124,
  "on_time_score": 0.88,
  "cancellation_rate": 0.04,
  "base_rate_pkr": 500,
  "per_km_rate": 50,
  "location": { "area": "G-11", "lat": 33.69, "lng": 73.03 },
  "availability_slots": ["2025-07-15T09:00", "2025-07-15T11:00"],
  "verified": true,
  "risk_score": 0.12,
  "recent_reviews": [{ "text": "...", "rating": 5, "timestamp": "..." }]
}
```

**`bookings`**
```json
{
  "bid": "string",
  "user_id": "string",
  "provider_id": "string",
  "service_type": "string",
  "status": "pending | confirmed | en_route | in_progress | completed | disputed | cancelled",
  "scheduled_time": "timestamp",
  "location": { "address": "string", "lat": 0.0, "lng": 0.0 },
  "price_quote": {
    "base_fee": 500,
    "distance_fee": 150,
    "urgency_surcharge": 100,
    "loyalty_discount": -50,
    "total": 700,
    "currency": "PKR"
  },
  "intent_raw": "string",
  "intent_parsed": { "service_type": "...", "urgency": "high" },
  "agent_trace_id": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

**`agent_traces`**
```json
{
  "trace_id": "string",
  "booking_id": "string",
  "session_id": "string",
  "steps": [
    {
      "agent": "IntentAgent",
      "action": "parse_language",
      "input": "AC bilkul kaam nahi kar raha",
      "output": { "service": "ac_repair", "urgency": "high", "confidence": 0.94 },
      "reasoning": "Detected 'AC kaam nahi' → ac_repair. 'bilkul' intensifier → high urgency.",
      "timestamp": "...",
      "latency_ms": 342
    }
  ],
  "total_latency_ms": 2100,
  "status": "completed | failed",
  "created_at": "timestamp"
}
```

**`disputes`**
```json
{
  "dispute_id": "string",
  "booking_id": "string",
  "type": "no_show | quality | price | overrun | cancellation",
  "description": "string",
  "evidence": ["photo_url"],
  "status": "open | under_review | resolved | escalated",
  "resolution": { "type": "refund | compensation | rebook", "amount_pkr": 0 },
  "created_at": "timestamp"
}
```

## 2.5 API Architecture

### REST Endpoints

```
POST /api/v1/intent/parse
  Body: { "text": "...", "user_id": "...", "session_id": "..." }
  Response: { "intent": {...}, "confidence": 0.94, "follow_up_question": null }

POST /api/v1/match/providers
  Body: { "intent": {...}, "user_location": {...}, "session_id": "..." }
  Response: { "providers": [...], "ranking_reasoning": {...}, "trace_id": "..." }

POST /api/v1/pricing/quote
  Body: { "provider_id": "...", "intent": {...}, "user_id": "..." }
  Response: { "quote": { "breakdown": {...}, "total": 700 }, "alternatives": [...] }

POST /api/v1/booking/confirm
  Body: { "provider_id": "...", "slot": "...", "quote": {...}, "user_id": "..." }
  Response: { "booking": {...}, "confirmation_message": "...", "receipt_url": "..." }

POST /api/v1/followup/trigger
  Body: { "booking_id": "...", "trigger_type": "reminder_1h | completion | feedback_request" }
  Response: { "status": "sent", "message_preview": "..." }

POST /api/v1/dispute/create
  Body: { "booking_id": "...", "type": "...", "description": "..." }
  Response: { "dispute_id": "...", "resolution_eta": "24h", "initial_action": "..." }

WS  /ws/agent-stream?session_id={id}
  Stream: { "type": "agent_step", "agent": "...", "content": "...", "timestamp": "..." }
```

## 2.6 Authentication Flow

```
Flutter App
    │
    ├── Firebase Auth (Phone OTP) ──→ id_token
    │
    └── FastAPI Request
            │
            ├── Verify id_token via Firebase Admin SDK
            ├── Inject user_id into request context
            └── Proceed to handler
```

## 2.7 State Management (Flutter / Riverpod)

```dart
// Core providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>
final agentTraceProvider = StreamProvider<AgentTraceStep>  // WebSocket stream
final providerMatchProvider = FutureProvider.family<List<Provider>, IntentModel>
```

## 2.8 Caching Strategy

| Data | Cache | TTL |
|---|---|---|
| Provider list by area | Redis | 5 min |
| User profile | Hive (local) | 1 hr |
| Price estimates | Redis | 10 min |
| Maps geocode results | Redis | 24 hr |
| Agent traces | Firestore only | Permanent |

---

# 3. AGENTIC AI SYSTEM DESIGN

## 3.1 ADK Orchestration Architecture

Google ADK is used as the **sole orchestrator**. All agents are defined using ADK's Agent class and communicate through structured tool calls. The root `OrchestratorAgent` uses a planning loop to sequence sub-agents.

```
OrchestratorAgent (root)
├── IntentAgent          → parse multilingual input
├── MatchingAgent        → rank providers
├── PricingAgent         → generate quote
├── BookingAgent         → simulate booking
├── FollowUpAgent        → schedule reminders
└── DisputeAgent         → resolve complaints
```

## 3.2 Agent Definitions

---

### Agent 1: IntentAgent

**Purpose**: Parse multilingual service requests into structured intent objects.

**Triggers**: Every new user message

**Inputs**:
- `raw_text: str` — user's message
- `user_profile: dict` — preferred language, past services
- `session_context: list` — conversation history

**Outputs**:
```json
{
  "service_type": "ac_repair",
  "location": "G-13, Islamabad",
  "time_preference": "tomorrow_morning",
  "urgency": "high",
  "budget_sensitivity": "high",
  "constraints": ["morning only"],
  "confidence": 0.94,
  "follow_up_question": null,
  "detected_language": "roman_urdu"
}
```

**Tools**:
- `gemini_chat_tool` — Gemini 1.5 Flash with multilingual system prompt
- `language_detector_tool` — detect Urdu / Roman Urdu / English / mixed
- `service_taxonomy_tool` — map extracted phrase to service_type enum

**ADK System Prompt** (IntentAgent):
```
You are an expert at understanding Pakistani service requests in Urdu, Roman Urdu, English, and mixed language.

Extract the following fields from the user message:
- service_type: one of [ac_repair, plumbing, electrical, tutoring, beauty, driving, mechanics, general_home]
- location: area/city name as stated
- time_preference: specific time or relative (tomorrow_morning, today_afternoon, etc.)
- urgency: low | medium | high | emergency
- budget_sensitivity: low | medium | high (infer from phrases like "zyada nahi hai", "budget mein", "jaldi chahiye")
- constraints: list of any special requirements

Common Urdu/Roman Urdu → intent mappings:
- "AC kaam nahi kar raha" → ac_repair, urgency: high
- "pipe leak ho gaya" → plumbing, urgency: high
- "light nahi aa rahi" → electrical, urgency: medium
- "kal subah" → tomorrow_morning
- "budget zyada nahi" → budget_sensitivity: high

Always return confidence 0.0-1.0. If < 0.7, set follow_up_question.
Return ONLY valid JSON.
```

**Reasoning Logic**:
1. Detect language variant
2. Apply domain-specific NER for Pakistani service terms
3. Map extracted entities to structured schema
4. Calculate confidence based on missing/ambiguous fields
5. Generate clarifying question if confidence < 0.7

**Failure Handling**:
- Gemini API timeout → retry once, then return partial intent with low confidence
- Unrecognized service type → return `service_type: "unknown"` with follow_up_question
- No location detected → ask "Aap ka area kya hai?"

---

### Agent 2: MatchingAgent

**Purpose**: Rank providers using 8-factor weighted scoring algorithm.

**Triggers**: After IntentAgent returns intent with confidence ≥ 0.7

**Inputs**:
- `intent: IntentModel`
- `user_location: GeoPoint`
- `time_window: TimeRange`

**Outputs**:
```json
{
  "ranked_providers": [
    {
      "provider_id": "P001",
      "name": "Ali AC Services",
      "composite_score": 0.87,
      "score_breakdown": {
        "distance_score": 0.9,
        "availability_score": 1.0,
        "rating_score": 0.92,
        "reliability_score": 0.88,
        "specialization_score": 1.0,
        "price_sensitivity_score": 0.75,
        "cancellation_penalty": -0.05,
        "review_sentiment_score": 0.91
      },
      "selection_reasoning": "Selected despite Provider B being closer due to higher AC specialization and 0.96 on-time score vs B's 0.71"
    }
  ],
  "rejected_providers": [{ "id": "P002", "reason": "Unavailable in window" }],
  "trace_id": "trace_abc123"
}
```

**Scoring Formula**:
```python
composite = (
    w1 * distance_score +
    w2 * availability_score +
    w3 * recency_weighted_rating +
    w4 * on_time_score +
    w5 * specialization_match +
    w6 * price_sensitivity_fit +
    w7 * (1 - cancellation_rate) +
    w8 * review_sentiment
)

# Default weights (tunable)
w1=0.15, w2=0.20, w3=0.18, w4=0.15, w5=0.12, w6=0.10, w7=0.05, w8=0.05
```

**Tools**:
- `provider_query_tool` — Firestore query + filter
- `maps_distance_tool` — Google Maps Distance Matrix API
- `review_sentiment_tool` — Gemini sentiment on recent reviews
- `availability_check_tool` — Conflict detection in calendar

**Failure Handling**:
- No providers available → trigger waitlist + suggest next available slot
- Maps API failure → use Haversine formula for distance fallback
- < 3 providers in area → expand search radius by 5km

---

### Agent 3: PricingAgent

**Purpose**: Generate dynamic, transparent price quotes fair to both user and provider.

**Triggers**: After MatchingAgent returns ranked providers

**Inputs**:
- `provider: ProviderModel`
- `intent: IntentModel`
- `user: UserModel` (for loyalty discount)
- `market_demand: float` (surge factor)

**Outputs**:
```json
{
  "quote": {
    "base_service_fee": 500,
    "visit_fee": 200,
    "distance_fee": 150,
    "urgency_surcharge": 100,
    "complexity_surcharge": 200,
    "loyalty_discount": -50,
    "surge_multiplier": 1.0,
    "total_pkr": 1100,
    "currency": "PKR",
    "breakdown_reasoning": "Base 500 (standard AC repair) + 150 distance (3km × 50/km) + 100 urgency (high priority) + 200 complexity (inverter AC) - 50 loyalty (silver tier)"
  },
  "budget_alternative": {
    "provider_id": "P003",
    "total_pkr": 800,
    "tradeoff": "15% lower rating, 30min later slot"
  }
}
```

**Pricing Logic**:
```python
total = (
    provider.base_rate +
    200 +  # fixed visit fee
    (distance_km * provider.per_km_rate) +
    (urgency_multiplier[intent.urgency]) +
    (complexity_surcharge[job_complexity]) -
    loyalty_discount(user.loyalty_tier)
) * surge_multiplier

surge_multiplier = 1.0 + (0.2 if demand_score > 0.8 else 0.0)
```

**Failure Handling**:
- Price seems outlier (>3σ from category mean) → flag for human review
- Budget conflict → always offer alternative option

---

### Agent 4: BookingAgent

**Purpose**: Simulate the complete booking lifecycle.

**Triggers**: User confirms provider + quote

**Inputs**:
- `user_id: str`
- `provider_id: str`
- `slot: datetime`
- `quote: PriceQuote`
- `intent: IntentModel`

**Actions** (in order):
1. Check double-booking conflict (provider + user)
2. Add travel-time buffer to adjacent slots
3. Write booking record to Firestore
4. Generate booking receipt (JSON/formatted)
5. Send confirmation notification (simulated WhatsApp/SMS)
6. Update provider's availability_slots
7. Schedule FollowUpAgent at T-24h and T-1h
8. Return booking confirmation + receipt

**Tools**:
- `conflict_check_tool` — query Firestore for overlapping slots
- `firestore_write_tool` — write booking document
- `notification_send_tool` — mock WhatsApp/SMS
- `calendar_update_tool` — add to mock calendar
- `receipt_generator_tool` — format receipt message

**Failure Handling**:
- Double booking detected → reject + suggest next 3 available slots
- Firestore write failure → retry 3x with exponential backoff
- Notification failure → log but don't fail booking

---

### Agent 5: FollowUpAgent

**Purpose**: Automate all post-booking communications and service quality collection.

**Triggers**:
- Scheduled: T-24h, T-1h before booking
- Event-driven: provider marks en_route, service completed
- Manual: user initiates feedback

**Actions by trigger**:

| Trigger | Action |
|---|---|
| T-24h | Send reminder to user + provider |
| T-1h | Send "Provider on the way" alert |
| en_route | Push "Provider is 15 min away" notification |
| completed | Send feedback request (1–5 stars + comment) |
| feedback_received | Update provider reputation score |
| no_response_24h | Auto-close with 5-star default or escalate |

**Tools**:
- `notification_send_tool`
- `feedback_collect_tool`
- `reputation_update_tool`

---

### Agent 6: DisputeAgent

**Purpose**: Handle all post-service disputes through structured escalation.

**Triggers**: User files dispute OR system detects no-show/cancellation

**Decision Tree**:
```
Dispute Type?
├── NO-SHOW
│   ├── Provider history: < 2 no-shows → auto-reschedule + 10% discount
│   └── Provider history: ≥ 2 no-shows → blacklist + full refund simulation
├── QUALITY_COMPLAINT
│   ├── Evidence provided → AI review of photos + description
│   │   ├── Valid complaint → compensation offer (partial refund)
│   │   └── Insufficient evidence → request more info
│   └── No evidence → mediation: ask both parties
├── PRICE_DISAGREEMENT
│   ├── Quote matches actual → explain breakdown
│   └── Overcharge detected → compensation + provider warning
├── CANCELLATION (by provider)
│   ├── < 2h before → auto-assign next-best provider
│   └── > 2h before → offer reschedule or full refund
└── OVERRUN
    └── Calculate overtime rate → send invoice → user approves/disputes
```

**Tools**:
- `dispute_analysis_tool` — Gemini review of complaint + evidence
- `provider_history_tool` — query past disputes for provider
- `compensation_calculator_tool`
- `escalation_ticket_tool` — create admin notification
- `blacklist_tool` — flag provider

---

## 3.3 Orchestrator Flow

```python
# ADK OrchestratorAgent pseudo-logic

async def handle_user_request(user_input: str, session: Session):
    
    # Step 1: Intent
    intent = await intent_agent.run(user_input, session.context)
    trace.log("IntentAgent", intent)
    
    if intent.confidence < 0.7:
        return clarification_response(intent.follow_up_question)
    
    # Step 2: Match
    providers = await matching_agent.run(intent, session.user_location)
    trace.log("MatchingAgent", providers)
    
    if not providers:
        return no_providers_response(suggest_alternatives=True)
    
    # Step 3: Price (for top 3)
    quotes = await pricing_agent.run(providers[:3], intent, session.user)
    trace.log("PricingAgent", quotes)
    
    # Step 4: Present to user → await confirmation
    confirmation = await stream_to_user(providers, quotes)
    
    # Step 5: Book (on user confirmation)
    if confirmation.confirmed:
        booking = await booking_agent.run(
            confirmation.provider_id, 
            confirmation.slot, 
            quotes[confirmation.provider_id]
        )
        trace.log("BookingAgent", booking)
        
        # Step 6: Schedule follow-ups
        await followup_agent.schedule(booking)
    
    return booking_confirmation_response(booking, trace)
```

## 3.4 Reasoning Trace Schema

Every ADK step emits a trace entry shown in the Flutter UI:

```json
{
  "step": 3,
  "agent": "MatchingAgent",
  "action": "rank_providers",
  "reasoning": "Provider A ranked #1 despite Provider B being 0.8km closer. A's on-time score (0.96) vs B's (0.71) and AC-specific reviews outweigh proximity. Budget sensitivity applied: lowest-priced option (Provider C) shown as alternative.",
  "confidence": 0.89,
  "latency_ms": 487,
  "tools_used": ["maps_distance_tool", "review_sentiment_tool"],
  "timestamp": "2025-07-15T08:34:22Z"
}
```

## 3.5 Safety Systems

- All agent outputs validated against Pydantic schemas before use
- Gemini outputs sanitized — no raw HTML, no PII leakage
- Agent permissions are isolated: DisputeAgent cannot write to bookings
- Human-in-the-loop: disputes escalated > 3 days get admin ticket
- Rate limiting: max 10 agent calls per session per minute

---

# 4. USER FLOW + UX DOCUMENT

## 4.1 Onboarding Flow

```
Screen 1: Splash (AI Seekho logo + tagline "Apni Zindagi Asaan Karo")
    ↓
Screen 2: Language selection (اردو / Roman Urdu / English)
    ↓
Screen 3: Phone number OTP (Firebase Auth)
    ↓
Screen 4: Name + area selection (dropdown of major cities/areas)
    ↓
Screen 5: Tutorial (3-slide swipe): "Type in any language" / "AI finds the best" / "Track everything"
    ↓
Screen 6: Main Chat Screen (HOME)
```

## 4.2 Primary Journey: Service Request → Booking

```
[CHAT SCREEN]
User types: "AC bilkul kaam nahi kar raha, kal subah G-13 mein technician chahiye, budget zyada nahi hai"

    ↓ [LOADING: ADK agents running — animated reasoning trace visible]

[INTENT CONFIRMATION CARD]
"Mujhe samajh aaya — aap ko chahiye:"
✓ AC Repair (High Urgency)  ✓ G-13, Islamabad  ✓ Kal Subah  ✓ Budget Sensitive
[Confirm] [Change]

    ↓

[PROVIDER CARDS] (top 3, ranked)
┌─────────────────────────────────────┐
│ 🥇 Ali AC Services                  │
│ ⭐ 4.8 · 3.2km · 96% on-time        │
│ From PKR 900 · Available 10:00 AM  │
│ [See Why Selected] [Book Now]       │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ 🥈 Hassan Cooling Solutions          │
│ ⭐ 4.5 · 1.1km · 71% on-time        │
│ From PKR 750 · Available 09:30 AM  │
│ [Book Now]                          │
└─────────────────────────────────────┘

    ↓ [User taps "See Why Selected"]

[REASONING PANEL] (expandable drawer)
"ADK ne yeh faisla kyun kiya:"
Step 1 → Intent: AC repair confirmed (94% confidence)
Step 2 → 8 providers found in G-13 area
Step 3 → Ali ranked #1: AC specialist (Hassan is generalist), on-time 96% vs 71%
Step 4 → Price adjusted for budget sensitivity: -10% discount applied

    ↓ [User taps "Book Now"]

[PRICE BREAKDOWN SCREEN]
Base service fee:     PKR 500
Visit fee:            PKR 200
Distance (3.2km):     PKR 160
Urgency adjustment:   PKR 100
Budget discount:      -PKR 80
─────────────────────────────
TOTAL:               PKR 880

[Confirm Booking — PKR 880] [Choose Different Provider]

    ↓

[BOOKING CONFIRMATION SCREEN]
✅ Booking Confirmed!
Ali AC Services — Tomorrow 10:00 AM
Booking ID: #BSK-2024-1821
[Reminder set for 9:00 AM]
[View Receipt] [Share via WhatsApp] [Track Booking]
```

## 4.3 Post-Service Quality Flow

```
[FOLLOW-UP NOTIFICATION] (at service completion)
"Ali ne kaam mukammal kar liya. Aap ka tajriba kaisa raha?"

[FEEDBACK SCREEN]
★ ★ ★ ★ ★
"Kuch aur batana chahte hain? (optional)"
[Text field in Urdu/English]
[Submit]

    ↓

[REPUTATION UPDATE] (background)
Ali's rating updated: 4.8 → 4.81
On-time score: maintained 0.96
Match impact: prioritized in future AC searches in G-13
```

## 4.4 Dispute Flow

```
[BOOKING HISTORY]
Status: Completed → [Any issue?]

[DISPUTE SCREEN]
"Kya masla hai?"
○ Provider nahi aaya (No-show)
○ Kaam theek nahi tha (Quality)
○ Paisa zyada liya (Price)
○ Jo kaam hua woh waqt se zyada laga (Overrun)

    ↓ [User selects + describes]

[AI MEDIATION SCREEN]
"Ham is masle ko hal karne ki koshish kar rahe hain..."
[ADK DisputeAgent reasoning visible]

    ↓

[RESOLUTION SCREEN]
"Faisle ke mutabiq: PKR 200 wapas kar diye jayenge"
[Accept] [Escalate to Support]
```

## 4.5 Navigation Structure

```
Bottom Nav:
├── 💬 Chat (Home — main request flow)
├── 📋 Bookings (history + active)
├── 🔍 Browse (provider search/map view)
└── 👤 Profile
```

## 4.6 Edge Case UX Handling

| Scenario | UX Response |
|---|---|
| Low confidence parse | "Aap thoda aur bata sakte hain? Masalan: 'G-13 mein kal subah plumber chahiye'" |
| No providers available | "Abhi G-13 mein koi available nahi. Kya waitlist mein add kar dein? Ya doosra waqt try karein?" |
| Provider cancels | Push notification: "Ali ne cancel kar diya. Ham ne [Hassan] automatically assign kar diya hai. Koi masla?" |
| Double booking attempt | "Yeh slot already book hai. Agli available times: 11:00 AM, 2:00 PM, 4:00 PM" |

---

# 5. IMPLEMENTATION ROADMAP

## Phase 1 — MVP (Days 1–3) — Demo Day Ready

**Priority**: Core flow working end-to-end for demo

| Task | Complexity | Priority | Depends On |
|---|---|---|---|
| Firebase project setup + Auth (Phone OTP) | Low | P0 | None |
| Mock provider dataset (50 providers, 8 categories) | Low | P0 | None |
| FastAPI skeleton + all route stubs | Low | P0 | None |
| IntentAgent: Gemini prompt for Urdu/Roman Urdu | Medium | P0 | FastAPI |
| MatchingAgent: 8-factor scoring algorithm | High | P0 | Mock data |
| PricingAgent: Dynamic quote calculator | Medium | P0 | None |
| BookingAgent: Firestore write + receipt gen | Medium | P0 | Firebase |
| Flutter: Chat screen with message bubbles | Medium | P0 | None |
| Flutter: Provider ranking cards UI | Medium | P0 | None |
| Flutter: Price breakdown + confirm screen | Low | P1 | None |
| Flutter: Booking confirmation screen | Low | P1 | BookingAgent |
| ADK orchestrator wiring all agents | High | P0 | All agents |
| WebSocket for real-time trace streaming | Medium | P1 | FastAPI |
| Flutter: Agent reasoning trace panel | Medium | P1 | WebSocket |

## Phase 2 — AI Integration (Days 3–4)

| Task | Complexity | Priority |
|---|---|---|
| DisputeAgent: All 5 dispute scenarios | High | P0 |
| FollowUpAgent: Reminders + feedback collection | Medium | P1 |
| Reputation score recalculation on feedback | Medium | P1 |
| Scheduling conflict prevention + waitlist | Medium | P0 |
| Google Maps Distance Matrix integration | Medium | P1 |
| Review sentiment analysis (Gemini NLP) | Low | P1 |
| Surge pricing logic | Low | P2 |
| No-provider-available + auto-reschedule | Medium | P0 |
| Stress test: 5 edge cases from problem statement | Medium | P0 |

## Phase 3 — Polish for Demo (Day 4–5)

| Task | Complexity | Priority |
|---|---|---|
| ADK trace visualization (Flutter animated) | Medium | P0 |
| Demo video flow scripted + tested | Low | P0 |
| README finalized | Low | P0 |
| Error states + loading animations | Low | P1 |
| Mock WhatsApp notification preview | Low | P1 |
| Performance optimization (cache providers) | Low | P2 |

---

# 6. AI CODING EXECUTION DOCUMENT

## 6.1 Implementation Order

```
1. Infrastructure setup (Firebase + FastAPI skeleton)
2. Mock data layer (providers_mock.json + seed script)
3. Agent implementations (Intent → Match → Price → Book)
4. ADK orchestrator wiring
5. FastAPI route connections
6. Flutter chat UI + API integration
7. Flutter booking + confirmation UI
8. WebSocket trace streaming
9. DisputeAgent + FollowUpAgent
10. Polish + demo preparation
```

## 6.2 File Creation Checklist

### Backend Files to Create

```
backend/
├── main.py                         ← FastAPI app, CORS, routers
├── requirements.txt                ← fastapi, uvicorn, google-adk, firebase-admin, httpx, pydantic, redis
├── config/settings.py              ← BaseSettings with env vars
├── agents/orchestrator.py          ← ADK root agent, planning loop
├── agents/intent_agent.py          ← Gemini prompt + structured output
├── agents/matching_agent.py        ← 8-factor scoring function
├── agents/pricing_agent.py         ← Quote calculation
├── agents/booking_agent.py         ← Firestore write + notifications
├── agents/followup_agent.py        ← Reminder scheduling
├── agents/dispute_agent.py         ← Dispute decision tree
├── services/provider_service.py    ← Query mock data + Firestore
├── services/scheduling_service.py  ← Conflict detection
├── services/maps_service.py        ← Google Maps or Haversine fallback
├── services/notification_service.py← Mock SMS/WhatsApp
├── services/reputation_service.py  ← Score recalculator
├── models/intent.py               ← Pydantic IntentModel
├── models/provider.py             ← Pydantic ProviderModel
├── models/booking.py              ← Pydantic BookingModel
├── models/pricing.py              ← Pydantic PriceQuote
├── data/providers_mock.json        ← 50+ providers (8 categories)
├── api/v1/intent.py               ← Route handler
├── api/v1/match.py                ← Route handler
├── api/v1/pricing.py              ← Route handler
├── api/v1/booking.py              ← Route handler
├── api/v1/dispute.py              ← Route handler
└── api/websocket.py               ← WebSocket trace stream
```

### Flutter Files to Create

```
lib/
├── main.dart
├── app/app.dart + router.dart + theme.dart
├── core/api/api_client.dart
├── features/auth/screens/onboarding_screen.dart
├── features/auth/screens/login_screen.dart
├── features/chat/screens/chat_screen.dart         ← PRIMARY SCREEN
├── features/chat/widgets/message_bubble.dart
├── features/chat/widgets/agent_trace_panel.dart   ← ADK reasoning UI
├── features/chat/widgets/provider_card.dart
├── features/chat/widgets/price_breakdown_card.dart
├── features/chat/widgets/booking_confirmation.dart
├── features/booking/screens/booking_detail_screen.dart
├── features/booking/screens/dispute_screen.dart
├── models/intent_model.dart
├── models/provider_model.dart
├── models/booking_model.dart
├── models/price_quote_model.dart
└── models/agent_trace_model.dart
```

## 6.3 Key API Contracts (for AI code generation)

### Intent Parse Request/Response
```python
# Request
class IntentParseRequest(BaseModel):
    text: str
    user_id: str
    session_id: str
    context: list[dict] = []

# Response
class IntentParseResponse(BaseModel):
    service_type: str
    location: str
    time_preference: str
    urgency: Literal["low", "medium", "high", "emergency"]
    budget_sensitivity: Literal["low", "medium", "high"]
    constraints: list[str]
    confidence: float  # 0.0-1.0
    follow_up_question: str | None
    detected_language: str
    trace_step: dict
```

### Provider Match Request/Response
```python
class MatchRequest(BaseModel):
    intent: IntentParseResponse
    user_lat: float
    user_lng: float
    max_results: int = 5

class RankedProvider(BaseModel):
    provider_id: str
    name: str
    phone: str
    distance_km: float
    composite_score: float
    score_breakdown: dict[str, float]
    selection_reasoning: str
    available_slots: list[datetime]
    base_quote_pkr: int

class MatchResponse(BaseModel):
    ranked_providers: list[RankedProvider]
    rejected_count: int
    waitlist_available: bool
    trace_steps: list[dict]
```

## 6.4 Mock Provider Dataset Schema

```json
[
  {
    "pid": "P001",
    "name": "Ali AC Services",
    "phone": "+92-300-1234567",
    "service_categories": ["ac_repair", "ac_installation"],
    "specializations": ["inverter_ac", "split_ac", "central_ac"],
    "experience_years": 12,
    "rating": 4.8,
    "rating_count": 247,
    "on_time_score": 0.96,
    "cancellation_rate": 0.02,
    "base_rate_pkr": 500,
    "per_km_rate": 50,
    "areas_served": ["G-11", "G-12", "G-13", "F-11"],
    "city": "Islamabad",
    "lat": 33.691,
    "lng": 73.028,
    "verified": true,
    "risk_score": 0.05,
    "available_slots": ["2025-07-15T09:00:00", "2025-07-15T11:00:00", "2025-07-16T10:00:00"],
    "recent_reviews": [
      {"text": "Bohat acha kaam kiya, waqt per aaya", "rating": 5, "date": "2025-07-10"},
      {"text": "Professional service, highly recommend", "rating": 5, "date": "2025-07-08"}
    ]
  }
]
```

## 6.5 ADK Agent Initialization Pattern

```python
# agents/intent_agent.py
from google.adk.agents import LlmAgent
from google.adk.tools import FunctionTool

intent_agent = LlmAgent(
    name="IntentAgent",
    model="gemini-1.5-flash",
    instruction=INTENT_SYSTEM_PROMPT,
    tools=[
        FunctionTool(detect_language),
        FunctionTool(map_to_service_taxonomy),
    ],
    output_schema=IntentParseResponse,
)

# agents/orchestrator.py
from google.adk.agents import SequentialAgent

orchestrator = SequentialAgent(
    name="ServiceOrchestrator",
    sub_agents=[
        intent_agent,
        matching_agent,
        pricing_agent,
        booking_agent,
    ],
    description="End-to-end service booking orchestrator"
)
```

---

# 7. SECURITY + SAFETY DOCUMENT

## 7.1 Authentication

- Firebase Phone Auth (OTP) — no passwords
- All API requests require valid Firebase JWT in `Authorization: Bearer {token}`
- Backend verifies with `firebase_admin.auth.verify_id_token(token)`
- Token expiry: 1 hour (Firebase default)

## 7.2 Authorization

```python
# Role-based access
USER: read own bookings, create bookings, file disputes
PROVIDER: read own schedule, update booking status (demo only)
ADMIN: full access, dispute escalations
AGENT: internal service-to-service calls only (secret key)
```

## 7.3 API Security

- CORS: whitelist Flutter app origin only
- Rate limiting: 60 req/min per user (Redis counter)
- Input validation: all requests validated via Pydantic before agent call
- API key for Google Maps + Gemini stored in env vars, never in code
- WebSocket authenticated via session_id linked to Firebase token

## 7.4 Prompt Injection Protection

```python
# IntentAgent input sanitization
def sanitize_user_input(text: str) -> str:
    # Remove prompt injection patterns
    injection_patterns = [
        r"ignore (all )?previous instructions",
        r"you are now",
        r"system prompt",
        r"<\|.*\|>",
    ]
    for pattern in injection_patterns:
        text = re.sub(pattern, "[REMOVED]", text, flags=re.IGNORECASE)
    return text[:1000]  # Max 1000 chars
```

## 7.5 Agent Permission Isolation

| Agent | Can Read | Can Write | Can Delete |
|---|---|---|---|
| IntentAgent | None | trace_steps | None |
| MatchingAgent | providers, bookings | trace_steps | None |
| PricingAgent | providers, users | trace_steps | None |
| BookingAgent | providers, users | bookings, notifications | None |
| FollowUpAgent | bookings | notifications, feedback | None |
| DisputeAgent | bookings, providers | disputes | None |

## 7.6 Data Privacy (Demo)

- All provider data is fictional/mock
- User phone numbers hashed in Firestore (SHA-256)
- No real financial transactions
- PII not logged in agent traces

## 7.7 Fraud Detection

- Duplicate booking detection: same user + same provider + same day → flag
- Abnormal dispute rate: > 3 disputes from same user in 7 days → review queue
- Provider risk_score factor in matching: high-risk providers deprioritized

---

# 8. README / SUBMISSION DOCUMENTATION

## AI Seekho 🤖

**Agentic AI Service Orchestrator for Pakistan's Informal Economy**

### Overview

AI Seekho automates the complete lifecycle of informal service requests in Pakistan — from a Roman Urdu WhatsApp message to a confirmed, tracked, and quality-assured booking. Built with Google ADK as the core orchestrator, Flutter for mobile, and FastAPI for the backend.

### Architecture Summary

```
Flutter App → FastAPI → Google ADK Orchestrator → Firebase
                              ↓
         [IntentAgent] → [MatchingAgent] → [PricingAgent]
                              ↓
         [BookingAgent] → [FollowUpAgent] → [DisputeAgent]
```

### AI Agents (Google ADK)

| Agent | Role |
|---|---|
| IntentAgent | Parse Urdu/Roman Urdu/English into structured intent |
| MatchingAgent | 8-factor provider ranking with reasoning |
| PricingAgent | Dynamic transparent price quotes |
| BookingAgent | Full booking simulation lifecycle |
| FollowUpAgent | Automated reminders + quality collection |
| DisputeAgent | Structured dispute resolution + escalation |

### APIs & Integrations

- Google ADK — Agent orchestration (mandatory)
- Gemini 1.5 Flash — Language understanding + review sentiment
- Google Maps/Places API — Distance matrix, geocoding
- Firebase Auth — Phone OTP authentication
- Firestore — Booking, provider, trace storage
- Firebase Cloud Messaging — Push notifications

### Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x + Riverpod |
| Backend | FastAPI (Python 3.11) |
| Agents | Google ADK |
| AI Model | Gemini 1.5 Flash |
| Auth | Firebase Phone Auth |
| Database | Firestore |
| Cache | Redis |
| Maps | Google Maps Platform |

### Setup Instructions

```bash
# Backend
cd backend
pip install -r requirements.txt
cp .env.example .env  # Add API keys
python data/seed_firestore.py  # Seed mock providers
uvicorn main:app --reload --port 8000

# Flutter
cd flutter_app
flutter pub get
flutter run
```

### Innovation Highlights

1. **Multilingual ADK** — First Pakistani service app with ADK-powered Urdu/Roman Urdu intent understanding
2. **Transparent AI reasoning** — Users see WHY a provider was selected (ADK trace in UI)
3. **8-factor matching** — Goes far beyond distance; on-time score, review sentiment, specialization
4. **Full dispute automation** — 5 dispute types handled by DisputeAgent with structured resolution
5. **Dynamic fair pricing** — Both user and provider protected with transparent breakdown

### Demo Instructions

1. Launch Flutter app
2. Type: *"AC bilkul kaam nahi kar raha, kal subah G-13 mein technician chahiye, budget zyada nahi hai"*
3. Watch ADK reasoning trace animate in real-time
4. Review ranked providers with selection reasoning
5. Confirm booking → see receipt + simulated WhatsApp confirmation
6. Trigger dispute scenario from booking history
7. Watch DisputeAgent resolve with reasoning

### Future Roadmap

- Real WhatsApp Business API integration
- Provider mobile app (Flutter)
- Voice input (Urdu speech-to-text)
- Payment integration (JazzCash / EasyPaisa)
- City expansion beyond Islamabad

---

# 9. WOW FACTOR FEATURES

These are the features that will make judges stop and say "this is different."

---

## 💡 WOW Feature 1: Live ADK Reasoning Glass

**What it is**: A translucent animated panel in the Flutter chat UI that shows the ADK agent reasoning in real-time as it runs — not just a spinner, but actual thought steps appearing one by one via WebSocket.

**How it looks**:
```
🤖 AI thinking...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Step 1 · IntentAgent          [342ms]
   "AC bilkul kaam nahi" → AC Repair
   Urgency: HIGH (bilkul intensifier)
   Confidence: 94%

⚡ Step 2 · MatchingAgent        [running]
   Scanning 23 providers in G-13...
   Applying 8-factor scoring...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**How to implement**:
1. FastAPI WebSocket endpoint `/ws/agent-stream?session_id={id}`
2. ADK agents emit trace events via a shared event bus
3. Each `trace_step` pushed to WebSocket channel
4. Flutter `StreamProvider` consumes WebSocket
5. `AnimatedList` widget inserts steps with fade-in animation
6. User can tap any step to see full JSON reasoning

**Why it wins**: Directly satisfies the "show ADK reasoning traces" evaluation criterion AND creates a memorable, trust-building UX moment.

---

## 💡 WOW Feature 2: "Why AI Chose This" Provider Card

**What it is**: Each ranked provider card has an expandable section that shows a human-readable explanation of why ADK chose them — in Urdu.

**How it looks**:
```
┌──────────────────────────────────────────┐
│ 🥇 Ali AC Services    ★4.8  PKR 880      │
│ ────────────────────────────────────────  │
│ 🤖 AI ne kyun choose kiya?               │
│                                           │
│ ✓ AC specialist (12 saal ka tajruba)     │
│ ✓ 96% waqt per — area mein best         │
│ ✓ Aap ke budget ke mutabiq              │
│ ⚠ Hassan 1km paas hai lekin on-time      │
│   record sirf 71% hai                   │
│                                           │
│ [Book Now — PKR 880]                     │
└──────────────────────────────────────────┘
```

**How to implement**:
1. MatchingAgent generates `selection_reasoning` field in Urdu
2. Gemini translates/generates Urdu explanation from structured scores
3. Flutter ProviderCard widget has expandable tile with Urdu text
4. Use `google_fonts` for Noto Nastaliq Urdu rendering

**Why it wins**: Creates trust through transparency. No other service app in Pakistan shows WHY a provider was picked. Judges will remember this.

---

## 💡 WOW Feature 3: Stress Test Mode (Live Demo Panel)

**What it is**: A hidden "Demo Mode" button that triggers pre-scripted stress test scenarios from the problem statement, shown live during the demo.

**Scenarios**:
- "No provider available" → auto-reschedule flow
- "Provider cancels after booking" → waitlist activation
- "Ambiguous input" → confidence < 0.7 → follow-up question
- "Two users, same provider, same time" → conflict resolution
- "Customer disputes price after service" → DisputeAgent resolution

**How to implement**:
1. Flutter: floating debug button (only in demo build)
2. Tapping shows scenario selector bottom sheet
3. Each scenario pre-fills a specific input + triggers a specific ADK path
4. Backend `/api/v1/demo/stress-test/{scenario_id}` endpoint
5. Returns scripted but realistic agent trace + resolution

**Why it wins**: Judges explicitly listed these exact scenarios in the evaluation criteria. Walking through them live with animated ADK traces is a showstopper demo moment.

---

## 💡 WOW Feature 4: Provider Fairness Dashboard

**What it is**: A screen that shows how ADK balances workload fairly across providers — not just sending all jobs to the top-rated one.

**How it looks**:
- Bar chart showing bookings per provider this week
- ADK explanation: "Tariq ko 3 naye bookings diye — Ali ke paas already 8 jobs hain is hafte"
- "Fair earning opportunity" metric per provider

**How to implement**:
1. MatchingAgent includes `workload_balance_factor` in scoring
2. Providers with < average bookings get a +0.05 score boost
3. Dashboard screen in Flutter (charts via `fl_chart`)
4. ADK logs workload reasoning in trace

**Why it wins**: Directly addresses the "provider-side optimization" requirement AND demonstrates ADK making ethical, fair decisions — a powerful demo narrative.

---

## 💡 WOW Feature 5: Multilingual Confidence Meter

**What it is**: A visual confidence indicator in the chat that shows how well ADK understood the request, and auto-improves as the user provides more context.

**How it looks**:
```
Input: "AC theek karo kal"
━━━━━━━━━━━━━━━━━━━━━━
Understanding: ████████░░  68%
Missing: Location, Time preference

[Add: "G-13 mein, subah 9 baje"]

Understanding: ██████████  96%
All fields confirmed ✓
```

**How to implement**:
1. IntentAgent returns `confidence` + `missing_fields` array
2. Flutter renders animated confidence bar (LinearProgressIndicator)
3. Missing fields shown as tappable chips that pre-fill message
4. Each user clarification triggers re-parse → confidence updates

**Why it wins**: Elegant UX solution to the multilingual robustness challenge. Shows the AI isn't just a black box — it tells users exactly what it needs.

---

## Implementation Priority for WOW Features

| Feature | Hackathon Value | Implementation Effort | Recommend? |
|---|---|---|---|
| Live ADK Reasoning Glass | ★★★★★ | Medium | **YES — Day 1** |
| "Why AI Chose This" Card | ★★★★★ | Low | **YES — Day 1** |
| Stress Test Demo Mode | ★★★★☆ | Medium | **YES — Day 2** |
| Multilingual Confidence Meter | ★★★★☆ | Low | **YES — Day 2** |
| Provider Fairness Dashboard | ★★★☆☆ | Medium | Optional (Day 3) |

---

*Generated by: AI Seekho Engineering Team*  
*Stack: Flutter · FastAPI · Google ADK · Firebase · Gemini 1.5 Flash*
