import os, json, re, functions_framework
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

REJECT_PATTERN = re.compile(r'(?i)\b(Mark Kibby|Mark Sosa-Kibby|Mark William Sosa|Mark Willliam Sosa|Mark W Kibby|Parker Sosa-Kibby|Cole Sosa-Kibby|Erik Sosa-Kibby|Parker|Cole|Erik)\b')

def normalize_entity_name(raw_name):
    upper_name = raw_name.upper().strip()
    for canonical, aliases in ENTITY_ALIAS_MAP.items():
        if upper_name in aliases: return canonical
    return raw_name.strip()

def sanitize_path(text): return re.sub(r'[\\/:*?"<>|]', '_', text).strip()

class Layer1RoutingSchema(BaseModel):
    document_date: str = Field(description="YYYY-MM-DD. If unknown, use 1900-01-01.")
    primary_subject: str = Field(description="Exact individual or business entity name.")
    document_classification: str = Field(description="e.g., 'Bank Statement', 'Utility Bill'.")
    institution_name: str = Field(description="e.g., 'Horizon Bank', 'Great Lakes Energy'.")
    primary_reference_id: str = Field(description="Last 4 digits of account, or full invoice number. Or 'NONE'.")
    recommended_18_lane_id: str = Field(description="e.g., 'LANE_04_BANKING'. If unknown, 'LANE_99_UNKNOWN'.")
    confidence_score: float = Field(description="Confidence from 0.0 to 1.0.")

def move_blob(bucket, source, dest_bucket, dest_name):
    sc = storage.Client()
    sb = sc.bucket(bucket)
    sc.bucket(dest_bucket).copy_blob(sb.blob(source), sc.bucket(dest_bucket), dest_name)
    sb.blob(source).delete()

@functions_framework.cloud_event
def process_document(cloud_event):
    data = cloud_event.data
    if "input/" not in data["name"]: return
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT_ID", "i-dub-thee")
    blob = storage.Client().bucket(data["bucket"]).blob(data["name"])
    try:
        file_bytes = blob.download_as_bytes()
        if not file_bytes.startswith(b'%PDF'): raise ValueError("Invalid PDF.")
        
        client = genai.Client(http_options={'api_version': 'v1beta1'}, vertexai=True, project=project_id, location="us-central1")
        pdf_part = types.Part.from_bytes(data=file_bytes, mime_type='application/pdf')
        config = types.GenerateContentConfig(temperature=0.0, response_mime_type="application/json", response_schema=Layer1RoutingSchema)
        
        res = client.models.generate_content(model="gemini-2.5-pro", contents=[pdf_part, "Extract routing variables."], config=config)
        res_data = json.loads(res.text)

        raw_sub = sanitize_path(res_data["primary_subject"])
        if REJECT_PATTERN.search(raw_sub): raise ValueError(f"FIREWALL_TRIGGERED: '{raw_sub}' is restricted.")
        if res_data["confidence_score"] < 0.90: raise ValueError("Low Confidence.")
            
        norm_ent = normalize_entity_name(raw_sub)
        evt_name = f"{sanitize_path(res_data['document_date'])} - {raw_sub} - {norm_ent} - {sanitize_path(res_data['document_classification'])} - {sanitize_path(res_data['institution_name'])}"
        ref_id = sanitize_path(res_data['primary_reference_id'])
        if ref_id.upper() != "NONE": evt_name += f" - {ref_id}"
        
        dest_path = f"{res_data['recommended_18_lane_id']}/{norm_ent}/{sanitize_path(res_data['institution_name'])}/{evt_name}/{evt_name}.pdf"
        move_blob(data["bucket"], data["name"], "i-dub-thee-staging-processed", dest_path)
    except Exception as e:
        print(f"[QUARANTINE] {str(e)}")
        move_blob(data["bucket"], data["name"], "i-dub-thee-staging-quarantine", data["name"].replace("input/", ""))
