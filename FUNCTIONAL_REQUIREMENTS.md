# FUNCTIONAL REQUIREMENTS

## 1. Automated Schema Ingestion (`tools/schema_ingestor.py`)
* **FR-1.1:** Must extract Python and JSON blocks from raw LLM markdown proposals using strict regular expressions and `textwrap.dedent`.
* **FR-1.2:** Must dynamically inject Pydantic V2 schemas into `src/schemas.py` directly before the `ForensicGoldenEnvelope` definition and seamlessly update the `Union` array.
* **FR-1.3:** Must execute `python3 -m pytest tests/test_iron_gate_factory.py -v` in a subprocess.
* **FR-1.4:** Must permanently route passing schemas to `accepted_schemas/` or failing schemas to `quarantined_schemas/`.

## 2. Autonomous Self-Healing (`tools/self_healer.py`)
* **FR-2.1:** Must pull broken Markdown schemas from the quarantine bucket.
* **FR-2.2:** Must temporarily inject the broken code into the local environment to capture the precise Pytest traceback log (the "Iron Gate Error").
* **FR-2.3:** Must invoke Vertex AI (`gemini-2.5-pro`, temperature=0.0) with the broken code and the error log, applying an Exponential Backoff algorithm (base delay 10s, max 6 retries) to negotiate Google Cloud 429 API rate limits.

## 3. The 18-Lane Taxonomy Routing
* **FR-3.1:** The system must dynamically categorize documents into one of 18 strict schemas (e.g., `LANE_01_PROPERTY_REAL_ESTATE`, `LANE_12_PAYROLL_COMPENSATION`, `JohnDeereUnifiedDocument`).
* **FR-3.2:** The `ForensicGoldenEnvelope` must act as the root JSON wrapper, encapsulating the lane-specific payload alongside the cryptographic hashes and URI pointers.

## 4. Hybrid Hypothesis Engine (`rag_api/main.py`)
* **FR-4.1:** Must accept natural language queries via JSON drops into the `investigations/` storage path.
* **FR-4.2:** Must translate queries into Google Standard SQL to hit the BigQuery `ingestion_ledger`.
* **FR-4.3:** Must pull the corresponding Markdown layout contexts from the Master Filing Cabinet based on the `sliced_child_sha256` hashes returned by the SQL query.
