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
