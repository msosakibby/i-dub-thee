#!/bin/bash
# ==============================================================================
# LEGAL FORENSICS ENGINE - HYPOTHESIS SUBMISSION UTILITY
# DIRECTIVE: Event-Driven Invocation via Google Cloud Storage
# ==============================================================================
set -o errexit
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export VAULT_BUCKET="${PROJECT_ID}-forensic-vault"

echo "============================================================================"
echo " FORENSIC HYPOTHESIS DEPLOYMENT"
echo "============================================================================"

read -p "Enter your investigative hypothesis: " HYPOTHESIS

# Generate unique payload identifier
TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
FILENAME="hypothesis_${TIMESTAMP}.json"

# Construct the JSON payload
cat << EOF > "${FILENAME}"
{
  "natural_language_query": "${HYPOTHESIS}",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "[SYSTEM] Pushing payload to isolated investigations/ path..."
gcloud storage cp "${FILENAME}" "gs://${VAULT_BUCKET}/investigations/"

# Teardown local artifact
rm "${FILENAME}"

echo "[SUCCESS] Hypothesis deployed. The Engine is currently synthesizing the report."
echo "Monitor logs: gcloud functions logs read forensic-hypothesis-engine --limit=50"
echo "Check archive: gcloud storage ls gs://${PROJECT_ID}-master-filing-cabinet/reports/"
echo "============================================================================"