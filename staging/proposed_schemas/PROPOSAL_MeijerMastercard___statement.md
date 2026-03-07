BLOCK 1 (Python Pydantic V2):
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of an extracted entity on the document page."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data entity, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class MeijerMastercardStatement(BaseModel):
    """
    Schema for an informational page from a Meijer Mastercard document,
    detailing how to update email communication preferences.
    """
    model_config = ConfigDict(extra='forbid')

    main_header: ForensicDataEntity
    sub_header: ForensicDataEntity
    instructions_title: ForensicDataEntity
    step_1_instruction: ForensicDataEntity
    step_2_instruction: ForensicDataEntity
    step_3_instruction: ForensicDataEntity
    step_4_instruction: ForensicDataEntity
    page_number: ForensicDataEntity
    total_pages: ForensicDataEntity
    document_code_1: Optional[ForensicDataEntity] = None
    document_code_2: Optional[ForensicDataEntity] = None
    document_code_3: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'MeijerMastercardStatement':
        """
        No financial transactions are present on this informational document.
        Therefore, no double-entry GAAP mathematical checksums can be performed.
        The validator will pass without action.
        """
        # No financial fields to validate in this document type.
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "meijer_mastercard_email_promo_001",
    "should_pass": true,
    "taxonomy_lane": "MeijerMastercardStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "main_header": {
        "extracted_string_or_numeric_value": "get the most from your Meijer Mastercard®",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [218, 801, 801, 218],
          "vertical_y_vertices": [708, 708, 851, 851]
        }
      },
      "sub_header": {
        "extracted_string_or_numeric_value": "update your email communication preferences to receive special offers and news",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [218, 785, 785, 218],
          "vertical_y_vertices": [605, 605, 691, 691]
        }
      },
      "instructions_title": {
        "extracted_string_or_numeric_value": "four easy steps to get started",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [388, 784, 784, 388],
          "vertical_y_vertices": [389, 389, 418, 418]
        }
      },
      "step_1_instruction": {
        "extracted_string_or_numeric_value": "log in to your account at Meijer.AccountOnline.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [302, 784, 784, 302],
          "vertical_y_vertices": [329, 329, 343, 343]
        }
      },
      "step_2_instruction": {
        "extracted_string_or_numeric_value": "select 'Manage Account'",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [480, 784, 784, 480],
          "vertical_y_vertices": [263, 263, 277, 277]
        }
      },
      "step_3_instruction": {
        "extracted_string_or_numeric_value": "select 'Profile'",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [558, 784, 784, 558],
          "vertical_y_vertices": [197, 197, 211, 211]
        }
      },
      "step_4_instruction": {
        "extracted_string_or_numeric_value": "select 'Email Communications'",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [439, 784, 784, 439],
          "vertical_y_vertices": [131, 131, 145, 145]
        }
      },
      "page_number": {
        "extracted_string_or_numeric_value": 9,
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [503, 512, 512, 503],
          "vertical_y_vertices": [25, 25, 34, 34]
        }
      },
      "total_pages": {
        "extracted_string_or_numeric_value": 18,
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [529, 545, 545, 529],
          "vertical_y_vertices": [25, 25, 34, 34]
        }
      },
      "document_code_1": {
        "extracted_string_or_numeric_value": "01300170-000156-0005-0009",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [863, 873, 873, 863],
          "vertical_y_vertices": [672, 672, 775, 775]
        }
      },
      "document_code_2": {
        "extracted_string_or_numeric_value": "142705",
        "optical_extraction_confidence_score": 0.93,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [863, 873, 873, 863],
          "vertical_y_vertices": [564, 564, 601, 601]
        }
      },
      "document_code_3": {
        "extracted_string_or_numeric_value": "791",
        "optical_extraction_confidence_score": 0.91,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [157, 173, 173, 157],
          "vertical_y_vertices": [76, 76, 85, 85]
        }
      }
    }
  }
]
```