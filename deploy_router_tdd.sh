#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TDD PHASE: FORENSIC ROUTER HARDENING (RED STATE)"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring Target Code (forensic_router.py)..."
cat << 'EOF_ROUTER' > forensic_router.py
import asyncio
import logging
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
                    delay = base_delay * (2 ** (retries - 1))
                    logger.warning(f"API Exception caught: {str(e)}. Retrying {func.__name__} in {delay} seconds...")
                    await asyncio.sleep(delay)
        return wrapper
    return decorator

def build_prompts(document_text: str, document_type: str) -> Dict[str, str]:
    return {
        "report_1_json_extraction": f"Extract JSON. DOC: {document_type} TEXT: {document_text}",
        "report_2_metadata_summary": f"Extract Metadata. DOC: {document_type} TEXT: {document_text}",
        "report_3_reserved_refinement": f"Refine logic. DOC: {document_type} TEXT: {document_text}",
        "report_4_persona_deep_dive": f"Deep dive. DOC: {document_type} TEXT: {document_text}",
        "report_5_structural_markdown": f"Markdown map. DOC: {document_type} TEXT: {document_text}"
    }

@async_retry(max_retries=3, base_delay=2.0)
async def generate_single_report(client: genai.Client, model_name: str, prompt: str) -> str:
    response = await client.aio.models.generate_content(
        model=model_name,
        contents=prompt,
        config=types.GenerateContentConfig(temperature=0.1)
    )
    return response.text

async def orchestrate_forensic_reports(document_text: str, document_type: str, api_key: str) -> Dict[str, str]:
    if not document_text or not document_text.strip():
        raise ValueError("FATAL: document_text cannot be empty.")
    
    client = genai.Client(api_key=api_key)
    model_name = 'gemini-2.0-pro-exp-02-05' 
    prompts = build_prompts(document_text, document_type)
    
    tasks = [
        generate_single_report(client, model_name, prompts["report_1_json_extraction"]),
        generate_single_report(client, model_name, prompts["report_2_metadata_summary"]),
        generate_single_report(client, model_name, prompts["report_3_reserved_refinement"]),
        generate_single_report(client, model_name, prompts["report_4_persona_deep_dive"]),
        generate_single_report(client, model_name, prompts["report_5_structural_markdown"])
    ]
    
    results = await asyncio.gather(*tasks)
    
    return {
        "report_1_json_extraction": results[0],
        "report_2_metadata_summary": results[1],
        "report_3_reserved_refinement": results[2],
        "report_4_persona_deep_dive": results[3],
        "report_5_structural_markdown": results[4]
    }
EOF_ROUTER

echo "[SYSTEM] 2. Authoring Pytest Fixtures (tests/test_forensic_router.py)..."
cat << 'EOF_TEST' > tests/test_forensic_router.py
import pytest
import asyncio
import ast
import inspect
from unittest.mock import patch, MagicMock, AsyncMock

import forensic_router

def test_thundering_herd_vulnerability():
    """VECTOR 1: Proves the async_retry lacks random jitter."""
    source_code = inspect.getsource(forensic_router.async_retry)
    assert "random.uniform" in source_code, "FATAL: async_retry lacks cryptographic jitter. Thundering herd timeout imminent."

def test_schema_hallucination_vulnerability():
    """VECTOR 2: Proves the generation config lacks strict JSON bounds."""
    source_code = inspect.getsource(forensic_router.generate_single_report)
    assert "response_mime_type" in source_code, "FATAL: generate_single_report does not dynamically enforce JSON structure."

@pytest.mark.asyncio
async def test_all_or_nothing_fragility():
    """VECTOR 3: Proves one API failure destroys the other 4 successful reports."""
    source_code = inspect.getsource(forensic_router.orchestrate_forensic_reports)
    assert "return_exceptions=True" in source_code, "FATAL: asyncio.gather will fail fast and drop successful reports."

def test_concurrency_quota_strike():
    """VECTOR 4: Proves the absence of an asyncio.Semaphore to throttle requests."""
    source_code = inspect.getsource(forensic_router.orchestrate_forensic_reports)
    assert "asyncio.Semaphore" in source_code, "FATAL: No concurrency throttle. Outbound bursts will trigger 429 quota bans."
EOF_TEST

echo "[SYSTEM] 3. Executing Pytest Iron Gate (Expecting Massive Failure/Red State)..."
python3 -m pytest tests/test_forensic_router.py -v || true

echo "============================================================================"
echo " [WAITING FOR RED STATE TELEMETRY]"
echo "============================================================================"
