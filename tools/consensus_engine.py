import copy

class ConsensusFractureError(Exception):
    pass

def evaluate_consensus(payload_alpha: dict, payload_beta: dict) -> dict:
    """
    Evaluates dual-model extraction for deterministic semantic equality.
    Survives key ordering and safe float/integer variations implicitly handled by Python dict equality.
    """
    alpha_copy = copy.deepcopy(payload_alpha)
    beta_copy = copy.deepcopy(payload_beta)
    
    if alpha_copy != beta_copy:
        raise ConsensusFractureError("FATAL: Semantic mismatch between Alpha and Beta extractions.")
    
    return alpha_copy
