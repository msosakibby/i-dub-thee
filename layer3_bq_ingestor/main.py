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
# ZERO-TRUST ROUTING & IDEMPOTENCY SUSPENSION
# ==============================================================================
def determine_routing_directives(file_uri: str) -> dict:
    """Inspects the URI for the Cryptographic Filename Bypass."""
    is_sandbox = "[SANDBOX]" in file_uri
    return {
        "is_sandbox": is_sandbox,
        "target_table": "sandbox_extracted_facts" if is_sandbox else "extracted_facts"
    }

def enforce_idempotency(bq_client, project_id: str, dataset_id: str, target_table: str, file_hash: str, is_sandbox: bool) -> bool:
    """
    Returns True if it is safe to proceed with database insertion.
    Returns False if a duplicate hash is found in a production environment.
    """
    if is_sandbox:
        logger.warning(f"SANDBOX MODE ACTIVE: Idempotency suspended for hash {file_hash}. Overwrites permitted.")
        return True # Safe to proceed, bypass idempotency
        
    query = f"SELECT parent_file_hash FROM `{project_id}.{dataset_id}.{target_table}` WHERE parent_file_hash = @file_hash LIMIT 1"
    job_config = bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("file_hash", "STRING", file_hash)]
    )
    results = list(bq_client.query(query, job_config=job_config).result())
    
    if len(results) > 0:
        return False # Duplicate exists, CANNOT proceed
        
    return True # Novel hash, safe to proceed

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

    storage_client = storage.Client()
    bq_client = bigquery.Client(project=project_id)

    try:
        # Determine Routing Path (Prod vs Sandbox)
        full_uri = f"gs://{bucket_name}/{file_name}"
        routing = determine_routing_directives(full_uri)
        target_table = routing["target_table"]
        is_sandbox = routing["is_sandbox"]

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

        logger.info(f"Validating Routing and Idempotency for Hash: {file_hash}")

        # 2. Idempotency Gate (with Sandbox Bypass)
        safe_to_insert = enforce_idempotency(bq_client, project_id, dataset_id, target_table, file_hash, is_sandbox)
        
        if not safe_to_insert:
            logger.warning(f"IDEMPOTENCY TRIGGERED: Hash {file_hash} already exists in {target_table}. Aborting insertion.")
            return

        # 3. Stream into the specific Fact Base Table
        table_ref = f"{project_id}.{dataset_id}.{target_table}"
        errors = bq_client.insert_rows_json(table_ref, [bq_row])

        if errors:
            logger.error(f"FATAL INSERTION ERRORS in {target_table}: {errors}")
            raise ValueError(f"BigQuery insertion violently rejected payload. Errors: {errors}")
        
        mode_str = "SANDBOX" if is_sandbox else "PRODUCTION"
        logger.info(f"SUCCESS ({mode_str}): Cryptographic payload {file_hash} safely anchored in {target_table}.")

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION IN L3: {str(e)}")
        raise e
