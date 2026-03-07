#!/bin/bash
# ==============================================================================
# REMEDIATION PROTOCOL: ZERO-TRUST BUCKET-DRIVEN RAG REFACTOR
# PROJECT ID: i-dub-thee
# ==============================================================================
set -e

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export VAULT_BUCKET="${PROJECT_ID}-forensic-vault"
export ARCHIVE_BUCKET="${PROJECT_ID}-master-filing-cabinet"
export SERVICE_ACCOUNT_EMAIL="forensic-engine-sa@${PROJECT_ID}.iam.gserviceaccount.com"

echo "[SYSTEM] Initiating Scorched Earth Remediation..."

# ==============================================================================
# 1. ANNIHILATE COMPROMISED WEB SERVER
# ==============================================================================
echo "[SYSTEM] Purging legacy rag_api directory..."
rm -rf rag_api

echo "[SYSTEM] Tearing down Cloud Run FastAPI service..."
gcloud run services delete forensic-rag-api \
    --region="${REGION}" \
    --project="${PROJECT_ID}" \
    --quiet || echo "[SYSTEM] Service already purged from GCP."

# ==============================================================================
# 2. DEPENDENCY ISOLATION BOUNDARY
# ==============================================================================
echo "[SYSTEM] Establishing ephemeral testing environment (.venv_rag_refactor)..."
python3 -m venv .venv_rag_refactor
source .venv_rag_refactor/bin/activate
pip install --quiet --upgrade pip
pip install --quiet pytest pytest-mock pydantic google-cloud-storage google-cloud-bigquery google-genai functions-framework

# ==============================================================================
# 3. AUTHORING BUCKET-DRIVEN HYPOTHESIS ENGINE (src/hypothesis_engine.py)
# ==============================================================================
echo "[SYSTEM] Authoring Serverless Hypothesis Logic..."
cat << 'EOF' > src/hypothesis_engine.py
import os
import json
import logging
from typing import List, Dict, Any
import functions_framework
from google.cloud import bigquery, storage
from google import genai
from google.genai import types

logging.basicConfig(level=logging.INFO)

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
REGION = "us-central1"
ARCHIVE_BUCKET = os.environ.get("GOOGLE_CLOUD_STORAGE_BUCKET_NAME", f"{PROJECT_ID}-master-filing-cabinet")
TABLE_ID = f"{PROJECT_ID}.forensic_fact_base.ingestion_ledger"

storage_client = storage.Client(project=PROJECT_ID)
bq_client = bigquery.Client(project=PROJECT_ID)
genai_client = genai.Client(vertexai=True, project=PROJECT_ID, location=REGION)

def generate_sql_from_hypothesis(hypothesis: str) -> str:
    prompt = f"""
    You are a forensic data engineer. Convert this investigative hypothesis into strictly valid Google Standard SQL.
    Target Table: `{TABLE_ID}`
    Schema fields available: original_parent_sha256, sliced_child_sha256, gcs_source_uri, entity_slug, taxonomy_lane, average_confidence, extracted_payload (JSON).
    
    Hypothesis: '{hypothesis}'
    
    IMPORTANT: You MUST include `sliced_child_sha256` in your SELECT statement so we can trace the math back to the physical document.
    Output ONLY the raw SQL string. Do not use markdown blocks.
    """
    response = genai_client.models.generate_content(
        model="gemini-2.5-pro",
        contents=prompt,
        config=types.GenerateContentConfig(temperature=0.0)
    )
    return response.text.replace('```sql', '').replace('```', '').strip()

def retrieve_qualitative_context(hashes: List[str]) -> str:
    bucket = storage_client.bucket(ARCHIVE_BUCKET)
    context_accumulator = []
    
    for doc_hash in hashes[:10]: 
        try:
            layout_blob = bucket.blob(f"archive/{doc_hash}/layout.md")
            if layout_blob.exists():
                markdown_content = layout_blob.download_as_text()
                context_accumulator.append(f"--- DOCUMENT HASH: {doc_hash} ---\n{markdown_content}\n")
        except Exception as e:
            logging.error(f"Failed to retrieve context for {doc_hash}: {e}")
            
    return "\n".join(context_accumulator)

def synthesize_report(hypothesis: str, sql_results: List[Dict], qualitative_context: str) -> str:
    synthesis_prompt = f"""
    You are an expert forensic accountant analyzing commingled assets.
    Synthesize the mathematical facts from the SQL database with the narrative context from the physical documents.
    
    HYPOTHESIS: {hypothesis}
    
    DETERMINISTIC MATH (SQL RESULTS): 
    {json.dumps(sql_results, default=str)}
    
    NARRATIVE CONTEXT (MARKDOWN):
    {qualitative_context}
    
    MANDATORY RULES:
    1. Output a formal Markdown report titled '## Hypothesis Validation Report'.
    2. You MUST append an exact source citation to every single insight, claim, or calculation.
    3. The citation MUST be strictly formatted as: (Source: Hash [insert sliced_child_sha256 here], Bbox: [x,y])
    4. If the bounding box is unknown, output Bbox: [Unknown].
    5. Do not hallucinate data. If the SQL math contradicts the Markdown, state the contradiction clearly.
    """
    
    response = genai_client.models.generate_content(
        model="gemini-2.5-pro",
        contents=synthesis_prompt,
        config=types.GenerateContentConfig(temperature=0.1)
    )
    return response.text

def process_hypothesis_request(bucket_name: str, object_name: str):
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    payload_str = blob.download_as_text()
    
    try:
        payload = json.loads(payload_str)
        natural_language_query = payload["natural_language_query"]
    except (json.JSONDecodeError, KeyError) as e:
        logging.error(f"MALFORMED_HYPOTHESIS_PAYLOAD: {str(e)}")
        return
        
    logging.info(f"Executing Hypothesis: {natural_language_query}")
    
    # 1. Quantitative SQL
    sql_query = generate_sql_from_hypothesis(natural_language_query)
    query_job = bq_client.query(sql_query)
    sql_results = [dict(row) for row in query_job]
    
    document_hashes = list(set([row.get("sliced_child_sha256") for row in sql_results if row.get("sliced_child_sha256")]))
    
    # 2. Qualitative Vector Context
    qualitative_context = retrieve_qualitative_context(document_hashes)
    
    # 3. Cryptographic Report Synthesis
    final_report = synthesize_report(natural_language_query, sql_results, qualitative_context)
    
    # 4. Terminal Storage Write
    report_filename = object_name.split('/')[-1].replace('.json', '_Validation_Report.md')
    archive_bucket = storage_client.bucket(ARCHIVE_BUCKET)
    report_blob = archive_bucket.blob(f"reports/{report_filename}")
    report_blob.upload_from_string(final_report, content_type="text/markdown")
    logging.info(f"[SUCCESS] Forensic Report Sealed: gs://{ARCHIVE_BUCKET}/reports/{report_filename}")

@functions_framework.cloud_event
def forensic_hypothesis_trigger(cloud_event) -> None:
    data = cloud_event.data
    bucket_name = data["bucket"]
    object_name = data["name"]

    # Strict Event Gate: Only process JSON files dropped into the investigations/ path
    if not object_name.startswith("investigations/") or not object_name.lower().endswith(".json"):
        return

    try:
        process_hypothesis_request(bucket_name, object_name)
    except Exception as e:
        logging.error(f"[FATAL] Hypothesis Engine Error on {object_name}: {str(e)}")
EOF

# ==============================================================================
# 4. RE-AUTHORING ROOT PROXY (main.py)
# ==============================================================================
echo "[SYSTEM] Updating main.py Root Proxy..."
cat << 'EOF' > main.py
# Root Entry Point for Google Cloud Functions
from src.main import forensic_document_trigger
from src.hypothesis_engine import forensic_hypothesis_trigger
EOF

# ==============================================================================
# 5. AUTHORING ADVERSARIAL TDD FOR HYPOTHESIS ENGINE
# ==============================================================================
echo "[SYSTEM] Authoring Hypothesis TDD Suite..."
cat << 'EOF' > tests/test_hypothesis_engine.py
import pytest
import json
from unittest.mock import patch, MagicMock

# Create a mock event class to satisfy the Cloud Event signature
class MockCloudEvent:
    def __init__(self, bucket, name):
        self.data = {"bucket": bucket, "name": name}

@patch('src.hypothesis_engine.process_hypothesis_request')
def test_hypothesis_trigger_gate(mock_process):
    """Proves the Cloud Function strictly isolates the investigations/ path."""
    from src.hypothesis_engine import forensic_hypothesis_trigger
    
    # Test valid path
    valid_event = MockCloudEvent("vault-bucket", "investigations/query_001.json")
    forensic_hypothesis_trigger(valid_event)
    mock_process.assert_called_once()
    mock_process.reset_mock()
    
    # Test poison paths (Should be violently rejected by the gate)
    poison_events = [
        MockCloudEvent("vault-bucket", "raw_intake/document.pdf"),
        MockCloudEvent("vault-bucket", "investigations/image.png"),
        MockCloudEvent("vault-bucket", "query_001.json") # Root path injection
    ]
    
    for event in poison_events:
        forensic_hypothesis_trigger(event)
        mock_process.assert_not_called()
EOF

# ==============================================================================
# 6. EXECUTING TDD GATE
# ==============================================================================
echo "[SYSTEM] Executing Pytest Assertion Gates..."
python3 -m pytest tests/test_hypothesis_engine.py -v

# ==============================================================================
# 7. DEPLOYING CLOUD FUNCTION
# ==============================================================================
echo "[SYSTEM] TDD Gate Passed. Deploying Layer 2: Bucket-Driven Hypothesis Engine..."
gcloud functions deploy forensic-hypothesis-engine \
    --gen2 \
    --runtime=python310 \
    --region="${REGION}" \
    --source=. \
    --entry-point=forensic_hypothesis_trigger \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=${VAULT_BUCKET}" \
    --service-account="${SERVICE_ACCOUNT_EMAIL}" \
    --memory=2048MB \
    --timeout=540s \
    --set-env-vars="GOOGLE_CLOUD_PROJECT=${PROJECT_ID},GOOGLE_CLOUD_STORAGE_BUCKET_NAME=${ARCHIVE_BUCKET}" \
    --project="${PROJECT_ID}"

# ==============================================================================
# 8. TEARDOWN
# ==============================================================================
echo "[SYSTEM] Tearing down ephemeral dependency boundary..."
deactivate
rm -rf .venv_rag_refactor

echo "============================================================================"
echo " RAG REFACTOR COMPLETE: 100% SERVERLESS PIPELINE ATTAINED "
echo " Drop JSON hypothesis payloads into gs://${VAULT_BUCKET}/investigations/ "
echo "============================================================================"