import os
import pytest
from pathlib import Path
from tools.context_extractor import build_allow_list, extract_workspace

@pytest.fixture
def mock_ide_environment(tmp_path: Path):
    """Dynamically generates a mock IDE with both valid files and poison vectors."""
    # Create valid directories and files
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    (src_dir / "main.py").write_text("print('Legal Forensics Engine')")
    
    tools_dir = tmp_path / "tools"
    tools_dir.mkdir()
    (tools_dir / "deploy.sh").write_text("echo 'Deploying...'")

    # Create poison vectors (Should be excluded)
    (tmp_path / ".env").write_text("GCP_SERVICE_ACCOUNT_KEY=12345")
    
    venv_dir = tmp_path / ".venv_forensic_extract"
    venv_dir.mkdir()
    (venv_dir / "dependency.py").write_text("print('noise')")
    
    git_dir = tmp_path / ".git"
    git_dir.mkdir()
    (git_dir / "config").write_text("git config data")

    return tmp_path

def test_exclusion_gate(mock_ide_environment: Path):
    """Proves that credentials and noise directories are strictly bypassed."""
    allowed_files = build_allow_list(mock_ide_environment)
    allowed_paths = [str(p.relative_to(mock_ide_environment)) for p in allowed_files]
    
    assert ".env" not in allowed_paths, "FATAL: Credentials leaked into allow-list."
    assert ".venv_forensic_extract/dependency.py" not in allowed_paths, "FATAL: Ephemeral venv bypassed exclusion gate."
    assert ".git/config" not in allowed_paths, "FATAL: Git history bypassed exclusion gate."

def test_allow_list_gate(mock_ide_environment: Path):
    """Proves that valid architectural files are successfully targeted."""
    allowed_files = build_allow_list(mock_ide_environment)
    allowed_paths = [str(p.relative_to(mock_ide_environment)) for p in allowed_files]
    
    assert "src/main.py" in allowed_paths, "FATAL: Core logic file dropped."
    assert "tools/deploy.sh" in allowed_paths, "FATAL: Deployment script dropped."

def test_output_formatting_gate(mock_ide_environment: Path):
    """Proves the mathematical boundaries of the output artifact."""
    output_artifact = mock_ide_environment / "test_forensic_context.md"
    extract_workspace(mock_ide_environment, output_artifact)
    
    content = output_artifact.read_text(encoding="utf-8")
    
    assert "================================================================================" in content
    assert "FILEPATH: src/main.py" in content
    assert "print('Legal Forensics Engine')" in content
    assert "GCP_SERVICE_ACCOUNT_KEY" not in content
