import pytest
import yaml
import json

# TDD STRICT ENFORCEMENT: We attempt to import the engine. 
# If it does not exist, we trap the ImportError and raise our Red Phase alert.
try:
    from src.forensic_evaluator import RulesEngine
except ImportError:
    class RulesEngine:
        def __init__(self, registry_path):
            raise NotImplementedError("TDD RED PHASE: src/forensic_evaluator.py has not been deployed yet.")
            
        def evaluate_payload(self, payload):
            pass

@pytest.fixture
def mock_bq_payload():
    """Simulates the flat, mathematically verified JSON from the Layer 1 BigQuery Ledger."""
    return {
        "dossier_id": "DSR-1A2B3C4D",
        "page_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "activity_line_01_description": "HOME DEPOT 4432",
        "activity_line_01_amount": "450.00",
        "activity_line_02_description": "WIRE TRANSFER FROM M & J Food Market",
        "activity_line_02_amount": "50000.00",
        "activity_line_03_description": "PAYROLL Kibby Company LLC",
        "activity_line_03_amount": "3200.00"
    }

def test_paragraph_compliance_isolation(mock_bq_payload):
    """
    MATHEMATICAL PROOF: The engine must ignore Home Depot, flag M & J Food Market, 
    and flag Kibby Company LLC based strictly on the YAML registry.
    """
    engine = RulesEngine(registry_path="tests/rules_registry.yaml")
    
    results = engine.evaluate_payload(mock_bq_payload)
    
    # We expect exactly 2 rule violations (M&J and Kibby LLC)
    assert len(results) == 2
    
    # Extract the rule IDs triggered
    triggered_rules = [res["rule_id"] for res in results]
    assert "PARAGRAPH_8F_M_AND_J" in triggered_rules
    assert "PARAGRAPH_6_KIBBY_LLC" in triggered_rules
    
    # Ensure Daubert-admissibility by verifying the raw evidence was attached to the outcome
    for res in results:
        if res["rule_id"] == "PARAGRAPH_8F_M_AND_J":
            assert "M & J Food Market" in res["matched_evidence_value"]

