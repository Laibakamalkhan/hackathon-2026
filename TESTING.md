# AI Seekho Hackathon - Stress Scenarios Demo Checklist

This document provides a reproducible script for demonstrating all required stress scenarios for the hackathon judges. 
Each scenario is designed to showcase the resilience, fairness, and error-handling capabilities of the AI Seekho platform.

**Target Video Length:** 3-5 minutes

## Prerequisites
- Backend must be running (`python main.py` or equivalent).
- Flutter frontend must be connected to the backend (ensure backend URL is constant and `backendOnline == true`).
- `MockDataService` should NOT be used (except for explicit retry fallback with banner).
- Debug Mode should be active in Flutter to access the Stress Scenarios Screen.

## Shot List & Script

### Scenario 1: Obscure Category + Tight Time (No Provider Available)
**Goal:** Show how the system handles impossible requests gracefully without showing fake success.
1. **Navigate:** Open the Stress Scenarios Debug Screen.
2. **Action:** Tap the "Trigger No Providers (Spaceship Repair)" button. This pre-fills the chat with "Mujhe abhi ke abhi spaceship repair wala chahiye".
3. **Assert:** 
   - The coordinator agent processes the request.
   - The UI displays an empathetic failure message (e.g., "No providers found near you").
   - The providers list is empty (NO success UI is shown).
   - An option to adjust the request or location is presented.

### Scenario 2: Provider Conflict (Double Booking)
**Goal:** Demonstrate atomicity and slot validation preventing double bookings.
1. **Setup:** In the backend, ensure a provider slot is already taken (or simulate a conflict during booking).
2. **Action:** Attempt to book a provider for a slot that just got taken or is unavailable.
3. **Assert:**
   - The executor agent detects the conflict via `validate_slot_tool`.
   - The booking fails cleanly.
   - The UI shows a conflict message ("Schedule conflict occurred").
   - The system automatically suggests the next available slot instead of crashing or booking anyway.

### Scenario 3: Low Confidence Query (Vague Text)
**Goal:** Showcase the coordinator's ability to ask clarifying questions when intent is ambiguous.
1. **Navigate:** Open the Stress Scenarios Debug Screen.
2. **Action:** Tap the "Trigger Low Confidence (Vague Query)" button. This pre-fills the chat with "kuch theek nahi chal raha".
3. **Assert:**
   - The `understand_request_tool` returns a confidence score `< 0.70`.
   - The AI pauses the workflow and asks a follow-up question (e.g., "Kya aap apni zaroorat ke baare mein thodi aur tafseelaat de sakte hain?").
   - Providers are NOT fetched prematurely.

### Scenario 4: Dispute Price Disagreement
**Goal:** Highlight the Guardian Agent's fair dispute resolution and auto-mediation.
1. **Setup:** Have a completed mock booking (e.g., total paid PKR 1500, base fee PKR 500).
2. **Navigate:** Go to the disputes/feedback section for that booking.
3. **Action:** Submit a dispute for "price_disagreement" with the comment "Unhone 500 ziyada maange".
4. **Assert:**
   - The Guardian Agent evaluates the claim.
   - A deterministic refund (or no_action) is computed based on the rules.
   - The provider's reputation is penalized appropriately.
   - The UI displays an empathetic, bilingual explanation of the resolution.

## Validation Checklist (Pre-Recording)
- [ ] `python -m unittest tests/test_stress_scenarios.py` passes successfully.
- [ ] The Flutter app compiles without errors (`flutter analyze` is clean).
- [ ] The Debug Screen is strictly guarded by `kDebugMode` and does not appear in release builds.
- [ ] No hardcoded PKR amounts or provider names are visible; everything is driven by the backend API.
