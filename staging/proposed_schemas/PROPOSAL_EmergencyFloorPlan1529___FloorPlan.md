BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon for spatial coordinates of an extracted entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including metadata."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class EmergencyFloorPlan1529(BaseModel):
    """
    Schema for emergency floor plans, detailing the location of safety equipment.
    """
    model_config = ConfigDict(extra='forbid')

    plan_number: ForensicDataEntity
    smoke_detectors: Optional[List[ForensicDataEntity]] = None
    heat_detectors: Optional[List[ForensicDataEntity]] = None
    extinguishers: Optional[List[ForensicDataEntity]] = None
    exit_emergency_lights: Optional[List[ForensicDataEntity]] = None
    sprinkler_risers: Optional[List[ForensicDataEntity]] = None
    inspector_test_valves: Optional[List[ForensicDataEntity]] = None
    kitchen_systems: Optional[List[ForensicDataEntity]] = None
    alarm_panels: Optional[List[ForensicDataEntity]] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'EmergencyFloorPlan1529':
        """
        A mandatory validator for performing double-entry GAAP mathematical checksums.
        No financial data is present in this document type, so this validator
        currently performs no operations.
        """
        # No financial figures to validate in this document.
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "emergency_plan_1529_comprehensive_layout",
    "should_pass": true,
    "taxonomy_lane": "EmergencyFloorPlan1529",
    "binary_header_simulation": "25504446",
    "payload": {
      "plan_number": {
        "extracted_string_or_numeric_value": "1529",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            550,
            673,
            673,
            550
          ],
          "vertical_y_vertices": [
            195,
            195,
            218,
            218
          ]
        }
      },
      "smoke_detectors": [
        {
          "extracted_string_or_numeric_value": "Smoke Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              498,
              508,
              508,
              498
            ],
            "vertical_y_vertices": [
              257,
              257,
              267,
              267
            ]
          }
        },
        {
          "extracted_string_or_numeric_value": "Smoke Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              597,
              607,
              607,
              597
            ],
            "vertical_y_vertices": [
              317,
              317,
              327,
              327
            ]
          }
        },
        {
          "extracted_string_or_numeric_value": "Smoke Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              268,
              278,
              278,
              268
            ],
            "vertical_y_vertices": [
              697,
              697,
              707,
              707
            ]
          }
        },
        {
          "extracted_string_or_numeric_value": "Smoke Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              498,
              508,
              508,
              498
            ],
            "vertical_y_vertices": [
              767,
              767,
              777,
              777
            ]
          }
        }
      ],
      "heat_detectors": [
        {
          "extracted_string_or_numeric_value": "Heat Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              528,
              538,
              538,
              528
            ],
            "vertical_y_vertices": [
              257,
              257,
              267,
              267
            ]
          }
        },
        {
          "extracted_string_or_numeric_value": "Heat Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              708,
              718,
              718,
              708
            ],
            "vertical_y_vertices": [
              317,
              317,
              327,
              327
            ]
          }
        },
        {
          "extracted_string_or_numeric_value": "Heat Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              597,
              607,
              607,
              597
            ],
            "vertical_y_vertices": [
              537,
              537,
              547,
              547
            ]
          }
        },
        {
          "extracted_string_or_numeric_value": "Heat Detector",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              368,
              378,
              378,
              368
            ],
            "vertical_y_vertices": [
              697,
              697,
              707,
              707
            ]
          }
        }
      ],
      "extinguishers": null,
      "exit_emergency_lights": [
        {
          "extracted_string_or_numeric_value": "Exit/Emergency Light",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              808,
              818,
              818,
              808
            ],
            "vertical_y_vertices": [
              317,
              317,
              327,
              327
            ]
          }
        }
      ],
      "sprinkler_risers": [
        {
          "extracted_string_or_numeric_value": "Sprinkler Riser",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              368,
              378,
              378,
              368
            ],
            "vertical_y_vertices": [
              717,
              717,
              727,
              727
            ]
          }
        }
      ],
      "inspector_test_valves": [
        {
          "extracted_string_or_numeric_value": "Inspector Test Valve",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              698,
              708,
              708,
              698
            ],
            "vertical_y_vertices": [
              767,
              767,
              777,
              777
            ]
          }
        }
      ],
      "kitchen_systems": [
        {
          "extracted_string_or_numeric_value": "Kitchen System",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              808,
              818,
              818,
              808
            ],
            "vertical_y_vertices": [
              697,
              697,
              707,
              707
            ]
          }
        }
      ],
      "alarm_panels": [
        {
          "extracted_string_or_numeric_value": "Alarm Panel",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [
              388,
              398,
              398,
              388
            ],
            "vertical_y_vertices": [
              717,
              717,
              727,
              727
            ]
          }
        }
      ]
    }
  }
]
```