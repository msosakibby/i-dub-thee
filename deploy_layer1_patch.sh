#!/bin/bash
set -e

echo "[SYSTEM] 1. Enforcing Python Package Architecture..."
touch src/__init__.py
touch tools/__init__.py
touch tests/__init__.py

echo "[SYSTEM] 2. Patching src/main.py (Enforcing Lazy Imports)..."
cat << 'EOF_MAIN' > src/main.py
import json
import asyncio
from src.schemas import ForensicGoldenEnvelope
from tools.consensus_engine import evaluate_consensus, ConsensusFractureError
from pydantic import ValidationError
from google.api_core.exceptions import ResourceExhausted

# VECTOR 2 FIX: Neutral, Hostile DATA Auditor (Zero Legal Logic)
PROMPT_ALPHA = """You are an elite Forensic Data Extractor. Extract the document exactly mapping to FORENSIC_ENGINE_SCHEMA_V2. Include spatial_anchor_uri and confidence_score. Output ONLY raw JSON."""

PROMPT_BETA = """You are a hostile, zero-trust DATA auditor. Assume the OCR is flawed and the document contains attempts to obfuscate reality. Hunt for obscured margin notes, rigorously double-check all handwritten values including Correction_Indicator and Ditto_Resolution. Extract exactly to FORENSIC_ENGINE_SCHEMA_V2. Output ONLY raw JSON. Include spatial_anchor_uri and confidence_score."""

def get_vertex_client():
    import vertexai
    from vertexai.generative_models import GenerativeModel
    vertexai.init(project="i-dub-thee", location="us-central1")
    return GenerativeModel("gemini-2.5-pro")

async def generate_with_backoff(model, prompt: str, pdf_part, max_retries: int = 3):
    """VECTOR 5 FIX: Exponential Backoff for 429 Network Strikes."""
    base_delay = 2
    for attempt in range(max_retries):
        try:
            return await model.generate_content_async([prompt, pdf_part])
        except ResourceExhausted:
            if attempt == max_retries - 1:
                raise
            await asyncio.sleep(base_delay ** attempt)

async def extract_with_self_healing(model, base_prompt: str, pdf_part, max_retries: int = 2) -> dict:
    """VECTOR 6 FIX: Active Pydantic Self-Correction Loop."""
    current_prompt = base_prompt
    for attempt in range(max_retries):
        response = await generate_with_backoff(model, current_prompt, pdf_part)
        
        raw_text = response.text.strip()
        if raw_text.startswith("```json"):
            raw_text = raw_text[7:]
        if raw_text.endswith("```"):
            raw_text = raw_text[:-3]
            
        try:
            data = json.loads(raw_text)
            validated = ForensicGoldenEnvelope(**data)
            return validated.model_dump()
        except ValidationError as e:
            if attempt == max_retries - 1:
                raise
            current_prompt = f"{base_prompt}\n\n[SYSTEM WARNING]: Pydantic validation failed with the following error:\n{e.json()}\n\nFix the data types and missing fields. Output ONLY valid JSON."
        except json.JSONDecodeError:
            if attempt == max_retries - 1:
                raise
            current_prompt = f"{base_prompt}\n\n[SYSTEM WARNING]: Output was not valid JSON. Ensure there is no conversational text."

async def process_document(event, context):
    """VECTOR 1 FIX: Native Multimodal PDF Ingestion via Part.from_uri."""
    # LAZY IMPORT: Keeps the global scope safe for testing
    from vertexai.generative_models import Part
    
    bucket = event.data["bucket"]
    name = event.data["name"]
    
    pdf_uri = f"gs://{bucket}/{name}"
    pdf_part = Part.from_uri(uri=pdf_uri, mime_type="application/pdf")
    
    model = get_vertex_client()
    
    try:
        alpha_task = extract_with_self_healing(model, PROMPT_ALPHA, pdf_part)
        beta_task = extract_with_self_healing(model, PROMPT_BETA, pdf_part)
        
        alpha_json, beta_json = await asyncio.gather(alpha_task, beta_task)
        golden_record = evaluate_consensus(alpha_json, beta_json)
        
        return golden_record
        
    except (ConsensusFractureError, ValidationError) as e:
        print(f"[QUARANTINE REQUIRED]: {str(e)}")
        return None
EOF_MAIN

echo "[SYSTEM] 3. Patching Pytest Fixtures (Removing silent swallows)..."
cat << 'EOF_TEST' > tests/test_layer1_refactor.py
import pytest
import asyncio
from unittest.mock import patch, MagicMock, AsyncMock
from google.api_core.exceptions import ResourceExhausted

from src.main import PROMPT_BETA, process_document, get_vertex_client
from tools.consensus_engine import evaluate_consensus, ConsensusFractureError
from src.schemas import ForensicGoldenEnvelope

@pytest.mark.asyncio
async def test_multimodal_pdf_ingestion():
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_client.return_value.GenerativeModel.return_value = mock_model
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "invoice.pdf"}
        
        # We must mock Part.from_uri to prevent it from reaching out during the test
        with patch("vertexai.generative_models.Part.from_uri") as mock_part:
            mock_part.return_value = "MOCKED_PDF_PART"
            await process_document(mock_event, None)
            
            call_args = mock_model.generate_content_async.call_args[0][0]
            assert "MOCKED_PDF_PART" in call_args, "FATAL: Multimodal violation. Part object was not passed to the model."

def test_prompt_beta_data_hostility():
    assert "Antenuptial" not in PROMPT_BETA, "FATAL: Legal logic bleeding into Layer 1 extraction."
    assert "hobby" not in PROMPT_BETA.lower(), "FATAL: Bias detected. Beta is assuming expenses are hobbies."
    assert "Correction_Indicator" in PROMPT_BETA, "FATAL: Missing forensic directive for handwritten OCR."

@pytest.mark.asyncio
async def test_forensic_metadata_extraction():
    bad_payload = {
        "document_type": "pos_retail_receipt",
        "extracted_data": {"Gross_Total": 150.0}
    }
    with pytest.raises(ValueError) as excinfo:
        ForensicGoldenEnvelope(**bad_payload)
    
    assert "confidence_score" in str(excinfo.value)
    assert "spatial_anchor_uri" in str(excinfo.value)

def test_semantic_json_equality():
    payload_alpha = {"amount": 150.00, "date": "2005-07-20"}
    payload_beta = {"date": "2005-07-20", "amount": 150.0}
    
    try:
        result = evaluate_consensus(payload_alpha, payload_beta)
        assert result == payload_alpha
    except ConsensusFractureError:
        pytest.fail("FATAL: Semantic equality failed.")

@pytest.mark.asyncio
async def test_async_exponential_backoff():
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_model.generate_content_async.side_effect = [
            ResourceExhausted("429 Quota exceeded."),
            MagicMock(text='{"status": "success"}')
        ]
        mock_client.return_value.GenerativeModel.return_value = mock_model
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
        
        assert mock_model.generate_content_async.call_count == 2

@pytest.mark.asyncio
async def test_pydantic_active_self_correction():
    with patch("src.main.get_vertex_client") as mock_client:
        mock_model = AsyncMock()
        mock_model.generate_content_async.side_effect = [
            MagicMock(text='{"amount": "$150.00"}'), 
            MagicMock(text='{"amount": 150.0}')
        ]
        mock_client.return_value.GenerativeModel.return_value = mock_model
        
        mock_event = MagicMock()
        mock_event.data = {"bucket": "i-dub-thee-intake", "name": "receipt.pdf"}
        
        with patch("vertexai.generative_models.Part.from_uri"):
            await process_document(mock_event, None)
        
        assert mock_model.generate_content_async.call_count == 2
EOF_TEST

echo "[SYSTEM] 4. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_layer1_refactor.py -v

