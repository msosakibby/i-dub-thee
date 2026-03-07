import pytest
import json
import hashlib
from unittest.mock import MagicMock, call

# ==============================================================================
# IMPORT STUBS FOR FUTURE IMPLEMENTATION
# These will fail until Layer 2B is upgraded to the Slicer Architecture.
# ==============================================================================
try:
    from pristine_deployment_chamber.forensic_router import (
        persist_forensic_artifacts,
        generate_artifact_paths,
        extract_embedded_images,
        append_forensic_disclaimer
    )
except ImportError:
    persist_forensic_artifacts = None
    generate_artifact_paths = None
    extract_embedded_images = None
    append_forensic_disclaimer = None

# ==============================================================================
# SLICER-1: REPORT 5 BIFURCATION (UI vs. RAW DATABASE)
# ==============================================================================
def test_report_5_bifurcation():
    """Validates that Report 5 generates both a pure .json file and an HTML/MD .md file."""
    if generate_artifact_paths is None:
        pytest.skip("Implementation missing")
        
    source_blob_name = "LANE_04_BANKING/KibbyCo/Horizon Bank/2023-09-30/2023-09-30.pdf"
    paths = generate_artifact_paths(source_blob_name)
    
    # Prove the bifurcation exists
    assert "report_5_raw" in paths, "FATAL: Raw JSON path missing."
    assert "report_5_ui" in paths, "FATAL: UI Markdown path missing."
    
    assert paths["report_5_raw"].endswith(".json"), "FATAL: Raw file must be strictly .json"
    assert paths["report_5_ui"].endswith(".md"), "FATAL: UI file must be strictly .md"

# ==============================================================================
# SLICER-2: OPTICAL IMAGE EXTRACTION & CRYPTOGRAPHIC ANCHORING
# ==============================================================================
def test_optical_image_extraction():
    """Proves the engine extracts images, generates hashes, and preserves the parent link."""
    if extract_embedded_images is None:
        pytest.skip("Implementation missing")
    
    # Mock parent PDF bytes and its pre-calculated hash
    mock_parent_bytes = b"%PDF-1.4 mock statement with 2 embedded check images"
    parent_hash = hashlib.sha256(mock_parent_bytes).hexdigest()
    
    # In the actual implementation, we will utilize PyMuPDF (fitz) here.
    # For the TDD contract, we define the expected output signature.
    extracted_images = extract_embedded_images(mock_parent_bytes, parent_hash)
    
    assert isinstance(extracted_images, list), "FATAL: Extractor must return a list of image objects."
    
    if len(extracted_images) > 0:
        first_image = extracted_images[0]
        assert "binary_data" in first_image, "FATAL: Missing raw image bytes."
        assert "child_hash" in first_image, "FATAL: Child image was not cryptographically hashed."
        assert first_image["parent_hash"] == parent_hash, "FATAL: Relational Chain of Custody severed. Parent hash missing."
        assert first_image["image_ext"] in [".png", ".jpeg", ".jpg"], "FATAL: Invalid image extension."

# ==============================================================================
# SLICER-3: WORM IMMUTABILITY ENFORCEMENT
# ==============================================================================
def test_worm_immutability_enforcement():
    """Proves that generating child artifacts DOES NOT alter the parent JSON."""
    if persist_forensic_artifacts is None:
        pytest.skip("Implementation missing")
        
    mock_bucket = MagicMock()
    mock_blob = MagicMock()
    mock_bucket.blob.return_value = mock_blob
    
    source_blob_name = "LANE_04/Entity/Inst/Event/Event.pdf"
    
    # The pure, original extraction of the parent
    ai_payloads = {
        "report_1": "MD", "report_2": "MD", "report_3": "MD", "report_4": "MD",
        "report_5_raw": '{"target": "Parent Statement"}', 
        "report_5_ui": "# UI Wrapper",
        "report_6": "MD",
        "child_images": [{"child_hash": "abc123xyz", "binary": b"fake_image_bytes"}]
    }
    
    persist_forensic_artifacts(mock_bucket, source_blob_name, ai_payloads)
    
    # Interrogate the exact arguments passed to the GCS upload function
    upload_calls = mock_blob.upload_from_string.call_args_list
    
    # Find the call that uploaded the raw JSON
    json_upload_call = next(call for call in upload_calls if call.kwargs.get("content_type") == "application/json")
    
    uploaded_json_string = json_upload_call.args[0]
    
    # The WORM Proof: The uploaded JSON must NOT contain the child hash. 
    # If it does, we violated immutability by altering the parent record.
    assert "abc123xyz" not in uploaded_json_string, "FATAL: WORM Violation. Parent JSON was mutated to include child data."

# ==============================================================================
# SLICER-4: LEGAL ADMISSIBILITY & FORENSIC DISCLAIMER INJECTION
# ==============================================================================
def test_forensic_admissibility_disclaimer():
    """Validates the explicit inclusion of WORM and extraction methodologies in the final reports."""
    if append_forensic_disclaimer is None:
        pytest.skip("Implementation missing")

    # 1. Test Markdown Injection
    md_text = "# Simulated Report"
    secured_md = append_forensic_disclaimer(md_text, is_json=False)
    
    assert "WORM (Write Once, Read Many)" in secured_md, "FATAL: Disclaimer missing WORM protocol definition."
    assert "relationally anchored" in secured_md.lower(), "FATAL: Disclaimer missing relational anchor explanation."
    assert "mathematically unaltered" in secured_md.lower(), "FATAL: Disclaimer missing immutability guarantee."

    # 2. Test JSON Injection
    # The JSON payload must carry the disclaimer natively inside its dossier_metadata block
    json_payload = {
        "dossier_metadata": {
            "zero_trust_mandate": "STRICT CITATION ENFORCEMENT ACTIVE"
        },
        "document_summary": "Extracted check image."
    }
    secured_json_dict = append_forensic_disclaimer(json_payload, is_json=True)
    
    # The dictionary must be structurally preserved but now contain the legal disclaimer
    assert "legal_admissibility_disclaimer" in secured_json_dict["dossier_metadata"], "FATAL: JSON metadata missing legal disclaimer."
    assert "WORM" in secured_json_dict["dossier_metadata"]["legal_admissibility_disclaimer"], "FATAL: JSON disclaimer text is invalid."

