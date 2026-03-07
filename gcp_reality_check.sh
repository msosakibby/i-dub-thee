#!/bin/bash
# ============================================================================
# ZERO-TRUST GCP INFRASTRUCTURE AUDIT
# DIRECTIVE: Strict READ-ONLY environment interrogation. Zero modifications.
# ============================================================================

echo "============================================================================"
echo " INITIATING GCP REALITY CHECK: ILLUMINATING LIVE INFRASTRUCTURE"
echo "============================================================================"

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
echo "[+] Active GCP Project: $PROJECT_ID"
echo "----------------------------------------------------------------------------"

echo "[SYSTEM] 1. Interrogating Cloud Storage (The Drop Zones)..."
gcloud storage ls --project="$PROJECT_ID" | grep "i-dub-thee" || echo "  [!] No buckets matching 'i-dub-thee' found."
echo ""

echo "[SYSTEM] 2. Interrogating BigQuery (The Vault)..."
echo "  [?] Checking Datasets..."
bq ls --project_id="$PROJECT_ID" --format=pretty || echo "  [!] No BigQuery datasets found."
echo "  [?] Checking Tables in 'forensic_fact_base'..."
bq ls --project_id="$PROJECT_ID" --format=pretty forensic_fact_base || echo "  [!] Dataset 'forensic_fact_base' missing or empty."
echo "  [?] Checking Schema of 'ingestion_ledger' (if exists)..."
bq show --schema --format=pretty "$PROJECT_ID:forensic_fact_base.ingestion_ledger" 2>/dev/null || echo "  [!] Table 'ingestion_ledger' missing."
echo ""

echo "[SYSTEM] 3. Interrogating Cloud Functions (The Compute)..."
gcloud functions list --project="$PROJECT_ID" --regions=us-central1 --format="table(name,status,versionId)" || echo "  [!] No Cloud Functions deployed in us-central1."
echo ""

echo "[SYSTEM] 4. Interrogating Eventarc (The Triggers)..."
gcloud eventarc triggers list --project="$PROJECT_ID" --location=us-central1 --format="table(name,destinationCloudFunction,eventFilters)" || echo "  [!] No Eventarc triggers found in us-central1."

echo "============================================================================"
echo " [AUDIT COMPLETE] AWAITING TELEMETRY"
echo "============================================================================"
