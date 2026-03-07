import os
import json
import hashlib
import asyncio
import logging
import math
from datetime import datetime, timezone
from decimal import Decimal

from google.cloud import storage, bigquery, documentai
import vertexai
from vertexai.generative_models import GenerativeModel, GenerationConfig, SafetySetting, HarmCategory, HarmBlockThreshold

from schemas import BankingCheckingLane

# --- STRICT LOGGING & ENVIRONMENT SETUP ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger("ForensicOrchestrator")

PROJECT_ID = os.environ.get("PROJECT_ID", "i-dub-thee")
LOCATION = "us-central1"
ENV_MODE = os.environ.get("ENV_MODE", "DEV")

BQ_DATASET = "forensic_fact_base_dev" if ENV_MODE == "DEV" else "forensic_fact_base"
BQ_TABLE = "ingestion_ledger"
ARCHIVE_BUCKET = "i-dub-thee-master-filing-cabinet-dev" if ENV_MODE == "DEV" else "i-dub-thee-master-filing-cabinet"

# --- CLIENT INITIALIZATION ---
storage_client = storage.Client(project=PROJECT_ID)
bq_client = bigquery.Client(project=PROJECT_ID)
docai_client = documentai.DocumentProcessorServiceClient()
vertexai.init(project=PROJECT_ID, location=LOCATION)

# --- THE COGNITIVE LOCK (DLP SYSTEM INSTRUCTION) ---
DLP_SYSTEM_INSTRUCTION = """
You are the Enterprise-Grade Legal Forensics Engine. Your sole directive is Daubert-admissible forensic accounting extraction.
You are evaluating complex, multi-decade marital asset commingling and separate property shielding.

STRICT PROTOCOLS:
1. PARAGRAPH 6 & 8F COMPLIANCE: Scrutinize all transactions for entities specifically including Kibby Company LLC and M & J Food Market.
2. ZERO-OMISSION MANDATE: You must extract every single transaction line item. Truncation is spoliation of evidence.
3. FLAT ARCHITECTURE: You are strictly forbidden from using nested objects ({}) or arrays ([]). The output must be a single-level dictionary.
4. GAAP MATHEMATICS: The extracted opening_balance + total_deposits - total_withdrawals MUST perfectly equal the closing_balance.

If handwriting proximity is provided, append it to the relevant line item description.
"""

# --- GEOSPATIAL PHYSICS (FR-5.1 & FR-5.2) ---
def calculate_centroid(vertices) -> tuple:
    """Calculates the physical center (Cx, Cy) of a bounding polygon."""
    if not vertices:
        return (0.0, 0.0)
    x_sum = sum(v.x for v in vertices)
    y_sum = sum(v.y for v in vertices)
    count = len(vertices)
    return (x_sum / count, y_sum / count)

def execute_euclidean_distance(c1: tuple, c2: tuple) -> float:
    """FR-5.2 Euclidean distance geometric binding logic."""
    return math.sqrt((c2[0] - c1[0])**2 + (c2[1] - c1[1])**2)

async def generate_sha256_hash(binary_data: bytes) -> str:
    """FRE 902: Cryptographic Anchoring at the exact millisecond of ingestion."""
    return hashlib.sha256(binary_data).hexdigest()

# --- LAYER 1 EXECUTION PIPELINE ---
async def execute_forensic_pipeline(source_uri: str):
    """
    The master async orchestrator. Extracts, maps, validates, and routes.
    """
    logger.info(f"Initiating Forensic Pipeline for: {source_uri}")
    
    # 1. Download Binary & Hash (FRE 901/902)
    bucket_name = source_uri.split("/")[2]
    blob_name = "/".join(source_uri.split("/")[3:])
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    
    pdf_bytes = blob.download_as_bytes()
    binary_hex = pdf_bytes[:4].hex().upper()
    file_hash = await generate_sha256_hash(pdf_bytes)
    
    logger.info(f"FRE 902 Anchor Secured. SHA-256: {file_hash}")

    # Note: In a full deployment, Document AI requires a specific Processor ID. 
    # For this orchestrator logic, we simulate the OCR spatial text dump that is fed to Gemini.
    # We pass the spatial reality as a pre-formatted string to the LLM to process.
    ocr_spatial_text = f"DOCUMENT_HASH: {file_hash}\nRAW_TEXT_EXTRACTED_FROM_PDF..."

    # 2. Vertex AI Gemini 2.5 Pro (The Cognitive Soft Gate)
    model = GenerativeModel(
        "gemini-2.5-pro",
        system_instruction=DLP_SYSTEM_INSTRUCTION
    )
    
    # Explicit 8192 Token Ceiling & JSON Enforcement
    generation_config = GenerationConfig(
        temperature=0.0,
        max_output_tokens=8192,
        response_mime_type="application/json",
    )
    
    safety_settings = [
        SafetySetting(category=HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold=HarmBlockThreshold.BLOCK_NONE),
        SafetySetting(category=HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold=HarmBlockThreshold.BLOCK_NONE),
        SafetySetting(category=HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold=HarmBlockThreshold.BLOCK_NONE),
        SafetySetting(category=HarmCategory.HARM_CATEGORY_HARASSMENT, threshold=HarmBlockThreshold.BLOCK_NONE),
    ]

    prompt = f"""
    Extract the financial checking account data from the following OCR text. 
    Enforce all GAAP constraints and Paragraph 6 / 8F entity tracking.
    
    TEXT:
    {ocr_spatial_text}
    """
    
    logger.info("Engaging Gemini 2.5 Pro AI Engine...")
    response = await model.generate_content_async(
        prompt,
        generation_config=generation_config,
        safety_settings=safety_settings
    )
    
    raw_json_string = response.text
    logger.info("Cognitive Extraction Complete. Routing to Pydantic Iron Gate.")

    # 3. Pydantic V2 Iron Gate (Stream A Validation)
    try:
        raw_dict = json.loads(raw_json_string)
        # Inject our immutable cryptographic anchors before validation
        raw_dict["binary_header_hex"] = binary_hex
        raw_dict["original_parent_sha256"] = file_hash
        
        # The violent validation gate
        validated_schema = BankingCheckingLane(**raw_dict)
        final_payload = json.loads(validated_schema.model_dump_json())
        
    except ValidationError as e:
        logger.error(f"IRON GATE REJECTION: Payload failed mathematical validation. {e}")
        raise ValueError(f"Spoliation of Evidence Prevented: {e}")
    except json.JSONDecodeError as e:
        logger.error(f"FATAL: AI returned malformed JSON. {e}")
        raise ValueError("Model hallucinated invalid JSON structure.")

    # 4. BigQuery Ingestion (The Fact Base)
    table_id = f"{PROJECT_ID}.{BQ_DATASET}.{BQ_TABLE}"
    rows_to_insert = [{
        "dossier_id": f"DSR-{file_hash[:8]}",
        "page_hash": file_hash,
        "source_uri": source_uri,
        "extraction_timestamp": datetime.now(timezone.utc).isoformat(),
        "extracted_payload": json.dumps(final_payload) # TR-3.1 Native JSON Insertion
    }]
    
    errors = bq_client.insert_rows_json(table_id, rows_to_insert)
    if errors:
        logger.error(f"BigQuery Insertion Failed: {errors}")
        raise RuntimeError("Failed to append to Immutable Fact Base.")
        
    logger.info(f"Stream A SECURED: Payload mathematically verified and written to {table_id}.")

    # 5. Tri-Pass Artifact Generation (Stream B WORM Archive)
    archive_bucket = storage_client.bucket(ARCHIVE_BUCKET)
    json_blob = archive_bucket.blob(f"json_dumps/{file_hash}.json")
    json_blob.upload_from_string(json.dumps(final_payload, indent=2), content_type="application/json")
    
    logger.info(f"Stream B SECURED: Exhaustive Artifacts written to {ARCHIVE_BUCKET}.")
    return True

