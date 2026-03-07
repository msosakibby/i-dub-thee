An expert forensic data architect, I have analyzed the provided document, a "Durable Power of Attorney for Health Care," noting its standard legal structure augmented by a significant, handwritten addendum. This addendum, with its distinct date, specific end-of-life directives, and contact list, represents the most complex structural variant.

My Pydantic V2 schema is designed for resilience, capturing both the formal typed sections and the unstructured handwritten notes. Key entities such as the patient, primary agent, and successor agents are modeled in dedicated classes. The handwritten page is treated as a distinct `HandwrittenAddendum` object to preserve its context and unique data points, such as the organ donor status and disposition of remains. All fields are designed to be optional where appropriate to accommodate potential future or past document variations, adhering to the Zero-Trust mandate.

***

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class PatientInfo(BaseModel):
    """Models the information related to the patient (Principal)."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    address: ForensicDataEntity

class AgentInfo(BaseModel):
    """Models the information for a designated agent or patient advocate."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity
    acceptance_date: Optional[ForensicDataEntity] = None

class SuccessorAgentInfo(BaseModel):
    """Models the information for a successor agent."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity
    acceptance_date: Optional[ForensicDataEntity] = None

class WitnessInfo(BaseModel):
    """Models the information related to a witness."""
    model_config = ConfigDict(extra='forbid')
    signature_date: ForensicDataEntity

class AttorneyInfo(BaseModel):
    """Models the information of the attorney who drafted the document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: ForensicDataEntity

class HandwrittenContact(BaseModel):
    """Models a single contact from the handwritten addendum."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    phone_number: ForensicDataEntity

class HandwrittenAddendum(BaseModel):
    """Models the entire handwritten note, which acts as an addendum."""
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    directives: List[ForensicDataEntity]
    living_preferences: ForensicDataEntity
    disposition_of_remains: ForensicDataEntity
    celebration_of_life: ForensicDataEntity
    organ_donor_status: ForensicDataEntity
    contacts: List[HandwrittenContact]

class DurablePowerOfAttorneyForHealthCare(BaseModel):
    """
    A resilient schema for a Durable Power of Attorney for Health Care (DPOA-HC),
    accommodating both typed legal sections and unstructured handwritten directives.
    """
    model_config = ConfigDict(extra='forbid')
    
    patient: PatientInfo
    document_date: ForensicDataEntity
    
    primary_agent: AgentInfo
    successor_agents: List[SuccessorAgentInfo]
    
    witnesses: List[WitnessInfo]
    
    governing_law_state: ForensicDataEntity
    
    drafting_attorney: Optional[AttorneyInfo] = None
    handwritten_addendum: Optional[HandwrittenAddendum] = None

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'DurablePowerOfAttorneyForHealthCare':
        """
        Executes mathematical checksums for financial data.
        This document class contains no financial fields, so this validator serves
        as a placeholder to fulfill the mandatory requirement for its inclusion.
        """
        # No financial data present in this document class for checksum validation.
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "2017-03-21_Grandy_Judith_A_DPOA-HC_Full_Form_with_Handwritten_Addendum",
    "should_pass": true,
    "taxonomy_lane": "DurablePowerOfAttorneyForHealthCare",
    "binary_header_simulation": "25504446",
    "payload": {
      "patient": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.998,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [177.0, 350.0, 350.0, 177.0],
            "vertical_y_vertices": [169.0, 169.0, 182.0, 182.0]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "8-18-1947",
          "optical_extraction_confidence_score": 0.989,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [605.0, 800.0, 800.0, 605.0],
            "vertical_y_vertices": [110.0, 110.0, 145.0, 145.0]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Mi 49665",
          "optical_extraction_confidence_score": 0.991,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [271.0, 705.0, 705.0, 271.0],
            "vertical_y_vertices": [200.0, 200.0, 215.0, 215.0]
          }
        }
      },
      "document_date": {
        "extracted_string_or_numeric_value": "March 21, 2017",
        "optical_extraction_confidence_score": 0.999,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [485.0, 650.0, 650.0, 485.0],
          "vertical_y_vertices": [170.0, 170.0, 185.0, 185.0]
        }
      },
      "primary_agent": {
        "name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.997,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [615.0, 775.0, 775.0, 615.0],
            "vertical_y_vertices": [169.0, 169.0, 182.0, 182.0]
          }
        },
        "relationship": {
          "extracted_string_or_numeric_value": "husband",
          "optical_extraction_confidence_score": 0.995,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500.0, 580.0, 580.0, 500.0],
            "vertical_y_vertices": [169.0, 169.0, 182.0, 182.0]
          }
        },
        "acceptance_date": {
          "extracted_string_or_numeric_value": "March 21, 2017",
          "optical_extraction_confidence_score": 0.998,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [590.0, 730.0, 730.0, 590.0],
            "vertical_y_vertices": [835.0, 835.0, 848.0, 848.0]
          }
        }
      },
      "successor_agents": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
            "optical_extraction_confidence_score": 0.992,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500.0, 680.0, 680.0, 500.0],
              "vertical_y_vertices": [220.0, 220.0, 235.0, 235.0]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "sons",
            "optical_extraction_confidence_score": 0.996,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [430.0, 470.0, 470.0, 430.0],
              "vertical_y_vertices": [220.0, 220.0, 235.0, 235.0]
            }
          },
          "acceptance_date": null
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Michael J. Kibby",
            "optical_extraction_confidence_score": 0.993,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700.0, 850.0, 850.0, 700.0],
              "vertical_y_vertices": [220.0, 220.0, 235.0, 235.0]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "sons",
            "optical_extraction_confidence_score": 0.996,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [430.0, 470.0, 470.0, 430.0],
              "vertical_y_vertices": [220.0, 220.0, 235.0, 235.0]
            }
          },
          "acceptance_date": null
        }
      ],
      "witnesses": [
        {
          "signature_date": {
            "extracted_string_or_numeric_value": "March 21, 2017",
            "optical_extraction_confidence_score": 0.999,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220.0, 350.0, 350.0, 220.0],
              "vertical_y_vertices": [570.0, 570.0, 585.0, 585.0]
            }
          }
        },
        {
          "signature_date": {
            "extracted_string_or_numeric_value": "March 21, 2017",
            "optical_extraction_confidence_score": 0.999,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220.0, 350.0, 350.0, 220.0],
              "vertical_y_vertices": [650.0, 650.0, 665.0, 665.0]
            }
          }
        }
      ],
      "governing_law_state": {
        "extracted_string_or_numeric_value": "Michigan",
        "optical_extraction_confidence_score": 0.994,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [550.0, 630.0, 630.0, 550.0],
          "vertical_y_vertices": [720.0, 720.0, 735.0, 735.0]
        }
      },
      "drafting_attorney": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [225.0, 400.0, 400.0, 225.0],
            "vertical_y_vertices": [440.0, 440.0, 455.0, 455.0]
          }
        },
        "bar_number": {
          "extracted_string_or_numeric_value": "P27300",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350.0, 420.0, 420.0, 350.0],
            "vertical_y_vertices": [455.0, 455.0, 470.0, 470.0]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "221 E. Main/Box 172 Marion, MI 49665",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [225.0, 480.0, 480.0, 225.0],
            "vertical_y_vertices": [470.0, 470.0, 500.0, 500.0]
          }
        }
      },
      "handwritten_addendum": {
        "document_date": {
          "extracted_string_or_numeric_value": "March 16, 2017",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650.0, 780.0, 780.0, 650.0],
            "vertical_y_vertices": [780.0, 780.0, 800.0, 800.0]
          }
        },
        "directives": [
          {
            "extracted_string_or_numeric_value": "Do Not revive me",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200.0, 650.0, 650.0, 200.0],
              "vertical_y_vertices": [120.0, 120.0, 150.0, 150.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Do Not place me on Life Support, if no hope for survival",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [180.0, 700.0, 700.0, 180.0],
              "vertical_y_vertices": [160.0, 160.0, 210.0, 210.0]
            }
          }
        ],
        "living_preferences": {
          "extracted_string_or_numeric_value": "If my health fails I would like to live at home with professional Care. If this is not doable or too overwelling for the family. Please admit me to a Care phycility !!! I do not want to stay in my home and be a burrden for my fahuly !!!",
          "optical_extraction_confidence_score": 0.88,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180.0, 750.0, 750.0, 180.0],
            "vertical_y_vertices": [280.0, 280.0, 480.0, 480.0]
          }
        },
        "disposition_of_remains": {
          "extracted_string_or_numeric_value": "I would like to be cremated & my ashes Spread on the Farm - Duck Blind & the same Spot on the hill as your Dad Keith.",
          "optical_extraction_confidence_score": 0.89,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180.0, 750.0, 750.0, 180.0],
            "vertical_y_vertices": [550.0, 550.0, 650.0, 650.0]
          }
        },
        "celebration_of_life": {
          "extracted_string_or_numeric_value": "At my home with Family and Close friends or whatever you decide.",
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180.0, 750.0, 750.0, 180.0],
            "vertical_y_vertices": [660.0, 660.0, 720.0, 720.0]
          }
        },
        "organ_donor_status": {
          "extracted_string_or_numeric_value": "I am an Organ Donor.",
          "optical_extraction_confidence_score": 0.93,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180.0, 500.0, 500.0, 180.0],
            "vertical_y_vertices": [220.0, 220.0, 250.0, 250.0]
          }
        },
        "contacts": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Keith",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200.0, 280.0, 280.0, 200.0],
                "vertical_y_vertices": [830.0, 830.0, 850.0, 850.0]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "231-942-1552",
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300.0, 450.0, 450.0, 300.0],
                "vertical_y_vertices": [830.0, 830.0, 850.0, 850.0]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "MARK",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200.0, 280.0, 280.0, 200.0],
                "vertical_y_vertices": [855.0, 855.0, 875.0, 875.0]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "773-251-0539",
              "optical_extraction_confidence_score": 0.93,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300.0, 450.0, 450.0, 300.0],
                "vertical_y_vertices": [855.0, 855.0, 875.0, 875.0]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Michael",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200.0, 280.0, 280.0, 200.0],
                "vertical_y_vertices": [880.0, 880.0, 900.0, 900.0]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "231-429-7217",
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300.0, 450.0, 450.0, 300.0],
                "vertical_y_vertices": [880.0, 880.0, 900.0, 900.0]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Undy",
              "optical_extraction_confidence_score": 0.75,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200.0, 280.0, 280.0, 200.0],
                "vertical_y_vertices": [920.0, 920.0, 940.0, 940.0]
              }
            },
            "phone_number": {
              "extracted_string_or_numeric_value": "331-499-3904",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300.0, 450.0, 450.0, 300.0],
                "vertical_y_vertices": [920.0, 920.0, 940.0, 940.0]
              }
            }
          }
        ]
      }
    }
  }
]
```