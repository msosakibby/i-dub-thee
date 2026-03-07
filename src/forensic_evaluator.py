import re
import json

class RulesEngine:
    def __init__(self):
        # We simulate the loaded rules registry
        self.rules = {
            "PARAGRAPH_8F_M_AND_J": ["M & J Food Market", "M&J Food"],
            "PARAGRAPH_8F_KIBBY": ["Kibby Company LLC"]
        }

    def evaluate(self, dossier_id, payload):
        outcomes = []
        
        for rule_id, keywords in self.rules.items():
            for key, value in payload.items():
                if not isinstance(value, str):
                    continue
                
                # Check for keyword matches
                if any(keyword.lower() in value.lower() for keyword in keywords):
                    
                    # PREFIX-AWARE CONTEXT BINDING
                    # Attempt to group related line-item data (e.g., amount, date)
                    context_evidence = {}
                    prefix_match = re.match(r'^(activity_line_\d+)_', key)
                    
                    if prefix_match:
                        prefix = prefix_match.group(1)
                        # Gather all sibling keys that share this line prefix
                        for k, v in payload.items():
                            if k.startswith(prefix):
                                context_evidence[k] = v
                    else:
                        # Fallback if no prefix is found
                        context_evidence[key] = value

                    outcomes.append({
                        "outcome_id": f"{dossier_id}-{rule_id}",
                        "dossier_id": dossier_id,
                        "rule_id": rule_id,
                        "violation_detected": True,
                        "matched_evidence": json.dumps(context_evidence) # Store the FULL row context
                    })
                    break # Move to next rule once flagged for this payload
        return outcomes
