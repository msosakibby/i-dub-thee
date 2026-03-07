# PROJECT BLUEPRINT: Legal Forensics & Trust Protection Engine (V17.0.0)

## 1. Executive Vision
A Daubert-admissible, serverless forensic accounting pipeline designed to enforce Paragraph 8F and Paragraph 6 constraints. The system completely bypasses generative AI trust in favor of deterministic algorithmic skepticism, strictly enforcing a cryptographic chain-of-custody that links newly generated data schemas directly back to the binary hashes of their original parent PDFs.

## 2. Core Architectural Pillars
* **Layer 1 (Ingestion & Optical Extraction):** Eventarc-triggered Cloud Run Functions (gen2) detect finalized PDFs in `gs://i-dub-thee-forensic-vault/`. Documents are sliced, hashed (SHA-256), and routed through Google Document AI (Form Parser).
* **Layer 2 (The Hypothesis Engine):** A Hybrid RAG FastAPI application that translates natural language queries into strictly typed Google Standard SQL to interrogate the BigQuery Fact Base, while cross-referencing qualitative Markdown context from Google Cloud Storage.
* **The Geospatial Anchor Engine:** A deterministic Python module that maps handwritten marginalia to printed text based on hard mathematical coordinate proximity (`v_thresh=0.05`, `h_thresh=0.40`).
* **Tri-Pass Synthesis:** Documents undergo three distinct LLM passes: Visual Layout (UHF Markdown), Narrative Summary/Persona, and Exhaustive JSON extraction.

## 3. Storage & Data Warehouse Infrastructure
* **Intake Vault:** `gs://i-dub-thee-forensic-vault/` (Public access prevented, automated event routing).
* **Master Filing Cabinet:** `gs://i-dub-thee-master-filing-cabinet/` (Permanent archive storing `.pdf`, `layout.md`, `summary.md`, and `exhaustive.json`).
* **Forensic Fact Base:** BigQuery Dataset `forensic_fact_base.ingestion_ledger` acting as the immutable terminal state for all mathematically verified schemas.
