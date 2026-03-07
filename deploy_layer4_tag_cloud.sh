#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
DATASET_ID="forensic_fact_base"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 4 V1.3.0 (TAG CLOUD DASHBOARD)"
echo "============================================================================"

mkdir -p layer4_discrepancy_engine
cd layer4_discrepancy_engine

# ==============================================================================
# 1. FORGE ALGEBRAIC SIMULATOR (engine_logic_tags.py)
# ==============================================================================
echo "[SYSTEM] 1. Forging TDD Regex Extraction Array Simulator..."

cat << 'EOF_PYTHON_TAG_LOGIC' > engine_logic_tags.py
import json
import re

def simulate_bq_tag_extraction(db_row: dict) -> dict:
    """
    Simulates the BigQuery vw_continuous_tag_cloud view.
    Executes JSON unnesting, Regex array generation, and empty-row bypass.
    """
    try:
        payload = json.loads(db_row.get("extracted_payload", "[]"))
    except json.JSONDecodeError:
        return None

    extracted_flags = []
    # Strict Regex targeting the [FLAG: EXACT_STRING] metadata embedded by AI
    pattern = re.compile(r'\[FLAG:\s*([A-Z0-9_]+)\]')
    
    for fact in payload:
        exact_val = str(fact.get("exact_value", ""))
        matches = pattern.findall(exact_val)
        if matches:
            extracted_flags.extend(matches)
            
    # Clean Document Bypass: Return None if no flags exist
    if not extracted_flags:
        return None
        
    return {
        "parent_file_hash": db_row.get("parent_file_hash"),
        "extracted_flags": extracted_flags
    }
EOF_PYTHON_TAG_LOGIC

# ==============================================================================
# 2. EXECUTE TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] 2. Verifying Regex Array Logic against TDD Contract..."
pytest tests/test_tag_cloud.py -v

# ==============================================================================
# 3. DEPLOY BIGQUERY FORENSIC VIEW
# ==============================================================================
echo "[SYSTEM] 3. Deploying Continuous SQL Lens to BigQuery..."

# Architectural Note: REGEXP_EXTRACT_ALL returns an array. We UNNEST that array so 
# a single document with 3 flags generates 3 distinct, filterable rows on the dashboard.
bq query \
    --use_legacy_sql=false \
    --project_id=$PROJECT_ID \
    "CREATE OR REPLACE VIEW \`${PROJECT_ID}.${DATASET_ID}.vw_continuous_tag_cloud\` AS
    SELECT
      parent_file_hash,
      gcs_source_uri,
      taxonomy_lane,
      entity_slug,
      document_type,
      JSON_EXTRACT_SCALAR(fact, '$.key_name') AS source_key,
      JSON_EXTRACT_SCALAR(fact, '$.exact_value') AS flagged_context_text,
      forensic_tag
    FROM
      \`${PROJECT_ID}.${DATASET_ID}.extracted_facts\`,
      UNNEST(JSON_EXTRACT_ARRAY(extracted_payload, '$')) AS fact,
      UNNEST(REGEXP_EXTRACT_ALL(JSON_EXTRACT_SCALAR(fact, '$.exact_value'), r'\[FLAG:\s*([A-Z0-9_]+)\]')) AS forensic_tag;"

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] METADATA TAG CLOUD ENGINE ONLINE"
echo "============================================================================"
