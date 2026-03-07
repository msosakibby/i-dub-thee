#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: GCP LIVE CODE INJECTION"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring GCP Root Dispatcher (main.py)..."
cat << 'EOF_ROOT_MAIN' > main.py
import asyncio
import functions_framework
from src.main import process_document
from tools.rules_engine import execute_rules_engine

# ============================================================================
# GCP EVENTARC DISPATCHER
# DIRECTIVE: Route CloudEvents to the TDD-Proven Layer 1 and Layer 2 Logic
# ============================================================================

@functions_framework.cloud_event
def pipeline_router_entry(cloud_event):
    """
    ENTRY POINT: forensic-pipeline-router (Layer 1)
    Triggered by: Storage Object Finalized (i-dub-thee-docs)
    """
    print(f"[+] Layer 1 Router triggered by event ID: {cloud_event['id']}")
    # Cloud Functions run in a synchronous wrapper; we must invoke the async loop
    return asyncio.run(process_document(cloud_event, None))

@functions_framework.cloud_event
def hypothesis_engine_entry(cloud_event):
    """
    ENTRY POINT: forensic-hypothesis-engine (Layer 2)
    Triggered by: Storage Object Finalized (or BigQuery insertion triggers)
    """
    print(f"[+] Layer 2 Engine triggered by event ID: {cloud_event['id']}")
    return execute_rules_engine()
EOF_ROOT_MAIN

echo "[SYSTEM] 2. Ensuring Cloud Dependencies (requirements.txt)..."
cat << 'EOF_REQ' > requirements.txt
google-cloud-aiplatform>=1.38.0
google-cloud-storage>=2.14.0
google-cloud-bigquery>=3.14.0
pydantic>=2.5.0
functions-framework>=3.0.0
EOF_REQ

PROJECT_ID=$(gcloud config get-value project)

echo "[SYSTEM] 3. Deploying Layer 1: forensic-pipeline-router..."
gcloud functions deploy forensic-pipeline-router \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=pipeline_router_entry \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-docs" \
    --timeout=300 \
    --memory=512MiB \
    --quiet

echo "[SYSTEM] 4. Deploying Layer 2: forensic-hypothesis-engine..."
gcloud functions deploy forensic-hypothesis-engine \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=hypothesis_engine_entry \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-processed" \
    --timeout=300 \
    --memory=512MiB \
    --quiet

echo "============================================================================"
echo " [SUCCESS] TDD-PROVEN CODE SUCCESSFULLY INJECTED INTO LIVE GCP PIPELINE."
echo "============================================================================"
