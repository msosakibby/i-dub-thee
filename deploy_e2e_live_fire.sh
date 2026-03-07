#!/bin/bash
set -e

echo "============================================================================"
echo " INITIATING END-TO-END LIVE-FIRE: THE GOLDEN RECORD HANDOFF"
echo "============================================================================"

echo "[SYSTEM] 0. Securing Local Workbench Dependencies..."
pip install reportlab --quiet

echo "[SYSTEM] 1. Forging a clean 'Golden Record' artifact..."
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

echo "[SYSTEM] 2. Dropping artifact into Layer 1 (gs://i-dub-thee-docs/input/)..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-docs/input/clean_receipt.pdf --quiet

echo "[SYSTEM] 3. Pipeline Activated. Awaiting Stage 1 (Fact Extraction) [15s]..."
sleep 15

echo "[SYSTEM] 4. Retrieving Stage 1 Telemetry (forensic-pipeline-router)..."
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=10

echo "[SYSTEM] 5. Awaiting Stage 2 (Analytical Orchestrator) [30s]..."
sleep 30

echo "[SYSTEM] 6. Retrieving Stage 2 Telemetry (layer2b-analytical-orchestrator)..."
gcloud functions logs read layer2b-analytical-orchestrator --region=us-central1 --limit=20

echo "============================================================================"
echo " [EXECUTION COMPLETE] AWAITING END-TO-END TELEMETRY REVIEW"
echo "============================================================================"
