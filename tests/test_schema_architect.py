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
