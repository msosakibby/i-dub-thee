#!/bin/bash
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export OUTPUT_FILE="PROD_GROUND_TRUTH.md"

echo "============================================================================"
echo " INITIATING ABSOLUTE GROUND-TRUTH EXTRACTION (CODEBASE + INFRASTRUCTURE)"
echo "============================================================================"

cat << 'EOF' > "${OUTPUT_FILE}"
# 🏛️ PRODUCTION GROUND TRUTH (CODEBASE + INFRASTRUCTURE)
**Project:** i-dub-thee
**Directive:** Absolute 1:1 Blueprint for Staging Instantiation
EOF

echo "--- [1/5] EXTRACTING LOCAL SOURCE CODE ---"
echo -e "\n## 1. LOCAL CODEBASE SNAPSHOT\n" >> "${OUTPUT_FILE}"

find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.json" -o -name "*.yaml" -o -name "requirements.txt" -o -name "Dockerfile" \) \
    ! -path "*/forensic_env/*" \
    ! -path "*/.venv*/*" \
    ! -path "*/.git/*" \
    ! -path "*/.idx/*" \
    ! -path "*/__pycache__/*" \
    ! -path "*/.pytest_cache/*" \
    ! -name "${OUTPUT_FILE}" | sort | while read -r filepath; do
    
    echo "  -> Extracting: $filepath"
    echo -e "### FILE: ${filepath}\n\`\`\`" >> "${OUTPUT_FILE}"
    cat "${filepath}" >> "${OUTPUT_FILE}"
    echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"
done

echo "--- [2/5] INTERROGATING CLOUD STORAGE ---"
echo -e "\n## 2. GOOGLE CLOUD STORAGE CONFIGURATION\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud storage buckets list --project="${PROJECT_ID}" --format="yaml(name,location,storageClass,uniformBucketLevelAccess,publicAccessPrevention)" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting buckets." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [3/5] INTERROGATING BIGQUERY FACT BASE ---"
echo -e "\n## 3. BIGQUERY SCHEMA STATE\n\`\`\`json" >> "${OUTPUT_FILE}"
bq show --schema --format=prettyjson "${PROJECT_ID}:forensic_fact_base.ingestion_ledger" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting BigQuery schema. Table might not exist." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [4/5] INTERROGATING SERVERLESS COMPUTE ---"
echo -e "\n## 4. SERVERLESS COMPUTE CONFIGURATIONS\n" >> "${OUTPUT_FILE}"

echo "### Cloud Function (Layer 1)" >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud functions describe forensic-pipeline-router --region="${REGION}" --gen2 --project="${PROJECT_ID}" --format="yaml(name,environment,serviceConfig.availableMemory,serviceConfig.timeoutSeconds,serviceConfig.environmentVariables,eventTrigger)" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Function not found." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "### Cloud Run Job (Layer 2B)" >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud run jobs describe layer2b-analytical-job --region="${REGION}" --project="${PROJECT_ID}" --format="yaml(name,template.template.containers[0].resources,template.template.timeout,template.template.containers[0].env)" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Job not found." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [5/5] INTERROGATING IAM BINDINGS ---"
echo -e "\n## 5. IAM POLICIES (FORENSIC SERVICE ACCOUNTS)\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud projects get-iam-policy "${PROJECT_ID}" \
    --flatten="bindings[].members" \
    --filter="bindings.members:forensic-engine-sa" \
    --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting IAM bindings." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "============================================================================"
echo " [EXTRACTION COMPLETE] Artifact generated: ${OUTPUT_FILE}"
echo "============================================================================"
