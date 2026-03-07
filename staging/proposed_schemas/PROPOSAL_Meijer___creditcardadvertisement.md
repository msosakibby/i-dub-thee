**BLOCK 1 (Python Pydantic V2):**
```python
from typing import List, Union, Optional
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

class MeijerCreditcardadvertisementV1(BaseModel):
    """
    A Pydantic V2 schema for Meijer credit card advertisements.
    This schema is designed to be resilient to structural variations over time.
    """
    model_config = ConfigDict(extra='forbid')

    document_code_top_right: Optional[ForensicDataEntity] = None
    document_code_top_middle: Optional[ForensicDataEntity] = None
    page_number: Optional[ForensicDataEntity] = None
    main_headline: Optional[ForensicDataEntity] = None
    service_option_delivery: Optional[ForensicDataEntity] = None
    service_option_pickup: Optional[ForensicDataEntity] = None
    legal_disclaimer: Optional[ForensicDataEntity] = None
    document_code_bottom_right: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'MeijerCreditcardadvertisementV1':
        """
        Validates financial data integrity using double-entry accounting principles.
        NOTE: This document class ('Meijer - creditcardadvertisement') does not contain
        financial figures, so no checksums are performed. The validator is included
        for structural compliance with the Zero-Trust mandate.
        """
        # No financial fields are present in this document type to perform a checksum on.
        return self

```

**BLOCK 2 (JSON Test Registry):**
```json
[
  {
    "test_identifier": "meijer_ad_complex_case_1",
    "should_pass": true,
    "taxonomy_lane": "MeijerCreditcardadvertisementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_code_top_right": {
        "extracted_string_or_numeric_value": "142706",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            902.0,
            941.0
          ],
          "vertical_y_vertices": [
            120.0,
            130.0
          ]
        }
      },
      "document_code_top_middle": {
        "extracted_string_or_numeric_value": "01300170-000156-56-0006-0009",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            670.0,
            800.0
          ],
          "vertical_y_vertices": [
            125.0,
            135.0
          ]
        }
      },
      "page_number": {
        "extracted_string_or_numeric_value": "Page 11 of 18",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            22.0,
            30.0
          ],
          "vertical_y_vertices": [
            470.0,
            520.0
          ]
        }
      },
      "main_headline": {
        "extracted_string_or_numeric_value": "use your Meijer Credit Card on meijer.com",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            860.0,
            950.0
          ],
          "vertical_y_vertices": [
            450.0,
            750.0
          ]
        }
      },
      "service_option_delivery": {
        "extracted_string_or_numeric_value": "home delivery",
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            750.0,
            840.0
          ],
          "vertical_y_vertices": [
            530.0,
            600.0
          ]
        }
      },
      "service_option_pickup": {
        "extracted_string_or_numeric_value": "pickup",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            750.0,
            840.0
          ],
          "vertical_y_vertices": [
            650.0,
            720.0
          ]
        }
      },
      "legal_disclaimer": {
        "extracted_string_or_numeric_value": "The Meijer Mastercard is issued by Citibank, N.A., pursuant to a license from Mastercard International Incorporated. Mastercard and the circles design are registered trademarks of Mastercard International Incorporated.",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            670.0,
            840.0
          ],
          "vertical_y_vertices": [
            410.0,
            800.0
          ]
        }
      },
      "document_code_bottom_right": {
        "extracted_string_or_numeric_value": "244",
        "optical_extraction_confidence_score": 0.89,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            820.0,
            835.0
          ],
          "vertical_y_vertices": [
            810.0,
            825.0
          ]
        }
      }
    }
  }
]
```