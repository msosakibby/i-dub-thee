#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
DATASET_ID="forensic_fact_base"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 4 TAX CAPITALIZATION FRAUD ENGINE"
echo "============================================================================"

mkdir -p layer4_discrepancy_engine
cd layer4_discrepancy_engine

# ==============================================================================
# 1. FORGE ALGEBRAIC SIMULATOR (engine_logic_tax.py)
# ==============================================================================
echo "[SYSTEM] 1. Forging TDD Regex Simulator for Tax Fraud Detection..."

cat << 'EOF_PYTHON_TAX_LOGIC' > engine_logic_tax.py
import json
import re

def simulate_bq_tax_fraud_view(db_row: dict) -> dict:
    """
    Simulates the BigQuery vw_tax_capitalization_fraud_ledger view.
    Executes JSON unnesting, LANE_07 isolation, and Regex asset detection.
    """
    # 1. Taxonomy Isolation Gate
    if db_row.get("taxonomy_lane") != "LANE_07_TAX":
        return None
        
    # 2. JSON Unnesting
    try:
        payload = json.loads(db_row.get("extracted_payload", "[]"))
    except json.JSONDecodeError:
        return None

    # Strict list of assets known to be personal/marital but suspected of business capitalization
    fraud_pattern = re.compile(r'(SILVERADO|HONDA SXS|PIONEER|RANGER BOAT|FURNACE|AIR CONDITIONER)')
    
    # 3. Target Identification & Regex Isolation
    for fact in payload:
        if fact.get("key_name") == "Depreciation Assets":
            exact_val = str(fact.get("exact_value", "")).upper()
            match = fraud_pattern.search(exact_val)
            
            if match:
                return {
                    "fraud_indicator": "TAX_FRAUD_RISK",
                    "detected_asset_pattern": match.group(1),
                    "full_asset_description": exact_val
                }
                
    return None
EOF_PYTHON_TAX_LOGIC

# ==============================================================================
# 2. EXECUTE TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] 2. Verifying Mathematical & Regex Logic against TDD Contract..."
pytest tests/test_tax_capitalization.py -v

# ==============================================================================
# 3. DEPLOY BIGQUERY FORENSIC VIEW
# ==============================================================================
echo "[SYSTEM] 3. Deploying Continuous SQL Lens to BigQuery..."

bq query \
    --use_legacy_sql=false \
    --project_id=$PROJECT_ID \
    "CREATE OR REPLACE VIEW \`${PROJECT_ID}.${DATASET_ID}.vw_tax_capitalization_fraud_ledger\` AS
    SELECT
      parent_file_hash,
      gcs_source_uri,
      taxonomy_lane,
      entity_slug,
      document_type,
      JSON_EXTRACT_SCALAR(fact, '$.key_name') AS extracted_field_name,
      JSON_EXTRACT_SCALAR(fact, '$.exact_value') AS asset_description_and_basis,
      'TAX_FRAUD_RISK' AS fraud_indicator,
      REGEXP_EXTRACT(UPPER(JSON_EXTRACT_SCALAR(fact, '$.exact_value')), r'(SILVERADO|HONDA SXS|PIONEER|RANGER BOAT|FURNACE|AIR CONDITIONER)') AS detected_asset_pattern
    FROM
      \`${PROJECT_ID}.${DATASET_ID}.extracted_facts\`,
      UNNEST(JSON_EXTRACT_ARRAY(extracted_payload, '$')) AS fact
    WHERE
      taxonomy_lane = 'LANE_07_TAX'
      AND JSON_EXTRACT_SCALAR(fact, '$.key_name') = 'Depreciation Assets'
      AND REGEXP_CONTAINS(UPPER(JSON_EXTRACT_SCALAR(fact, '$.exact_value')), r'SILVERADO|HONDA SXS|PIONEER|RANGER BOAT|FURNACE|AIR CONDITIONER');"

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] ASSET CAPITALIZATION FRAUD ENGINE ONLINE"
echo "============================================================================"
