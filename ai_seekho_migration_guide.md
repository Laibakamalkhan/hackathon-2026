# AI Seekho → KARIGAR Migration Guide

> A complete, beginner-friendly analysis of both projects — with a safe, step-by-step migration strategy that keeps your backend fully intact.

*Migration Guide — AI Seekho Hackathon 2026*

---

## Contents

1. [Overview of Both Projects](#section-1-overview-of-both-projects)
2. [Backend Analysis](#section-2-backend-analysis)
3. [Old Frontend Analysis](#section-3-old-frontend-analysis)
4. [New Frontend Analysis](#section-4-new-frontend-analysis)
5. [Gap Analysis — What's Missing](#section-5-gap-analysis--whats-missing)
6. [Step-by-Step Migration Plan](#section-6-step-by-step-migration-plan)
7. [What You Must NOT Delete or Change](#section-7-what-you-must-not-delete-or-change)
8. [Risks & Warnings](#section-8-risks--warnings)
9. [Quick Reference Summary](#section-9-quick-reference-summary)

---

## Section 1: Overview of Both Projects

You have two completely separate things that need to be combined into one: the **existing system** (backend + old frontend) and the **new beautiful UI** (new frontend only). Here's what each contains at a glance.

### Old Project — `ai-seekho-hackathon-2026`

Contains BOTH the backend (Python/FastAPI) AND the old Flutter frontend. Has full API integration but older UI.

- ✓ Real Backend
- ✓ Firebase
- ✓ AI Agents
- ⚠ Old UI

### New Project — `ai_seekho_flutter_frontend`

Contains ONLY the new Flutter frontend (called "KARIGAR"). Beautiful Figma-designed UI but no backend connection.

- ✓ Beautiful UI
- ✓ More Screens
- ✗ No Backend
- ✗ Mock Data Only

> 💡 **Your Goal in Simple Terms:** Keep the backend exactly as it is. Replace only the old Flutter frontend with the new one, and then carefully add the backend connections into the new frontend. The backend does NOT need to change at all.

---

## Section 2: Backend Analysis

The backend lives at `ai_seekho_backend/` inside the old project. It is a Python FastAPI application powered by Google Gemini AI. It has three intelligent agents, Firebase for data storage, and many API endpoints.

### Backend Folder Structure

```
ai_seekho_backend/
├── main.py              ← All API routes defined here
├── .env                 ← API keys (NEVER commit this!)
├── agents/
│   ├── coordinator_agent.py ← Understands user's request
│   ├── executor_agent.py    ← Creates bookings
│   └── guardian_agent.py    ← Resolves disputes & feedback
├── config/
│   ├── firebase_config.py   ← Firebase database connection
│   └── settings.py
├── services/
│   ├── dispute_service.py
│   ├── pricing_service.py
│   ├── provider_service.py
│   └── scheduling_service.py
├── models/
│   ├── booking.py
│   └── dispute.py
└── orchestrator/
    └── agent_coordinator.py
```

### All Backend API Endpoints

Every one of these must be connected to the new Flutter frontend eventually.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/providers` | Get all service providers |
| POST | `/api/match` | Legacy: match technicians (old flow) |
| POST | `/api/booking/create` | Legacy: create a booking record |
| POST | `/api/dispute/create` | Legacy: create a dispute |
| POST v1 | `/api/v1/agent/coordinate` | 🤖 AI: Understand request + find providers + get price quote |
| POST v1 | `/api/v1/agent/execute` | 🤖 AI: Lock slot + create Firestore booking |
| POST v1 | `/api/v1/agent/resolve` | 🤖 AI: Resolve dispute via Gemini |
| POST v1 | `/api/v1/feedback/submit` | Submit feedback + update provider rating |
| GET | `/api/v1/bookings?user_id=...` | Get all bookings for a user |
| PATCH | `/api/v1/booking/{bid}/status` | Update booking status |
| WS | `/ws/agent-stream` | 🔴 Real-time: Stream agent reasoning steps live |
| WS | `/ws/trace/{session_id}` | Legacy: Real-time orchestration trace |

> ⚠️ **Important: The most important endpoint is `/ws/agent-stream`**
> This WebSocket endpoint streams the AI agent's thinking in real-time — each step (THINK, ACT, OBSERVE) is broadcast as it happens. The new frontend's `ChatActiveScreen` simulates this with a timer. You'll need to replace that fake timer with a real WebSocket connection to this endpoint.

---

## Section 3: Old Frontend Analysis

The old Flutter app (`ai_seekho_flutter/`) is inside the old project. It is fully connected to the backend. Here is what it has that the new frontend does NOT have yet.

### Network Layer (Critical — Must Be Ported)

**Files That Handle API Calls:**
- `core/network/api_service.dart` — calls every backend endpoint
- `core/network/http_client.dart` — HTTP GET/POST wrapper
- `core/network/websocket_client.dart` — WebSocket connection manager
- `core/constants/api_endpoints.dart` — all URL strings
- `core/network/models.dart` — request/response model classes

**State Management (Riverpod Providers):**
- `features/booking/providers/booking_provider.dart`
- `features/dispute/providers/dispute_provider.dart`
- `features/matching/providers/matching_provider.dart`
- `core/providers/core_providers.dart`

### Old Frontend Screens (with Backend Connections)

| Screen | Backend API Called | Status in New Frontend |
|--------|--------------------|------------------------|
| `ChatHomeScreen` | None (UI only) | ✅ Done (redesigned) |
| `ChatActiveScreen` | `/ws/agent-stream` (WebSocket) | 🟡 Partial — UI done, no real WS |
| `ProviderRankingScreen` | `/api/v1/agent/coordinate` | 🟡 Partial — UI done, uses mock data |
| `PriceBreakdownScreen` | Uses data from coordinator result | 🟡 Partial — UI done, uses mock data |
| `BookingConfirmedScreen` | `/api/v1/agent/execute` | 🟡 Partial — UI done, no real booking |
| `BookingHistoryScreen` | `/api/v1/bookings` | 🟡 Partial — UI done, uses mock data |
| `BookingDetailScreen` | `/api/v1/booking/{bid}/status` | 🟡 Partial — UI done, mock data |
| `FeedbackScreen` | `/api/v1/feedback/submit` | 🟡 Partial — UI done, not wired |
| `DisputeScreen` | `/api/v1/agent/resolve` | 🟡 Partial — UI done, not wired |
| `DisputeResolutionScreen` | Receives GuardianAgent response | 🟡 Partial — UI done, not wired |
| `BookingChatScreen` | Provider/user messaging | 🟡 Exists as ChatMessagingScreen |
| `ProviderDashboardScreen` | Provider-side views | 🟡 Redesigned, mock data |
| `BrowseDirectoryScreen` | `/api/providers` | 🔴 Missing — no browse screen |

---

## Section 4: New Frontend Analysis

The new Flutter app is called **KARIGAR**. It is a complete redesign from Figma with much better UI, more screens, and better structure. But it currently uses fake (mock) data for everything.

### What's New and Better in the New Frontend

- **🎨 Better Design System** — Proper `AppTheme.light` and `AppTheme.dark`. Real typography system, consistent colors, glassmorphism cards, decorative backgrounds.
- **✨ Animations** — Uses `flutter_animate` package for smooth transitions. Custom page transitions with fade+slide effect.
- **📱 More Screens** — Tutorial screens, live tracking, map view, confidence meter, reasoning panel drawer, and many more provider-specific screens.
- **🌐 Multi-language Ready** — `app_strings.dart` with Urdu/English string support. Ready for localization.

### New Screens That Don't Exist in the Old Frontend

**Consumer Screens (New):**
- Tutorial 1 & 2 screens
- Live Tracking screen
- Map View screen
- Confidence Meter screen
- Reasoning Panel / Drawer screen
- Low Confidence screen
- No Providers Found screen
- Provider Cancelled screen
- Dispute Resolving (loading) screen
- Chat Messaging screen
- Profile screen
- Provider Profile screen

**Provider Screens (New):**
- Provider En Route screen
- Provider Job Leads screen
- Provider Earnings screen
- Provider Wallet screen
- Provider History screen
- Provider Account Profile screen
- Provider Settings screen

### What the New Frontend Does NOT Have (Critical Gaps)

> 🚨 **Zero Backend Connection — Everything Uses Fake Data**
> The new frontend does not have the `http` or `web_socket_channel` packages. It does not have any ApiService, HttpClient, or WebSocketClient. Every screen shows hardcoded fake data from `MockDataService`. Nothing actually talks to the backend yet.

---

## Section 5: Gap Analysis — What's Missing

This is the most important section. Here is exactly what exists in the old frontend/backend that needs to be added to the new frontend.

### Missing: Packages (pubspec.yaml)

| Package | Purpose | In Old Frontend? | In New Frontend? |
|---------|---------|-----------------|-----------------|
| `http: ^1.6.0` | Make HTTP calls to backend | ✅ Yes | ❌ MISSING |
| `web_socket_channel: ^3.0.3` | Real-time WebSocket connection | ✅ Yes | ❌ MISSING |

### Missing: Network Layer Files

```
These files exist in old frontend but NOT in new frontend:

lib/core/network/
├── api_service.dart       ← Calls ALL backend endpoints
├── http_client.dart       ← HTTP GET/POST helper
├── websocket_client.dart  ← WebSocket connection
└── models.dart            ← Request/response models

lib/core/constants/
└── api_endpoints.dart     ← All URL constants

lib/features/booking/providers/
└── booking_provider.dart  ← Real Firestore bookings

lib/features/dispute/providers/
└── dispute_provider.dart  ← Real dispute handling

lib/features/matching/providers/
└── matching_provider.dart ← Real AI matching
```

### Missing: Screen-to-API Connections

| New Screen | What It Currently Does | What It Should Do (Backend) |
|------------|----------------------|----------------------------|
| `ChatActiveScreen` | Fake timer simulates AI steps | Connect to `/ws/agent-stream` WebSocket, show real AI reasoning |
| `ProviderRankingScreen` | Shows hardcoded mock providers | Display real providers from `/api/v1/agent/coordinate` response |
| `PriceBreakdownScreen` | Shows hardcoded price | Show real price quote from coordinator agent response |
| `BookingConfirmedScreen` | Shows fake confirmation | Call `/api/v1/agent/execute` to create real Firestore booking |
| `BookingHistoryScreen` | Shows 4 mock bookings | Call `/api/v1/bookings?user_id=...` to load real bookings |
| `FeedbackScreen` | Accepts input but does nothing | Call `/api/v1/feedback/submit` to save feedback |
| `DisputeScreen` | Accepts input but does nothing | Call `/api/v1/agent/resolve` to resolve via GuardianAgent |
| `DisputeResolutionScreen` | Shows placeholder text | Display real GuardianAgent resolution result |
| `BookingDetailScreen` | Shows mock booking info | Load real booking + allow status update via `PATCH /api/v1/booking/{bid}/status` |

### What the Old Frontend Has That Should Also Be in New Frontend

> 📋 **Browse Directory Screen — Currently Missing**
> The old frontend has a `BrowseDirectoryScreen` that calls `/api/providers` to list all service providers by category. The new frontend does not have this screen. It should be added eventually.

---

## Section 6: Step-by-Step Migration Plan

> ✅ **Golden Rule: The Backend Stays Completely Untouched**
> You will never modify `ai_seekho_backend/` at all. You are only working on the Flutter frontend. The backend is already working and already has all the features you need.

### Phase 0 — Before Anything: Create a Safety Net

Do this FIRST, before changing a single file. This protects you if anything goes wrong.

- Open a terminal inside your `ai-seekho-hackathon-2026` folder
- Run: `git checkout -b feature/karigar-frontend` — this creates a safe branch
- Your original `main` branch stays unchanged as a backup
- Copy the `ai_seekho_flutter_frontend` zip into the repo as a new folder
- Name it something clear like `karigar_frontend/` inside the main project folder
- Commit this as: `git commit -m "chore: add new KARIGAR frontend (not yet integrated)"`

### Phase 1 — Add the Missing Packages

Open `karigar_frontend/pubspec.yaml` and add two packages.

- Under `dependencies:`, add: `http: ^1.6.0`
- Also add: `web_socket_channel: ^3.0.3`
- Run `flutter pub get` in your terminal
- If there are version conflicts, check the exact versions from the old frontend's pubspec.yaml

### Phase 2 — Copy the Network Layer (Most Important Step)

Copy these 5 files from the old frontend into the new frontend. Do NOT modify them yet — just copy.

- Copy `old/lib/core/network/api_service.dart` → `new/lib/core/network/api_service.dart`
- Copy `old/lib/core/network/http_client.dart` → `new/lib/core/network/http_client.dart`
- Copy `old/lib/core/network/websocket_client.dart` → `new/lib/core/network/websocket_client.dart`
- Copy `old/lib/core/network/models.dart` → `new/lib/core/network/models.dart`
- Copy `old/lib/core/constants/api_endpoints.dart` → `new/lib/core/constants/api_endpoints.dart`
- Fix any import paths that reference `ai_seekho_flutter` — change them to `ai_seekho` (the new package name)
- Test that the app still compiles: `flutter run`

### Phase 3 — Copy the Providers (Real State Management)

The old frontend has real Riverpod providers that fetch data from the API. Copy them into the new frontend.

- Create folder: `new/lib/features/booking/providers/`
- Copy `old/features/booking/providers/booking_provider.dart` into it
- Create folder: `new/lib/features/dispute/providers/`
- Copy `old/features/dispute/providers/dispute_provider.dart` into it
- Copy `old/features/matching/providers/matching_provider.dart` → `new/lib/features/matching/providers/`
- Fix all import paths (change package name from `ai_seekho_flutter` to `ai_seekho`)
- Test compilation again

### Phase 4 — Connect Screens One by One (Never All At Once)

This is the main work phase. Connect each screen to its backend API, one screen at a time. Do NOT rush through all screens in one go.

- **Start with `BookingHistoryScreen`** — it's the easiest to test (just loads a list from the API)
- Then connect **`ChatActiveScreen`** — replace the fake timer with a real WebSocket connection to `/ws/agent-stream`
- Then connect **`ProviderRankingScreen`** — replace mock provider list with real coordinator response
- Then connect **`PriceBreakdownScreen`** and **`BookingConfirmedScreen`** (these depend on ranking working first)
- Then connect **`FeedbackScreen`**, **`DisputeScreen`**, and **`DisputeResolutionScreen`**
- For each screen: test it fully before moving to the next
- If a screen breaks, revert just that screen — don't panic, the other screens are fine

### Phase 5 — Remove Mock Data (Only After Real Data Works)

Only do this phase AFTER you have confirmed the real API data is showing correctly in each screen.

- Keep `mock_data_service.dart` as a fallback — do not delete it yet
- Update `app_providers.dart` to use real providers instead of mock data
- Test the full user journey from home → chat → booking → history → feedback
- Once everything works end-to-end, you can archive mock data as a dev fallback

### Phase 6 — Replace the Old Frontend Folder (Final Step)

Only do this after Phase 5 is fully working and tested.

- Rename `ai_seekho_flutter/` to `ai_seekho_flutter_OLD_backup/` — do NOT delete yet
- Rename `karigar_frontend/` to `ai_seekho_flutter/` (or keep as its own folder)
- Keep the old folder around for at least 2 weeks before deleting
- Make a Git tag: `git tag v1.0-karigar-integrated`

---

## Section 7: What You Must NOT Delete or Change

### 🚫 NEVER Delete or Modify These Files/Folders

- **The entire `ai_seekho_backend/` folder** — This is your backend. It does not need any changes.
- **`ai_seekho_backend/.env`** — Contains your Gemini API key, Maps API key, and Firebase credentials path. If you delete this, your backend will stop working completely.
- **`ai-seekho--01-firebase-adminsdk-fbsvc-ff54490668.json`** — This is your Firebase service account key. Without it, no data can be saved to Firestore.
- **`ai_seekho_backend/config/firebase_config.py`** — Firebase connection setup. Do not touch.
- **`google-services.json`** (root of old project) — Android Firebase config. Do not delete.
- **The `main` Git branch** — Always work on a feature branch. Never force-push to main.
- **The old `ai_seekho_flutter/` folder** — Keep it as backup until the new frontend is fully working.

> ⚠️ **Never commit the .env file or Firebase JSON key to Git**
> They are already in `.gitignore`. Keep them there. If you accidentally commit them, rotate (regenerate) your API keys immediately via Google Cloud Console and Firebase Console.

---

## Section 8: Risks & Warnings

### Package Name Mismatch

> ⚠️ **The package name changed: `ai_seekho_flutter` → `ai_seekho`**
> Every import path in copied files will say `package:ai_seekho_flutter/...`. You must change all of them to `package:ai_seekho/...`. Do a find-and-replace in your editor. Missing even one will cause a compile error.

### Riverpod Version Difference

> ⚠️ **The old frontend uses `flutter_riverpod: ^3.3.1`, the new uses `^2.6.1`**
> This is a major version difference. Provider syntax may be different between v2 and v3. When you copy providers from the old frontend, some code may not compile in the new frontend. The safest fix is to upgrade the new frontend's Riverpod to v3 as well, OR rewrite the copied providers to match v2 syntax. Either approach works — but check first.

### go_router Version Difference

> ⚠️ **Old uses `go_router: ^17.2.3`, new uses `^14.8.1`**
> There may be API differences. If you copy router-related code from the old frontend, test it carefully. The safest approach: keep the new frontend's routing code as-is and only copy the networking/provider layers.

### Android Emulator URL

> 💡 **Different URLs for Android Emulator vs iOS Simulator**
> The backend runs on `localhost:8000`. On Android Emulator you must use `10.0.2.2:8000` instead of `127.0.0.1:8000`. The old `api_endpoints.dart` already handles this with a build flag. When testing on a real device, you'll need to use your computer's actual network IP address.

### WebSocket Connection — The Most Complex Part

> 🔴 **`ChatActiveScreen` has the hardest integration**
> The current `ChatActiveScreen` uses a simple `Timer` to fake AI progress. Replacing this with a real WebSocket requires: connecting to `/ws/agent-stream`, sending the user's query as JSON, and then parsing incoming events (`thinking`, `tool_call`, `tool_result`, `completed`) and mapping them to the 5 visual stages. Do this step last, after all simpler API connections are working.

---

## Section 9: Quick Reference Summary

### At a Glance: The Migration in One Table

| What | Action | When |
|------|--------|------|
| Backend (`ai_seekho_backend/`) | 🔒 Touch nothing. Leave it exactly as it is. | Never |
| Old Flutter folder | 📦 Keep as backup, don't delete yet | Until new works |
| New Flutter folder | ✅ This becomes your main codebase | Now |
| Add `http` + `web_socket_channel` packages | ➕ Add to new pubspec.yaml | Phase 1 |
| 5 network layer files | 📋 Copy from old, fix package name | Phase 2 |
| 3 provider files | 📋 Copy from old, fix package name | Phase 3 |
| `BookingHistoryScreen` | 🔗 Connect to `/api/v1/bookings` | Phase 4, first |
| `ChatActiveScreen` | 🔗 Connect to WebSocket `/ws/agent-stream` | Phase 4, second |
| ProviderRanking + Price + Confirmed | 🔗 Connect to coordinator + executor | Phase 4, third |
| Feedback + Dispute screens | 🔗 Connect to feedback + resolve APIs | Phase 4, fourth |
| Mock data | 🗑 Remove (or keep as dev fallback) | Phase 5 |
| Old Flutter folder | 🗑 Safe to archive/delete | Phase 6, after testing |

### The Ideal Final Folder Structure

```
ai-seekho-hackathon-2026/
├── ai_seekho_backend/          ← Backend (unchanged)
│   ├── main.py
│   ├── agents/
│   ├── services/
│   └── .env                    ← NOT in Git
│
├── karigar_frontend/           ← Your new Flutter app
│   ├── lib/
│   │   ├── core/network/       ← Copied from old frontend
│   │   ├── core/constants/     ← Copied from old frontend
│   │   ├── features/           ← New beautiful screens
│   │   ├── services/           ← MockDataService (kept as fallback)
│   │   └── main.dart
│   └── pubspec.yaml            ← Includes http + web_socket_channel
│
├── ai_seekho_flutter_OLD_backup/   ← Old frontend (keep for now)
│
└── README.md
```

> 🎯 **One Final Piece of Advice**
> Do NOT try to migrate everything at once in a single day. The safest approach is: one phase per coding session, test fully after each phase, commit to Git after each successful phase. This way, if something breaks, you can always roll back to your last commit and nothing is permanently lost.

---

*Generated by deep analysis of both project zips • ai-seekho-hackathon-2026 + ai_seekho_flutter_frontend • May 2026*
