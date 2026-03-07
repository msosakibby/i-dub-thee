#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING MASTER PATCH: QUARANTINE AUTOPSY SUB-SYSTEM"
echo "============================================================================"

PROJECT_ID=$(gcloud config get-value project)

echo "[SYSTEM] 1. Forging BigQuery 'quarantine_ledger'..."
bq mk --table \
    --schema=document_id:STRING,quarantine_timestamp:TIMESTAMP,gcs_source_uri:STRING,alpha_payload:JSON,beta_payload:JSON,fracture_reason:STRING \
    "$PROJECT_ID:forensic_fact_base.quarantine_ledger" 2>/dev/null || echo "  [+] Table already exists."

echo "[SYSTEM] 2. Authoring Autopsy Engine (tools/quarantine_autopsy.py)..."
cat << 'EOF_AUTOPSY' > tools/quarantine_autopsy.py
import json
from datetime import datetime
from google.cloud import bigquery, storage

def isolate_json_fractures(alpha: dict, beta: dict) -> dict:
    """Mathematically isolates mismatched key-value pairs between two dictionaries."""
    fractures = {}
    
    # Flatten dicts for easier comparison (simple top-level diff for now)
    alpha_keys = set(alpha.keys())
    beta_keys = set(beta.keys())
    
    for key in alpha_keys.union(beta_keys):
        val_alpha = alpha.get(key)
        val_beta = beta.get(key)
        if val_alpha != val_beta:
            fractures[key] = {"alpha_value": val_alpha, "beta_value": val_beta}
            
    return fractures

def generate_autopsy_markdown(bq_rows) -> str:
    """Compiles isolated fractures into a Daubert-admissible Markdown string."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    report = f"# QUARANTINE AUTOPSY REPORT\n**Generated:** {timestamp}\n\n"
    
    if not bq_rows:
        report += "No new quarantine fractures detected in the ledger.\n"
        return report

    for row in bq_rows:
        report += f"## Document ID: `{row.document_id}`\n"
        report += f"**Timestamp:** {row.quarantine_timestamp}\n"
        report += f"**Source URI:** {row.gcs_source_uri}\n"
        report += f"**Reason:** {row.fracture_reason}\n\n"
        
        try:
            alpha = json.loads(row.alpha_payload) if isinstance(row.alpha_payload, str) else row.alpha_payload
            beta = json.loads(row.beta_payload) if isinstance(row.beta_payload, str) else row.beta_payload
            
            fractures = isolate_json_fractures(alpha, beta)
            report += "### ISOLATED FRACTURES:\n"
            report += "| Disputed Field | Alpha Extraction (Neutral) | Beta Extraction (Hostile) |\n"
            report += "|---|---|---|\n"
            for field, vals in fractures.items():
                report += f"| `{field}` | `{vals['alpha_value']}` | `{vals['beta_value']}` |\n"
            
        except Exception as e:
             report += f"*(Error parsing payloads for diff: {str(e)})*\n"
        report += "\n---\n"
        
    return report

def execute_autopsy_report():
    """Queries the ledger and writes the Markdown artifact to GCS."""
    bq_client = bigquery.Client()
    storage_client = storage.Client()
    
    query = """
        SELECT * FROM `i-dub-thee.forensic_fact_base.quarantine_ledger`
        ORDER BY quarantine_timestamp DESC LIMIT 50
    """
    rows = list(bq_client.query(query).result())
    markdown_content = generate_autopsy_markdown(rows)
    
    bucket = storage_client.bucket("i-dub-thee-master-filing-cabinet")
    blob = bucket.blob("Quarantine_Autopsy_Report.md")
    blob.upload_from_string(markdown_content, content_type="text/markdown")
    print("[+] Autopsy Report written to Master Filing Cabinet.")

if __name__ == "__main__":
    execute_autopsy_report()
EOF_AUTOPSY

echo "[SYSTEM] 3. Patching src/main.py to vault fractured data..."
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

SCHEMA_DEFINITION = json.dumps(ForensicGoldenEnvelope.model_json_schema(), indent=2)

PROMPT_ALPHA = f"""You are an elite Forensic Data Extractor. Extract the document exactly mapping to the FORENSIC_ENGINE_SCHEMA_V2 provided below. 
You MUST output valid JSON strictly adhering to this schema. Include spatial_anchor_uri and confidence_score.

SCHEMA:
{SCHEMA_DEFINITION}
"""

PROMPT_BETA = f"""You are a hostile, zero-trust DATA auditor. Assume the OCR is flawed and the document contains attempts to obfuscate reality. Hunt for obscured margin notes, rigorously double-check all handwritten values. Extract exactly to the FORENSIC_ENGINE_SCHEMA_V2 provided below. 
You MUST output valid JSON strictly adhering to this schema. Include spatial_anchor_uri and confidence_score.

SCHEMA:
{SCHEMA_DEFINITION}
"""

def get_vertex_client():
    import vertexai
    from vertexai.generative_models import GenerativeModel
    vertexai.init(project="i-dub-thee", location="us-central1")
    return GenerativeModel("gemini-2.5-pro")

async def generate_with_backoff(model, prompt: str, pdf_part, max_retries: int = 3):
    from vertexai.generative_models import GenerationConfig
    config = GenerationConfig(response_mime_type="application/json")
    base_delay = 2
    for attempt in range(max_retries):
        try:
            return await model.generate_content_async([prompt, pdf_part], generation_config=config)
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
            current_prompt = f"{base_prompt}\n\n[SYSTEM WARNING]: Pydantic validation failed:\n{e.json()}"
        except json.JSONDecodeError:
            if attempt == max_retries - 1:
                raise
            current_prompt = f"{base_prompt}\n\n[SYSTEM WARNING]: Output was not valid JSON."

async def process_document(event, context):
    from vertexai.generative_models import Part
    
    bucket = event.data["bucket"]
    name = event.data["name"]
    
    if not name.startswith("input/"):
        return None
        
    clean_name = name.split("input/")[-1]
    pdf_uri = f"gs://{bucket}/{name}"
    pdf_part = Part.from_uri(uri=pdf_uri, mime_type="application/pdf")
    
    model = get_vertex_client()
    storage_client = storage.Client()
    bq_client = bigquery.Client()
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    
    source_bucket = storage_client.bucket(bucket)
    source_blob = source_bucket.blob(name)
    
    alpha_json = None
    beta_json = None
    
    try:
        alpha_task = extract_with_self_healing(model, PROMPT_ALPHA, pdf_part)
        beta_task = extract_with_self_healing(model, PROMPT_BETA, pdf_part)
        
        alpha_json, beta_json = await asyncio.gather(alpha_task, beta_task)
        golden_record = evaluate_consensus(alpha_json, beta_json)
        
        table_id = f"{project_id}.forensic_fact_base.ingestion_ledger"
        row_to_insert = [{
            "document_id": clean_name,
            "ingestion_timestamp": datetime.now(timezone.utc).isoformat(),
            "extracted_payload": json.dumps(golden_record)
        }]
        bq_client.insert_rows_json(table_id, row_to_insert)
            
        dest_bucket = storage_client.bucket("i-dub-thee-processed")
        source_bucket.copy_blob(source_blob, dest_bucket, new_name=clean_name)
        source_blob.delete()
        
        return golden_record
        
    except (ConsensusFractureError, ValidationError, Exception) as e:
        print(f"[QUARANTINE REQUIRED]: {str(e)}")
        
        # VECTOR 1 FIX: Vault the fractured data into the Ledger
        if alpha_json or beta_json:
             q_table_id = f"{project_id}.forensic_fact_base.quarantine_ledger"
             q_row = [{
                 "document_id": clean_name,
                 "quarantine_timestamp": datetime.now(timezone.utc).isoformat(),
                 "gcs_source_uri": pdf_uri,
                 "alpha_payload": json.dumps(alpha_json) if alpha_json else None,
                 "beta_payload": json.dumps(beta_json) if beta_json else None,
                 "fracture_reason": str(e)
             }]
             bq_client.insert_rows_json(q_table_id, q_row)
             print(f"[+] Fractured payloads vaulted to quarantine_ledger.")
        
        dest_bucket = storage_client.bucket("i-dub-thee-quarantine")
        source_bucket.copy_blob(source_blob, dest_bucket, new_name=clean_name)
        source_blob.delete()
        return None
EOF_MAIN

echo "[SYSTEM] 4. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_quarantine_autopsy.py -v

echo "[SYSTEM] 5. Deploying Layer 1 to GCP..."
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
echo " [SUCCESS] AUTOPSY SUB-SYSTEM LIVE. DATA NO LONGER EVAPORATES."
echo "============================================================================"
