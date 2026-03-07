# LAYER 3 PROD SCHEMA - RESTORATION BLUEPRINT
**Archived:** $TIMESTAMP
**Reason for Archival:** Strategic pivot to Zero-Omission Flat JSON for the Layer 3 Hypothesis Engine to mathematically eliminate Vertex AI / LLM hallucination during Text-to-SQL translation.
**Contents:** Original nested Pydantic schemas (src/schemas.py), BigQuery DDL configurations, and Layer 3 ingestor logic.

## RESTORATION PROTOCOL
To reverse this pivot and restore the 18-Lane Geospatial Schema:
1. Extract this archive into the root directory of the `i-dub-thee` workspace.
2. Overwrite the Flat JSON `src/schemas.py` and `sql_agent.py` files with these archived versions.
3. Re-run `deploy_layer3_sandbox.sh` to update the BigQuery dataset back to the nested schemas.
