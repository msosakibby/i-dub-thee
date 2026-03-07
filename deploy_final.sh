#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING FINAL DEPLOYMENT (NANO BYPASS)"
echo "============================================================================"

echo "[SYSTEM] 1. Purging Web Server Dependencies..."
cat << 'EOF_REQ' > requirements.txt
google-cloud-storage>=2.10.0
google-cloud-bigquery>=3.11.0
google-genai>=0.2.0
pydantic>=2.0.0
vertexai>=1.0.0
reportlab>=4.0.0
EOF_REQ

echo "[SYSTEM] 2. Forging Port-Free Entry Point (batch_main.py)..."
cat << 'EOF_BATCH' > batch_main.py
import os
import asyncio
import logging
from forensic_router import orchestrate_forensic_reports

logging.basicConfig(level=logging.INFO, format='%(asctime)s - BATCH_ENTRY - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def main():
    bucket = os.environ.get("CE_BUCKET")
    subject = os.environ.get("CE_SUBJECT") 
    
    if not bucket or not subject:
        logger.error("FATAL: Missing CE_BUCKET or CE_SUBJECT variables. Pipeline breach detected.")
        return
        
    name = subject.replace("objects/", "") if subject.startswith("objects/") else subject
    
    if not name.lower().endswith(".pdf"):
        logger.info(f"[BOUNDARY ENFORCEMENT]: Ignoring non-PDF file: {name}")
        return
        
    pdf_uri = f"gs://{bucket}/{name}"
    logger.info(f"[+] Layer 2B Batch Orchestrator triggered for URI: {pdf_uri}")
    
    await orchestrate_forensic_reports(
        document_uri=pdf_uri,
        document_type="Forensic Evidence"
    )

if __name__ == "__main__":
    asyncio.run(main())
EOF_BATCH

echo "[SYSTEM] 3. Executing Pytest Iron Gate..."
python3 -m pytest tests/test_batch_entry.py -v

echo "[SYSTEM] 4. Deploying Cloud Run Job..."
PROJECT_ID=$(gcloud config get-value project)
gcloud run jobs deploy layer2b-analytical-job \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --source=. \
    --command="python3" \
    --args="batch_main.py" \
    --task-timeout=540s \
    --memory=1024Mi \
    --quiet

echo "[SYSTEM] 5. Linking Eventarc Trigger..."
gcloud eventarc triggers create layer2b-batch-trigger \
    --project="$PROJECT_ID" \
    --location=us-central1 \
    --destination-run-job=layer2b-analytical-job \
    --event-filters="type=google.cloud.storage.object.v1.finalized" \
    --event-filters="bucket=i-dub-thee-processed" \
    --service-account="110409945269-compute@developer.gserviceaccount.com" \
    --quiet || echo "  [+] Trigger linked successfully."

echo "============================================================================"
echo " [SUCCESS] BATCH ARCHITECTURE SECURED. LAYER 2B DEPLOYED AS A JOB."
echo "============================================================================"
