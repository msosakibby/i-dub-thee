#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 2B ANALYTICAL ORCHESTRATOR"
echo "============================================================================"

mkdir -p pristine_deployment_chamber
cd pristine_deployment_chamber

echo "[SYSTEM] 1. Forging Modern Dependencies..."
cat << 'EOF_REQ' > requirements.txt
google-cloud-storage==2.14.0
google-genai==0.3.0
pydantic==2.6.3
asyncio==3.4.3
EOF_REQ

echo "[SYSTEM] 2. Forging Analytical Container (forensic_router.py)..."
cat << 'EOF_PYTHON' > forensic_router.py
import os
import sys
import json
import asyncio
import logging
from google.cloud import storage
from google import genai
from google.genai import types
from pydantic import BaseModel, Field

# Strict logging for Zero-Trust Auditing
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - FORENSIC_ORCHESTRATOR - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ==============================================================================
# PYDANTIC SCHEMA ENFORCEMENT (REPORT 5: JSON EXTRACTION)
# ==============================================================================
class ExtractedDataPoint(BaseModel):
    key_name: str = Field(description="The normalized name of the extracted data point (e.g., 'Account_Number', 'Total_Due').")
    extracted_value: str = Field(description="The exact alphanumeric value extracted from the document.")
    data_type: str = Field(description="The strict data type (e.g., 'currency', 'date', 'string', 'number').")

class ForensicExhaustiveJSON(BaseModel):
    document_summary: str = Field(description="A brief 1-sentence summary of the document's contents.")
    extracted_data_points: list[ExtractedDataPoint] = Field(description="An exhaustive array of every data element, table cell, and notation found in the document.")

# ==============================================================================
# GEOMETRIC PATH & PERSISTENCE ENGINE
# ==============================================================================
def generate_artifact_paths(source_blob_name: str) -> dict:
    """Calculates the strict sibling paths for the 5 analytical artifacts."""
    base_path = source_blob_name.rsplit('.', 1)[0]
    return {
        "report_1": f"{base_path}_Report1_Structural.md",
        "report_2": f"{base_path}_Report2_Analyst.md",
        "report_3": f"{base_path}_Report3_Expert.md",
        "report_4": f"{base_path}_Report4_QA_Strategy.md",
        "report_5": f"{base_path}_Report5_Extraction.json"
    }

def persist_forensic_artifacts(bucket, source_blob_name: str, payloads: dict):
    """Physically writes the volatile RAM artifacts to the permanent GCS vault."""
    paths = generate_artifact_paths(source_blob_name)
    
    logger.info(f"Anchoring Report 1 (Structural) to {paths['report_1']}")
    bucket.blob(paths['report_1']).upload_from_string(payloads['report_1'], content_type="text/markdown")
    
    logger.info(f"Anchoring Report 2 (Analyst) to {paths['report_2']}")
    bucket.blob(paths['report_2']).upload_from_string(payloads['report_2'], content_type="text/markdown")
    
    logger.info(f"Anchoring Report 3 (Expert) to {paths['report_3']}")
    bucket.blob(paths['report_3']).upload_from_string(payloads['report_3'], content_type="text/markdown")
    
    logger.info(f"Anchoring Report 4 (QA) to {paths['report_4']}")
    bucket.blob(paths['report_4']).upload_from_string(payloads['report_4'], content_type="text/markdown")
    
    logger.info(f"Anchoring Report 5 (JSON) to {paths['report_5']}")
    bucket.blob(paths['report_5']).upload_from_string(payloads['report_5'], content_type="application/json")

# ==============================================================================
# ASYNCHRONOUS AI EXTRACTION ENGINE
# ==============================================================================
async def execute_prompt(client, model_id, document_part, prompt_text, schema=None, is_json=False):
    """Executes a single forensic thread against the Vertex AI Global Endpoint."""
    config_args = {
        "temperature": 0.0,
    }
    if is_json and schema:
        config_args["response_mime_type"] = "application/json"
        config_args["response_schema"] = schema
    else:
        config_args["response_mime_type"] = "text/plain"

    config = types.GenerateContentConfig(**config_args)
    
    # We use client.aio for asynchronous parallel execution
    response = await client.aio.models.generate_content(
        model=model_id,
        contents=[document_part, prompt_text],
        config=config
    )
    return response.text

async def run_concurrent_forensics(project_id: str, file_bytes: bytes) -> dict:
    """Orchestrates the 5 exact prompts defined in the Master Doctrine."""
    client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="us-central1")
    model_id = "gemini-2.5-pro"
    document_part = types.Part.from_bytes(data=file_bytes, mime_type='application/pdf')

    # PROMPT 1: Structural Recreation
    p1 = """You are an expert document formatter. 
    STRUCTURAL RECREATION: Output a precise MARKDOWN representation of this document's visual layout. Preserve all structure. include all images
    Tables must use GFM (GitHub Flavored Markdown)."""

    # PROMPT 2: Forensic Document Analyst
    p2 = """Your role is to act as a highly specialized Forensic Document Analyst. 
    Analyze the document content thoroughly and produce a detailed report in the following strict Markdown format.
    # Analysis - Document content
    | Metadata Field | Value |
    | :--- | :--- |
    | **Filename** | [Derived from document content] |
    | **Title** | [Main title of the document] |
    | **Source / Author** | [Author or origin, if present] |
    | **Subject** | [Primary subject/topic] |
    | **Key Words** | [Relevant keywords, comma-separated] |
    | **Document Type** | [Classification of the document] |
    | **Income Type** | [If financial, type of income; otherwise 'None'] |

    ## Executive Summary (BLUF)
    [Provide a concise, bottom-line-up-front summary...]
    
    ## Content Analysis & Verification
    [Detail the main content of the document...]
    
    ## Risk & Concern Assessment
    [Identify and assess any risks, anomalies, or potential concerns...]
    
    ## Structural Data Extraction
    [Extract key data points from the document into a structured key-value format...]"""

    # PROMPT 3 (Report 3 in Doctrine): Elite Expert Persona
    p3 = """System Objective: You are an AI routing mechanism. Immediately adopt the persona of the most elite, specialized forensic expert suited to analyze the document.
    Format Constraints: Markdown only.
    # [Analysis Type] - [Extract Entity Name]
    ## 1. EXECUTIVE SUMMARY (BLUF)
    ## 2. STRUCTURAL DATA SUMMARY
    ## 3. EXTRACTED INSIGHTS & FORENSIC OBSERVATIONS
    ## 4. STRATEGIC RECOMMENDATIONS & ACTIONABLE NEXT STEPS"""

    # PROMPT 4 (Report 4 in Doctrine): Forensic QA Architect
    p4 = """You are a Forensic QA Architect. Review the document and outline a 3-step refinement strategy for extracting secondary/tertiary entities."""

    # PROMPT 5: Exhaustive JSON Extraction
    p5 = """You are an expert document transcriber and data analyst.
    Perform an EXHAUSTIVE EXTRACTION of scanned information from the attached document.
    1. Extract every piece of text, table, and handwritten notation.
    2. DATA ELEMENT IDENTIFICATION: Map every identifying key into the provided structured JSON block."""

    logger.info("Awaiting concurrent AI resolutions (5 Threads)...")
    
    # Execute all 5 threads simultaneously
    results = await asyncio.gather(
        execute_prompt(client, model_id, document_part, p1),
        execute_prompt(client, model_id, document_part, p2),
        execute_prompt(client, model_id, document_part, p3),
        execute_prompt(client, model_id, document_part, p4),
        execute_prompt(client, model_id, document_part, p5, schema=ForensicExhaustiveJSON, is_json=True)
    )

    logger.info("All 5 forensic execution threads resolved successfully.")
    
    return {
        "report_1": results[0],
        "report_2": results[1],
        "report_3": results[2],
        "report_4": results[3],
        "report_5": results[4]
    }

# ==============================================================================
# MAIN EXECUTION THREAD
# ==============================================================================
if __name__ == "__main__":
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    bucket_name = os.environ.get("CE_BUCKET")
    subject_name = os.environ.get("CE_SUBJECT")

    if not bucket_name or not subject_name:
        logger.error("FATAL: Missing CE_BUCKET or CE_SUBJECT environment variables. Workflows V2 override failed.")
        sys.exit(1)

    logger.info(f"Layer 2B Awakened. Target: gs://{bucket_name}/{subject_name}")

    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(subject_name)
        
        file_bytes = blob.download_as_bytes()
        
        # Execute concurrent AI
        payloads = asyncio.run(run_concurrent_forensics(project_id, file_bytes))
        
        # Persist to disk
        persist_forensic_artifacts(bucket, subject_name, payloads)
        
        logger.info("Layer 2B Execution Complete. Files anchored. Exiting cleanly.")
        sys.exit(0)

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION: {str(e)}")
        sys.exit(1)

EOF_PYTHON

echo "[SYSTEM] 3. Deploying Fortified Cloud Run Job..."
gcloud run jobs deploy layer2b-analytical-job \
    --source . \
    --region us-central1 \
    --service-account "$SERVICE_ACCOUNT" \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=$PROJECT_ID" \
    --max-retries 0 \
    --task-timeout 600s \
    --memory 2Gi \
    --quiet

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] LAYER 2B ARTIFACT PERSISTENCE IS ACTIVE"
echo "============================================================================"
