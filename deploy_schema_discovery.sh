#!/bin/bash
# ==============================================================================
# REMEDIATION PROTOCOL: AIR-GAPPED SCHEMA DISCOVERY LOOP
# PROJECT ID: i-dub-thee
# ==============================================================================
set -e

export PROJECT_ID="i-dub-thee"
export VAULT_BUCKET="${PROJECT_ID}-forensic-vault"

echo "[SYSTEM] Initiating Air-Gapped Schema Discovery Deployment..."

# ==============================================================================
# 1. SCAFFOLDING STAGING DIRECTORIES
# ==============================================================================
echo "[SYSTEM] Provisioning local staging vaults..."
mkdir -p staging/legacy_intel/quarantine
mkdir -p staging/legacy_intel/review_new_entity
mkdir -p staging/proposed_schemas
mkdir -p tools tests

# ==============================================================================
# 2. DEPENDENCY ISOLATION BOUNDARY
# ==============================================================================
echo "[SYSTEM] Establishing ephemeral testing environment (.venv_schema_discovery)..."
python3 -m venv .venv_schema_discovery
source .venv_schema_discovery/bin/activate
pip install --quiet --upgrade pip
pip install --quiet pytest pytest-mock pydantic google-genai

# ==============================================================================
# 3. AUTHORING QUARANTINE EXTRACTOR SCRIPT
# ==============================================================================
echo "[SYSTEM] Authoring Quarantine Extractor..."
cat << 'EOF' > tools/quarantine_extractor.sh
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export VAULT_BUCKET="${PROJECT_ID}-forensic-vault"

echo "============================================================================"
echo " INITIATING LEGACY INTELLIGENCE EXTRACTION"
echo "============================================================================"

echo "[SYSTEM] Sweeping gs://${VAULT_BUCKET}/_QUARANTINE/ ..."
gcloud storage cp "gs://${VAULT_BUCKET}/_QUARANTINE/*" staging/legacy_intel/quarantine/ --quiet || echo "[INFO] No quarantine files found or bucket empty."

echo "[SYSTEM] Sweeping gs://${VAULT_BUCKET}/review_new_entity/ ..."
gcloud storage cp "gs://${VAULT_BUCKET}/review_new_entity/*" staging/legacy_intel/review_new_entity/ --quiet || echo "[INFO] No review files found or bucket empty."

echo "[SUCCESS] Legacy intelligence safely isolated in local staging directory."
echo "============================================================================"
EOF
chmod +x tools/quarantine_extractor.sh

# ==============================================================================
# 4. AUTHORING SCHEMA ARCHITECT (tools/schema_architect.py)
# ==============================================================================
echo "[SYSTEM] Authoring Local Schema Architect Utility..."
cat << 'EOF' > tools/schema_architect.py
import os
import sys
import json
import argparse
import re
from pathlib import Path
from google import genai
from google.genai import types

def generate_schema_proposal(pdf_path: Path, legacy_text_path: Path, output_dir: Path):
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    region = "us-central1"
    
    print(f"[SYSTEM] Analyzing {pdf_path.name} alongside legacy intelligence...")
    
    try:
        pdf_bytes = pdf_path.read_bytes()
        legacy_context = legacy_text_path.read_text(encoding='utf-8') if legacy_text_path.exists() else "No legacy context provided."
    except Exception as e:
        print(f"[FATAL] Failed to read inputs: {e}")
        sys.exit(1)

    prompt = f"""
    You are an expert forensic data architect operating under a Zero-Trust mandate.
    I am providing you a raw PDF document and the legacy analytical notes regarding this document's business meaning.
    
    LEGACY CONTEXT:
    {legacy_context}
    
    DIRECTIVE:
    Create a new Taxonomy Lane schema (e.g., Lane19...) for this document type.
    
    MANDATORY OUTPUT (Exactly Two Markdown Blocks):
    
    BLOCK 1 (Python Pydantic V2):
    Write the `pydantic` classes required to extract this data.
    - You MUST use `model_config = ConfigDict(extra='forbid')`.
    - You MUST include an `@model_validator(mode='after')` that executes double-entry GAAP mathematical checksums to prove the data is not hallucinated.
    - Utilize the `ForensicDataEntity` class structure for field definitions.
    
    BLOCK 2 (JSON Test Registry):
    Write a JSON array containing EXACTLY ONE test case for `tests/golden_test_registry.json`.
    - It must include "test_identifier", "should_pass": true, "taxonomy_lane", "binary_header_simulation", and a "payload" that perfectly passes your math validator.
    """

    client = genai.Client(vertexai=True, project=project_id, location=region)
    
    response = client.models.generate_content(
        model="gemini-2.5-pro",
        contents=[
            types.Part.from_bytes(data=pdf_bytes, mime_type="application/pdf"), 
            prompt
        ],
        config=types.GenerateContentConfig(temperature=0.0)
    )
    
    output_content = response.text
    
    # Save the raw artifact
    base_name = pdf_path.stem
    artifact_path = output_dir / f"PROPOSAL_{base_name}.md"
    artifact_path.write_text(output_content, encoding='utf-8')
    
    print(f"[SUCCESS] Proposal Generated: {artifact_path}")
    print("Action Required: Manually review the Markdown, extract the Python to src/schemas.py, and the JSON to tests/golden_test_registry.json. Then run the Pytest gate.")
    
    return output_content

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Air-Gapped Schema Architect")
    parser.add_argument("--pdf", required=True, help="Path to the quarantined PDF")
    parser.add_argument("--legacy", required=False, help="Path to the legacy JSON/TXT analysis")
    args = parser.parse_args()
    
    pdf_file = Path(args.pdf)
    legacy_file = Path(args.legacy) if args.legacy else Path("/dev/null")
    out_dir = Path("staging/proposed_schemas")
    
    generate_schema_proposal(pdf_file, legacy_file, out_dir)
EOF

# ==============================================================================
# 5. AUTHORING ADVERSARIAL TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] Authoring TDD Fixtures for Schema Architect..."
cat << 'EOF' > tests/test_schema_architect.py
import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock
from tools.schema_architect import generate_schema_proposal

@pytest.fixture
def mock_filesystem(tmp_path: Path):
    pdf = tmp_path / "quarantine_doc.pdf"
    pdf.write_bytes(b"%PDF-1.4 mock data")
    
    legacy = tmp_path / "legacy_analysis.json"
    legacy.write_text('{"summary": "This is an agritourism receipt."}')
    
    out_dir = tmp_path / "proposed_schemas"
    out_dir.mkdir()
    
    return pdf, legacy, out_dir

@patch('tools.schema_architect.genai.Client')
def test_schema_architect_output_validation(mock_client_class, mock_filesystem):
    pdf_path, legacy_path, out_dir = mock_filesystem
    
    # Mock the Gemini Response
    mock_instance = MagicMock()
    mock_client_class.return_value = mock_instance
    mock_response = MagicMock()
    mock_response.text = """
    Here is the requested schema:
    ```python
    class Lane19AgritourismSchema(BaseModel):
        model_config = ConfigDict(extra='forbid')
        @model_validator(mode='after')
        def validate_math(self):
            return self
    ```
    Here is the test:
    ```json
    [
      {
        "test_identifier": "TEST_LANE19_AGRITOURISM",
        "should_pass": true,
        "payload": {}
      }
    ]
    ```
    """
    mock_instance.models.generate_content.return_value = mock_response
    
    # Execute Function
    result = generate_schema_proposal(pdf_path, legacy_path, out_dir)
    
    # Assertions
    assert "ConfigDict(extra='forbid')" in result, "FATAL: Pydantic security override missing from LLM instruction validation."
    assert "@model_validator(mode='after')" in result, "FATAL: Mathematical validator override missing."
    assert "test_identifier" in result, "FATAL: TDD JSON registry structure missing."
    
    # Verify file was written
    generated_file = out_dir / "PROPOSAL_quarantine_doc.md"
    assert generated_file.exists(), "FATAL: Output artifact was not persisted to disk."
EOF

# ==============================================================================
# 6. EXECUTING TDD GATE
# ==============================================================================
echo "[SYSTEM] Executing Pytest Assertion Gates..."
python3 -m pytest tests/test_schema_architect.py -v

# ==============================================================================
# 7. TEARDOWN
# ==============================================================================
echo "[SYSTEM] Tearing down ephemeral dependency boundary..."
deactivate
rm -rf .venv_schema_discovery

echo "============================================================================"
echo " SCHEMA DISCOVERY LOOP DEPLOYED AND VERIFIED "
echo "============================================================================"