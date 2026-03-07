An analysis of the provided document, a Fifth Third Bank receipt, alongside supplementary handwritten calculations, reveals a transactional data structure. The primary document establishes the core fields such as bank identity, transaction metadata (date, time, reference numbers), and a total amount. The handwritten notes, while not part of the official receipt, suggest a potential structural variant where a total amount is derived from a series of line items.

To create a resilient schema that accommodates both the observed structure and this potential variant, the Pydantic model will include core, non-optional fields for essential transaction data and optional fields for details that might vary between document layouts. Crucially, an optional `line_items` field is introduced. This allows the schema to parse simple receipts with only a total, as well as more complex ones with itemized breakdowns.

The mandatory GAAP checksum is implemented via a `model_validator`. This validator activates only if `line_items` are present, summing them and comparing the result against the `total_amount`. This ensures mathematical consistency for documents that provide an itemization, while gracefully handling those that do not. The JSON test case is constructed to represent this "most complex" variant, including line items that successfully pass the checksum, thereby demonstrating the schema's full capability.

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError
from typing import List, Optional, Union

#
# MANDATORY FORENSIC DATA STRUCTURES
#

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of a detected text block on a document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

#
# DOCUMENT-SPECIFIC SCHEMA
#

class FifthThirdBankReceipt(BaseModel):
    """
    A resilient schema for Fifth Third Bank receipts, accommodating single-total
    transactions and potential future variants with itemized breakdowns.
    """
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    bank_slogan: Optional[ForensicDataEntity] = None
    payment_service_header: Optional[ForensicDataEntity] = None
    payment_service_subheader: Optional[ForensicDataEntity] = None
    payment_service_url: Optional[ForensicDataEntity] = None
    receipt_title: ForensicDataEntity
    teller_id: Optional[ForensicDataEntity] = None
    branch_code: Optional[ForensicDataEntity] = None
    reference_number: Optional[ForensicDataEntity] = None
    payment_instrument_type: Optional[ForensicDataEntity] = None
    payment_instrument_last4: Optional[ForensicDataEntity] = None
    transaction_date: ForensicDataEntity
    transaction_time: ForensicDataEntity
    total_amount: ForensicDataEntity
    disclaimers: Optional[List[ForensicDataEntity]] = None
    document_id: Optional[ForensicDataEntity] = None
    line_items: Optional[List[ForensicDataEntity]] = None

    @model_validator(mode='after')
    def validate_gaap_checksum(self) -> 'FifthThirdBankReceipt':
        """
        Performs a GAAP-style checksum if line items are present, ensuring
        their sum matches the total amount.
        """
        if self.line_items:
            # Ensure total_amount is a numeric type for comparison
            if not isinstance(self.total_amount.extracted_string_or_numeric_value, (int, float)):
                raise TypeError(f"Total amount must be numeric for checksum, but got type {type(self.total_amount.extracted_string_or_numeric_value)}")

            # Sum the line items, ensuring they are also numeric
            line_item_values = []
            for item in self.line_items:
                if not isinstance(item.extracted_string_or_numeric_value, (int, float)):
                    raise TypeError(f"Line item value must be numeric, but got type {type(item.extracted_string_or_numeric_value)}")
                line_item_values.append(item.extracted_string_or_numeric_value)
            
            calculated_sum = sum(line_item_values)
            total_val = self.total_amount.extracted_string_or_numeric_value

            # Compare sum with total, allowing for floating point inaccuracies
            if abs(calculated_sum - total_val) > 0.01:
                raise ValueError(f"GAAP Checksum Failed: Sum of line items ({calculated_sum:.2f}) does not match the total amount ({total_val:.2f}).")
        
        return self

```
```json
[
  {
    "test_identifier": "00165_2014-05-16_complex_variant_checksum",
    "should_pass": true,
    "taxonomy_lane": "FifthThirdBankReceipt",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "FIFTH THIRD BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [51, 300],
          "vertical_y_vertices": [350, 380]
        }
      },
      "bank_slogan": {
        "extracted_string_or_numeric_value": "The curious bank.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [51, 200],
          "vertical_y_vertices": [390, 405]
        }
      },
      "payment_service_header": {
        "extracted_string_or_numeric_value": "Paying your bills has never been easier.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [485, 960],
          "vertical_y_vertices": [310, 330]
        }
      },
      "payment_service_subheader": {
        "extracted_string_or_numeric_value": "Fifth Third Online Bill Payment",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [605, 960],
          "vertical_y_vertices": [340, 360]
        }
      },
      "payment_service_url": {
        "extracted_string_or_numeric_value": "53.com/bill-pay",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 960],
          "vertical_y_vertices": [370, 390]
        }
      },
      "receipt_title": {
        "extracted_string_or_numeric_value": "This is your receipt.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 280],
          "vertical_y_vertices": [550, 570]
        }
      },
      "teller_id": {
        "extracted_string_or_numeric_value": "1",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [520, 560],
          "vertical_y_vertices": [460, 475]
        }
      },
      "branch_code": {
        "extracted_string_or_numeric_value": "5403",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [570, 630],
          "vertical_y_vertices": [460, 475]
        }
      },
      "reference_number": {
        "extracted_string_or_numeric_value": "799489163",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [670, 820],
          "vertical_y_vertices": [460, 475]
        }
      },
      "payment_instrument_type": {
        "extracted_string_or_numeric_value": "CK",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [520, 545],
          "vertical_y_vertices": [480, 495]
        }
      },
      "payment_instrument_last4": {
        "extracted_string_or_numeric_value": "3451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [550, 650],
          "vertical_y_vertices": [480, 495]
        }
      },
      "transaction_date": {
        "extracted_string_or_numeric_value": "5/16/2014",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [520, 620],
          "vertical_y_vertices": [520, 535]
        }
      },
      "transaction_time": {
        "extracted_string_or_numeric_value": "4:08:59 PM",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [630, 750],
          "vertical_y_vertices": [520, 535]
        }
      },
      "total_amount": {
        "extracted_string_or_numeric_value": 793.24,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [870, 950],
          "vertical_y_vertices": [480, 500]
        }
      },
      "line_items": [
        {
          "extracted_string_or_numeric_value": 80.00,
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 200], "vertical_y_vertices": [100, 120] }
        },
        {
          "extracted_string_or_numeric_value": 24.00,
          "optical_extraction_confidence_score": 0.93,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 200], "vertical_y_vertices": [120, 140] }
        },
        {
          "extracted_string_or_numeric_value": 174.50,
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 200], "vertical_y_vertices": [140, 160] }
        },
        {
          "extracted_string_or_numeric_value": 265.00,
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 200], "vertical_y_vertices": [160, 180] }
        },
        {
          "extracted_string_or_numeric_value": 211.48,
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 200], "vertical_y_vertices": [180, 200] }
        },
        {
          "extracted_string_or_numeric_value": 38.26,
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 200], "vertical_y_vertices": [200, 220] }
        }
      ],
      "disclaimers": [
        {
          "extracted_string_or_numeric_value": "Deposits may not be available for immediate withdrawal.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [50, 500], "vertical_y_vertices": [590, 605] }
        }
      ],
      "document_id": {
        "extracted_string_or_numeric_value": "901081 (8/13)",
        "optical_extraction_confidence_score": 0.90,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [50, 150], "vertical_y_vertices": [700, 715] }
      }
    }
  }
]
```