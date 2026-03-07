#!/bin/bash
set -o pipefail

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export OUTPUT_FILE="PROD_STATE_AUDIT.md"

echo "============================================================================"
echo " INITIATING READ-ONLY STATE EXTRACTION (TARGET: PRODUCTION)"
echo "============================================================================"

cat << 'EOF' > "${OUTPUT_FILE}"
# 🏛️ PRODUCTION ENVIRONMENT STATE AUDIT
**Project:** i-dub-thee
**Directive:** Ground-Truth Blueprint for Staging Mirror
EOF

echo "[SYSTEM] 1. Extracting Storage Vault Configurations..."
echo -e "\n## 1. STORAGE CONFIGURATIONS\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud storage buckets list --project="${PROJECT_ID}" --format="yaml(name,location,storageClass,uniformBucketLevelAccess,publicAccessPrevention)" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting buckets." >> "${OUTPUT_FILE}"
echo -e "\`\`\`\n" >> "${OUTPUT_FILE}"

echo "[SYSTEM] 2. Extracting BigQuery Schema..."
echo -e "## 2. BIGQUERY FACT BASE (ingestion_ledger)\n\`\`\`json" >> "${OUTPUT_FILE}"
bq show --schema --format=prettyjson "${PROJECT_ID}:forensic_fact_base.ingestion_ledger" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting BigQuery schema." >> "${OUTPUT_FILE}"
echo -e "\`\`\`\n" >> "${OUTPUT_FILE}"

echo "[SYSTEM] 3. Extracting Layer 1 Compute (Cloud Function)..."
echo -e "## 3. LAYER 1: PIPELINE ROUTER (Cloud Function)\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud functions describe forensic-pipeline-router --region="${REGION}" --gen2 --project="${PROJECT_ID}" --format="yaml(name,environment,serviceConfig.availableMemory,serviceConfig.timeoutSeconds,serviceConfig.environmentVariables,eventTrigger)" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Function not found." >> "${OUTPUT_FILE}"
echo -e "\`\`\`\n" >> "${OUTPUT_FILE}"

echo "[SYSTEM] 4. Extracting Layer 2B Compute (Cloud Run Job)..."
echo -e "## 4. LAYER 2B: ANALYTICAL ORCHESTRATOR (Cloud Run Job)\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud run jobs describe layer2b-analytical-job --region="${REGION}" --project="${PROJECT_ID}" --format="yaml(name,template.template.containers[0].resources,template.template.timeout,template.template.containers[0].env)" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Job not found." >> "${OUTPUT_FILE}"
echo -e "\`\`\`\n" >> "${OUTPUT_FILE}"

echo "============================================================================"
echo " [SUCCESS] EXTRACTION COMPLETE."
echo " Artifact generated: ${OUTPUT_FILE}"
echo "============================================================================"
