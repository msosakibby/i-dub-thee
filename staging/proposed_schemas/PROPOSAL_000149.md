An exhaustive forensic analysis of the provided document, a product manual for a glass break detector, has been conducted. The resulting schema is designed for maximum resilience and logical data grouping, encapsulating all textual and structural elements observed.

### BLOCK 1: Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon area for a given data entity on the source document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class InstallationGuidelines(BaseModel):
    """Contains instructions for setting up and mounting the device."""
    model_config = ConfigDict(extra='forbid')
    setup_instructions: List[ForensicDataEntity]
    mounting_instructions: List[ForensicDataEntity]

class TestingInfo(BaseModel):
    """Contains instructions and notes related to testing the device."""
    model_config = ConfigDict(extra='forbid')
    walk_test_instructions: List[ForensicDataEntity]
    rf_test_instructions: ForensicDataEntity
    testing_note: ForensicDataEntity

class GlassType(BaseModel):
    """Defines a single row in the glass type and thickness compatibility table."""
    model_config = ConfigDict(extra='forbid')
    type: ForensicDataEntity
    thickness: ForensicDataEntity

class GlassTypeThicknessInfo(BaseModel):
    """Contains information on compatible glass types and thicknesses."""
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    glass_types: List[GlassType]
    footnote: Optional[ForensicDataEntity] = None

class BatteryInfo(BaseModel):
    """Contains all information related to battery installation, replacement, and safety."""
    model_config = ConfigDict(extra='forbid')
    installation_instructions: ForensicDataEntity
    warning: ForensicDataEntity
    disposal_instructions: ForensicDataEntity
    safety_warning: ForensicDataEntity
    california_perchlorate_warning: Optional[ForensicDataEntity] = None

class Specifications(BaseModel):
    """A detailed list of the device's technical specifications."""
    model_config = ConfigDict(extra='forbid')
    wireless_signal_range: ForensicDataEntity
    code_outputs: ForensicDataEntity
    transmitter_frequency: ForensicDataEntity
    transmitter_frequency_tolerance: ForensicDataEntity
    transmitter_bandwidth: ForensicDataEntity
    modulation_type: ForensicDataEntity
    unique_id_codes: ForensicDataEntity
    supervisory_interval: ForensicDataEntity
    peak_field_strength: ForensicDataEntity
    sensor_type: ForensicDataEntity
    mounting_height: ForensicDataEntity
    sensor_range: ForensicDataEntity
    max_horizontal_sensing_angle: ForensicDataEntity
    dimensions: ForensicDataEntity
    weight: ForensicDataEntity
    housing_material: ForensicDataEntity
    color: ForensicDataEntity
    operating_temperature: ForensicDataEntity
    relative_humidity: ForensicDataEntity
    battery_type: ForensicDataEntity
    regulatory_listings: ForensicDataEntity
    approved_glass_break_simulator: ForensicDataEntity
    warranty: ForensicDataEntity
    included_accessories: ForensicDataEntity

class FCCCompliance(BaseModel):
    """Contains FCC and Industry Canada compliance statements and identifiers."""
    model_config = ConfigDict(extra='forbid')
    compliance_statement: ForensicDataEntity
    operation_conditions: List[ForensicDataEntity]
    modification_note: ForensicDataEntity
    fcc_id: ForensicDataEntity
    industry_canada_id: ForensicDataEntity

class Footer(BaseModel):
    """Contains all footer information such as company details, support, and document revision."""
    model_config = ConfigDict(extra='forbid')
    company_name: ForensicDataEntity
    copyright_notice: ForensicDataEntity
    technical_support_phone: ForensicDataEntity
    company_website: ForensicDataEntity
    document_id: ForensicDataEntity
    certification_marks: List[ForensicDataEntity]
    warranty_compliance_info_url: ForensicDataEntity

class Document_000149(BaseModel):
    """
    A schema for the 2GIG-GB1-345 Glass Break Detector instruction manual.
    """
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    model_number: ForensicDataEntity
    product_description: ForensicDataEntity
    installation_guidelines: InstallationGuidelines
    testing_info: TestingInfo
    glass_type_thickness_info: GlassTypeThicknessInfo
    battery_info: BatteryInfo
    specifications: Specifications
    fcc_compliance: FCCCompliance
    footer: Footer

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'Document_000149':
        """
        No financial data or summations are present in this document class.
        This validator is included to meet the structural requirements of the prompt,
        but no checksum calculations are applicable.
        """
        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "golden_test_case_for_000149",
    "should_pass": true,
    "taxonomy_lane": "Document_000149",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "Glass Break Detector",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [26, 199],
          "vertical_y_vertices": [141, 154]
        }
      },
      "model_number": {
        "extracted_string_or_numeric_value": "2GIG-GB1-345",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [210, 300],
          "vertical_y_vertices": [141, 154]
        }
      },
      "product_description": {
        "extracted_string_or_numeric_value": "The 2GIG-GB1-345 Glass Break Detector is a fully supervised, tamper-protected, ceiling- or wall-mounted unit with 15 ft. maximum detection range, 360° maximum horizontal sensing angle, and dual-stage glass break detection.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [26, 488],
          "vertical_y_vertices": [181, 238]
        }
      },
      "installation_guidelines": {
        "setup_instructions": [
          {
            "extracted_string_or_numeric_value": "1. Hold the 2GIG-GB1-345 Glass Break Detector unit upside down and twist the base counter clockwise to remove it.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [279, 310]
            }
          },
          {
            "extracted_string_or_numeric_value": "2. Install recommended batteries making sure to observe the correct polarity.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [312, 323]
            }
          },
          {
            "extracted_string_or_numeric_value": "3. Wait 5 seconds for the power up delay.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [325, 336]
            }
          },
          {
            "extracted_string_or_numeric_value": "4. Enter the programming mode for a wireless device on the 2GIG alarm control panel.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [338, 349]
            }
          },
          {
            "extracted_string_or_numeric_value": "5. Enroll the Glass Break Detector by pressing and holding the tamper switch for 2 seconds (see Figure 4).",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [351, 374]
            }
          }
        ],
        "mounting_instructions": [
          {
            "extracted_string_or_numeric_value": "1. Place the Glass Break Detector base on the opposite wall or adjacent wall to the window being protected.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [390, 421]
            }
          },
          {
            "extracted_string_or_numeric_value": "2. Affix the base to the desired location utilizing the 3 long mounting screws with anchors that are supplied. NOTE: For wall mounting the test button should be oriented down nearest the floor.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [423, 467]
            }
          },
          {
            "extracted_string_or_numeric_value": "3. When attaching the detector to the base, match the alignment marks and twist clockwise. If batteries are not present, the red tabs must be held away from the detector.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [469, 513]
            }
          }
        ]
      },
      "testing_info": {
        "walk_test_instructions": [
          {
            "extracted_string_or_numeric_value": "1. Push the test button for 2 seconds and then release it. The red LED will light while the button is pressed. The green LED will blink once to indicate that the unit is in auto test mode for 90 seconds (see Figure 1).",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [550, 594]
            }
          },
          {
            "extracted_string_or_numeric_value": "2. Activate a glass break simulator in the area of the window or windows that you are attempting to protect with the glass break detector. The Glass Break Detector should first acknowledge the detection of a thud sound by illuminating the green LED and then illuminate the red LED when the unit detects the crash portion of the glass breaking sound (see Figure 1).",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [26, 488],
              "vertical_y_vertices": [596, 663]
            }
          }
        ],
        "rf_test_instructions": {
          "extracted_string_or_numeric_value": "Push and hold the test button for 5 seconds and then release it. The red LED will light while the button is pressed. The green LED will blink twice to indicate that the unit is in RF test mode for 90 seconds (see Figure 1).",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [26, 488],
            "vertical_y_vertices": [675, 708]
          }
        },
        "testing_note": {
          "extracted_string_or_numeric_value": "Note: It is recommended that a system test be performed per the Operation & User's Guide at least once a year.",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [26, 488],
            "vertical_y_vertices": [719, 730]
          }
        }
      },
      "glass_type_thickness_info": {
        "description": {
          "extracted_string_or_numeric_value": "Minimum size for all glass types is 11\" x 11\" (28 cm x 28 cm) square; glass must be framed in the wall of the room or mounted in a barrier of 36\" (.9 m) minimum width.",
          "optical_extraction_confidence_score": 0.93,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [26, 488],
            "vertical_y_vertices": [752, 783]
          }
        },
        "glass_types": [
          {
            "type": {
              "extracted_string_or_numeric_value": "Plate",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [26, 100],
                "vertical_y_vertices": [800, 810]
              }
            },
            "thickness": {
              "extracted_string_or_numeric_value": "1/8 in. to 1/4 in. (3.2 mm to 6.4 mm)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 488],
                "vertical_y_vertices": [800, 810]
              }
            }
          },
          {
            "type": {
              "extracted_string_or_numeric_value": "Tempered",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [26, 100],
                "vertical_y_vertices": [812, 822]
              }
            },
            "thickness": {
              "extracted_string_or_numeric_value": "1/8 in. to 1/4 in. (3.2 mm to 6.4 mm)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 488],
                "vertical_y_vertices": [812, 822]
              }
            }
          },
          {
            "type": {
              "extracted_string_or_numeric_value": "Sealed Insulating+",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [26, 100],
                "vertical_y_vertices": [824, 834]
              }
            },
            "thickness": {
              "extracted_string_or_numeric_value": "1/8 in. to 1/4 in. (3.2 mm to 6.4 mm)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 488],
                "vertical_y_vertices": [824, 834]
              }
            }
          }
        ],
        "footnote": {
          "extracted_string_or_numeric_value": "+ Sealed insulating glass types are protected only if both plates of glass are broken.",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [26, 488],
            "vertical_y_vertices": [836, 846]
          }
        }
      },
      "battery_info": {
        "installation_instructions": {
          "extracted_string_or_numeric_value": "Remove the cover by twisting counterclockwise. Use only the recommended replacement batteries (see Specifications). Be sure to observe the polarity.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [141, 164]
          }
        },
        "warning": {
          "extracted_string_or_numeric_value": "WARNING! The polarity of the battery must be observed, as shown (See Figure 4). Improper handling of lithium batteries may result in heat generation, explosion or fire, which may lead to personal injuries. Replace only with the same or equivalent type of battery as recommended by the manufacturer. (see Specifications)",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [166, 223]
          }
        },
        "disposal_instructions": {
          "extracted_string_or_numeric_value": "Batteries must not be recharged, disassembled or disposed of in fire. Disposal of used batteries must be made in accordance with the waste recovery and recycling regulations in your area.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [225, 258]
          }
        },
        "safety_warning": {
          "extracted_string_or_numeric_value": "Keep away from small children. If batteries are swallowed, promptly see a doctor.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [260, 271]
          }
        },
        "california_perchlorate_warning": {
          "extracted_string_or_numeric_value": "California Only: This Perchlorate warning applies only to Manganese Dioxide Lithium cells sold or distributed ONLY in California, USA. Perchlorate Material-special handling may apply. See www.dtsc.ca.gov/hazardouswaste/perchlorate.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [273, 317]
          }
        }
      },
      "specifications": {
        "wireless_signal_range": {
          "extracted_string_or_numeric_value": "300 ft., open air, with 2GIG Wireless Alarm Control Panel",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [340, 350]
          }
        },
        "code_outputs": {
          "extracted_string_or_numeric_value": "Alarm; Alarm Restore; Tamper; Tamper Restore; Supervisory; Low Battery",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [352, 362]
          }
        },
        "transmitter_frequency": {
          "extracted_string_or_numeric_value": "345.000 MHz (crystal controlled)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [364, 374]
          }
        },
        "transmitter_frequency_tolerance": {
          "extracted_string_or_numeric_value": "± 15 kHz",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [376, 386]
          }
        },
        "transmitter_bandwidth": {
          "extracted_string_or_numeric_value": "24 kHz",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [388, 398]
          }
        },
        "modulation_type": {
          "extracted_string_or_numeric_value": "Amplitude Shift Keying-On/Off Keying (ASK-OOK)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [400, 410]
          }
        },
        "unique_id_codes": {
          "extracted_string_or_numeric_value": "Over one (1) million different code combinations",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [412, 422]
          }
        },
        "supervisory_interval": {
          "extracted_string_or_numeric_value": "70 minutes",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [424, 434]
          }
        },
        "peak_field_strength": {
          "extracted_string_or_numeric_value": "Typical 50,000 uV/m at 3m",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [436, 446]
          }
        },
        "sensor_type": {
          "extracted_string_or_numeric_value": "Single microphone, dual stage thud, and crash",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [448, 458]
          }
        },
        "mounting_height": {
          "extracted_string_or_numeric_value": "7 ft. (2.13 m) Minimum to 10 ft. (3.05 m) Maximum",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [460, 470]
          }
        },
        "sensor_range": {
          "extracted_string_or_numeric_value": "15 ft. (4.57 m)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [472, 482]
          }
        },
        "max_horizontal_sensing_angle": {
          "extracted_string_or_numeric_value": "360° for ceiling mount or 180° for wall mount",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [484, 494]
          }
        },
        "dimensions": {
          "extracted_string_or_numeric_value": "4.55 x 1.9 in. (11.56 x 4.83 cm)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [496, 506]
          }
        },
        "weight": {
          "extracted_string_or_numeric_value": "5.1 oz. (144.6 g)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [508, 518]
          }
        },
        "housing_material": {
          "extracted_string_or_numeric_value": "ABS plastic",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [520, 530]
          }
        },
        "color": {
          "extracted_string_or_numeric_value": "White",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [532, 542]
          }
        },
        "operating_temperature": {
          "extracted_string_or_numeric_value": "32° to 120°F (0° to 49°C)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [544, 554]
          }
        },
        "relative_humidity": {
          "extracted_string_or_numeric_value": "5-95% Non-Condensing",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [556, 566]
          }
        },
        "battery_type": {
          "extracted_string_or_numeric_value": "Two (2) Panasonic CR123A, or equivalent Lithium batteries",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [568, 578]
          }
        },
        "regulatory_listings": {
          "extracted_string_or_numeric_value": "ETL, FCC Part 15, Industry Canada",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [580, 590]
          }
        },
        "approved_glass_break_simulator": {
          "extracted_string_or_numeric_value": "Intellisense FG-701",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [592, 602]
          }
        },
        "warranty": {
          "extracted_string_or_numeric_value": "Two (2) years",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [604, 614]
          }
        },
        "included_accessories": {
          "extracted_string_or_numeric_value": "Three (3) Phillip's head screws, three (3) plastic wall anchors",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [616, 626]
          }
        }
      },
      "fcc_compliance": {
        "compliance_statement": {
          "extracted_string_or_numeric_value": "This device complies with FCC Rules and Regulations as Part 15 devices, as well as Industry Canada Rules and Regulations.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [648, 671]
          }
        },
        "operation_conditions": [
          {
            "extracted_string_or_numeric_value": "1. This device may not cause harmful interference.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [526, 988],
              "vertical_y_vertices": [683, 693]
            }
          },
          {
            "extracted_string_or_numeric_value": "2. This device must accept any interference received, including interference that may cause undesired operation.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [526, 988],
              "vertical_y_vertices": [695, 718]
            }
          }
        ],
        "modification_note": {
          "extracted_string_or_numeric_value": "Note: Changes or modifications to the device may void FCC compliance.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [720, 730]
          }
        },
        "fcc_id": {
          "extracted_string_or_numeric_value": "WDQ-GB1345",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 650],
            "vertical_y_vertices": [732, 742]
          }
        },
        "industry_canada_id": {
          "extracted_string_or_numeric_value": "7794A-GB1345",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 650],
            "vertical_y_vertices": [744, 754]
          }
        }
      },
      "footer": {
        "company_name": {
          "extracted_string_or_numeric_value": "2gig technologies",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 790],
            "vertical_y_vertices": [810, 825]
          }
        },
        "copyright_notice": {
          "extracted_string_or_numeric_value": "©2009 2gig Technologies Inc. All Rights Reserved",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 790],
            "vertical_y_vertices": [830, 840]
          }
        },
        "technical_support_phone": {
          "extracted_string_or_numeric_value": "1-866-670-1591",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [880, 988],
            "vertical_y_vertices": [810, 820]
          }
        },
        "company_website": {
          "extracted_string_or_numeric_value": "www.2gig.com",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [880, 988],
            "vertical_y_vertices": [822, 832]
          }
        },
        "document_id": {
          "extracted_string_or_numeric_value": "187-0721 Rev. B",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [880, 988],
            "vertical_y_vertices": [840, 850]
          }
        },
        "certification_marks": [
          {
            "extracted_string_or_numeric_value": "ETL US LISTED",
            "optical_extraction_confidence_score": 0.9,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [920, 980],
              "vertical_y_vertices": [740, 790]
            }
          }
        ],
        "warranty_compliance_info_url": {
          "extracted_string_or_numeric_value": "For more warranty and compliance information, visit our website (www.2gig.com).",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [526, 988],
            "vertical_y_vertices": [766, 776]
          }
        }
      }
    }
  }
]
```