import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock, call
from src.main import process_document

VALID_MOCK_JSON = '{"document_type": "pos_retail_receipt", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-docs/input/receipt.pdf", "extracted_data": {"amount": 150.0}}'
INVALID_MOCK_JSON = '{"document_type": "pos_retail_receipt", "spatial_anchor_uri": "gs://i-dub-thee-docs/input/receipt.pdf", "extracted_data": {}}' 

@pytest.mark.asyncio
@patch('src.main.storage')
@patch('src.main.bigquery')
async def test_successful_io_routing(mock_bq, mock_storage):
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model
        
        mock_model.generate_content_async.side_effect = [
            MagicMock(text=VALID_MOCK_JSON), MagicMock(text=VALID_MOCK_JSON)
        ]
        
        # PROVING THE BOUNDARY: Using the 'input/' prefix
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-docs", "name": "input/receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
            
    mock_bq.Client().insert_rows_json.assert_called_once()
    client_mock = mock_storage.Client()
    assert call("i-dub-thee-processed") in client_mock.bucket.call_args_list
    
    # Ensure it moved cleanly without the 'input/' directory
    bucket_mock = client_mock.bucket()
    call_args = bucket_mock.copy_blob.call_args
    assert "new_name='receipt.pdf'" in str(call_args) or "'receipt.pdf'" in str(call_args), "FATAL: Did not strip input/ prefix."

@pytest.mark.asyncio
@patch('src.main.storage')
@patch('src.main.bigquery')
@patch('src.main.get_vertex_client')
async def test_boundary_rejection(mock_get_client, mock_bq, mock_storage):
    """VECTOR 3: Proves the system ignores files outside of the input/ folder."""
    mock_event = MagicMock()
    mock_event.data = {"bucket": "i-dub-thee-docs", "name": "rogue_file.pdf"} # Missing input/
    
    result = await process_document(mock_event, None)
    
    assert result is None
    mock_get_client.assert_not_called()
    mock_bq.Client().insert_rows_json.assert_not_called()
