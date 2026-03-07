import os
import zipfile
from pathlib import Path
from datetime import datetime

# ==============================================================================
# EXTREME DETAIL DOCUMENTATION ASSETS
# ==============================================================================

PROJECT_BLUEPRINT = """# PROJECT BLUEPRINT: Legal Forensics & Trust Protection Engine (V17.0.0)

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
"""

MASTER_CONTROL = """# MASTER CONTROL DOCUMENT

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
"""

FUNCTIONAL_REQS = """# FUNCTIONAL REQUIREMENTS

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
"""

TECHNICAL_REQS = """# TECHNICAL REQUIREMENTS

## 1. Infrastructure Stack
* **Local IDE:** NixOS Container (Project IDX), Python 3.11.10.
* **Compute:** Google Cloud Run Functions (gen2, 4096MB memory, 540s timeout), Google Cloud Run (FastAPI).
* **AI/ML:** Google Vertex AI (`gemini-2.5-pro`), Document AI (Form Parser v2).
* **Database:** Google BigQuery (Serverless).

## 2. Core Python Dependencies (`requirements.txt`)
* `google-cloud-storage>=2.14.0`
* `google-cloud-bigquery>=3.17.0`
* `google-cloud-documentai>=3.4.0`
* `google-genai>=0.3.0`
* `pydantic==2.6.1`
* `pytest>=8.0.0`
* `functions-framework>=3.8.0`
* `pypdf>=4.1.0`
* `fastapi>=0.109.2`
* `uvicorn>=0.27.1`

## 3. Service Account IAM Matrix (`forensic-engine-sa`)
* `roles/storage.admin` (Required for Eventarc trigger configurations)
* `roles/bigquery.dataEditor`
* `roles/bigquery.jobUser`
* `roles/documentai.apiUser`
* `roles/aiplatform.user`
* `roles/eventarc.eventReceiver`
* `roles/run.invoker`

## 4. Mathematical Validation (Pydantic)
* All data models MUST implement `model_config = ConfigDict(extra='forbid')` to prevent LLM hallucinations from silently injecting non-schema fields.
* All financial and sequential schemas MUST contain an `@model_validator(mode='after')` decorator that manually recalculates the sub-totals, taxes, and running balances using the `extracted_string_or_numeric_value` fields before allowing the object to instantiate.
"""

def generate_documents():
    print("[SYSTEM] Authoring Extreme Detail GHFMD Documentation...")
    docs = {
        "PROJECT_BLUEPRINT.md": PROJECT_BLUEPRINT,
        "MASTER_CONTROL_DOCUMENT.md": MASTER_CONTROL,
        "FUNCTIONAL_REQUIREMENTS.md": FUNCTIONAL_REQS,
        "TECHNICAL_REQUIREMENTS.md": TECHNICAL_REQS
    }
    for filename, content in docs.items():
        Path(filename).write_text(content, encoding="utf-8")
        print(f"    [+] Created {filename}")

def parse_state_and_build_deploy_sh():
    print("\n[SYSTEM] Parsing ENVIRONMENT_STATE to construct monolithic deploy.sh...")
    
    # Locate the environment state file you just uploaded
    state_files = list(Path('.').glob('ENVIRONMENT_STATE*.md'))
    if not state_files:
        print("    [!] FATAL: Could not find ENVIRONMENT_STATE.md. Ensure it is in the root directory.")
        return False
        
    content = state_files[0].read_text(encoding='utf-8')
    parts = content.split('### FILE: ')
    
    deploy_sh = "#!/bin/bash\n"
    deploy_sh += "# ============================================================================\n"
    deploy_sh += "# LEGAL FORENSICS ENGINE - MONOLITHIC RESTORATION SCRIPT\n"
    deploy_sh += "# Generated from mathematically verified state artifact.\n"
    deploy_sh += "# ============================================================================\n"
    deploy_sh += "set -e\nset -o pipefail\n\n"
    deploy_sh += "echo '[SYSTEM] Rebuilding Legal Forensics Engine Codebase...'\n\n"
    
    file_count = 0
    for part in parts[1:]:
        lines = part.splitlines()
        filepath = lines[0].strip()
        if filepath.startswith('./'):
            filepath = filepath[2:]
            
        try:
            # Extract content strictly between the markdown backticks
            start_idx = part.index('```')
            start_idx = part.index('\n', start_idx) + 1
            end_idx = part.rindex('```')
            file_data = part[start_idx:end_idx].strip()
            
            # Escape EOF markers if they exist inside the code to prevent bash breakage
            file_data = file_data.replace('EOF', 'EOF_ESCAPED')
            
            deploy_sh += f"mkdir -p $(dirname \"{filepath}\")\n"
            deploy_sh += f"cat << 'EOF_INTERNAL_MARKER' > \"{filepath}\"\n{file_data}\nEOF_INTERNAL_MARKER\n\n"
            file_count += 1
        except Exception as e:
            print(f"    [-] Failed to parse {filepath}: {e}")
            continue
            
    Path("deploy.sh").write_text(deploy_sh, encoding='utf-8')
    os.chmod("deploy.sh", 0o755)
    print(f"    [+] Successfully injected {file_count} codebase files into deploy.sh")
    return True

def package_downloadable_archive():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    zip_filename = f"Legal_Forensics_Release_{timestamp}.zip"
    
    print(f"\n[SYSTEM] Compressing artifacts into downloadable archive: {zip_filename}...")
    
    targets = [
        "PROJECT_BLUEPRINT.md",
        "MASTER_CONTROL_DOCUMENT.md",
        "FUNCTIONAL_REQUIREMENTS.md",
        "TECHNICAL_REQUIREMENTS.md",
        "deploy.sh"
    ]
    
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for target in targets:
            if os.path.exists(target):
                zipf.write(target)
                
    print(f"    [+] Archive complete.")
    print("============================================================================")
    print(f" [ACTION REQUIRED] Right-click '{zip_filename}' in your IDE and select 'Download'")
    print("============================================================================")

if __name__ == '__main__':
    print("============================================================================")
    print(" INITIATING ZERO-TRUST ARTIFACT GENERATOR ")
    print("============================================================================")
    generate_documents()
    if parse_state_and_build_deploy_sh():
        package_downloadable_archive()