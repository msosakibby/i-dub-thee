import functions_framework
import os
import json
import re
from google.cloud import storage
import vertexai
from vertexai.generative_models import GenerativeModel, Part

PROJECT_ID = os.environ.get("GCP_PROJECT", "i-dub-thee")
PROCESSED_BUCKET = os.environ.get("PROCESSED_BUCKET", f"{PROJECT_ID}-processed")
QUARANTINE_BUCKET = os.environ.get("QUARANTINE_BUCKET", f"{PROJECT_ID}-quarantine")

storage_client = storage.Client(project=PROJECT_ID)
vertexai.init(project=PROJECT_ID, location="us-central1")
model = GenerativeModel("gemini-2.5-pro")

def sanitize_path_string(text: str) -> str:
    if not text: return "UNKNOWN"
    return re.sub(r'[\\/:*?"<>|]', '_', str(text)).strip()

def build_standardized_event_name(doc_date: str, primary_subject: str, entity: str, classification: str, institution: str, ref_id: str) -> str:
    base = f"{doc_date} - {primary_subject} - {entity} - {classification} - {institution}"
    if ref_id.upper() != "NONE" and ref_id:
        return f"{base} - {ref_id}"
    return base

def build_deep_geometric_path(lane: str, entity: str, institution: str, event_name: str) -> str:
    return f"{sanitize_path_string(lane)}/{sanitize_path_string(entity)}/{sanitize_path_string(institution)}/{sanitize_path_string(event_name)}/{sanitize_path_string(event_name)}.pdf"

@functions_framework.cloud_event
def process_intake(cloud_event):
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]
    
    intake_bucket = storage_client.bucket(bucket_name)
    intake_blob = intake_bucket.blob(file_name)
    temp_path = f"/tmp/{file_name.replace('/', '_')}"
    intake_blob.download_to_filename(temp_path)
    document_part = Part.from_uri(f"gs://{bucket_name}/{file_name}", mime_type="application/pdf")
    
    prompt = """
    Analyze this document and extract the exact routing variables. Output strictly as JSON:
    - document_date (YYYY-MM-DD)
    - primary_subject (Raw name on document)
    - normalized_entity (Canonical name)
    - document_classification
    - institution_name
    - primary_reference_id (or "NONE")
    - recommended_18_lane_id
    """
    
    try:
        response = model.generate_content([document_part, prompt])
        routing_data = json.loads(response.text.replace("```json", "").replace("```", "").strip())
        
        event_name = build_standardized_event_name(
            sanitize_path_string(routing_data.get("document_date", "UNKNOWN")),
            sanitize_path_string(routing_data.get("primary_subject", "UNKNOWN")),
            sanitize_path_string(routing_data.get("normalized_entity", "UNKNOWN")),
            sanitize_path_string(routing_data.get("document_classification", "UNKNOWN")),
            sanitize_path_string(routing_data.get("institution_name", "UNKNOWN")),
            sanitize_path_string(routing_data.get("primary_reference_id", "NONE"))
        )
        
        deep_path = build_deep_geometric_path(
            routing_data.get("recommended_18_lane_id", "UNKNOWN_LANE"),
            routing_data.get("normalized_entity", "UNKNOWN"),
            routing_data.get("institution_name", "UNKNOWN"),
            event_name
        )
        
        processed_bucket = storage_client.bucket(PROCESSED_BUCKET)
        new_blob = processed_bucket.blob(deep_path)
        new_blob.upload_from_filename(temp_path)
        intake_blob.delete()
        print(f"[SUCCESS] Vaulted to: {deep_path}")
        
    except Exception as e:
        print(f"[FATAL] Routing to Quarantine: {e}")
        quarantine_bucket = storage_client.bucket(QUARANTINE_BUCKET)
        quarantine_bucket.blob(f"failed_intake/{file_name}").upload_from_filename(temp_path)
        intake_blob.delete()
    finally:
        if os.path.exists(temp_path): os.remove(temp_path)
