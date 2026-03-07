An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document class '000075-1' to design a resilient Pydantic V2 schema. The document is a birth announcement card, and the schema captures all key details from both the front and back, including the baby's information, birth statistics, parental details, and card branding. Fields that are likely part of the card's template or branding, and thus may not be present in all variations, are typed as `Optional` to ensure broad compatibility. A logical validator is included to check the integrity of the numerical birth statistics, fulfilling the directive for a mathematical checksum in a context-appropriate manner.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon for the spatial coordinates of an extracted entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class BirthAnnouncementV1(BaseModel):
    """
    Schema for a birth announcement card, capturing details of the newborn and the announcement itself.
    """
    model_config = ConfigDict(extra='forbid')

    baby_full_name: ForensicDataEntity
    birth_date: ForensicDataEntity
    birth_time: ForensicDataEntity
    weight_pounds: ForensicDataEntity
    weight_ounces: ForensicDataEntity
    length_inches: ForensicDataEntity
    parents_names: ForensicDataEntity
    welcome_message: Optional[ForensicDataEntity] = None
    card_title: Optional[ForensicDataEntity] = None
    brand_name: Optional[ForensicDataEntity] = None
    website: Optional[ForensicDataEntity] = None
    copyright_holder: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_logical_checks(self) -> 'BirthAnnouncementV1':
        """
        Performs logical data integrity checks on birth statistics.
        As this document class does not contain financial data, a traditional
        double-entry GAAP checksum is not applicable. Instead, this validator
        ensures that key numeric birth statistics are plausible (e.g., non-negative weight and length,
        and a valid range for ounces).
        """
        weight_lbs = self.weight_pounds.extracted_string_or_numeric_value
        weight_oz = self.weight_ounces.extracted_string_or_numeric_value
        length = self.length_inches.extracted_string_or_numeric_value

        if not isinstance(weight_lbs, (int, float)) or weight_lbs < 0:
            raise ValueError(f"Weight in pounds must be a non-negative number, but got {weight_lbs}")

        if not isinstance(weight_oz, (int, float)) or not (0 <= weight_oz < 16):
            raise ValueError(f"Weight in ounces must be a number between 0 and 15, but got {weight_oz}")

        if not isinstance(length, (int, float)) or length < 0:
            raise ValueError(f"Length in inches must be a non-negative number, but got {length}")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "birth_announcement_eleanor_roulston_2012",
    "should_pass": true,
    "taxonomy_lane": "BirthAnnouncementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "baby_full_name": {
        "extracted_string_or_numeric_value": "ELEANOR SHANTI ROULSTON",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178.0, 821.0, 821.0, 178.0],
          "vertical_y_vertices": [879.0, 879.0, 896.0, 896.0]
        }
      },
      "birth_date": {
        "extracted_string_or_numeric_value": "SEPTEMBER 2, 2012",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178.0, 420.0, 420.0, 178.0],
          "vertical_y_vertices": [906.0, 906.0, 922.0, 922.0]
        }
      },
      "birth_time": {
        "extracted_string_or_numeric_value": "5:06 AM",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [425.0, 545.0, 545.0, 425.0],
          "vertical_y_vertices": [906.0, 906.0, 922.0, 922.0]
        }
      },
      "weight_pounds": {
        "extracted_string_or_numeric_value": 7.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [550.0, 680.0, 680.0, 550.0],
          "vertical_y_vertices": [906.0, 906.0, 922.0, 922.0]
        }
      },
      "weight_ounces": {
        "extracted_string_or_numeric_value": 6.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [685.0, 821.0, 821.0, 685.0],
          "vertical_y_vertices": [906.0, 906.0, 922.0, 922.0]
        }
      },
      "length_inches": {
        "extracted_string_or_numeric_value": 19.0,
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [826.0, 950.0, 950.0, 826.0],
          "vertical_y_vertices": [906.0, 906.0, 922.0, 922.0]
        }
      },
      "parents_names": {
        "extracted_string_or_numeric_value": "kevin & amy",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700.0, 821.0, 821.0, 700.0],
          "vertical_y_vertices": [933.0, 933.0, 949.0, 949.0]
        }
      },
      "welcome_message": {
        "extracted_string_or_numeric_value": "with love and gratitude we welcome her",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [415.0, 695.0, 695.0, 415.0],
          "vertical_y_vertices": [933.0, 933.0, 949.0, 949.0]
        }
      },
      "card_title": {
        "extracted_string_or_numeric_value": "Our new arrival",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220.0, 780.0, 780.0, 220.0],
          "vertical_y_vertices": [390.0, 390.0, 440.0, 440.0]
        }
      },
      "brand_name": {
        "extracted_string_or_numeric_value": "tinyprints",
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [490.0, 620.0, 620.0, 490.0],
          "vertical_y_vertices": [910.0, 910.0, 925.0, 925.0]
        }
      },
      "website": {
        "extracted_string_or_numeric_value": "www.tinyprints.com",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [340.0, 490.0, 490.0, 340.0],
          "vertical_y_vertices": [935.0, 935.0, 950.0, 950.0]
        }
      },
      "copyright_holder": {
        "extracted_string_or_numeric_value": "Tiny Prints, Inc.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500.0, 630.0, 630.0, 500.0],
          "vertical_y_vertices": [935.0, 935.0, 950.0, 950.0]
        }
      }
    }
  }
]
```