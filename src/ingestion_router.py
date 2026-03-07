import os
import json
import uuid
import hashlib
from datetime import datetime, timezone
from google.cloud import bigquery, storage
from src.schemas import FlatForensicPayload, ValidationError

class WORM_IngestionRouter:
    def __init__(self):
        self.project_id = os.environ.get("GCP_PROJECT", "i-dub-thee")
        self.bq_client = bigquery.Client(project=self.project_id)
        self.storage_client = storage.Client(project=self.project_id)
        
        # Physical Vault Locations
        self.ledger_table = f"{self.project_id}.forensic_fact_base_dev.ingestion_ledger"
        self.quarantine_bucket_name = f"{self.project_id}-dev-quarantine"

    def process_payload(self, raw_json_dict: dict):
        try:
            # 1. Attempt Iron Gate Validation
            validated = FlatForensicPayload(**raw_json_dict)
            
            # 2. Package for BigQuery WORM Insertion
            row_to_insert = {
                "dossier_id": validated.dossier_id,
                "extraction_timestamp": validated.extraction_timestamp.isoformat(),
                "extracted_payload": validated.model_dump_json() # Store the entire flat JSON
            }
            
            print(f"\n[SYSTEM] Transmitting Valid Payload to BigQuery WORM Vault...")
            errors = self.bq_client.insert_rows_json(self.ledger_table, [row_to_insert])
            
            if errors:
                raise Exception(f"BigQuery WORM Insertion Failed: {errors}")
                
            print(f"[SUCCESS] Event ID {validated.ingestion_event_id} securely vaulted.")
            return {"status": "INGESTED", "hash": validated.cryptographic_sha256_hash}
            
        except ValidationError as e:
            # 3. Mathematical Quarantine (Zero Deletion)
            quarantine_uuid = str(uuid.uuid4())
            raw_serialized = json.dumps(raw_json_dict, sort_keys=True, default=str)
            quarantine_hash = hashlib.sha256(raw_serialized.encode('utf-8')).hexdigest()
            
            quarantine_dossier = {
                "quarantine_event_id": quarantine_uuid,
                "quarantine_timestamp": datetime.now(timezone.utc).isoformat(),
                "original_payload_hash": quarantine_hash,
                "pydantic_violation_log": e.errors(),
                "raw_rejected_payload": raw_json_dict
            }
            
            print(f"\n[BLOCKED] Nested/Invalid Data Intercepted. Routing to WORM Quarantine...")
            bucket = self.storage_client.bucket(self.quarantine_bucket_name)
            blob = bucket.blob(f"quarantine_event_{quarantine_uuid}.json")
            blob.upload_from_string(json.dumps(quarantine_dossier, indent=2))
            
            print(f"[QUARANTINE SUCCESS] WORM Hash securely vaulted: {quarantine_hash}")
            return {"status": "QUARANTINED", "quarantine_id": quarantine_uuid}

if __name__ == "__main__":
    router = WORM_IngestionRouter()
    
    print("\n============================================================================")
    print(" INITIATING LIVE FIRE PHYSICAL ROUTING TEST")
    print("============================================================================")
    
    # Simulate a clean optical extraction from Layer 1
    valid_data = {
        "dossier_id": f"DOSS-{uuid.uuid4().hex[:6].upper()}",
        "activity_line_01_description_value": "M & J Food Market Wire Transfer",
        "activity_line_01_description_confidence": 0.99,
        "activity_line_01_amount_value": 50000.00,
        "activity_line_01_amount_confidence": 0.95
    }
    router.process_payload(valid_data)
    
    # Simulate a nested LLM hallucination attack
    invalid_data = {
        "dossier_id": f"DOSS-{uuid.uuid4().hex[:6].upper()}",
        "nested_hallucination": {"amount": 50000.00}
    }
    router.process_payload(invalid_data)
