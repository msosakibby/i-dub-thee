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
