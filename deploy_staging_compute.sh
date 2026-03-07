#!/bin/bash
set -e

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING STAGING COMPUTE DEPLOYMENT (1:1 MIRROR)"
echo "============================================================================"

# ------------------------------------------------------------------------------
# 1. LAYER 1: STAGING ROUTER
# ------------------------------------------------------------------------------
echo "[SYSTEM] 1. Cloning and Patching Layer 1 (Intake Router)..."
rm -rf staging_layer1_intake
cp -r layer1_intake staging_layer1_intake
cd staging_layer1_intake

# Surgically patch the hardcoded production buckets to target the staging buckets
sed -i 's/"i-dub-thee-processed"/"i-dub-thee-staging-processed"/g' main.py
sed -i 's/"i-dub-thee-quarantine"/"i-dub-thee-staging-quarantine"/g' main.py

gcloud functions deploy forensic-pipeline-router-staging \
    --gen2 \
    --runtime=python311 \
    --region=${REGION} \
    --source=. \
    --entry-point=process_document \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=${PROJECT_ID}-staging-docs" \
    --service-account=${SERVICE_ACCOUNT} \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=${PROJECT_ID}" \
    --timeout=540s \
    --memory=1024MB \
    --quiet
cd ..

# ------------------------------------------------------------------------------
# 2. LAYER 2B: STAGING ANALYTICAL ORCHESTRATOR
# ------------------------------------------------------------------------------
echo "[SYSTEM] 2. Cloning and Deploying Layer 2B (Cloud Run Job)..."
rm -rf staging_deployment_chamber
cp -r pristine_deployment_chamber staging_deployment_chamber
cd staging_deployment_chamber

# Layer 2B natively inherits the bucket name from Eventarc (CE_BUCKET), so no code changes are required!
gcloud run jobs deploy layer2b-analytical-job-staging \
    --source . \
    --region ${REGION} \
    --service-account ${SERVICE_ACCOUNT} \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=${PROJECT_ID}" \
    --max-retries 0 \
    --task-timeout 600s \
    --memory 2Gi \
    --quiet

# Link Eventarc trigger specifically to the staging bucket
gcloud eventarc triggers create layer2b-staging-trigger \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --destination-run-job=layer2b-analytical-job-staging \
    --event-filters="type=google.cloud.storage.object.v1.finalized" \
    --event-filters="bucket=${PROJECT_ID}-staging-processed" \
    --service-account=${SERVICE_ACCOUNT} \
    --quiet || echo "  [+] Eventarc Trigger already exists."
cd ..

# ------------------------------------------------------------------------------
# 3. LAYER 3: STAGING BIGQUERY INGESTOR
# ------------------------------------------------------------------------------
echo "[SYSTEM] 3. Cloning and Deploying Layer 3 (BigQuery Bridge)..."
rm -rf staging_layer3_ingestor
cp -r layer3_bq_ingestor staging_layer3_ingestor
cd staging_layer3_ingestor

# We dynamically repoint the BQ_DATASET environment variable
gcloud functions deploy forensic-bq-ingestor-staging \
    --gen2 \
    --runtime=python311 \
    --region=${REGION} \
    --source=. \
    --entry-point=ingest_to_bigquery \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=${PROJECT_ID}-staging-processed" \
    --service-account=${SERVICE_ACCOUNT} \
    --set-env-vars="BQ_DATASET=forensic_fact_base_staging" \
    --timeout=60s \
    --memory=512Mi \
    --quiet
cd ..

echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] STAGING MIRROR IS 100% ONLINE."
echo " Drop test files into: gs://${PROJECT_ID}-staging-docs/"
echo "============================================================================"
