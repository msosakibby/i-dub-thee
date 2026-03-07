Here is the Pydantic V2 schema and the corresponding JSON test case, designed to be resilient to the structural variations observed in the provided documents.

### BLOCK 1: Python Pydantic V2 Schema

```python
import math
from typing import List, Optional, Union

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    model_validator,
)

# DO NOT MODIFY THIS CLASS
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

# DO NOT MODIFY THIS CLASS
class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class LineItem(BaseModel):
    """Represents a single line item from a receipt or calculation."""
    model_config = ConfigDict(extra='forbid')
    item_amount: ForensicDataEntity

class MJFoodMarketDocument(BaseModel):
    """
    A resilient schema for documents from M & J Food Market, accommodating
    both business card layouts and receipt-like financial data.
    """
    model_config = ConfigDict(extra='forbid')

    # Business card fields
    business_name: Optional[ForensicDataEntity] = None
    phone_number: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    contact_name: Optional[ForensicDataEntity] = None
    contact_title: Optional[ForensicDataEntity] = None
    established_date: Optional[ForensicDataEntity] = None

    # Financial/Receipt fields
    line_items: Optional[List[LineItem]] = None
    subtotal: Optional[ForensicDataEntity] = None
    tax: Optional[ForensicDataEntity] = None
    total: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'MJFoodMarketDocument':
        """
        Performs checksums on financial fields if they are present.
        1. Verifies that the sum of line item amounts equals the subtotal.
        2. Verifies that subtotal + tax equals the total.
        """
        # Check 1: Sum of line items vs. subtotal
        if self.line_items and self.subtotal:
            # Ensure subtotal is a numeric type for comparison
            provided_subtotal = self.subtotal.extracted_string_or_numeric_value
            if isinstance(provided_subtotal, (int, float)):
                calculated_subtotal = sum(
                    item.item_amount.extracted_string_or_numeric_value
                    for item in self.line_items
                    if isinstance(item.item_amount.extracted_string_or_numeric_value, (int, float))
                )
                if not math.isclose(calculated_subtotal, provided_subtotal, rel_tol=1e-5):
                    raise ValueError(
                        f"Line items sum ({calculated_subtotal}) does not match subtotal ({provided_subtotal})"
                    )

        # Check 2: Subtotal + Tax vs. Total
        if self.subtotal and self.tax and self.total:
            subtotal_val = self.subtotal.extracted_string_or_numeric_value
            tax_val = self.tax.extracted_string_or_numeric_value
            total_val = self.total.extracted_string_or_numeric_value

            # Proceed only if all values are numeric
            if all(isinstance(v, (int, float)) for v in [subtotal_val, tax_val, total_val]):
                if not math.isclose(subtotal_val + tax_val, total_val, rel_tol=1e-5):
                    raise ValueError(
                        f"Subtotal ({subtotal_val}) + Tax ({tax_val}) does not equal Total ({total_val})"
                    )
        
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "complex_receipt_and_business_info_001",
    "should_pass": true,
    "taxonomy_lane": "MJFoodMarketDocument",
    "binary_header_simulation": "25504446",
    "payload": {
      "business_name": {
        "extracted_string_or_numeric_value": "M & J Food Market",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [300, 685],
          "vertical_y_vertices": [480, 515]
        }
      },
      "phone_number": {
        "extracted_string_or_numeric_value": "(616) 743-2873",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [738, 925],
          "vertical_y_vertices": [255, 275]
        }
      },
      "address": {
        "extracted_string_or_numeric_value": "P.O. Box 297\nMarion, MI 49665",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [378, 598],
          "vertical_y_vertices": [540, 600]
        }
      },
      "contact_name": {
        "extracted_string_or_numeric_value": "MAX R. KIBBY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [42, 225],
          "vertical_y_vertices": [680, 700]
        }
      },
      "contact_title": {
        "extracted_string_or_numeric_value": "President",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [73, 195],
          "vertical_y_vertices": [710, 730]
        }
      },
      "established_date": {
        "extracted_string_or_numeric_value": "1969",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [835, 925],
          "vertical_y_vertices": [705, 725]
        }
      },
      "line_items": [
        {
          "item_amount": {
            "extracted_string_or_numeric_value": 34.60,
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 300],
              "vertical_y_vertices": [300, 320]
            }
          }
        },
        {
          "item_amount": {
            "extracted_string_or_numeric_value": 5.37,
            "optical_extraction_confidence_score": 0.89,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 300],
              "vertical_y_vertices": [325, 345]
            }
          }
        }
      ],
      "subtotal": {
        "extracted_string_or_numeric_value": 39.97,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850],
          "vertical_y_vertices": [400, 420]
        }
      },
      "tax": {
        "extracted_string_or_numeric_value": 2.40,
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850],
          "vertical_y_vertices": [425, 445]
        }
      },
      "total": {
        "extracted_string_or_numeric_value": 42.37,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850],
          "vertical_y_vertices": [450, 470]
        }
      }
    }
  }
]
```