import os
import json
import logging
import uuid
from datetime import datetime, timezone
from google.cloud import bigquery
from google.api_core.exceptions import NotFound

from forensic_evaluator import RulesEngine

# --- STRICT LOGGING ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger("ForensicJobRunner")

PROJECT_ID = os.environ.get("PROJECT_ID", "i-dub-thee")
ENV_MODE = os.environ.get("ENV_MODE", "DEV")

BQ_DATASET = "forensic_fact_base_dev" if ENV_MODE == "DEV" else "forensic_fact_base"
TABLE_INGESTION = "ingestion_ledger"
TABLE_OUTCOMES = "hypothesis_outcomes"

bq_client = bigquery.Client(project=PROJECT_ID)

def assert_outcomes_table():
    """Mathematically guarantees the destination WORM table exists before querying."""
    table_id = f"{PROJECT_ID}.{BQ_DATASET}.{TABLE_OUTCOMES}"
    try:
        bq_client.get_table(table_id)
        logger.info(f"Target vault {table_id} verified.")
    except NotFound:
        logger.warning(f"Vault {table_id} missing. Provisioning strict schema...")
        schema = [
            bigquery.SchemaField("outcome_id", "STRING", mode="REQUIRED"),
            bigquery.SchemaField("dossier_id", "STRING", mode="REQUIRED"),
            bigquery.SchemaField("rule_id", "STRING", mode="REQUIRED"),
            bigquery.SchemaField("evaluation_timestamp", "TIMESTAMP", mode="REQUIRED"),
            bigquery.SchemaField("violation_detected", "BOOLEAN", mode="REQUIRED"),
            bigquery.SchemaField("matched_evidence", "JSON", mode="NULLABLE"),
        ]
        table = bigquery.Table(table_id, schema=schema)
        bq_client.create_table(table)
        logger.info(f"Vault {table_id} successfully provisioned.")

def execute_anti_join_evaluation(engine: RulesEngine):
    """
    The core FP loop. Evaluates rules only against un-processed dossiers.
    """
    for rule in engine.rules:
        rule_id = rule.get("rule_id")
        logger.info(f"--- Evaluating Rule: {rule_id} ---")
        
        # The Zero-Reingestion SQL Anti-Join
        query = f"""
            SELECT i.dossier_id, i.extracted_payload
            FROM `{PROJECT_ID}.{BQ_DATASET}.{TABLE_INGESTION}` i
            WHERE NOT EXISTS (
                SELECT 1 
                FROM `{PROJECT_ID}.{BQ_DATASET}.{TABLE_OUTCOMES}` h
                WHERE h.dossier_id = i.dossier_id
                AND h.rule_id = @rule_id
            )
        """
        
        job_config = bigquery.QueryJobConfig(
            query_parameters=[bigquery.ScalarQueryParameter("rule_id", "STRING", rule_id)]
        )
        
        query_job = bq_client.query(query, job_config=job_config)
        records = list(query_job.result())
        
        if not records:
            logger.info(f"Zero unprocessed dossiers found for {rule_id}. Skipping.")
            continue
            
        logger.info(f"Found {len(records)} unprocessed dossiers for {rule_id}. Executing Engine...")
        
        outcomes_to_insert = []
        for record in records:
            dossier_id = record.dossier_id
            payload_str = record.extracted_payload
            
            # BigQuery returns JSON as string or dict depending on the driver version. Coerce safely.
            payload = json.loads(payload_str) if isinstance(payload_str, str) else payload_str
            
            # Execute the mathematical evaluation
            violations = engine.evaluate_payload(payload)
            
            # Filter violations specifically for the current rule iteration
            specific_violations = [v for v in violations if v["rule_id"] == rule_id]
            
            if specific_violations:
                # Daubert-admissible evidence found
                for violation in specific_violations:
                    outcomes_to_insert.append({
                        "outcome_id": f"OUT-{uuid.uuid4().hex[:8].upper()}",
                        "dossier_id": dossier_id,
                        "rule_id": rule_id,
                        "evaluation_timestamp": datetime.now(timezone.utc).isoformat(),
                        "violation_detected": True,
                        "matched_evidence": json.dumps(violation)
                    })
            else:
                # Record a negative outcome to fulfill the Anti-Join state requirement
                outcomes_to_insert.append({
                    "outcome_id": f"OUT-{uuid.uuid4().hex[:8].upper()}",
                    "dossier_id": dossier_id,
                    "rule_id": rule_id,
                    "evaluation_timestamp": datetime.now(timezone.utc).isoformat(),
                    "violation_detected": False,
                    "matched_evidence": None
                })
        
        # Batch insert results to the ledger
        if outcomes_to_insert:
            table_id = f"{PROJECT_ID}.{BQ_DATASET}.{TABLE_OUTCOMES}"
            errors = bq_client.insert_rows_json(table_id, outcomes_to_insert)
            if errors:
                logger.error(f"FATAL: Failed to write outcomes for {rule_id}: {errors}")
                raise RuntimeError("Spoliation of Outcome Ledger.")
            logger.info(f"Successfully committed {len(outcomes_to_insert)} outcomes to the vault.")

if __name__ == "__main__":
    logger.info("Initializing Layer 2 Forensic Rules Engine Job...")
    
    # 1. Enforce physical schema reality
    assert_outcomes_table()
    
    # 2. Boot the immutable logic registry
    # In a deployed Cloud Run Job container, the root is /app, so tests/ is copied over.
    registry_path = os.getenv("REGISTRY_PATH", "tests/rules_registry.yaml")
    rules_engine = RulesEngine(registry_path=registry_path)
    
    # 3. Execute the batch evaluation
    execute_anti_join_evaluation(rules_engine)
    
    logger.info("Layer 2 Job Execution Complete. Terminating cleanly.")
