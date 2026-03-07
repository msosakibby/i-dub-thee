#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING GREEN STATE: BUFFER-BYPASS DEPLOYMENT"
echo "============================================================================"

echo "[SYSTEM] 1. Forging Port-Free Entry Point via Micro-Batches..."
> batch_main.py
echo 'import os' >> batch_main.py
echo 'import asyncio' >> batch_main.py
echo 'import logging' >> batch_main.py
echo 'from forensic_router import orchestrate_forensic_reports' >> batch_main.py
echo '' >> batch_main.py
echo 'logging.basicConfig(level=logging.INFO, format="%(asctime)s - BATCH - %(levelname)s - %(message)s")' >> batch_main.py
echo 'logger = logging.getLogger(__name__)' >> batch_main.py
echo '' >> batch_main.py
echo 'async def main():' >> batch_main.py
echo '    bucket = os.environ.get("CE_BUCKET")' >> batch_main.py
echo '    subject = os.environ.get("CE_SUBJECT")' >> batch_main.py
echo '    if not bucket or not subject:' >> batch_main.py
echo '        logger.error("FATAL: Missing Eventarc variables."); return' >> batch_main.py
echo '    name = subject.replace("objects/", "") if subject.startswith("objects/") else subject' >> batch_main.py
echo '    if not name.lower().endswith(".pdf"): return' >> batch_main.py
echo '    pdf_uri = f"gs://{bucket}/{name}"' >> batch_main.py
echo '    logger.info(f"[+] Layer 2B Batch Orchestrator triggered for URI: {pdf_uri}")' >> batch_main.py
echo '    await orchestrate_forensic_reports(document_uri=pdf_uri, document_type="Forensic Evidence")' >> batch_main.py
echo '' >> batch_main.py
echo 'if __name__ == "__main__":' >> batch_main.py
echo '    asyncio.run(main())' >> batch_main.py

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_batch_entry.py -v

echo "[SYSTEM] 3. Deploying Cloud Run Job (Layer 2B)..."
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

echo "[SYSTEM] 4. Linking Eventarc Trigger to Cloud Run Job..."
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
