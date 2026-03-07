#!/bin/bash
set -e

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: TDD FIXTURES FOR L2B BLAST WALLS"
echo "============================================================================"

mkdir -p tests

cat << 'EOF_PYTHON_L2B_ISOLATION_TESTS' > tests/test_layer2b_isolation.py
import pytest
import asyncio
from pydantic import ValidationError
from unittest.mock import AsyncMock, patch

# ==============================================================================
# IMPORT STUBS FOR FUTURE IMPLEMENTATION
# These will fail until Layer 2B forensic_router.py is engineered to satisfy them.
# ==============================================================================
try:
    from pristine_deployment_chamber.forensic_router import (
        ForensicExhaustiveJSON,
        run_concurrent_forensics
    )
except ImportError:
    ForensicExhaustiveJSON = None
    run_concurrent_forensics = None

# ==============================================================================
# ISOLATION-1: FLATTENED SCHEMA VALIDATION
# ==============================================================================
def test_flattened_schema_acceptance():
    """Validates the removal of nested $defs to prevent LLM schema hallucinations."""
    if ForensicExhaustiveJSON is None:
        pytest.skip("Implementation missing")
    
    # Valid flat payload
    valid_payload = {
        "document_summary": "Allstate Policy Binder",
        "extracted_data_points": [
            {"key_name": "Policy Number", "extracted_value": "123456789", "data_type": "string"}
        ]
    }
    
    schema_instance = ForensicExhaustiveJSON(**valid_payload)
    assert schema_instance.document_summary == "Allstate Policy Binder"
    assert len(schema_instance.extracted_data_points) == 1
    
    # Invalid payload (Testing the extra='forbid' Iron Gate)
    invalid_payload = valid_payload.copy()
    invalid_payload["$defs"] = {"ExtractedDataPoint": "hallucination"}
    
    with pytest.raises(ValidationError):
        ForensicExhaustiveJSON(**invalid_payload)

# ==============================================================================
# ISOLATION-2: ASYNC THREAD BLAST WALLS
# ==============================================================================
def test_async_blast_wall_isolation():
    """Validates that a single thread failure does not vaporize the other 5 reports."""
    if run_concurrent_forensics is None:
        pytest.skip("Implementation missing")
    
    # We mock the internal execute_prompt to succeed 5 times and fail once (Thread 5)
    async def mock_execute_prompt(client, model_id, doc_part, prompt, schema=None, is_json=False):
        if is_json:
            raise ValueError("FATAL: Simulated Pydantic Validation Error in Thread 5")
        return "# Successful Markdown Execution"

    with patch("pristine_deployment_chamber.forensic_router.execute_prompt", new=mock_execute_prompt):
        # We run the orchestrator synchronously for the test
        results = asyncio.run(run_concurrent_forensics("dummy_project", b"%PDF-1.4 mock bytes"))
        
        # Assert the 5 Markdown reports survived the blast radius
        assert results["report_1"] == "# Successful Markdown Execution"
        assert results["report_2"] == "# Successful Markdown Execution"
        assert results["report_3"] == "# Successful Markdown Execution"
        assert results["report_4"] == "# Successful Markdown Execution"
        assert results["report_6"] == "# Successful Markdown Execution"
        
        # Assert Thread 5 safely degraded into a JSON error payload instead of crashing the app
        assert "error" in results["report_5"].lower() or "failed" in results["report_5"].lower()
        # Must still be parsable JSON
        import json
        try:
            parsed = json.loads(results["report_5"])
            assert isinstance(parsed, dict)
        except json.JSONDecodeError:
            pytest.fail("Thread 5 error fallback did not output valid JSON.")

EOF_PYTHON_L2B_ISOLATION_TESTS

echo "[SYSTEM] TDD Fixtures successfully written to tests/test_layer2b_isolation.py"
echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
