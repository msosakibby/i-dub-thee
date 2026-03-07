import os
import sys
import argparse
import time
from pathlib import Path
from google import genai
from google.genai import types

def generate_schema_proposal(pdf_paths: list[Path], output_dir: Path, variant_name: str):
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    region = "us-central1"
    
    # Sanitize variant name for file system safety
    safe_variant = "".join([c if c.isalnum() else "_" for c in variant_name])
    artifact_path = output_dir / f"PROPOSAL_{safe_variant}.md"
    
    if artifact_path.exists():
        print(f"[INFO] Skipping {variant_name}. Proposal already exists.")
        return

    print(f"[SYSTEM] Analyzing {len(pdf_paths)} temporal variants for {variant_name}...")
    
    contents = []
    for pdf_path in pdf_paths:
        try:
            pdf_bytes = pdf_path.read_bytes()
            contents.append(types.Part.from_bytes(data=pdf_bytes, mime_type="application/pdf"))
        except Exception as e:
            print(f"[WARNING] Could not read {pdf_path.name}: {e}")

    if not contents:
        print(f"[FATAL] No valid PDFs provided for {variant_name}.")
        return

    prompt = f"""
    You are an expert forensic data architect operating under a Zero-Trust mandate.
    I have provided you with {len(pdf_paths)} distinct documents. These represent years of structural design drift for a single document class: '{variant_name}'.
    
    DIRECTIVE:
    Create a highly resilient Pydantic V2 schema that accommodates the structural realities of ALL provided documents.
    If a field exists in a newer layout but not an older one, type it as `Optional`.
    
    MANDATORY OUTPUT (Exactly Two Markdown Blocks):
    
    BLOCK 1 (Python Pydantic V2):
    Write the `pydantic` classes required to extract this data.
    - You MUST use `model_config = ConfigDict(extra='forbid')`.
    - You MUST include an `@model_validator(mode='after')` that executes double-entry GAAP mathematical checksums (if financial numbers exist).
    - You MUST use the exact `ForensicDataEntity` class below for all data fields. Do NOT invent new wrapper classes.
    
    ```python
    class SpatialCoordinatesPolygon(BaseModel):
        model_config = ConfigDict(extra='forbid')
        horizontal_x_vertices: List[float]
        vertical_y_vertices: List[float]

    class ForensicDataEntity(BaseModel):
        model_config = ConfigDict(extra='forbid')
        extracted_string_or_numeric_value: Union[str, float]
        optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
        physical_evidence_coordinates: SpatialCoordinatesPolygon
    ```
    
    BLOCK 2 (JSON Test Registry):
    Write a JSON array containing EXACTLY ONE test case for `tests/golden_test_registry.json` that represents the most complex structural variant you identified.
    - It must include "test_identifier", "should_pass": true, "taxonomy_lane": "[YourSchemaName]", "binary_header_simulation": "25504446", and a "payload" that perfectly passes your math validator.
    """
    
    contents.append(prompt)
    client = genai.Client(vertexai=True, project=project_id, location=region)
    
    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = client.models.generate_content(
                model="gemini-2.5-pro",
                contents=contents,
                config=types.GenerateContentConfig(temperature=0.0)
            )
            artifact_path.write_text(response.text, encoding='utf-8')
            print(f"[SUCCESS] Proposal Generated: {artifact_path.name}")
            break
        except Exception as e:
            error_msg = str(e).lower()
            if "429" in error_msg or "quota" in error_msg:
                print(f"[WARNING] Quota hit. Backing off for 30s... (Attempt {attempt+1}/{max_retries})")
                time.sleep(30)
            elif "400" in error_msg and "payload" in error_msg:
                 print(f"[FATAL] Payload too large for API. Skipping {variant_name}.")
                 break
            else:
                print(f"[FATAL] API Error: {e}")
                break

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdfs", nargs='+', required=True)
    parser.add_argument("--variant", required=True)
    args = parser.parse_args()
    
    out_dir = Path("staging/proposed_schemas")
    out_dir.mkdir(parents=True, exist_ok=True)
    
    pdf_files = [Path(p) for p in args.pdfs]
    generate_schema_proposal(pdf_files, out_dir, args.variant)
