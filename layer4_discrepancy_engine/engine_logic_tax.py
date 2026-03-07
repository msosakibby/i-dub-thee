import json
import re

def simulate_bq_tax_fraud_view(db_row: dict) -> dict:
    """
    Simulates the BigQuery vw_tax_capitalization_fraud_ledger view.
    Executes JSON unnesting, LANE_07 isolation, and Regex asset detection.
    """
    # 1. Taxonomy Isolation Gate
    if db_row.get("taxonomy_lane") != "LANE_07_TAX":
        return None
        
    # 2. JSON Unnesting
    try:
        payload = json.loads(db_row.get("extracted_payload", "[]"))
    except json.JSONDecodeError:
        return None

    # Strict list of assets known to be personal/marital but suspected of business capitalization
    fraud_pattern = re.compile(r'(SILVERADO|HONDA SXS|PIONEER|RANGER BOAT|FURNACE|AIR CONDITIONER)')
    
    # 3. Target Identification & Regex Isolation
    for fact in payload:
        if fact.get("key_name") == "Depreciation Assets":
            exact_val = str(fact.get("exact_value", "")).upper()
            match = fraud_pattern.search(exact_val)
            
            if match:
                return {
                    "fraud_indicator": "TAX_FRAUD_RISK",
                    "detected_asset_pattern": match.group(1),
                    "full_asset_description": exact_val
                }
                
    return None
