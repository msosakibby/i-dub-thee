#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export SERVICE_NAME="forensic-pipeline-router"
echo "--- FETCHING REVISION HISTORY ---"
gcloud run revisions list --service="${SERVICE_NAME}" --region="${REGION}" --project="${PROJECT_ID}" --sort-by="~metadata.creationTimestamp" --limit=5
echo ""
read -p "Enter the REVISION ID to rollback to: " TARGET_REVISION
gcloud run services update-traffic "${SERVICE_NAME}" --region="${REGION}" --project="${PROJECT_ID}" --to-revisions="${TARGET_REVISION}=100"
echo "--- ROLLBACK COMPLETE ---"
