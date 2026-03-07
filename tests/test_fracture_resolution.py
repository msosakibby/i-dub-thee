import pytest
import json
from pathlib import Path
from tools.fracture_resolver import fortify_schema_imports, excise_uscis_schema, sterilize_json_registry, fortify_dependencies

@pytest.fixture
def fractured_workspace(tmp_path: Path):
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    schema_file = src_dir / "schemas.py"
    schema_file.write_text("# FORENSIC STANDARD LIBRARY IMPORTS\nfrom typing import Literal, Union, List, Optional, Any, Dict\nimport pydantic\nfrom pydantic import BaseModel\nclass UscisChangeOfAddressConfirmationV1(BaseModel):\n    pass\nclass ForensicGoldenEnvelope(BaseModel):\n    extracted_payload: Union[\n        Lane00GeneralTransactionalSchema,\n        UscisChangeOfAddressConfirmationV1\n    ]\n", encoding="utf-8")
    
    test_dir = tmp_path / "tests"
    test_dir.mkdir()
    registry_file = test_dir / "golden_test_registry.json"
    registry_file.write_text(json.dumps([{"test_identifier": "TEST_VALID"}, {"test_identifier": "uscis-coa-confirmation-001"}]), encoding="utf-8")
    
    req_file = tmp_path / "requirements.txt"
    req_file.write_text("google-cloud-storage==2.14.0\n", encoding="utf-8")
    return tmp_path

def test_ast_import_fortification(fractured_workspace):
    schema_file = fractured_workspace / "src" / "schemas.py"
    fortify_schema_imports(schema_file)
    assert "Tuple" in schema_file.read_text(encoding="utf-8")

def test_uscis_schema_excision(fractured_workspace):
    schema_file = fractured_workspace / "src" / "schemas.py"
    excise_uscis_schema(schema_file)
    assert "class UscisChangeOfAddressConfirmationV1" not in schema_file.read_text(encoding="utf-8")

def test_registry_sterilization(fractured_workspace):
    registry_file = fractured_workspace / "tests" / "golden_test_registry.json"
    sterilize_json_registry(registry_file)
    assert len(json.loads(registry_file.read_text(encoding="utf-8"))) == 1

def test_dependency_fortification(fractured_workspace):
    req_file = fractured_workspace / "requirements.txt"
    fortify_dependencies(req_file)
    assert "functions-framework" in req_file.read_text(encoding="utf-8")
