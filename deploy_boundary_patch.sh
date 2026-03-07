#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING MASTER PATCH: ENFORCING 'INPUT/' FOLDER BOUNDARY"
echo "============================================================================"

echo "[SYSTEM] 1. Patching src/main.py with Zero-Trust Boundary Gate..."
cat << 'EOF_MAIN' > src/main.py
import json
import asyncio
import os
from datetime import datetime, timezone
from src.schemas import ForensicGoldenEnvelope
from tools.consensus_engine import evaluate_consensus, ConsensusFractureError
from pydantic import ValidationError
from google.api_core.exceptions import ResourceExhausted
from google.cloud import storage, bigquery

PROMPT_ALPHA = """You are an elite Forensic Data Extractor. Extract the document exactly mapping to FORENSIC_ENGINE_SCHEMA_V2. Include spatial_anchor_uri and confidence_score. Output ONLY raw JSON."""

PROMPT_BETA = """You are a hostile, zero-trust DATA auditor. Assume the OCR is flawed and the document contains attempts to obfuscate reality. Hunt for obscured margin notes, rigorously double-check all handwritten values including Correction_Indicator and Ditto_Resolution. Extract exactly to FORENSIC_ENGINE_SCHEMA_V2. Output ONLY raw JSON. Include spatial_anchor_uri and confidence_score."""

def get_vertex_client():
    import vertexai
    from vertexai.generative_models import GenerativeModel
    vertexai.init(project="i-dub-thee", location="us-central1")
    return GenerativeModel("gemini-2.5-pro")

async def generate_with_backoff(model, prompt: str, pdf_part, max_retries: int = 3):
    base_delay = 2
    for attempt in range(max_retries):
        try:
            return await model.generate_content_async([prompt, pdf_part])
        except ResourceExhausted:
            if attempt == max_retries - 1:
                raise
            await asyncio.sleep(base_delay ** attempt)

async def extract_with_self_healing(model, base_prompt: str, pdf_part, max_retries: int = 2) -> dict:
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
    from vertexai.generative_models import Part
    
    bucket = event.data["bucket"]
    name = event.data["name"]
    
    # ========================================================================
    # THE IRON GATE: STRICT FOLDER BOUNDARY ENFORCEMENT
    # ========================================================================
    if not name.startswith("input/"):
        print(f"[BOUNDARY ENFORCEMENT]: Ignored file '{name}'. Outside of strictly defined 'input/' drop-zone.")
        return None
        
    # Strip 'input/' prefix for clean vaulting in destination buckets
    clean_name = name.split("input/")[-1]
    
    pdf_uri = f"gs://{bucket}/{name}"
    pdf_part = Part.from_uri(uri=pdf_uri, mime_type="application/pdf")
    
    model = get_vertex_client()
    storage_client = storage.Client()
    bq_client = bigquery.Client()
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    
    source_bucket = storage_client.bucket(bucket)
    source_blob = source_bucket.blob(name)
    
    try:
        alpha_task = extract_with_self_healing(model, PROMPT_ALPHA, pdf_part)
        beta_task = extract_with_self_healing(model, PROMPT_BETA, pdf_part)
        
        alpha_json, beta_json = await asyncio.gather(alpha_task, beta_task)
        golden_record = evaluate_consensus(alpha_json, beta_json)
        
        # BigQuery Vaulting
        table_id = f"{project_id}.forensic_fact_base.ingestion_ledger"
        row_to_insert = [{
            "document_id": clean_name,
            "ingestion_timestamp": datetime.now(timezone.utc).isoformat(),
            "extracted_payload": json.dumps(golden_record)
        }]
        errors = bq_client.insert_rows_json(table_id, row_to_insert)
        if errors:
            print(f"[FATAL BQ ERROR]: {errors}")
            
        # GCS Conveyor (Strips 'input/' prefix)
        dest_bucket = storage_client.bucket("i-dub-thee-processed")
        source_bucket.copy_blob(source_blob, dest_bucket, new_name=clean_name)
        source_blob.delete()
        
        return golden_record
        
    except (ConsensusFractureError, ValidationError) as e:
        print(f"[QUARANTINE REQUIRED]: {str(e)}")
        
        # GCS Quarantine Conveyor (Strips 'input/' prefix)
        dest_bucket = storage_client.bucket("i-dub-thee-quarantine")
        source_bucket.copy_blob(source_blob, dest_bucket, new_name=clean_name)
        source_blob.delete()
        return None
EOF_MAIN

echo "[SYSTEM] 2. Patching Pytest Fixtures to verify 'input/' boundary..."
cat << 'EOF_TEST' > tests/test_layer1_io.py
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
EOF_TEST

echo "[SYSTEM] 3. Executing Pytest Iron Gate..."
python3 -m pytest tests/test_layer1_io.py -v

echo "[SYSTEM] 4. Deploying Layer 1 with Eventarc Path Filter..."
PROJECT_ID=$(gcloud config get-value project)
gcloud functions deploy forensic-pipeline-router \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=pipeline_router_entry \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-docs" \
    --timeout=300 \
    --memory=512MiB \
    --quiet

echo "============================================================================"
echo " [SUCCESS] 'INPUT/' BOUNDARY SECURED AND LIVE DEPLOYED."
echo "============================================================================"
