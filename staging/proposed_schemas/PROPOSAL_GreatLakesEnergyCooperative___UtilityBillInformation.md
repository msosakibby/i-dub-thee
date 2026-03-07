An expert forensic data architect, I have meticulously analyzed the provided document fragments. Despite the severe optical degradation, I have reverse-engineered the underlying data structure of the `GreatLakesEnergyCooperative - UtilityBillInformation` document class.

The resulting Pydantic V2 schema is designed for maximum resilience, accommodating the observed fields while designating user-fillable sections and potentially missing data as `Optional`. The schema adheres strictly to the provided `ForensicDataEntity` wrapper and includes the mandated, albeit currently non-operational, GAAP checksum validator for future-proofing against variants with financial data.

The accompanying JSON test case represents the most complex structural variant—a fully completed form—and uses cleaned, human-readable data to serve as a "golden record" for testing extraction accuracy, while the confidence scores reflect the poor quality of the source image.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, bool]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class CorrespondenceAddress(BaseModel):
    model_config = ConfigDict(extra='forbid')
    addressee: ForensicDataEntity
    department: ForensicDataEntity
    phone: ForensicDataEntity

class PaymentAddress(BaseModel):
    model_config = ConfigDict(extra='forbid')
    department: ForensicDataEntity
    po_box: ForensicDataEntity
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: ForensicDataEntity

class CustomerServiceAddress(BaseModel):
    model_config = ConfigDict(extra='forbid')
    addressee: ForensicDataEntity
    department: ForensicDataEntity
    po_box: ForensicDataEntity
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: Optional[ForensicDataEntity] = None

class ContactInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    toll_free_number: ForensicDataEntity
    department: ForensicDataEntity
    availability: ForensicDataEntity

class AddressChangeForm(BaseModel):
    model_config = ConfigDict(extra='forbid')
    is_permanent: Optional[ForensicDataEntity] = None
    is_temporary: Optional[ForensicDataEntity] = None
    temporary_start_date: Optional[ForensicDataEntity] = None
    temporary_end_date: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    city: Optional[ForensicDataEntity] = None
    state: Optional[ForensicDataEntity] = None
    zip_code: Optional[ForensicDataEntity] = None
    phone: Optional[ForensicDataEntity] = None
    email_address: Optional[ForensicDataEntity] = None

class GreatLakesEnergyCooperativeUtilityBillInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    
    correspondence_address: CorrespondenceAddress
    payment_address: PaymentAddress
    customer_service_address: CustomerServiceAddress
    contact_info: ContactInfo
    website: ForensicDataEntity
    address_change_form: Optional[AddressChangeForm] = None
    people_fund_round_up_authorization: Optional[ForensicDataEntity] = None
    signature: Optional[ForensicDataEntity] = None
    signature_date: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatLakesEnergyCooperativeUtilityBillInformation':
        """
        Performs double-entry GAAP-style mathematical checksums.
        NOTE: This document variant does not contain explicit financial figures
        (e.g., balance, payments, new charges, total due) for validation.
        The validator is included for schema resilience but will pass without action.
        """
        # No financial fields to validate in this document part.
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "great-lakes-energy-bill-v1-complex",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyCooperativeUtilityBillInformation",
    "binary_header_simulation": "25504446",
    "payload": {
      "correspondence_address": {
        "addressee": {
          "extracted_string_or_numeric_value": "Great Lakes Energy Cooperative",
          "optical_extraction_confidence_score": 0.65,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [160, 450],
            "vertical_y_vertices": [170, 185]
          }
        },
        "department": {
          "extracted_string_or_numeric_value": "Support Center",
          "optical_extraction_confidence_score": 0.72,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [160, 280],
            "vertical_y_vertices": [190, 205]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "1-800-678-0411",
          "optical_extraction_confidence_score": 0.88,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 450],
            "vertical_y_vertices": [190, 205]
          }
        }
      },
      "payment_address": {
        "department": {
          "extracted_string_or_numeric_value": "Bill Payment Center",
          "optical_extraction_confidence_score": 0.68,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 750],
            "vertical_y_vertices": [170, 185]
          }
        },
        "po_box": {
          "extracted_string_or_numeric_value": "PO Box 7633",
          "optical_extraction_confidence_score": 0.55,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 680],
            "vertical_y_vertices": [190, 205]
          }
        },
        "city": {
          "extracted_string_or_numeric_value": "Hart",
          "optical_extraction_confidence_score": 0.91,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 630],
            "vertical_y_vertices": [210, 225]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "MI",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [635, 655],
            "vertical_y_vertices": [210, 225]
          }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "49420-4007",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [660, 760],
            "vertical_y_vertices": [210, 225]
          }
        }
      },
      "customer_service_address": {
        "addressee": {
          "extracted_string_or_numeric_value": "Great Lakes",
          "optical_extraction_confidence_score": 0.61,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 900],
            "vertical_y_vertices": [170, 185]
          }
        },
        "department": {
          "extracted_string_or_numeric_value": "Customer Service",
          "optical_extraction_confidence_score": 0.78,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 950],
            "vertical_y_vertices": [190, 205]
          }
        },
        "po_box": {
          "extracted_string_or_numeric_value": "P.O. Box",
          "optical_extraction_confidence_score": 0.45,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 880],
            "vertical_y_vertices": [210, 225]
          }
        },
        "city": {
          "extracted_string_or_numeric_value": "Boyne City",
          "optical_extraction_confidence_score": 0.85,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 900],
            "vertical_y_vertices": [230, 245]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "MI",
          "optical_extraction_confidence_score": 0.70,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [905, 930],
            "vertical_y_vertices": [230, 245]
          }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "49712",
          "optical_extraction_confidence_score": 0.5,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [935, 980],
            "vertical_y_vertices": [230, 245]
          }
        }
      },
      "contact_info": {
        "toll_free_number": {
          "extracted_string_or_numeric_value": "1-888-453-2357",
          "optical_extraction_confidence_score": 0.75,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [160, 350],
            "vertical_y_vertices": [260, 275]
          }
        },
        "department": {
          "extracted_string_or_numeric_value": "Great Lakes Energy Call Center",
          "optical_extraction_confidence_score": 0.70,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [480, 800],
            "vertical_y_vertices": [260, 275]
          }
        },
        "availability": {
          "extracted_string_or_numeric_value": "Available Monday - Friday, 8:00 a.m. to 5:00 p.m., (except holidays)",
          "optical_extraction_confidence_score": 0.82,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [480, 950],
            "vertical_y_vertices": [275, 290]
          }
        }
      },
      "website": {
        "extracted_string_or_numeric_value": "www.gatlakes.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [300, 450],
          "vertical_y_vertices": [430, 445]
        }
      },
      "address_change_form": {
        "is_permanent": {
          "extracted_string_or_numeric_value": true,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [430, 440],
            "vertical_y_vertices": [690, 700]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "456 Oak Avenue",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 500],
            "vertical_y_vertices": [710, 725]
          }
        },
        "city": {
          "extracted_string_or_numeric_value": "Lansing",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 400],
            "vertical_y_vertices": [730, 745]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550, 580],
            "vertical_y_vertices": [730, 745]
          }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "48910",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [620, 680],
            "vertical_y_vertices": [730, 745]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "517-555-0101",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 900],
            "vertical_y_vertices": [710, 725]
          }
        },
        "email_address": {
          "extracted_string_or_numeric_value": "jane.doe@email.com",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 500],
            "vertical_y_vertices": [750, 765]
          }
        }
      },
      "people_fund_round_up_authorization": {
        "extracted_string_or_numeric_value": true,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 130],
          "vertical_y_vertices": [910, 920]
        }
      },
      "signature": {
        "extracted_string_or_numeric_value": "Jane Doe",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [210, 550],
          "vertical_y_vertices": [950, 970]
        }
      },
      "signature_date": {
        "extracted_string_or_numeric_value": "2023-11-15",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 850],
          "vertical_y_vertices": [950, 970]
        }
      }
    }
  }
]
```