#!/bin/bash
set -e
echo "[SYSTEM] Compiling and Deploying to DEV Sandbox via Dockerfile..."

gcloud run deploy forensic-pipeline-router-dev \
    --source . \
    --region us-central1 \
    --project i-dub-thee \
    --service-account forensic-engine-sa-dev@i-dub-thee.iam.gserviceaccount.com \
    --set-env-vars ENV_MODE=DEV \
    --no-allow-unauthenticated \
    --quiet

echo "============================================================================"
echo " [SUCCESS] DOCKER CONTAINER DEPLOYED TO CLOUD RUN DEV ENVIRONMENT."
echo "============================================================================"
