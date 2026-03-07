#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING MASTER TDD DEPLOYMENT: DUAL-MODEL CONSENSUS ENGINE"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring Implementation (tools/consensus_engine.py)..."
cat << 'EOF_PYTHON' > tools/consensus_engine.py
class ConsensusFractureError(Exception):
    """Custom exception raised when Model Alpha and Model Beta fail to reach mathematical consensus."""
    pass

def evaluate_consensus(alpha_payload: dict, beta_payload: dict) -> dict:
    """
    Evaluates the Dual-Model JSON payloads for deterministic equality across three critical vectors.
    Returns the pristine Alpha payload if consensus is achieved.
    Raises ConsensusFractureError if a discrepancy is detected.
    """
    # 1. The Taxonomy Vector Check
    alpha_tax = alpha_payload.get("taxonomy_lane")
    beta_tax = beta_payload.get("taxonomy_lane")
    if alpha_tax != beta_tax:
        raise ConsensusFractureError(f"Taxonomy Mismatch: Alpha[{alpha_tax}] vs Beta[{beta_tax}]")

    # 2. The Entity Vector Check (Paragraph 8F Commingling Defense)
    alpha_entity = alpha_payload.get("entity_identified")
    beta_entity = beta_payload.get("entity_identified")
    if alpha_entity != beta_entity:
        raise ConsensusFractureError(f"Entity Mismatch: Alpha[{alpha_entity}] vs Beta[{beta_entity}]")

    # 3. The Financial Vector Check
    alpha_data = alpha_payload.get("extracted_data")
    beta_data = beta_payload.get("extracted_data")
    if alpha_data != beta_data:
        raise ConsensusFractureError(f"Financial Data Mismatch: Alpha[{alpha_data}] vs Beta[{beta_data}]")

    # If all deterministic checks pass, the models are in perfect agreement.
    return alpha_payload
EOF_PYTHON

echo "[SYSTEM] 2. Executing Pytest Iron Gate (TDD Proof)..."
python3 -m pytest tests/test_consensus_engine.py -v

echo "============================================================================"
echo " [SUCCESS] DUAL-MODEL CONSENSUS ENGINE DEPLOYED AND MATHEMATICALLY PROVEN."
echo "============================================================================"
