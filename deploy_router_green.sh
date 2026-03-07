#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING GREEN STATE: WEAPONIZING FORENSIC ROUTER"
echo "============================================================================"

echo "[SYSTEM] 1. Injecting Zero-Trust Patches into forensic_router.py..."
cat << 'EOF_ROUTER' > forensic_router.py
import asyncio
import logging
import random
from typing import Dict, Any
from google import genai
from google.genai import types

# Configure strict forensic logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - FORENSIC_ROUTER - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# --- EXPONENTIAL BACKOFF DECORATOR ---
# VECTOR 1 FIX: Cryptographic Jitter injected to prevent Thundering Herd 429s
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
                    # Jitter prevents simultaneous API strikes
                    delay = (base_delay * (2 ** (retries - 1))) + random.uniform(0, 1)
                    logger.warning(f"API Exception caught: {str(e)}. Retrying {func.__name__} in {delay:.2f} seconds (Attempt {retries}/{max_retries})...")
                    await asyncio.sleep(delay)
        return wrapper
    return decorator

# --- PROMPT TEMPLATE REPOSITORY ---
def build_prompts(document_text: str, document_type: str) -> Dict[str, str]:
    """
    Generates the exact, un-truncated prompt payloads for the 5-tier extraction pipeline.
    """
    return {
        "report_1_json_extraction": f"""
You are an expert document transcriber and data analyst.
Perform an EXHAUSTIVE EXTRACTION of scanned information from the provided text.
1. Extract every piece of text, table, and handwritten notation.
2. DATA ELEMENT IDENTIFICATION: Map every identifying key (Serial #, Meter ID, Account #, SKU, Tax ID, Amounts, Dates) into a structured JSON block.

DOCUMENT TYPE: {document_type}
RAW TEXT:{document_text}
""",

        "report_2_metadata_summary": f"""
Your role is to act as a highly specialized Forensic Document Analyst. 
Analyze the provided document content thoroughly and produce a detailed report in the following strict Markdown format.

# Analysis - {document_type} - [Extract Entity Name]

| Metadata Field | Value |
| :--- | :--- |
| **Filename** | Derived from document content |
| **Title** | Main title of the document |
| **Source / Author** | Extracted Entity |
| **Subject** | Primary subject/topic |
| **Document Type** | {document_type} |

---
## Executive Summary (BLUF)
Provide a concise, bottom-line-up-front summary of the document's purpose, key findings, and any immediate anomalies or critical information. Be direct and objective.

---
## Content Analysis & Verification
Detail the main content of the document. Describe its structure, sections, and primary information. Verify any stated facts or calculations if possible. Highlight any discrepancies or significant observations related to the document's core function.

---
## Risk & Concern Assessment
Identify and assess any risks, anomalies, or potential concerns related to the document. This could include PII, unusual transactions, missing information, data inconsistencies, or anything that deviates from expected norms. Quantify risk where possible. If no risks are detected, state 'No significant risks or concerns detected based on the document content.'

---
## Structural Data Extraction Summary
Summarize the key data points extracted. Do not list every transaction, but summarize totals, date ranges, and key account numbers found.

RAW TEXT:{document_text}
""",

        "report_3_reserved_refinement": f"""
You are a Forensic QA Architect. 
Review the following document and outline a 3-step refinement strategy for extracting secondary/tertiary entities (e.g., opposing counsel, secondary beneficiaries, shell companies). Provide your output in plain, direct Markdown.

DOCUMENT TYPE: {document_type}
RAW TEXT:{document_text}
""",

        "report_4_persona_deep_dive": f"""
System Objective: You are an AI routing mechanism. First, analyze the attached text. Based strictly on the nature of the document, immediately adopt the persona of the most elite, specialized forensic expert suited to analyze it.

Format Constraints:
- Maximum length: 5 pages.
- Output must be purely Markdown. 
- You must include the exact Metadata Header provided below.

# FORENSIC DEEP-DIVE: [Document Title/Type]
**Executing Persona:** [State the specific expert persona you have adopted and why]

## 1. EXECUTIVE SUMMARY (BLUF)
[A concise, bottom-line-up-front statement identifying the most critical hidden risk, liability, or actionable intelligence within the document.]

## 2. STRUCTURAL DATA SUMMARY
[Create a visually dense, logically grouped GFM table extracting the most critical identifying keys, amounts, and dates.]

## 3. EXTRACTED INSIGHTS & FORENSIC OBSERVATIONS
[Detail the "not readily obvious" findings. Look for gap analyses, structural anomalies, or patterns that deviate from standard baselines.]

## 4. STRATEGIC RECOMMENDATIONS & ACTIONABLE NEXT STEPS
[Provide a prioritized, numbered list of immediate actions. What must be subpoenaed next?]

RAW TEXT:{document_text}
""",

        "report_5_structural_markdown": f"""
You are an expert document formatter. 
STRUCTURAL RECREATION: Create a Markdown version of the provided text. 
Tables must use GFM (GitHub Flavored Markdown). Formatting (bold/italics/headers) must mirror the original's physical layout as closely as possible based on the text provided. Do not invent data.

DOCUMENT TYPE: {document_type}
RAW TEXT:{document_text}
"""
    }

# --- ASYNC EXECUTION ENGINE ---
# VECTOR 4 FIX: Added Semaphore injection for concurrency throttling
@async_retry(max_retries=3, base_delay=2.0)
async def generate_single_report(client: genai.Client, model_name: str, prompt: str, semaphore: asyncio.Semaphore, is_json: bool = False) -> str:
    """
    Executes a single prompt against the Gemini 2.x API using asynchronous networking.
    """
    # VECTOR 2 FIX: Dynamically apply strict JSON boundaries based on report type
    mime_type = "application/json" if is_json else "text/plain"
    
    config = types.GenerateContentConfig(
        temperature=0.1, 
        response_mime_type=mime_type
    )
    
    # Throttle outbound requests to respect project quotas
    async with semaphore:
        response = await client.aio.models.generate_content(
            model=model_name,
            contents=prompt,
            config=config
        )
        return response.text

async def orchestrate_forensic_reports(document_text: str, document_type: str, api_key: str) -> Dict[str, str]:
    """
    Master deployment function. Orchestrates 5 concurrent Gemini 2.x API calls.
    """
    if not document_text or not document_text.strip():
        raise ValueError("FATAL: document_text cannot be empty.")
    
    logger.info(f"Initiating 5-tier forensic extraction for document type: {document_type}")
    
    client = genai.Client(api_key=api_key)
    model_name = 'gemini-2.0-pro-exp-02-05' 
    
    prompts = build_prompts(document_text, document_type)
    
    # VECTOR 4 FIX: Initialize Semaphore (Max 3 concurrent inflight requests)
    semaphore = asyncio.Semaphore(3)
    
    # Map tasks concurrently, explicitly flagging report 1 for JSON schema constraints
    tasks = [
        generate_single_report(client, model_name, prompts["report_1_json_extraction"], semaphore, is_json=True),
        generate_single_report(client, model_name, prompts["report_2_metadata_summary"], semaphore),
        generate_single_report(client, model_name, prompts["report_3_reserved_refinement"], semaphore),
        generate_single_report(client, model_name, prompts["report_4_persona_deep_dive"], semaphore),
        generate_single_report(client, model_name, prompts["report_5_structural_markdown"], semaphore)
    ]
    
    logger.info("Awaiting concurrent API resolutions...")
    # VECTOR 3 FIX: return_exceptions=True captures partial failures without destroying successful data
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    processed_results = []
    for i, res in enumerate(results):
        if isinstance(res, Exception):
            logger.error(f"FATAL: Thread {i+1} collapsed: {str(res)}. Quarantining slot.")
            processed_results.append(f"[QUARANTINED: THREAD EXECUTION FAILED] - {str(res)}")
        else:
            processed_results.append(res)
            
    logger.info("All 5 forensic execution threads resolved.")
    
    return {
        "report_1_json_extraction": processed_results[0],
        "report_2_metadata_summary": processed_results[1],
        "report_3_reserved_refinement": processed_results[2],
        "report_4_persona_deep_dive": processed_results[3],
        "report_5_structural_markdown": processed_results[4]
    }
EOF_ROUTER

echo "[SYSTEM] 2. Re-Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_forensic_router.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
