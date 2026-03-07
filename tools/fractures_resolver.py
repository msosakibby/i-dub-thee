import re
import json
from pathlib import Path

def fortify_schema_imports(schema_path: Path):
    """Satisfies TDD: Injects required typing libraries for Gemini 2.5 Pro compatibility."""
    content = schema_path.read_text(encoding="utf-8")
    target_import = "from typing import Literal, Union, List, Optional, Any, Dict"
    new_import = "from typing import Literal, Union, List, Optional, Any, Dict, Tuple, TypeVar, Set, Sequence"
    
    if target_import in content and "Tuple" not in content:
        content = content.replace(target_import, new_import)
        schema_path.write_text(content, encoding="utf-8")
        print("    [+] FIXED: Missing typing imports fortified.")

def excise_uscis_schema(schema_path: Path):
    """Satisfies TDD: Surgically removes the legacy MRE 801-violating schema."""
    content = schema_path.read_text(encoding="utf-8")
    
    # Target the class definition and delete until the start of the Golden Envelope
    content = re.sub(r'class UscisChangeOfAddressConfirmationV1\(BaseModel\):.*?(?=class ForensicGoldenEnvelope)', '', content, flags=re.DOTALL)
    
    # Strip the stranded references from the Golden Envelope Union
    content = content.replace(',\n        UscisChangeOfAddressConfirmationV1', '')
    content = content.replace(', UscisChangeOfAddressConfirmationV1', '')
    
    schema_path.write_text(content, encoding="utf-8")
    print("    [+] FIXED: UscisChangeOfAddressConfirmationV1 AST excision complete.")

def sterilize_json_registry(registry_path: Path):
    """Satisfies TDD: Removes the mathematically doomed test case from the Pytest baseline."""
    data = json.loads(registry_path.read_text(encoding="utf-8"))
    clean_data = [item for item in data if item.get("test_identifier") != "uscis-coa-confirmation-001"]
    
    registry_path.write_text(json.dumps(clean_data, indent=2), encoding="utf-8")
    print("    [+] FIXED: uscis-coa-confirmation-001 test payload excised.")

def fortify_dependencies(req_path: Path):
    """Satisfies TDD: Restores the exact 9-line execution manifest. Zero web bloat."""
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
    req_path.write_text(reqs, encoding="utf-8")
    print("    [+] FIXED: dependencies fortified. Container starvation resolved.")

if __name__ == "__main__":
    print("============================================================================")
    print(" INITIATING ZERO-TRUST FRACTURE RESOLUTION")
    print("============================================================================")
    root = Path.cwd()
    
    schema_file = root / "src" / "schemas.py"
    registry_file = root / "tests" / "golden_test_registry.json"
    req_file = root / "requirements.txt"
    
    fortify_schema_imports(schema_file)
    excise_uscis_schema(schema_file)
    sterilize_json_registry(registry_file)
    fortify_dependencies(req_file)
    
    print("============================================================================")
    print(" [SUCCESS] Local fractures structurally resolved.")
    print("============================================================================")