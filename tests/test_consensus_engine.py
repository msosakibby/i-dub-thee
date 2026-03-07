import pytest
import copy
from tools.consensus_engine import evaluate_consensus, ConsensusFractureError

@pytest.fixture
def base_alpha_payload():
    return {
        "taxonomy_lane": "LANE_09_INFRASTRUCTURE_EQUIPMENT",
        "entity_identified": "Kibby Company LLC",
        "extracted_data": {"mock_value": 15000.00}
    }

def test_perfect_consensus(base_alpha_payload):
    """PROVES: When Alpha and Beta exactly match, Alpha's payload is passed to the Iron Gate."""
    beta_payload = copy.deepcopy(base_alpha_payload)
    
    result = evaluate_consensus(base_alpha_payload, beta_payload)
    assert result == base_alpha_payload, "FATAL: Consensus engine dropped a perfect match."

def test_adversarial_taxonomy_fracture(base_alpha_payload):
    """PROVES: If Beta's adversarial prompt classifies the expense as a hobby, the system violently halts."""
    beta_payload = copy.deepcopy(base_alpha_payload)
    beta_payload["taxonomy_lane"] = "LANE_17_SPORTING_RECREATION"
    
    with pytest.raises(ConsensusFractureError) as exc_info:
        evaluate_consensus(base_alpha_payload, beta_payload)
    
    assert "Taxonomy Mismatch" in str(exc_info.value), "FATAL: Engine failed to catch taxonomy hallucination."

def test_entity_commingling_fracture(base_alpha_payload):
    """PROVES: If the models disagree on who owns the transaction (Paragraph 8F), the system halts."""
    beta_payload = copy.deepcopy(base_alpha_payload)
    beta_payload["entity_identified"] = "M & J Food Market"
    
    with pytest.raises(ConsensusFractureError) as exc_info:
        evaluate_consensus(base_alpha_payload, beta_payload)
        
    assert "Entity Mismatch" in str(exc_info.value), "FATAL: Engine failed to catch entity commingling dispute."

def test_financial_hallucination_fracture(base_alpha_payload):
    """PROVES: If the models extract different monetary values, the system halts before Pydantic."""
    beta_payload = copy.deepcopy(base_alpha_payload)
    beta_payload["extracted_data"]["mock_value"] = 1500.00  # Beta missed a zero
    
    with pytest.raises(ConsensusFractureError) as exc_info:
        evaluate_consensus(base_alpha_payload, beta_payload)
        
    assert "Financial Data Mismatch" in str(exc_info.value), "FATAL: Engine allowed a financial hallucination."
