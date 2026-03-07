#!/bin/bash
set -e
echo "[SYSTEM] Patching Layer 1: Enforcing Strict Regex Family Reject List..."
cd layer1_intake

cat << 'EOF_LAYER1_MAIN' > main.py
import os
import json
import hashlib
import re
import functions_framework
from google.cloud import storage
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

ENTITY_ALIAS_MAP = {
  "Judith Grandy": ["A GRANDY", "JA GRANDY", "JOYCE A GRANDY", "JUDITH A GRANDY", "JUDITH A GRANDY TTEE", "JUDITH A KIBBY", "JUDITH ANN GRANDY", "JUDITH GRANDY", "JUDITH KIBBY", "JUDITH KLHHY", "JUDITHA GRANDY", "JUDITHANN GRANDY", "JUDY GRANDY", "JUDY KIBBY", "JUDITH A KIBBY GRANDY", "JUDY", "MRS JUDITH A GRANDY"],
  "Keith Grandy": ["GRANDY KEITH ARTHUR", "GRANDY KIETH", "K GRANDY", "KEITH A GRANDY", "KEITH ARTHUR GRANDY", "KEITH GRANDY", "KATH GRANELY"],
  "KibbyCo": ["KIBBY CO", "KIBBY COMPANY", "KIBBY COMPANY LLC"],
  "K Grandy Enterprises": ["K GRANDY ENTERPRISES LLC"],
  "Max R Kibby Trust": ["MAX R KIBBY"]
}

# THE STRICT REGEX REJECT LIST (Intercepts all variations of restricted family)
REJECT_PATTERN = re.compile(r'(?i)\b(Mark Kibby|Mark Sosa-Kibby|Mark William Sosa|Mark Willliam Sosa|Mark W Kibby|Parker Sosa-Kibby|Cole Sosa-Kibby|Erik Sosa-Kibby|Parker|Cole|Erik)\b')

def normalize_entity_name(raw_name: str) -> str:
    upper_name = raw_name.upper().strip()
    for canonical, aliases in ENTITY_ALIAS_MAP.items():
        if upper_name in aliases:
            return canonical
    return raw_name.strip()

def sanitize_path_string(text: str) -> str:
    return re.sub(r'[\\/:*?"<>|]', '_', text).strip()

def build_standardized_event_name(doc_date: str, primary_subject: str, entity: str, classification: str, institution: str, ref_id: str) -> str:
    base = f"{doc_date} - {primary_subject} - {entity} - {classification} - {institution}"
    if ref_id.upper() != "NONE": return f"{base} - {ref_id}"
    return base

def build_deep_geometric_path(lane: str, entity: str, institution: str, event_name: str, extension: str) -> str:
    return f"{lane}/{entity}/{institution}/{event_name}/{event_name}{extension}"

class Layer1RoutingSchema(BaseModel):
    document_date: str = Field(description="YYYY-MM-DD. If unknown, use 1900-01-01.")
    primary_subject: str = Field(description="Exact individual or business entity name.")
    document_classification: str = Field(description="e.g., 'Bank Statement', 'Utility Bill'.")
    institution_name: str = Field(description="e.g., 'Horizon Bank', 'Great Lakes Energy'.")
    primary_reference_id: str = Field(description="Last 4 digits of account, or full invoice number. Or 'NONE'.")
    recommended_18_lane_id: str = Field(description="e.g., 'LANE_04_BANKING'. If unknown, 'LANE_99_UNKNOWN'.")
    confidence_score: float = Field(description="Confidence from 0.0 to 1.0.")

def validate_pdf_binary(file_bytes: bytes) -> bool:
    if not file_bytes.startswith(b'%PDF'): raise ValueError("FATAL: Invalid binary header.")
    return True

def move_blob(bucket_name: str, source_blob_name: str, destination_bucket_name: str, destination_blob_name: str):
    storage_client = storage.Client()
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(source_blob_name)
    destination_bucket = storage_client.bucket(destination_bucket_name)
    source_bucket.copy_blob(source_blob, destination_bucket, destination_blob_name)
    source_blob.delete()

@functions_framework.cloud_event
def process_document(cloud_event):
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]

    if "input/" not in file_name: return

    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    
    try:
        file_bytes = blob.download_as_bytes()
        validate_pdf_binary(file_bytes)
        
        client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="us-central1")
        model_id = "gemini-2.5-pro"
        prompt = "Extract the routing geometry variables from this document."
        pdf_part = types.Part.from_bytes(data=file_bytes, mime_type='application/pdf')
        config = types.GenerateContentConfig(temperature=0.0, response_mime_type="application/json", response_schema=Layer1RoutingSchema)

        alpha_res = client.models.generate_content(model=model_id, contents=[pdf_part, prompt], config=config)
        alpha_data = json.loads(alpha_res.text)

        raw_subject = sanitize_path_string(alpha_data["primary_subject"])

        # 🚨 THE HARD REGEX FIREWALL (Intercepts Mark William Sosa instantly)
        if REJECT_PATTERN.search(raw_subject):
            raise ValueError(f"FAMILY_FIREWALL_TRIGGERED: '{raw_subject}' is strictly restricted.")

        beta_res = client.models.generate_content(model=model_id, contents=[pdf_part, prompt], config=config)
        beta_data = json.loads(beta_res.text)

        doc_date = sanitize_path_string(alpha_data["document_date"])
        classification = sanitize_path_string(alpha_data["document_classification"])
        institution = sanitize_path_string(alpha_data["institution_name"])
        ref_id = sanitize_path_string(alpha_data["primary_reference_id"])
        
        norm_alpha_entity = normalize_entity_name(raw_subject)
        norm_beta_entity = normalize_entity_name(sanitize_path_string(beta_data["primary_subject"]))

        if norm_alpha_entity != norm_beta_entity: raise ValueError("FATAL: Normalized Entity Mismatch.")
        if alpha_data["confidence_score"] < 0.90: raise ValueError("FATAL: Confidence Threshold Failed.")
            
        event_name = build_standardized_event_name(doc_date, raw_subject, norm_alpha_entity, classification, institution, ref_id)
        destination_path = build_deep_geometric_path(alpha_data["recommended_18_lane_id"], norm_alpha_entity, institution, event_name, ".pdf")
        
        move_blob(bucket_name, file_name, "i-dub-thee-processed", destination_path)

    except Exception as e:
        print(f"[QUARANTINE TRIGGERED] {str(e)}")
        clean_filename = file_name.replace("input/", "")
        move_blob(bucket_name, file_name, "i-dub-thee-quarantine", f"{clean_filename}")
EOF_LAYER1_MAIN

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

gcloud functions deploy forensic-pipeline-router \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=process_document \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=i-dub-thee-docs" \
    --service-account="$SERVICE_ACCOUNT" \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_ID=$PROJECT_ID" \
    --timeout=540s \
    --memory=1024MB \
    --quiet
cd ..
echo "[SUCCESS] PART 2 DEPLOYED."
