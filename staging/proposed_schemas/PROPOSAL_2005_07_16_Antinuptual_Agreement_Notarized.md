Here are the Pydantic V2 schema and the corresponding JSON test case as requested.

**BLOCK 1 (Python Pydantic V2):**
```python
from typing import List, Optional, Union
from pydantic import BaseModel, Field, ConfigDict, model_validator

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

class PartyChild(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: Optional[ForensicDataEntity] = None
    age: Optional[ForensicDataEntity] = None

class PartyDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    full_name: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    occupation_or_status: Optional[ForensicDataEntity] = None
    children: Optional[List[PartyChild]] = None
    attorney_name: Optional[ForensicDataEntity] = None
    business_name: Optional[ForensicDataEntity] = None

class Appraisal(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: Optional[ForensicDataEntity] = None
    property_id: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None
    appraiser: Optional[ForensicDataEntity] = None

class HouseholdExpenses(BaseModel):
    model_config = ConfigDict(extra='forbid')
    judy_share_percentage: Optional[ForensicDataEntity] = None
    keith_share_percentage: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_expense_shares(self) -> 'HouseholdExpenses':
        """Ensures household expense shares sum to 100%."""
        if self.judy_share_percentage and self.keith_share_percentage:
            judy_share = self.judy_share_percentage.extracted_string_or_numeric_value
            keith_share = self.keith_share_percentage.extracted_string_or_numeric_value
            
            if not isinstance(judy_share, (int, float)) or not isinstance(keith_share, (int, float)):
                 raise ValueError("Share percentages must be numeric.")

            if not (judy_share + keith_share == 100.0):
                raise ValueError(f"Expense shares must sum to 100. Found: {judy_share + keith_share}")
        return self

class ProvisionUponDeath(BaseModel):
    model_config = ConfigDict(extra='forbid')
    duration_in_years: Optional[ForensicDataEntity] = None
    term_description: Optional[ForensicDataEntity] = None

class EstatePlanning(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provision_if_death_within_15_years: Optional[ProvisionUponDeath] = None
    provision_if_death_after_15_years: Optional[ProvisionUponDeath] = None

class Signature(BaseModel):
    model_config = ConfigDict(extra='forbid')
    party_name: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None

class NotaryBlock(BaseModel):
    model_config = ConfigDict(extra='forbid')
    notary_name: Optional[ForensicDataEntity] = None
    county: Optional[ForensicDataEntity] = None
    state: Optional[ForensicDataEntity] = None
    acknowledged_parties: Optional[List[ForensicDataEntity]] = None

class AntinuptualAgreement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: Optional[ForensicDataEntity] = None
    party_1_details: Optional[PartyDetails] = None
    party_2_details: Optional[PartyDetails] = None
    planned_marriage_date: Optional[ForensicDataEntity] = None
    judy_provided_appraisals: Optional[List[Appraisal]] = None
    keith_provided_appraisals: Optional[List[Appraisal]] = None
    household_expenses: Optional[HouseholdExpenses] = None
    estate_planning_provisions: Optional[EstatePlanning] = None
    signatures: Optional[List[Signature]] = None
    notary_block: Optional[NotaryBlock] = None
    governing_law_state: Optional[ForensicDataEntity] = None

```

**BLOCK 2 (JSON Test Registry):**
```json
[
  {
    "test_identifier": "20050716-kibby-grandy-antenuptial",
    "should_pass": true,
    "taxonomy_lane": "AntinuptualAgreement",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "Antenuptial Agreement",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [392, 584],
          "vertical_y_vertices": [104, 118]
        }
      },
      "party_1_details": {
        "full_name": {
          "extracted_string_or_numeric_value": "Judith A. Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [370, 510],
            "vertical_y_vertices": [241, 252]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Michigan 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 660],
            "vertical_y_vertices": [578, 590]
          }
        },
        "occupation_or_status": {
          "extracted_string_or_numeric_value": "retired",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 370],
            "vertical_y_vertices": [595, 606]
          }
        },
        "children": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Mark",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [410, 450],
                "vertical_y_vertices": [612, 623]
              }
            },
            "age": {
              "extracted_string_or_numeric_value": "31",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [488, 505],
                "vertical_y_vertices": [612, 623]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Michael",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [528, 585],
                "vertical_y_vertices": [612, 623]
              }
            },
            "age": {
              "extracted_string_or_numeric_value": "30",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [623, 640],
                "vertical_y_vertices": [612, 623]
              }
            }
          }
        ],
        "attorney_name": {
          "extracted_string_or_numeric_value": "John Martin",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [360, 455],
            "vertical_y_vertices": [353, 364]
          }
        },
        "business_name": {
          "extracted_string_or_numeric_value": "Kibby Company, L.L.C.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 580],
            "vertical_y_vertices": [835, 846]
          }
        }
      },
      "party_2_details": {
        "full_name": {
          "extracted_string_or_numeric_value": "Keith A Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [535, 665],
            "vertical_y_vertices": [241, 252]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "4316 21 Mile Road, Marion, Michigan 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 660],
            "vertical_y_vertices": [646, 657]
          }
        },
        "occupation_or_status": {
          "extracted_string_or_numeric_value": "Station Mechanic A at Consumers Energy",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 630],
            "vertical_y_vertices": [663, 674]
          }
        },
        "children": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Jody",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [678, 710],
                "vertical_y_vertices": [680, 691]
              }
            },
            "age": {
              "extracted_string_or_numeric_value": "34",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [748, 765],
                "vertical_y_vertices": [680, 691]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Jason",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [218, 260],
                "vertical_y_vertices": [697, 708]
              }
            },
            "age": {
              "extracted_string_or_numeric_value": "31",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [298, 315],
                "vertical_y_vertices": [697, 708]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Amanda",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [338, 395],
                "vertical_y_vertices": [697, 708]
              }
            },
            "age": {
              "extracted_string_or_numeric_value": "29",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [433, 450],
                "vertical_y_vertices": [697, 708]
              }
            }
          }
        ],
        "attorney_name": {
          "extracted_string_or_numeric_value": "Greg Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [390, 505],
            "vertical_y_vertices": [458, 469]
          }
        },
        "business_name": {
          "extracted_string_or_numeric_value": "KG Fishing",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 580],
            "vertical_y_vertices": [250, 261]
          }
        }
      },
      "planned_marriage_date": {
        "extracted_string_or_numeric_value": "July 23, 2005",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [340, 460],
          "vertical_y_vertices": [337, 348]
        }
      },
      "judy_provided_appraisals": [
        {
          "description": {
            "extracted_string_or_numeric_value": "House located at 3291 18 Mile Road, Marion, MI",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 640],
              "vertical_y_vertices": [570, 581]
            }
          },
          "property_id": {
            "extracted_string_or_numeric_value": "#67-10-004-001-00",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 430],
              "vertical_y_vertices": [587, 598]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "June 7, 2005",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [440, 540],
              "vertical_y_vertices": [587, 598]
            }
          },
          "appraiser": {
            "extracted_string_or_numeric_value": "Ted J. Rycenga",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 730],
              "vertical_y_vertices": [587, 598]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Farm 258.5 acres property",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 480],
              "vertical_y_vertices": [640, 651]
            }
          },
          "property_id": {
            "extracted_string_or_numeric_value": "#67-10-004-001-00",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [485, 650],
              "vertical_y_vertices": [640, 651]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "June 7, 2005",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 366],
              "vertical_y_vertices": [657, 668]
            }
          },
          "appraiser": {
            "extracted_string_or_numeric_value": "Ted Rycenga",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 540],
              "vertical_y_vertices": [657, 668]
            }
          }
        }
      ],
      "keith_provided_appraisals": [
        {
          "description": {
            "extracted_string_or_numeric_value": "Home and property located at 4316 21 Mile Road, Marion, MI",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 720],
              "vertical_y_vertices": [298, 309]
            }
          },
          "property_id": {
            "extracted_string_or_numeric_value": "#67-09-017-006-00 and #67-09-017-006-50",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 650],
              "vertical_y_vertices": [315, 326]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "December 23, 2002",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [266, 420],
              "vertical_y_vertices": [332, 343]
            }
          },
          "appraiser": {
            "extracted_string_or_numeric_value": "Ted Rycenga",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 540],
              "vertical_y_vertices": [332, 343]
            }
          }
        }
      ],
      "household_expenses": {
        "judy_share_percentage": {
          "extracted_string_or_numeric_value": 70.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218, 360],
            "vertical_y_vertices": [218, 229]
          }
        },
        "keith_share_percentage": {
          "extracted_string_or_numeric_value": 30.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [410, 550],
            "vertical_y_vertices": [218, 229]
          }
        }
      },
      "estate_planning_provisions": {
        "provision_if_death_within_15_years": {
          "duration_in_years": {
            "extracted_string_or_numeric_value": "2",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 610],
              "vertical_y_vertices": [240, 251]
            }
          },
          "term_description": {
            "extracted_string_or_numeric_value": "use of the home, real estate and property at 3291 18 Mile Road, Marion, Michigan",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [218, 760],
              "vertical_y_vertices": [223, 251]
            }
          }
        },
        "provision_if_death_after_15_years": {
          "term_description": {
            "extracted_string_or_numeric_value": "use of the home, real estate and property at 3291 18 Mile Road, Marion, Michigan for the remainder of his life",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [218, 760],
              "vertical_y_vertices": [310, 350]
            }
          }
        }
      },
      "signatures": [
        {
          "party_name": {
            "extracted_string_or_numeric_value": "Judith A. Kibby",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 320],
              "vertical_y_vertices": [440, 451]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "July 16, 2005",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 350],
              "vertical_y_vertices": [400, 411]
            }
          }
        },
        {
          "party_name": {
            "extracted_string_or_numeric_value": "Keith A. Grandy",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 320],
              "vertical_y_vertices": [510, 521]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "July 16, 2005",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 350],
              "vertical_y_vertices": [470, 481]
            }
          }
        }
      ],
      "notary_block": {
        "notary_name": {
          "extracted_string_or_numeric_value": "Diane Lousbury",
          "optical_extraction_confidence_score": 0.85,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [670, 800],
            "vertical_y_vertices": [420, 431]
          }
        },
        "county": {
          "extracted_string_or_numeric_value": "Osceola",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 750],
            "vertical_y_vertices": [440, 451]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "Michigan",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 670],
            "vertical_y_vertices": [460, 471]
          }
        },
        "acknowledged_parties": [
          {
            "extracted_string_or_numeric_value": "Judy Kibby",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [580, 680],
              "vertical_y_vertices": [480, 491]
            }
          },
          {
            "extracted_string_or_numeric_value": "Keith Grandy",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [690, 790],
              "vertical_y_vertices": [480, 491]
            }
          }
        ]
      },
      "governing_law_state": {
        "extracted_string_or_numeric_value": "Michigan",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [640, 710],
          "vertical_y_vertices": [890, 901]
        }
      }
    }
  }
]
```