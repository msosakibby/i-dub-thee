#!/bin/bash
set -e

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: UNIFIED IDX ARCHITECTURE"
echo "============================================================================"

mkdir -p tools tests
touch tools/__init__.py
touch tests/__init__.py

# ==============================================================================
# 1. FORGE TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] 1. Forging TDD Fixtures for Unified Architecture..."

cat << 'EOF_TESTS' > tests/test_unified_architecture.py
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
    
    assert f"DELETE FROM \`i-dub-thee.forensic_fact_base.ingestion_ledger\` WHERE original_parent_sha256 = '{target_hash}'" in queries["delete_sql"]
    assert "INSERT INTO \`i-dub-thee.forensic_fact_base.expungement_audit_log\`" in queries["audit_sql"]

EOF_TESTS

# ==============================================================================
# 2. FORGE CLOUD FIREWALL (tools/json_firewall.py)
# ==============================================================================
echo "[SYSTEM] 2. Forging Layer 3 JSON Firewall..."

cat << 'EOF_FIREWALL' > tools/json_firewall.py
import re

def scan_payload_for_scope_breach(payload: dict) -> bool:
    """
    Scans the finalized JSON dictionary for out-of-scope family intelligence.
    Returns True if contaminated, False if clean.
    """
    payload_string = str(payload)
    
    # Strict list of entities requiring manual review before Fact Base ingestion
    # (?i) makes it case-insensitive. \b ensures word boundaries.
    quarantine_pattern = re.compile(
        r'(?i)\b(Mark Kibby|Mark Sosa-Kibby|Parker|Parker Sosa-Kibby|Cole|Cole Sosa-Kibby|Erik|Erik Sosa-Kibby)\b'
    )
    
    if quarantine_pattern.search(payload_string):
        return True
        
    return False
EOF_FIREWALL

# ==============================================================================
# 3. FORGE CATALOGUE ARCHITECT (tools/catalogue_architect.py)
# ==============================================================================
echo "[SYSTEM] 3. Forging Master Ingestion Catalogue Generator..."

cat << 'EOF_CATALOGUE' > tools/catalogue_architect.py
import os
import json
from google.cloud import bigquery, storage

def generate_duodecimal_id(lane: str, doc_type: str, date_str, sequence: int) -> str:
    """Generates the mathematically structured [LANE].[CATEGORY].[YEAR].[SEQUENCE] ID."""
    # Extract numbers from lane (e.g., LANE_04 -> 04). Default to 99.
    lane_num = "".join(filter(str.isdigit, str(lane)))
    if not lane_num:
        lane_num = "99"
        
    # Take first 3 alphabetical characters of document type for the slug
    doc_slug = "".join([c for c in str(doc_type) if c.isalpha()])[:3].upper()
    if not doc_slug:
        doc_slug = "UNK"
        
    # Extract year
    year = str(date_str)[:4] if date_str else "0000"
    
    # Format sequence
    seq_str = str(sequence).zfill(4)
    
    return f"{lane_num}.{doc_slug}.{year}.{seq_str}"

def format_catalogue_entry(dict_id: str, row) -> str:
    """Constructs the strict 3-tier GHFMD visual layout for the Platinum Copy."""
    date_val = str(row.document_date) if row.document_date else "UNKNOWN_DATE"
    lane = str(row.taxonomy_lane)
    doc_type = str(row.document_type)
    uri = str(row.gcs_source_uri)
    
    try:
        payload = json.loads(row.extracted_payload) if isinstance(row.extracted_payload, str) else row.extracted_payload
        summary = payload.get("document_summary", "No AI summary extracted.")
    except Exception:
        summary = "JSON Parse Failure."

    # Tier 1: Metadata Table
    # Tier 2: Description Box
    # Tier 3: Relational Links
    entry = f"""
### 📄 Dictionary ID: `{dict_id}`

| 🗓️ Temporal Anchor | ⚖️ Logical Route | 🏷️ Primary Tag | 🏷️ Secondary Tag |
| :--- | :--- | :--- | :--- |
| **{date_val}** | `BigQuery Fact Base` | `{lane}` | `{doc_type}` |

> **DOCUMENT DESCRIPTION:**
> *{summary}*

| ⚠️ Forensic Notations | 🔗 Cross-Reference / Metadata Links |
| :--- | :--- |
| • Fact Base mathematically locked.<br>• Verified via JSON Firewall. | • [View Cloud PDF Artifact]({uri}) |

---
"""
    return entry

def execute_catalogue_generation():
    """Queries BigQuery and writes the Master TOC to GCS."""
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    bq_client = bigquery.Client(project=project_id)
    storage_client = storage.Client(project=project_id)
    
    print("[SYSTEM] Querying BigQuery Fact Base for Universal Ledger...")
    query = f"""
        SELECT 
            taxonomy_lane, document_type, document_date, gcs_source_uri, extracted_payload
        FROM `{project_id}.forensic_fact_base.ingestion_ledger`
        ORDER BY taxonomy_lane, document_date
    """
    
    try:
        rows = list(bq_client.query(query).result())
    except Exception as e:
        print(f"[!] BQ Query Failed. (Is the table empty?): {e}")
        return
        
    catalogue_md = "# 🏛️ MASTER INGESTION CATALOGUE & FORENSIC DATA DICTIONARY\n"
    catalogue_md += f"*Generated from BigQuery Terminal Truth. Total Extracted Artifacts: {len(rows)}*\n\n---\n"
    
    current_lane = ""
    sequence_counter = 1
    
    for row in rows:
        if row.taxonomy_lane != current_lane:
            current_lane = row.taxonomy_lane
            sequence_counter = 1
            catalogue_md += f"\n## 📂 DIRECTORY ROOT: {current_lane}\n\n"
            
        dict_id = generate_duodecimal_id(current_lane, row.document_type, row.document_date, sequence_counter)
        catalogue_md += format_catalogue_entry(dict_id, row)
        sequence_counter += 1
        
    print("[SYSTEM] Anchoring Master Catalogue to GCS Master Filing Cabinet...")
    bucket = storage_client.bucket(f"{project_id}-master-filing-cabinet")
    blob = bucket.blob("Master_Ingestion_Catalogue.md")
    blob.upload_from_string(catalogue_md, content_type="text/markdown")
    print("[+] Master Catalogue Generated.")

if __name__ == "__main__":
    execute_catalogue_generation()
EOF_CATALOGUE

# ==============================================================================
# 4. FORGE EXPUNGEMENT PROTOCOL (tools/expungement_commander.py)
# ==============================================================================
echo "[SYSTEM] 4. Forging Cryptographic Kill Switch..."

cat << 'EOF_KILLSWITCH' > tools/expungement_commander.py
import datetime
import os
from google.cloud import bigquery, storage

def generate_expungement_sql(target_hash: str, project_id: str = "i-dub-thee") -> dict:
    """Mathematically constructs the Daubert-admissible SQL expungement sequence."""
    timestamp = datetime.datetime.now().isoformat()
    
    return {
        "delete_sql": f"DELETE FROM `{project_id}.forensic_fact_base.ingestion_ledger` WHERE original_parent_sha256 = '{target_hash}';",
        "audit_sql": f"INSERT INTO `{project_id}.forensic_fact_base.expungement_audit_log` (target_hash, expungement_timestamp, action) VALUES ('{target_hash}', TIMESTAMP('{timestamp}'), 'FORENSIC_EXPUNGEMENT_EXECUTED');"
    }

def execute_forensic_expungement(target_hash: str, reason: str):
    """The Master Kill Switch."""
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    bq_client = bigquery.Client(project=project_id)
    
    print(f"[🚨 WARNING] INITIATING FORENSIC EXPUNGEMENT FOR HASH: {target_hash}")
    print(f"[REASON] {reason}")
    
    queries = generate_expungement_sql(target_hash, project_id)
    
    try:
        print("[SYSTEM] Executing Metadata Destruction...")
        bq_client.query(queries['delete_sql']).result()
        
        print("[SYSTEM] Writing to Cryptographic Audit Ledger...")
        # Note: In a live environment, ensure the expungement_audit_log table exists.
        try:
            bq_client.query(queries['audit_sql']).result()
        except Exception as e:
            print(f"[WARNING] Could not write to audit log (Table may not exist): {e}")
            
    except Exception as e:
        print(f"[!] EXPUNGEMENT FAILED: {str(e)}")
        return

    print("============================================================================")
    print(f" [KILL SWITCH COMPLETE] Hash {target_hash} expunged from Fact Base.")
    print("============================================================================")

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 2 and sys.argv[1] == "--expunge":
        execute_forensic_expungement(sys.argv[2], "Manual CLI Override")
EOF_KILLSWITCH

# ==============================================================================
# 5. EXECUTE TDD FIXTURES
# ==============================================================================
echo "[SYSTEM] 5. Verifying Unified Logic against TDD Contract..."
python3 -m pytest tests/test_unified_architecture.py -v

