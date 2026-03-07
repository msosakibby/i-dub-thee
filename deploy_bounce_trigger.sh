#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING LIVE-FIRE: THE KINETIC BOUNCE RETRY"
echo "============================================================================"

TARGET_FILE="2014-10-10 Great Lakes Energy Utility Bill.pdf"
GCS_PATH="gs://i-dub-thee-docs/input/$TARGET_FILE"
LOCAL_TMP="/tmp/live_fire_artifact.pdf"

echo "[SYSTEM] 1. Pulling artifact to local workbench..."
gcloud storage cp "$GCS_PATH" "$LOCAL_TMP" --quiet

echo "[SYSTEM] 2. Punching artifact back into the drop-zone (Triggering Eventarc)..."
gcloud storage cp "$LOCAL_TMP" "$GCS_PATH" --quiet

echo "[SYSTEM] 3. Pipeline Activated. Awaiting Dual-LLM Extraction (15 Seconds)..."
sleep 15

echo "[SYSTEM] 4. Retrieving Live-Fire Telemetry..."
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=20

echo "============================================================================"
echo " [EXECUTION COMPLETE] AWAITING TELEMETRY REVIEW"
echo "============================================================================"
