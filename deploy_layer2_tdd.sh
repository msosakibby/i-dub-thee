#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING TDD PHASE: LAYER 2 RULES ENGINE (FIRST PRINCIPLES RED STATE)"
echo "============================================================================"

echo "[SYSTEM] 1. Authoring TDD Fixtures (tests/test_rules_engine.py)..."
cat << 'EOF_TEST' > tests/test_rules_engine.py
import pytest
from unittest.mock import MagicMock

# We attempt to import the target. It will likely fail or lack the new logic.
try:
    from tools.rules_engine import ANTENUPTIAL_COMPLIANCE_SQL, generate_markdown_report
except ImportError:
    ANTENUPTIAL_COMPLIANCE_SQL = ""
    generate_markdown_report = None

def test_sql_temporal_gate():
    """VECTOR 1: Proves SQL enforces the July 23, 2005 Marriage Date (Par. 2A & 8A)."""
    assert "2005-07-23" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Missing July 23, 2005 temporal threshold."
    assert "PREMARITAL_DEBT" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Missing premarital debt classification."

def test_sql_commingling_leakage():
    """VECTOR 2: Proves SQL detects Source/Destination cross-contamination (Par. 8H)."""
    assert "COMMINGLING_VIOLATION" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Missing Commingling Violation flag."
    assert "Source_Account" in ANTENUPTIAL_COMPLIANCE_SQL or "Payment_Information" in ANTENUPTIAL_COMPLIANCE_SQL, \
        "FATAL: SQL is not inspecting the funding source for cross-contamination."

def test_sql_ambiguity_quarantine():
    """VECTOR 3: Proves SQL handles OCR failures via strict quarantine (Null State)."""
    assert "IS NULL" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Missing strict NULL state handling."
    assert "AMBIGUOUS_QUARANTINE_REQUIRED" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Ambiguity does not default to Quarantine."

def test_sql_hobby_penalty():
    """VECTOR 4: Proves SQL targets Lane 17 for 100% sole liability (Par. 10G)."""
    assert "LANE_17_SPORTING_RECREATION" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Missing Hobby Penalty trigger."
    assert "100_PERCENT_SOLE_LIABILITY_HOBBY" in ANTENUPTIAL_COMPLIANCE_SQL, "FATAL: Missing Hobby liability classification."

def test_markdown_report_generation():
    """VECTOR 5: Proves the Python logic correctly generates the Daubert-admissible Markdown string."""
    if generate_markdown_report is None:
        pytest.fail("FATAL: generate_markdown_report function is missing.")

    # Simulating the output of the BigQuery execution
    mock_rows = [
        MagicMock(
            document_id="doc_001.pdf", 
            taxonomy_lane="LANE_17_SPORTING_RECREATION", 
            gross_amount=150.00, 
            classification="100_PERCENT_SOLE_LIABILITY_HOBBY",
            judy_liability=0.00,
            keith_liability=150.00
        ),
        MagicMock(
            document_id="doc_002.pdf", 
            taxonomy_lane="LANE_14_UTILITIES", 
            gross_amount=1000.00, 
            classification="70_30_MARITAL_SPLIT",
            judy_liability=700.00,
            keith_liability=300.00
        ),
        MagicMock(
            document_id="doc_003.pdf", 
            taxonomy_lane="LANE_09_INFRASTRUCTURE", 
            gross_amount=3190.00, 
            classification="COMMINGLING_VIOLATION",
            judy_liability=0.00,
            keith_liability=0.00
        )
    ]
    
    report_content = generate_markdown_report(mock_rows)
    
    # Asserting Admissibility & Mathematics
    assert "[RESTRICTED: DO NOT RE-INGEST FOR ML TRAINING]" in report_content, "FATAL: Missing restriction tag."
    assert "Total Judy Liability: $700.00" in report_content, "FATAL: Judy calculation failed."
    assert "Total Keith Liability: $450.00" in report_content, "FATAL: Keith calculation failed."
    assert "Commingling / Quarantine Flags Detected: 1" in report_content, "FATAL: Failed to aggregate commingling flags."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting Massive Failure/Red State)..."
python3 -m pytest tests/test_rules_engine.py -v || true

echo "============================================================================"
echo " [WAITING FOR RED STATE TELEMETRY]"
echo "============================================================================"
