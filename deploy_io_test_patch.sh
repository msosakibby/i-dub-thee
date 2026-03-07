#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TEST PATCH: ALIGNING GCS MOCK ASSERTIONS"
echo "============================================================================"

echo "[SYSTEM] 1. Patching tests/test_layer1_io.py..."
cat << 'EOF_TEST' > tests/test_layer1_io.py
import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock, call
from src.main import process_document

VALID_MOCK_JSON = '{"document_type": "pos_retail_receipt", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-docs/receipt.pdf", "extracted_data": {"amount": 150.0}}'
INVALID_MOCK_JSON = '{"document_type": "pos_retail_receipt", "spatial_anchor_uri": "gs://i-dub-thee-docs/receipt.pdf", "extracted_data": {}}' # Missing confidence_score

@pytest.mark.asyncio
@patch('src.main.storage')
@patch('src.main.bigquery')
async def test_successful_io_routing(mock_bq, mock_storage):
    """VECTOR 1: Proves successful extraction writes to BQ and moves to 'processed' bucket."""
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model
        
        # Alpha and Beta both return valid, matching JSON
        mock_model.generate_content_async.side_effect = [
            MagicMock(text=VALID_MOCK_JSON),
            MagicMock(text=VALID_MOCK_JSON)
        ]
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-docs", "name": "receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
            
    # THE IRON GATE ASSERTIONS
    try:
        mock_bq.Client().insert_rows_json.assert_called_once()
    except AssertionError:
        pytest.fail("FATAL: BigQuery insertion logic is missing or bypassed.")
        
    try:
        client_mock = mock_storage.Client()
        # Verify the client requested the "processed" bucket
        assert call("i-dub-thee-processed") in client_mock.bucket.call_args_list, "FATAL: Did not route to processed bucket."
        
        # Ensure original file is deleted from intake
        bucket_mock = client_mock.bucket()
        blob_mock = bucket_mock.blob()
        blob_mock.delete.assert_called_once()
    except AssertionError as e:
        pytest.fail(f"FATAL: GCS move/delete logic is missing. Error: {e}")

@pytest.mark.asyncio
@patch('src.main.storage')
@patch('src.main.bigquery')
async def test_quarantine_io_routing(mock_bq, mock_storage):
    """VECTOR 2: Proves fractured extraction skips BQ and moves to 'quarantine' bucket."""
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model
        
        # Force a persistent Pydantic failure to trigger quarantine
        async def dynamic_healing_mock(prompt_data, *args, **kwargs):
            return MagicMock(text=INVALID_MOCK_JSON)
            
        mock_model.generate_content_async.side_effect = dynamic_healing_mock
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-docs", "name": "receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
            
    # THE IRON GATE ASSERTIONS
    mock_bq.Client().insert_rows_json.assert_not_called() # MUST NOT write bad data
    
    try:
        client_mock = mock_storage.Client()
        # Verify the client requested the "quarantine" bucket
        assert call("i-dub-thee-quarantine") in client_mock.bucket.call_args_list, "FATAL: Did not route to quarantine bucket."
        
        # Ensure original file is deleted from intake
        bucket_mock = client_mock.bucket()
        blob_mock = bucket_mock.blob()
        blob_mock.delete.assert_called_once()
    except AssertionError as e:
        pytest.fail(f"FATAL: Quarantine GCS routing logic is missing. Error: {e}")
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_layer1_io.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
