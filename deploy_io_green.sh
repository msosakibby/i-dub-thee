#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TDD PHASE: LAYER 1 I/O PHYSICAL ROUTING (GREEN STATE)"
echo "============================================================================"

echo "[SYSTEM] 1. Patching src/main.py with physical I/O routing..."
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
    """VECTOR 1 FIX: Native Multimodal PDF Ingestion and Physical Routing."""
    from vertexai.generative_models import Part
    
    bucket = event.data["bucket"]
    name = event.data["name"]
    
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
        
        # THE I/O STRIKE: BigQuery Vaulting
        table_id = f"{project_id}.forensic_fact_base.ingestion_ledger"
        row_to_insert = [{
            "document_id": name,
            "ingestion_timestamp": datetime.now(timezone.utc).isoformat(),
            "extracted_payload": json.dumps(golden_record)
        }]
        errors = bq_client.insert_rows_json(table_id, row_to_insert)
        if errors:
            print(f"[FATAL BQ ERROR]: {errors}")
            
        # THE GCS CONVEYOR: Route to Processed
        dest_bucket = storage_client.bucket("i-dub-thee-processed")
        source_bucket.copy_blob(source_blob, dest_bucket, name)
        source_blob.delete()
        
        return golden_record
        
    except (ConsensusFractureError, ValidationError) as e:
        print(f"[QUARANTINE REQUIRED]: {str(e)}")
        
        # THE GCS CONVEYOR: Route to Quarantine
        dest_bucket = storage_client.bucket("i-dub-thee-quarantine")
        source_bucket.copy_blob(source_blob, dest_bucket, name)
        source_blob.delete()
        return None
EOF_MAIN

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_layer1_io.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
