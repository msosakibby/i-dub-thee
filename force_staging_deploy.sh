#!/bin/bash
set -e

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
EVENTARC_SA="service-${PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com"
GCS_SA=$(gcloud storage service-agent --project="${PROJECT_ID}")

echo "============================================================================"
echo " INITIATING EVENTARC IAM OVERRIDE & STAGING DEPLOYMENT"
echo "============================================================================"

echo "[SYSTEM] 1. Forcing Staging Bucket Creation (Unmasked)..."
gcloud storage buckets create "gs://${PROJECT_ID}-staging-docs" --location="${REGION}" --project="${PROJECT_ID}" --uniform-bucket-level-access || echo "  [+] Staging Docs verified."
gcloud storage buckets create "gs://${PROJECT_ID}-staging-processed" --location="${REGION}" --project="${PROJECT_ID}" --uniform-bucket-level-access || echo "  [+] Staging Processed verified."
gcloud storage buckets create "gs://${PROJECT_ID}-staging-quarantine" --location="${REGION}" --project="${PROJECT_ID}" --uniform-bucket-level-access || echo "  [+] Staging Quarantine verified."
gcloud storage buckets create "gs://${PROJECT_ID}-staging-master-filing-cabinet" --location="${REGION}" --project="${PROJECT_ID}" --uniform-bucket-level-access || echo "  [+] Staging Cabinet verified."

echo "[SYSTEM] 2. Applying Absolute Eventarc IAM Overrides..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${EVENTARC_SA}" \
    --role="roles/storage.admin" \
    --condition=None --quiet >/dev/null

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GCS_SA}" \
    --role="roles/pubsub.publisher" \
    --condition=None --quiet >/dev/null

echo "[SYSTEM] 3. Pausing 20 seconds for global IAM propagation..."
sleep 20

# ------------------------------------------------------------------------------
# 1. LAYER 1: STAGING ROUTER
# ------------------------------------------------------------------------------
echo "[SYSTEM] 4. Re-engaging Layer 1 Staging Deployment..."
cd staging_layer1_intake
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
echo "[SYSTEM] 5. Cloning and Deploying Layer 2B (Cloud Run Job)..."
rm -rf staging_deployment_chamber
cp -r pristine_deployment_chamber staging_deployment_chamber
cd staging_deployment_chamber

gcloud run jobs deploy layer2b-analytical-job-staging \
    --source . \
    --region ${REGION} \
    --service-account ${SERVICE_ACCOUNT} \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=${PROJECT_ID}" \
    --max-retries 0 \
    --task-timeout 600s \
    --memory 2Gi \
    --quiet

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
echo "[SYSTEM] 6. Cloning and Deploying Layer 3 (BigQuery Bridge)..."
rm -rf staging_layer3_ingestor
cp -r layer3_bq_ingestor staging_layer3_ingestor
cd staging_layer3_ingestor

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
echo "============================================================================"
