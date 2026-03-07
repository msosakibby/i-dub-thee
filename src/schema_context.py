FLAT_SCHEMA_DDL = """
-- THIS IS THE WORM-COMPLIANT FLAT FACT BASE.
-- DO NOT HALLUCINATE COLUMNS. YOU MAY ONLY USE THE FIELDS BELOW.

TABLE: `forensic_fact_base_dev.ingestion_ledger`
DESCRIPTION: Raw, flat JSON extracted evidence.
COLUMNS:
- dossier_id (STRING): The unique ID of the document.
- extraction_timestamp (TIMESTAMP): When it was ingested.
- extracted_payload (JSON): The ZERO-OMISSION FLAT JSON payload.
    - Keys include: 'activity_line_01_description', 'activity_line_01_amount', etc.

TABLE: `forensic_fact_base_dev.hypothesis_outcomes`
DESCRIPTION: The output of the forensic rules engine.
COLUMNS:
- outcome_id (STRING): Unique ID for the evaluation.
- dossier_id (STRING): Links back to the ingestion_ledger.
- rule_id (STRING): The legal rule evaluated (e.g., 'PARAGRAPH_8F_M_AND_J').
- violation_detected (BOOLEAN): TRUE if commingling or violation occurred.
- matched_evidence (JSON): The specific flat JSON key/value that triggered the rule.
"""
