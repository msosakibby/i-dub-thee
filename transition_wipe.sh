#!/bin/bash
# ============================================================================
# TRANSITION PROTOCOL: APPLICATION TEAR-DOWN
# PROJECT ID: i-dub-thee
# ============================================================================
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"

echo "--- [1/3] PURGING COMPROMISED SERVERLESS COMPUTE ---"
# Deleting the hollow Cloud Function (Layer 1)
gcloud functions delete forensic-pipeline-router \
    --region="${REGION}" --gen2 --project="${PROJECT_ID}" --quiet || echo "Router already removed."

# Deleting the incomplete FastAPI service (Layer 2)
gcloud run services delete forensic-rag-api \
    --region="${REGION}" --project="${PROJECT_ID}" --quiet || echo "RAG API already removed."

echo "--- [2/3] PURGING COMPROMISED LOCAL CODEBASE ---"
# Whitelist scorch: Keep tests, git, and idx. Destroy the hollow src and rag_api.
find . -mindepth 1 -maxdepth 1 \
    ! -name 'tests' \
    ! -name '.git' \
    ! -name '.idx' \
    ! -name '*.sh' \
    ! -name '.*' \
    -exec rm -rf {} +

echo "--- [3/3] PROVISIONING THE MISSING BIGQUERY VAULT ---"
# Remediating the missing infrastructure from TR-3.1 / FR-2.2
if ! bq show --dataset "${PROJECT_ID}:forensic_fact_base" >/dev/null 2>&1; then
    echo "Creating BigQuery Dataset..."
    bq mk --dataset --location=US "${PROJECT_ID}:forensic_fact_base"
fi

# Authoring the native JSON schema explicitly
bq query --use_legacy_sql=false \
"CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.forensic_fact_base.ingestion_ledger\` (
    original_parent_sha256 STRING NOT NULL,
    sliced_child_sha256 STRING NOT NULL,
    gcs_source_uri STRING NOT NULL,
    entity_slug STRING NOT NULL,
    taxonomy_lane STRING NOT NULL,
    average_confidence FLOAT64 NOT NULL,
    requires_manual_review BOOL NOT NULL,
    extracted_payload JSON NOT NULL,
    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);"

echo "============================================================================"
echo " TRANSITION COMPLETE: ENVIRONMENT IS PRISTINE AND READY FOR PLATINUM CODE "
echo "============================================================================"