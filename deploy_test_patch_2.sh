#!/bin/bash
set -e

echo "[SYSTEM] 1. Patching Pytest Fixtures (Resolving Async Mock Exhaustion)..."
cat << 'EOF_TEST' > tests/test_layer1_refactor.py
import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock
from google.api_core.exceptions import ResourceExhausted

from src.main import PROMPT_BETA, process_document
from tools.consensus_engine import evaluate_consensus, ConsensusFractureError
from src.schemas import ForensicGoldenEnvelope

VALID_MOCK_JSON = '{"document_type": "pos_retail_receipt", "confidence_score": 0.99, "spatial_anchor_uri": "gs://i-dub-thee-intake/receipt.pdf", "extracted_data": {"amount": 150.0}}'
INVALID_MOCK_JSON = '{"document_type": "pos_retail_receipt", "spatial_anchor_uri": "gs://i-dub-thee-intake/receipt.pdf", "extracted_data": {}}' # Missing confidence_score

@pytest.mark.asyncio
async def test_multimodal_pdf_ingestion():
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model 
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "invoice.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri") as mock_part:
            mock_part.return_value = "MOCKED_PDF_PART"
            mock_model.generate_content_async.return_value = MagicMock(text=VALID_MOCK_JSON)
            
            await process_document(mock_event, None)
            
            call_args = mock_model.generate_content_async.call_args[0][0]
            assert "MOCKED_PDF_PART" in call_args, "FATAL: Multimodal violation."

def test_prompt_beta_data_hostility():
    assert "Antenuptial" not in PROMPT_BETA
    assert "hobby" not in PROMPT_BETA.lower()
    assert "Correction_Indicator" in PROMPT_BETA

@pytest.mark.asyncio
async def test_forensic_metadata_extraction():
    bad_payload = {"document_type": "pos_retail_receipt", "extracted_data": {}}
    with pytest.raises(ValueError):
        ForensicGoldenEnvelope(**bad_payload)

def test_semantic_json_equality():
    payload_alpha = {"amount": 150.00, "date": "2005-07-20"}
    payload_beta = {"date": "2005-07-20", "amount": 150.0}
    assert evaluate_consensus(payload_alpha, payload_beta) == payload_alpha

@pytest.mark.asyncio
async def test_async_exponential_backoff():
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model 
        
        mock_model.generate_content_async.side_effect = [
            ResourceExhausted("429 Quota"),
            ResourceExhausted("429 Quota"),
            MagicMock(text=VALID_MOCK_JSON),
            MagicMock(text=VALID_MOCK_JSON)
        ]
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
        
        assert mock_model.generate_content_async.call_count == 4

@pytest.mark.asyncio
async def test_pydantic_active_self_correction():
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value = mock_model 
        
        async def dynamic_healing_mock(prompt_data, *args, **kwargs):
            """Deterministically evaluates the prompt text to simulate LLM self-healing."""
            prompt_text = prompt_data[0]
            if "Pydantic validation failed" in prompt_text:
                return MagicMock(text=VALID_MOCK_JSON)
            else:
                return MagicMock(text=INVALID_MOCK_JSON)
                
        mock_model.generate_content_async.side_effect = dynamic_healing_mock
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
        
        # Alpha fails once, fixes itself. Beta fails once, fixes itself. Total = 4.
        assert mock_model.generate_content_async.call_count == 4
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_layer1_refactor.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
