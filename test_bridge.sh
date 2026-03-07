#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING BRIDGE VALIDATION STRIKE"
echo "============================================================================"

echo "[SYSTEM] 1. Manually injecting PDF into the Processed Vault..."
gcloud storage cp gs://i-dub-thee-quarantine/clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 2. Awaiting Eventarc -> Workflow -> Cloud Run Job Handoff [35s]..."
sleep 35

echo "--- 3. WORKFLOW TELEMETRY (Did it trigger and route?) ---"
gcloud workflows executions list layer2b-workflow --location=us-central1 --project="$PROJECT_ID" --limit=2

echo "--- 4. LAYER 2B JOB TELEMETRY (Did the container execute?) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=10 \
    --format="table(timestamp, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
