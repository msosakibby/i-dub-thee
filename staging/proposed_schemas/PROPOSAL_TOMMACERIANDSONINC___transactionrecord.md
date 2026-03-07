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

class TransactionDetails(BaseModel):
    """Detailed breakdown of the financial transaction."""
    model_config = ConfigDict(extra='forbid')
    you_sent: ForensicDataEntity
    wise_s_fees: ForensicDataEntity
    recipient_received_amount: ForensicDataEntity
    reference: ForensicDataEntity
    transaction_number: ForensicDataEntity

    @model_validator(mode='after')
    def validate_gaap_checksum(self) -> 'TransactionDetails':
        """
        Validates that the total amount sent equals the sum of the received amount and fees.
        This follows the double-entry accounting principle.
        """
        try:
            sent_total = float(self.you_sent.extracted_string_or_numeric_value)
            fees = float(self.wise_s_fees.extracted_string_or_numeric_value)
            received_amount = float(self.recipient_received_amount.extracted_string_or_numeric_value)
        except (ValueError, TypeError):
            raise ValueError("Financial fields (you_sent, wise_s_fees, recipient_received_amount) must contain valid numeric values for GAAP validation.")

        if not math.isclose(sent_total, received_amount + fees):
            raise ValueError(
                f"GAAP checksum failed: Total sent amount {sent_total} does not equal "
                f"the sum of the received amount {received_amount} and fees {fees}."
            )
        return self

class AccountDetails(BaseModel):
    """Recipient's bank account details."""
    model_config = ConfigDict(extra='forbid')
    account_holder_name: ForensicDataEntity
    routing_number: ForensicDataEntity
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    email: Optional[ForensicDataEntity] = None
    bank_name: ForensicDataEntity

class TommaceriandsonincTransactionrecord(BaseModel):
    """
    Schema for a transaction record sent to TOM MACERI AND SON, INC.
    """
    model_config = ConfigDict(extra='forbid')
    sent_amount: ForensicDataEntity
    recipient_name_header: ForensicDataEntity
    transaction_details: TransactionDetails
    account_details: AccountDetails
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "tmac_trans_rec_001_complex",
    "should_pass": true,
    "taxonomy_lane": "TommaceriandsonincTransactionrecord",
    "binary_header_simulation": "25504446",
    "payload": {
      "sent_amount": {
        "extracted_string_or_numeric_value": 505.20,
        "optical_extraction_confidence_score": 0.995,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [398.0, 601.0, 601.0, 398.0],
          "vertical_y_vertices": [40.0, 40.0, 68.0, 68.0]
        }
      },
      "recipient_name_header": {
        "extracted_string_or_numeric_value": "TOM MACERI AND SON, INC.",
        "optical_extraction_confidence_score": 0.989,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [399.0, 599.0, 599.0, 399.0],
          "vertical_y_vertices": [74.0, 74.0, 87.0, 87.0]
        }
      },
      "transaction_details": {
        "you_sent": {
          "extracted_string_or_numeric_value": 506.33,
          "optical_extraction_confidence_score": 0.991,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 690.0, 690.0, 261.0],
            "vertical_y_vertices": [359.0, 359.0, 374.0, 374.0]
          }
        },
        "wise_s_fees": {
          "extracted_string_or_numeric_value": 1.13,
          "optical_extraction_confidence_score": 0.992,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 690.0, 690.0, 261.0],
            "vertical_y_vertices": [390.0, 390.0, 405.0, 405.0]
          }
        },
        "recipient_received_amount": {
          "extracted_string_or_numeric_value": 505.20,
          "optical_extraction_confidence_score": 0.998,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [449.0, 449.0, 466.0, 466.0]
          }
        },
        "reference": {
          "extracted_string_or_numeric_value": "Bill345145",
          "optical_extraction_confidence_score": 0.994,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [520.0, 520.0, 535.0, 535.0]
          }
        },
        "transaction_number": {
          "extracted_string_or_numeric_value": "#1604782735",
          "optical_extraction_confidence_score": 0.993,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [551.0, 551.0, 566.0, 566.0]
          }
        }
      },
      "account_details": {
        "account_holder_name": {
          "extracted_string_or_numeric_value": "TOM MACERI AND SON, INC.",
          "optical_extraction_confidence_score": 0.988,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [745.0, 745.0, 760.0, 760.0]
          }
        },
        "routing_number": {
          "extracted_string_or_numeric_value": "072403473",
          "optical_extraction_confidence_score": 0.997,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [776.0, 776.0, 791.0, 791.0]
          }
        },
        "account_number": {
          "extracted_string_or_numeric_value": "01368576990",
          "optical_extraction_confidence_score": 0.996,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [807.0, 807.0, 822.0, 822.0]
          }
        },
        "account_type": {
          "extracted_string_or_numeric_value": "Checking",
          "optical_extraction_confidence_score": 0.995,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [838.0, 838.0, 853.0, 853.0]
          }
        },
        "email": {
          "extracted_string_or_numeric_value": "danielle@tommaceriandson.com",
          "optical_extraction_confidence_score": 0.990,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [869.0, 869.0, 884.0, 884.0]
          }
        },
        "bank_name": {
          "extracted_string_or_numeric_value": "HUNTINGTON NATIONAL BANK",
          "optical_extraction_confidence_score": 0.987,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [261.0, 720.0, 720.0, 261.0],
            "vertical_y_vertices": [900.0, 900.0, 915.0, 915.0]
          }
        }
      }
    }
  }
]
```