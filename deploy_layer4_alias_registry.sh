#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
DATASET_ID="forensic_fact_base"
TABLE_ID="account_alias_registry"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 4 V1.2.0 (ACCOUNT ALIAS REGISTRY)"
echo "============================================================================"

# ==============================================================================
# 1. PROVISION BIGQUERY REGISTRY TABLE & SEED DATA
# ==============================================================================
echo "[SYSTEM] 1. Provisioning Entity Resolution Table in BigQuery..."

cat << 'EOF_ALIAS_SCHEMA' > bq_alias_schema.json
[
  {"name": "raw_institution", "type": "STRING", "mode": "REQUIRED"},
  {"name": "raw_account_suffix", "type": "STRING", "mode": "NULLABLE"},
  {"name": "canonical_entity_id", "type": "STRING", "mode": "REQUIRED"}
]
EOF_ALIAS_SCHEMA

# Create table (ignore error if it already exists)
bq mk --table --schema=bq_alias_schema.json ${PROJECT_ID}:${DATASET_ID}.${TABLE_ID} 2>/dev/null || true

echo "[SYSTEM] 2. Injecting Foundational Temporal Seeds (Chemical -> Huntington)..."

# Wipe existing seeds to ensure idempotency during re-deployments
bq query --use_legacy_sql=false "DELETE FROM \`${PROJECT_ID}.${DATASET_ID}.${TABLE_ID}\` WHERE true;"

# Inject the exact entities harvested from your 900+ page archive
bq query --use_legacy_sql=false "
INSERT INTO \`${PROJECT_ID}.${DATASET_ID}.${TABLE_ID}\` (raw_institution, raw_account_suffix, canonical_entity_id)
VALUES 
  ('Chemical Bank', '4797', 'JOINT_CHECKING_MAIN'),
  ('Huntington Bank', '4797', 'JOINT_CHECKING_MAIN'),
  ('K-J Wildlife', NULL, 'KEITH_SEPARATE_BUSINESS'),
  ('KG Fishing', '2268', 'KEITH_SEPARATE_BUSINESS'),
  ('Kibby Company L.L.C.', NULL, 'JUDY_SEPARATE_BUSINESS'),
  ('Midland National', 'Policy #04', 'ASSET_VAULT_ANNUITY');
"

# ==============================================================================
# 2. FORGE ALGEBRAIC SIMULATOR (alias_resolver.py)
# ==============================================================================
mkdir -p layer4_discrepancy_engine
cd layer4_discrepancy_engine

echo "[SYSTEM] 3. Forging TDD Resolution Logic..."

cat << 'EOF_PYTHON_ALIAS_LOGIC' > alias_resolver.py
import json

def resolve_financial_entity(raw_institution: str, raw_account_string: str = None) -> str:
    """
    Simulates the BigQuery JOIN logic for Entity Resolution.
    In the live cloud environment, this is handled natively via SQL against account_alias_registry.
    """
    # Hardcoded local dictionary mimicking the exact rows inserted into BigQuery
    registry = {
        ("Chemical Bank", "4797"): "JOINT_CHECKING_MAIN",
        ("Huntington Bank", "4797"): "JOINT_CHECKING_MAIN",
        ("K-J Wildlife", None): "KEITH_SEPARATE_BUSINESS",
        ("KG Fishing", "2268"): "KEITH_SEPARATE_BUSINESS",
        ("Kibby Company L.L.C.", None): "JUDY_SEPARATE_BUSINESS"
    }
    
    # 1. Attempt Exact Match (Institution + Account String)
    exact_key = (raw_institution, raw_account_string)
    if exact_key in registry:
        return registry[exact_key]
        
    # 2. Attempt Partial Match (Institution Only - useful for corporate entities without specific accounts)
    partial_key = (raw_institution, None)
    if partial_key in registry:
        return registry[partial_key]
        
    # 3. Fallback Degradation
    return "UNRESOLVED_ENTITY"
EOF_PYTHON_ALIAS_LOGIC

# ==============================================================================
# 3. EXECUTE TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] 4. Verifying Temporal Resolution Logic against TDD Contract..."
pytest tests/test_alias_registry.py -v

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] ACCOUNT ALIAS REGISTRY ONLINE"
echo "============================================================================"
