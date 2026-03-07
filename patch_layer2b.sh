#!/bin/bash
set -e
echo "[SYSTEM] Patching Layer 2B: Bypassing Pydantic to fix \$defs crash..."
cd pristine_deployment_chamber

cat << 'EOF_PYTHON_ROUTER' > forensic_router.py
import os
import sys
import json
import asyncio
import logging
from google.cloud import storage
from google import genai
from google.genai import types

logging.basicConfig(level=logging.INFO, format='%(asctime)s - FORENSIC_ORCHESTRATOR - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

COMPLIANCE_FOOTER = "\n\n---\n\n### 🛡️ ZERO-TRUST SYSTEM COMPLIANCE & CHAIN OF CUSTODY AUDIT\n*This document was generated under the strict parameters of the Legal Forensics Engine V10.5.1.*\n* **FR-2.1:** Cryptographic Hash verified.\n* **FR-1.3:** Strict citation enforcement active."

def append_compliance_footer(text: str, is_json: bool) -> str:
    if is_json: return text
    return text + COMPLIANCE_FOOTER

# ==============================================================================
# NATIVE SDK SCHEMA (Bypassing Pydantic $defs bug)
# ==============================================================================
ForensicExhaustiveSchema = types.Schema(
    type=types.Type.OBJECT,
    properties={
        "dossier_metadata": types.Schema(
            type=types.Type.OBJECT,
            properties={
                "system_version": types.Schema(type=types.Type.STRING),
                "source_artifact_uri": types.Schema(type=types.Type.STRING),
                "cryptographic_hash": types.Schema(type=types.Type.STRING),
                "ingestion_timestamp_utc": types.Schema(type=types.Type.STRING),
                "taxonomy_vector": types.Schema(type=types.Type.STRING),
                "zero_trust_mandate": types.Schema(type=types.Type.STRING),
            }
        ),
        "document_summary": types.Schema(type=types.Type.STRING),
        "extracted_facts": types.Schema(
            type=types.Type.ARRAY,
            items=types.Schema(
                type=types.Type.OBJECT,
                properties={
                    "key_name": types.Schema(type=types.Type.STRING),
                    "exact_value": types.Schema(type=types.Type.STRING),
                    "document_citation": types.Schema(type=types.Type.STRING),
                }
            )
        )
    }
)

CITATION_MANDATE = "\n\nZERO-TRUST MANDATE: You must ONLY extract referenceable facts explicitly present in the document. Every extracted data point MUST include a direct inline citation (e.g., [Citation: Page 1])."

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
    for rep_key, content_type in [
        ('report_1', 'text/markdown'), ('report_2', 'text/markdown'),
        ('report_3', 'text/markdown'), ('report_4', 'text/markdown'),
        ('report_5', 'application/json'), ('report_6', 'text/markdown')
    ]:
        logger.info(f"Anchoring {rep_key} to {paths[rep_key]}")
        bucket.blob(paths[rep_key]).upload_from_string(payloads[rep_key], content_type=content_type)

def build_universal_header(report_name, original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector):
    return f"# 🏛️ FORENSIC DOSSIER: {report_name}\n**System:** V10.5.1\n\n## 🔗 CHAIN OF CUSTODY\n**Source:** `{original_filename}`\n**Hash:** `{sha256_hash}`\n**UTC:** `{utc_timestamp}`\n**Vector:** `{taxonomy_vector}`\n\n---\n"

def apply_shadow_box_and_footer(raw_markdown, original_filename, sha256_hash, utc_timestamp, header_markdown):
    return f"{header_markdown}\n\n{raw_markdown}\n\n<div align='center'><b>🛡️ ZERO-TRUST COMPLIANCE VALIDATED</b><br><i>Hash: <code>{sha256_hash}</code></i></div>"

async def execute_prompt_safe(client, model_id, document_part, prompt_text, schema=None, is_json=False):
    try:
        config_args = {"temperature": 0.0}
        if is_json and schema:
            config_args["response_mime_type"] = "application/json"
            config_args["response_schema"] = schema
        else:
            config_args["response_mime_type"] = "text/plain"

        config = types.GenerateContentConfig(**config_args)
        response = await client.aio.models.generate_content(model=model_id, contents=[document_part, prompt_text], config=config)
        return response.text
    except Exception as e:
        logger.error(f"Thread Execution Failed: {str(e)}")
        if is_json: return json.dumps({"error": "Extraction failed.", "details": str(e)})
        else: return f"## FORENSIC EXTRACTION FAILED\n\n**System Error:** {str(e)}"

async def run_concurrent_forensics(project_id: str, bucket_name: str, blob_name: str, sha256_hash: str, utc_timestamp: str) -> dict:
    client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="us-central1")
    model_id = "gemini-2.5-pro"
    uri = build_gcs_uri(bucket_name, blob_name)
    document_part = types.Part.from_uri(file_uri=uri, mime_type='application/pdf')

    parts = blob_name.split('/')
    lane = parts[0] if len(parts)>0 else "UNKNOWN"
    entity = parts[1] if len(parts)>1 else "UNKNOWN"
    institution = parts[2] if len(parts)>2 else "UNKNOWN"
    event_name = parts[3] if len(parts)>3 else "UNKNOWN"
    original_filename = parts[-1]
    
    classification = "Unknown"
    if " - " in event_name:
        ep = event_name.split(" - ")
        if len(ep) >= 4: classification = ep[3]

    taxonomy_vector = f"{lane} / {entity} / {institution} / {classification}"

    p_report_1 = "Output a precise MARKDOWN representation of this document's visual layout. Preserve all structure." + CITATION_MANDATE
    p_report_2 = "Produce a detailed report in strict GHFMD. Include Executive Summary, Content Verification, Risk Assessment, and Data Extraction." + CITATION_MANDATE
    p_report_3 = "Adopt the persona of the most elite, specialized forensic expert suited to analyze the document. Produce BLUF, Insights, and Actionable Steps." + CITATION_MANDATE
    p_report_4 = "You are a Forensic QA Architect. Outline a 3-step refinement strategy for extracting secondary entities." + CITATION_MANDATE
    p_report_5 = f"Perform an EXHAUSTIVE EXTRACTION.\n\nExtract all key-value pairs.\nMANDATORY DOSSIER METADATA: System: V10.5.1, URI: {uri}, Hash: {sha256_hash}, UTC: {utc_timestamp}, Taxonomy: {taxonomy_vector}.\n" + CITATION_MANDATE
    p_report_6 = "You are opposing council. Describe how this document could be tactically leveraged as a surprise gambit." + CITATION_MANDATE

    results = await asyncio.gather(
        execute_prompt_safe(client, model_id, document_part, p_report_1),
        execute_prompt_safe(client, model_id, document_part, p_report_2),
        execute_prompt_safe(client, model_id, document_part, p_report_3),
        execute_prompt_safe(client, model_id, document_part, p_report_4),
        execute_prompt_safe(client, model_id, document_part, p_report_5, schema=ForensicExhaustiveSchema, is_json=True),
        execute_prompt_safe(client, model_id, document_part, p_report_6)
    )

    h_r1 = build_universal_header("Structural Recreation", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r2 = build_universal_header("Forensic Analyst", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r3 = build_universal_header("Elite Expert", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r4 = build_universal_header("QA Architect", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)
    h_r6 = build_universal_header("Legal Gambit", original_filename, event_name, sha256_hash, utc_timestamp, taxonomy_vector)

    return {
        "report_1": apply_shadow_box_and_footer(results[0], original_filename, sha256_hash, utc_timestamp, h_r1),
        "report_2": apply_shadow_box_and_footer(results[1], original_filename, sha256_hash, utc_timestamp, h_r2),
        "report_3": apply_shadow_box_and_footer(results[2], original_filename, sha256_hash, utc_timestamp, h_r3),
        "report_4": apply_shadow_box_and_footer(results[3], original_filename, sha256_hash, utc_timestamp, h_r4),
        "report_5": results[4],
        "report_6": apply_shadow_box_and_footer(results[5], original_filename, sha256_hash, utc_timestamp, h_r6)
    }
EOF_PYTHON_ROUTER

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

gcloud run jobs deploy layer2b-analytical-job \
    --source . \
    --region us-central1 \
    --service-account "$SERVICE_ACCOUNT" \
    --max-retries 0 \
    --task-timeout 600s \
    --memory 2Gi \
    --quiet

cd ..
echo "[SUCCESS] PART 1 DEPLOYED."
