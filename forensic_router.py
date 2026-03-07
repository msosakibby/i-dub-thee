import asyncio
import logging
import random
import os
from typing import Dict, Any
from google import genai
from google.genai import types

logging.basicConfig(level=logging.INFO, format='%(asctime)s - FORENSIC_ROUTER - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def async_retry(max_retries: int = 3, base_delay: float = 2.0):
    def decorator(func):
        async def wrapper(*args, **kwargs):
            retries = 0
            while retries < max_retries:
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    retries += 1
                    if retries == max_retries:
                        logger.error(f"FATAL: Max retries ({max_retries}) reached for {func.__name__}. Error: {str(e)}")
                        raise e
                    delay = (base_delay * (2 ** (retries - 1))) + random.uniform(0, 1)
                    logger.warning(f"API Exception caught: {str(e)}. Retrying {func.__name__} in {delay:.2f} seconds...")
                    await asyncio.sleep(delay)
        return wrapper
    return decorator

def build_prompts(document_type: str) -> Dict[str, str]:
    return {
        "report_1_json_extraction": f"""
You are an expert document transcriber and data analyst.
Perform an EXHAUSTIVE EXTRACTION of scanned information from the attached document.
1. Extract every piece of text, table, and handwritten notation.
2. DATA ELEMENT IDENTIFICATION: Map every identifying key into a structured JSON block.
DOCUMENT TYPE: {document_type}
[DOCUMENT CONTENT ATTACHED EXTERNALLY]
""",
        "report_2_metadata_summary": f"""
Your role is to act as a highly specialized Forensic Document Analyst. 
Analyze the attached document content thoroughly and produce a detailed report in the following strict Markdown format.
# Analysis - {document_type} - [Extract Entity Name]
| Metadata Field | Value |
| :--- | :--- |
| **Filename** | Derived from document content |
| **Document Type** | {document_type} |
---
## Executive Summary (BLUF)
Provide a concise, bottom-line-up-front summary.
---
## Content Analysis & Verification
Detail the main content of the document.
---
## Risk & Concern Assessment
Identify and assess any risks, anomalies, or potential concerns.
---
## Structural Data Extraction Summary
Summarize the key data points extracted.
[DOCUMENT CONTENT ATTACHED EXTERNALLY]
""",
        "report_3_reserved_refinement": f"""
You are a Forensic QA Architect. 
Review the attached document and outline a 3-step refinement strategy for extracting secondary/tertiary entities.
DOCUMENT TYPE: {document_type}
[DOCUMENT CONTENT ATTACHED EXTERNALLY]
""",
        "report_4_persona_deep_dive": f"""
System Objective: You are an AI routing mechanism. Immediately adopt the persona of the most elite, specialized forensic expert suited to analyze the attached document.
Format Constraints: Markdown only.
# FORENSIC DEEP-DIVE: [Document Title/Type]
**Executing Persona:** [State the specific expert persona]
## 1. EXECUTIVE SUMMARY (BLUF)
## 2. STRUCTURAL DATA SUMMARY
## 3. EXTRACTED INSIGHTS & FORENSIC OBSERVATIONS
## 4. STRATEGIC RECOMMENDATIONS & ACTIONABLE NEXT STEPS
[DOCUMENT CONTENT ATTACHED EXTERNALLY]
""",
        "report_5_structural_markdown": f"""
You are an expert document formatter. 
STRUCTURAL RECREATION: Create a Markdown version of the attached document. 
Tables must use GFM (GitHub Flavored Markdown).
DOCUMENT TYPE: {document_type}
[DOCUMENT CONTENT ATTACHED EXTERNALLY]
"""
    }

@async_retry(max_retries=3, base_delay=2.0)
async def generate_single_report(client: genai.Client, model_name: str, prompt: str, pdf_part: types.Part, semaphore: asyncio.Semaphore, is_json: bool = False) -> str:
    mime_type = "application/json" if is_json else "text/plain"
    config = types.GenerateContentConfig(temperature=0.1, response_mime_type=mime_type)
    
    async with semaphore:
        response = await client.aio.models.generate_content(
            model=model_name,
            contents=[prompt, pdf_part],
            config=config
        )
        return response.text

async def orchestrate_forensic_reports(document_uri: str, document_type: str) -> Dict[str, str]:
    logger.info(f"Initiating 5-tier forensic extraction for: {document_uri}")
    
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    
    # NATIVE IAM BINDING: No API keys required.
    client = genai.Client(vertexai=True, project=project_id, location="us-central1")
    model_name = 'gemini-2.0-pro-exp-02-05' 
    
    pdf_part = types.Part.from_uri(file_uri=document_uri, mime_type="application/pdf")
    prompts = build_prompts(document_type)
    semaphore = asyncio.Semaphore(3)
    
    tasks = [
        generate_single_report(client, model_name, prompts["report_1_json_extraction"], pdf_part, semaphore, is_json=True),
        generate_single_report(client, model_name, prompts["report_2_metadata_summary"], pdf_part, semaphore),
        generate_single_report(client, model_name, prompts["report_3_reserved_refinement"], pdf_part, semaphore),
        generate_single_report(client, model_name, prompts["report_4_persona_deep_dive"], pdf_part, semaphore),
        generate_single_report(client, model_name, prompts["report_5_structural_markdown"], pdf_part, semaphore)
    ]
    
    logger.info("Awaiting concurrent API resolutions...")
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    processed_results = []
    for i, res in enumerate(results):
        if isinstance(res, Exception):
            logger.error(f"FATAL: Thread {i+1} collapsed: {str(res)}. Quarantining slot.")
            processed_results.append(f"[QUARANTINED: THREAD EXECUTION FAILED] - {str(res)}")
        else:
            processed_results.append(res)
            
    logger.info("All 5 forensic execution threads resolved.")
    
    # In a full deployment, this dict would be vaulted to BigQuery here.
    return {
        "report_1_json_extraction": processed_results[0],
        "report_2_metadata_summary": processed_results[1],
        "report_3_reserved_refinement": processed_results[2],
        "report_4_persona_deep_dive": processed_results[3],
        "report_5_structural_markdown": processed_results[4]
    }
