#!/bin/bash
# ==============================================================================
# MASTER DEPLOYMENT: FORENSIC CONTEXT EXTRACTOR (TDD + ISOLATED DEPENDENCIES)
# ==============================================================================
set -e

echo "[SYSTEM] Initiating Zero-Trust Extraction Deployment..."

# ==============================================================================
# 0. DEPENDENCY ISOLATION BOUNDARY
# ==============================================================================
echo "[SYSTEM] Establishing ephemeral virtual environment (.venv_forensic_extract)..."
python3 -m venv .venv_forensic_extract
source .venv_forensic_extract/bin/activate

echo "[SYSTEM] Installing adversarial testing framework (Pytest)..."
pip install --quiet --upgrade pip
pip install --quiet pytest

# 1. Scaffold Directories
mkdir -p tools tests

# ==============================================================================
# 2. WRITE TDD FIXTURES (pytest)
# ==============================================================================
echo "[SYSTEM] Generating Adversarial Pytest Fixtures..."
cat << 'EOF' > tests/test_context_extractor.py
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
EOF

# ==============================================================================
# 3. WRITE EXTRACTION LOGIC (Python 3.10+)
# ==============================================================================
echo "[SYSTEM] Generating Python 3.10+ Extraction Logic..."
cat << 'EOF' > tools/context_extractor.py
import os
import datetime
from pathlib import Path
from typing import List

# ==============================================================================
# HARDENED CONFIGURATION MATRIX
# ==============================================================================
EXCLUDE_DIRS = {
    ".git", "venv", "env", "__pycache__", ".pytest_cache", 
    ".vscode", "idea", "node_modules", ".mypy_cache", ".venv_forensic_extract"
}

EXCLUDE_FILES = {
    ".env", ".pem", "credentials.json", "service-account.json", 
    ".DS_Store"
}

ALLOW_EXTENSIONS = {
    ".py", ".sh", ".json", ".md", ".yaml", ".yml", ".sql", ".txt", ".toml", ".ini"
}

def build_allow_list(root_dir: Path) -> List[Path]:
    """
    Recursively scans the directory, violently rejecting any path matching
    the EXCLUDE_DIRS or EXCLUDE_FILES sets, and filtering by ALLOW_EXTENSIONS.
    """
    valid_files = []
    for current_root, dirs, files in os.walk(root_dir):
        # Mutate dirs in-place to prevent os.walk from entering excluded directories
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        
        for file in files:
            if file in EXCLUDE_FILES:
                continue
                
            file_path = Path(current_root) / file
            if file_path.suffix.lower() in ALLOW_EXTENSIONS:
                valid_files.append(file_path)
                
    return sorted(valid_files)

def extract_workspace(root_dir: Path, output_path: Path) -> None:
    """
    Iterates through the verified allow-list and generates the highly structured
    Markdown artifact for LLM ingestion.
    """
    valid_files = build_allow_list(root_dir)
    
    with open(output_path, "w", encoding="utf-8") as outfile:
        timestamp = datetime.datetime.now().isoformat()
        outfile.write(f"# LEGAL FORENSICS ENGINE - IDE EXTRACTION ARTIFACT\n")
        outfile.write(f"**TIMESTAMP:** {timestamp}\n")
        outfile.write(f"**TOTAL FILES EXTRACTED:** {len(valid_files)}\n\n")
        
        for file_path in valid_files:
            try:
                # Calculate relative path for clean headers
                rel_path = file_path.relative_to(root_dir)
                content = file_path.read_text(encoding="utf-8")
                
                outfile.write("=" * 80 + "\n")
                outfile.write(f"FILEPATH: {rel_path}\n")
                outfile.write("=" * 80 + "\n")
                
                # Use standard markdown code blocks, defaulting to raw text if extension varies
                ext = file_path.suffix.lower().replace(".", "")
                outfile.write(f"```{ext}\n")
                outfile.write(content)
                if not content.endswith("\n"):
                    outfile.write("\n")
                outfile.write("```\n\n")
                
            except Exception as e:
                outfile.write(f"[WARNING: FAILED TO EXTRACT {rel_path} - {str(e)}]\n\n")

if __name__ == "__main__":
    workspace_root = Path.cwd()
    timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    output_artifact = workspace_root / f"forensic_context_{timestamp_str}.md"
    
    print(f"[SYSTEM] Extracting Legal Forensics Engine workspace from: {workspace_root}")
    extract_workspace(workspace_root, output_artifact)
    print(f"[SUCCESS] Extraction complete. Artifact generated at: {output_artifact.name}")
EOF

# ==============================================================================
# 4. EXECUTE ADVERSARIAL TDD SUITE
# ==============================================================================
echo "[SYSTEM] Executing Pytest Gate via isolated environment..."
python -m pytest tests/test_context_extractor.py -v

# ==============================================================================
# 5. EXECUTE EXTRACTION IF GREEN
# ==============================================================================
echo "[SYSTEM] TDD Gate Passed. Executing Workspace Extraction..."
python tools/context_extractor.py

# ==============================================================================
# 6. TEARDOWN
# ==============================================================================
echo "[SYSTEM] Tearing down ephemeral dependency boundary..."
deactivate
echo "[SYSTEM] Extraction Lifecycle Complete."