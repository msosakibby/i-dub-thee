#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER PATCH: WORKFLOW IAM AUTHORIZATION"
echo "============================================================================"

echo "[SYSTEM] 1. Binding strict v2 execution roles to the Service Account..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/run.invoker" \
    --condition=None \
    --quiet >/dev/null

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/workflows.admin" \
    --condition=None \
    --quiet >/dev/null

echo "============================================================================"
echo " INITIATING KINETIC BOUNCE TO RETRIGGER PIPELINE"
echo "============================================================================"

echo "[SYSTEM] 2. Purging remote artifact to clear state..."
gcloud storage rm gs://i-dub-thee-processed/clean_receipt.pdf --quiet || echo "  [-] File already missing."

echo "[SYSTEM] 3. Uploading fresh artifact to Processed Vault..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 4. Awaiting Workflow -> Job Propagation [40s]..."
sleep 40

echo "--- 5. LATEST WORKFLOW EXECUTIONS (Did it succeed?) ---"
gcloud workflows executions list layer2b-workflow --location=us-central1 --project="$PROJECT_ID" --limit=2

echo "--- 6. LAYER 2B JOB TELEMETRY (Application Logs) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job AND severity>=INFO" \
    --project="$PROJECT_ID" \
    --limit=25 \
    --format="table(timestamp, severity, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
