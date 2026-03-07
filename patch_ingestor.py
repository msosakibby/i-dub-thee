import re
from pathlib import Path

file_path = Path("tools/schema_ingestor.py")
content = file_path.read_text(encoding="utf-8")

# Add textwrap import if missing
if "import textwrap" not in content:
    content = content.replace("import json", "import json\nimport textwrap")

# Fix the extraction block to include dedent
new_block = """        clean_python_code = re.sub(r'^(from\s+.*import\s+.*|import\s+.*)$', '', python_code, flags=re.MULTILINE).strip()
        clean_python_code = textwrap.dedent(clean_python_code).strip()  # FIX: Force flush-left indentation"""

content = re.sub(r'clean_python_code = re\.sub.*?\.strip\(\)', new_block, content, flags=re.DOTALL)
file_path.write_text(content, encoding="utf-8")
print("[SYSTEM] schema_ingestor.py patched for whitespace resilience.")
