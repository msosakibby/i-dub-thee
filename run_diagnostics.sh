#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " FORENSIC DIAGNOSTIC: TRACING THE GOLDEN RECORD"
echo "============================================================================"

echo "--- 1. INTERROGATING LAYER 1 (Did it process?) ---"
gcloud functions logs read forensic-pipeline-router --region=us-central1 --limit=5

echo "--- 2. INTERROGATING THE QUARANTINE VAULT (Did it fail consensus?) ---"
gcloud storage ls gs://i-dub-thee-quarantine/clean_receipt.pdf || echo "  [-] File not in quarantine."

echo "--- 3. INTERROGATING THE PROCESSED VAULT (Did it pass the Iron Gate?) ---"
gcloud storage ls gs://i-dub-thee-processed/clean_receipt.pdf || echo "  [-] File not in processed bucket."

echo "--- 4. INTERROGATING THE WORKFLOW BRIDGE (Did Eventarc route it?) ---"
gcloud workflows executions list layer2b-workflow --location=us-central1 --project="$PROJECT_ID" --limit=3 || echo "  [-] No workflow executions found."

echo "============================================================================"
echo " [DIAGNOSTIC COMPLETE]"
echo "============================================================================"
