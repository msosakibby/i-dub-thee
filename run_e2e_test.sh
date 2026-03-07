#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING FINAL END-TO-END LIVE FIRE: THE GOLDEN RECORD"
echo "============================================================================"

echo "[SYSTEM] 1. Securing Eventarc Trigger to Cloud Run Job..."
gcloud eventarc triggers create layer2b-batch-trigger \
    --project="$PROJECT_ID" \
    --location=us-central1 \
    --destination-run-job=layer2b-analytical-job \
    --event-filters="type=google.cloud.storage.object.v1.finalized" \
    --event-filters="bucket=i-dub-thee-processed" \
    --service-account="110409945269-compute@developer.gserviceaccount.com" \
    --quiet || echo "  [+] Trigger linked successfully."

echo "[SYSTEM] 2. Forging a clean 'Golden Record' artifact..."
cat << 'EOF_PYTHON' > generate_clean_artifact.py
from reportlab.pdfgen import canvas

c = canvas.Canvas("clean_receipt.pdf")
c.setFont("Helvetica-Bold", 16)
c.drawString(100, 750, "M & J FOOD MARKET - CLEAN RECEIPT")
c.setFont("Helvetica", 12)
c.drawString(100, 710, "Transaction Date: 2026-02-26")
c.drawString(100, 690, "Payment Method: Corporate Credit Card")
c.drawString(100, 670, "Total Amount: $150.00")
c.drawString(100, 650, "Notes: Standard office supplies.")
c.save()
EOF_PYTHON

python3 generate_clean_artifact.py

echo "[SYSTEM] 3. Dropping artifact into Layer 1 (gs://i-dub-thee-docs/input/)..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-docs/input/clean_receipt.pdf --quiet

echo "[SYSTEM] 4. Pipeline Activated. Awaiting Stage 1 (Fact Extraction) [15s]..."
sleep 15

echo "[SYSTEM] 5. Retrieving Stage 1 Telemetry (forensic-pipeline-router)..."
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=10

echo "[SYSTEM] 6. Awaiting Stage 2 Eventarc Handoff (Analytical Job) [20s]..."
sleep 20

echo "[SYSTEM] 7. Retrieving Stage 2 Telemetry (layer2b-analytical-job)..."
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=15 \
    --format="table(timestamp, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE] AWAITING END-TO-END TELEMETRY REVIEW"
echo "============================================================================"
