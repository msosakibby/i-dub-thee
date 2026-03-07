#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING GRAND FINALE: DEPLOY, BOUNCE, AND AUTOPSY"
echo "============================================================================"

PROJECT_ID=$(gcloud config get-value project)
export GOOGLE_CLOUD_PROJECT="$PROJECT_ID"

echo "[SYSTEM] 1. Pushing Layer 1.5 to Live GCP Environment..."
gcloud functions deploy forensic-pipeline-router \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=pipeline_router_entry \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-docs" \
    --timeout=300 \
    --memory=512MiB \
    --quiet

echo "[SYSTEM] 2. Executing Kinetic Bounce (Quarantine -> Input)..."
gcloud storage cp "gs://i-dub-thee-quarantine/2014-10-10 Great Lakes Energy Utility Bill.pdf" "gs://i-dub-thee-docs/input/2014-10-10 Great Lakes Energy Utility Bill.pdf" --quiet

echo "[SYSTEM] 3. Pipeline Activated. Awaiting Disputed Extraction (15 Seconds)..."
sleep 15

echo "[SYSTEM] 4. Triggering Autopsy Engine (JSON Diff & Markdown Gen)..."
python3 tools/quarantine_autopsy.py

echo "============================================================================"
echo " THE AUTOPSY REPORT:"
echo "============================================================================"
gcloud storage cat gs://i-dub-thee-master-filing-cabinet/Quarantine_Autopsy_Report.md

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
