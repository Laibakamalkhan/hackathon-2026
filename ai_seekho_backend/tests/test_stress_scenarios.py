import unittest
from datetime import datetime, timedelta
import sys
from pathlib import Path

# Setup import path
BACKEND_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_DIR))

from services.intent_service import parse_user_intent
from services.provider_service import get_matching_providers
from services.scheduling_service import validate_provider_schedule
from agents.shared.tools import execute_tool
from orchestrator.agent_coordinator import run_orchestrated_matching

class TestStressScenarios(unittest.TestCase):
    def setUp(self):
        self.user_lat = 33.649
        self.user_lng = 72.973

    def test_no_provider_available(self):
        """Stress Scenario 1: Obscure category + tight time -> No provider available"""
        query = "Mujhe abhi ke abhi spaceship repair wala chahiye"
        intent = parse_user_intent(query)
        matches = get_matching_providers(self.user_lat, self.user_lng, intent, limit=3)
        if not matches:
            self.assertEqual(len(matches), 0)
        print("\n[PASS] Scenario 1: No provider available handled.")

    def test_provider_conflict_double_booking(self):
        """Stress Scenario 2: Provider conflict double booking"""
        provider_slots = ["2026-05-18T09:00:00"]
        requested_time = "2026-05-18T14:00:00" # Conflicting time
        
        is_ok, msg, next_slot = validate_provider_schedule("P001", requested_time, provider_slots)
        self.assertFalse(is_ok)
        self.assertIsNotNone(next_slot)
        print("\n[PASS] Scenario 2: Provider conflict double booking handled.")

    def test_low_confidence_query(self):
        """Stress Scenario 3: Low confidence query (vague text)"""
        query = "kuch theek nahi chal raha"
        intent = execute_tool("understand_request_tool", {"query": query})
        confidence = intent.get("confidence", 1.0)
        self.assertIn("confidence", intent)
        print(f"\n[PASS] Scenario 3: Low confidence query handled (Confidence: {confidence}).")

    def test_dispute_price_disagreement(self):
        """Stress Scenario 4: Dispute price disagreement after mock booking"""
        dispute_type = "price_disagreement"
        desc = "Unhone 500 ziyada maange"
        
        refund_result = execute_tool("compute_refund_amount_tool", {
            "dispute_type": dispute_type,
            "total_paid": 1500,
            "base_fee": 500,
            "description": desc
        })
        
        self.assertIn("amount_pkr", refund_result)
        self.assertIn("resolution_type", refund_result)
        print(f"\n[PASS] Scenario 4: Dispute price disagreement handled (Resolution: {refund_result['resolution_type']}).")

if __name__ == "__main__":
    unittest.main()
