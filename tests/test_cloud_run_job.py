import pytest
from unittest.mock import MagicMock, patch, ANY
import io

# We represent the future implementation as 'main' for this test
# (The actual file will be created in the implementation phase)

@pytest.fixture
def mock_storage_client():
    with patch("google.cloud.storage.Client") as mock_client:
        yield mock_client

@pytest.fixture
def mock_genai_client():
    with patch("google.genai.Client") as mock_client:
        yield mock_client

def test_deduplication_logic(mock_storage_client, mock_genai_client):
    """
    CRITICAL GATE: If a proposal exists in the output bucket, 
    the engine MUST NOT invoke Vertex AI.
    """
    # Setup: Mock the bucket structure
    mock_bucket = MagicMock()
    mock_storage_client.return_value.bucket.return_value = mock_bucket

    # Mock Input: One unprocessed variant
    input_blob = MagicMock()
    input_blob.name = "_QUARANTINE/0000-00-00 - TestBank - Statement.pdf"
    input_blob.size = 1024
    
    # Mock Output: The proposal ALREADY EXISTS
    existing_blob = MagicMock()
    existing_blob.name = "proposed_schemas/PROPOSAL_TestBank_Statement.md"

    # Configure list_blobs to return inputs then outputs
    mock_bucket.list_blobs.side_effect = [
        [input_blob],          # Input sweep
        [existing_blob]        # Output/State sweep
    ]

    # Import the logic (to be written)
    from src import cloud_run_main

    # Execute
    cloud_run_main.execute_sweep(project_id="test-project")

    # Assert: Vertex AI generate_content was NEVER called
    mock_genai_client.return_value.models.generate_content.assert_not_called()

def test_stratified_sampling_logic(mock_storage_client, mock_genai_client):
    """
    CRITICAL GATE: The engine must select Smallest, Median, and Largest files.
    """
    mock_bucket = MagicMock()
    mock_storage_client.return_value.bucket.return_value = mock_bucket
    
    # Setup: Create 5 blobs of increasing size
    blobs = []
    for i in range(1, 6): # Sizes: 100, 200, 300, 400, 500
        b = MagicMock()
        b.name = f"_QUARANTINE/0000-00-00 - StratifiedBank - Doc_{i}.pdf"
        b.size = i * 100 
        blobs.append(b)

    # Mock Output: Empty (nothing processed yet)
    mock_bucket.list_blobs.side_effect = [blobs, []]

    # Import logic
    from src import cloud_run_main
    cloud_run_main.execute_sweep(project_id="test-project")

    # Assert: generate_content called exactly once
    mock_genai_client.return_value.models.generate_content.assert_called_once()
    
    # Assert: The payload contained exactly 3 parts (Smallest=100, Median=300, Largest=500)
    call_args = mock_genai_client.return_value.models.generate_content.call_args
    sent_contents = call_args.kwargs['contents']
    
    # Filter for PDF parts (exclude the text prompt)
    pdf_parts = [c for c in sent_contents if hasattr(c, 'mime_type') and c.mime_type == 'application/pdf']
    assert len(pdf_parts) == 3

def test_zero_disk_streaming(mock_storage_client, mock_genai_client):
    """
    CRITICAL GATE: Data must be read via download_as_bytes, NOT download_to_filename.
    """
    mock_bucket = MagicMock()
    mock_storage_client.return_value.bucket.return_value = mock_bucket

    blob = MagicMock()
    blob.name = "_QUARANTINE/0000-00-00 - StreamBank - Statement.pdf"
    blob.size = 500
    blob.download_as_bytes.return_value = b"%PDF-1.5..." # Fake PDF bytes

    mock_bucket.list_blobs.side_effect = [[blob], []]

    from src import cloud_run_main
    cloud_run_main.execute_sweep(project_id="test-project")

    # Assert: download_as_bytes was called
    blob.download_as_bytes.assert_called()
    
    # Assert: download_to_filename was NEVER called (Strict Zero-Disk Policy)
    blob.download_to_filename.assert_not_called()

