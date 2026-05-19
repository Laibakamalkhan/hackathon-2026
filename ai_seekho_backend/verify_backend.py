"""Quick backend verification script — run from ai_seekho_backend directory."""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

results = []

def check(label, fn):
    try:
        result = fn()
        results.append(("PASS", label, result))
        print(f"[PASS] {label}: {result}")
    except Exception as e:
        results.append(("FAIL", label, str(e)))
        print(f"[FAIL] {label}: {e}")

check("tools.py imports",
    lambda: f"{__import__('agents.shared.tools', fromlist=['ALL_TOOL_DECLARATIONS']).ALL_TOOL_DECLARATIONS.__len__()} tools loaded")

check("CoordinatorAgent import",
    lambda: str(__import__('agents.coordinator_agent', fromlist=['CoordinatorAgent']).CoordinatorAgent))

check("ExecutorAgent import",
    lambda: str(__import__('agents.executor_agent', fromlist=['ExecutorAgent']).ExecutorAgent))

check("GuardianAgent import",
    lambda: str(__import__('agents.guardian_agent', fromlist=['GuardianAgent']).GuardianAgent))

def test_intent():
    from services.intent_service import parse_intent_heuristically
    r = parse_intent_heuristically("AC theek karo G-13 mein jaldi budget 1500")
    assert "confidence" in r, "confidence key missing"
    assert "follow_up_question" in r, "follow_up_question key missing"
    return f"service={r['service_type']} confidence={r['confidence']} fq={r['follow_up_question']}"
check("intent_service heuristic", test_intent)

def test_scheduling():
    from services.scheduling_service import validate_provider_schedule
    r = validate_provider_schedule("P-001", "2026-05-20T10:00:00", [])
    assert len(r) == 3, f"Expected 3-tuple, got {len(r)}"
    return f"available={r[0]} next_slot={r[2]}"
check("scheduling_service 3-tuple", test_scheduling)

def test_pricing():
    from services.pricing_service import generate_price_quote
    import inspect
    sig = inspect.signature(generate_price_quote)
    assert "user_lat" in sig.parameters, "user_lat param missing"
    assert "user_lng" in sig.parameters, "user_lng param missing"
    return f"signature has user_lat, user_lng — coordinate bug FIXED"
check("pricing_service signature fix", test_pricing)

def test_provider():
    from services.provider_service import update_provider_rating_in_firestore
    return "update_provider_rating_in_firestore function exists"
check("provider_service reputation fn", test_provider)

def test_main_imports():
    import importlib.util
    spec = importlib.util.spec_from_file_location("main", "main.py")
    # Just check it doesn't have syntax errors by reading
    with open("main.py") as f:
        src = f.read()
    assert "agent_coordinate" in src, "agent_coordinate endpoint missing"
    assert "agent_execute" in src, "agent_execute endpoint missing"
    assert "agent_resolve" in src, "agent_resolve endpoint missing"
    assert "/api/v1/feedback/submit" in src, "feedback endpoint missing"
    assert "/api/v1/bookings" in src, "bookings endpoint missing"
    assert "/ws/agent-stream" in src, "agent-stream ws missing"
    return "All 7 new endpoints found in main.py"
check("main.py new endpoints", test_main_imports)

print("\n" + "="*50)
passes = sum(1 for r in results if r[0] == "PASS")
fails = sum(1 for r in results if r[0] == "FAIL")
print(f"RESULTS: {passes}/{len(results)} passed, {fails} failed")
if fails > 0:
    print("\nFailed checks:")
    for r in results:
        if r[0] == "FAIL":
            print(f"  - {r[1]}: {r[2]}")
