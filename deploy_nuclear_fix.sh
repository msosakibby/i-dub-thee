#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING NUCLEAR FIX: ENFORCING STRICT DEPENDENCY MANIFEST"
echo "============================================================================"

echo "[SYSTEM] 1. Violently overwriting requirements.txt..."
cat << 'EOF_REQ' > requirements.txt
functions-framework==3.*
google-cloud-storage>=2.10.0
google-cloud-bigquery>=3.11.0
google-genai>=0.2.0
pydantic>=2.0.0
vertexai>=1.0.0
reportlab>=4.0.0
EOF_REQ

echo "[SYSTEM] 2. Re-Deploying Layer 2B Analytical Orchestrator..."
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
echo " [SUCCESS] CONTAINER HEALTHCHECK SECURED. LAYER 2B DEPLOYED."
echo "============================================================================"
