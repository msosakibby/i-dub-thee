import os
import re
import time
import subprocess
from pathlib import Path
from google.cloud import storage
import concurrent.futures

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
BUCKET_NAME = "i-dub-thee-docs"
PREFIX = "_QUARANTINE/"
LOCAL_PDF_DIR = Path("staging/legacy_intel/_QUARANTINE")
LOCAL_PDF_DIR.mkdir(parents=True, exist_ok=True)

storage_client = storage.Client(project=PROJECT_ID)
bucket = storage_client.bucket(BUCKET_NAME)

print("============================================================================")
print(" INITIATING V8 THREADED SCHEMA SWEEP (MAX_WORKERS=3)")
print("============================================================================")

blobs = list(bucket.list_blobs(prefix=PREFIX))
variant_buckets = {}

# 1. Intelligent Clustering
for blob in blobs:
    if not blob.name.lower().endswith('.pdf'):
        continue
    filename = blob.name.split('/')[-1]
    clean_name = re.sub(r'^\d{4}-\d{2}-\d{2}\s*-\s*', '', filename)
    clean_name = re.sub(r'(_Original)?\.pdf$', '', clean_name, flags=re.IGNORECASE)
    signature = clean_name.strip() or "UNKNOWN_VARIANT"
    variant_buckets.setdefault(signature, []).append(blob)

print(f"[SYSTEM] Clustered into {len(variant_buckets)} unique document classes.")

MAX_FILE_SIZE_MB = 6
MAX_CONCURRENT_THREADS = 3

def process_variant(variant, blob_list):
    print(f"\n[+] THREAD START: {variant} (Population: {len(blob_list)})")
    
    valid_blobs = [b for b in blob_list if b.size < (MAX_FILE_SIZE_MB * 1024 * 1024)]
    if not valid_blobs:
        return f"[-] SKIPPED {variant}: All files exceed size limits."
        
    valid_blobs.sort(key=lambda x: x.size)
    sampled_blobs = valid_blobs if len(valid_blobs) <= 3 else [valid_blobs[0], valid_blobs[len(valid_blobs)//2], valid_blobs[-1]]
        
    local_paths = []
    # Use a thread-safe prefix to prevent file collision on disk
    thread_safe_prefix = "".join([c if c.isalnum() else "" for c in variant])[:10]
    
    try:
        for i, sb in enumerate(sampled_blobs):
            safe_name = f"t_{thread_safe_prefix}_{i}_{sb.name.split('/')[-1].replace(' ', '_')}"
            local_path = LOCAL_PDF_DIR / safe_name
            sb.download_to_filename(local_path)
            local_paths.append(str(local_path))
            
        if local_paths:
            subprocess.run(
                ["python3", "tools/schema_architect.py", "--variant", variant, "--pdfs"] + local_paths, 
                check=False
            )
            # Shortened rate limit for threaded environment
            time.sleep(5)
            return f"[+] SUCCESS {variant}"
            
    except Exception as e:
        return f"[!] FAILED {variant}: {str(e)}"
        
    finally:
        for path in local_paths:
            if os.path.exists(path):
                os.remove(path)

# 2. Bounded Multi-Threaded Execution
with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_CONCURRENT_THREADS) as executor:
    futures = {executor.submit(process_variant, var, blobs): var for var, blobs in variant_buckets.items()}
    for future in concurrent.futures.as_completed(futures):
        result = future.result()
        print(result)

print("============================================================================")
print(" [SUCCESS] Threaded sweep complete. Check staging/proposed_schemas/")
print("============================================================================")
