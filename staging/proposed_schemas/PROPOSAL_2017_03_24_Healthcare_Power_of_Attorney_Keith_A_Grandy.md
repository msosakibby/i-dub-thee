An expert forensic data architect, I have analyzed the provided document, a "Durable Power of Attorney for Health Care," and designed a resilient Pydantic V2 schema to capture its structure. The schema accounts for all key data points, including patient, agent, successor, and attorney details, as well as signature information.

***

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

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
    """Contains information about the principal (the patient)."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    address: ForensicDataEntity

class AgentInfo(BaseModel):
    """Contains information about the designated agent (Patient Advocate)."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity

class SuccessorAgentInfo(BaseModel):
    """Contains information about the designated successor agent."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: ForensicDataEntity

class Signatories(BaseModel):
    """Captures the names and dates associated with all signatures on the document."""
    model_config = ConfigDict(extra='forbid')
    patient_name: ForensicDataEntity
    patient_signature_date: ForensicDataEntity
    agent_name: ForensicDataEntity
    agent_acceptance_date: ForensicDataEntity
    successor_agent_name: ForensicDataEntity
    successor_agent_acceptance_date: ForensicDataEntity
    witness_1_signature_date: ForensicDataEntity
    witness_2_signature_date: ForensicDataEntity

class AttorneyInfo(BaseModel):
    """Contains information about the attorney who drafted the document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: ForensicDataEntity

class HealthcarePowerOfAttorneyV1(BaseModel):
    """
    A schema for a Durable Power of Attorney for Health Care document,
    as governed by the laws of the State of Michigan.
    """
    model_config = ConfigDict(extra='forbid')
    
    document_title: ForensicDataEntity
    patient_info: PatientInfo
    agent_info: AgentInfo
    successor_agent_info: SuccessorAgentInfo
    governing_law_state: ForensicDataEntity
    signatories: Signatories
    drafting_attorney: AttorneyInfo

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'HealthcarePowerOfAttorneyV1':
        """
        A placeholder for mathematical checksums as required by the directive.
        This document type does not contain financial figures, so no validation is performed.
        """
        # No financial fields are present in this document type.
        # The validator is included to conform to the directive's requirements.
        # It will always pass as there are no mathematical checks to perform.
        return self

```

***

```json
[
  {
    "test_identifier": "2017-03-24_healthcare_poa_keith_grandy",
    "should_pass": true,
    "taxonomy_lane": "HealthcarePowerOfAttorneyV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "DURABLE POWER OF ATTORNEY FOR HEALTH CARE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [81.0, 684.0, 684.0, 81.0],
          "vertical_y_vertices": [81.0, 81.0, 97.0, 97.0]
        }
      },
      "patient_info": {
        "name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [299.0, 500.0, 500.0, 299.0],
            "vertical_y_vertices": [160.0, 160.0, 178.0, 178.0]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "7/21/1951",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221.0, 300.0, 300.0, 221.0],
            "vertical_y_vertices": [150.0, 150.0, 165.0, 165.0]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Mi 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [265.0, 700.0, 700.0, 265.0],
            "vertical_y_vertices": [1950.0, 1950.0, 2010.0, 2010.0]
          }
        }
      },
      "agent_info": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580.0, 750.0, 750.0, 580.0],
            "vertical_y_vertices": [160.0, 160.0, 178.0, 178.0]
          }
        },
        "relationship": {
          "extracted_string_or_numeric_value": "wife",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [520.0, 560.0, 560.0, 520.0],
            "vertical_y_vertices": [160.0, 160.0, 178.0, 178.0]
          }
        }
      },
      "successor_agent_info": {
        "name": {
          "extracted_string_or_numeric_value": "Jodi Marie Bell",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600.0, 750.0, 750.0, 600.0],
            "vertical_y_vertices": [210.0, 210.0, 228.0, 228.0]
          }
        },
        "relationship": {
          "extracted_string_or_numeric_value": "daughter",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500.0, 580.0, 580.0, 500.0],
            "vertical_y_vertices": [210.0, 210.0, 228.0, 228.0]
          }
        }
      },
      "governing_law_state": {
        "extracted_string_or_numeric_value": "Michigan",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680.0, 750.0, 750.0, 680.0],
          "vertical_y_vertices": [750.0, 750.0, 765.0, 765.0]
        }
      },
      "signatories": {
        "patient_name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [455.0, 588.0, 588.0, 455.0],
            "vertical_y_vertices": [2500.0, 2500.0, 2515.0, 2515.0]
          }
        },
        "patient_signature_date": {
          "extracted_string_or_numeric_value": "March 24, 2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600.0, 720.0, 720.0, 600.0],
            "vertical_y_vertices": [1850.0, 1850.0, 1865.0, 1865.0]
          }
        },
        "agent_name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [540.0, 680.0, 680.0, 540.0],
            "vertical_y_vertices": [820.0, 820.0, 835.0, 835.0]
          }
        },
        "agent_acceptance_date": {
          "extracted_string_or_numeric_value": "March 24, 2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600.0, 720.0, 720.0, 600.0],
            "vertical_y_vertices": [840.0, 840.0, 855.0, 855.0]
          }
        },
        "successor_agent_name": {
          "extracted_string_or_numeric_value": "Jodi Marie Bell",
          "optical_extraction_confidence_score": 0.93,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [540.0, 680.0, 680.0, 540.0],
            "vertical_y_vertices": [150.0, 150.0, 165.0, 165.0]
          }
        },
        "successor_agent_acceptance_date": {
          "extracted_string_or_numeric_value": "3.24.17",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600.0, 680.0, 680.0, 600.0],
            "vertical_y_vertices": [170.0, 170.0, 185.0, 185.0]
          }
        },
        "witness_1_signature_date": {
          "extracted_string_or_numeric_value": "March 24, 2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220.0, 340.0, 340.0, 220.0],
            "vertical_y_vertices": [2600.0, 2600.0, 2615.0, 2615.0]
          }
        },
        "witness_2_signature_date": {
          "extracted_string_or_numeric_value": "March 24, 2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220.0, 340.0, 340.0, 220.0],
            "vertical_y_vertices": [2700.0, 2700.0, 2715.0, 2715.0]
          }
        }
      },
      "drafting_attorney": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221.0, 380.0, 380.0, 221.0],
            "vertical_y_vertices": [350.0, 350.0, 365.0, 365.0]
          }
        },
        "bar_number": {
          "extracted_string_or_numeric_value": "P27300",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350.0, 420.0, 420.0, 350.0],
            "vertical_y_vertices": [370.0, 370.0, 385.0, 385.0]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "221 E. Main/Box 172\nMarion, MI 49665",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221.0, 380.0, 380.0, 221.0],
            "vertical_y_vertices": [390.0, 390.0, 420.0, 420.0]
          }
        }
      }
    }
  }
]
```