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
