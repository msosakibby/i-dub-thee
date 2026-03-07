#!/bin/bash
set -e

echo "============================================================================"
echo " INITIATING MASTER PATCH: WORKBENCH CONTAMINATION PURGE"
echo "============================================================================"

echo "[SYSTEM] 1. Forging the .gcloudignore Iron Gate..."
cat << 'EOF_IGNORE' > .gcloudignore
# Exclude local environments and caches
forensic_env/
venv/
__pycache__/
*.pyc

# EXCLUDE CONTAMINATING ARTIFACTS
Dockerfile
docker-compose.yml
src/cloud_run_main.py
generate_clean_artifact.py
clean_receipt.pdf
EOF_IGNORE

echo "[SYSTEM] 2. Re-Deploying Layer 2B Analytical Orchestrator (Native Buildpack)..."
PROJECT_ID=$(gcloud config get-value project)
gcloud functions deploy layer2b-analytical-orchestrator \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=layer2b_analytical_entry \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-processed" \
    --timeout=540 \
    --memory=1024MiB \
    --quiet

echo "============================================================================"
echo " [SUCCESS] CONTAMINATION PURGED. LAYER 2B DEPLOYED NATIVELY."
echo "============================================================================"
