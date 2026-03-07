import re
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
    core_classes = """class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon"""

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
            
    union_string = ",\n        ".join(root_schemas)
    
    envelope_class = f"""class ForensicGoldenEnvelope(BaseModel):
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
        return self"""

    imports = """# ==========================================
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
from pydantic import BaseModel, ConfigDict, Field, model_validator\n\n"""

    final_content = imports + core_classes + "\n\n" + "\n\n".join(unique_classes.values()) + "\n\n" + envelope_class + "\n"
    schema_path.write_text(final_content, encoding='utf-8')

def amputate_split_brain(workspace_root: Path):
    rag_dir = workspace_root / "rag_api"
    if rag_dir.exists() and rag_dir.is_dir():
        shutil.rmtree(rag_dir)
        print("    [+] TR-5.1 Enforced: Amputated orphaned rag_api web server.")

def fortify_dependencies(workspace_root: Path):
    req_path = workspace_root / "requirements.txt"
    # STRICT FIX: Excludes fastapi and uvicorn to maintain Zero-Idle-Cost perimeter
    reqs = """google-cloud-storage>=2.14.0
google-cloud-bigquery>=3.17.0
google-cloud-documentai>=3.4.0
google-genai>=0.3.0
functions-framework>=3.8.0
pydantic>=2.6.1
pytest>=8.0.0
pytest-mock>=3.12.0
pypdf>=4.1.0
"""
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
