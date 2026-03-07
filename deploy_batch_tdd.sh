#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TDD PHASE: PORT-FREE BATCH ARCHITECTURE (RED STATE)"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring Pytest Fixtures (tests/test_batch_entry.py)..."
cat << 'EOF_TEST' > tests/test_batch_entry.py
import pytest
import os
import ast

def test_functions_framework_eradicated():
    """VECTOR 1: Proves the web server framework is completely removed from dependencies."""
    if not os.path.exists("requirements.txt"):
        pytest.fail("FATAL: requirements.txt is missing.")
    with open("requirements.txt", "r") as f:
        content = f.read()
    assert "functions-framework" not in content, "FATAL: Web server framework still present in dependencies. Cloud Build will force a web server."

def test_batch_entry_point_exists():
    """VECTOR 2: Proves the existence of a port-free batch entry point."""
    assert os.path.exists("batch_main.py"), "FATAL: batch_main.py does not exist."

def test_environment_variable_parsing():
    """VECTOR 3: Proves the entry point parses CE_BUCKET and CE_SUBJECT natively."""
    if not os.path.exists("batch_main.py"):
        pytest.skip("FATAL: batch_main.py missing.")
    
    with open("batch_main.py", "r") as f:
        source = f.read()
    tree = ast.parse(source)
    
    # Introspect the AST to verify os.environ.get is targeting the exact Eventarc variables
    env_vars = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            if getattr(node.func, "attr", "") == "get":
                value_node = getattr(node.func, "value", None)
                if getattr(value_node, "id", "") == "environ":
                    if node.args and hasattr(node.args[0], "value"):
                        env_vars.append(node.args[0].value)
                        
    assert "CE_BUCKET" in env_vars, "FATAL: Code does not parse Eventarc CE_BUCKET."
    assert "CE_SUBJECT" in env_vars, "FATAL: Code does not parse Eventarc CE_SUBJECT."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting Massive Failure/Red State)..."
python3 -m pytest tests/test_batch_entry.py -v || true

echo "============================================================================"
echo " [WAITING FOR RED STATE TELEMETRY]"
echo "============================================================================"
