#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING MASTER PATCH: ROOT ENTRY POINT INJECTION"
echo "============================================================================"

echo "[SYSTEM] 1. Injecting Layer 2B Bridge into root main.py..."
cat << 'EOF_MAIN_APPEND' >> main.py

# ==============================================================================
# LAYER 2B: ANALYTICAL ORCHESTRATOR BRIDGE
# ==============================================================================
@functions_framework.cloud_event
def layer2b_analytical_entry(cloud_event):
    """The physical bridge between Eventarc and the Layer 2B Async Orchestrator."""
    import asyncio
    from forensic_router import orchestrate_forensic_reports
    
    data = cloud_event.data
    bucket = data["bucket"]
    name = data["name"]
    
    if not name.lower().endswith(".pdf"):
        print(f"[BOUNDARY ENFORCEMENT]: Ignoring non-PDF file in Layer 2B: {name}")
        return
        
    pdf_uri = f"gs://{bucket}/{name}"
    
    print(f"[+] Layer 2B Orchestrator triggered for URI: {pdf_uri}")
    
    # Execute the 5-tier async extraction
    asyncio.run(orchestrate_forensic_reports(
        document_uri=pdf_uri,
        document_type="Forensic Evidence"
    ))
EOF_MAIN_APPEND

echo "[SYSTEM] 2. Re-Deploying Layer 2B Analytical Orchestrator to Live GCP..."
PROJECT_ID=$(gcloud config get-value project)
gcloud functions deploy layer2b-analytical-orchestrator \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=layer2b_analytical_entry \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-processed" \
    --timeout=540 \
    --memory=1024MiB \
    --quiet

echo "============================================================================"
echo " [SUCCESS] ROOT ENTRY POINT SECURED. LAYER 2B DEPLOYED."
echo "============================================================================"
