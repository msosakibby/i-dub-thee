from pathlib import Path

schema_file = Path("src/schemas.py")
content = schema_file.read_text(encoding="utf-8")

standard_imports = """# ==========================================
# FORENSIC STANDARD LIBRARY IMPORTS
# ==========================================
import logging
import decimal
from decimal import Decimal
from datetime import date, datetime
from typing import Literal, Union, List, Optional, Any, Dict
try:
    from typing import Self
except ImportError:
    from typing_extensions import Self
import pydantic
from pydantic import Field, ConfigDict, model_validator

"""

if "FORENSIC STANDARD LIBRARY IMPORTS" not in content:
    schema_file.write_text(standard_imports + content, encoding="utf-8")
    print("[SYSTEM] src/schemas.py fortified with Standard Libraries.")
else:
    print("[SYSTEM] Standard Libraries already present.")
