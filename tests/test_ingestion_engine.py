import pytest
import json
from pathlib import Path
from unittest.mock import patch, MagicMock

# We represent the future implementation as 'ingestor'
# (The actual file will be created in the implementation phase)

def test_markdown_extraction_logic():
    """CRITICAL GATE: The engine must flawlessly split the Python and JSON blocks."""
    mock_markdown = """
    Some LLM preamble text.
    BLOCK 1 (Python Pydantic V2):
    ```python
    class Lane99TestSchema(BaseModel):
        issuer_name: ForensicDataEntity
    ```
    Some middle text.
    BLOCK 2 (JSON Test Registry):
    ```json
    [
      {"test_identifier": "test-99", "payload": {}}
    ]
    ```
    """
    from tools import schema_ingestor
    
    python_code, json_code = schema_ingestor.extract_blocks(mock_markdown)
    
    assert "class Lane99TestSchema" in python_code
    assert "test-99" in json_code
    assert "```" not in python_code # Must strip markdown backticks
    assert "```" not in json_code

def test_schema_injection_logic(tmp_path):
    """CRITICAL GATE: Must splice code before the Envelope and update the Union."""
    mock_schema_file = tmp_path / "schemas.py"
    mock_schema_file.write_text("""
class Lane01PropertyRealEstateSchema(BaseModel):
    pass

class ForensicGoldenEnvelope(BaseModel):
    extracted_payload: Union[
        Lane00GeneralTransactionalSchema, Lane01PropertyRealEstateSchema
    ]
""", encoding="utf-8")

    new_python_code = "class Lane99TestSchema(BaseModel):\n    pass\n"
    new_schema_name = "Lane99TestSchema"

    from tools import schema_ingestor
    schema_ingestor.inject_python_schema(mock_schema_file, new_python_code, new_schema_name)

    modified_code = mock_schema_file.read_text(encoding="utf-8")
    
    # Assert the class was injected
    assert "class Lane99TestSchema(BaseModel):" in modified_code
    # Assert the class was injected BEFORE the Envelope
    assert modified_code.find("class Lane99TestSchema") < modified_code.find("class ForensicGoldenEnvelope")
    # Assert the Union was updated safely
    assert "Lane01PropertyRealEstateSchema, Lane99TestSchema" in modified_code

@patch('subprocess.run')
def test_scorched_earth_rollback(mock_subprocess, tmp_path):
    """CRITICAL GATE: If Pytest fails, the system must revert all files to original state."""
    # Simulate a Pytest failure (returncode != 0)
    mock_result = MagicMock()
    mock_result.returncode = 1 
    mock_subprocess.return_value = mock_result

    mock_schema_file = tmp_path / "schemas.py"
    mock_test_file = tmp_path / "golden_test_registry.json"
    
    original_schema_content = "ORIGINAL_SCHEMA_STATE"
    original_test_content = '["ORIGINAL_TEST_STATE"]'
    
    mock_schema_file.write_text(original_schema_content)
    mock_test_file.write_text(original_test_content)

    from tools import schema_ingestor
    
    # Execute the dangerous process
    success = schema_ingestor.process_proposal(
        proposal_text="MOCK_MARKDOWN",
        schema_path=mock_schema_file,
        test_path=mock_test_file,
        variant_name="TestVariant"
    )

    # Assert it recognized the failure
    assert success is False
    
    # Assert the files were rolled back to their exact original state
    assert mock_schema_file.read_text() == original_schema_content
    assert mock_test_file.read_text() == original_test_content

