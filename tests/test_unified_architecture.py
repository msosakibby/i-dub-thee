import pytest
import json
from unittest.mock import MagicMock, patch

try:
    from tools.json_firewall import scan_payload_for_scope_breach
    from tools.catalogue_architect import generate_duodecimal_id, format_catalogue_entry
    from tools.expungement_commander import generate_expungement_sql
except ImportError:
    scan_payload_for_scope_breach = None
    generate_duodecimal_id = None
    format_catalogue_entry = None
    generate_expungement_sql = None

# --- FIREWALL TDD ---
def test_firewall_scope_breach():
    if scan_payload_for_scope_breach is None:
        pytest.skip("Implementation missing")
        
    clean_payload = {"line_items": [{"desc": "Office Supplies", "amount": 100}]}
    contaminated_payload = {"line_items": [{"desc": "Medical payment for Cole", "amount": 500}]}
    
    assert scan_payload_for_scope_breach(clean_payload) is False
    assert scan_payload_for_scope_breach(contaminated_payload) is True

# --- CATALOGUE TDD ---
def test_duodecimal_generator():
    if generate_duodecimal_id is None:
        pytest.skip("Implementation missing")
        
    calculated_id = generate_duodecimal_id("LANE_04_BANKING", "Bank Statement", "2016-07-02", 42)
    assert calculated_id == "04.BAN.2016.0042"
    
    fallback_id = generate_duodecimal_id("UNKNOWN", "Receipt", None, 1)
    assert fallback_id == "99.REC.0000.0001"

def test_platinum_markdown_formatting():
    if format_catalogue_entry is None:
        pytest.skip("Implementation missing")
        
    mock_row = MagicMock(
        document_date="2016-07-02",
        taxonomy_lane="LANE_04_BANKING",
        document_type="CHECK_REGISTER",
        gcs_source_uri="gs://bucket/file.pdf",
        extracted_payload='{"document_summary": "Extracted Summary: Test."}'
    )
    
    entry = format_catalogue_entry("04.CHE.2016.0001", mock_row)
    
    assert "### 📄 Dictionary ID: `04.CHE.2016.0001`" in entry
    assert "| **2016-07-02** |" in entry
    assert "> **DOCUMENT DESCRIPTION:**" in entry
    assert "*Extracted Summary: Test.*" in entry

# --- KILL SWITCH TDD ---
def test_killswitch_sql_generation():
    if generate_expungement_sql is None:
        pytest.skip("Implementation missing")
        
    target_hash = "abc123xyz"
    queries = generate_expungement_sql(target_hash)
    
    # FIX: Removed the Python-invalid backslash escape sequences
    assert f"DELETE FROM `i-dub-thee.forensic_fact_base.ingestion_ledger` WHERE original_parent_sha256 = '{target_hash}'" in queries["delete_sql"]
    assert "INSERT INTO `i-dub-thee.forensic_fact_base.expungement_audit_log`" in queries["audit_sql"]

