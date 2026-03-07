#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TDD PHASE: LAYER 1 ARCHITECTURAL REFACTOR (RED STATE)"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring TDD Fixtures (tests/test_layer1_refactor.py)..."
cat << 'EOF_TEST' > tests/test_layer1_refactor.py
import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock
from google.api_core.exceptions import ResourceExhausted

# We will attempt to import from the current architecture.
# Some of these will fail immediately if the hooks don't exist yet (Expected Red State).
try:
    from src.main import PROMPT_BETA, process_document, get_vertex_client
except ImportError:
    pass

try:
    from tools.consensus_engine import evaluate_consensus, ConsensusFractureError
except ImportError:
    pass

@pytest.mark.asyncio
async def test_multimodal_pdf_ingestion():
    """VECTOR 1: Proves the system passes raw PDF URIs to Gemini 2.x+, not simulated text."""
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value.GenerativeModel.return_value = mock_model
        
        # Simulate an Eventarc trigger for a PDF drop
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "invoice.pdf"}
        
        await process_document(mock_event, None)
        
        # The model MUST be called with a Part object representing the PDF, not a string.
        call_args = mock_model.generate_content_async.call_args[0][0]
        assert any(hasattr(arg, "file_data") or hasattr(arg, "uri") for arg in call_args), \
            "FATAL: Multimodal violation. Model was passed raw text instead of a PDF Part."

def test_prompt_beta_data_hostility():
    """VECTOR 2: Proves Model Beta is a Data Auditor, not a Legal Auditor."""
    assert "Antenuptial" not in PROMPT_BETA, "FATAL: Legal logic bleeding into Layer 1 extraction."
    assert "hobby" not in PROMPT_BETA.lower(), "FATAL: Bias detected. Beta is assuming expenses are hobbies."
    assert "Correction_Indicator" in PROMPT_BETA, "FATAL: Missing forensic directive for handwritten OCR."

@pytest.mark.asyncio
async def test_forensic_metadata_extraction():
    """VECTOR 3: Proves the schema forces extraction of spatial anchors and confidence scores."""
    from src.schemas import ForensicGoldenEnvelope
    
    # Simulating an LLM payload missing the mandatory metadata
    bad_payload = {
        "document_type": "pos_retail_receipt",
        "extracted_data": {"Gross_Total": 150.0}
    }
    
    with pytest.raises(ValueError) as excinfo:
        ForensicGoldenEnvelope(**bad_payload)
    
    assert "confidence_score" in str(excinfo.value), "FATAL: Schema allowed extraction without a confidence score."
    assert "spatial_anchor" in str(excinfo.value) or "bounding_box" in str(excinfo.value), \
        "FATAL: Schema allowed extraction without a physical document anchor."

def test_semantic_json_equality():
    """VECTOR 4: Proves consensus engine survives floating-point and ordering variations."""
    payload_alpha = {"amount": 150.00, "date": "2005-07-20"}
    payload_beta = {"date": "2005-07-20", "amount": 150.0} # Order swapped, integer float vs double float
    
    try:
        result = evaluate_consensus(payload_alpha, payload_beta)
        assert result == payload_alpha # Should succeed seamlessly
    except ConsensusFractureError:
        pytest.fail("FATAL: Semantic equality failed. The engine is brittle to JSON serialization differences.")

@pytest.mark.asyncio
async def test_async_exponential_backoff():
    """VECTOR 5: Proves the router survives transient 429 Rate Limit errors."""
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        
        # First call fails with 429. Second call succeeds.
        mock_model.generate_content_async.side_effect = [
            ResourceExhausted("429 Quota exceeded."),
            MagicMock(text='{"status": "success"}')
        ]
        mock_client.return_value.GenerativeModel.return_value = mock_model
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "receipt.pdf"}
        
        # If backoff isn't implemented, this will crash the entire function.
        await process_document(mock_event, None)
        
        # Assert the engine retried and eventually succeeded
        assert mock_model.generate_content_async.call_count == 2, \
            "FATAL: Exponential backoff missing. Pipeline crashed on first network error."

@pytest.mark.asyncio
async def test_pydantic_active_self_correction():
    """VECTOR 6: Proves the engine feeds Pydantic errors back to Gemini for self-healing."""
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        
        # First call returns a string instead of a float (triggers Pydantic ValueError)
        # Second call returns the corrected JSON
        mock_model.generate_content_async.side_effect = [
            MagicMock(text='{"amount": "$150.00"}'), 
            MagicMock(text='{"amount": 150.0}')
        ]
        mock_client.return_value.GenerativeModel.return_value = mock_model
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "receipt.pdf"}
        
        await process_document(mock_event, None)
        
        # The model MUST be called twice: once for the initial extraction, once for the correction.
        assert mock_model.generate_content_async.call_count == 2, \
            "FATAL: Active self-correction missing. Pydantic passively quarantined the document."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting Massive Failure/Red State)..."
python3 -m pytest tests/test_layer1_refactor.py -v || true

echo "============================================================================"
echo " [WAITING FOR RED STATE TELEMETRY]"
echo "============================================================================"
