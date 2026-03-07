#!/bin/bash
# ============================================================================
# LEGAL FORENSICS ENGINE - LEGACY INTELLIGENCE EXTRACTOR (V2)
# DIRECTIVE: Targeted Sweep of gs://i-dub-thee-docs/
# ============================================================================
set -o errexit
set -o nounset
set -o pipefail

export LEGACY_BUCKET="i-dub-thee-docs"
export STAGING_ROOT="staging/legacy_intel"

echo "============================================================================"
echo " INITIATING AIR-GAPPED SWEEP OF LEGACY REPOSITORY"
echo " TARGET: gs://${LEGACY_BUCKET}/"
echo "============================================================================"

# 1. Scaffold Local Mirror Directories
echo "[SYSTEM] Provisioning local mirror directories..."
mkdir -p "${STAGING_ROOT}/_QUARANTINE"
mkdir -p "${STAGING_ROOT}/_REVIEW_NEW_ENTITY"
mkdir -p "${STAGING_ROOT}/LANE_99_UNKNOWN"
mkdir -p "${STAGING_ROOT}/forensic_summaries"
mkdir -p "${STAGING_ROOT}/persona_insights"
mkdir -p "${STAGING_ROOT}/reports"

# 2. Execute Parallelized Extraction
# Using 'gcloud storage rsync' instead of 'cp' to safely resume if interrupted
# and to prevent duplicating files on multiple runs.

echo "[SYSTEM] Sweeping Unresolved & Quarantined Entities..."
gcloud storage rsync "gs://${LEGACY_BUCKET}/_QUARANTINE" "${STAGING_ROOT}/_QUARANTINE" --recursive --quiet || echo "[INFO] Empty or missing directory."
gcloud storage rsync "gs://${LEGACY_BUCKET}/_REVIEW_NEW_ENTITY" "${STAGING_ROOT}/_REVIEW_NEW_ENTITY" --recursive --quiet || echo "[INFO] Empty or missing directory."
gcloud storage rsync "gs://${LEGACY_BUCKET}/LANE_99_UNKNOWN" "${STAGING_ROOT}/LANE_99_UNKNOWN" --recursive --quiet || echo "[INFO] Empty or missing directory."

echo "[SYSTEM] Sweeping Legacy Analytical Intelligence (For Schema Seeding)..."
gcloud storage rsync "gs://${LEGACY_BUCKET}/forensic_summaries" "${STAGING_ROOT}/forensic_summaries" --recursive --quiet || echo "[INFO] Empty or missing directory."
gcloud storage rsync "gs://${LEGACY_BUCKET}/persona_insights" "${STAGING_ROOT}/persona_insights" --recursive --quiet || echo "[INFO] Empty or missing directory."
gcloud storage rsync "gs://${LEGACY_BUCKET}/reports" "${STAGING_ROOT}/reports" --recursive --quiet || echo "[INFO] Empty or missing directory."

echo "============================================================================"
echo " [SUCCESS] LEGACY INTELLIGENCE SAFELY ISOLATED."
echo " Local staging path: ./${STAGING_ROOT}/"
echo "============================================================================"