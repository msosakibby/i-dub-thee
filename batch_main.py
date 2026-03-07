import os
import asyncio
import logging
from forensic_router import orchestrate_forensic_reports

logging.basicConfig(level=logging.INFO, format='%(asctime)s - BATCH_ENTRY - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def main():
    bucket = os.environ.get("CE_BUCKET")
    subject = os.environ.get("CE_SUBJECT") 
    
    if not bucket or not subject:
        logger.error("FATAL: Missing CE_BUCKET or CE_SUBJECT variables. Pipeline breach detected.")
        return
        
    name = subject.replace("objects/", "") if subject.startswith("objects/") else subject
    
    if not name.lower().endswith(".pdf"):
        logger.info(f"[BOUNDARY ENFORCEMENT]: Ignoring non-PDF file: {name}")
        return
        
    pdf_uri = f"gs://{bucket}/{name}"
    logger.info(f"[+] Layer 2B Batch Orchestrator triggered for URI: {pdf_uri}")
    
    await orchestrate_forensic_reports(
        document_uri=pdf_uri,
        document_type="Forensic Evidence"
    )

if __name__ == "__main__":
    asyncio.run(main())
