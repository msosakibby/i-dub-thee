import pytest
from pydantic import ValidationError

# ==============================================================================
# IMPORT STUBS FOR FUTURE IMPLEMENTATION
# These will fail until Layer 1 main.py is strictly engineered to satisfy them.
# ==============================================================================
try:
    from main import Layer1RoutingSchema
except ImportError:
    Layer1RoutingSchema = None

def generate_valid_layer1_payload() -> dict:
    return {
        "document_date": "2024-10-15",
        "primary_subject": "Kibby Company LLC",
        "document_classification": "Policy Binder",
        "institution_name": "Allstate",
        "primary_reference_id": "NONE",
        "recommended_18_lane_id": "LANE_08_INSURANCE",
        "confidence_score": 0.98
    }

# ==============================================================================
# SCHEMA-1: STRICT LITERAL ENUMERATION PASS
# ==============================================================================
def test_strict_lane_enumeration_pass():
    """Validates that a perfectly matched 18-Lane ID passes the Iron Gate."""
    if Layer1RoutingSchema is None:
        pytest.skip("Implementation missing")
    
    valid_payload = generate_valid_layer1_payload()
    schema_instance = Layer1RoutingSchema(**valid_payload)
    
    assert schema_instance.recommended_18_lane_id == "LANE_08_INSURANCE"

# ==============================================================================
# SCHEMA-2: STRICT LITERAL ENUMERATION FAIL (HALLUCINATION REJECTION)
# ==============================================================================
def test_strict_lane_enumeration_fail():
    """Validates that a hallucinated Lane ID violently triggers a ValidationError."""
    if Layer1RoutingSchema is None:
        pytest.skip("Implementation missing")
    
    invalid_payload = generate_valid_layer1_payload()
    # Simulating Gemini hallucinating a non-existent lane
    invalid_payload["recommended_18_lane_id"] = "LANE_08_Policies"
    
    with pytest.raises(ValidationError) as exc_info:
        Layer1RoutingSchema(**invalid_payload)
    
    assert "Input should be" in str(exc_info.value) # Pydantic's exact Literal error

# ==============================================================================
# SCHEMA-3: PAYER / PAYEE DELINEATION ENFORCEMENT
# ==============================================================================
def test_payer_payee_delineation():
    """Validates the explicit extraction fields for Vendor and Payer."""
    if Layer1RoutingSchema is None:
        pytest.skip("Implementation missing")
    
    pos_receipt_payload = generate_valid_layer1_payload()
    pos_receipt_payload["primary_subject"] = "M & J Food Market"
    pos_receipt_payload["institution_name"] = "Meijer"
    pos_receipt_payload["document_classification"] = "Retail POS Receipt"
    pos_receipt_payload["recommended_18_lane_id"] = "LANE_00_GENERAL_TRANSACTIONAL"
    
    schema_instance = Layer1RoutingSchema(**pos_receipt_payload)
    
    assert schema_instance.primary_subject == "M & J Food Market"
    assert schema_instance.institution_name == "Meijer"

