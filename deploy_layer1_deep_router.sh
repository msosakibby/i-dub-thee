#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: LAYER 1 DEEP TAXONOMY ROUTER"
echo "============================================================================"

mkdir -p layer1_intake
cd layer1_intake

cat << 'EOF_PYTHON' > main.py
import os
import json
import hashlib
import re
import functions_framework
from google.cloud import storage
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

# ==============================================================================
# MASTER ENTITY REGISTRY
# ==============================================================================
ENTITY_ALIAS_MAP = {
  "Judith Grandy": ["A GRANDY", "JA GRANDY", "JOYCE A GRANDY", "JUDITH A GRANDY", "JUDITH A GRANDY TTEE", "JUDITH A KIBBY", "JUDITH ANN GRANDY", "JUDITH GRANDY", "JUDITH KIBBY", "JUDITH KLHHY", "JUDITHA GRANDY", "JUDITHANN GRANDY", "JUDY GRANDY", "JUDY KIBBY", "JUDITH A KIBBY GRANDY", "JUDY", "MRS JUDITH A GRANDY"],
  "Keith Grandy": ["GRANDY KEITH ARTHUR", "GRANDY KIETH", "K GRANDY", "KEITH A GRANDY", "KEITH ARTHUR GRANDY", "KEITH GRANDY", "KATH GRANELY"],
  "Mark Sosa-Kibby": ["M SOSA-KIBBY", "MARK SOSA-KIBBY", "MARK SOSAKIBBY", "MARK W KIBBY", "MARK W SOSA-KIBBY", "MARK KIBBY", "SOSA-KIBBY MARK", "SOSA-KIBBY MARK W"],
  "KibbyCo": ["KIBBY CO", "KIBBY COMPANY", "KIBBY COMPANY LLC"],
  "K Grandy Enterprises": ["K GRANDY ENTERPRISES LLC"],
  "Max R Kibby Trust": ["MAX R KIBBY"],
  "Mike Kibby": ["MIKE KIBBY"],
  "Emily Ida Kibby Trust": ["EMILY IDA KIBBY ADMINISTRATION TRUST"],
  "Cecil F Munn": ["CECIL F MUNN"],
  "Fred Prielipp": ["FRED PRIELIPP"],
  "Jim Weston": ["JIM WESTON"],
  "Guadalupe Alexander Kibby": ["GUADALUPE ALEXANDER KIBBY"],
  "Family Fare LLC": ["FAMILY FARE LLC"],
  "UNKNOWN": ["R GRANAY", "STOCKHOLDERS"]
}

def normalize_entity_name(raw_name: str) -> str:
    upper_name = raw_name.upper().strip()
    for canonical, aliases in ENTITY_ALIAS_MAP.items():
        if upper_name in aliases:
            return canonical
    return raw_name.strip()

# ==============================================================================
# DEEP ROUTING ALGEBRA
# ==============================================================================
def sanitize_path_string(text: str) -> str:
    """Neutralizes illegal file system characters."""
    return re.sub(r'[\\/:*?"<>|]', '_', text).strip()

def build_standardized_event_name(doc_date: str, primary_subject: str, entity: str, classification: str, institution: str, ref_id: str) -> str:
    """Constructs the exact 6-part standardized event string."""
    base = f"{doc_date} - {primary_subject} - {entity} - {classification} - {institution}"
    if ref_id.upper() != "NONE":
        return f"{base} - {ref_id}"
    return base

def build_deep_geometric_path(lane: str, entity: str, institution: str, event_name: str, extension: str) -> str:
    """Constructs the absolute GCS path for the physical file move."""
    return f"{lane}/{entity}/{institution}/{event_name}/{event_name}{extension}"

# ==============================================================================
# PYDANTIC DEEP ROUTING SCHEMA
# ==============================================================================
class Layer1RoutingSchema(BaseModel):
    document_date: str = Field(description="The primary date of the document, formatted exactly as YYYY-MM-DD. If unknown, use 1900-01-01.")
    primary_subject: str = Field(description="The exact individual or business entity name as literally printed on the document.")
    document_classification: str = Field(description="The specific classification (e.g., 'Bank Statement', 'Utility Bill', 'Warranty Deed').")
    institution_name: str = Field(description="The issuing authority, vendor, or bank (e.g., 'Horizon Bank', 'Great Lakes Energy').")
    primary_reference_id: str = Field(description="The polymorphic ID. For accounts/cards, extract ONLY the last 4 digits. For invoices/meters/VINs, extract the full number. If no ID exists, output exactly 'NONE'.")
    recommended_18_lane_id: str = Field(description="The taxonomy lane, strictly formatted as 'LANE_XX_NAME' (e.g., 'LANE_04_BANKING'). If unknown, output 'LANE_99_UNKNOWN'.")
    confidence_score: float = Field(description="The confidence score of this extraction from 0.0 to 1.0.")

# ==============================================================================
# DETERMINISTIC AUTHENTICATION
# ==============================================================================
def validate_pdf_binary(file_bytes: bytes) -> bool:
    if not file_bytes.startswith(b'%PDF'):
        raise ValueError("FATAL: Invalid binary header. Missing %PDF magic number.")
    return True

def generate_sha256_hash(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()

def move_blob(bucket_name: str, source_blob_name: str, destination_bucket_name: str, destination_blob_name: str):
    storage_client = storage.Client()
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(source_blob_name)
    destination_bucket = storage_client.bucket(destination_bucket_name)

    print(f"[STORAGE] Moving to gs://{destination_bucket_name}/{destination_blob_name}")
    source_bucket.copy_blob(source_blob, destination_bucket, destination_blob_name)
    source_blob.delete()

# ==============================================================================
# LAYER 1 ENTRYPOINT
# ==============================================================================
@functions_framework.cloud_event
def process_document(cloud_event):
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]

    if "input/" not in file_name:
        return

    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    
    try:
        file_bytes = blob.download_as_bytes()
        validate_pdf_binary(file_bytes)
        
        client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="us-central1")
        model_id = "gemini-2.5-pro"
        prompt = "Extract the routing geometry variables from this document to satisfy the strict schema parameters."
        pdf_part = types.Part.from_bytes(data=file_bytes, mime_type='application/pdf')
        config = types.GenerateContentConfig(temperature=0.0, response_mime_type="application/json", response_schema=Layer1RoutingSchema)

        # Execution Alpha
        alpha_res = client.models.generate_content(model=model_id, contents=[pdf_part, prompt], config=config)
        alpha_data = json.loads(alpha_res.text)
        
        # Execution Beta
        beta_res = client.models.generate_content(model=model_id, contents=[pdf_part, prompt], config=config)
        beta_data = json.loads(beta_res.text)

        # Sanitization & Normalization
        doc_date = sanitize_path_string(alpha_data["document_date"])
        primary_subject = sanitize_path_string(alpha_data["primary_subject"])
        classification = sanitize_path_string(alpha_data["document_classification"])
        institution = sanitize_path_string(alpha_data["institution_name"])
        ref_id = sanitize_path_string(alpha_data["primary_reference_id"])
        
        norm_alpha_entity = normalize_entity_name(primary_subject)
        norm_beta_entity = normalize_entity_name(sanitize_path_string(beta_data["primary_subject"]))

        # Deep Consensus Checks
        if norm_alpha_entity != norm_beta_entity:
            raise ValueError("FATAL: Normalized Entity Mismatch.")
        if alpha_data["recommended_18_lane_id"] != beta_data["recommended_18_lane_id"]:
            raise ValueError("FATAL: Taxonomy Lane Mismatch.")
        if alpha_data["confidence_score"] < 0.90 or beta_data["confidence_score"] < 0.90:
            raise ValueError("FATAL: Confidence Threshold Failed.")
            
        # Path Algebra
        event_name = build_standardized_event_name(doc_date, primary_subject, norm_alpha_entity, classification, institution, ref_id)
        destination_path = build_deep_geometric_path(alpha_data["recommended_18_lane_id"], norm_alpha_entity, institution, event_name, ".pdf")
        
        print(f"[GATEWAY] CONSENSUS ACHIEVED. Deep Routing to {destination_path}")
        move_blob(bucket_name, file_name, "i-dub-thee-processed", destination_path)

    except Exception as e:
        print(f"[QUARANTINE TRIGGERED] {str(e)}")
        clean_filename = file_name.replace("input/", "")
        move_blob(bucket_name, file_name, "i-dub-thee-quarantine", f"{clean_filename}")

EOF_PYTHON

echo "[SYSTEM] Deploying Cloud Function (Layer 1 Deep Router)..."
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
echo "============================================================================"
echo " [DEPLOYMENT COMPLETE] LAYER 1 6-PART GEOMETRY ROUTER IS ACTIVE"
echo "============================================================================"
