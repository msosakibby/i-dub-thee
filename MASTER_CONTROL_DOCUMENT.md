# MASTER CONTROL DOCUMENT

## 1. Evidentiary Compliance & Legal Guardrails
* **FRE 901 (Authentication):** The system executes binary `%PDF` header inspection (`504B0304` rejection) prior to processing any file. Every extracted JSON payload must possess a `sliced_child_sha256` traceable to an `original_parent_sha256`.
* **FRE 1006 (Summaries):** Double-entry algebraic checksums are enforced across all 18 Taxonomy Lanes. For example, `Lane04BankingCheckingSchema` natively calculates running balances and automatically resolves sequential "ditto" marks (") before validating against the extracted totals.
* **MRE 801 (Hearsay):** Every single extracted integer or string is wrapped in a `ForensicDataEntity` containing the Document AI confidence score and a strict `BoundingPolygon` (min/max X,Y vertices) mapping the data to its physical location on the page.

## 2. Engineering Directives
* **Zero-Trust Operational Stance:** All LLM-generated JSON is treated as hostile. It is routed through a rigorous Pydantic V2 Iron Gate.
* **Strict TDD (Test-Driven Development):** No structural schema or Python logic is merged without pre-existing adversarial Pytest fixtures proving its mathematical boundaries.
* **Scorched-Earth Rollback:** If the Pytest suite detects a fracture during schema ingestion, the `schema_ingestor.py` instantly reverts the `schemas.py` and `golden_test_registry.json` files to their exact previous state to prevent AST bloat and baseline contamination.

## 3. Human-In-The-Loop (HITL) Governance
* **Confidence Thresholding:** Any optical extraction returning an average Document AI confidence score below `0.90` mathematically triggers the `requires_manual_review = True` flag within the `ForensicGoldenEnvelope`.
* **Quarantine Protocol:** Payloads failing Pydantic `extra_forbidden` rules or GAAP mathematical validators are routed to `gs://i-dub-thee-forensic-vault/quarantined_schemas/` for the `self_healer.py` engine to process.
