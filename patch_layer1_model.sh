#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER PATCH: ROUTING LAYER 1 TO STABLE MODEL"
echo "============================================================================"

cd layer1_intake

echo "[SYSTEM] 1. Patching main.py to use gemini-2.5-pro and us-central1..."
sed -i 's/gemini-3.1-pro-preview/gemini-2.5-pro/g' main.py
sed -i 's/location="global"/location="us-central1"/g' main.py

echo "[SYSTEM] 2. Re-Deploying Cloud Function (Layer 1 Intake)..."
gcloud functions deploy forensic-pipeline-router \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=process_document \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-docs" \
    --service-account="$SERVICE_ACCOUNT" \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=$PROJECT_ID" \
    --timeout=540s \
    --memory=1024MB \
    --quiet

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] LAYER 1 IRON GATE IS ACTIVE"
echo "============================================================================"
