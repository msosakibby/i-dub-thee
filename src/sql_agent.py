import os
import vertexai
from vertexai.generative_models import GenerativeModel
from src.schema_context import FLAT_SCHEMA_DDL

class ForensicSQLAgent:
    def __init__(self):
        # Bind to the physical project reality
        self.project_id = os.environ.get("GCP_PROJECT", "i-dub-thee")
        self.location = "us-central1"
        
        # Initialize the secure AI perimeter
        vertexai.init(project=self.project_id, location=self.location)
        self.model = GenerativeModel("gemini-2.5-pro")

    def translate_to_sql(self, hypothesis: str) -> str:
        """
        Translates a natural language legal hypothesis into Daubert-admissible BigQuery SQL.
        """
        prompt = f"""
        You are a forensic legal data engineer. 
        Your ONLY job is to translate the user's natural language hypothesis into a BigQuery SQL statement.
        
        STRICT LAWS:
        1. ONLY output raw, executable BigQuery SQL. Do not include markdown formatting like ```sql or explanations.
        2. You are STRICTLY FORBIDDEN from outputting DROP, DELETE, UPDATE, INSERT, or ALTER statements. 
        3. You may ONLY use the tables and columns defined in this schema:
        
        {FLAT_SCHEMA_DDL}

        Hypothesis to translate: {hypothesis}
        """
        
        # 1. Generate the SQL
        response = self.model.generate_content(prompt)
        raw_sql = response.text
        
        # 2. Clean AI Markdown Hallucinations
        clean_sql = raw_sql.replace("```sql", "").replace("```", "").strip()
        
        # 3. ZERO-TRUST KILL SWITCH (Physical Python Block)
        upper_sql = clean_sql.upper()
        forbidden_commands = ["DROP", "DELETE", "UPDATE", "INSERT", "ALTER"]
        
        for command in forbidden_commands:
            if command in upper_sql:
                raise ValueError(f"SECURITY BREACH: LLM attempted destructive command: {command}")
                
        return clean_sql
