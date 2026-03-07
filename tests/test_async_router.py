import pytest
import asyncio
from unittest.mock import patch, AsyncMock, MagicMock
from src.main import execute_dual_model_fanout
from tools.consensus_engine import ConsensusFractureError

@pytest.fixture
def mock_alpha_response():
    return '{"taxonomy_lane": "LANE_09_INFRASTRUCTURE_EQUIPMENT", "entity_identified": "Kibby Company LLC", "extracted_data": {"mock_value": 15000.00}}'

@pytest.fixture
def mock_beta_response_match():
    return '{"taxonomy_lane": "LANE_09_INFRASTRUCTURE_EQUIPMENT", "entity_identified": "Kibby Company LLC", "extracted_data": {"mock_value": 15000.00}}'

@pytest.fixture
def mock_beta_response_fracture():
    return '{"taxonomy_lane": "LANE_17_SPORTING_RECREATION", "entity_identified": "Kibby Company LLC", "extracted_data": {"mock_value": 15000.00}}'

@pytest.mark.asyncio
@patch('src.main.get_vertex_client')
async def test_async_fanout_consensus_success(mock_get_client, mock_alpha_response, mock_beta_response_match):
    """PROVES: The async fan-out successfully aggregates matching payloads and returns the pristine dict."""
    mock_client = MagicMock()
    # Mock the asynchronous generate_content call directly on the client object
    mock_client.aio.models.generate_content = AsyncMock(side_effect=[
        AsyncMock(text=mock_alpha_response),
        AsyncMock(text=mock_beta_response_match)
    ])
    mock_get_client.return_value = mock_client
    
    result = await execute_dual_model_fanout("RAW_OCR_TEXT")
    
    assert result["taxonomy_lane"] == "LANE_09_INFRASTRUCTURE_EQUIPMENT", "FATAL: Consensus match failed to return Alpha payload."
    assert mock_client.aio.models.generate_content.call_count == 2, "FATAL: Async client was not called exactly twice."

@pytest.mark.asyncio
@patch('src.main.get_vertex_client')
async def test_async_fanout_consensus_fracture(mock_get_client, mock_alpha_response, mock_beta_response_fracture):
    """PROVES: The async fan-out violently halts and raises the custom error if the models disagree."""
    mock_client = MagicMock()
    mock_client.aio.models.generate_content = AsyncMock(side_effect=[
        AsyncMock(text=mock_alpha_response),
        AsyncMock(text=mock_beta_response_fracture)
    ])
    mock_get_client.return_value = mock_client
    
    with pytest.raises(ConsensusFractureError) as exc_info:
        await execute_dual_model_fanout("RAW_OCR_TEXT")
        
    assert "Taxonomy Mismatch" in str(exc_info.value), "FATAL: Async router swallowed a consensus fracture."
