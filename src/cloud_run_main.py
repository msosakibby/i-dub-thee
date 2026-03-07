import os
import re
import time
from google.cloud import storage
from google import genai
from google.genai import types

def execute_sweep(project_id: str):
    input_bucket_name = "i-dub-thee-docs"
    output_bucket_name = "i-dub-thee-forensic-vault"
    in_prefix = "_QUARANTINE/"
    out_prefix = "proposed_schemas/"
    
    storage_client = storage.Client(project=project_id)
    input_bucket = storage_client.bucket(input_bucket_name)
    output_bucket = storage_client.bucket(output_bucket_name)
    
    print("[SYSTEM] Executing Input Sweep...")
    # TDD GATE 1a: Input Sweep occurs first to satisfy test mock sequence
    in_blobs = list(input_bucket.list_blobs(prefix=in_prefix))
    
    print("[SYSTEM] Executing State Verification (Deduplication)...")
    # TDD GATE 1b: Output Sweep
    out_blobs = list(output_bucket.list_blobs(prefix=out_prefix))
    
    processed_variants = set()
    for ob in out_blobs:
        match = re.search(r'PROPOSAL_(.*?)\.md', ob.name)
        if match:
            processed_variants.add(match.group(1))
            
    print("[SYSTEM] Clustering temporal variants...")
    variant_buckets = {}
    for blob in in_blobs:
        if not blob.name.lower().endswith('.pdf'):
            continue
            
        filename = blob.name.split('/')[-1]
        clean_name = re.sub(r'^\d{4}-\d{2}-\d{2}\s*-\s*', '', filename)
        clean_name = re.sub(r'(_Original)?\.pdf$', '', clean_name, flags=re.IGNORECASE)
        signature = clean_name.strip()
        if not signature:
            signature = "UNKNOWN_VARIANT"
            
        safe_signature = "".join([c if c.isalnum() else "_" for c in signature])
        variant_buckets.setdefault(safe_signature, []).append(blob)
        
    print(f"[SYSTEM] Discovered {len(variant_buckets)} unique document classes. Engaging processing loop.")
    genai_client = genai.Client(vertexai=True, project=project_id, location="us-central1")
    
    for variant, blobs in variant_buckets.items():
        # TDD GATE 1: Deduplication
        if variant in processed_variants:
            print(f"[CACHE HIT] Variant already architected. Skipping {variant}.")
            continue
            
        print(f"\n[+] ARCHITECTING: {variant} (Population: {len(blobs)})")
        valid_blobs = [b for b in blobs if b.size < (6 * 1024 * 1024)]
        if not valid_blobs:
            print(f"[-] SKIPPED {variant}: All files exceed 6MB payload limits.")
            continue
            
        # TDD GATE 2: Stratified Sampling
        valid_blobs.sort(key=lambda x: x.size)
        if len(valid_blobs) <= 3:
            sampled_blobs = valid_blobs
        else:
            sampled_blobs = [valid_blobs[0], valid_blobs[len(valid_blobs)//2], valid_blobs[-1]]
            
        contents = []
        for b in sampled_blobs:
            try:
                # TDD GATE 3: Zero-Disk Streaming
                print(f"    -> In-Memory Streaming: {b.name.split('/')[-1]} ({b.size} bytes)")
                pdf_bytes = b.download_as_bytes()
                contents.append(types.Part.from_bytes(data=pdf_bytes, mime_type="application/pdf"))
            except Exception as e:
                print(f"    [!] Failed to stream bytes: {e}")
                
        if not contents:
            continue
            
        prompt = f"""
        You are an expert forensic data architect operating under a Zero-Trust mandate.
        I have provided you with {len(sampled_blobs)} distinct documents. These represent years of structural design drift for a single document class: '{variant}'.
        
        DIRECTIVE:
        Create a highly resilient Pydantic V2 schema that accommodates the structural realities of ALL provided documents.
        If a field exists in a newer layout but not an older one, type it as `Optional`.
        
        MANDATORY OUTPUT (Exactly Two Markdown Blocks):
        
        BLOCK 1 (Python Pydantic V2):
        Write the `pydantic` classes required to extract this data.
        - You MUST use `model_config = ConfigDict(extra='forbid')`.
        - You MUST include an `@model_validator(mode='after')` that executes double-entry GAAP mathematical checksums (if financial numbers exist).
        - You MUST use the system's baseline `ForensicDataEntity` class.
        
        BLOCK 2 (JSON Test Registry):
        Write a JSON array containing EXACTLY ONE test case for `tests/golden_test_registry.json` that represents the most complex structural variant you identified.
        - It must include "test_identifier", "should_pass": true, "taxonomy_lane": "[YourSchemaName]", "binary_header_simulation": "25504446", and a "payload" that perfectly passes your math validator.
        """
        contents.append(prompt)
        
        try:
            response = genai_client.models.generate_content(
                model="gemini-2.5-pro",
                contents=contents,
                config=types.GenerateContentConfig(temperature=0.0)
            )
            
            out_blob_name = f"{out_prefix}PROPOSAL_{variant}.md"
            out_blob = output_bucket.blob(out_blob_name)
            # ZERO DISK WRITE: Stream text directly into Google Cloud Storage memory
            out_blob.upload_from_string(response.text, content_type="text/markdown")
            
            print(f"[SUCCESS] Uploaded {out_blob_name} to Vault. Cooling down 15s...")
            time.sleep(15)
        except Exception as e:
            print(f"[FATAL] API Error for {variant}: {e}")

if __name__ == "__main__":
    execute_sweep(os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee"))
