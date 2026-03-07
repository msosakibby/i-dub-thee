import pytest
import os
import ast

def test_functions_framework_eradicated():
    if not os.path.exists("requirements.txt"):
        pytest.fail("FATAL: requirements.txt is missing.")
    with open("requirements.txt", "r") as f:
        content = f.read()
    assert "functions-framework" not in content, "FATAL: Web server framework still present."

def test_batch_entry_point_exists():
    assert os.path.exists("batch_main.py"), "FATAL: batch_main.py does not exist."

def test_environment_variable_parsing():
    if not os.path.exists("batch_main.py"):
        pytest.skip("FATAL: batch_main.py missing.")
    
    with open("batch_main.py", "r") as f:
        source = f.read()
    tree = ast.parse(source)
    
    env_vars = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            if getattr(node.func, "attr", "") == "get":
                value_node = getattr(node.func, "value", None)
                # THE FIX: Properly identify the os.environ attribute
                if isinstance(value_node, ast.Attribute) and getattr(value_node, "attr", "") == "environ":
                    if node.args and hasattr(node.args[0], "value"):
                        env_vars.append(node.args[0].value)
                        
    assert "CE_BUCKET" in env_vars, "FATAL: Code does not parse Eventarc CE_BUCKET."
    assert "CE_SUBJECT" in env_vars, "FATAL: Code does not parse Eventarc CE_SUBJECT."
