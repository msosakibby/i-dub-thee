import pytest
import json
from decimal import Decimal, InvalidOperation
from pydantic import BaseModel, Field, field_validator, model_validator, ValidationError, ConfigDict

# --- PYDANTIC V2 IRON GATE DEFINITION ---
class BankingCheckingLane(BaseModel):
    model_config = ConfigDict(extra='allow', strict=True) 
    
    # 1. FRE 901/902 Anchors
    binary_header_hex: str = Field(...)
    original_parent_sha256: str = Field(..., min_length=64, max_length=64)
    
    # 2. GAAP Math Anchors
    opening_balance: Decimal = Field(...)
    total_deposits: Decimal = Field(...)
    total_withdrawals: Decimal = Field(...)
    closing_balance: Decimal = Field(...)

    @field_validator('opening_balance', 'total_deposits', 'total_withdrawals', 'closing_balance', mode='before')
    @classmethod
    def coerce_string_to_decimal(cls, v):
        """Intercepts the raw string from the AI and legally casts it to a Decimal."""
        if isinstance(v, str):
            try:
                # Remove any stray dollar signs or commas the AI might have hallucinated
                clean_v = v.replace('$', '').replace(',', '').strip()
                return Decimal(clean_v)
            except InvalidOperation:
                raise ValueError(f"FRE 1006 VIOLATION: Cannot coerce extracted value '{v}' to a valid number.")
        return v

    @field_validator('binary_header_hex')
    @classmethod
    def validate_pdf_magic_number(cls, v: str) -> str:
        if v.upper() != "25504446":
            raise ValueError(f"FRE 901 VIOLATION: Invalid binary signature detected ({v}).")
        return v.upper()

    @model_validator(mode='after')
    def verify_forensic_integrity(self):
        # A. GAAP Double-Entry Checksum
        calculated_closing = self.opening_balance + self.total_deposits - self.total_withdrawals
        if self.closing_balance != calculated_closing:
            raise ValueError(
                f"FRE 1006 VIOLATION: Calculated Closing Balance ({calculated_closing}) "
                f"does not match Extracted Closing Balance ({self.closing_balance})."
            )
            
        # B. 10000% Flatness Guarantee
        for key, value in self.model_dump().items():
            if isinstance(value, (dict, list)):
                raise ValueError(
                    f"FATAL FORENSIC ERROR: Nested architecture detected at key '{key}'. "
                    f"Zero-Omission rules violated."
                )
        return self

# --- PYTEST FACTORY EXECUTION ---
def load_registry():
    with open("tests/golden_test_registry.json", "r") as f:
        return json.load(f)

REGISTRY = load_registry()

@pytest.mark.parametrize("test_case", REGISTRY, ids=[tc["test_id"] for tc in REGISTRY])
def test_iron_gate_factory(test_case):
    """Dynamically executes every forensic constraint defined in the JSON registry."""
    payload = test_case["payload"]
    expected_result = test_case["expected_result"]
    
    if expected_result == "PASS":
        # The payload must parse flawlessly without raising an error
        instance = BankingCheckingLane(**payload)
        assert instance.binary_header_hex == "25504446"
        
    elif expected_result == "FAIL":
        # The payload MUST trigger a violent ValidationError containing the exact string
        expected_error = test_case["expected_error_string"]
        with pytest.raises(ValidationError) as exc_info:
            BankingCheckingLane(**payload)
        
        assert expected_error in str(exc_info.value), \
            f"Expected error '{expected_error}' not found in '{str(exc_info.value)}'"

