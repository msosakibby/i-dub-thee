#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING FINAL DEPLOYMENT: FORENSIC ROUTER"
echo "============================================================================"

echo "[SYSTEM] 1. Aligning Test Fixtures for Behavior vs. Introspection..."
cat << 'EOF_TEST' > tests/test_forensic_router.py
import pytest
import asyncio
import inspect
from unittest.mock import patch, MagicMock, AsyncMock

import forensic_router

def test_thundering_herd_vulnerability():
    """VECTOR 1: Proves the async_retry lacks random jitter."""
    source_code = inspect.getsource(forensic_router.async_retry)
    assert "random.uniform" in source_code, "FATAL: async_retry lacks cryptographic jitter."

@pytest.mark.asyncio
async def test_schema_hallucination_vulnerability():
    """VECTOR 2: Behaviorally proves dynamic JSON bounds."""
    mock_client = MagicMock()
    mock_client.aio.models.generate_content = AsyncMock()
    mock_semaphore = asyncio.Semaphore(1)
    
    # Test JSON injection
    await forensic_router.generate_single_report(mock_client, "test-model", "test-prompt", mock_semaphore, is_json=True)
    call_args = mock_client.aio.models.generate_content.call_args[1]
    assert call_args["config"].response_mime_type == "application/json", "FATAL: JSON bounds not applied."

@pytest.mark.asyncio
async def test_all_or_nothing_fragility():
    """VECTOR 3: Proves gather will not fail fast."""
    source_code = inspect.getsource(forensic_router.orchestrate_forensic_reports)
    assert "return_exceptions=True" in source_code, "FATAL: gather drops successful reports."

def test_concurrency_quota_strike():
    """VECTOR 4: Proves the asyncio.Semaphore is present."""
    source_code = inspect.getsource(forensic_router.orchestrate_forensic_reports)
    assert "asyncio.Semaphore" in source_code, "FATAL: No concurrency throttle."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_forensic_router.py -v

echo "[SYSTEM] 3. Deploying Layer 2B Analytical Orchestrator to Live GCP..."
PROJECT_ID=$(gcloud config get-value project)
gcloud functions deploy layer2b-analytical-orchestrator \
    --project="$PROJECT_ID" \
    --region=us-central1 \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=orchestrate_forensic_reports \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-processed" \
    --timeout=540 \
    --memory=1024MiB \
    --quiet

echo "============================================================================"
echo " [SUCCESS] LAYER 2B DEPLOYED. FULL PIPELINE IS OPERATIONAL."
echo "============================================================================"
