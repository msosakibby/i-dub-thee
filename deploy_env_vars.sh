#!/bin/bash
set -e
set -o pipefail
export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
echo "[SYSTEM] Querying Document AI API for active Form Parser..."
DOCAI_RAW_NAME=$(gcloud documentai processors list --location=us --project="${PROJECT_ID}" --format="value(name)" --filter="displayName:forensic-form-parser" | head -n 1)
if [ -z "$DOCAI_RAW_NAME" ]; then
    echo "[!] FATAL: Could not locate 'forensic-form-parser' in project."
    exit 1
fi
DOCAI_PROCESSOR_ID=$(echo "${DOCAI_RAW_NAME}" | awk -F'/' '{print $NF}')
echo "[SYSTEM] Pushing differential update to forensic-pipeline-router..."
gcloud functions deploy forensic-pipeline-router \
    --gen2 \
    --region="${REGION}" \
    --project="${PROJECT_ID}" \
    --source=. \
    --update-env-vars="DOCAI_PROCESSOR_ID=${DOCAI_PROCESSOR_ID}"
