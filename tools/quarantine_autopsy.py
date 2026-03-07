import json
from datetime import datetime
from google.cloud import bigquery, storage

def isolate_json_fractures(alpha: dict, beta: dict) -> dict:
    """Mathematically isolates mismatched key-value pairs between two dictionaries."""
    fractures = {}
    
    # Flatten dicts for easier comparison (simple top-level diff for now)
    alpha_keys = set(alpha.keys())
    beta_keys = set(beta.keys())
    
    for key in alpha_keys.union(beta_keys):
        val_alpha = alpha.get(key)
        val_beta = beta.get(key)
        if val_alpha != val_beta:
            fractures[key] = {"alpha_value": val_alpha, "beta_value": val_beta}
            
    return fractures

def generate_autopsy_markdown(bq_rows) -> str:
    """Compiles isolated fractures into a Daubert-admissible Markdown string."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    report = f"# QUARANTINE AUTOPSY REPORT\n**Generated:** {timestamp}\n\n"
    
    if not bq_rows:
        report += "No new quarantine fractures detected in the ledger.\n"
        return report

    for row in bq_rows:
        report += f"## Document ID: `{row.document_id}`\n"
        report += f"**Timestamp:** {row.quarantine_timestamp}\n"
        report += f"**Source URI:** {row.gcs_source_uri}\n"
        report += f"**Reason:** {row.fracture_reason}\n\n"
        
        try:
            alpha = json.loads(row.alpha_payload) if isinstance(row.alpha_payload, str) else row.alpha_payload
            beta = json.loads(row.beta_payload) if isinstance(row.beta_payload, str) else row.beta_payload
            
            fractures = isolate_json_fractures(alpha, beta)
            report += "### ISOLATED FRACTURES:\n"
            report += "| Disputed Field | Alpha Extraction (Neutral) | Beta Extraction (Hostile) |\n"
            report += "|---|---|---|\n"
            for field, vals in fractures.items():
                report += f"| `{field}` | `{vals['alpha_value']}` | `{vals['beta_value']}` |\n"
            
        except Exception as e:
             report += f"*(Error parsing payloads for diff: {str(e)})*\n"
        report += "\n---\n"
        
    return report

def execute_autopsy_report():
    """Queries the ledger and writes the Markdown artifact to GCS."""
    bq_client = bigquery.Client()
    storage_client = storage.Client()
    
    query = """
        SELECT * FROM `i-dub-thee.forensic_fact_base.quarantine_ledger`
        ORDER BY quarantine_timestamp DESC LIMIT 50
    """
    rows = list(bq_client.query(query).result())
    markdown_content = generate_autopsy_markdown(rows)
    
    bucket = storage_client.bucket("i-dub-thee-master-filing-cabinet")
    blob = bucket.blob("Quarantine_Autopsy_Report.md")
    blob.upload_from_string(markdown_content, content_type="text/markdown")
    print("[+] Autopsy Report written to Master Filing Cabinet.")

if __name__ == "__main__":
    execute_autopsy_report()
