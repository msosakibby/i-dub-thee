#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING MASTER PATCH: FORTIFYING CLEAN ROOM DEPENDENCIES"
echo "============================================================================"

cd pristine_deployment_chamber

echo "[SYSTEM] 1. Violently overwriting requirements.txt with Vertex SDK..."
cat << 'EOF_REQ' > requirements.txt
google-cloud-storage>=2.10.0
google-cloud-bigquery>=3.11.0
google-cloud-aiplatform>=1.43.0
google-genai>=0.2.0
pydantic>=2.0.0
reportlab>=4.0.0
EOF_REQ

echo "[SYSTEM] 2. Re-Deploying Cloud Run Job..."
gcloud run jobs deploy layer2b-analytical-job \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --source=. \
    --command="python3" \
    --args="main.py" \
    --task-timeout=540s \
    --memory=1024Mi \
    --quiet

cd ..

echo "============================================================================"
echo " INITIATING KINETIC BOUNCE TO RETRIGGER WORKFLOW"
echo "============================================================================"

echo "[SYSTEM] 3. Bouncing PDF to Trigger the Native Bridge..."
gcloud storage cp gs://i-dub-thee-processed/clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 4. Awaiting Container Execution [20s]..."
sleep 20

echo "--- 5. LAYER 2B JOB TELEMETRY (Application Logs) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job AND severity>=WARNING" \
    --project="$PROJECT_ID" \
    --limit=10 \
    --format="table(timestamp, severity, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
