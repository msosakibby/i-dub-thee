#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING MASTER PATCH: NUCLEAR STATE CLEAR & NATIVE DOCKER DEPLOY"
echo "============================================================================"

echo "[SYSTEM] 1. Violently purging corrupted Cloud Run Job state..."
gcloud run jobs delete layer2b-analytical-job --region=us-central1 --project="$PROJECT_ID" --quiet || echo "  [-] Job already purged."

cd pristine_deployment_chamber

echo "[SYSTEM] 2. Re-Deploying Cloud Run Job from Deterministic Dockerfile..."
gcloud run jobs deploy layer2b-analytical-job \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --source=. \
    --task-timeout=540s \
    --memory=1024Mi \
    --quiet

cd ..

echo "============================================================================"
echo " INITIATING KINETIC BOUNCE TO RETRIGGER WORKFLOW"
echo "============================================================================"

echo "[SYSTEM] 3. Purging remote artifact to clear state..."
gcloud storage rm gs://i-dub-thee-processed/clean_receipt.pdf --quiet || echo "  [-] File already missing."

echo "[SYSTEM] 4. Uploading fresh artifact to Processed Vault..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 5. Awaiting Eventarc -> Workflow -> Cloud Run Job Handoff [45s]..."
sleep 45

echo "--- 6. LAYER 2B JOB TELEMETRY (Application Logs) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=15 \
    --format="table(timestamp, severity, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
