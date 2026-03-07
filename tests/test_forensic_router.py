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
