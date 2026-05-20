# KARIGAR — Flutter Mobile Frontend

> **This is the canonical submission app for AI Seekho Hackathon 2026.**  
> Package name: `ai_seekho` · Entry point: `lib/main.dart` · App title: `KARIGAR`

See [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) for the full architecture, API contract table, data flow diagram, and environment variable reference.

---

## Quick Start

### Prerequisites

- Flutter SDK ≥ 3.x (`flutter --version`)
- Backend running at `localhost:8000` (see [backend setup](../../ARCHITECTURE.md#8-run-commands-quick-reference))

### Android Emulator (recommended for development)

```bash
cd kaarigar_frontend/ai_seekho_flutter_frontend
flutter pub get
flutter run --dart-define=ANDROID_EMULATOR=true
```

The `ANDROID_EMULATOR=true` flag routes API calls to `10.0.2.2:8000` instead of `127.0.0.1:8000`, which is required for Android emulator networking.

### Physical Device / iOS Simulator

```bash
cd kaarigar_frontend/ai_seekho_flutter_frontend
flutter pub get
flutter run
```

---

## App Architecture

```
lib/
├── core/
│   ├── constants/api_endpoints.dart   ← all backend URL constants
│   ├── network/http_client.dart       ← single HTTP client (no duplicates)
│   └── theme/app_theme.dart
├── features/                          ← feature-first screen modules
├── models/                            ← Dart data models
├── routes/app_router.dart             ← go_router config
├── services/                          ← ApiService, MockDataService (fallback only)
├── widgets/                           ← shared UI components
└── main.dart                          ← KarigarApp + backendOnlineProvider
```

**State management:** Riverpod (`flutter_riverpod`)  
**Routing:** `go_router`  
**Fonts:** Google Fonts — Nunito  
**Animations:** `flutter_animate`

---

## Backend Connectivity

On startup, `main.dart` pings `GET /` with a 3-second timeout and sets `backendOnlineProvider`.

- **`backendOnlineProvider == true`** → `ApiService` makes live calls to all `/api/v1/*` endpoints.  
- **`backendOnlineProvider == false`** → offline banner is shown; `MockDataService` may be used as a fallback **only** with an explicit banner indicating mock data.

---

## Onboarding Flow

1. Splash → **Language** selection (first launch)
2. Tutorial carousel (with Skip)
3. Role selection: **Seeker** / **Provider**
4. Phone auth → OTP verification
5. Profile setup (name, city, area, street address)
6. Home (seeker) or Provider dashboard

---

## Key API Endpoints Used

| Screen | Endpoint |
|--------|----------|
| Chat / matching | `POST /api/v1/agent/coordinate` + `WS /ws/agent-stream` |
| Confirm booking | `POST /api/v1/agent/execute` |
| Booking history | `GET /api/v1/bookings?user_id=<uid>` |
| Status update | `PATCH /api/v1/booking/{bid}/status` |
| Feedback | `POST /api/v1/feedback/submit` |
| Dispute | `POST /api/v1/agent/resolve` |

Full request/response schemas: [ARCHITECTURE.md § 3](../../ARCHITECTURE.md#3-api-contract-table)

---

## Stack

| Dependency | Purpose |
|------------|---------|
| `flutter_riverpod` | State management & dependency injection |
| `go_router` | Declarative navigation |
| `google_fonts` | Nunito typeface |
| `flutter_animate` | Micro-animations |
| `web_socket_channel` | WebSocket client for agent stream |

---

## ⚠️ Legacy Note

`ai_seekho_flutter/` (repo root sibling) is a **legacy prototype** and is **not** this app.  
Do not run it as the submission frontend.
