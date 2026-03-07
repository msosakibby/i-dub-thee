#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER PATCH: LAYER 2B CONTAINER ENTRYPOINT"
echo "============================================================================"

cd pristine_deployment_chamber

echo "[SYSTEM] 1. Forging compliant main.py to bridge Buildpack to Forensic Router..."
cat << 'EOF_MAIN_PYTHON' > main.py
import os
import sys
import logging
import asyncio
from google.cloud import storage

# Strict logging for Zero-Trust Auditing
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - CONTAINER_ENTRY - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

try:
    from forensic_router import run_concurrent_forensics, persist_forensic_artifacts
except ImportError as e:
    logger.error(f"FATAL IMPORT ERROR: {str(e)}")
    sys.exit(1)

if __name__ == "__main__":
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    bucket_name = os.environ.get("CE_BUCKET")
    subject_name = os.environ.get("CE_SUBJECT")

    if not bucket_name or not subject_name:
        logger.error("FATAL: Missing CE_BUCKET or CE_SUBJECT environment variables.")
        sys.exit(1)

    logger.info(f"Layer 2B Awakened. Target: gs://{bucket_name}/{subject_name}")

    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(subject_name)
        
        file_bytes = blob.download_as_bytes()
        
        # Execute concurrent AI
        logger.info("Executing asynchronous cognitive engine...")
        payloads = asyncio.run(run_concurrent_forensics(project_id, file_bytes))
        
        # Persist to disk
        logger.info("Anchoring artifacts to Google Cloud Storage...")
        persist_forensic_artifacts(bucket, subject_name, payloads)
        
        logger.info("Layer 2B Execution Complete. Files anchored. Exiting cleanly.")
        sys.exit(0)

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION: {str(e)}")
        sys.exit(1)
EOF_MAIN_PYTHON

echo "[SYSTEM] 2. Re-Deploying Fortified Cloud Run Job..."
gcloud run jobs deploy layer2b-analytical-job \
    --source . \
    --region us-central1 \
    --service-account "$SERVICE_ACCOUNT" \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=$PROJECT_ID" \
    --max-retries 0 \
    --task-timeout 600s \
    --memory 2Gi \
    --quiet

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] LAYER 2B ENTRYPOINT ALIGNED"
echo "============================================================================"
