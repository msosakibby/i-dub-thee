import re

def scan_payload_for_scope_breach(payload: dict) -> bool:
    """
    Scans the finalized JSON dictionary for out-of-scope family intelligence.
    Returns True if contaminated, False if clean.
    """
    payload_string = str(payload)
    
    # Strict list of entities requiring manual review before Fact Base ingestion
    # (?i) makes it case-insensitive. \b ensures word boundaries.
    quarantine_pattern = re.compile(
        r'(?i)\b(Mark Kibby|Mark Sosa-Kibby|Parker|Parker Sosa-Kibby|Cole|Cole Sosa-Kibby|Erik|Erik Sosa-Kibby)\b'
    )
    
    if quarantine_pattern.search(payload_string):
        return True
        
    return False
