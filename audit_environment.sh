#!/bin/bash
# ============================================================================
# LEGAL FORENSICS ENGINE - ENVIRONMENT STATE EXTRACTOR
# PROJECT ID: i-dub-thee
# DIRECTIVE: Absolute Ground Truth Reconnaissance
# ============================================================================
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export OUTPUT_FILE="ENVIRONMENT_STATE.md"

echo "============================================================================"
echo " INITIATING STATE RECONNAISSANCE (TARGET: ${PROJECT_ID}) "
echo "============================================================================"

# Initialize a clean output file
cat << 'EOF' > "${OUTPUT_FILE}"
# LEGAL FORENSICS ENGINE: GROUND TRUTH STATE
This document contains the exact local codebase and the live Google Cloud infrastructure configuration.
EOF

echo "--- [1/5] EXTRACTING LOCAL SOURCE CODE ---"
echo -e "\n## 1. LOCAL CODEBASE SNAPSHOT\n" >> "${OUTPUT_FILE}"

# Dynamically extract all relevant files, ignoring virtual environments and the output file itself
find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.txt" -o -name "*.json" \) \
    ! -path "*/forensic_env/*" \
    ! -path "*/.venv*/*" \
    ! -path "*/.git/*" \
    ! -path "*/.idx/*" \
    ! -path "*/__pycache__/*" \
    ! -name "${OUTPUT_FILE}" | sort | while read -r filepath; do
    
    echo "Extracting: $filepath"
    echo -e "### FILE: ${filepath}\n\`\`\`" >> "${OUTPUT_FILE}"
    cat "${filepath}" >> "${OUTPUT_FILE}"
    echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"
done

echo "--- [2/5] INTERROGATING BIFURCATED STORAGE VAULTS ---"
echo -e "\n## 2. GOOGLE CLOUD STORAGE CONFIGURATION\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud storage buckets list --project="${PROJECT_ID}" --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting buckets." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [3/5] INTERROGATING BIGQUERY FACT BASE ---"
echo -e "\n## 3. BIGQUERY SCHEMA & DATASET STATE\n\`\`\`yaml" >> "${OUTPUT_FILE}"
bq show --format=prettyjson "${PROJECT_ID}:forensic_fact_base.ingestion_ledger" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting BigQuery schema. Table might not exist." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [4/5] INTERROGATING SERVERLESS COMPUTE (LAYER 1 & 2) ---"
echo -e "\n## 4. SERVERLESS COMPUTE CONFIGURATIONS\n" >> "${OUTPUT_FILE}"

echo "### Cloud Function: forensic-pipeline-router (Layer 1)" >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud functions describe forensic-pipeline-router --region="${REGION}" --gen2 --project="${PROJECT_ID}" --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Function forensic-pipeline-router not found or failed to deploy." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "### Cloud Run: forensic-rag-api (Layer 2)" >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud run services describe forensic-rag-api --region="${REGION}" --project="${PROJECT_ID}" --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Service forensic-rag-api not found or failed to deploy." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [5/5] INTERROGATING IAM BINDINGS ---"
echo -e "\n## 5. IAM POLICIES (FORENSIC SERVICE ACCOUNTS)\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud projects get-iam-policy "${PROJECT_ID}" \
    --flatten="bindings[].members" \
    --filter="bindings.members:forensic-engine-sa" \
    --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting IAM bindings." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "============================================================================"
echo " STATE EXTRACTION COMPLETE "
echo " Artifact generated: ${OUTPUT_FILE}"
echo "============================================================================"