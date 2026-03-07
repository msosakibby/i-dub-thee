**BLOCK 1 (Python Pydantic V2):**
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class ChildDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date_of_birth: ForensicDataEntity

class GuardianDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity
    residence: ForensicDataEntity

class WitnessDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    address: ForensicDataEntity
    signature_date: ForensicDataEntity

class PreparerInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    firm_name: ForensicDataEntity
    attorney_name: ForensicDataEntity
    address: ForensicDataEntity
    attorney_bar_number: ForensicDataEntity
    phone_number: ForensicDataEntity
    email: ForensicDataEntity

class NominationOfGuardian(BaseModel):
    """
    Schema for a Nomination of Guardian for Minor Children document.
    """
    model_config = ConfigDict(extra='forbid')

    document_title: ForensicDataEntity
    declarant_name: ForensicDataEntity
    declarant_former_name: Optional[ForensicDataEntity] = None
    children: List[ChildDetail]
    partner_name: ForensicDataEntity
    partner_former_name: Optional[ForensicDataEntity] = None
    partner_residence: ForensicDataEntity
    nominated_guardians: List[GuardianDetail]
    declarant_execution_date: ForensicDataEntity
    declarant_date_of_birth: ForensicDataEntity
    declarant_address: ForensicDataEntity
    witnesses: List[WitnessDetail]
    notary_name: ForensicDataEntity
    notary_subscription_date: ForensicDataEntity
    preparer_info: PreparerInfo

    @model_validator(mode='after')
    def perform_integrity_checks(self) -> 'NominationOfGuardian':
        """
        Performs integrity checks on the document data.
        - No financial data is present for a GAAP checksum.
        - Validates that at least one child is listed.
        - Validates that the number of witnesses is at least two, a common legal requirement.
        """
        if not self.children or len(self.children) < 1:
            raise ValueError("At least one child must be listed in the nomination.")

        if not self.witnesses or len(self.witnesses) < 2:
            raise ValueError("Document must be signed by at least two witnesses.")
            
        return self

```

**BLOCK 2 (JSON Test Registry):**
```json
[
  {
    "test_identifier": "doc_000012_3_complex_variant_01",
    "should_pass": true,
    "taxonomy_lane": "NominationOfGuardian",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "NOMINATION OF GUARDIAN FOR MINOR CHILDREN",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [99, 688, 688, 99],
          "vertical_y_vertices": [99, 99, 135, 135]
        }
      },
      "declarant_name": {
        "extracted_string_or_numeric_value": "Erik Rolando Sosa-Kibby",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [200, 520, 520, 200],
          "vertical_y_vertices": [165, 165, 178, 178]
        }
      },
      "declarant_former_name": {
        "extracted_string_or_numeric_value": "Erik Rolando Sosa",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [535, 718, 718, 535],
          "vertical_y_vertices": [165, 165, 178, 178]
        }
      },
      "children": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Parker Erik Alexander Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 550, 550, 200],
              "vertical_y_vertices": [183, 183, 196, 196]
            }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "May 28, 2006",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [595, 700, 700, 595],
              "vertical_y_vertices": [183, 183, 196, 196]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Cole Mark Santiago Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 550, 550, 200],
              "vertical_y_vertices": [198, 198, 211, 211]
            }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "May 15, 2006",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [595, 700, 700, 595],
              "vertical_y_vertices": [198, 198, 211, 211]
            }
          }
        }
      ],
      "partner_name": {
        "extracted_string_or_numeric_value": "Mark William Sosa-Kibby",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [520, 790, 790, 520],
          "vertical_y_vertices": [750, 750, 763, 763]
        }
      },
      "partner_former_name": {
        "extracted_string_or_numeric_value": "Mark William Kibby",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [202, 440, 440, 202],
          "vertical_y_vertices": [765, 765, 778, 778]
        }
      },
      "partner_residence": {
        "extracted_string_or_numeric_value": "Kenosha, Wisconsin",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 620, 620, 450],
          "vertical_y_vertices": [765, 765, 778, 778]
        }
      },
      "nominated_guardians": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Julie Wilsey",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 340, 340, 240],
              "vertical_y_vertices": [650, 650, 663, 663]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "Mark's cousin",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [165, 265, 265, 165],
              "vertical_y_vertices": [650, 650, 663, 663]
            }
          },
          "residence": {
            "extracted_string_or_numeric_value": "Hudsonville, Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [370, 540, 540, 370],
              "vertical_y_vertices": [650, 650, 663, 663]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Judith Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 350, 350, 240],
              "vertical_y_vertices": [675, 675, 688, 688]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "Mark's mother",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [165, 265, 265, 165],
              "vertical_y_vertices": [675, 675, 688, 688]
            }
          },
          "residence": {
            "extracted_string_or_numeric_value": "Marion, Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [380, 510, 510, 380],
              "vertical_y_vertices": [675, 675, 688, 688]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "JoAnn Weston",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 350, 350, 240],
              "vertical_y_vertices": [700, 700, 713, 713]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "Mark's aunt",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [165, 250, 250, 165],
              "vertical_y_vertices": [700, 700, 713, 713]
            }
          },
          "residence": {
            "extracted_string_or_numeric_value": "Cadillac, Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [380, 520, 520, 380],
              "vertical_y_vertices": [700, 700, 713, 713]
            }
          }
        }
      ],
      "declarant_execution_date": {
        "extracted_string_or_numeric_value": "August 7, 2012",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608, 832, 832, 608],
          "vertical_y_vertices": [650, 650, 685, 685]
        }
      },
      "declarant_date_of_birth": {
        "extracted_string_or_numeric_value": "JAN 25, 1975",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [360, 540, 540, 360],
          "vertical_y_vertices": [710, 710, 735, 735]
        }
      },
      "declarant_address": {
        "extracted_string_or_numeric_value": "15203 74th St Kenosha, WI 53142",
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [200, 790, 790, 200],
          "vertical_y_vertices": [740, 740, 765, 765]
        }
      },
      "witnesses": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Jonathan R. Loye",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 330, 330, 200],
              "vertical_y_vertices": [230, 230, 245, 245]
            }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "October 12",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 320, 320, 200],
              "vertical_y_vertices": [250, 250, 265, 265]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "450 S. Yellowstone Drive, Madison, WI 53719",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 530, 530, 200],
              "vertical_y_vertices": [270, 270, 285, 285]
            }
          },
          "signature_date": {
            "extracted_string_or_numeric_value": "8-7-2012",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [610, 720, 720, 610],
              "vertical_y_vertices": [210, 210, 230, 230]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Cheryl Golden Wallom",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 380, 380, 200],
              "vertical_y_vertices": [350, 350, 365, 365]
            }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "October 31",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 320, 320, 200],
              "vertical_y_vertices": [390, 390, 405, 405]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "450 S. Yellowstone Drive, Madison, WI 53719",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 530, 530, 200],
              "vertical_y_vertices": [410, 410, 425, 425]
            }
          },
          "signature_date": {
            "extracted_string_or_numeric_value": "8/7/12",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [610, 700, 700, 610],
              "vertical_y_vertices": [340, 340, 365, 365]
            }
          }
        }
      ],
      "notary_name": {
        "extracted_string_or_numeric_value": "EMILY DUDAK TAYLOR",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [290, 470, 470, 290],
          "vertical_y_vertices": [470, 470, 500, 500]
        }
      },
      "notary_subscription_date": {
        "extracted_string_or_numeric_value": "8/7/12",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [200, 270, 270, 200],
          "vertical_y_vertices": [500, 500, 520, 520]
        }
      },
      "preparer_info": {
        "firm_name": {
          "extracted_string_or_numeric_value": "the LAW CENTER for CHILDREN & FAMILIES",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 800, 800, 660],
            "vertical_y_vertices": [660, 660, 730, 730]
          }
        },
        "attorney_name": {
          "extracted_string_or_numeric_value": "Emily Dudak Taylor",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 800, 800, 660],
            "vertical_y_vertices": [780, 780, 790, 790]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "450 S. YELLOWSTONE DR. MADISON, WI 53719-1068",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 800, 800, 660],
            "vertical_y_vertices": [740, 740, 760, 760]
          }
        },
        "attorney_bar_number": {
          "extracted_string_or_numeric_value": "1050724",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 800, 800, 660],
            "vertical_y_vertices": [795, 795, 805, 805]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "(608) 821-8214",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 800, 800, 660],
            "vertical_y_vertices": [810, 810, 820, 820]
          }
        },
        "email": {
          "extracted_string_or_numeric_value": "edudaktaylor@law4kids.com",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 800, 800, 660],
            "vertical_y_vertices": [825, 825, 835, 835]
          }
        }
      }
    }
  }
]
```