import pytest
from pathlib import Path
import json
from tools.generate_ghfld_mocks import generate_mocks, FORENSIC_LANES

@pytest.fixture
def mock_workspace(tmp_path: Path):
    return tmp_path

def test_ghfld_directory_creation(mock_workspace):
    """PROVES: The generator creates the target directory if it does not exist."""
    target_dir = mock_workspace / "ghfld"
    generate_mocks(target_dir)
    assert target_dir.exists(), "FATAL: ghfld directory was not created."

def test_tri_pass_artifact_count(mock_workspace):
    """PROVES: Exactly 4 artifacts are generated per taxonomy lane."""
    target_dir = mock_workspace / "ghfld"
    generate_mocks(target_dir)
    
    files = list(target_dir.glob("*"))
    expected_count = len(FORENSIC_LANES) * 4
    assert len(files) == expected_count, f"FATAL: Expected {expected_count} files, found {len(files)}."

def test_json_payload_integrity(mock_workspace):
    """PROVES: The JSON artifact contains the mandatory Daubert-admissible cryptographic keys."""
    target_dir = mock_workspace / "ghfld"
    generate_mocks(target_dir)
    
    sample_json = target_dir / "MOCK_LANE_04_payload.json"
    assert sample_json.exists(), "FATAL: JSON payload missing."
    
    data = json.loads(sample_json.read_text(encoding="utf-8"))
    assert "original_parent_sha256" in data, "FATAL: FRE 901 Cryptographic anchor missing."
    assert "taxonomy_lane" in data, "FATAL: Taxonomy routing data missing."
    assert "confidence_score" in data, "FATAL: FR-6.1 Confidence score missing."
