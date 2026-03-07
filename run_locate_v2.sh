#!/bin/bash
echo "============================================================================"
echo " INITIATING ZERO-TRUST DIAGNOSTIC: THE A-TO-Z TELEMETRY PULL"
echo "============================================================================"

echo "--- 1. PHYSICAL VAULTS (Where is the PDF right now?) ---"
echo "[QUARANTINE VAULT]:"
gcloud storage ls gs://i-dub-thee-quarantine/** || echo "  [-] Empty"
echo "[PROCESSED VAULT]:"
gcloud storage ls gs://i-dub-thee-processed/** || echo "  [-] Empty"

echo "--- 2. LAYER 1 LOGS (Did it pass the gate?) ---"
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=10

echo "--- 3. WORKFLOW LOGS (Did Eventarc catch the nested file?) ---"
gcloud workflows executions list layer2b-workflow --location=us-central1 --project=$(gcloud config get-value project) --limit=3

echo "--- 4. LAYER 2B LOGS (Did the container crash?) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project=$(gcloud config get-value project) \
    --limit=15 \
    --format="table(timestamp, textPayload, jsonPayload.message)"

echo "============================================================================"
echo " [DIAGNOSTIC COMPLETE]"
echo "============================================================================"
