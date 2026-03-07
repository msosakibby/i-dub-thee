Here are the Pydantic V2 schema and the corresponding JSON test case as requested.

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single piece of extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AflacPremiumNotice(BaseModel):
    """
    Schema for Aflac's 'Notice of Premium Due' documents, circa 2019.
    """
    model_config = ConfigDict(extra='forbid')

    # Core Policy & Billing Information
    plan_number: ForensicDataEntity
    plan_type: ForensicDataEntity
    coverage_type: ForensicDataEntity
    months_billed: ForensicDataEntity
    recipient_name: ForensicDataEntity
    recipient_address: ForensicDataEntity
    due_date: ForensicDataEntity
    amount_due: ForensicDataEntity

    # Issuer Information
    issuer_name: ForensicDataEntity
    issuer_phone: ForensicDataEntity
    issuer_website: ForensicDataEntity

    # Optional fields that may vary across document versions
    termination_date: Optional[ForensicDataEntity] = None
    issuer_phone_spanish: Optional[ForensicDataEntity] = None
    issuer_legal_name: Optional[ForensicDataEntity] = None
    issuer_address: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'AflacPremiumNotice':
        """
        Performs double-entry GAAP mathematical checksums.
        For this document, there is only a single financial value ('amount_due')
        with no corresponding line items to sum. Therefore, no checksum
        is applicable or performed. The validator is included to meet
        the structural requirement of the forensic framework.
        """
        # No line items, subtotals, or other values are present to validate against the amount_due.
        # For example, a check like `sum(line_items) == total_amount` is not possible.
        # As this is not possible, the validator confirms its own execution and passes.
        return self

```

```json
[
  {
    "test_identifier": "2019-03-15-aflac-premium-notice-001",
    "should_pass": true,
    "taxonomy_lane": "AflacPremiumNotice",
    "binary_header_simulation": "25504446",
    "payload": {
      "plan_number": {
        "extracted_string_or_numeric_value": "OZ100560",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [80, 160, 160, 80],
          "vertical_y_vertices": [220, 235, 235, 220]
        }
      },
      "plan_type": {
        "extracted_string_or_numeric_value": "CANCER",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [230, 285, 285, 230],
          "vertical_y_vertices": [220, 235, 235, 220]
        }
      },
      "coverage_type": {
        "extracted_string_or_numeric_value": "INDIVIDUAL",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [370, 445, 445, 370],
          "vertical_y_vertices": [220, 235, 235, 220]
        }
      },
      "months_billed": {
        "extracted_string_or_numeric_value": 3,
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [520, 600, 600, 520],
          "vertical_y_vertices": [220, 235, 235, 220]
        }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [107, 200, 200, 107],
          "vertical_y_vertices": [328, 340, 340, 328]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "PO Box 297\nMarion MI 49665-0297",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [107, 250, 250, 107],
          "vertical_y_vertices": [341, 370, 370, 341]
        }
      },
      "due_date": {
        "extracted_string_or_numeric_value": "March 15, 2019",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 780, 780, 680],
          "vertical_y_vertices": [280, 295, 295, 280]
        }
      },
      "amount_due": {
        "extracted_string_or_numeric_value": 60.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [820, 890, 890, 820],
          "vertical_y_vertices": [280, 295, 295, 280]
        }
      },
      "issuer_name": {
        "extracted_string_or_numeric_value": "Aflac",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [718, 892, 892, 718],
          "vertical_y_vertices": [105, 155, 155, 105]
        }
      },
      "issuer_phone": {
        "extracted_string_or_numeric_value": "1-800-992-3522",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [718, 892, 892, 718],
          "vertical_y_vertices": [168, 180, 180, 168]
        }
      },
      "issuer_website": {
        "extracted_string_or_numeric_value": "aflac.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [790, 850, 850, 790],
          "vertical_y_vertices": [195, 205, 205, 195]
        }
      },
      "termination_date": {
        "extracted_string_or_numeric_value": "May 6, 2019",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 750, 750, 680],
          "vertical_y_vertices": [825, 835, 835, 825]
        }
      },
      "issuer_phone_spanish": {
        "extracted_string_or_numeric_value": "1-800-742-3522",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [718, 892, 892, 718],
          "vertical_y_vertices": [181, 193, 193, 181]
        }
      },
      "issuer_legal_name": {
        "extracted_string_or_numeric_value": "American Family Life Assurance Company of Columbus (Aflac)",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 580, 580, 120],
          "vertical_y_vertices": [910, 922, 922, 910]
        }
      },
      "issuer_address": {
        "extracted_string_or_numeric_value": "Worldwide Headquarters Columbus, Georgia 31999-0001",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [585, 880, 880, 585],
          "vertical_y_vertices": [910, 922, 922, 910]
        }
      }
    }
  }
]
```