import json

def resolve_financial_entity(raw_institution: str, raw_account_string: str = None) -> str:
    """
    Simulates the BigQuery JOIN logic for Entity Resolution.
    In the live cloud environment, this is handled natively via SQL against account_alias_registry.
    """
    # Hardcoded local dictionary mimicking the exact rows inserted into BigQuery
    registry = {
        ("Chemical Bank", "4797"): "JOINT_CHECKING_MAIN",
        ("Huntington Bank", "4797"): "JOINT_CHECKING_MAIN",
        ("K-J Wildlife", None): "KEITH_SEPARATE_BUSINESS",
        ("KG Fishing", "2268"): "KEITH_SEPARATE_BUSINESS",
        ("Kibby Company L.L.C.", None): "JUDY_SEPARATE_BUSINESS"
    }
    
    # 1. Attempt Exact Match (Institution + Account String)
    exact_key = (raw_institution, raw_account_string)
    if exact_key in registry:
        return registry[exact_key]
        
    # 2. Attempt Partial Match (Institution Only - useful for corporate entities without specific accounts)
    partial_key = (raw_institution, None)
    if partial_key in registry:
        return registry[partial_key]
        
    # 3. Fallback Degradation
    return "UNRESOLVED_ENTITY"
