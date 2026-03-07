#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING HARD RETRIGGER: DELETE & RE-UPLOAD"
echo "============================================================================"

echo "[SYSTEM] 1. Purging remote artifact to clear state..."
gcloud storage rm gs://i-dub-thee-processed/clean_receipt.pdf --quiet || echo "  [-] File already missing."

echo "[SYSTEM] 2. Forging fresh local Golden Record..."
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

echo "[SYSTEM] 3. Uploading fresh artifact to Processed Vault..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 4. Awaiting Eventarc -> Workflow -> Cloud Run Job Handoff [30s]..."
sleep 30

echo "--- 5. WORKFLOW EXECUTIONS (Did the bridge fire?) ---"
gcloud workflows executions list layer2b-workflow --location=us-central1 --project="$PROJECT_ID" --limit=2

echo "--- 6. LAYER 2B JOB TELEMETRY (Application Logs) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=15 \
    --format="table(timestamp, severity, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
