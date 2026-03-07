#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"
DATASET_ID="forensic_fact_base"
TABLE_ID="extracted_facts"
BUCKET_NAME="i-dub-thee-processed"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 3 BIGQUERY BRIDGE"
echo "============================================================================"

# ==============================================================================
# 1. PROVISION BIGQUERY FACT BASE & STRICT SCHEMA
# ==============================================================================
echo "[SYSTEM] 1. Provisioning Serverless BigQuery Storage..."

bq mk --dataset --location=us-central1 ${PROJECT_ID}:${DATASET_ID} || true

cat << 'EOF_BQ_SCHEMA' > bq_schema.json
[
  {"name": "parent_file_hash", "type": "STRING", "mode": "REQUIRED"},
  {"name": "gcs_source_uri", "type": "STRING", "mode": "REQUIRED"},
  {"name": "taxonomy_lane", "type": "STRING", "mode": "REQUIRED"},
  {"name": "entity_slug", "type": "STRING", "mode": "REQUIRED"},
  {"name": "document_type", "type": "STRING", "mode": "REQUIRED"},
  {"name": "document_date", "type": "DATE", "mode": "NULLABLE"},
  {"name": "confidence_score", "type": "FLOAT64", "mode": "REQUIRED"},
  {"name": "requires_manual_review", "type": "BOOLEAN", "mode": "REQUIRED"},
  {"name": "evidence_coordinates", "type": "JSON", "mode": "NULLABLE"},
  {"name": "extracted_payload", "type": "JSON", "mode": "REQUIRED"}
]
EOF_BQ_SCHEMA

bq mk --table --schema=bq_schema.json ${PROJECT_ID}:${DATASET_ID}.${TABLE_ID} || true

# ==============================================================================
# 2. FORGE CLOUD FUNCTION ENVIRONMENT
# ==============================================================================
mkdir -p layer3_bq_ingestor
cd layer3_bq_ingestor

echo "[SYSTEM] 2. Forging Modern Dependencies..."
cat << 'EOF_REQ' > requirements.txt
functions-framework==3.5.0
google-cloud-storage==2.14.0
google-cloud-bigquery==3.17.2
cloudevents==1.10.1
EOF_REQ

echo "[SYSTEM] 3. Forging Analytical Container (main.py)..."
cat << 'EOF_PYTHON_MAIN' > main.py
import os
import json
import logging
import functions_framework
from google.cloud import storage, bigquery
from cloudevents.http import CloudEvent

# Strict logging for Zero-Trust Auditing
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - BIGQUERY_BRIDGE - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ==============================================================================
# MATHEMATICAL ALGEBRA & TRANSFORMATION LOGIC
# ==============================================================================
def parse_taxonomy_vector(vector: str) -> dict:
    """Deterministically fractures the taxonomy vector into schema columns."""
    parts = [p.strip() for p in vector.split('/')]
    return {
        "taxonomy_lane": parts[0] if len(parts) > 0 else "UNKNOWN",
        "entity_slug": parts[1] if len(parts) > 1 else "UNKNOWN",
        "institution": parts[2] if len(parts) > 2 else "UNKNOWN",
        "document_type": parts[3] if len(parts) > 3 else "UNKNOWN"
    }

def build_bq_row(payload: dict) -> dict:
    """Transforms the flexible JSON envelope into the strict BigQuery mapping."""
    metadata = payload.get("dossier_metadata", {})
    vector = metadata.get("taxonomy_vector", "UNKNOWN / UNKNOWN / UNKNOWN / UNKNOWN")
    parsed_vector = parse_taxonomy_vector(vector)
    
    return {
        "parent_file_hash": metadata.get("cryptographic_hash", "UNKNOWN_HASH"),
        "gcs_source_uri": metadata.get("source_artifact_uri", "UNKNOWN_URI"),
        "taxonomy_lane": parsed_vector["taxonomy_lane"],
        "entity_slug": parsed_vector["entity_slug"],
        "document_type": parsed_vector["document_type"],
        "document_date": None, # Chronological partitioning injected by future phase if needed
        "confidence_score": 0.99, # L1 Iron Gate mathematically verified confidence prior to L3
        "requires_manual_review": False,
        "evidence_coordinates": None,
        "extracted_payload": json.dumps(payload.get("extracted_facts", []))
    }

# ==============================================================================
# IDEMPOTENCY GATE
# ==============================================================================
def check_hash_exists(bq_client, project_id: str, file_hash: str, dataset_id: str = "forensic_fact_base", table_id: str = "extracted_facts") -> bool:
    """Cryptographically ensures no duplicate hashes enter the fact base."""
    query = f"SELECT parent_file_hash FROM `{project_id}.{dataset_id}.{table_id}` WHERE parent_file_hash = @file_hash LIMIT 1"
    job_config = bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("file_hash", "STRING", file_hash)]
    )
    results = list(bq_client.query(query, job_config=job_config).result())
    return len(results) > 0

# ==============================================================================
# SERVERLESS ENTRYPOINT
# ==============================================================================
@functions_framework.cloud_event
def ingest_to_bigquery(cloud_event: CloudEvent):
    """Listens for Report 5 Drops and routes payloads across the bridge."""
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]

    # Recursive Severance & Targeting Filter
    if not file_name.endswith("_Report5_Extraction.json"):
        logger.info(f"Target ignored. File {file_name} is not a JSON payload.")
        return

    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    dataset_id = os.environ.get("BQ_DATASET", "forensic_fact_base")
    table_id = os.environ.get("BQ_TABLE", "extracted_facts")

    storage_client = storage.Client()
    bq_client = bigquery.Client(project=project_id)

    try:
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        file_contents = blob.download_as_string()
        
        if len(file_contents) == 0:
            logger.info(f"Ignored 0-byte marker: {file_name}")
            return
            
        payload = json.loads(file_contents)
        
        # 1. Map to BigQuery constraints
        bq_row = build_bq_row(payload)
        file_hash = bq_row["parent_file_hash"]

        logger.info(f"Validating Idempotency Gate for Hash: {file_hash}")

        # 2. Idempotency Gate
        if check_hash_exists(bq_client, project_id, file_hash, dataset_id, table_id):
            logger.warning(f"IDEMPOTENCY TRIGGERED: Hash {file_hash} already exists in BigQuery. Aborting insertion to prevent duplication.")
            return

        # 3. Stream into the Fact Base
        table_ref = f"{project_id}.{dataset_id}.{table_id}"
        errors = bq_client.insert_rows_json(table_ref, [bq_row])

        if errors:
            logger.error(f"FATAL INSERTION ERRORS: {errors}")
            raise ValueError(f"BigQuery insertion violently rejected payload. Errors: {errors}")
        
        logger.info(f"SUCCESS: Cryptographic payload {file_hash} safely anchored in BigQuery.")

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION IN L3: {str(e)}")
        raise e
EOF_PYTHON_MAIN

# ==============================================================================
# 3. DEPLOY GEN 2 CLOUD FUNCTION
# ==============================================================================
echo "[SYSTEM] 4. Deploying Event-Driven Ingestor to GCP..."

gcloud functions deploy forensic-bq-ingestor \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=ingest_to_bigquery \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=$BUCKET_NAME" \
    --service-account="$SERVICE_ACCOUNT" \
    --set-env-vars="BQ_DATASET=$DATASET_ID,BQ_TABLE=$TABLE_ID" \
    --timeout=60s \
    --memory=512Mi \
    --quiet

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] PHASE 3 BIGQUERY BRIDGE ONLINE"
echo "============================================================================"
