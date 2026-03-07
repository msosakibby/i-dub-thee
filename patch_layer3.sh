#!/bin/bash
set -e
echo "[SYSTEM] Patching Layer 3: Enforcing Deep Text Regex Firewall..."
cd layer3_bq_ingestor

cat << 'EOF_LAYER3_MAIN' > main.py
import os
import json
import logging
import re
import functions_framework
from google.cloud import storage, bigquery
from cloudevents.http import CloudEvent

logging.basicConfig(level=logging.INFO, format='%(asctime)s - BIGQUERY_BRIDGE - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# THE STRICT REGEX REJECT LIST
QUARANTINE_REGEX = re.compile(r'(?i)\b(Mark Kibby|Mark Sosa-Kibby|Mark William Sosa|Mark Willliam Sosa|Mark W Kibby|Parker Sosa-Kibby|Cole Sosa-Kibby|Erik Sosa-Kibby|Parker|Cole|Erik)\b')

def parse_taxonomy_vector(vector: str) -> dict:
    parts = [p.strip() for p in vector.split('/')]
    return {
        "taxonomy_lane": parts[0] if len(parts) > 0 else "UNKNOWN",
        "entity_slug": parts[1] if len(parts) > 1 else "UNKNOWN",
        "institution": parts[2] if len(parts) > 2 else "UNKNOWN",
        "document_type": parts[3] if len(parts) > 3 else "UNKNOWN"
    }

def build_bq_row(payload: dict) -> dict:
    metadata = payload.get("dossier_metadata", {})
    vector = metadata.get("taxonomy_vector", "UNKNOWN / UNKNOWN / UNKNOWN / UNKNOWN")
    parsed_vector = parse_taxonomy_vector(vector)
    
    return {
        "parent_file_hash": metadata.get("cryptographic_hash", "UNKNOWN_HASH"),
        "gcs_source_uri": metadata.get("source_artifact_uri", "UNKNOWN_URI"),
        "taxonomy_lane": parsed_vector["taxonomy_lane"],
        "entity_slug": parsed_vector["entity_slug"],
        "document_type": parsed_vector["document_type"],
        "document_date": None,
        "confidence_score": 0.99,
        "requires_manual_review": False,
        "evidence_coordinates": None,
        "extracted_payload": json.dumps(payload.get("extracted_facts", []))
    }

def determine_routing_directives(file_uri: str) -> dict:
    is_sandbox = "[SANDBOX]" in file_uri
    return {"is_sandbox": is_sandbox, "target_table": "sandbox_extracted_facts" if is_sandbox else "extracted_facts"}

def enforce_idempotency(bq_client, project_id: str, dataset_id: str, target_table: str, file_hash: str, is_sandbox: bool) -> bool:
    if is_sandbox: return True
    query = f"SELECT parent_file_hash FROM `{project_id}.{dataset_id}.{target_table}` WHERE parent_file_hash = @file_hash LIMIT 1"
    job_config = bigquery.QueryJobConfig(query_parameters=[bigquery.ScalarQueryParameter("file_hash", "STRING", file_hash)])
    results = list(bq_client.query(query, job_config=job_config).result())
    return len(results) == 0

@functions_framework.cloud_event
def ingest_to_bigquery(cloud_event: CloudEvent):
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]

    if not file_name.endswith("_Report5_Extraction.json"): return

    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    dataset_id = os.environ.get("BQ_DATASET", "forensic_fact_base")

    storage_client = storage.Client()
    bq_client = bigquery.Client(project=project_id)

    try:
        full_uri = f"gs://{bucket_name}/{file_name}"
        routing = determine_routing_directives(full_uri)
        target_table = routing["target_table"]
        is_sandbox = routing["is_sandbox"]

        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        
        file_contents_bytes = blob.download_as_string()
        if len(file_contents_bytes) == 0: return
        
        file_contents_str = file_contents_bytes.decode('utf-8')
        
        # 🚨 LAYER 3 DEEP TEXT FIREWALL
        if QUARANTINE_REGEX.search(file_contents_str):
            logger.warning(f"FAMILY_FIREWALL_BREACH: Restricted entity detected. Aborting DB Insert. File: {file_name}")
            return
            
        payload = json.loads(file_contents_str)
        
        bq_row = build_bq_row(payload)
        file_hash = bq_row["parent_file_hash"]

        if not enforce_idempotency(bq_client, project_id, dataset_id, target_table, file_hash, is_sandbox):
            return

        table_ref = f"{project_id}.{dataset_id}.{target_table}"
        errors = bq_client.insert_rows_json(table_ref, [bq_row])

        if errors: raise ValueError(f"BigQuery rejection. Errors: {errors}")

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION IN L3: {str(e)}")
        raise e
EOF_LAYER3_MAIN

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

gcloud functions deploy forensic-bq-ingestor \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=ingest_to_bigquery \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-processed" \
    --service-account="$SERVICE_ACCOUNT" \
    --set-env-vars="BQ_DATASET=forensic_fact_base" \
    --timeout=60s \
    --memory=512Mi \
    --quiet
cd ..
echo "[SUCCESS] PART 3 DEPLOYED. V10.5.1 IS LIVE."
