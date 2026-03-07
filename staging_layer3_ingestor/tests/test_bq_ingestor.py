import pytest
import json
from unittest.mock import MagicMock, patch

# ==============================================================================
# IMPORT STUBS FOR FUTURE IMPLEMENTATION
# These will fail until Layer 3 main.py is engineered to satisfy them.
# ==============================================================================
try:
    from main import parse_taxonomy_vector, build_bq_row, check_hash_exists
except ImportError:
    parse_taxonomy_vector = None
    build_bq_row = None
    check_hash_exists = None

# ==============================================================================
# L3-1: TAXONOMY VECTOR ALGEBRA
# ==============================================================================
def test_taxonomy_vector_algebra():
    """Validates the exact fracturing of the taxonomy vector into schema columns."""
    if parse_taxonomy_vector is None:
        pytest.skip("Implementation missing")
    
    vector = "LANE_04_BANKING / Judith Grandy / Chemical Bank / Bank Statement"
    
    parsed = parse_taxonomy_vector(vector)
    
    assert parsed["taxonomy_lane"] == "LANE_04_BANKING"
    assert parsed["entity_slug"] == "Judith Grandy"
    assert parsed["institution"] == "Chemical Bank"
    assert parsed["document_type"] == "Bank Statement"

    # Test malformed vector fallback survival
    malformed = parse_taxonomy_vector("LANE_99_UNKNOWN / JustOne")
    assert malformed["taxonomy_lane"] == "LANE_99_UNKNOWN"
    assert malformed["entity_slug"] == "JustOne"
    assert malformed["document_type"] == "UNKNOWN"

# ==============================================================================
# L3-2: BIGQUERY PAYLOAD TRANSFORMATION
# ==============================================================================
def test_payload_transformation():
    """Validates the Layer 2B JSON perfectly maps to the forensic_fact_base schema."""
    if build_bq_row is None:
        pytest.skip("Implementation missing")
    
    # Mock Layer 2B output payload
    l2b_output = {
        "dossier_metadata": {
            "cryptographic_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "source_artifact_uri": "gs://i-dub-thee-processed/LANE_04/file.pdf",
            "taxonomy_vector": "LANE_04_BANKING / Judith Grandy / Bank / Statement"
        },
        "extracted_facts": [
            {"key_name": "Closing Balance", "exact_value": "12500.00", "document_citation": "Page 1"}
        ]
    }
    
    bq_row = build_bq_row(l2b_output)
    
    # Must match your exact BigQuery Schema definition
    assert bq_row["parent_file_hash"] == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    assert bq_row["gcs_source_uri"] == "gs://i-dub-thee-processed/LANE_04/file.pdf"
    assert bq_row["taxonomy_lane"] == "LANE_04_BANKING"
    assert bq_row["entity_slug"] == "Judith Grandy"
    assert bq_row["document_type"] == "Statement"
    assert bq_row["confidence_score"] == 0.99  # Deterministic default for L2B success
    assert bq_row["requires_manual_review"] is False
    
    # Payload must be a serialized JSON string for BigQuery JSON column ingestion
    assert isinstance(bq_row["extracted_payload"], str)
    assert "Closing Balance" in bq_row["extracted_payload"]

# ==============================================================================
# L3-3: THE IDEMPOTENCY GATE
# ==============================================================================
def test_idempotency_gate():
    """Proves the system intercepts duplicate hashes and blocks ingestion."""
    if check_hash_exists is None:
        pytest.skip("Implementation missing")
    
    mock_bq_client = MagicMock()
    
    # Simulate the query returning 1 row (Hash already exists)
    mock_query_job = MagicMock()
    mock_query_job.result.return_value = [("e3b0c442...")] 
    mock_bq_client.query.return_value = mock_query_job
    
    exists = check_hash_exists(mock_bq_client, "dummy_project", "e3b0c442...")
    assert exists is True
    
    # Simulate the query returning 0 rows (Hash is novel)
    mock_query_job.result.return_value = []
    exists_novel = check_hash_exists(mock_bq_client, "dummy_project", "novel_hash...")
    assert exists_novel is False

