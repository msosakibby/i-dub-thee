#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TDD PHASE: QUARANTINE AUTOPSY ENGINE (RED STATE)"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring TDD Fixtures (tests/test_quarantine_autopsy.py)..."
cat << 'EOF_TEST' > tests/test_quarantine_autopsy.py
import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock, call

# Attempt to import the future reporting engine
try:
    from tools.quarantine_autopsy import isolate_json_fractures, generate_autopsy_markdown
except ImportError:
    isolate_json_fractures = None
    generate_autopsy_markdown = None

from src.main import process_document

INVALID_MOCK_JSON_ALPHA = '{"document_type": "utility_bill", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-docs/input/bill.pdf", "extracted_data": {"total_amount": 150.00}}'
INVALID_MOCK_JSON_BETA = '{"document_type": "utility_bill", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-docs/input/bill.pdf", "extracted_data": {"total_amount": 150.80}}' # Notice the 80 cent discrepancy

@pytest.mark.asyncio
@patch('src.main.storage')
@patch('src.main.bigquery')
async def test_quarantine_ledger_vaulting(mock_bq, mock_storage):
    """VECTOR 1: Proves fractured data is vaulted into the quarantine_ledger, not erased."""
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model
        
        # Force a Consensus Fracture by feeding mismatched JSONs
        mock_model.generate_content_async.side_effect = [
            MagicMock(text=INVALID_MOCK_JSON_ALPHA),
            MagicMock(text=INVALID_MOCK_JSON_BETA)
        ]
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-docs", "name": "input/bill.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
            
    # THE IRON GATE ASSERTION
    bq_client_mock = mock_bq.Client()
    try:
        # We must verify BigQuery was called to insert the broken data
        bq_client_mock.insert_rows_json.assert_called()
        
        # Extract the arguments passed to the BQ insert call
        insert_calls = bq_client_mock.insert_rows_json.call_args_list
        found_quarantine_insert = False
        for c in insert_calls:
            if "quarantine_ledger" in str(c):
                found_quarantine_insert = True
                break
        assert found_quarantine_insert, "FATAL: Data evaporated. BigQuery did not vault the fractured payload into the quarantine_ledger."
    except AssertionError as e:
        pytest.fail(str(e))

def test_deterministic_diff_engine():
    """VECTOR 2: Proves the engine can mathematically isolate the exact disputed fields."""
    if isolate_json_fractures is None:
        pytest.fail("FATAL: isolate_json_fractures function does not exist.")
        
    alpha_dict = {"total": 150.00, "date": "2014-10-10", "vendor": "Great Lakes Energy"}
    beta_dict = {"total": 150.80, "date": "2014-10-10", "vendor": "Great Lakes Energy"}
    
    fractures = isolate_json_fractures(alpha_dict, beta_dict)
    
    assert "total" in fractures, "FATAL: Failed to isolate the fractured 'total' key."
    assert "date" not in fractures, "FATAL: Falsely flagged 'date' as a fracture."

def test_autopsy_markdown_generation():
    """VECTOR 3: Proves the Daubert-admissible Markdown string is correctly formatted."""
    if generate_autopsy_markdown is None:
        pytest.fail("FATAL: generate_autopsy_markdown function does not exist.")
        
    mock_bq_rows = [
        MagicMock(
            document_id="bill.pdf",
            quarantine_timestamp="2026-02-26 12:00:00 UTC",
            gcs_source_uri="gs://i-dub-thee-quarantine/bill.pdf",
            fracture_reason="Semantic mismatch between Alpha and Beta extractions.",
            alpha_payload='{"total": 150.0}',
            beta_payload='{"total": 150.8}'
        )
    ]
    
    report = generate_autopsy_markdown(mock_bq_rows)
    
    assert "## QUARANTINE AUTOPSY REPORT" in report, "FATAL: Missing report header."
    assert "bill.pdf" in report, "FATAL: Missing Document ID."
    assert "150.0" in report and "150.8" in report, "FATAL: Missing isolated conflicting values."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting Massive Failure/Red State)..."
python3 -m pytest tests/test_quarantine_autopsy.py -v || true

echo "============================================================================"
echo " [WAITING FOR RED STATE TELEMETRY]"
echo "============================================================================"
