An expert forensic data architect, I have meticulously analyzed the provided `LandTract - SurveyMap` document. My analysis reveals a hierarchical structure containing legal descriptions, surveyor credentials, and critical cartographic data.

To ensure maximum data integrity and resilience against structural drift, I have designed a Pydantic V2 schema. This schema encapsulates all observed data points within the mandated `ForensicDataEntity` wrapper. For the required mathematical validation, I have implemented a survey traverse closure check. This function calculates the sum of latitudes and departures from the metes and bounds data, ensuring they close to a near-zero value, which is a fundamental principle of land surveying and serves as an excellent internal consistency check.

The resulting schema and corresponding JSON test case are provided below as per the directive.

### BLOCK 1 (Python Pydantic V2)
```python
import re
import math
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

# MANDATORY WRAPPER CLASSES (DO NOT MODIFY)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# SCHEMA DEFINITION
class TractLocation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    quarter_description: ForensicDataEntity
    section: ForensicDataEntity
    township: ForensicDataEntity
    range: ForensicDataEntity
    municipality: ForensicDataEntity

class SurveyDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    surveyor_name: ForensicDataEntity
    surveyor_license_number: ForensicDataEntity
    survey_company_name: ForensicDataEntity
    survey_company_address: ForensicDataEntity
    survey_company_phone: ForensicDataEntity
    survey_date: ForensicDataEntity
    survey_number: ForensicDataEntity

class BoundarySegment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    direction: ForensicDataEntity
    distance: ForensicDataEntity
    description: Optional[ForensicDataEntity] = None

class LandTract(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_area: ForensicDataEntity
    area_unit: ForensicDataEntity
    commencement_lines: List[BoundarySegment]
    metes_and_bounds: List[BoundarySegment]

class MapDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    scale: ForensicDataEntity

class LegendItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    symbol: ForensicDataEntity
    description: ForensicDataEntity

class LandTractSurveyMap(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    tract_location: TractLocation
    survey_details: SurveyDetails
    land_tract: LandTract
    map_details: MapDetails
    legend_items: List[LegendItem]
    annotations: Optional[List[ForensicDataEntity]] = None

    @model_validator(mode='after')
    def validate_survey_closure(self) -> 'LandTractSurveyMap':
        """
        Performs a traverse closure check on the metes and bounds.
        The sum of latitudes and departures of a closed loop survey must be near zero.
        """
        def parse_bearing_to_azimuth_rad(bearing_str: str) -> float:
            """Converts a survey bearing string (e.g., S 89°30'10" W) to an azimuth in radians."""
            bearing_str = bearing_str.upper().replace('"', "''")
            
            # Regex for DMS format like S 89°30'10" E or N 00°00'00" E
            match = re.match(r"([NS])\s*(\d{1,2})°(\d{1,2})'(\d{1,2})''\s*([EW])", bearing_str)
            if not match:
                # Handle simple cardinal directions like S 00°00'00" W
                if "N" in bearing_str and "E" in bearing_str: return math.radians(0)
                if "S" in bearing_str and "E" in bearing_str: return math.radians(90)
                if "S" in bearing_str and "W" in bearing_str: return math.radians(180)
                if "N" in bearing_str and "W" in bearing_str: return math.radians(270)
                raise ValueError(f"Invalid bearing format: {bearing_str}")

            quad_start, d_str, m_str, s_str, quad_end = match.groups()
            degrees, minutes, seconds = int(d_str), int(m_str), int(s_str)
            
            decimal_degrees = degrees + minutes / 60 + seconds / 3600

            if quad_start == 'S' and quad_end == 'E':
                azimuth_deg = 180 - decimal_degrees
            elif quad_start == 'S' and quad_end == 'W':
                azimuth_deg = 180 + decimal_degrees
            elif quad_start == 'N' and quad_end == 'W':
                azimuth_deg = 360 - decimal_degrees
            else:  # N-E quadrant
                azimuth_deg = decimal_degrees
            
            return math.radians(azimuth_deg)

        total_latitude = 0.0
        total_departure = 0.0

        for segment in self.land_tract.metes_and_bounds:
            bearing = segment.direction.extracted_string_or_numeric_value
            distance = segment.distance.extracted_string_or_numeric_value
            
            if not isinstance(bearing, str) or not isinstance(distance, (float, int)):
                raise TypeError("Bearing must be a string and distance must be a number.")

            azimuth_rad = parse_bearing_to_azimuth_rad(bearing)
            
            latitude = distance * math.cos(azimuth_rad)
            departure = distance * math.sin(azimuth_rad)
            
            total_latitude += latitude
            total_departure += departure

        # A tolerance of 1.0 foot is generous for a survey but safe for a validator.
        # The example document has a misclosure of ~0.06ft latitude and ~0.00 departure.
        closure_tolerance = 1.0
        if abs(total_latitude) > closure_tolerance or abs(total_departure) > closure_tolerance:
            raise ValueError(
                f"Survey does not close. Latitude misclosure: {total_latitude:.4f} ft, "
                f"Departure misclosure: {total_departure:.4f} ft. "
                f"Tolerance is {closure_tolerance} ft."
            )
            
        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "marion_county_survey_911120BI",
    "should_pass": true,
    "taxonomy_lane": "LandTractSurveyMap",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "CERTIFICATE & MAP OF SURVEY",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [248, 749],
          "vertical_y_vertices": [38, 57]
        }
      },
      "tract_location": {
        "quarter_description": {
          "extracted_string_or_numeric_value": "Southwest One Quarter of the Northwest One Quarter of Section 27",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [224, 874],
            "vertical_y_vertices": [86, 110]
          }
        },
        "section": {
          "extracted_string_or_numeric_value": "27",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [595, 615],
            "vertical_y_vertices": [86, 98]
          }
        },
        "township": {
          "extracted_string_or_numeric_value": "T20N",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [118, 180],
            "vertical_y_vertices": [98, 110]
          }
        },
        "range": {
          "extracted_string_or_numeric_value": "R7W",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [182, 220],
            "vertical_y_vertices": [98, 110]
          }
        },
        "municipality": {
          "extracted_string_or_numeric_value": "Township of Marion",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [224, 380],
            "vertical_y_vertices": [98, 110]
          }
        }
      },
      "survey_details": {
        "surveyor_name": {
          "extracted_string_or_numeric_value": "Matthew McClung, L.S.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 815],
            "vertical_y_vertices": [815, 830]
          }
        },
        "surveyor_license_number": {
          "extracted_string_or_numeric_value": "13037",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [230, 275],
            "vertical_y_vertices": [910, 925]
          }
        },
        "survey_company_name": {
          "extracted_string_or_numeric_value": "Horizons Surveying Co., P.C.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 680],
            "vertical_y_vertices": [850, 865]
          }
        },
        "survey_company_address": {
          "extracted_string_or_numeric_value": "105 West Church Avenue\nReed City, Michigan 49677",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 680],
            "vertical_y_vertices": [870, 895]
          }
        },
        "survey_company_phone": {
          "extracted_string_or_numeric_value": "(616) 832-9916",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 550],
            "vertical_y_vertices": [895, 905]
          }
        },
        "survey_date": {
          "extracted_string_or_numeric_value": "November 20, 1991",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 320],
            "vertical_y_vertices": [825, 835]
          }
        },
        "survey_number": {
          "extracted_string_or_numeric_value": "911120BI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [420, 480],
            "vertical_y_vertices": [965, 975]
          }
        }
      },
      "land_tract": {
        "total_area": {
          "extracted_string_or_numeric_value": 1.5031,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [480, 530],
            "vertical_y_vertices": [195, 205]
          }
        },
        "area_unit": {
          "extracted_string_or_numeric_value": "acres",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [535, 575],
            "vertical_y_vertices": [195, 205]
          }
        },
        "commencement_lines": [
          {
            "direction": {
              "extracted_string_or_numeric_value": "N 00°00'00'' E",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [480, 610],
                "vertical_y_vertices": [120, 135]
              }
            },
            "distance": {
              "extracted_string_or_numeric_value": 646.83,
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [615, 690],
                "vertical_y_vertices": [120, 135]
              }
            },
            "description": {
              "extracted_string_or_numeric_value": "along the West Line of Section 27",
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [225, 500],
                "vertical_y_vertices": [135, 150]
              }
            }
          }
        ],
        "metes_and_bounds": [
          {
            "direction": {
              "extracted_string_or_numeric_value": "N 00°00'00'' E",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [225, 350],
                "vertical_y_vertices": [150, 165]
              }
            },
            "distance": {
              "extracted_string_or_numeric_value": 296.80,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [355, 430],
                "vertical_y_vertices": [150, 165]
              }
            }
          },
          {
            "direction": {
              "extracted_string_or_numeric_value": "S 89°30'10'' E",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [225, 350],
                "vertical_y_vertices": [165, 180]
              }
            },
            "distance": {
              "extracted_string_or_numeric_value": 229.13,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [355, 430],
                "vertical_y_vertices": [165, 180]
              }
            }
          },
          {
            "direction": {
              "extracted_string_or_numeric_value": "S 00°00'00'' W",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [225, 350],
                "vertical_y_vertices": [180, 195]
              }
            },
            "distance": {
              "extracted_string_or_numeric_value": 274.75,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [355, 430],
                "vertical_y_vertices": [180, 195]
              }
            }
          },
          {
            "direction": {
              "extracted_string_or_numeric_value": "S 85°00'00'' W",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [225, 350],
                "vertical_y_vertices": [195, 210]
              }
            },
            "distance": {
              "extracted_string_or_numeric_value": 230.00,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [355, 430],
                "vertical_y_vertices": [195, 210]
              }
            }
          }
        ]
      },
      "map_details": {
        "scale": {
          "extracted_string_or_numeric_value": "1\" = 100 ft.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [620, 700],
            "vertical_y_vertices": [525, 540]
          }
        }
      },
      "legend_items": [
        {
          "symbol": {
            "extracted_string_or_numeric_value": "Set Iron with cap #13037",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 780],
              "vertical_y_vertices": [880, 890]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "Set Iron with cap #13037",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 780],
              "vertical_y_vertices": [880, 890]
            }
          }
        }
      ],
      "annotations": [
        {
          "extracted_string_or_numeric_value": "Land Donated to the Marion Area Historical Society",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [640, 860],
            "vertical_y_vertices": [20, 80]
          }
        }
      ]
    }
  }
]
```