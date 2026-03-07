import os
import logging
from fastapi import FastAPI, Request, HTTPException
from google.cloud import bigquery
from src.forensic_router import execute_forensic_pipeline

# Initialize strict logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger("ForensicEngine")

app = FastAPI(title="Legal Forensics Engine - Layer 1 Ingestion")

# Environment Variable Binding
PROJECT_ID = os.environ.get("PROJECT_ID", "i-dub-thee")
ENV_MODE = os.environ.get("ENV_MODE", "DEV")
BQ_DATASET = "forensic_fact_base_dev" if ENV_MODE == "DEV" else "forensic_fact_base"
BQ_TABLE = "ingestion_ledger"

bq_client = bigquery.Client(project=PROJECT_ID)

async def check_idempotency(source_uri: str) -> bool:
    """Queries BigQuery to kill Eventarc retry loops."""
    query = f"""
        SELECT source_uri 
        FROM `{PROJECT_ID}.{BQ_DATASET}.{BQ_TABLE}`
        WHERE source_uri = @source_uri
        LIMIT 1
    """
    job_config = bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("source_uri", "STRING", source_uri)]
    )
    try:
        query_job = bq_client.query(query, job_config=job_config)
        results = query_job.result()
        return results.total_rows > 0
    except Exception as e:
        logger.error(f"Idempotency Check Failed: {e}")
        raise HTTPException(status_code=500, detail="Database integrity check failed.")

@app.post("/")
async def eventarc_receptor(request: Request):
    """The singular entrypoint for the serverless architecture."""
    headers = request.headers
    object_name = headers.get("ce-subject")
    bucket_name = headers.get("ce-source")
    
    if not object_name:
        return {"status": "ignored", "reason": "Not a valid Eventarc trigger."}

    clean_bucket = bucket_name.split('/')[-1] if bucket_name else ("i-dub-thee-forensic-vault-dev" if ENV_MODE == "DEV" else "i-dub-thee-forensic-vault")
    source_uri = f"gs://{clean_bucket}/{object_name}"
    
    logger.info(f"[{ENV_MODE}] INGESTION TRIGGERED: {source_uri}")

    # 1. Idempotency Gate
    is_duplicate = await check_idempotency(source_uri)
    if is_duplicate:
        logger.info(f"Idempotency Guard: {source_uri} exists. Killing retry.")
        return {"status": "success", "message": "Duplicate ignored safely."}

    logger.info(f"File cleared idempotency check. Handing off to AI Orchestrator...")
    
    # 2. PHYSICAL HANDOFF
    await execute_forensic_pipeline(source_uri)

    return {"status": "success", "message": "Payload routed through Iron Gate."}
