import os
import zipfile
import subprocess
from pathlib import Path
from datetime import datetime

# ==============================================================================
# PART 1: THE REMEDIATION LOGIC
# ==============================================================================
REMEDIATION_CODE = """import re
import json
import shutil
from pathlib import Path

def sanitize_schemas(schema_path: Path):
    content = schema_path.read_text(encoding='utf-8')
    
    # 1. Eradicate BoundingBox class entirely
    content = re.sub(r'class BoundingBox\(BaseModel\):.*?(?=^class |\Z)', '', content, flags=re.DOTALL | re.MULTILINE)
    
    # 2. Patch hallucinated type references back to standard
    content = content.replace(': BoundingBox', ': SpatialCoordinatesPolygon')
    
    # 3. Safely split the file by class definitions to establish an AST-like dictionary
    parts = re.split(r'^(?=class \w+\(BaseModel\):)', content, flags=re.MULTILINE)
    
    unique_classes = {}
    for part in parts:
        if part.startswith('class '):
            name_match = re.search(r'^class (\w+)\(BaseModel\):', part)
            if name_match:
                name = name_match.group(1)
                unique_classes[name] = part.strip()
                
    # 4. Hardcode the absolute V17 Platinum Core Classes
    core_classes = \"\"\"class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon\"\"\"

    # 5. Remove the core classes from the scraped dictionary to prevent duplicates
    for core in ['SpatialCoordinatesPolygon', 'ForensicDataEntity', 'ForensicGoldenEnvelope']:
        unique_classes.pop(core, None)

    # 6. SURGICAL EXCISION: Remove Antenuptial Poison Pill & ALL 15 nested classes
    poison_classes = [
        'RealEstateAsset', 'BankAccount', 'InvestmentAsset', 'RetirementAsset',
        'PersonalPropertyAsset', 'BusinessOwnership', 'OtherAssetOwed',
        'SecuredLoan', 'CreditCardDebt', 'BankLoanLineOfCredit', 'PrivateLoan',
        'IncomeItem', 'ExpenseItem', 'FinancialDisclosure', 'KeithDisclosureSummary',
        'AntenuptualAgreement'
    ]
    for pc in poison_classes:
        unique_classes.pop(pc, None)
        
    # 7. Dynamically rebuild the Golden Envelope Union using ONLY valid root schemas
    root_schemas = []
    for name in unique_classes.keys():
        # Exclude known valid sub-schemas from the Envelope Root Union
        if name in ['AddressSchema', 'SequentialTransaction', 'UnifiedLineItem', 'MerchantInfo', 'CustomerInfo', 'VehicleInfo', 'ServicePart', 'ServiceItem', 'PaymentInfo', 'RefundInfo']:
            continue
        if 'Schema' in name or name in ['Rename316', 'JohnDeereUnifiedDocument', 'UscisChangeOfAddressConfirmationV1']:
            root_schemas.append(name)
            
    union_string = ",\\n        ".join(root_schemas)
    
    envelope_class = f\"\"\"class ForensicGoldenEnvelope(BaseModel):
    model_config = ConfigDict(extra='forbid')
    original_parent_sha256: str = Field(min_length=64, max_length=64)
    sliced_child_sha256: str = Field(min_length=64, max_length=64)
    gcs_source_uri: str
    entity_slug: str
    taxonomy_lane: str
    average_confidence: float = Field(ge=0.0, le=1.0)
    requires_manual_review: bool
    extracted_payload: Union[
        {union_string}
    ]

    @model_validator(mode='after')
    def enforce_hitl_governance(self) -> 'ForensicGoldenEnvelope':
        if self.average_confidence < 0.90 and not self.requires_manual_review:
            raise ValueError("HITL_VIOLATION: Document AI average confidence < 0.90 mandates manual review flag = True.")
        return self\"\"\"

    imports = \"\"\"# ==========================================
# FORENSIC STANDARD LIBRARY IMPORTS (V17 PLATINUM)
# ==========================================
import logging
import math
import decimal
from decimal import Decimal
from datetime import date, datetime
from typing import Literal, Union, List, Optional, Any, Dict
try:
    from typing import Self
except ImportError:
    from typing_extensions import Self
import pydantic
from pydantic import BaseModel, ConfigDict, Field, model_validator\\n\\n\"\"\"

    final_content = imports + core_classes + "\\n\\n" + "\\n\\n".join(unique_classes.values()) + "\\n\\n" + envelope_class + "\\n"
    schema_path.write_text(final_content, encoding='utf-8')

def amputate_split_brain(workspace_root: Path):
    rag_dir = workspace_root / "rag_api"
    if rag_dir.exists() and rag_dir.is_dir():
        shutil.rmtree(rag_dir)
        print("    [+] TR-5.1 Enforced: Amputated orphaned rag_api web server.")

def fortify_dependencies(workspace_root: Path):
    req_path = workspace_root / "requirements.txt"
    # STRICT FIX: Excludes fastapi and uvicorn to maintain Zero-Idle-Cost perimeter
    reqs = \"\"\"google-cloud-storage>=2.14.0
google-cloud-bigquery>=3.17.0
google-cloud-documentai>=3.4.0
google-genai>=0.3.0
functions-framework>=3.8.0
pydantic>=2.6.1
pytest>=8.0.0
pytest-mock>=3.12.0
pypdf>=4.1.0
\"\"\"
    req_path.write_text(reqs, encoding='utf-8')
    print("    [+] TR-2 Enforced: Fortified requirements.txt (Purged FastAPI/Uvicorn).")

def excise_poison_pill(workspace_root: Path):
    registry_path = workspace_root / "tests" / "golden_test_registry.json"
    if registry_path.exists():
        data = json.loads(registry_path.read_text(encoding='utf-8'))
        original_len = len(data)
        cleaned = [item for item in data if item.get("test_identifier") != "20050716_grandy_antenuptial_full.pdf"]
        registry_path.write_text(json.dumps(cleaned, indent=2), encoding='utf-8')
        if len(cleaned) < original_len:
            print(f"    [+] TR-4 Enforced: Excised poison pill '20050716_grandy_antenuptial_full.pdf'.")

def execute_surgery():
    root = Path.cwd()
    schema_path = root / "src" / "schemas.py"
    if schema_path.exists():
        sanitize_schemas(schema_path)
        print(f"    [+] AST Normalized: Eradicated duplicate/poison classes in src/schemas.py.")
    amputate_split_brain(root)
    fortify_dependencies(root)
    excise_poison_pill(root)

if __name__ == '__main__':
    execute_surgery()
"""

# ==============================================================================
# PART 2: THE TDD FIXTURE
# ==============================================================================
TDD_CODE = """import pytest
import json
from pathlib import Path
from tools.realign_v17_platinum import sanitize_schemas, amputate_split_brain, fortify_dependencies, excise_poison_pill

@pytest.fixture
def corrupted_workspace(tmp_path: Path):
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    schema_file = src_dir / "schemas.py"
    corrupted_content = \"\"\"from pydantic import BaseModel, ConfigDict, Field
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
\"\"\"
    schema_file.write_text(corrupted_content, encoding='utf-8')
    
    rag_dir = tmp_path / "rag_api"
    rag_dir.mkdir()
    (rag_dir / "main.py").write_text("FastAPI Code")
    
    req_file = tmp_path / "requirements.txt"
    req_file.write_text("pydantic==2.6.1\\nfastapi>=0.109.0")
    
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
"""

# ==============================================================================
# PART 3: THE AUTONOMOUS EXECUTION ENGINE
# ==============================================================================
def package_downloadable_archive():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    zip_filename = f"V17_Platinum_Restored_{timestamp}.zip"
    print(f"\\n[SYSTEM] Compressing restored V17 environment into {zip_filename}...")
    
    exclude_dirs = {'.git', '.idx', 'forensic_env', '__pycache__', '.pytest_cache', '.venv_rag_refactor', '.venv_forensic_extract', '.venv_schema_discovery'}
    
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk('.'):
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            for file in files:
                if not file.endswith('.zip') and not file.endswith('.pyc'):
                    file_path = Path(root) / file
                    zipf.write(file_path, file_path.relative_to('.'))
                    
    print("============================================================================")
    print(f" [ACTION REQUIRED] Right-click '{zip_filename}' in your IDE and select 'Download'")
    print("============================================================================")

if __name__ == "__main__":
    print("============================================================================")
    print(" INITIATING ZERO-TRUST REMEDIATION PAYLOAD ")
    print("============================================================================")
    
    Path("tools/realign_v17_platinum.py").write_text(REMEDIATION_CODE, encoding="utf-8")
    Path("tests/test_remediation.py").write_text(TDD_CODE, encoding="utf-8")
    
    print("\\n[SYSTEM] Executing Isolated TDD Gate...")
    result = subprocess.run(["python3", "-m", "pytest", "tests/test_remediation.py", "-v"], capture_output=True, text=True)
    
    if result.returncode != 0:
        print("[!] FATAL TDD FAILURE. Halting surgery.")
        print(result.stdout)
        exit(1)
        
    print("[+] TDD Gate Passed. Executing Codebase Surgery...")
    subprocess.run(["python3", "-m", "tools.realign_v17_platinum"])
    
    print("\\n[SYSTEM] Proving Master Green State (Iron Gate)...")
    gate_result = subprocess.run(["python3", "-m", "pytest", "tests/test_iron_gate_factory.py", "-v"], capture_output=True, text=True)
    
    if gate_result.returncode != 0:
        print("[!] SECONDARY FRACTURE DETECTED IN MASTER GATE.")
        print(gate_result.stdout[-1500:])
    else:
        print("[+] GREEN STATE ACHIEVED: 0 Failures.")
        
    package_downloadable_archive()