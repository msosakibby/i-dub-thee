BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class DepositReceipt00166(BaseModel):
    """
    A Pydantic V2 schema for Fifth Third Bank deposit receipts.
    The provided documents show a consistent structure from the same form version.
    """
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    teller_number: ForensicDataEntity
    branch_number: ForensicDataEntity
    reference_number: ForensicDataEntity
    check_number_last4: ForensicDataEntity
    transaction_date: ForensicDataEntity
    transaction_time: ForensicDataEntity
    deposit_amount: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'DepositReceipt00166':
        """
        Executes double-entry GAAP mathematical checksums.
        For this document, only a single financial value (deposit_amount) is present.
        A true double-entry checksum is not possible as there are no itemized amounts to sum.
        As a proxy, this validator ensures the primary financial value is non-negative,
        adhering to the principle of validating financial data integrity.
        """
        deposit_amount = self.deposit_amount.extracted_string_or_numeric_value

        if not isinstance(deposit_amount, (float, int)):
            raise ValueError("deposit_amount must be a numeric value for validation.")

        if deposit_amount < 0:
            raise ValueError(f"Invalid deposit amount: {deposit_amount}. Amount cannot be negative.")

        # No other values to sum against, so the check is complete.
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "00166_804017089_receipt",
    "should_pass": true,
    "taxonomy_lane": "DepositReceipt00166",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "FIFTH THIRD BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            38.0,
            308.0,
            308.0,
            38.0
          ],
          "vertical_y_vertices": [
            360.0,
            360.0,
            385.0,
            385.0
          ]
        }
      },
      "teller_number": {
        "extracted_string_or_numeric_value": "1",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            530.0,
            558.0,
            558.0,
            530.0
          ],
          "vertical_y_vertices": [
            453.0,
            453.0,
            469.0,
            469.0
          ]
        }
      },
      "branch_number": {
        "extracted_string_or_numeric_value": "5403",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            578.0,
            635.0,
            635.0,
            578.0
          ],
          "vertical_y_vertices": [
            453.0,
            453.0,
            469.0,
            469.0
          ]
        }
      },
      "reference_number": {
        "extracted_string_or_numeric_value": "804017089",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            688.0,
            808.0,
            808.0,
            688.0
          ],
          "vertical_y_vertices": [
            453.0,
            453.0,
            469.0,
            469.0
          ]
        }
      },
      "check_number_last4": {
        "extracted_string_or_numeric_value": "3451",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            530.0,
            650.0,
            650.0,
            530.0
          ],
          "vertical_y_vertices": [
            477.0,
            477.0,
            493.0,
            493.0
          ]
        }
      },
      "transaction_date": {
        "extracted_string_or_numeric_value": "6/6/2014",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            529.0,
            618.0,
            618.0,
            529.0
          ],
          "vertical_y_vertices": [
            501.0,
            501.0,
            517.0,
            517.0
          ]
        }
      },
      "transaction_time": {
        "extracted_string_or_numeric_value": "1:15:15 PM",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            623.0,
            735.0,
            735.0,
            623.0
          ],
          "vertical_y_vertices": [
            501.0,
            501.0,
            517.0,
            517.0
          ]
        }
      },
      "deposit_amount": {
        "extracted_string_or_numeric_value": 639.67,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            870.0,
            955.0,
            955.0,
            870.0
          ],
          "vertical_y_vertices": [
            477.0,
            477.0,
            493.0,
            493.0
          ]
        }
      }
    }
  }
]
```