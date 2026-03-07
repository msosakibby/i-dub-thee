import pytest
import json
from pathlib import Path
from tools.realign_v17_platinum import sanitize_schemas, amputate_split_brain, fortify_dependencies, excise_poison_pill

@pytest.fixture
def corrupted_workspace(tmp_path: Path):
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    schema_file = src_dir / "schemas.py"
    corrupted_content = """from pydantic import BaseModel, ConfigDict, Field
class SpatialCoordinatesPolygon(BaseModel):
    pass
class ForensicDataEntity(BaseModel):
    pass
class Lane00GeneralTransactionalSchema(BaseModel):
    test: ForensicDataEntity
class BoundingBox(BaseModel):
    horizontal_x_vertices: list
class FinancialDisclosure(BaseModel):
    pass
class AntenuptualAgreement(BaseModel):
    party_one: FinancialDisclosure
class ForensicGoldenEnvelope(BaseModel):
    extracted_payload: Union[Lane00GeneralTransactionalSchema, AntenuptualAgreement]
"""
    schema_file.write_text(corrupted_content, encoding='utf-8')
    
    rag_dir = tmp_path / "rag_api"
    rag_dir.mkdir()
    (rag_dir / "main.py").write_text("FastAPI Code")
    
    req_file = tmp_path / "requirements.txt"
    req_file.write_text("pydantic==2.6.1\nfastapi>=0.109.0")
    
    test_dir = tmp_path / "tests"
    test_dir.mkdir()
    registry_file = test_dir / "golden_test_registry.json"
    registry_file.write_text(json.dumps([{"test_identifier": "TEST_VALID"}, {"test_identifier": "20050716_grandy_antenuptial_full.pdf"}]))
    
    return tmp_path

def test_ast_schema_sanitization_and_poison_excision(corrupted_workspace):
    schema_file = corrupted_workspace / "src" / "schemas.py"
    sanitize_schemas(schema_file)
    cleaned = schema_file.read_text(encoding='utf-8')
    
    assert cleaned.count("class SpatialCoordinatesPolygon(BaseModel):") == 1
    assert "class BoundingBox" not in cleaned
    assert "class AntenuptualAgreement" not in cleaned, "FATAL: Poison class survived."
    assert "class FinancialDisclosure" not in cleaned, "FATAL: Orphaned nested class survived."
    assert "AntenuptualAgreement" not in cleaned[cleaned.find("class ForensicGoldenEnvelope"):]

def test_architectural_amputation(corrupted_workspace):
    amputate_split_brain(corrupted_workspace)
    assert not (corrupted_workspace / "rag_api").exists()

def test_dependency_fortification(corrupted_workspace):
    fortify_dependencies(corrupted_workspace)
    reqs = (corrupted_workspace / "requirements.txt").read_text()
    assert "functions-framework>=3.8.0" in reqs
    assert "fastapi" not in reqs, "FATAL: FastAPI bloat survived fortification."

def test_baseline_excision(corrupted_workspace):
    excise_poison_pill(corrupted_workspace)
    registry = json.loads((corrupted_workspace / "tests" / "golden_test_registry.json").read_text())
    assert len(registry) == 1
