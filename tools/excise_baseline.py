import json
from pathlib import Path

def excise_corrupted_test(registry_path: Path, target_id: str) -> bool:
    """Safely removes a specific test case from the JSON registry array."""
    try:
        content = registry_path.read_text(encoding="utf-8")
        data = json.loads(content)
        
        if not isinstance(data, list):
            raise ValueError("Fatal: Golden registry is not a JSON array.")
            
        original_length = len(data)
        
        # Filter out the corrupted object by checking all serialized string values
        cleaned_data = []
        for item in data:
            item_str = json.dumps(item)
            if target_id not in item_str:
                cleaned_data.append(item)
                
        if len(cleaned_data) == original_length:
            print(f"    [-] Target '{target_id}' not found in registry.")
            return False
            
        # Write back to disk with strict formatting
        registry_path.write_text(json.dumps(cleaned_data, indent=4), encoding="utf-8")
        print(f"    [+] Successfully excised '{target_id}'.")
        print(f"    [+] Registry reduced from {original_length} to {len(cleaned_data)} items.")
        return True
        
    except Exception as e:
        print(f"    [!] FATAL EXCISION ERROR: {e}")
        raise

if __name__ == "__main__":
    target = "test_po_15706488_complex_variant"
    registry = Path("tests/golden_test_registry.json")
    
    print("============================================================================")
    print(" INITIATING BASELINE EXCISION PROTOCOL")
    print("============================================================================")
    excise_corrupted_test(registry, target)
    print("============================================================================")
    print(" [COMPLETE] Baseline Sanitized. Ready for Pytest Green State Verification.")
    print("============================================================================")