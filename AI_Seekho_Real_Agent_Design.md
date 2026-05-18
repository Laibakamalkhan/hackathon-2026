# 🧠 AI Seekho — Agentic System Rethink
### How Real Agents Should Work: Reasoning, Autonomy, Human-in-Loop, and Workflow

**For Antigravity:** This is the agent design. Not API wrappers. Not pipelines. Real agents that reason, get surprised, make judgment calls, pause for human input at the right moments, and recover from failure on their own.

---

> **The problem with the old spec:** It described 6 functions that call each other in sequence. That is not agentic. A real agent:
> - Starts with a goal, not a script
> - Encounters unexpected situations and figures out what to do
> - Knows when it can decide alone vs when to ask the human
> - Acts in the world (writes, sends, books) not just returns data
> - Monitors what it did and reacts if things go wrong
>
> Every agent below is defined by: **what it's trying to achieve**, **how it reasons**, **what it can decide alone**, **when it pauses for the human**, and **what it does when things go sideways.**

---

## THE REAL PROBLEM (re-read from the challenge)

A user sends a WhatsApp-style broken message:
> *"AC bilkul kaam nahi kar raha, kal subah G-13 mein technician chahiye, budget zyada nahi hai"*

What needs to happen is not a pipeline. It's a **conversation between an intelligent coordinator and a stressed user**, followed by autonomous action, followed by monitoring, followed by resolution if anything goes wrong.

The coordinator (our agent system) must:
1. Understand what the user actually needs — not just extract keywords
2. Go find the right person for the job — not just sort a list
3. Negotiate and confirm on the user's behalf — so the user doesn't have to chase anyone
4. Watch over the service while it's happening — catch problems before they become crises
5. Handle anything that goes wrong — without making the user fight for it

This is the difference between a search engine and an agent.

---

## AGENT ARCHITECTURE: 3 AGENTS, REAL GOALS

Instead of 6 micro-agents that do one narrow thing each, we have **3 agents with real agency** — each owns a phase of the lifecycle, reasons across multiple concerns, and hands off with full context.

```
USER
 │
 │  "AC bilkul kaam nahi kar raha..."
 ▼
┌─────────────────────────────────────────────────────────┐
│  AGENT 1: THE COORDINATOR                               │
│  Goal: Understand exactly what's needed and find        │
│  the best provider. Keep user informed. Get their ok.   │
│                                                         │
│  Reasons about: language, urgency, context, tradeoffs   │
│  Decides alone: who to contact, what to offer           │
│  Pauses for human: final provider + price confirmation  │
└──────────────────────────┬──────────────────────────────┘
                           │ "Confirmed — book Ali"
                           ▼
┌─────────────────────────────────────────────────────────┐
│  AGENT 2: THE EXECUTOR                                  │
│  Goal: Make the booking real. Send confirmations.       │
│  Schedule reminders. Watch the service happen.          │
│                                                         │
│  Reasons about: conflicts, timing, provider behavior    │
│  Decides alone: slot conflicts, reminder timing         │
│  Pauses for human: if provider cancels, if no-show      │
└──────────────────────────┬──────────────────────────────┘
                           │ Service completed / something went wrong
                           ▼
┌─────────────────────────────────────────────────────────┐
│  AGENT 3: THE GUARDIAN                                  │
│  Goal: Make sure the user got what they paid for.       │
│  Collect feedback. Resolve disputes. Update reputation. │
│                                                         │
│  Reasons about: evidence, provider history, fairness    │
│  Decides alone: compensation amount, provider warning   │
│  Pauses for human: large refunds, permanent bans        │
└─────────────────────────────────────────────────────────┘
```

---

## AGENT 1 — THE COORDINATOR

**File:** `backend/agents/coordinator_agent.py`

### What This Agent Is Actually Trying To Do

A stressed user sent a broken message. The Coordinator's job is to go from that broken message to a confirmed booking — but not blindly. It must understand the user's *real situation*, reason about tradeoffs the user hasn't even thought of, and present a recommendation the user can trust. It's the smart friend who knows all the plumbers in town and tells you which one to actually call.

### The Reasoning Loop (this is what makes it an agent)

The Coordinator does NOT just extract fields and query a DB. It runs a loop:

```
THINK → ACT → OBSERVE → THINK → ACT → OBSERVE → PAUSE (human) → ACT
```

Here's what that actually looks like:

**THINK:** What is this user really asking for?
- "AC bilkul kaam nahi" — bilkul is an intensifier. This isn't "check my AC." The AC is fully dead. Urgency is high.
- "kal subah" — tomorrow morning. Not today. They're stressed but not panicking. This means I have time to find the *right* provider, not just the nearest available.
- "budget zyada nahi" — price sensitive. This changes the tradeoffs I should optimize for.
- Missing: which G-13 sector? G-13/1, /2, /3, /4? Distance calculations will be off. I need to ask — but only this one thing. Don't bombard.

**ACT:** Ask the one missing question, then query providers.

**OBSERVE:** Found 7 providers in G-13 area. But wait:
- Top-rated provider (Ali, 4.8★) has 3 recent reviews mentioning "late arrival." His on-time score is listed as 0.88 but his last 5 reviews tell a different story.
- Second provider (Hassan) is 1km closer AND cheaper AND has 0.94 on-time score. BUT he has no inverter AC reviews — and "AC bilkul kaam nahi" on a hot day in Pakistan likely means inverter AC (most common in G-series).
- Third provider (Tariq) has inverter AC specialization AND good on-time score but is PKR 300 more expensive for a price-sensitive user.

**THINK:** This is a real tradeoff. If I just sort by composite score, Hassan wins. But Hassan can't confidently fix an inverter AC. Tariq can but is expensive. I need to surface this to the user honestly — not hide it behind a number.

**ACT:** Recommend Tariq with honest reasoning in Urdu. Show Hassan as the budget option with the caveat. Don't hide the tradeoff.

**PAUSE FOR HUMAN:** Show the user the recommendation + reasoning. Wait for their choice. They might pick Hassan and accept the risk. That's their right. The agent's job is to make them an informed decision-maker, not decide for them.

### What The Coordinator Can Decide Alone (no human needed)

- Which providers to contact (user doesn't need to see the shortlisting)
- Whether to expand search radius (if < 3 providers found, quietly expand by 5km)
- Which follow-up question to ask (pick the most important missing field only)
- Whether to re-rank after reading review text (not just scores)
- Whether to warn about a provider (high rating but recent bad pattern = show warning)
- Which price breakdown to show first (match user's budget sensitivity)

### What Always Requires Human Confirmation

- Final provider selection → the user must tap "Book"
- If the agent is unsure between two very similar providers, it says so and asks the user which tradeoff they prefer
- If no good provider exists → explicitly tell the user and ask if they want to wait, expand area, or lower their standards

### Coordinator State Machine

```
IDLE
  │  user sends message
  ▼
UNDERSTANDING
  │  confidence < 0.7 → ask one question → back to UNDERSTANDING
  │  confidence ≥ 0.7 →
  ▼
SEARCHING
  │  no providers found → tell user honestly → offer waitlist or expand
  │  providers found →
  ▼
REASONING_ABOUT_TRADEOFFS
  │  generates honest reasoning per provider
  │  flags any warnings (recent bad reviews, high cancellation)
  │
  ▼
PRESENTING_TO_USER  ← ← ← ← human is in the loop here
  │  user selects provider + slot
  ▼
GENERATING_QUOTE
  │  shows itemized breakdown
  │  if budget conflict → proactively offers alternative
  ▼
AWAITING_CONFIRMATION  ← ← ← human is in the loop here
  │  user confirms
  ▼
HANDING_OFF_TO_EXECUTOR  (passes full context)
```

### ADK Implementation

```python
# backend/agents/coordinator_agent.py

class CoordinatorAgent(Agent):
    """
    Goal-directed agent. Not a pipeline. 
    Runs a reasoning loop until it reaches AWAITING_CONFIRMATION, 
    then hands off to ExecutorAgent on user confirmation.
    """
    
    name = "CoordinatorAgent"
    
    # These are the tools it can USE (actions it can take in the world)
    tools = [
        understand_request_tool,       # Gemini: multilingual parsing
        ask_clarification_tool,        # injects follow-up question into chat
        search_providers_tool,         # queries Firestore + Maps
        read_recent_reviews_tool,      # reads actual review text, not just scores
        compute_match_scores_tool,     # 8-factor weighted scoring
        generate_tradeoff_reasoning_tool,  # Gemini: writes honest Urdu reasoning
        compute_price_quote_tool,      # dynamic pricing formula
        present_options_to_user_tool,  # sends structured response to Flutter chat
        flag_provider_warning_tool,    # surfaces red flags to user
    ]
    
    instruction = """
    You are a smart coordinator helping a Pakistani user find and book a service provider.
    
    Your goal is to get the user to a confirmed booking they trust.
    
    REASONING RULES:
    1. Never show the user a provider you wouldn't recommend to a friend.
    2. If two providers are close in score, tell the user honestly and let them choose.
    3. If a provider has high stars but recent bad reviews, surface the warning. Never hide it.
    4. If the user is price-sensitive (said "budget zyada nahi" or similar), always show a budget option alongside your recommendation.
    5. Only ask ONE clarifying question at a time. Never ask 3 things at once.
    6. Your reasoning must be in the user's language (Urdu/Roman Urdu if that's what they wrote).
    7. You can silently expand the search radius, silently retry failed API calls — 
       but never silently lower the quality of recommendation you make.
    
    WHEN TO STOP AND ASK THE HUMAN:
    - When you've found and ranked providers → show them, wait for selection
    - When the quote is ready → show it, wait for confirmation
    - When you genuinely cannot decide between 2 options → say so, ask user preference
    - When NO good option exists → be honest, don't pretend
    
    WHEN YOU CAN ACT ALONE:
    - Expanding search radius when results are thin
    - Re-reading review text to override misleading aggregate scores  
    - Choosing which clarifying question is most important
    - Deciding to show a warning on a provider card
    """
```

### Tools Detail

**`understand_request_tool`**
```python
# Calls Gemini with this system prompt:
MULTILINGUAL_PARSER_PROMPT = """
You are an expert at Pakistani service requests in Urdu, Roman Urdu, English, and mixed language.

Do not just extract fields. REASON about what the user actually needs.

Ask yourself:
- How urgent is this really? ("bilkul" and "abhi" are intensifiers)
- Is the user stressed or just planning ahead?
- What time constraint matters most?
- What is their actual budget tolerance vs stated tolerance?
- What are they NOT saying that I should infer from context?

Extract:
- service_type: [ac_repair, plumbing, electrical, tutoring, beauty, driving, mechanics, general_home]
- location: as stated
- urgency: [low, medium, high, emergency] with reasoning
- time_preference: specific or relative
- budget_sensitivity: [low, medium, high]
- inferred_context: any situational clues (e.g., "sounds like a hot day emergency")
- missing_fields: what's genuinely unclear and needs one follow-up question
- confidence: 0.0–1.0
- most_important_missing_field: which ONE field to ask about if confidence < 0.7

Return JSON only.
"""
```

**`read_recent_reviews_tool`**
```python
# This is what separates the agent from a simple ranker.
# Fetches last 10 review texts for each shortlisted provider.
# Sends to Gemini: "Does this provider have any concerning patterns? 
#                  Look for: late arrivals, price disputes, incomplete work, rudeness."
# Returns: { "warning": null | "string describing concern", "sentiment_score": 0.0-1.0 }
# The agent then DECIDES whether to show a warning card, override the composite score, 
# or exclude the provider entirely.
```

**`generate_tradeoff_reasoning_tool`**
```python
# For each top-3 provider, generates a human-readable explanation IN URDU of why 
# the agent recommends or warns about them.
# Input: provider scores, warnings, user's stated preferences
# Output: 2-3 sentences in Roman Urdu explaining the recommendation
# 
# Example output:
# "Ali ko isliye suggest kar rahe hain kyunki inverter AC mein 12 saal ka tajruba hai 
#  aur 94% waqt per aate hain. Hassan 1km paas hain aur sasta bhi hai, lekin 
#  unke haalia reviews mein 3 baar late aane ki shikayat hai."
```

### Flutter Integration

```
ChatActive screen:
  - User types message → POST /api/v1/agent/coordinate
  - Response type "ask_clarification" → inject as system message bubble
  - Response type "show_providers" → render ProviderRanking screen
  - Response type "show_quote" → render PriceBreakdown screen
  - User taps "Book" → POST /api/v1/agent/confirm → hands to ExecutorAgent

AgentTracePanel shows:
  "🧠 Coordinator: Reading your request..."
  "🔍 Coordinator: Found 7 providers — checking recent reviews..."
  "⚠️ Coordinator: Ali has recent late-arrival complaints — adjusting ranking"
  "✅ Coordinator: Recommending Tariq — ready for your decision"
```

---

## AGENT 2 — THE EXECUTOR

**File:** `backend/agents/executor_agent.py`

### What This Agent Is Actually Trying To Do

The user said yes. Now make it real. The Executor's job is to turn a user's confirmation into a concrete, tracked, reminded, monitored booking — and to watch over it until the service actually happens. If anything goes wrong between confirmation and completion, the Executor must catch it and handle it — without making the user follow up.

This is the agent that actually acts in the world. It writes to databases. It sends messages. It sets timers. It checks in.

### The Reasoning Loop

**THINK:** What needs to happen right now, and in what order, for this booking to be real?
1. Check one more time that the slot is still free (race condition — another user might have just booked Ali)
2. Lock the slot atomically
3. Tell both parties (confirmation message to user, job alert to provider)
4. Set up the monitoring schedule (when to remind, when to check on status)
5. Confirm to user that everything is done

**ACT:** Execute all of the above. Log every action.

**OBSERVE (over time):**
- T-24h: Did I send the reminder? Did the provider acknowledge?
- T-1h: Is the provider still showing as available? Did they mark themselves en-route?
- T+0 (scheduled time): Is the provider marked as arrived? If not, flag.
- T+30min: Provider still not marked arrived → this is a problem. Act.

**THINK (when something goes wrong):**
"Provider has not marked en-route 45 minutes after the job was supposed to start. 
What do I know?
- Their last location update was 3 hours ago
- They have a 0.04 cancellation rate — this is unusual for them
- I should try to reach them first before alarming the user
- If no response in 10 minutes → escalate to Guardian and notify user"

**ACT:** Try provider ping. Start countdown. Escalate to Guardian if no response.

**PAUSE FOR HUMAN:** When something goes wrong that affects the user's day — provider no-show, last-minute cancellation — the Executor does NOT silently fix it. It notifies the user immediately, explains what happened, tells them what it's doing about it, and gives them a choice.

### What The Executor Can Decide Alone

- Whether a slot conflict is real or a data sync issue (retry and check)
- Which reminder message to send (formats based on urgency + time remaining)
- Whether to extend or re-ping a provider before declaring no-show (gives 15-min grace)
- When to trigger the Guardian (based on how severe the situation is)
- Whether to auto-assign a backup provider (only if user has pre-authorized this in settings)

### What Always Requires Human Notification (not necessarily approval)

- Slot conflict detected after user confirmed → tell user immediately, show alternatives
- Provider cancels → user must be told + asked if they want to rebook or cancel
- Provider no-show confirmed → user must be told what options are available
- Service marked complete → user must confirm they're satisfied before the booking closes

### Executor State Machine

```
BOOKING_INITIATED (received from Coordinator)
  │
  ├─ Slot still free? 
  │    NO → tell user, show alternatives → back to Coordinator
  │    YES →
  ▼
BOOKING_LOCKED (atomic write to Firestore)
  │
  ▼
NOTIFICATIONS_SENT
  │  user: "✅ Booking confirmed — Ali AC Services, kal subah 9 AM"
  │  provider: "📋 Naya kaam mila — [user address], 9 AM"
  │
  ▼
MONITORING_SCHEDULED
  │  T-24h reminder set
  │  T-1h reminder set
  │  T+0 no-show check set
  │
  ▼
WAITING  ←─────────────────────────────────────────┐
  │                                                  │
  ├─ T-24h fires → send reminder → back to WAITING   │
  │                                                  │
  ├─ T-1h fires → send reminder → back to WAITING    │
  │                                                  │
  ├─ Provider marks en_route →                       │
  │    notify user with ETA → back to WAITING        │
  │                                                  │
  ├─ Provider marks arrived →                        │
  │    notify user → SERVICE_IN_PROGRESS             │
  │                                                  │
  ├─ T+30min, no en_route status →                  │
  │    SUSPECT_NO_SHOW                               │
  │    ping provider → wait 10 min                  │
  │    still no response → ESCALATE_TO_GUARDIAN      │
  │    notify user immediately ─────────────────────┘
  │
  └─ Provider marks completed →
       SERVICE_COMPLETED → notify user → hand to Guardian
```

### ADK Implementation

```python
# backend/agents/executor_agent.py

class ExecutorAgent(Agent):
    """
    Acts in the world. Monitors outcomes. Catches failures before users notice.
    """
    
    name = "ExecutorAgent"
    
    tools = [
        check_slot_atomically_tool,        # Firestore transaction — lock or fail
        write_booking_tool,                 # Creates booking doc in Firestore
        notify_user_tool,                   # FCM push + in-app message
        notify_provider_tool,               # FCM push to provider app
        simulate_sms_tool,                  # Mock SMS confirmation
        simulate_whatsapp_tool,             # Mock WhatsApp message
        schedule_reminder_tool,             # Creates timed trigger in Firestore
        check_provider_status_tool,         # Reads provider's current status
        ping_provider_tool,                 # Sends urgent ping notification
        update_booking_status_tool,         # Writes status changes
        hand_off_to_guardian_tool,          # Triggers GuardianAgent with full context
        offer_alternatives_tool,            # Re-queries for backup providers
    ]
    
    instruction = """
    You are the executor. When the user confirms a booking, you make it real.
    Then you watch over it until the service is done.
    
    ACTING RULES:
    1. Always check the slot is still free before locking it. Race conditions are real.
    2. Send confirmations to BOTH user and provider. Both need to know.
    3. After booking, your job isn't done. You monitor until the service completes.
    4. If something goes wrong, don't hide it. Tell the user immediately and tell them 
       exactly what you're doing about it.
    5. Log every action you take with a timestamp. The Guardian will need this audit trail.
    
    AUTONOMY RULES:
    - You CAN silently retry a failed Firestore write (up to 3x).
    - You CAN give a provider a 15-minute grace period before declaring no-show.
    - You CAN re-ping a provider once before escalating.
    - You CANNOT rebook a provider without telling the user.
    - You CANNOT close a booking as "completed" without user confirmation.
    - You CANNOT take any money-related action without the Guardian.
    
    NO-SHOW DECISION LOGIC:
    If provider has not marked en_route 30 minutes after scheduled time:
      → Check their last app activity (are they even online?)
      → Send one ping notification: "Ali, aap G-13 ke liye nikle hain?"
      → Wait 10 minutes
      → If still no response: notify user, offer alternatives, call Guardian
      → If response: update user with new ETA
    """
```

### Key Tool: `check_slot_atomically_tool`

```python
# This is critical for preventing double bookings.
# Uses Firestore transaction:
@firestore.transactional
def lock_slot(transaction, provider_ref, slot_datetime):
    provider = provider_ref.get(transaction=transaction)
    
    # Check if slot is still in available_slots
    if slot_datetime not in provider.get("available_slots", []):
        raise SlotTakenException("Slot no longer available")
    
    # Remove slot + add travel buffers to adjacent slots
    available = provider["available_slots"]
    available.remove(slot_datetime)
    # Also block: slot - 30min and slot + job_duration + 30min
    
    transaction.update(provider_ref, {"availability_slots": available})
    return True
```

### Flutter Integration

```
After user taps "Confirm Booking":
  POST /api/v1/agent/execute
  → BookingConfirmed screen shows animated actions log:
    "✅ Slot locked"
    "✅ Ali AC Services notified" 
    "✅ You'll get a reminder tomorrow at 9 AM"
    "✅ Booking ID: BK-0042"

Provider app (ProviderEnRoute screen):
  "Start Job" button → POST /api/v1/agent/execute/status-update
    body: { booking_id, status: "en_route" }
  → Executor receives, notifies user, updates LiveTracking

BookingDetail screen:
  Firestore real-time listener on bookings/{id}
  Status badge updates live as Executor changes it

Push notifications (all sent by Executor):
  T-24h: "Kal Ali AC Services aayenge subah 9 baje — ghar par rahein"
  T-1h: "Ali 1 ghante mein pohunch rahe hain"
  en_route: "Ali raste mein hain — 18 minute mein pohunchenge"
  no_show: "Ali abhi tak nahi aaye — hum check kar rahe hain"
```

---

## AGENT 3 — THE GUARDIAN

**File:** `backend/agents/guardian_agent.py`

### What This Agent Is Actually Trying To Do

The service is done (or something went wrong). The Guardian's job is to make sure the user got what they paid for — and if they didn't, to make it right. It also makes the system smarter for next time by updating provider reputations based on real evidence, not just star ratings.

The Guardian is also the safety net: the Executor calls the Guardian whenever something is outside its authority (no-shows, cancellations, quality disputes). The Guardian has more power — it can penalize providers, apply credits, escalate to a human admin.

### The Reasoning Loop

**THINK (on service completion):**
"Service is marked complete. What do I actually know about how it went?
- Provider marked it complete at 11:47 AM (job was scheduled 9 AM — 2h47m for a standard repair, that's long)
- User hasn't been asked for feedback yet
- I need to collect feedback — but not aggressively. User might be busy."

**ACT:** Send a gentle feedback request. Wait.

**OBSERVE:** User gave 2 stars and wrote "late aaye aur kaam bhi adhoora chora" (arrived late and left work incomplete).

**THINK:** This is a legitimate complaint. What do I know about this provider?
- Ali: 4.8★ aggregate, but this is the 3rd complaint in 10 days about incomplete work
- The pattern is real. This isn't a one-off bad mood from a customer.
- The user deserves a partial refund. How much? The job was incomplete — a 40% refund is fair.
- Ali needs a formal warning. If one more complaint in 30 days → temporary suspension.

**ACT:** Apply 40% refund credit. Warn provider. Update reputation with recency weighting. Show user the resolution clearly.

**PAUSE FOR HUMAN:** The user might still want to escalate. The agent offers: "Agar aap chahein to hum yeh mamla hamare review team ko bhej sakte hain." If user says yes → create ticket → real human reviews.

If the refund exceeds PKR 2,000 → Guardian doesn't decide alone. Creates escalation ticket, freezes the amount, notifies admin, tells user it's under review.

### What The Guardian Can Decide Alone

- Partial refunds under PKR 2,000
- Provider warnings (logged, not public-facing yet)
- Reputation score recalculation (using evidence, not just stars)
- Auto-rebook with next provider after no-show
- Blacklisting from search results (internal flag, not permanent ban)

### What Always Requires Human (admin) in the Loop

- Refunds over PKR 2,000
- Permanent provider bans
- User account actions (suspension, fraud flag)
- Cases where both user and provider are disputing conflicting facts

### Guardian Decision Tree (this is actual reasoning, not a fixed flowchart)

```python
# The Guardian uses this reasoning system to decide what to do

GUARDIAN_SYSTEM_PROMPT = """
You are the Guardian agent. Your job is to ensure fairness for both users and providers.

When a dispute is raised, reason through it like this:

1. GATHER EVIDENCE FIRST
   - What does the booking record say? (original quote, scheduled time, service type)
   - What does the provider's history show? (past disputes, cancellation rate, on-time score)
   - Has the user disputed before? (some users dispute every booking — note this)
   - Is there a pattern (provider)? (first complaint vs 5th in 30 days is very different)

2. CLASSIFY THE SITUATION
   NO-SHOW:
     - Did provider give advance notice? (> 2hr = less severe, < 2hr = severe)
     - Is this their first no-show or a pattern?
     - How much did this disrupt the user? (emergency vs flexible)
   
   QUALITY COMPLAINT:
     - Is the complaint specific or vague?
     - Does the evidence (photos/description) match the service type?
     - Did the provider actually come? (no-show disguised as quality complaint?)
   
   PRICE DISPUTE:
     - Pull the exact original quote from Firestore (immutable)
     - Compare to what user says they were charged
     - If mismatch > 10% → almost certainly an overcharge, act on it
   
   CANCELLATION:
     - When did they cancel relative to the appointment?
     - Did the user suffer real consequences (took day off, had emergency)?

3. DECIDE THE RESOLUTION
   Apply this fairness principle: 
   "Would a reasonable, senior operations manager at a good company make this call?"
   
   Partial refund formula:
   - Provider no-show: 100% refund + PKR 100 inconvenience credit
   - Provider cancelled < 2hr: 100% refund + PKR 50 credit
   - Quality complaint (evidence supports): 30-50% refund based on severity
   - Price overcharge: exact overcharge amount refunded + PKR 50 apology credit
   
   Provider action formula:
   - 1st offense: logged warning (not visible to user)
   - 2nd offense same type in 30 days: ranking penalty (-0.15 composite score for 30 days)
   - 3rd offense or severe (fraud, dangerous behavior): flag for human review + hide from search
   
4. COMMUNICATE CLEARLY
   Tell the user:
   - What you found
   - What decision you made
   - Why
   - What happens next
   In their language. In plain words. No jargon.

ESCALATE TO HUMAN when:
   - You cannot determine who is right from available evidence
   - The refund amount exceeds PKR 2,000
   - The user explicitly says "yeh nahi chalta, manager se baat karni hai"
   - Provider claims the user is lying and has counter-evidence
"""
```

### ADK Implementation

```python
# backend/agents/guardian_agent.py

class GuardianAgent(Agent):
    name = "GuardianAgent"
    
    tools = [
        get_booking_audit_trail_tool,    # Full immutable booking history from Firestore
        get_provider_dispute_history_tool,  # All past disputes for this provider
        get_user_dispute_history_tool,   # Has this user disputed before? Pattern?
        analyze_complaint_evidence_tool,  # Gemini: reads photos + description, assesses validity
        compute_refund_amount_tool,      # Formula-based, with Guardian reasoning override
        apply_user_credit_tool,          # Writes to user wallet in Firestore
        issue_provider_warning_tool,     # Writes formal warning to provider record
        update_provider_reputation_tool,  # Recalculates ranking scores with recency weight
        create_human_escalation_ticket_tool,  # Creates ticket for human admin review
        notify_user_resolution_tool,     # Sends clear resolution message in user's language
        close_dispute_tool,              # Marks dispute resolved in Firestore
        temporarily_hide_provider_tool,  # Removes from search results (not a ban)
    ]
    
    instruction = GUARDIAN_SYSTEM_PROMPT  # (above)
```

### Triggered By

```
1. ExecutorAgent hands off (no-show, provider cancellation)
2. User taps "Dispute" on BookingDetail screen
3. User gives feedback rating ≤ 2 stars (FeedbackScreen smart routing)
4. FollowUpAgent detects no feedback received 48h after job completion
```

### Flutter Integration

```
DisputeScreen:
  User fills: dispute type + description + optional photos
  POST /api/v1/agent/dispute
  → Guardian starts reasoning (visible in AgentTracePanel)
  → While reasoning: show "Hum aap ka mamla dekh rahe hain..." with trace steps
  → Navigate to DisputeResolution screen with Guardian's decision

DisputeResolution screen:
  Shows Guardian's reasoning (what it found, what it decided, why)
  Shows resolution (credit amount, provider action taken)
  "Accept" → close dispute
  "Escalate" → Guardian creates human ticket, tells user ETA

FeedbackScreen:
  Rating ≤ 2 → Guardian activated automatically:
    "Lagta hai kuch theek nahi raha. Kya hua? Hum madad kar sakte hain."
  Rating ≥ 4 → Guardian updates provider reputation (good signal), shows thank you
  Rating 3 → Guardian asks one follow-up: "Kya koi cheez better ho sakti thi?"
```

---

## FULL WORKFLOW (end-to-end as one story)

This is what the judges want to see. One request, handled start to finish by agents reasoning and acting.

```
1. USER: "AC bilkul kaam nahi kar raha, kal subah G-13 mein technician chahiye, 
          budget zyada nahi hai"

2. COORDINATOR thinks:
   - Roman Urdu, urgency HIGH ("bilkul" intensifier), tomorrow morning, budget sensitive
   - Missing: G-13 sub-sector (G-13/1 through /4)
   - Confidence: 0.68 → one question needed
   
3. COORDINATOR asks:
   "G-13 ka kaunsa sector? (1, 2, 3, ya 4?)"
   [USER: "G-13/2"]
   Confidence: 0.95 ✓

4. COORDINATOR acts:
   - Searches 7 AC technicians in G-13 radius
   - Reads recent review texts (not just scores)
   - Finds: Ali (4.8★, but 3 recent "late" complaints), 
            Hassan (4.5★, cheaper, closer, no inverter reviews),
            Tariq (4.7★, inverter specialist, PKR 300 more)
   - Reasons: Hassan is risky for inverter AC. Tariq is safest match. Ali has concerning pattern.
   - Decision: recommend Tariq (best fit), show Hassan (budget option), warn about Ali

5. USER sees:
   "🥇 Tariq AC Services — PKR 950 — Inverter AC specialist ✓
    AI ki rai: Aap ke inverter AC ke liye Tariq best match hain — 
    11 saal ka tajruba aur 94% waqt per aate hain.
    
    💰 Budget option: Hassan AC Repairs — PKR 680
    ⚠️ Note: Hassan ke recent reviews mein inverter AC ka zikr nahi — risk ho sakta hai"

6. USER picks Tariq, selects 9 AM slot

7. COORDINATOR generates quote:
   Base: PKR 700 + Distance (1.8km × 50 = PKR 90) + Urgency: 0 (not today) = PKR 790
   Shows breakdown, user confirms

8. EXECUTOR takes over:
   - Checks slot atomically (still free ✓)
   - Locks slot in Firestore
   - Sends push to user: "✅ Booking confirmed! Tariq kal subah 9 baje aayenge"
   - Sends push to Tariq: "📋 Naya kaam: AC repair, G-13/2, kal 9 AM"
   - Schedules: T-24h reminder, T-1h reminder, T+30min no-show check

9. [Next day, 8 AM] EXECUTOR fires T-1h reminder:
   User: "Tariq 1 ghante mein pohunch rahe hain — ghar par rahein"
   Tariq: "1 ghante mein G-13/2 job hai — nikalne ka waqt ho gaya"

10. [9:15 AM] EXECUTOR observes: Tariq not marked en-route
    - Pings Tariq: "Tariq bhai, aap raste mein hain?"
    - Tariq responds: marks en-route
    - EXECUTOR notifies user: "Tariq raste mein hain — 22 minute mein pohunchenge"

11. [10:47 AM] Tariq marks job complete

12. GUARDIAN activates:
    - Sends feedback request: "Kaam kaisa raha? Tariq ko rate karein (1-5)"
    - USER gives 4★ + "Thoda late aye lekin kaam acha kiya"
    - GUARDIAN reasons: legitimate 4-star feedback, slight latency issue
    - Updates Tariq's on-time score (slight dip), overall rating stays good
    - No action needed. Closes booking. Updates user loyalty (1 more job = closer to Gold tier)

13. WORKFLOW COMPLETE ✓
    Full trace logged in Firestore. Every agent decision recorded.

--- ALTERNATE: SOMETHING GOES WRONG ---

10b. [9:45 AM] Tariq never responds to ping. 45 min after scheduled time.
     EXECUTOR declares likely no-show.
     EXECUTOR → GUARDIAN (handoff with full context)
     EXECUTOR → USER: "Tariq abhi tak nahi aaye aur reply bhi nahi kar rahe. 
                       Hum alternatives dhundh rahe hain — 2 minute mein update milega"

     GUARDIAN reasons:
     - Tariq's first no-show. Cancellation rate was 0.02 — unusual.
     - User has an urgent AC problem (it was hot enough to contact us yesterday).
     - Next best provider: Hassan (available 11 AM). User is budget sensitive so cheaper Hassan works here.
     - Issue: Hassan has no inverter experience. Is this still the right call?
     - Decision: Tell the user honestly. Let them decide: wait for Tariq explanation, or take Hassan.
     
     GUARDIAN → USER:
     "Tariq se contact nahi ho pa raha. 
      Option 1: Hassan AC Repairs 11 AM — PKR 680 (sasta, lekin inverter ka kam tajruba)
      Option 2: Kal subah Tariq ka doosra slot (agar woh available ho) 
      Aap kya chahte hain?"
     
     [USER picks Option 1]
     
     GUARDIAN → EXECUTOR: rebook with Hassan at 11 AM
     GUARDIAN: Tariq gets warning logged, cancellation_rate updated
     GUARDIAN → USER: "Hassan ka 11 AM slot confirm ho gaya. 
                        Tariq wali booking ka pura refund + PKR 100 credit aap ke account mein"
```

---

## HUMAN-IN-LOOP SUMMARY

This table tells Antigravity exactly where to pause and wait for the human, and where to act autonomously.

| Decision | Agent | Human Needed? | Why |
|---|---|---|---|
| Which clarifying question to ask | Coordinator | ❌ No | Agent chooses most important missing field |
| Whether to expand search radius | Coordinator | ❌ No | Silent quality safeguard |
| Which provider to recommend | Coordinator | ❌ No | Agent's job |
| Whether to show a provider warning | Coordinator | ❌ No | Agent decides based on review analysis |
| Final provider selection | Coordinator → User | ✅ YES | User's money, user's choice |
| Price confirmation | Coordinator → User | ✅ YES | Transparency before commitment |
| Slot lock (race condition) | Executor | ❌ No | Technical operation |
| Sending confirmations | Executor | ❌ No | Automatic after user confirms |
| Retry failed Firestore write | Executor | ❌ No | Technical retry |
| 15-min grace before no-show | Executor | ❌ No | Judgment call within authority |
| Pinging provider | Executor | ❌ No | Autonomous monitoring |
| Notifying user of no-show | Executor | ✅ YES (notify) | User must be told immediately |
| Offering alternatives after no-show | Executor → User | ✅ YES | User chooses next step |
| Partial refund < PKR 2,000 | Guardian | ❌ No | Within agent's authority |
| Provider warning | Guardian | ❌ No | Within agent's authority |
| Reputation score update | Guardian | ❌ No | Data operation |
| Partial refund > PKR 2,000 | Guardian | ✅ YES (human admin) | Exceeds agent authority |
| Permanent provider ban | Guardian | ✅ YES (human admin) | Irreversible action |
| Disputed facts (he said / she said) | Guardian | ✅ YES (human admin) | Cannot determine truth alone |

---

## DEMO STRESS TESTS (Reasoning on display)

For each scenario below, the agent's reasoning should be visible in the AgentTracePanel. Judges must see the agent *thinking*, not just doing.

### Stress Test 1: No Provider Available
```
Input: "Electrician chahiye G-6 mein aaj raat 10 baje"
Coordinator reasons:
- 10 PM is very late. Most providers end at 8 PM.
- Searched 12 km radius. Zero availability for tonight.
- Should I lie and say "checking..."? No. Be honest.
- What CAN I offer? Tomorrow morning 8 AM (3 electricians available).
- Is there an emergency option? Check if any providers offer 24/7 — found 1 (higher rate).

Shows user:
"Aaj raat 10 baje koi electrician available nahi hai. 
 Options:
 1. Kal subah 8 AM — 3 electricians available (normal rate)
 2. Aaj raat emergency service — Ali Emergency (higher cost: PKR 1,200)"
```

### Stress Test 2: Provider Cancels After Confirmation
```
[6 AM day of booking] Provider sends cancellation
Executor detects: booking status change to "provider_cancelled"
Executor reasons:
- 3 hours before a 9 AM job. User might already be arranging their day.
- This needs to be surfaced immediately. Push notification now.
- Do I have alternatives ready? Check what's available this morning.
- Find 2 alternatives, prepare options before notifying user (don't send problem without solution)

Executor notifies user:
"Tariq ne kal booking cancel kar di. Maafi chahte hain!
 Hum ne already doosre options dhundhe hain:
 ✓ Hassan AC Repairs — aaj 10 AM available (PKR 720)  
 ✓ Khalid Technicians — aaj 11 AM available (PKR 850)
 Aap kya chahte hain?"

Guardian logs: Tariq's cancellation_rate updated. Warning issued.
```

### Stress Test 3: Ambiguous Input
```
Input: "kuch theek karo"
Coordinator reasons:
- This is 2 words. No service type. No location. No time.
- Confidence: 0.12
- Don't ask 5 questions. Ask the one that unlocks everything else: service type.
- Keep it friendly — user might be frustrated.

Response: "Bilkul! Kaunsi cheez theek karni hai? 
           [AC/Cooling] [Plumbing/Pani] [Bijli] [Tutoring] [Kuch Aur]"
           (tappable chips)
```

### Stress Test 4: Two Users, Same Provider, Same Time
```
User A confirms Tariq at 10 AM → Executor locks slot (transaction T1)
User B confirms Tariq at 10 AM simultaneously → Executor tries lock (transaction T2)
Transaction T2 fails (slot already taken)

Executor for User B reasons:
- Slot is gone. Don't show an error page. Show a solution.
- What's next best? Hassan at 10 AM (0.85 composite vs Tariq's 0.87 — very close)
- Or: Tariq at 12 PM (his next slot)
- Tell User B immediately.

Response to User B:
"Tariq ki 10 AM slot abhi abhi book ho gayi. 
 Aap ke liye yeh options hain:
 ✓ Hassan AC Repairs — 10 AM, PKR 680 (almost same rating)
 ✓ Tariq hi chahiye? 12 PM available hain"
```

### Stress Test 5: Price Dispute After Service
```
User gives 1★: "Quote 790 tha, unhone 1,200 liye"

Guardian activates. Reasoning:
- Pull original quote from Firestore: PKR 790. Immutable. Timestamped.
- User claims: PKR 1,200.
- Difference: PKR 410.
- Provider's history: first price dispute. Rating otherwise good (4.5★).
- What are the scenarios?
  a) Provider added work that was genuinely extra
  b) Provider overcharged deliberately
  c) User misremembered
- The quote is clear: PKR 790. If extra work was done, provider should have asked for approval first.
- Standard policy: overcharge → full refund of difference + PKR 50 credit.

Guardian action:
- Applies PKR 460 credit (difference + apology)
- Issues provider warning: "Extra charges require user approval before proceeding"
- Tells user clearly what was done and why

Guardian response:
"Original quote PKR 790 tha. PKR 410 extra charge ke baare mein hum ne check kiya.
 Provider ne pehle aap se approval nahi li — yeh galat tha.
 PKR 460 aap ke account mein credit ho gaya.
 Hassan ko warning bhi di gayi hai."
```

---

## IMPLEMENTATION NOTES FOR ANTIGRAVITY

### Files to Create

```
backend/agents/
├── coordinator_agent.py    ← Agent 1 (replaces IntentAgent + MatchingAgent + PricingAgent)
├── executor_agent.py       ← Agent 2 (replaces BookingAgent + FollowUpAgent)
├── guardian_agent.py       ← Agent 3 (replaces DisputeAgent)
└── shared/
    ├── tools.py            ← All tool definitions
    ├── prompts.py          ← All system prompts
    └── state.py            ← Shared state models between agents
```

### FastAPI Endpoints (3, not 6)

```
POST /api/v1/agent/coordinate     ← Coordinator: from user message to confirmed booking
POST /api/v1/agent/execute        ← Executor: booking actions + status updates
POST /api/v1/agent/resolve        ← Guardian: disputes, feedback, post-service

WS   /ws/agent-stream             ← Real-time reasoning trace to Flutter
```

### Agent Handoff Protocol

```python
# When one agent hands to another, it passes full context:
class AgentHandoff:
    from_agent: str
    to_agent: str
    reason: str           # "no-show confirmed" / "user confirmed booking" / etc.
    booking_id: str
    full_context: dict    # Everything the next agent needs — no re-querying
    urgency: str          # "normal" | "urgent" | "emergency"
    user_message: str     # What to tell the user right now
```

### Reasoning Trace (what Flutter AgentTracePanel shows)

Every agent emits trace events that describe its THINKING, not just its actions:

```json
{ "agent": "CoordinatorAgent", "type": "thinking", 
  "text": "Ali has 4.8★ but 3 recent late complaints — re-ranking..." }

{ "agent": "CoordinatorAgent", "type": "decision", 
  "text": "Recommending Tariq over closer Ali due to review pattern" }

{ "agent": "ExecutorAgent", "type": "action", 
  "text": "Slot locked ✓" }

{ "agent": "ExecutorAgent", "type": "observation", 
  "text": "Provider not en-route 30min after slot — initiating ping" }

{ "agent": "GuardianAgent", "type": "thinking", 
  "text": "Checking if this is Tariq's first no-show or a pattern..." }

{ "agent": "GuardianAgent", "type": "decision", 
  "text": "First offense — warning issued. Refund + PKR 100 credit applied." }
```

This is what makes the demo memorable: judges see the AI's thought process, not just outputs.

---

*This is what agentic means: the agents reason, act, observe outcomes, make judgment calls, know their limits, and keep humans in the loop at exactly the right moments — not at every step (that's just a form), and not at no steps (that's a black box).*

*Stack: Flutter · FastAPI · Google ADK · Gemini 1.5 Flash · Firebase*
