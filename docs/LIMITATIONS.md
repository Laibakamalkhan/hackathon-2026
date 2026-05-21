# Known limitations (hackathon build)

## Antigravity SDK

- **Workflow bridge integrated** in `orchestrator/antigravity_workflow.py` — all coordinate/execute/resolve paths tagged with Antigravity node metadata.
- Optional `pip install google-antigravity` detected via `importlib`; native Gemini agent graph used as fallback.
- **Not in `requirements.txt`:** PyPI wheels are Linux/macOS only (no Windows build); install manually on supported OS if needed.
- WebSocket still replays trace events after synchronous `coordinator.run()` (demo pacing ~400ms between steps).

## Authentication

- **Partial (P3).** `firebase_auth` is integrated with graceful fallback:
  - If `Firebase.initializeApp()` succeeds → real phone OTP via Firebase.
  - If Firebase is not configured (no `google-services.json` / options) → demo session (`demo_<phone>` or `user_demo_001`) via `HttpClient.demoUid`.
- Backend does not yet validate `Authorization` bearer tokens on API routes.

## Live tracking

- Polls `GET /api/v1/bookings` every 10s; no live GPS WebSocket.
- **ETA** estimated from `distance_km` when status is `en_route` (heuristic, not Maps traffic).
- Call is simulated snackbar; chat uses `GET/POST /api/v1/booking/{bid}/messages`.

## Provider (kaarigar) app

- Dashboard wired to `GET /api/v1/provider/{pid}/dashboard` and job status PATCH.
- Earnings/history sub-screens may still use partial static UI when Firestore has no provider bookings.
- Debug “Simulate en_route” only available in `kDebugMode` on consumer live tracking.

## Offline / mock fallbacks

- If backend health check fails at startup, chat pipeline may use timer demo stages.
- Bookings list falls back to `MockDataService.bookings` when GET bookings throws.
- Browse map/list uses `providersListProvider` → real API when online; mock providers only in offline booking fallback path.

## Reschedule

- PATCH supports `scheduled_time` (ISO 8601 UTC). UI does not re-run slot validation against provider `availability_slots` (server-side validation on create/execute only).

## Chat home quick actions

- Preset chips (`Plumber`, `AC Repair`, etc.) seed the user message into the agent pipeline — not separate category APIs.

## Documentation scope

- `docs/API_CONTRACT_v1.md` — frozen integration fields for demo handoff.
- Provider dashboard APIs, Firebase, and Antigravity are **out of scope** for this sprint slice.
