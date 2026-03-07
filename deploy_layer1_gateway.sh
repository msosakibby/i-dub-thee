#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER DEPLOYMENT: FORENSIC IRON GATE (LAYER 1)"
echo "============================================================================"

mkdir -p layer1_intake
cd layer1_intake

echo "[SYSTEM] 1. Forging Modern Dependencies..."
cat << 'EOF_REQ' > requirements.txt
functions-framework==3.5.0
google-cloud-storage==2.14.0
pydantic==2.6.3
google-genai==0.3.0
EOF_REQ

echo "[SYSTEM] 2. Forging Deterministic Python Application (main.py)..."
cat << 'EOF_PYTHON' > main.py
import os
import json
import hashlib
import math
import functions_framework
from google.cloud import storage
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

# ==============================================================================
# PYDANTIC ROUTING SCHEMA (STAGE 1 DETERMINISM)
# ==============================================================================
class Layer1RoutingSchema(BaseModel):
    document_classification: str = Field(
        description="The strict classification of the document (e.g., 'Bank Statement', 'Contract', 'Invoice')."
    )
    recommended_18_lane_id: str = Field(
        description="The assigned lane from the 18-Lane Taxonomy. Must be formatted as 'Lane_X' (e.g., 'Lane_4'). If unknown or anomaly, output 'Lane_0'."
    )
    confidence_score: float = Field(
        description="The confidence score of this classification from 0.0 to 1.0."
    )

# ==============================================================================
# DETERMINISTIC FORENSIC MATHEMATICS (FRE 901, 902, 707)
# ==============================================================================
def validate_pdf_binary(file_bytes: bytes) -> bool:
    """FR-1.1: Binary Authentication Validation"""
    if not file_bytes.startswith(b'%PDF'):
        raise ValueError("FATAL: Invalid binary header. Missing %PDF magic number.")
    return True

def generate_sha256_hash(payload: bytes) -> str:
    """FR-2.1: Cryptographic Anchoring"""
    return hashlib.sha256(payload).hexdigest()

def calculate_centroid(bounding_box: list[dict]) -> tuple[float, float]:
    """FR-5.1: Bounding Polygon Centroid Mathematics"""
    x_coords = [vertex["x"] for vertex in bounding_box]
    y_coords = [vertex["y"] for vertex in bounding_box]
    centroid_x = sum(x_coords) / len(bounding_box)
    centroid_y = sum(y_coords) / len(bounding_box)
    return (centroid_x, centroid_y)

def find_closest_row(marginalia_centroid: tuple[float, float], row_centroids: dict[str, tuple[float, float]]) -> str:
    """FR-5.2: Euclidean Distance Geometric Binding"""
    closest_row = None
    min_distance = float('inf')
    mx, my = marginalia_centroid

    for row_id, (rx, ry) in row_centroids.items():
        distance = math.sqrt((rx - mx)**2 + (ry - my)**2)
        if distance < min_distance:
            min_distance = distance
            closest_row = row_id

    return closest_row

# ==============================================================================
# CLOUD STORAGE ORCHESTRATION
# ==============================================================================
def move_blob(bucket_name: str, blob_name: str, destination_bucket_name: str):
    """Physically shifts the immutable artifact between architectural vaults."""
    storage_client = storage.Client()
    source_bucket = storage_client.bucket(bucket_name)
    source_blob = source_bucket.blob(blob_name)
    destination_bucket = storage_client.bucket(destination_bucket_name)

    print(f"[STORAGE] Moving {blob_name} to {destination_bucket_name}...")
    source_bucket.copy_blob(source_blob, destination_bucket, blob_name)
    source_blob.delete()
    print(f"[STORAGE] Move complete. Source blob deleted.")

# ==============================================================================
# LAYER 1 INTAKE GATEWAY (CLOUD FUNCTION ENTRYPOINT)
# ==============================================================================
@functions_framework.cloud_event
def process_document(cloud_event):
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]
    
    print(f"\n============================================================================")
    print(f" INITIATING LAYER 1 INTAKE FOR: gs://{bucket_name}/{file_name}")
    print(f"============================================================================")

    # Architectural Boundary Check
    if "input/" not in file_name:
        print("[GATEWAY] File not in input/ prefix. Ignoring event to prevent infinite loops.")
        return

    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    
    try:
        file_bytes = blob.download_as_bytes()
        
        # 1. DETERMINISTIC AUTHENTICATION (FR-1.1 & FR-2.1)
        validate_pdf_binary(file_bytes)
        file_hash = generate_sha256_hash(file_bytes)
        print(f"[AUTH] FRE 901/902 Passed. Cryptographic Hash: {file_hash}")

        # 2. DUAL-LLM CONSENSUS ROUTING
        print("[ROUTER] Initiating Dual-LLM Consensus via Gemini 3.1 Pro Preview...")
        client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="global")
        model_id = "gemini-3.1-pro-preview"
        
        prompt = "Analyze this document and strictly classify it according to the 18-Lane Taxonomy."
        pdf_part = types.Part.from_bytes(data=file_bytes, mime_type='application/pdf')
        
        # Absolute Zero Temperature & Strict Pydantic Schema
        config = types.GenerateContentConfig(
            temperature=0.0,
            response_mime_type="application/json",
            response_schema=Layer1RoutingSchema,
        )

        # Execution Alpha
        print("[ROUTER] Executing Model Alpha...")
        alpha_response = client.models.generate_content(model=model_id, contents=[pdf_part, prompt], config=config)
        alpha_data = json.loads(alpha_response.text)
        
        # Execution Beta
        print("[ROUTER] Executing Model Beta...")
        beta_response = client.models.generate_content(model=model_id, contents=[pdf_part, prompt], config=config)
        beta_data = json.loads(beta_response.text)

        print(f"[CONSENSUS] Alpha: {alpha_data}")
        print(f"[CONSENSUS] Beta:  {beta_data}")

        # 3. FIELD-LEVEL DETERMINISTIC EVALUATION
        if alpha_data["recommended_18_lane_id"] != beta_data["recommended_18_lane_id"]:
            raise ValueError(f"FATAL: Taxonomy Lane Mismatch (A: {alpha_data['recommended_18_lane_id']}, B: {beta_data['recommended_18_lane_id']})")
        
        if alpha_data["document_classification"] != beta_data["document_classification"]:
            raise ValueError(f"FATAL: Classification Mismatch (A: {alpha_data['document_classification']}, B: {beta_data['document_classification']})")

        if alpha_data["confidence_score"] < 0.90 or beta_data["confidence_score"] < 0.90:
            raise ValueError(f"FATAL: Confidence Threshold Failed. (A: {alpha_data['confidence_score']}, B: {beta_data['confidence_score']})")
            
        if alpha_data["recommended_18_lane_id"] == "Lane_0":
             raise ValueError("FATAL: Document routed to Lane 0 (Unclassified / Anomaly).")

        # 4. SUCCESS - ROUTE TO LAYER 2B
        print("[GATEWAY] CONSENSUS ACHIEVED. Routing to Analytical Orchestrator.")
        # Strip the "input/" prefix for the clean processed vault
        clean_filename = file_name.replace("input/", "")
        move_blob(bucket_name, file_name, "i-dub-thee-processed")
        print("[GATEWAY] Execution resolved perfectly.")

    except Exception as e:
        # 5. FAILURE - ROUTE TO QUARANTINE
        print(f"[QUARANTINE TRIGGERED] Error Details: {str(e)}")
        quarantine_filename = file_name.replace("input/", "")
        move_blob(bucket_name, file_name, "i-dub-thee-quarantine")
        print("[QUARANTINE] File successfully isolated.")

EOF_PYTHON

echo "[SYSTEM] 3. Deploying Cloud Function (Layer 1 Intake)..."
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
echo " [DEPLOYMENT COMPLETE] LAYER 1 IRON GATE IS ACTIVE"
echo "============================================================================"
