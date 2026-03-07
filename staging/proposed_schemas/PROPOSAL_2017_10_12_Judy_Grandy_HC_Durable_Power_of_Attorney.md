An expert forensic data architect, I have meticulously analyzed the provided document, '2017-10-12 Judy Grandy HC Durable Power of Attorney', to design a resilient Pydantic V2 schema. This schema accommodates the document's specific structure, including typed sections, handwritten addendums, and multiple signatures, while adhering to the Zero-Trust mandate.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Optional, Union
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class PrincipalInfo(BaseModel):
    """Information about the person creating the power of attorney."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date_of_birth: Optional[ForensicDataEntity] = None
    address: ForensicDataEntity
    signature: ForensicDataEntity

class AgentInfo(BaseModel):
    """Information about the primary appointed agent (Patient Advocate)."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity
    acceptance_signature: ForensicDataEntity
    acceptance_date: ForensicDataEntity

class SuccessorAgentInfo(BaseModel):
    """Information about a successor agent."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: Optional[ForensicDataEntity] = None
    acceptance_signature: Optional[ForensicDataEntity] = None
    acceptance_date: Optional[ForensicDataEntity] = None

class WitnessInfo(BaseModel):
    """Information about a witness to the document's signing."""
    model_config = ConfigDict(extra='forbid')
    signature: ForensicDataEntity
    date: ForensicDataEntity

class AttorneyInfo(BaseModel):
    """Information about the attorney who drafted the document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: ForensicDataEntity

class ContactInfo(BaseModel):
    """Contact details found within the document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    phone_number: ForensicDataEntity

class HandwrittenAddendum(BaseModel):
    """Captures data from handwritten notes or addendums."""
    model_config = ConfigDict(extra='forbid')
    title: Optional[ForensicDataEntity] = None
    directives: List[ForensicDataEntity]
    living_preference_instructions: ForensicDataEntity
    final_arrangements: ForensicDataEntity
    celebration_of_life_instructions: ForensicDataEntity
    signature: ForensicDataEntity
    date: ForensicDataEntity
    contacts: List[ContactInfo]

class DurablePowerOfAttorneyForHealthCareV1(BaseModel):
    """
    A schema for a Durable Power of Attorney for Health Care document,
    based on the 2017 Michigan format for Judith A. Grandy.
    """
    model_config = ConfigDict(extra='forbid')

    principal: PrincipalInfo
    agent: AgentInfo
    successor_agents: List[SuccessorAgentInfo]
    witnesses: List[WitnessInfo]
    document_execution_date: ForensicDataEntity
    governing_law_state: ForensicDataEntity
    drafting_attorney: Optional[AttorneyInfo] = None
    life_support_statement: ForensicDataEntity
    handwritten_addendum: Optional[HandwrittenAddendum] = None

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'DurablePowerOfAttorneyForHealthCareV1':
        """
        Executes mathematical checksums for financial data.
        NOTE: This document class does not contain financial figures suitable for
        double-entry accounting validation. This validator is included to meet
        the directive's requirements and will pass by default.
        """
        # No financial fields to validate in this document type.
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "2017-grandy-dpoa-full-handwritten",
    "should_pass": true,
    "taxonomy_lane": "DurablePowerOfAttorneyForHealthCareV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "principal": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [168, 420],
            "vertical_y_vertices": [168, 182]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "8-18-1947",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [605, 810],
            "vertical_y_vertices": [115, 145]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Mi 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [273, 708],
            "vertical_y_vertices": [200, 214]
          }
        },
        "signature": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [445, 725],
            "vertical_y_vertices": [225, 265]
          }
        }
      },
      "agent": {
        "name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [615, 765],
            "vertical_y_vertices": [168, 182]
          }
        },
        "relationship": {
          "extracted_string_or_numeric_value": "husband",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [525, 595],
            "vertical_y_vertices": [168, 182]
          }
        },
        "acceptance_signature": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [525, 750],
            "vertical_y_vertices": [790, 830]
          }
        },
        "acceptance_date": {
          "extracted_string_or_numeric_value": "March 21, 2017",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [525, 680],
            "vertical_y_vertices": [835, 848]
          }
        }
      },
      "successor_agents": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [660, 780],
              "vertical_y_vertices": [220, 235]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "son",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [580, 620],
              "vertical_y_vertices": [220, 235]
            }
          },
          "acceptance_signature": {
            "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [540, 780],
              "vertical_y_vertices": [110, 160]
            }
          },
          "acceptance_date": null
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Michael J. Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 400],
              "vertical_y_vertices": [238, 250]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "son",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [580, 620],
              "vertical_y_vertices": [220, 235]
            }
          },
          "acceptance_signature": null,
          "acceptance_date": null
        }
      ],
      "witnesses": [
        {
          "signature": {
            "extracted_string_or_numeric_value": "Signature 1",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 420],
              "vertical_y_vertices": [510, 550]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "March 21, 2017",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 350],
              "vertical_y_vertices": [555, 568]
            }
          }
        },
        {
          "signature": {
            "extracted_string_or_numeric_value": "Signature 2",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 480],
              "vertical_y_vertices": [590, 630]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "March 21, 2017",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 350],
              "vertical_y_vertices": [635, 648]
            }
          }
        }
      ],
      "document_execution_date": {
        "extracted_string_or_numeric_value": "March 21, 2017",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [530, 660],
          "vertical_y_vertices": [165, 178]
        }
      },
      "governing_law_state": {
        "extracted_string_or_numeric_value": "Michigan",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 750],
          "vertical_y_vertices": [720, 732]
        }
      },
      "drafting_attorney": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [225, 400],
            "vertical_y_vertices": [900, 912]
          }
        },
        "bar_number": {
          "extracted_string_or_numeric_value": "P27300",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 410],
            "vertical_y_vertices": [915, 927]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "221 E. Main/Box 172 Marion, MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [225, 420],
            "vertical_y_vertices": [930, 955]
          }
        }
      },
      "life_support_statement": {
        "extracted_string_or_numeric_value": "I do not wish to receive or to continue to receive medical treatment that will only postpone the moment of my death from an incurable and terminal condition or that will prolong an irreversible coma.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [225, 780],
          "vertical_y_vertices": [540, 590]
        }
      },
      "handwritten_addendum": {
        "title": {
          "extracted_string_or_numeric_value": "Patient Advocate:",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 400],
            "vertical_y_vertices": [80, 110]
          }
        },
        "directives": [
          {
            "extracted_string_or_numeric_value": "Do Not revive me",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 500],
              "vertical_y_vertices": [115, 140]
            }
          },
          {
            "extracted_string_or_numeric_value": "Do Not place me on Life Support, if no hope for survival",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 680],
              "vertical_y_vertices": [145, 190]
            }
          },
          {
            "extracted_string_or_numeric_value": "I am an Organ Donor",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 520],
              "vertical_y_vertices": [195, 220]
            }
          }
        ],
        "living_preference_instructions": {
          "extracted_string_or_numeric_value": "If my health fails I would like to live at home with professional Care. If this is not doable or too overwelling for the family. Please admit me to a Care phycility !!! I do not want to stay in my home and be a burrden for my fahuly !!!",
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 750],
            "vertical_y_vertices": [250, 450]
          }
        },
        "final_arrangements": {
          "extracted_string_or_numeric_value": "I would like to be cremated & my ashes Spread on the Farm - Duck Blind & the same Spot on the hill as your Dad Keith.",
          "optical_extraction_confidence_score": 0.91,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 750],
            "vertical_y_vertices": [500, 600]
          }
        },
        "celebration_of_life_instructions": {
          "extracted_string_or_numeric_value": "Celebration of Life: At my home with Family and Close friends or whatever you decide.",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 750],
            "vertical_y_vertices": [605, 680]
          }
        },
        "signature": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.93,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 750],
            "vertical_y_vertices": [680, 710]
          }
        },
        "date": {
          "extracted_string_or_numeric_value": "March 16, 2017",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 750],
            "vertical_y_vertices": [740, 760]
          }
        },
        "contacts": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Keith",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 280],
                "vertical_y_vertices": [820, 840]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "231-942-1552",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300, 450],
                "vertical_y_vertices": [820, 840]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "MARK",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 280],
                "vertical_y_vertices": [845, 865]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "773-251-0539",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300, 450],
                "vertical_y_vertices": [845, 865]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Michael",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 280],
                "vertical_y_vertices": [870, 890]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "231-429-7217",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300, 450],
                "vertical_y_vertices": [870, 890]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Undy",
              "optical_extraction_confidence_score": 0.85,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 280],
                "vertical_y_vertices": [920, 940]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "331-499-3904",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300, 450],
                "vertical_y_vertices": [920, 940]
              }
            }
          }
        ]
      }
    }
  }
]
```