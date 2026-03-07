An expert forensic data architect, I have analyzed the provided document, a Last Will and Testament, and its handwritten addendum. The following Pydantic V2 schema is designed for maximum resilience, accommodating all structural elements observed. The corresponding JSON test case represents the complete data extraction from the provided document, serving as a golden record for validation.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box of extracted data on the physical document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single piece of extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class PersonalRepresentativeInfo(BaseModel):
    """Models the appointed Personal Representative (Executor)."""
    model_config = ConfigDict(extra='forbid')
    primary_representative: ForensicDataEntity
    successor_representative: Optional[ForensicDataEntity] = None
    bond_waived: ForensicDataEntity

class BeneficiaryInfo(BaseModel):
    """Models a single beneficiary of the estate."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity

class SpouseInfo(BaseModel):
    """Models details mentioned about the testator's spouse."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    notes: ForensicDataEntity

class WitnessInfo(BaseModel):
    """Models a witness to the will's execution."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    location: ForensicDataEntity

class AttorneyInfo(BaseModel):
    """Models the attorney who drafted the document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: ForensicDataEntity

class FinancialInstitutionInfo(BaseModel):
    """Models financial institution details from the handwritten addendum."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    phone: ForensicDataEntity
    address: ForensicDataEntity
    agent: ForensicDataEntity

class HandwrittenAddendum(BaseModel):
    """Models the separate handwritten instructions attached to the will."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    addressees: List[ForensicDataEntity]
    personal_property_instructions: ForensicDataEntity
    financial_institution_details: FinancialInstitutionInfo
    testator_ssn: ForensicDataEntity

class LastWillAndTestamentV1(BaseModel):
    """
    A resilient schema for the Last Will and Testament of Judith A. Grandy,
    accommodating both the typed will and the attached handwritten note.
    """
    model_config = ConfigDict(extra='forbid')
    
    testator_name: ForensicDataEntity
    testator_location: ForensicDataEntity
    execution_date: ForensicDataEntity
    personal_representative: PersonalRepresentativeInfo
    beneficiaries: List[BeneficiaryInfo]
    distribution_instructions: ForensicDataEntity
    spouse_details: Optional[SpouseInfo] = None
    witnesses: List[WitnessInfo]
    drafting_attorney: Optional[AttorneyInfo] = None
    handwritten_addendum: Optional[HandwrittenAddendum] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'LastWillAndTestamentV1':
        """
        This document class, a Last Will and Testament, does not contain explicit financial figures
        (e.g., asset values, liability amounts) that would allow for a double-entry GAAP checksum.
        The will directs the payment of debts and distribution of an estate, but does not enumerate
        the values. The handwritten addendum mentions financial instruments but provides no monetary
        values. Therefore, no mathematical validation is performed.
        This validator is included to meet the structural requirement of the directive.
        """
        # No financial data available in the source document for checksum validation.
        pass
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "20170321_grandy_judith_a_will",
    "should_pass": true,
    "taxonomy_lane": "LastWillAndTestamentV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "testator_name": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [353, 533, 533, 353],
          "vertical_y_vertices": [350, 350, 364, 364]
        }
      },
      "testator_location": {
        "extracted_string_or_numeric_value": "Marion, Osceola County, Michigan",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [281, 578, 578, 281],
          "vertical_y_vertices": [421, 421, 435, 435]
        }
      },
      "execution_date": {
        "extracted_string_or_numeric_value": "2017-03-21",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [550, 725, 725, 550],
          "vertical_y_vertices": [570, 570, 583, 583]
        }
      },
      "personal_representative": {
        "primary_representative": {
          "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [530, 725, 725, 530],
            "vertical_y_vertices": [329, 329, 343, 343]
          }
        },
        "successor_representative": {
          "extracted_string_or_numeric_value": "Michael J. Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [498, 650, 650, 498],
            "vertical_y_vertices": [362, 362, 376, 376]
          }
        },
        "bond_waived": {
          "extracted_string_or_numeric_value": "no bond be required of either of them",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [245, 595, 595, 245],
            "vertical_y_vertices": [395, 395, 409, 409]
          }
        }
      },
      "beneficiaries": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 765, 765, 221],
              "vertical_y_vertices": [740, 740, 770, 770]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "children",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [615, 680, 680, 615],
              "vertical_y_vertices": [740, 740, 754, 754]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Michael J. Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 765, 765, 221],
              "vertical_y_vertices": [755, 755, 785, 785]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "children",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [615, 680, 680, 615],
              "vertical_y_vertices": [740, 740, 754, 754]
            }
          }
        }
      ],
      "distribution_instructions": {
        "extracted_string_or_numeric_value": "share and share alike, per capita",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [475, 765, 765, 475],
          "vertical_y_vertices": [771, 771, 785, 785]
        }
      },
      "spouse_details": {
        "name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [535, 675, 675, 535],
            "vertical_y_vertices": [474, 474, 488, 488]
          }
        },
        "notes": {
          "extracted_string_or_numeric_value": "This is a second marriage for each of us and each of us have children from our prior marriages and our estates are subject to Premarital Agreements.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 765, 765, 221],
            "vertical_y_vertices": [507, 507, 552, 552]
          }
        }
      },
      "witnesses": [
        {
          "name": {
            "extracted_string_or_numeric_value": "GREGORY C. MERRIFIELD",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 420, 420, 221],
              "vertical_y_vertices": [250, 250, 265, 265]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "Marion, Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [470, 600, 600, 470],
              "vertical_y_vertices": [250, 250, 265, 265]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Norman Carmon",
            "optical_extraction_confidence_score": 0.85,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 400, 400, 221],
              "vertical_y_vertices": [360, 360, 375, 375]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "Marion, Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [470, 600, 600, 470],
              "vertical_y_vertices": [360, 360, 375, 375]
            }
          }
        }
      ],
      "drafting_attorney": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 380, 380, 221],
            "vertical_y_vertices": [560, 560, 572, 572]
          }
        },
        "bar_number": {
          "extracted_string_or_numeric_value": "P27300",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 380, 380, 221],
            "vertical_y_vertices": [575, 575, 587, 587]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "221 E. Main/Box 172 Marion, MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 380, 380, 221],
            "vertical_y_vertices": [590, 590, 615, 615]
          }
        }
      },
      "handwritten_addendum": {
        "date": {
          "extracted_string_or_numeric_value": "2017-03-16",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 750, 750, 600],
            "vertical_y_vertices": [930, 930, 945, 945]
          }
        },
        "addressees": [
          {
            "extracted_string_or_numeric_value": "Mark",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 250, 250, 150],
              "vertical_y_vertices": [150, 150, 170, 170]
            }
          },
          {
            "extracted_string_or_numeric_value": "Mike",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [280, 360, 360, 280],
              "vertical_y_vertices": [150, 150, 170, 170]
            }
          }
        ],
        "personal_property_instructions": {
          "extracted_string_or_numeric_value": "Take what you want, then invite family in & ask what they may be interested in. Sell or give to them. Sell the rest at Auction or Donate or yard sale!!!",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 750, 750, 150],
            "vertical_y_vertices": [210, 210, 350, 350]
          }
        },
        "financial_institution_details": {
          "name": {
            "extracted_string_or_numeric_value": "Advanced Financial Group",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 500, 500, 150],
              "vertical_y_vertices": [500, 500, 520, 520]
            }
          },
          "phone": {
            "extracted_string_or_numeric_value": "231-922-8943",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [510, 650, 650, 510],
              "vertical_y_vertices": [500, 500, 520, 520]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "2131 North Four Mile Rd. Traverse City MI 49686",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 550, 550, 150],
              "vertical_y_vertices": [550, 550, 620, 620]
            }
          },
          "agent": {
            "extracted_string_or_numeric_value": "John P. Olesnavage, CEP",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 500, 500, 150],
              "vertical_y_vertices": [650, 650, 670, 670]
            }
          }
        },
        "testator_ssn": {
          "extracted_string_or_numeric_value": "375-52-1882",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 750, 750, 580],
            "vertical_y_vertices": [880, 880, 900, 900]
          }
        }
      }
    }
  }
]
```