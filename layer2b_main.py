import functions_framework
import asyncio
from forensic_router import orchestrate_forensic_reports

@functions_framework.cloud_event
def layer2b_event_bridge(cloud_event):
    """The physical bridge between Eventarc and the Layer 2B Async Orchestrator."""
    data = cloud_event.data
    bucket = data["bucket"]
    name = data["name"]
    
    if not name.lower().endswith(".pdf"):
        print(f"[BOUNDARY] Ignoring non-PDF file: {name}")
        return
        
    pdf_uri = f"gs://{bucket}/{name}"
    
    # Execute the 5-tier async extraction
    asyncio.run(orchestrate_forensic_reports(
        document_uri=pdf_uri,
        document_type="Forensic Evidence"
    ))
