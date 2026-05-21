# Known limitations (hackathon build)

## Antigravity SDK

- **Not integrated.** Agent orchestration uses Gemini function-calling in `ai_seekho_backend` (`CoordinatorAgent`, `ExecutorAgent`, `GuardianAgent`).
- WebSocket `/ws/agent-stream` replays trace events **after** a synchronous `coordinator.run()` — not true token-by-token Antigravity streaming.
- No Antigravity handoff to external runtimes; `AgentHandoff` is an in-repo Pydantic model only.

## Authentication

- **Deferred (P3).** Demo user id `user_demo_001` is hardcoded in API calls.
- Phone OTP screens are UI-only; SMS is not sent (mock flow).
- No Firebase Auth token on HTTP/WS requests yet.

## Live tracking

- Polls `GET /api/v1/bookings` every 10s; no provider GPS WebSocket.
- **No ETA** — header shows status text only (`On the way`, `Scheduled HH:MM`, etc.).
- Call Provider / in-app chat on tracking screen show “coming soon” (no telephony or messaging backend).

## Provider (kaarigar) app

- Provider dashboard screens are **static / mock** — no provider-side booking accept/reject APIs wired.
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
