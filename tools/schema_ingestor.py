import re
import json
import subprocess
import textwrap
from pathlib import Path
from google.cloud import storage

def extract_blocks(markdown_text: str):
    """Isolates the Python and JSON blocks from the LLM markdown response."""
    python_match = re.search(r'```python\s+(.*?)\s+```', markdown_text, re.DOTALL)
    if not python_match:
        raise ValueError("Could not find the Python code block in the proposal.")
    python_code = python_match.group(1).strip()
    
    json_match = re.search(r'```json\s+(.*?)\s+```', markdown_text, re.DOTALL)
    if not json_match:
        raise ValueError("Could not find the JSON code block in the proposal.")
    json_code = json_match.group(1).strip()
    
    return python_code, json_code

def inject_python_schema(filepath: Path, new_code: str, schema_name: str):
    """Splices the new schema into schemas.py right before the Envelope."""
    content = filepath.read_text(encoding="utf-8")
    
    if f"class {schema_name}" in content:
        raise ValueError(f"Schema class {schema_name} already exists in master file. Preventing AST bloat.")
    
    envelope_idx = content.find("class ForensicGoldenEnvelope(BaseModel):")
    if envelope_idx == -1:
        raise ValueError("Could not find ForensicGoldenEnvelope in schemas.py")
        
    top_half = content[:envelope_idx]
    bottom_half = content[envelope_idx:]
    new_content = top_half + "\n" + new_code + "\n\n" + bottom_half
    
    union_match = re.search(r'(extracted_payload:\s*Union\[)(.*?)(\])', new_content, re.DOTALL)
    if not union_match:
        raise ValueError("Could not find extracted_payload Union in schemas.py")
        
    prefix = union_match.group(1)
    existing_schemas_str = union_match.group(2)
    suffix = union_match.group(3)
    
    existing_list = [s.strip() for s in existing_schemas_str.split(',')]
    
    if schema_name not in existing_list:
        existing_list.append(schema_name)
        updated_schemas = ", ".join(existing_list)
        new_content = new_content[:union_match.start()] + prefix + "\n        " + updated_schemas + "\n    " + suffix + new_content[union_match.end():]

    filepath.write_text(new_content, encoding="utf-8")

def inject_json_test(filepath: Path, new_json_str: str):
    """Appends the new test object to the JSON registry array."""
    try:
        registry = json.loads(filepath.read_text(encoding="utf-8"))
        new_test = json.loads(new_json_str)
        
        if isinstance(new_test, list):
            registry.extend(new_test)
        else:
            registry.append(new_test)
            
        filepath.write_text(json.dumps(registry, indent=2), encoding="utf-8")
    except Exception as e:
         raise ValueError(f"Failed to parse or inject JSON test: {e}")

def process_proposal(proposal_text: str, schema_path: Path, test_path: Path, variant_name: str) -> bool:
    """The master orchestration loop with Scorched-Earth Rollback."""
    print(f"\n[SYSTEM] Ingesting Proposal: {variant_name}")
    
    original_schema = schema_path.read_text(encoding="utf-8")
    original_test = test_path.read_text(encoding="utf-8")
    
    try:
        python_code, json_code = extract_blocks(proposal_text)
        
        # FIX: Strip AI imports, then brutally enforce flush-left indentation
        clean_python_code = re.sub(r'^(from\s+.*import\s+.*|import\s+.*)$', '', python_code, flags=re.MULTILINE).strip()
        clean_python_code = textwrap.dedent(clean_python_code).strip()
        
        schema_name_matches = []
        for match in re.finditer(r'class\s+([A-Za-z0-9_]+).*?:', clean_python_code):
            name = match.group(1)
            if name not in ['ForensicDataEntity', 'SpatialCoordinatesPolygon', 'BaseModel']:
                schema_name_matches.append(name)
                
        if not schema_name_matches:
            raise ValueError("Could not identify any valid Pydantic class definitions to register.")
            
        schema_name = schema_name_matches[-1]
        
        inject_python_schema(schema_path, clean_python_code, schema_name)
        inject_json_test(test_path, json_code)
        
        print("    -> Engaging Pytest Iron Gate...")
        result = subprocess.run(
            ["python3", "-m", "pytest", "tests/test_iron_gate_factory.py", "-v"],
            capture_output=True, text=True
        )
        
        if result.returncode == 0:
            print("    [+] PASS. Schema permanently merged into master codebase.")
            return True
        else:
            print("    [!] FAIL. Mathematical checksum or structural error detected.")
            print(f"    [!] Pytest Output:\n{result.stdout[-500:]}")
            raise ValueError("Pytest Factory rejected the schema.")
            
    except Exception as e:
        print(f"    [!] FATAL INGESTION ERROR: {e}")
        print("    [SYSTEM] Triggering Scorched-Earth Rollback...")
        schema_path.write_text(original_schema, encoding="utf-8")
        test_path.write_text(original_test, encoding="utf-8")
        print("    [SYSTEM] Rollback complete. Files restored to previous state.")
        return False

def run_batch_ingestion():
    """Pulls pending proposals from GCS and processes them sequentially."""
    project_id = "i-dub-thee"
    bucket_name = "i-dub-thee-forensic-vault"
    prefix = "proposed_schemas/"
    
    schema_path = Path("src/schemas.py")
    test_path = Path("tests/golden_test_registry.json")
    
    storage_client = storage.Client(project=project_id)
    bucket = storage_client.bucket(bucket_name)
    blobs = list(bucket.list_blobs(prefix=prefix))
    
    proposals = [b for b in blobs if b.name.endswith('.md')]
    print(f"============================================================================")
    print(f" INITIATING AUTOMATED INGESTION ENGINE. Pending Proposals: {len(proposals)}")
    print(f"============================================================================")
    
    success_count = 0
    fail_count = 0
    
    for blob in proposals:
        variant_name = blob.name.split('/')[-1].replace('PROPOSAL_', '').replace('.md', '')
        
        try:
            proposal_text = blob.download_as_text()
        except Exception as net_err:
            print(f"\n[!] NETWORK ERROR fetching {variant_name}. Skipping to preserve queue. Details: {net_err}")
            continue
        
        success = process_proposal(proposal_text, schema_path, test_path, variant_name)
        
        if success:
            success_count += 1
            new_name = blob.name.replace("proposed_schemas/", "accepted_schemas/")
            bucket.rename_blob(blob, new_name)
            print(f"    -> Moved to accepted queue: gs://{bucket_name}/{new_name}")
        else:
            fail_count += 1
            new_name = blob.name.replace("proposed_schemas/", "quarantined_schemas/")
            bucket.rename_blob(blob, new_name)
            print(f"    -> Quarantined for manual review: gs://{bucket_name}/{new_name}")
            
    print(f"\n============================================================================")
    print(f" [COMPLETE] Successfully Merged: {success_count} | Quarantined: {fail_count}")
    print(f"============================================================================")

if __name__ == "__main__":
    run_batch_ingestion()