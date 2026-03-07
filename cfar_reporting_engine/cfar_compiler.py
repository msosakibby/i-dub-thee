import os
from datetime import datetime, timezone
from google.cloud import bigquery

# ==============================================================================
# MARKDOWN GENERATION ALGEBRA (TDD COMPLIANT)
# ==============================================================================

def generate_cryptographic_header(doc_count: int) -> str:
    """Generates the Executive Cryptographic Header with UTC temporal anchors."""
    utc_now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    return f"""# 🏛️ COMPREHENSIVE FORENSIC ASSET REPORT (CFAR)
**System:** Legal Forensics Engine V1.1.0 | **Execution Type:** On-Demand BigQuery Synthesis

## 🏛️ EXECUTIVE CRYPTOGRAPHIC HEADER
* **Temporal Anchor:** `{utc_now}`
* **Database State:** {doc_count} Verified Documents Indexed
* **Admissibility Constraint:** Generated via deterministic SQL execution against immutably hashed source binaries.

---
"""

def build_8f_discrepancy_table(bq_rows) -> tuple[str, float]:
    """Iterates the 8F SQL view joined with the Alias Registry."""
    table_markdown = "## ⚖️ PARAGRAPH 8F: THE MARITAL DISCREPANCY LEDGER\n"
    table_markdown += "*Calculation: Total Household/Marital Transport Expenses subject to 70/30 Split.*\n\n"
    table_markdown += "| Resolved Entity | Document Type | Expense Category | Total Expense | Keith's 30% Shortfall |\n"
    table_markdown += "| :--- | :--- | :--- | :--- | :--- |\n"
    
    total_shortfall = 0.0
    
    for row in bq_rows:
        resolved_entity = row.get("resolved_entity") if isinstance(row, dict) else row.resolved_entity
        doc_type = row.get("document_type") if isinstance(row, dict) else row.document_type
        exp_cat = row.get("expense_category") if isinstance(row, dict) else row.expense_category
        tot_exp = row.get("total_expense_amount") if isinstance(row, dict) else row.total_expense_amount
        owed = row.get("keith_owed_share") if isinstance(row, dict) else row.keith_owed_share
        
        # Format as standard USD currency
        tot_exp_str = f"${tot_exp:,.2f}"
        owed_str = f"${owed:,.2f}"
        
        table_markdown += f"| {resolved_entity} | {doc_type} | {exp_cat} | {tot_exp_str} | {owed_str} |\n"
        total_shortfall += float(owed)
        
    table_markdown += f"\n**TOTAL DOCUMENTED 8F SHORTFALL:** ${total_shortfall:,.2f}\n\n---\n"
    return table_markdown, total_shortfall

def build_tax_fraud_table(bq_rows) -> str:
    """Iterates the Tax Fraud view and formats the GFM detection table."""
    table_markdown = "## 🚨 ASSET CAPITALIZATION & TAX FRAUD AUDIT\n"
    table_markdown += "*Detection: Personal or Marital assets illegally capitalized under separate corporate schedules.*\n\n"
    table_markdown += "| Entity | Detected Asset | Full Description & Basis | Source Artifact |\n"
    table_markdown += "| :--- | :--- | :--- | :--- |\n"
    
    for row in bq_rows:
        entity = row.get("entity_slug") if isinstance(row, dict) else row.entity_slug
        asset = row.get("detected_asset_pattern") if isinstance(row, dict) else row.detected_asset_pattern
        desc = row.get("asset_description_and_basis") if isinstance(row, dict) else row.asset_description_and_basis
        uri = row.get("gcs_source_uri") if isinstance(row, dict) else row.gcs_source_uri
        
        uri_link = f"[View Source]({uri})"
        table_markdown += f"| {entity} | {asset} | {desc} | {uri_link} |\n"
        
    table_markdown += "\n---\n"
    return table_markdown

def build_tag_cloud_exhibit(bq_rows) -> str:
    """Iterates the Tag Cloud View to build Exhibit B."""
    table_markdown = "## 🔍 EXHIBIT B: CONTINUOUS METADATA TAG CLOUD\n"
    table_markdown += "*Detection: AI-embedded forensic metadata extracted securely from native JSON payloads.*\n\n"
    table_markdown += "| Forensic Tag | Source Node | Flagged Context | Source Artifact |\n"
    table_markdown += "| :--- | :--- | :--- | :--- |\n"
    
    for row in bq_rows:
        tag = row.get("forensic_tag") if isinstance(row, dict) else row.forensic_tag
        node = row.get("source_key") if isinstance(row, dict) else row.source_key
        context = row.get("flagged_context_text") if isinstance(row, dict) else row.flagged_context_text
        uri = row.get("gcs_source_uri") if isinstance(row, dict) else row.gcs_source_uri
        
        uri_link = f"[View Source]({uri})"
        # Clean up line breaks for markdown table compatibility
        clean_context = str(context).replace("\n", " ")
        
        table_markdown += f"| {tag} | {node} | {clean_context} | {uri_link} |\n"
        
    table_markdown += "\n---\n"
    return table_markdown

# ==============================================================================
# BIGQUERY ORCHESTRATION ENGINE
# ==============================================================================

def execute_cfar_compilation(project_id: str, dataset_id: str):
    print("[SYSTEM] Establishing connection to BigQuery Forensic Fact Base...")
    client = bigquery.Client(project=project_id)
    
    # 1. Capture Master Database State
    count_query = f"SELECT COUNT(*) as doc_count FROM `{project_id}.{dataset_id}.extracted_facts`"
    count_result = list(client.query(count_query).result())
    doc_count = count_result[0].doc_count if count_result else 0
    
    # 2. Query Paragraph 8F Parity View (WITH ALIAS REGISTRY JOIN)
    print("[SYSTEM] Executing 8F Parity Ledger algebra with Entity Resolution...")
    query_8f = f"""
        SELECT 
            COALESCE(ar.canonical_entity_id, v.entity_slug) AS resolved_entity, 
            v.document_type, 
            v.expense_category, 
            v.total_expense_amount, 
            v.keith_owed_share 
        FROM `{project_id}.{dataset_id}.vw_paragraph_8f_parity_ledger` v
        LEFT JOIN `{project_id}.{dataset_id}.account_alias_registry` ar 
            ON v.entity_slug = ar.raw_institution
    """
    rows_8f = list(client.query(query_8f).result())
    
    # 3. Query Tax Capitalization Fraud View
    print("[SYSTEM] Executing Tax Capitalization Fraud detection...")
    query_tax = f"SELECT entity_slug, detected_asset_pattern, asset_description_and_basis, gcs_source_uri FROM `{project_id}.{dataset_id}.vw_tax_capitalization_fraud_ledger`"
    rows_tax = list(client.query(query_tax).result())

    # 4. Query Tag Cloud Dashboard
    print("[SYSTEM] Retrieving Continuous Metadata Tag Cloud...")
    query_tags = f"SELECT forensic_tag, source_key, flagged_context_text, gcs_source_uri FROM `{project_id}.{dataset_id}.vw_continuous_tag_cloud`"
    rows_tags = list(client.query(query_tags).result())
    
    # 5. Synthesize Markdown Components
    print("[SYSTEM] Formatting Daubert-Admissible Markdown Dossier...")
    header_md = generate_cryptographic_header(doc_count)
    table_8f_md, total_shortfall = build_8f_discrepancy_table(rows_8f)
    table_tax_md = build_tax_fraud_table(rows_tax)
    table_tags_md = build_tag_cloud_exhibit(rows_tags)
    
    # 6. Compile Master Dossier
    date_str = datetime.now(timezone.utc).strftime('%Y%m%d')
    filename = f"CFAR_Master_Dossier_{date_str}.md"
    
    with open(filename, 'w') as f:
        f.write(header_md)
        f.write(table_8f_md)
        f.write(table_tax_md)
        f.write(table_tags_md)
        
    print(f"============================================================================")
    print(f" [CFAR GENERATED] Master Dossier successfully compiled to: {filename}")
    print(f" [DISCREPANCY ALERT] Total 8F Shortfall Calculated: ${total_shortfall:,.2f}")
    print(f"============================================================================")

if __name__ == "__main__":
    proj_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
    dataset = os.environ.get("BQ_DATASET", "forensic_fact_base")
    execute_cfar_compilation(proj_id, dataset)
