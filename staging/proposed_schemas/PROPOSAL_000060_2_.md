**BLOCK 1 (Python Pydantic V2):**
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Optional, Union

class SpatialCoordinatesPolygon(BaseModel):
    """
    Defines the spatial coordinates of a detected entity on the document.
    The vertices should be provided in a consistent order (e.g., clockwise).
    """
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """
    A wrapper for a single piece of extracted data, including its value,
    confidence, and location on the source document.
    """
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class HolidayCardV1(BaseModel):
    """
    Schema for a holiday greeting card, capturing textual content, names,
    and any incidental or processing information.
    """
    model_config = ConfigDict(extra='forbid')

    greeting_message: ForensicDataEntity
    family_name: ForensicDataEntity
    family_members: ForensicDataEntity
    location_name: Optional[ForensicDataEntity] = None
    mentioned_organizations: Optional[List[ForensicDataEntity]] = None
    processing_codes: Optional[List[ForensicDataEntity]] = None
    incidental_text: Optional[List[ForensicDataEntity]] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'HolidayCardV1':
        """
        A placeholder for GAAP-compliant mathematical checksums.
        No financial fields are present in this document class, so this
        validator performs no action.
        """
        # No financial data to validate in a holiday card.
        return self

```

**BLOCK 2 (JSON Test Registry):**
```json
[
  {
    "test_identifier": "test_000060_01_newsome_card",
    "should_pass": true,
    "taxonomy_lane": "HolidayCardV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "greeting_message": {
        "extracted_string_or_numeric_value": "From our family\nto yours...\nHappy New Year!",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [45, 450, 450, 45],
          "vertical_y_vertices": [450, 450, 750, 750]
        }
      },
      "family_name": {
        "extracted_string_or_numeric_value": "The Newsome's",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [90, 350, 350, 90],
          "vertical_y_vertices": [760, 760, 790, 790]
        }
      },
      "family_members": {
        "extracted_string_or_numeric_value": "Chad, Sue, Keaton and Ana",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [90, 400, 400, 90],
          "vertical_y_vertices": [795, 795, 825, 825]
        }
      },
      "location_name": {
        "extracted_string_or_numeric_value": "Great Smoky Mountains National Park",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [140, 405, 405, 140],
          "vertical_y_vertices": [130, 130, 250, 250]
        }
      },
      "mentioned_organizations": [
        {
          "extracted_string_or_numeric_value": "National Park Service",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 350, 350, 195],
            "vertical_y_vertices": [260, 260, 280, 280]
          }
        },
        {
          "extracted_string_or_numeric_value": "US Department of the interior",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 350, 350, 195],
            "vertical_y_vertices": [285, 285, 305, 305]
          }
        }
      ],
      "processing_codes": [
        {
          "extracted_string_or_numeric_value": "01001/18012 NNNN 6704620",
          "optical_extraction_confidence_score": 0.85,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 850, 850, 450],
            "vertical_y_vertices": [1100, 1100, 1120, 1120]
          }
        },
        {
          "extracted_string_or_numeric_value": "309938293-1",
          "optical_extraction_confidence_score": 0.88,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 950, 950, 800],
            "vertical_y_vertices": [1125, 1125, 1145, 1145]
          }
        }
      ],
      "incidental_text": [
        {
          "extracted_string_or_numeric_value": "ALE-4",
          "optical_extraction_confidence_score": 0.80,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [700, 780, 780, 700],
            "vertical_y_vertices": [450, 450, 490, 490]
          }
        }
      ]
    }
  }
]
```