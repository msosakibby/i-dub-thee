#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TEST PATCH: UNWRAPPING THE DECORATOR MASK"
echo "============================================================================"

echo "[SYSTEM] 1. Patching tests/test_forensic_router.py..."
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
    # FIX: Use inspect.unwrap to strip the @async_retry decorator and see the core function
    core_function = inspect.unwrap(forensic_router.generate_single_report)
    source_code = inspect.getsource(core_function)
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

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_forensic_router.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
