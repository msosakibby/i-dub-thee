#!/bin/bash
set -e

echo "============================================================================"
echo " INITIATING LIVE-FIRE: PHYSICAL I/O RETRY"
echo "============================================================================"

PROJECT_ID=$(gcloud config get-value project)

echo "[SYSTEM] 1. Forging the Quarantine Vault (If Missing)..."
gcloud storage buckets create gs://i-dub-thee-quarantine --project="$PROJECT_ID" --location=us-central1 2>/dev/null || echo "  [+] Quarantine bucket confirmed."

echo "[SYSTEM] 2. Re-triggering the Eventarc Pipeline (Copy-to-Self)..."
gcloud storage cp "gs://i-dub-thee-docs/input/2014-10-10 Great Lakes Energy Utility Bill.pdf" "gs://i-dub-thee-docs/input/2014-10-10 Great Lakes Energy Utility Bill.pdf"

echo "[SYSTEM] 3. Pipeline Activated. Awaiting Dual-LLM Extraction (15 Seconds)..."
sleep 15

echo "[SYSTEM] 4. Retrieving Live-Fire Telemetry..."
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=20

echo "============================================================================"
echo " [EXECUTION COMPLETE] AWAITING TELEMETRY REVIEW"
echo "============================================================================"
