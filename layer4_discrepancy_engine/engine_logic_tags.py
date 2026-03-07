import json
import re

def simulate_bq_tag_extraction(db_row: dict) -> dict:
    """
    Simulates the BigQuery vw_continuous_tag_cloud view.
    Executes JSON unnesting, Regex array generation, and empty-row bypass.
    """
    try:
        payload = json.loads(db_row.get("extracted_payload", "[]"))
    except json.JSONDecodeError:
        return None

    extracted_flags = []
    # Strict Regex targeting the [FLAG: EXACT_STRING] metadata embedded by AI
    pattern = re.compile(r'\[FLAG:\s*([A-Z0-9_]+)\]')
    
    for fact in payload:
        exact_val = str(fact.get("exact_value", ""))
        matches = pattern.findall(exact_val)
        if matches:
            extracted_flags.extend(matches)
            
    # Clean Document Bypass: Return None if no flags exist
    if not extracted_flags:
        return None
        
    return {
        "parent_file_hash": db_row.get("parent_file_hash"),
        "extracted_flags": extracted_flags
    }
