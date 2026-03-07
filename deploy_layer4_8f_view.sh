#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
DATASET_ID="forensic_fact_base"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 4 DISCREPANCY ENGINE (PARAGRAPH 8F)"
echo "============================================================================"

mkdir -p layer4_discrepancy_engine
cd layer4_discrepancy_engine

# ==============================================================================
# 1. FORGE ALGEBRAIC SIMULATOR (engine_logic.py)
# ==============================================================================
echo "[SYSTEM] 1. Forging TDD Algebraic Simulator..."

cat << 'EOF_PYTHON_LOGIC' > engine_logic.py
import json
import re

def simulate_bq_8f_view_logic(db_row: dict) -> dict:
    """
    Simulates the exact SQL logic of the BigQuery vw_paragraph_8f_parity_ledger view.
    Executes JSON unnesting, taxonomy filtering, and 70/30 mathematical division.
    """
    # 1. Taxonomy Isolation Gate
    target_lanes = ["LANE_14_UTILITIES", "LANE_15_TRANSPORT"]
    if db_row.get("taxonomy_lane") not in target_lanes:
        return None
        
    # 2. JSON Unnesting (Simulating BQ UNNEST)
    try:
        payload = json.loads(db_row.get("extracted_payload", "[]"))
    except json.JSONDecodeError:
        return None

    target_keys = ["Gross Receipt Total", "Total Amount Due", "Net Receipt Total"]
    
    # 3. Target Identification & Float64 Casting
    for fact in payload:
        if fact.get("key_name") in target_keys:
            raw_val = fact.get("exact_value", "0.0")
            # Strip standard currency formatting for mathematical precision
            clean_val = re.sub(r'[$,]', '', str(raw_val))
            try:
                total_val = float(clean_val)
                # 4. Paragraph 8F Discrepancy Algebra
                return {
                    "total_expense_amount": total_val,
                    "judith_mandated_share": round(total_val * 0.70, 2),
                    "keith_owed_share": round(total_val * 0.30, 2)
                }
            except ValueError:
                continue
                
    return None
EOF_PYTHON_LOGIC

# ==============================================================================
# 2. EXECUTE TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] 2. Verifying Mathematical Logic against TDD Contract..."
pytest tests/test_8f_parity_algebra.py -v

# ==============================================================================
# 3. DEPLOY BIGQUERY FORENSIC VIEW
# ==============================================================================
echo "[SYSTEM] 3. Deploying Continuous SQL Lens to BigQuery..."

bq query \
    --use_legacy_sql=false \
    --project_id=$PROJECT_ID \
    "CREATE OR REPLACE VIEW \`${PROJECT_ID}.${DATASET_ID}.vw_paragraph_8f_parity_ledger\` AS
    SELECT
      parent_file_hash,
      gcs_source_uri,
      document_type,
      entity_slug,
      taxonomy_lane,
      JSON_EXTRACT_SCALAR(fact, '$.key_name') AS expense_category,
      CAST(REGEXP_REPLACE(JSON_EXTRACT_SCALAR(fact, '$.exact_value'), r'[$,]', '') AS FLOAT64) AS total_expense_amount,
      ROUND(CAST(REGEXP_REPLACE(JSON_EXTRACT_SCALAR(fact, '$.exact_value'), r'[$,]', '') AS FLOAT64) * 0.70, 2) AS judith_mandated_share,
      ROUND(CAST(REGEXP_REPLACE(JSON_EXTRACT_SCALAR(fact, '$.exact_value'), r'[$,]', '') AS FLOAT64) * 0.30, 2) AS keith_owed_share
    FROM
      \`${PROJECT_ID}.${DATASET_ID}.extracted_facts\`,
      UNNEST(JSON_EXTRACT_ARRAY(extracted_payload, '$')) AS fact
    WHERE
      taxonomy_lane IN ('LANE_14_UTILITIES', 'LANE_15_TRANSPORT')
      AND JSON_EXTRACT_SCALAR(fact, '$.key_name') IN ('Gross Receipt Total', 'Total Amount Due', 'Net Receipt Total');"

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] PARAGRAPH 8F DISCREPANCY ENGINE ONLINE"
echo "============================================================================"
