import json
import re

def simulate_bq_8f_view_logic(db_row: dict) -> dict:
    """
    Simulates the exact SQL logic of the BigQuery vw_paragraph_8f_parity_ledger view.
    Executes JSON unnesting, taxonomy filtering, and 70/30 mathematical division.
    """
    # 1. Taxonomy Isolation Gate
    target_lanes = ["LANE_14_UTILITIES", "LANE_15_TRANSPORT"]
    if db_row.get("taxonomy_lane") not in target_lanes:
        return None
        
    # 2. JSON Unnesting (Simulating BQ UNNEST)
    try:
        payload = json.loads(db_row.get("extracted_payload", "[]"))
    except json.JSONDecodeError:
        return None

    target_keys = ["Gross Receipt Total", "Total Amount Due", "Net Receipt Total"]
    
    # 3. Target Identification & Float64 Casting
    for fact in payload:
        if fact.get("key_name") in target_keys:
            raw_val = fact.get("exact_value", "0.0")
            # Strip standard currency formatting for mathematical precision
            clean_val = re.sub(r'[$,]', '', str(raw_val))
            try:
                total_val = float(clean_val)
                # 4. Paragraph 8F Discrepancy Algebra
                return {
                    "total_expense_amount": total_val,
                    "judith_mandated_share": round(total_val * 0.70, 2),
                    "keith_owed_share": round(total_val * 0.30, 2)
                }
            except ValueError:
                continue
                
    return None
