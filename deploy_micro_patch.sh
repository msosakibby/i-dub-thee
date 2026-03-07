#!/bin/bash
set -e

echo "[SYSTEM] 1. Patching Pytest Fixtures (Aligning Markdown Assertions)..."
cat << 'EOF_TEST' > tests/test_rules_engine.py
import pytest
from unittest.mock import MagicMock

try:
    from tools.rules_engine import ANTENUPTIAL_COMPLIANCE_SQL, generate_markdown_report
except ImportError:
    ANTENUPTIAL_COMPLIANCE_SQL = ""
    generate_markdown_report = None

def test_sql_temporal_gate():
    assert "2005-07-23" in ANTENUPTIAL_COMPLIANCE_SQL
    assert "PREMARITAL_DEBT" in ANTENUPTIAL_COMPLIANCE_SQL

def test_sql_commingling_leakage():
    assert "COMMINGLING_VIOLATION" in ANTENUPTIAL_COMPLIANCE_SQL
    assert "Source_Account" in ANTENUPTIAL_COMPLIANCE_SQL or "Payment_Information" in ANTENUPTIAL_COMPLIANCE_SQL

def test_sql_ambiguity_quarantine():
    assert "IS NULL" in ANTENUPTIAL_COMPLIANCE_SQL
    assert "AMBIGUOUS_QUARANTINE_REQUIRED" in ANTENUPTIAL_COMPLIANCE_SQL

def test_sql_hobby_penalty():
    assert "LANE_17_SPORTING_RECREATION" in ANTENUPTIAL_COMPLIANCE_SQL
    assert "100_PERCENT_SOLE_LIABILITY_HOBBY" in ANTENUPTIAL_COMPLIANCE_SQL

def test_markdown_report_generation():
    if generate_markdown_report is None:
        pytest.fail("FATAL: generate_markdown_report function is missing.")

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
    
    # Asserting Admissibility & Mathematics (Now matching the Markdown bolding exactly)
    assert "[RESTRICTED: DO NOT RE-INGEST FOR ML TRAINING]" in report_content
    assert "**Total Judy Liability:** $700.00" in report_content, "FATAL: Judy calculation failed."
    assert "**Total Keith Liability:** $450.00" in report_content, "FATAL: Keith calculation failed."
    assert "**Commingling / Quarantine Flags Detected:** 1" in report_content, "FATAL: Failed to aggregate commingling flags."
EOF_TEST

echo "[SYSTEM] 2. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_rules_engine.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
