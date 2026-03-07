An expert forensic data architect, I have analyzed the provided multi-page marriage license application and designed a resilient Pydantic V2 schema to precisely model its structure. The schema accounts for all data points, including nested information about each party and their previous marriages, while adhering to the strict Zero-Trust mandate.

### BLOCK 1 (Python Pydantic V2)
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

# Base classes mandated by the directive
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema for previous marriage details
class PreviousMarriage(BaseModel):
    model_config = ConfigDict(extra='forbid')
    marriage_date: Optional[ForensicDataEntity] = None
    marriage_place: Optional[ForensicDataEntity] = None
    spouse_name: Optional[ForensicDataEntity] = None
    end_reason: Optional[ForensicDataEntity] = None
    end_date: Optional[ForensicDataEntity] = None
    end_place: Optional[ForensicDataEntity] = None

# Schema for one of the parties (Groom or Bride)
class PartyInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    maiden_name: Optional[ForensicDataEntity] = None
    address: ForensicDataEntity
    phone_number: ForensicDataEntity
    social_security_number: ForensicDataEntity
    residence_city_state: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    place_of_birth: ForensicDataEntity
    is_blood_related: ForensicDataEntity
    legal_impediments: ForensicDataEntity
    marriage_number: ForensicDataEntity
    consent_given: ForensicDataEntity
    sworn_statement_signature: ForensicDataEntity
    previous_marriages: List[PreviousMarriage]

# Top-level schema for the entire marriage license application
class MarriageLicenseApplication(BaseModel):
    """
    A resilient schema for the 2005 State of Alaska Marriage License Application form.
    """
    model_config = ConfigDict(extra='forbid')

    application_date: ForensicDataEntity
    contact_name: ForensicDataEntity
    mailing_address: ForensicDataEntity
    mailing_city_state_zip: ForensicDataEntity
    
    groom: PartyInformation
    bride: PartyInformation
    
    notary_date: ForensicDataEntity
    notary_signature_title_seal: ForensicDataEntity
    
    intended_pickup_date: ForensicDataEntity
    
    license_number: Optional[ForensicDataEntity] = None
    date_issued: Optional[ForensicDataEntity] = None
    remarks: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksum(self) -> 'MarriageLicenseApplication':
        """
        Executes double-entry GAAP mathematical checksums.
        
        Note: No financial fields are present in this document class for a GAAP checksum.
        The application fee of $40.00 is mentioned in the instructions but is not
        an extractable field within the form's data area. This validator is included
        to meet the structural requirements of the directive.
        """
        # No financial data to validate in this document.
        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2005-07-26 Application for Marriage License Keith A Grandy and Judith A Grandy",
    "should_pass": true,
    "taxonomy_lane": "MarriageLicenseApplication",
    "binary_header_simulation": "25504446",
    "payload": {
      "application_date": {
        "extracted_string_or_numeric_value": "May 25, 2005",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [660, 755, 755, 660],
          "vertical_y_vertices": [165, 165, 175, 175]
        }
      },
      "contact_name": {
        "extracted_string_or_numeric_value": "Judith Ann Kibby",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [245, 380, 380, 245],
          "vertical_y_vertices": [165, 165, 175, 175]
        }
      },
      "mailing_address": {
        "extracted_string_or_numeric_value": "P. O. Box 297",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [245, 380, 380, 245],
          "vertical_y_vertices": [188, 188, 198, 198]
        }
      },
      "mailing_city_state_zip": {
        "extracted_string_or_numeric_value": "Marion, MI 49665",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [245, 380, 380, 245],
          "vertical_y_vertices": [210, 210, 220, 220]
        }
      },
      "groom": {
        "name": {
          "extracted_string_or_numeric_value": "Keith Arthur Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 300, 300, 188],
            "vertical_y_vertices": [375, 375, 385, 385]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "4316 21 Mile Road Marion, MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [310, 490, 490, 310],
            "vertical_y_vertices": [460, 460, 495, 495]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-743-6686",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 280, 280, 188],
            "vertical_y_vertices": [540, 540, 550, 550]
          }
        },
        "social_security_number": {
          "extracted_string_or_numeric_value": "376-48-9851",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 280, 280, 188],
            "vertical_y_vertices": [585, 585, 595, 595]
          }
        },
        "residence_city_state": {
          "extracted_string_or_numeric_value": "Marion, MI 49556",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 380, 380, 175],
            "vertical_y_vertices": [365, 365, 375, 375]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "July 21, 1951",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 380, 380, 175],
            "vertical_y_vertices": [388, 388, 398, 398]
          }
        },
        "place_of_birth": {
          "extracted_string_or_numeric_value": "Reed City, MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 380, 380, 175],
            "vertical_y_vertices": [410, 410, 420, 420]
          }
        },
        "is_blood_related": {
          "extracted_string_or_numeric_value": "No",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 210, 210, 195],
            "vertical_y_vertices": [445, 445, 455, 455]
          }
        },
        "legal_impediments": {
          "extracted_string_or_numeric_value": "No",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 210, 210, 195],
            "vertical_y_vertices": [480, 480, 490, 490]
          }
        },
        "marriage_number": {
          "extracted_string_or_numeric_value": "2nd",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 380, 380, 350],
            "vertical_y_vertices": [500, 500, 510, 510]
          }
        },
        "consent_given": {
          "extracted_string_or_numeric_value": "No",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 335, 335, 320],
            "vertical_y_vertices": [780, 780, 790, 790]
          }
        },
        "sworn_statement_signature": {
          "extracted_string_or_numeric_value": "Keith A Grandy",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 400, 400, 180],
            "vertical_y_vertices": [650, 650, 670, 670]
          }
        },
        "previous_marriages": [
          {
            "marriage_date": {
              "extracted_string_or_numeric_value": "October 3, 1970",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 400, 400, 250], "vertical_y_vertices": [170, 170, 180, 180] }
            },
            "marriage_place": {
              "extracted_string_or_numeric_value": "Dighton, MI",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 400, 400, 250], "vertical_y_vertices": [215, 215, 225, 225] }
            },
            "spouse_name": {
              "extracted_string_or_numeric_value": "Marliee Sue Grandy (Briggs)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 400, 400, 250], "vertical_y_vertices": [240, 240, 250, 250] }
            },
            "end_reason": {
              "extracted_string_or_numeric_value": "Death",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [430, 440, 440, 430], "vertical_y_vertices": [285, 285, 295, 295] }
            },
            "end_date": {
              "extracted_string_or_numeric_value": "December 27, 2003",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 400, 400, 250], "vertical_y_vertices": [310, 310, 320, 320] }
            },
            "end_place": {
              "extracted_string_or_numeric_value": "Spectrum Hos Grand Rapids M",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 400, 400, 250], "vertical_y_vertices": [335, 335, 345, 345] }
            }
          }
        ]
      },
      "bride": {
        "name": {
          "extracted_string_or_numeric_value": "Judith Ann Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [510, 620, 620, 510],
            "vertical_y_vertices": [375, 375, 385, 385]
          }
        },
        "maiden_name": {
          "extracted_string_or_numeric_value": "Judith Ann Munn",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [510, 620, 620, 510],
            "vertical_y_vertices": [410, 410, 420, 420]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road Marion, ΜΙ 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [620, 770, 770, 620],
            "vertical_y_vertices": [460, 460, 495, 495]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-743-6686",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [510, 600, 600, 510],
            "vertical_y_vertices": [540, 540, 550, 550]
          }
        },
        "social_security_number": {
          "extracted_string_or_numeric_value": "375-52-1882",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [510, 600, 600, 510],
            "vertical_y_vertices": [585, 585, 595, 595]
          }
        },
        "residence_city_state": {
          "extracted_string_or_numeric_value": "Marion, MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 700, 700, 500],
            "vertical_y_vertices": [365, 365, 375, 375]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "August 18, 1947",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 700, 700, 500],
            "vertical_y_vertices": [388, 388, 398, 398]
          }
        },
        "place_of_birth": {
          "extracted_string_or_numeric_value": "Lakeview, MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 700, 700, 500],
            "vertical_y_vertices": [410, 410, 420, 420]
          }
        },
        "is_blood_related": {
          "extracted_string_or_numeric_value": "No",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [520, 535, 535, 520],
            "vertical_y_vertices": [445, 445, 455, 455]
          }
        },
        "legal_impediments": {
          "extracted_string_or_numeric_value": "No",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [520, 535, 535, 520],
            "vertical_y_vertices": [480, 480, 490, 490]
          }
        },
        "marriage_number": {
          "extracted_string_or_numeric_value": "2nd",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [675, 705, 705, 675],
            "vertical_y_vertices": [500, 500, 510, 510]
          }
        },
        "consent_given": {
          "extracted_string_or_numeric_value": "No",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [645, 660, 660, 645],
            "vertical_y_vertices": [780, 780, 790, 790]
          }
        },
        "sworn_statement_signature": {
          "extracted_string_or_numeric_value": "Judith A Kibby",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [505, 725, 725, 505],
            "vertical_y_vertices": [650, 650, 670, 670]
          }
        },
        "previous_marriages": [
          {
            "marriage_date": {
              "extracted_string_or_numeric_value": "May 21, 1967",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690, 690, 540], "vertical_y_vertices": [170, 170, 180, 180] }
            },
            "marriage_place": {
              "extracted_string_or_numeric_value": "Marion, MI",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690, 690, 540], "vertical_y_vertices": [215, 215, 225, 225] }
            },
            "spouse_name": {
              "extracted_string_or_numeric_value": "Max Revoe Kibby",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690, 690, 540], "vertical_y_vertices": [240, 240, 250, 250] }
            },
            "end_reason": {
              "extracted_string_or_numeric_value": "Death",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 730, 730, 720], "vertical_y_vertices": [285, 285, 295, 295] }
            },
            "end_date": {
              "extracted_string_or_numeric_value": "September 18, 1999",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690, 690, 540], "vertical_y_vertices": [310, 310, 320, 320] }
            },
            "end_place": {
              "extracted_string_or_numeric_value": "Spectrum Hos Grand Rapids M",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690, 690, 540], "vertical_y_vertices": [335, 335, 345, 345] }
            }
          }
        ]
      },
      "notary_date": {
        "extracted_string_or_numeric_value": "June 9, 2005",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [380, 480, 480, 380],
          "vertical_y_vertices": [690, 690, 700, 700]
        }
      },
      "notary_signature_title_seal": {
        "extracted_string_or_numeric_value": "Diana Salisbury",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [300, 480, 480, 300],
          "vertical_y_vertices": [715, 715, 735, 735]
        }
      },
      "intended_pickup_date": {
        "extracted_string_or_numeric_value": "July 19, 2005",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [420, 520, 520, 420],
          "vertical_y_vertices": [800, 800, 810, 810]
        }
      },
      "license_number": null,
      "date_issued": null,
      "remarks": null
    }
  }
]
```