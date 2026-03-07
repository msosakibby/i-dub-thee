import sys
import json
from src.sql_agent import ForensicSQLAgent
from src.bq_query_runner import BigQueryExecutor

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 run_hypothesis_local.py 'Your natural language query here'")
        sys.exit(1)

    hypothesis = sys.argv[1]
    print(f"\n============================================================================")
    print(f" [HYPOTHESIS]: {hypothesis}")
    print(f"============================================================================")

    # 1. Translate English to SQL
    print("\n[SYSTEM] Calling Vertex AI to generate strict Flat-JSON SQL...")
    agent = ForensicSQLAgent()
    try:
        sql_query = agent.translate_to_sql(hypothesis)
        print(f"\n[TRANSLATED SQL]:\n{sql_query}\n")
    except Exception as e:
        print(f"[FATAL] Translation blocked: {e}")
        sys.exit(1)

    # 2. Execute SQL against BigQuery
    executor = BigQueryExecutor()
    results = executor.execute_read_only(sql_query)

    # 3. Output the raw forensic evidence
    print(f"\n[SYSTEM] Forensic Fact Base returned {len(results)} rows.")
    print(f"============================================================================")
    print(json.dumps(results, indent=2, default=str))
    print(f"============================================================================")

if __name__ == "__main__":
    main()
