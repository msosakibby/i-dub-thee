import pytest

# TDD STRICT ENFORCEMENT
try:
    from src.sql_agent import ForensicSQLAgent
except ImportError:
    class ForensicSQLAgent:
        def translate_to_sql(self, query):
            raise NotImplementedError("TDD RED PHASE: src/sql_agent.py has not been deployed yet.")

def test_flat_json_sql_translation_isolation():
    """
    MATHEMATICAL PROOF: The agent must generate a valid BigQuery SELECT statement 
    that targets the flat JSON structure and explicitly rejects destructive commands.
    """
    agent = ForensicSQLAgent()
    
    hypothesis = "Show me all transactions where rule PARAGRAPH_8F_M_AND_J was triggered."
    generated_sql = agent.translate_to_sql(hypothesis)
    
    # 1. Must be a read-only query
    assert "SELECT" in generated_sql.upper()
    assert "DROP" not in generated_sql.upper()
    assert "DELETE" not in generated_sql.upper()
    assert "UPDATE" not in generated_sql.upper()
    
    # 2. Must target the flat vault
    assert "forensic_fact_base_dev.hypothesis_outcomes" in generated_sql

