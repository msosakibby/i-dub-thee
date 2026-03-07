#!/bin/bash
set -e

cd pristine_deployment_chamber

cat << 'EOF_MAIN_PYTHON' > main.py
import os
import sys
import logging
import asyncio
from google.cloud import storage

logging.basicConfig(level=logging.INFO, format='%(asctime)s - CONTAINER_ENTRY - %(levelname)s - %(message)s')
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
        logger.error("FATAL: Missing CE_BUCKET or CE_SUBJECT variables.")
        sys.exit(1)

    # ==========================================================================
    # ZERO-TRUST RECURSIVE SEVERANCE GATE
    # ==========================================================================
    valid_extensions = ('.pdf', '.jpg', '.jpeg', '.png')
    if not subject_name.lower().endswith(valid_extensions) or "_Report" in subject_name:
        logger.info(f"[LOOP SEVERED] Ignoring secondary artifact: {subject_name}")
        sys.exit(0)

    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(subject_name)
        
        file_bytes = blob.download_as_bytes()
        
        # Protect against 0-byte directory markers
        if len(file_bytes) == 0:
            logger.info(f"[LOOP SEVERED] Ignoring 0-byte directory marker: {subject_name}")
            sys.exit(0)
        
        logger.info("Executing 6-Part asynchronous cognitive engine with isolated threads...")
        payloads = asyncio.run(run_concurrent_forensics(project_id, file_bytes))
        
        logger.info("Anchoring artifacts to Deep Taxonomy Storage...")
        persist_forensic_artifacts(bucket, subject_name, payloads)
        
        logger.info("Layer 2B Execution Complete. Artifacts safely anchored. Exiting cleanly.")
        sys.exit(0)

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION: {str(e)}")
        sys.exit(1)
EOF_MAIN_PYTHON

echo "[SYSTEM] Deploying Fortified Cloud Run Job (Kill Switch Active)..."
gcloud run jobs deploy layer2b-analytical-job \
    --source . \
    --region us-central1 \
    --quiet

echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] RECURSIVE LOOP MATHEMATICALLY SEVERED"
echo "============================================================================"
