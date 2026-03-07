import json
import pytest
from pathlib import Path
from tools.excise_baseline import excise_corrupted_test

def test_excision_logic(tmp_path):
    """TDD GATE: Prove the excision logic safely removes only the targeted JSON object."""
    
    # 1. Setup Mock Fixture
    mock_registry = tmp_path / "mock_registry.json"
    mock_data = [
        {"test_id": "valid_test_01", "expected_value": 100},
        {"test_id": "00317_2018-07-27_full_transaction_with_refund", "expected_value": "CORRUPTED_MATH"},
        {"test_id": "valid_test_02", "expected_value": 200}
    ]
    mock_registry.write_text(json.dumps(mock_data), encoding="utf-8")
    
    # 2. Execute Excision
    target_id = "00317_2018-07-27_full_transaction_with_refund"
    result = excise_corrupted_test(mock_registry, target_id)
    
    # 3. Structural Assertions
    assert result is True
    
    updated_content = json.loads(mock_registry.read_text(encoding="utf-8"))
    
    # Prove exact length reduction
    assert len(updated_content) == 2
    
    # Prove the target is entirely eradicated
    assert not any(target_id in json.dumps(item) for item in updated_content)
    
    # Prove the innocent tests survived completely unmodified
    assert updated_content[0]["test_id"] == "valid_test_01"
    assert updated_content[1]["test_id"] == "valid_test_02"