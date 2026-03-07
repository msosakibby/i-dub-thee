#!/bin/bash
set -e

echo "============================================================================"
echo " INITIATING TEST PATCH: ALIGNING AUTOPSY MARKDOWN ASSERTIONS"
echo "============================================================================"

echo "[SYSTEM] 1. Patching tests/test_quarantine_autopsy.py..."
cat << 'EOF_TEST' > tests/test_quarantine_autopsy.py
import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock, call

try:
    from tools.quarantine_autopsy import isolate_json_fractures, generate_autopsy_markdown
except ImportError:
    isolate_json_fractures = None
    generate_autopsy_markdown = None

from src.main import process_document

INVALID_MOCK_JSON_ALPHA = '{"document_type": "utility_bill", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-docs/input/bill.pdf", "extracted_data": {"total_amount": 150.00}}'
INVALID_MOCK_JSON_BETA = '{"document_type": "utility_bill", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-docs/input/bill.pdf", "extracted_data": {"total_amount": 150.80}}'

@pytest.mark.asyncio
@patch('src.main.storage')
@patch('src.main.bigquery')
async def test_quarantine_ledger_vaulting(mock_bq, mock_storage):
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model
        mock_model.generate_content_async.side_effect = [
            MagicMock(text=INVALID_MOCK_JSON_ALPHA), MagicMock(text=INVALID_MOCK_JSON_BETA)
        ]
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-docs", "name": "input/bill.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
            
    bq_client_mock = mock_bq.Client()
    try:
        bq_client_mock.insert_rows_json.assert_called()
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
    if isolate_json_fractures is None:
        pytest.fail("FATAL: isolate_json_fractures function does not exist.")
    alpha_dict = {"total": 150.00, "date": "2014-10-10", "vendor": "Great Lakes Energy"}
    beta_dict = {"total": 150.80, "date": "2014-10-10", "vendor": "Great Lakes Energy"}
    fractures = isolate_json_fractures(alpha_dict, beta_dict)
    assert "total" in fractures, "FATAL: Failed to isolate the fractured 'total' key."

def test_autopsy_markdown_generation():
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
    
    # EXACT MATCH ALIGNMENT
    assert "# QUARANTINE AUTOPSY REPORT" in report, "FATAL: Missing H1 report header."
    assert "bill.pdf" in report, "FATAL: Missing Document ID."
    assert "150.0" in report and "150.8" in report, "FATAL: Missing isolated conflicting values."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_quarantine_autopsy.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
