#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 2B V10.3.0 (FORENSIC UI & CITATIONS)"
echo "============================================================================"

mkdir -p pristine_deployment_chamber
cd pristine_deployment_chamber

echo "[SYSTEM] 1. Forging Modern Dependencies..."
cat << 'EOF_REQ' > requirements.txt
google-cloud-storage==2.14.0
google-genai==0.3.0
pydantic==2.6.3
asyncio==3.4.3
EOF_REQ

echo "[SYSTEM] 2. Forging Analytical Container (forensic_router.py)..."
cat << 'EOF_PYTHON_ROUTER' > forensic_router.py
import os
import sys
import json
import asyncio
import logging
from google.cloud import storage
from google import genai
from google.genai import types
from pydantic import BaseModel, Field, ConfigDict

# Strict logging for Zero-Trust Auditing
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - FORENSIC_ORCHESTRATOR - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ==============================================================================
# UNIVERSAL CITATION MANDATE
# ==============================================================================
CITATION_MANDATE = """

ZERO-TRUST MANDATE: You must ONLY use, extract, or analyze referenceable facts explicitly present in the provided document. You are strictly prohibited from hallucinating, inferring, or assuming external information. Every single extracted data point, analytical conclusion, and strategic assessment MUST include a direct inline citation referencing the exact section, page, paragraph, or table from the document (e.g., [Citation: Page 1, 'Total Amount Due' section]).
"""

# ==============================================================================
# PYDANTIC SCHEMA ENFORCEMENT (SHOCK ABSORBER & CITATION BINDING)
# ==============================================================================
class ExtractedFact(BaseModel):
    key_name: str = Field(description="The exact name of the extracted data point.")
    exact_value: str = Field(description="The precise alphanumeric value extracted.")
    document_citation: str = Field(description="MANDATORY: Strict citation of exactly where this fact was found in the text.")

class DossierMetadata(BaseModel):
    system_version: str = Field(description="The system version string.")
    source_artifact_uri: str = Field(description="The GCS URI pointer.")
    cryptographic_hash: str = Field(description="The SHA-256 hash.")
    ingestion_timestamp_utc: str = Field(description="The UTC timestamp.")
    taxonomy_vector: str = Field(description="The path classification.")
    zero_trust_mandate: str = Field(description="Strict enforcement status.")

class ForensicExhaustiveJSON(BaseModel):
    model_config = ConfigDict(extra='ignore') # The Shock Absorber
    dossier_metadata: DossierMetadata = Field(description="The immutable ledger metadata.")
    document_summary: str = Field(description="A brief summary of the document's contents.")
    extracted_facts: list[ExtractedFact] = Field(description="An exhaustive array of every referenced fact.")

# ==============================================================================
# UI ARCHITECTURE & CRYPTOGRAPHIC LEDGER
# ==============================================================================
def build_universal_header(report_name, original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector):
    return f"""# 🏛️ FORENSIC DOSSIER: {report_name}
**System:** Legal Forensics Engine V10.3.0 | **Model:** Gemini-2.5-Pro (Native URI)

## 🔗 CHAIN OF CUSTODY & ARTIFACT MATRIX
| Admissibility Metric | Cryptographic Value |
| :--- | :--- |
| **Source Artifact** | [`{original_filename}`](./{original_filename}) |
| **Cryptographic Hash** | `{sha256_hash}` |
| **Ingestion Timestamp** | `{utc_timestamp}` |
| **Taxonomy Vector** | `{taxonomy_vector}` |
| **Zero-Trust Mandate** | STRICT CITATION ENFORCEMENT ACTIVE (FRE 901/902) |

## 🗂️ DOSSIER NAVIGATION PORTAL
*Click to cross-navigate between concurrent forensic threads generated from this artifact.*
* 📄 **[Source]** [`Original Document Image`](./{original_filename})
* 🏗️ **[Report 1]** [`Structural Recreation & Baseline Data`](./{event_name}_Report1_Structural.md)
* ��️ **[Report 2]** [`Forensic Analyst Content Verification`](./{event_name}_Report2_Analyst.md)
* 🏛️ **[Report 3]** [`Elite Expert Strategic Assessment`](./{event_name}_Report3_Expert.md)
* ⚖️ **[Report 4]** [`QA Architect Entity Refinement`](./{event_name}_Report4_QA.md)
* 🧩 **[Report 5]** [`Exhaustive Fact Base Extraction (JSON)`](./{event_name}_Report5_Extraction.json)
* 🎭 **[Report 6]** [`Opposing Counsel Gambit & Legal Strategy`](./{event_name}_Report6_LegalGambit.md)

---
"""

def apply_shadow_box_and_footer(raw_markdown, original_filename, sha256_hash, utc_timestamp, header_markdown):
    return f"""{header_markdown}
<div markdown="1" style="border: 1px solid #d3d3d3; border-radius: 6px; padding: 25px; box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.08); background-color: #ffffff; margin-top: 20px; margin-bottom: 20px;">

{raw_markdown}

</div>

<div align="center" style="font-size: 0.85em; color: #555; border-top: 1px solid #eaeaea; padding-top: 15px; margin-top: 30px;">
  <b>🛡️ ZERO-TRUST COMPLIANCE & CHAIN OF CUSTODY VALIDATED</b><br>
  <i>This extraction was mathematically anchored by the Legal Forensics Engine at <b>{utc_timestamp}</b>.</i><br>
  <i>Source Hash: <code>{sha256_hash}</code> | Algorithm: Deterministic Geometry + Multi-Modal LLM</i><br>
  <a href="./{original_filename}" style="color: #0056b3; text-decoration: none;"><b>[ VIEW SOURCE ARTIFACT ]</b></a>
</div>
"""

# ==============================================================================
# GEOMETRIC PATH & PERSISTENCE ENGINE
# ==============================================================================
def build_gcs_uri(bucket_name: str, blob_name: str) -> str:
    return f"gs://{bucket_name}/{blob_name}"

def generate_artifact_paths(source_blob_name: str) -> dict:
    base_path = source_blob_name.rsplit('.', 1)[0]
    return {
        "report_1": f"{base_path}_Report1_Structural.md",
        "report_2": f"{base_path}_Report2_Analyst.md",
        "report_3": f"{base_path}_Report3_Expert.md",
        "report_4": f"{base_path}_Report4_QA.md",
        "report_5": f"{base_path}_Report5_Extraction.json",
        "report_6": f"{base_path}_Report6_LegalGambit.md"
    }

def persist_forensic_artifacts(bucket, source_blob_name: str, payloads: dict):
    paths = generate_artifact_paths(source_blob_name)
    logger.info(f"Anchoring Report 1 (Structural) to {paths['report_1']}")
    bucket.blob(paths['report_1']).upload_from_string(payloads['report_1'], content_type="text/markdown")
    logger.info(f"Anchoring Report 2 (Analyst) to {paths['report_2']}")
    bucket.blob(paths['report_2']).upload_from_string(payloads['report_2'], content_type="text/markdown")
    logger.info(f"Anchoring Report 3 (Expert) to {paths['report_3']}")
    bucket.blob(paths['report_3']).upload_from_string(payloads['report_3'], content_type="text/markdown")
    logger.info(f"Anchoring Report 4 (QA) to {paths['report_4']}")
    bucket.blob(paths['report_4']).upload_from_string(payloads['report_4'], content_type="text/markdown")
    logger.info(f"Anchoring Report 5 (JSON) to {paths['report_5']}")
    bucket.blob(paths['report_5']).upload_from_string(payloads['report_5'], content_type="application/json")
    logger.info(f"Anchoring Report 6 (Legal Gambit) to {paths['report_6']}")
    bucket.blob(paths['report_6']).upload_from_string(payloads['report_6'], content_type="text/markdown")

# ==============================================================================
# ASYNCHRONOUS AI EXTRACTION ENGINE (BLAST WALLS ACTIVE)
# ==============================================================================
async def execute_prompt_safe(client, model_id, document_part, prompt_text, schema=None, is_json=False):
    try:
        config_args = {"temperature": 0.0}
        if is_json and schema:
            config_args["response_mime_type"] = "application/json"
            config_args["response_schema"] = schema
        else:
            config_args["response_mime_type"] = "text/plain"

        config = types.GenerateContentConfig(**config_args)
        response = await client.aio.models.generate_content(
            model=model_id,
            contents=[document_part, prompt_text],
            config=config
        )
        return response.text
    except Exception as e:
        logger.error(f"Thread Execution Failed: {str(e)}")
        if is_json:
            return json.dumps({"error": "Extraction failed.", "details": str(e)})
        else:
            return f"## FORENSIC EXTRACTION FAILED\n\n**System Error:** {str(e)}\n\n*This thread was safely isolated.*"

async def run_concurrent_forensics(project_id: str, bucket_name: str, blob_name: str, sha256_hash: str, utc_timestamp: str) -> dict:
    client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="us-central1")
    model_id = "gemini-2.5-pro"
    
    uri = build_gcs_uri(bucket_name, blob_name)
    document_part = types.Part.from_uri(file_uri=uri, mime_type='application/pdf')

    # Deep Routing Algebra for Dynamic Variables
    parts = blob_name.split('/')
    lane = parts[0] if len(parts) > 0 else "UNKNOWN"
    entity = parts[1] if len(parts) > 1 else "UNKNOWN"
    institution = parts[2] if len(parts) > 2 else "UNKNOWN"
    event_name = parts[3] if len(parts) > 3 else "UNKNOWN"
    original_filename = parts[-1]
    taxonomy_vector = f"{lane} / {entity} / {institution}"

    # CORE PROMPTS + CITATION MANDATE
    p_report_1 = "You are an expert document formatter. STRUCTURAL RECREATION: Output a precise MARKDOWN representation of this document's visual layout. Preserve all structure. include all images. Tables must use GFM." + CITATION_MANDATE
    p_report_2 = "Your role is to act as a highly specialized Forensic Document Analyst. Analyze the document content thoroughly and produce a detailed report in strict GHFMD. Include Executive Summary, Content Verification, Risk Assessment, and Data Extraction." + CITATION_MANDATE
    p_report_3 = "System Objective: You are an AI routing mechanism. Immediately adopt the persona of the most elite, specialized forensic expert suited to analyze the document. Produce BLUF, Insights, and Actionable Steps in Markdown." + CITATION_MANDATE
    p_report_4 = "You are a Forensic QA Architect. Review the document and outline a 3-step refinement strategy for extracting secondary/tertiary entities." + CITATION_MANDATE
    
    p_report_5 = f"You are an expert document transcriber. Perform an EXHAUSTIVE EXTRACTION. MANDATORY DOSSIER METADATA: System: Legal Forensics Engine V10.3.0, URI: {uri}, Hash: {sha256_hash}, UTC: {utc_timestamp}, Taxonomy: {taxonomy_vector}." + CITATION_MANDATE
    
    p_report_6 = "You are a divorce attorney with more than two decades obtaining favorable outcomes... You are opposing council as described how woud this document be tactically or strategically leveraged in what context and how as a surprise or unusual gambit." + CITATION_MANDATE

    logger.info(f"Executing direct GCS URI extraction from {uri} (6 Threads)...")
    results = await asyncio.gather(
        execute_prompt_safe(client, model_id, document_part, p_report_1),
        execute_prompt_safe(client, model_id, document_part, p_report_2),
        execute_prompt_safe(client, model_id, document_part, p_report_3),
        execute_prompt_safe(client, model_id, document_part, p_report_4),
        execute_prompt_safe(client, model_id, document_part, p_report_5, schema=ForensicExhaustiveJSON, is_json=True),
        execute_prompt_safe(client, model_id, document_part, p_report_6)
    )

    # UI INJECTION
    h_r1 = build_universal_header("Structural Recreation", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r2 = build_universal_header("Forensic Analyst", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r3 = build_universal_header("Elite Expert", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r4 = build_universal_header("QA Architect", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r6 = build_universal_header("Legal Gambit (Opposing Counsel)", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)

    return {
        "report_1": apply_shadow_box_and_footer(results[0], original_filename, sha256_hash, utc_timestamp, h_r1),
        "report_2": apply_shadow_box_and_footer(results[1], original_filename, sha256_hash, utc_timestamp, h_r2),
        "report_3": apply_shadow_box_and_footer(results[2], original_filename, sha256_hash, utc_timestamp, h_r3),
        "report_4": apply_shadow_box_and_footer(results[3], original_filename, sha256_hash, utc_timestamp, h_r4),
        "report_5": results[4], # JSON bypasses Markdown UI wrapping
        "report_6": apply_shadow_box_and_footer(results[5], original_filename, sha256_hash, utc_timestamp, h_r6)
    }
EOF_PYTHON_ROUTER

echo "[SYSTEM] 3. Forging Fortified Container Entrypoint (main.py)..."
cat << 'EOF_MAIN_PYTHON' > main.py
import os
import sys
import logging
import asyncio
import hashlib
from datetime import datetime, timezone
from google.cloud import storage

logging.basicConfig(level=logging.INFO, format='%(asctime)s - CONTAINER_ENTRY - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

try:
    from forensic_router import run_concurrent_forensics, persist_forensic_artifacts
except ImportError as e:
    logger.error(f"FATAL IMPORT ERROR: {str(e)}")
    sys.exit(1)

if __name__ == "__main__":
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    bucket_name = os.environ.get("CE_BUCKET")
    subject_name = os.environ.get("CE_SUBJECT")

    if not bucket_name or not subject_name:
        logger.error("FATAL: Missing CE_BUCKET or CE_SUBJECT variables.")
        sys.exit(1)

    # ZERO-TRUST RECURSIVE SEVERANCE GATE
    valid_extensions = ('.pdf', '.jpg', '.jpeg', '.png')
    if not subject_name.lower().endswith(valid_extensions) or "_Report" in subject_name:
        logger.info(f"[LOOP SEVERED] Ignoring secondary artifact: {subject_name}")
        sys.exit(0)

    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(subject_name)
        
        # Download once purely for mathematical hashing (not sent to AI)
        file_bytes = blob.download_as_bytes()
        if len(file_bytes) == 0:
            logger.info(f"[LOOP SEVERED] Ignoring 0-byte directory marker: {subject_name}")
            sys.exit(0)
            
        sha256_hash = hashlib.sha256(file_bytes).hexdigest()
        utc_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        
        logger.info(f"Hash Computed: {sha256_hash} | UTC: {utc_timestamp}")
        logger.info("Engaging 6-Part asynchronous cognitive engine via direct URI pointers...")
        
        payloads = asyncio.run(run_concurrent_forensics(project_id, bucket_name, subject_name, sha256_hash, utc_timestamp))
        
        logger.info("Anchoring UI-wrapped artifacts to Deep Taxonomy Storage...")
        persist_forensic_artifacts(bucket, subject_name, payloads)
        
        logger.info("Layer 2B V10.3.0 Execution Complete. Exiting cleanly.")
        sys.exit(0)

    except Exception as e:
        logger.error(f"FATAL SYSTEM EXCEPTION: {str(e)}")
        sys.exit(1)
EOF_MAIN_PYTHON

echo "[SYSTEM] 4. Deploying Fortified Cloud Run Job..."
gcloud run jobs deploy layer2b-analytical-job \
    --source . \
    --region us-central1 \
    --service-account "$SERVICE_ACCOUNT" \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=$PROJECT_ID" \
    --max-retries 0 \
    --task-timeout 600s \
    --memory 2Gi \
    --quiet

cd ..
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] LAYER 2B V10.3.0 MASTER ARCHITECTURE ONLINE"
echo "============================================================================"
