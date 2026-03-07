#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING MASTER PATCH: DETERMINISTIC DOCKER CONTAINER"
echo "============================================================================"

cd pristine_deployment_chamber

echo "[SYSTEM] 1. Forging the Deterministic Dockerfile..."
cat << 'EOF_DOCKER' > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENTRYPOINT ["python3", "main.py"]
EOF_DOCKER

echo "[SYSTEM] 2. Re-Deploying Cloud Run Job (Native Container)..."
gcloud run jobs deploy layer2b-analytical-job \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --source=. \
    --task-timeout=540s \
    --memory=1024Mi \
    --clear-command \
    --clear-args \
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
