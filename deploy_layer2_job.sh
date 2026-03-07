#!/bin/bash
set -e
echo "[SYSTEM] Compiling and Deploying to DEV Sandbox via Dockerfile..."

gcloud run jobs deploy forensic-rules-engine-dev \
    --source . \
    --region us-central1 \
    --project i-dub-thee \
    --service-account forensic-engine-sa-dev@i-dub-thee.iam.gserviceaccount.com \
    --set-env-vars ENV_MODE=DEV,REGISTRY_PATH=rules/rules_registry.yaml,PROJECT_ID=i-dub-thee \
    --command "python3" \
    --args "src/job_runner.py" \
    --task-timeout 3600s \
    --quiet

echo "============================================================================"
echo " [SUCCESS] FORENSIC RULES ENGINE (LAYER 2) JOB DEPLOYED."
echo "============================================================================"
