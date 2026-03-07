#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING ZERO-TRUST DIAGNOSTIC: LAYER 1 INTAKE SWEEP"
echo "============================================================================"

echo "--- 1. PHYSICAL INVENTORY: INPUT VAULT (Is the file stuck here?) ---"
gcloud storage ls gs://i-dub-thee-docs/input/ || echo "  [-] Input bucket is empty or inaccessible."

echo "--- 2. PHYSICAL INVENTORY: QUARANTINE VAULT (Did it fail consensus?) ---"
gcloud storage ls gs://i-dub-thee-quarantine/ || echo "  [-] Quarantine bucket is empty."

echo "--- 3. PHYSICAL INVENTORY: PROCESSED VAULT (Did it pass?) ---"
gcloud storage ls gs://i-dub-thee-processed/ || echo "  [-] Processed bucket is empty."

echo "--- 4. LAYER 1 ROUTER TELEMETRY (Did the Cloud Function wake up?) ---"
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=15

echo "============================================================================"
echo " [DIAGNOSTIC COMPLETE]"
echo "============================================================================"
