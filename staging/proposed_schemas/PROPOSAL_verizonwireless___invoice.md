Here are the two requested markdown blocks.

BLOCK 1 (Python Pydantic V2):
```python
import math
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon


class UsageDetail(BaseModel):
    """Represents a single line item for usage, such as voice, data, or messaging."""
    model_config = ConfigDict(extra='forbid')
    item_description: ForensicDataEntity
    usage_unit: Optional[ForensicDataEntity] = None
    plan_limit: Optional[ForensicDataEntity] = None
    used_quantity: Optional[ForensicDataEntity] = None
    cost: ForensicDataEntity


class VerizonwirelessInvoiceV1(BaseModel):
    """
    Schema for a Verizon Wireless invoice, designed to be resilient to structural changes.
    It captures key financial summary figures and a detailed breakdown of usage charges.
    """
    model_config = ConfigDict(extra='forbid')

    # High-level document and account identifiers
    account_number: Optional[ForensicDataEntity] = None
    bill_date: Optional[ForensicDataEntity] = None
    due_date: Optional[ForensicDataEntity] = None
    document_id: Optional[ForensicDataEntity] = None

    # Core financial summary fields
    previous_balance: Optional[ForensicDataEntity] = None
    payments_and_credits: Optional[ForensicDataEntity] = None
    balance_forward: Optional[ForensicDataEntity] = None
    new_charges: Optional[ForensicDataEntity] = None
    total_amount_due: Optional[ForensicDataEntity] = None

    # Detailed breakdown of charges
    usage_details: Optional[List[UsageDetail]] = None

    @model_validator(mode='after')
    def gaap_checksum(self) -> 'VerizonwirelessInvoiceV1':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        1. Verifies that Previous Balance - Payments/Credits = Balance Forward.
        2. Verifies that Balance Forward + New Charges = Total Amount Due.
        """
        def get_value(field: Optional[ForensicDataEntity]) -> Optional[float]:
            if field and isinstance(field.extracted_string_or_numeric_value, (int, float)):
                return float(field.extracted_string_or_numeric_value)
            return None

        # Check 1: Previous Balance - Payments = Balance Forward
        previous_balance = get_value(self.previous_balance)
        payments = get_value(self.payments_and_credits)
        balance_forward = get_value(self.balance_forward)

        if all(v is not None for v in [previous_balance, payments, balance_forward]):
            if not math.isclose(previous_balance - payments, balance_forward, rel_tol=0.01):
                raise ValueError(
                    f"Checksum failed: Previous Balance ({previous_balance}) - Payments ({payments}) "
                    f"is not close to Balance Forward ({balance_forward})"
                )

        # Check 2: Balance Forward + New Charges = Total Amount Due
        new_charges = get_value(self.new_charges)
        total_due = get_value(self.total_amount_due)

        if all(v is not None for v in [balance_forward, new_charges, total_due]):
            if not math.isclose(balance_forward + new_charges, total_due, rel_tol=0.01):
                raise ValueError(
                    f"Checksum failed: Balance Forward ({balance_forward}) + New Charges ({new_charges}) "
                    f"is not close to Total Amount Due ({total_due})"
                )

        return self
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "verizon-invoice-complex-variant-01",
    "should_pass": true,
    "taxonomy_lane": "VerizonwirelessInvoiceV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_id": {
        "extracted_string_or_numeric_value": "0096235-036053",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [88, 201, 201, 88],
          "vertical_y_vertices": [969, 969, 978, 978]
        }
      },
      "previous_balance": {
        "extracted_string_or_numeric_value": 125.50,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [200, 200, 210, 210]
        }
      },
      "payments_and_credits": {
        "extracted_string_or_numeric_value": 125.50,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [215, 215, 225, 225]
        }
      },
      "balance_forward": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [230, 230, 240, 240]
        }
      },
      "new_charges": {
        "extracted_string_or_numeric_value": 95.75,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [245, 245, 255, 255]
        }
      },
      "total_amount_due": {
        "extracted_string_or_numeric_value": 95.75,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [260, 260, 270, 270]
        }
      },
      "usage_details": [
        {
          "item_description": {
            "extracted_string_or_numeric_value": "Total Voice",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [145, 220, 220, 145], "vertical_y_vertices": [754, 754, 764, 764] }
          },
          "usage_unit": {
            "extracted_string_or_numeric_value": "minutes",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 640, 640, 590], "vertical_y_vertices": [754, 754, 764, 764] }
          },
          "plan_limit": {
            "extracted_string_or_numeric_value": "unlimited",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710, 710, 650], "vertical_y_vertices": [754, 754, 764, 764] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850, 850, 800], "vertical_y_vertices": [754, 754, 764, 764] }
          }
        },
        {
          "item_description": {
            "extracted_string_or_numeric_value": "Text, Picture & Video",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [145, 300, 300, 145], "vertical_y_vertices": [780, 780, 790, 790] }
          },
          "usage_unit": {
            "extracted_string_or_numeric_value": "messages",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 650, 650, 590], "vertical_y_vertices": [780, 780, 790, 790] }
          },
          "plan_limit": {
            "extracted_string_or_numeric_value": "unlimited",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710, 710, 650], "vertical_y_vertices": [780, 780, 790, 790] }
          },
          "used_quantity": {
            "extracted_string_or_numeric_value": 73,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 740, 740, 720], "vertical_y_vertices": [780, 780, 790, 790] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850, 850, 800], "vertical_y_vertices": [780, 780, 790, 790] }
          }
        },
        {
          "item_description": {
            "extracted_string_or_numeric_value": "Unlimited Plus Plan",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [145, 280, 280, 145], "vertical_y_vertices": [650, 650, 660, 660] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 80.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850, 850, 800], "vertical_y_vertices": [650, 650, 660, 660] }
          }
        },
        {
          "item_description": {
            "extracted_string_or_numeric_value": "Taxes and Surcharges",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [145, 290, 290, 145], "vertical_y_vertices": [670, 670, 680, 680] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 15.75,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850, 850, 800], "vertical_y_vertices": [670, 670, 680, 680] }
          }
        }
      ]
    }
  }
]
```