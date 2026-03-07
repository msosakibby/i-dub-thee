import subprocess
import time
import random
from pathlib import Path
from google.cloud import storage
from google import genai
from google.genai import types

def extract_error_log(schema_path: Path, test_path: Path, broken_markdown: str, variant_name: str) -> str:
    """Temporarily injects the broken schema to capture the exact Pytest error."""
    original_schema = schema_path.read_text(encoding="utf-8")
    original_test = test_path.read_text(encoding="utf-8")
    
    from tools import schema_ingestor
    
    try:
        python_code, json_code = schema_ingestor.extract_blocks(broken_markdown)
        
        import re
        import textwrap
        clean_python_code = re.sub(r'^(from\s+.*import\s+.*|import\s+.*)$', '', python_code, flags=re.MULTILINE).strip()
        clean_python_code = textwrap.dedent(clean_python_code).strip()
        
        schema_name_matches = []
        for match in re.finditer(r'class\s+([A-Za-z0-9_]+).*?:', clean_python_code):
            name = match.group(1)
            if name not in ['ForensicDataEntity', 'SpatialCoordinatesPolygon', 'BaseModel']:
                schema_name_matches.append(name)
        schema_name = schema_name_matches[-1]
        
        schema_ingestor.inject_python_schema(schema_path, clean_python_code, schema_name)
        schema_ingestor.inject_json_test(test_path, json_code)
        
    except Exception as e:
        schema_path.write_text(original_schema, encoding="utf-8")
        test_path.write_text(original_test, encoding="utf-8")
        return f"Extraction/Injection Error: {e}"

    result = subprocess.run(
        ["python3", "-m", "pytest", "tests/test_iron_gate_factory.py", "-v"],
        capture_output=True, text=True
    )
    
    error_log = result.stdout[-1500:] 
    
    schema_path.write_text(original_schema, encoding="utf-8")
    test_path.write_text(original_test, encoding="utf-8")
    
    return error_log

def generate_remediation(broken_markdown: str, variant_name: str, project_id: str) -> str:
    """Synthesizes the prompt and invokes Vertex AI for self-healing with Exponential Backoff."""
    
    schema_path = Path("src/schemas.py")
    test_path = Path("tests/golden_test_registry.json")
    
    print(f"    -> Running isolated Iron Gate to capture error trace...")
    error_trace = extract_error_log(schema_path, test_path, broken_markdown, variant_name)
    
    prompt = f"""
    You are an expert forensic data architect operating under a Zero-Trust mandate.
    
    You previously generated a Pydantic V2 schema and JSON test case for a document variant named '{variant_name}'.
    However, your code was rejected by the automated Pytest Iron Gate. It failed mathematical or structural validation.
    
    YOUR BROKEN PROPOSAL:
    {broken_markdown}
    
    THE PYTEST ERROR TRACE:
    {error_trace}
    
    DIRECTIVE:
    Analyze the Pytest error. Fix the specific Pydantic structures or JSON values that caused the failure.
    - If the error is `CHAIN_OF_CUSTODY_FRACTURE`, your JSON payload failed to pass your own Pydantic validators (e.g., GAAP checksums failed, or you included extra fields that `extra='forbid'` rejected).
    - If the error is a `SyntaxError` or `NameError`, fix the Python code. (Do not import external libraries, standard types are already injected).
    - CRITICAL: Strict Python 3.10/3.11 syntax only. Do not use PEP 695 type parameter syntax (e.g. `class Name[T]`).
    
    MANDATORY OUTPUT (Exactly Two Markdown Blocks):
    BLOCK 1 (Python Pydantic V2): Write the fixed classes.
    BLOCK 2 (JSON Test Registry): Write the fixed JSON test array.
    """
    
    genai_client = genai.Client(vertexai=True, project=project_id, location="us-central1")
    
    max_retries = 6
    base_delay = 10
    
    for attempt in range(max_retries):
        try:
            print(f"    -> Invoking Vertex AI Self-Healing mechanism (Attempt {attempt + 1})...")
            response = genai_client.models.generate_content(
                model="gemini-2.5-pro",
                contents=prompt,
                config=types.GenerateContentConfig(temperature=0.0) 
            )
            return response.text
            
        except Exception as e:
            error_str = str(e)
            if "429" in error_str or "RESOURCE_EXHAUSTED" in error_str:
                if attempt < max_retries - 1:
                    sleep_time = (base_delay * (2 ** attempt)) + random.uniform(0, 2)
                    print(f"    [!] 429 QUOTA HIT. Exponential backoff: Sleeping for {sleep_time:.2f} seconds...")
                    time.sleep(sleep_time)
                else:
                    raise RuntimeError(f"Vertex AI Rate Limit completely exhausted after {max_retries} attempts.")
            else:
                # If it's a 500 or other non-quota error, raise it immediately
                raise e

def process_quarantine_queue(project_id: str):
    """The main orchestration loop for the Self-Healing Engine."""
    bucket_name = "i-dub-thee-forensic-vault"
    prefix = "quarantined_schemas/"
    
    storage_client = storage.Client(project=project_id)
    bucket = storage_client.bucket(bucket_name)
    blobs = list(bucket.list_blobs(prefix=prefix))
    
    proposals = [b for b in blobs if b.name.endswith('.md')]
    print(f"============================================================================")
    print(f" INITIATING SELF-HEALING ENGINE. Quarantined Proposals: {len(proposals)}")
    print(f"============================================================================")
    
    for blob in proposals:
        variant_name = blob.name.split('/')[-1].replace('PROPOSAL_', '').replace('.md', '')
        print(f"\n[SYSTEM] Healing Proposal: {variant_name}")
        
        try:
            broken_text = blob.download_as_text()
            fixed_markdown = generate_remediation(broken_text, variant_name, project_id)
            
            proposed_name = blob.name.replace("quarantined_schemas/", "proposed_schemas/")
            proposed_blob = bucket.blob(proposed_name)
            proposed_blob.upload_from_string(fixed_markdown, content_type="text/markdown")
            
            blob.delete()
            print(f"    [+] PASS. Healed proposal routed to: {proposed_name}")
            
            # Base cooling period to prevent hitting the RPM limit on successful runs
            time.sleep(12)
            
        except Exception as e:
            print(f"    [!] FATAL HEALING ERROR for {variant_name}: {e}")
            
    print(f"\n============================================================================")
    print(f" [COMPLETE] Self-Healing cycle finished. Pending schemas routed to active queue.")
    print(f"============================================================================")

if __name__ == "__main__":
    process_quarantine_queue("i-dub-thee")