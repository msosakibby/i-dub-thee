import os
from google.cloud import bigquery

class BigQueryExecutor:
    def __init__(self):
        self.project_id = os.environ.get("GCP_PROJECT", "i-dub-thee")
        self.client = bigquery.Client(project=self.project_id)

    def execute_read_only(self, sql_query: str):
        """
        Executes the generated SQL against the WORM BigQuery Vault.
        """
        print(f"\n[EXECUTOR] Executing SQL on project: {self.project_id}...")
        try:
            query_job = self.client.query(sql_query)
            results = query_job.result()
            rows = [dict(row) for row in results]
            return rows
        except Exception as e:
            print(f"[FATAL EXCEPTION] BigQuery Execution Failed: {e}")
            return []
