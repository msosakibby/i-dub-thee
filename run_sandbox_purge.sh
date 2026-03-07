#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING ZERO-TRUST PURGE: STERILIZING EPHEMERAL SANDBOX"
echo "============================================================================"

# 1. VAPORIZE CLOUD STORAGE ARTIFACTS
echo "[SYSTEM] 1. Scrubbing Master Filing Cabinet (GCS) for [SANDBOX] artifacts..."
# Suppress errors if no files are currently found
gcloud storage rm "gs://i-dub-thee-docs/input/*[SANDBOX]*" 2>/dev/null || true
gcloud storage rm "gs://i-dub-thee-processed/**/*[SANDBOX]*" 2>/dev/null || true

# 2. TRUNCATE BIGQUERY SANDBOX TABLE
echo "[SYSTEM] 2. Severing and Truncating BigQuery Sandbox Table..."
bq query \
    --use_legacy_sql=false \
    --project_id=$PROJECT_ID \
    "TRUNCATE TABLE \`${PROJECT_ID}.forensic_fact_base.sandbox_extracted_facts\`;"

echo "============================================================================"
echo " [STERILIZATION COMPLETE] THE SANDBOX IS PRISTINE"
echo "============================================================================"
