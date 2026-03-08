import functions_framework
import os
import json
from google.cloud import storage, bigquery
import vertexai
from vertexai.generative_models import GenerativeModel

PROJECT_ID = os.environ.get("GCP_PROJECT", "i-dub-thee")
RESULTS_BUCKET = os.environ.get("RESULTS_BUCKET", f"{PROJECT_ID}-dev-results")

storage_client = storage.Client(project=PROJECT_ID)
bq_client = bigquery.Client(project=PROJECT_ID)

FLAT_SCHEMA_DDL = """
CREATE TABLE `i-dub-thee.forensic_fact_base_dev.ingestion_ledger` (
  dossier_id STRING,
  extraction_timestamp TIMESTAMP,
  extracted_payload JSON
);
"""

@functions_framework.cloud_event
def process_query(cloud_event):
    print("[SYSTEM] Wake event received. Initializing AI core...")
    
    vertexai.init(project=PROJECT_ID, location="us-central1")
    model = GenerativeModel("gemini-2.5-pro")
    
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]
    
    print(f"[SYSTEM] Reading hypothesis from: gs://{bucket_name}/{file_name}")
    
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    hypothesis = blob.download_as_text().strip()
    
    prompt = f"""
    You are a forensic legal data engineer. 
    Translate the user's natural language hypothesis into a BigQuery SQL statement.
    STRICT LAWS:
    1. ONLY output raw, executable BigQuery SQL. No markdown, no formatting.
    2. STRICTLY FORBIDDEN: DROP, DELETE, UPDATE, INSERT, ALTER.
    3. You must use JSON_EXTRACT_SCALAR(extracted_payload, '$.key_name') to read the Flat JSON.
    Schema:
    {FLAT_SCHEMA_DDL}
    Hypothesis: {hypothesis}
    """
    
    print("[SYSTEM] Engaging AI Model...")
    response = model.generate_content(prompt)
    clean_sql = response.text.replace("```sql", "").replace("```", "").strip()
    
    upper_sql = clean_sql.upper()
    for cmd in ["DROP", "DELETE", "UPDATE", "INSERT", "ALTER"]:
        if cmd in upper_sql:
            print(f"[FATAL] SECURITY BREACH: Destructive command blocked ({cmd}).")
            return
            
    print(f"[SYSTEM] Executing SQL: {clean_sql}")
    query_job = bq_client.query(clean_sql)
    results = [dict(row) for row in query_job.result()]
    
    out_bucket = storage_client.bucket(RESULTS_BUCKET)
    out_blob = out_bucket.blob(f"evidence_report_{file_name.replace('.txt', '.json')}")
    out_blob.upload_from_string(json.dumps(results, indent=2, default=str))
    
    print(f"[SUCCESS] Evidence packaged and written to: gs://{RESULTS_BUCKET}/{out_blob.name}")
