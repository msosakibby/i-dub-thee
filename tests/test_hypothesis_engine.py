import pytest
import json
from unittest.mock import patch, MagicMock

# Create a mock event class to satisfy the Cloud Event signature
class MockCloudEvent:
    def __init__(self, bucket, name):
        self.data = {"bucket": bucket, "name": name}

@patch('src.hypothesis_engine.process_hypothesis_request')
def test_hypothesis_trigger_gate(mock_process):
    """Proves the Cloud Function strictly isolates the investigations/ path."""
    from src.hypothesis_engine import forensic_hypothesis_trigger
    
    # Test valid path
    valid_event = MockCloudEvent("vault-bucket", "investigations/query_001.json")
    forensic_hypothesis_trigger(valid_event)
    mock_process.assert_called_once()
    mock_process.reset_mock()
    
    # Test poison paths (Should be violently rejected by the gate)
    poison_events = [
        MockCloudEvent("vault-bucket", "raw_intake/document.pdf"),
        MockCloudEvent("vault-bucket", "investigations/image.png"),
        MockCloudEvent("vault-bucket", "query_001.json") # Root path injection
    ]
    
    for event in poison_events:
        forensic_hypothesis_trigger(event)
        mock_process.assert_not_called()
