BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Address(BaseModel):
    """Represents the holder's address."""
    model_config = ConfigDict(extra='forbid')
    street: ForensicDataEntity
    city_state_zip: ForensicDataEntity

class DonorInfo(BaseModel):
    """Represents the organ donor information."""
    model_config = ConfigDict(extra='forbid')
    status: ForensicDataEntity
    revision_date: ForensicDataEntity

class MichiganDriverLicenseV1(BaseModel):
    """
    A Pydantic V2 schema for a Michigan Driver's License.
    The document class is '08-18-1947 - JUDITHANNGRANDY - DRIVERLICENSE'.
    """
    model_config = ConfigDict(extra='forbid')

    # Header
    issuer: ForensicDataEntity
    document_type: ForensicDataEntity

    # Primary Holder Information
    license_number: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    full_name: ForensicDataEntity
    address: Address
    signature: ForensicDataEntity

    # License Details
    issue_date: ForensicDataEntity
    expiration_date: ForensicDataEntity
    sex: ForensicDataEntity
    height: ForensicDataEntity
    eye_color: ForensicDataEntity
    license_type: ForensicDataEntity
    endorsements: ForensicDataEntity
    restrictions: ForensicDataEntity
    dd_number: ForensicDataEntity

    # Special Designations
    donor_info: DonorInfo

    # Back of Card Data
    barcode_data: ForensicDataEntity
    medical_alert_info: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'MichiganDriverLicenseV1':
        """
        Executes double-entry GAAP mathematical checksums.
        No financial fields are present in this document class, so this validator
        is included to meet the directive's requirements and will always pass.
        """
        # Placeholder for GAAP compliance checks.
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "michigan_dl_v1_judith_grandy_08181947",
    "should_pass": true,
    "taxonomy_lane": "MichiganDriverLicenseV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "issuer": {
        "extracted_string_or_numeric_value": "MICHIGAN",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 485, 485, 355],
          "vertical_y_vertices": [265, 265, 280, 280]
        }
      },
      "document_type": {
        "extracted_string_or_numeric_value": "DRIVER LICENSE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 480, 480, 355],
          "vertical_y_vertices": [285, 285, 298, 298]
        }
      },
      "license_number": {
        "extracted_string_or_numeric_value": "G 653 454 067 645",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 645, 645, 450],
          "vertical_y_vertices": [310, 310, 325, 325]
        }
      },
      "date_of_birth": {
        "extracted_string_or_numeric_value": "08-18-1947",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 550, 550, 450],
          "vertical_y_vertices": [326, 326, 338, 338]
        }
      },
      "full_name": {
        "extracted_string_or_numeric_value": "JUDITH ANN GRANDY",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 610, 610, 450],
          "vertical_y_vertices": [340, 340, 352, 352]
        }
      },
      "address": {
        "street": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 580, 580, 450],
            "vertical_y_vertices": [353, 353, 365, 365]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "MARION, MI 49665",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 600, 600, 450],
            "vertical_y_vertices": [366, 366, 378, 378]
          }
        }
      },
      "signature": {
        "extracted_string_or_numeric_value": "Judith A Brandy",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 480, 480, 355],
          "vertical_y_vertices": [420, 420, 440, 440]
        }
      },
      "issue_date": {
        "extracted_string_or_numeric_value": "06-08-2022",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 740, 740, 650],
          "vertical_y_vertices": [310, 310, 325, 325]
        }
      },
      "expiration_date": {
        "extracted_string_or_numeric_value": "08-18-2026",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 740, 740, 650],
          "vertical_y_vertices": [326, 326, 338, 338]
        }
      },
      "sex": {
        "extracted_string_or_numeric_value": "F",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 465, 465, 450],
          "vertical_y_vertices": [385, 385, 398, 398]
        }
      },
      "height": {
        "extracted_string_or_numeric_value": "500",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [570, 605, 605, 570],
          "vertical_y_vertices": [385, 385, 398, 398]
        }
      },
      "eye_color": {
        "extracted_string_or_numeric_value": "BRO",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 685, 685, 650],
          "vertical_y_vertices": [385, 385, 398, 398]
        }
      },
      "license_type": {
        "extracted_string_or_numeric_value": "O",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 465, 465, 450],
          "vertical_y_vertices": [399, 399, 412, 412]
        }
      },
      "endorsements": {
        "extracted_string_or_numeric_value": "NONE",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [570, 615, 615, 570],
          "vertical_y_vertices": [399, 399, 412, 412]
        }
      },
      "restrictions": {
        "extracted_string_or_numeric_value": "NONE",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 550, 550, 450],
          "vertical_y_vertices": [413, 413, 425, 425]
        }
      },
      "dd_number": {
        "extracted_string_or_numeric_value": "DD 1204147192400",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 640, 640, 500],
          "vertical_y_vertices": [440, 440, 452, 452]
        }
      },
      "donor_info": {
        "status": {
          "extracted_string_or_numeric_value": "DONOR",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 730, 730, 680],
            "vertical_y_vertices": [440, 440, 452, 452]
          }
        },
        "revision_date": {
          "extracted_string_or_numeric_value": "Rev 08-16-2021",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 760, 760, 680],
            "vertical_y_vertices": [453, 453, 465, 465]
          }
        }
      },
      "barcode_data": {
        "extracted_string_or_numeric_value": "G65345406764519470818260801",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [640, 810, 810, 640],
          "vertical_y_vertices": [630, 630, 645, 645]
        }
      },
      "medical_alert_info": {
        "extracted_string_or_numeric_value": "ENCODED DATA: BIRTH, EXPIRATION, REVISION & TRANSACTION DATES; DL/ID CARD #; NAME; ADDRESS; GENDER; ISSUING STATE & INVENTORY CONTROL #, COMPLIANCY INDICATOR, DURATION INDICATOR.",
        "optical_extraction_confidence_score": 0.90,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [670, 810, 810, 670],
          "vertical_y_vertices": [680, 680, 760, 760]
        }
      }
    }
  }
]
```