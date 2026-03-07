import pytest
from unittest.mock import MagicMock, patch, ANY

@patch('subprocess.run')
@patch('google.genai.Client')
def test_context_synthesis_and_invocation(mock_genai_client, mock_subprocess):
    """CRITICAL GATE: The engine must combine the broken code and the exact error into the prompt."""
    
    # 1. Setup the mock Pytest failure
    mock_result = MagicMock()
    mock_result.returncode = 1
    mock_result.stdout = "Failed: Unexpected failure: CHAIN_OF_CUSTODY_FRACTURE\nNameError: 'Decimal' is not defined"
    mock_subprocess.return_value = mock_result
    
    # 2. Setup the mock Vertex AI response
    mock_genai_instance = mock_genai_client.return_value
    mock_response = MagicMock()
    mock_response.text = "```python\n# FIXED CODE\n```\n```json\n[{}]\n```"
    mock_genai_instance.models.generate_content.return_value = mock_response

    from tools import self_healer
    
    # 3. Execute the synthesis layer
    # FIX: Added a valid JSON block to the mock input so the extraction parser does not abort early.
    fixed_text = self_healer.generate_remediation(
        broken_markdown="```python\nclass BadSchema:\n    pass\n```\n```json\n[{}]\n```",
        variant_name="TestVariant",
        project_id="test-project"
    )
    
    # 4. Assertions: Prove Vertex AI was called with the correct context
    mock_genai_instance.models.generate_content.assert_called_once()
    call_args = mock_genai_instance.models.generate_content.call_args
    sent_prompt = call_args.kwargs['contents']
    
    assert "class BadSchema" in sent_prompt
    assert "CHAIN_OF_CUSTODY_FRACTURE" in sent_prompt
    assert "'Decimal' is not defined" in sent_prompt
    assert "FIXED CODE" in fixed_text

@patch('google.cloud.storage.Client')
def test_state_routing_logic(mock_storage_client):
    """CRITICAL GATE: The engine must write to proposed/ and delete from quarantined/."""
    mock_bucket = MagicMock()
    mock_storage_client.return_value.bucket.return_value = mock_bucket
    
    # Mock the quarantined blob
    mock_quarantined_blob = MagicMock()
    mock_quarantined_blob.name = "quarantined_schemas/PROPOSAL_TestVariant.md"
    mock_quarantined_blob.download_as_text.return_value = "BROKEN_MARKDOWN"
    
    mock_bucket.list_blobs.return_value = [mock_quarantined_blob]
    
    # Mock the destination blob
    mock_proposed_blob = MagicMock()
    mock_bucket.blob.return_value = mock_proposed_blob

    from tools import self_healer
    
    # Mock the actual LLM call to isolate the routing test
    with patch('tools.self_healer.generate_remediation', return_value="FIXED_MARKDOWN"):
        self_healer.process_quarantine_queue(project_id="test-project")
        
    # Assertions: Prove the state was routed correctly
    mock_bucket.blob.assert_called_with("proposed_schemas/PROPOSAL_TestVariant.md")
    mock_proposed_blob.upload_from_string.assert_called_with("FIXED_MARKDOWN", content_type="text/markdown")
    mock_quarantined_blob.delete.assert_called_once()