#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING MASTER TDD DEPLOYMENT: LAYER 1 ASYNC ROUTER (LAZY INIT FIX)"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring TDD Fixtures (tests/test_async_router.py)..."
cat << 'EOF_TEST' > tests/test_async_router.py
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
EOF_TEST

echo "[SYSTEM] 2. Authoring Implementation (src/main.py)..."
cat << 'EOF_PYTHON' > src/main.py
import os
import json
import asyncio
import functions_framework
from google import genai
from google.genai import types
from google.cloud import storage, bigquery
from tools.consensus_engine import evaluate_consensus, ConsensusFractureError
from src.schemas import ForensicGoldenEnvelope

# ============================================================================
# LEGAL FORENSICS ENGINE - LAYER 1 ROUTER (V17 PLATINUM)
# DIRECTIVE: Dual-Model Asynchronous Consensus & Zero-Trust Ingestion
# ============================================================================

MODEL_ID = "gemini-2.5-pro"
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT_IDENTIFIER", "i-dub-thee")

PROMPT_ALPHA = """You are a neutral forensic data extraction engine. 
Map the provided OCR text strictly to the 18-Lane Taxonomy. 
Extract entities and monetary values objectively. Output ONLY raw JSON."""

PROMPT_BETA = """You are a hostile defense auditor enforcing the 2005 Antenuptial Agreement. 
Assume all expenses are personal Claimant hobbies (e.g., LANE_17) unless explicitly proven otherwise by the text. 
Challenge entity commingling relentlessly. Output ONLY raw JSON."""

# Global state for container reuse
_vertex_client = None
storage_client = None
bq_client = None

def get_vertex_client():
    """Lazy initialization: Prevents Pytest import crashes and explicitly targets GCP Vertex AI."""
    global _vertex_client
    if _vertex_client is None:
        _vertex_client = genai.Client(vertexai=True, project=PROJECT_ID, location="us-central1")
    return _vertex_client

async def query_model(system_instruction: str, ocr_text: str) -> dict:
    """Executes a single asynchronous Vertex AI call with strict greedy decoding."""
    client = get_vertex_client()
    config = types.GenerateContentConfig(
        system_instruction=system_instruction,
        temperature=0.0,
        response_mime_type="application/json"
    )
    response = await client.aio.models.generate_content(
        model=MODEL_ID,
        contents=ocr_text,
        config=config
    )
    return json.loads(response.text)

async def execute_dual_model_fanout(ocr_text: str) -> dict:
    """Fires Alpha and Beta concurrently, waits for both, and enforces mathematical consensus."""
    alpha_task = query_model(PROMPT_ALPHA, ocr_text)
    beta_task = query_model(PROMPT_BETA, ocr_text)
    
    alpha_json, beta_json = await asyncio.gather(alpha_task, beta_task)
    return evaluate_consensus(alpha_json, beta_json)

def quarantine_payload(bucket_name: str, file_name: str, error_msg: str, payload: dict):
    """Routes fractured or mathematically doomed payloads to the human-in-the-loop bucket."""
    global storage_client
    if storage_client is None:
        storage_client = storage.Client()
        
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(f"quarantined_schemas/{file_name}_FRACTURE.json")
    quarantine_data = {"error": error_msg, "attempted_payload": payload}
    blob.upload_from_string(json.dumps(quarantine_data, indent=2), content_type="application/json")
    print(f"[!] QUARANTINE TRIGGERED: {error_msg}")

@functions_framework.cloud_event
def forensic_pipeline_router(cloud_event):
    """The main Eventarc entry point triggered by a GCS PDF drop."""
    global bq_client
    if bq_client is None:
        bq_client = bigquery.Client()
        
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]
    
    raw_ocr_text = f"Simulated OCR extraction for {file_name}. Transfer of $15,000 to Kibby Company LLC."
    
    try:
        # 1. Execute Dual-Model Consensus (The Soft Gate)
        consensus_payload = asyncio.run(execute_dual_model_fanout(raw_ocr_text))
        
        # 2. Execute Pydantic Validation (The Iron Gate)
        golden_envelope = ForensicGoldenEnvelope(**consensus_payload)
        
        # 3. Stream A: Insert to BigQuery Fact Base
        table_id = f"{PROJECT_ID}.forensic_fact_base.ingestion_ledger"
        errors = bq_client.insert_rows_json(table_id, [golden_envelope.model_dump(mode='json')])
        
        if errors:
            raise RuntimeError(f"BigQuery Insertion Failed: {errors}")
            
        print(f"[+] SUCCESS: {file_name} mathematically verified and written to Fact Base.")
        
    except ConsensusFractureError as cfe:
        quarantine_payload("i-dub-thee-forensic-vault", file_name, str(cfe), {"ocr_text": raw_ocr_text})
        
    except ValueError as ve:
        quarantine_payload("i-dub-thee-forensic-vault", file_name, f"Pydantic Iron Gate Rejection: {str(ve)}", {"ocr_text": raw_ocr_text})

EOF_PYTHON

echo "[SYSTEM] 3. Executing Pytest Iron Gate (Async TDD Proof)..."
python3 -m pytest tests/test_async_router.py -v

echo "============================================================================"
echo " [SUCCESS] LAYER 1 ASYNC ROUTER FULLY REFACTORED AND PROVEN."
echo "============================================================================"
