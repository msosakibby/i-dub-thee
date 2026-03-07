An expert forensic data architect, I have analyzed the provided document images of the 'GreatLakesEnergyCooperative - UtilityBill' class. The document is the reverse side of a utility bill, containing contact information, service directories, and customer-fillable forms. My schema design accommodates all identified fields, treating user-input areas and checkboxes as optional to handle both blank and completed forms. The schema is structured with nested models for clarity and resilience.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]


class ForensicDataEntity(BaseModel):
    """Wrapper for extracted data, including metadata for forensic analysis."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon


class CallCenterService(BaseModel):
    """Represents a single service listed in the call center directory."""
    model_config = ConfigDict(extra='forbid')
    service_name: ForensicDataEntity
    extension: ForensicDataEntity
    notes: Optional[ForensicDataEntity] = None


class AddressChangeForm(BaseModel):
    """Models the form for customers to update their mailing address or phone number."""
    model_config = ConfigDict(extra='forbid')
    is_permanent_change: Optional[ForensicDataEntity] = None
    is_temporary_change: Optional[ForensicDataEntity] = None
    temporary_from_date: Optional[ForensicDataEntity] = None
    temporary_to_date: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    city: Optional[ForensicDataEntity] = None
    state: Optional[ForensicDataEntity] = None
    zip_code: Optional[ForensicDataEntity] = None
    phone: Optional[ForensicDataEntity] = None
    email_address: Optional[ForensicDataEntity] = None


class GreatLakesEnergyCooperativeUtilityBill(BaseModel):
    """
    Schema for the reverse side of a Great Lakes Energy Cooperative utility bill.
    
    This side contains contact information, service directories, and forms for
    account changes and payment authorization.
    """
    model_config = ConfigDict(extra='forbid')

    correspondence_address: ForensicDataEntity
    payment_address: ForensicDataEntity
    power_outage_address: ForensicDataEntity
    toll_free_number: ForensicDataEntity
    local_numbers: List[ForensicDataEntity]
    website: ForensicDataEntity
    call_center_services: List[CallCenterService]
    address_change_form: AddressChangeForm
    automated_checking_payment_plan_checkbox: Optional[ForensicDataEntity] = None
    people_fund_support_checkbox: Optional[ForensicDataEntity] = None
    signature: Optional[ForensicDataEntity] = None
    signature_date: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatLakesEnergyCooperativeUtilityBill':
        """
        Performs double-entry GAAP mathematical checksums.
        
        Note: This document variant (the back of the bill) does not contain
        financial figures to validate. This validator is included to meet
        the structural requirement and would be populated for the front side
        of the bill containing charge details.
        """
        # No financial fields are present on this side of the bill to perform checksums on.
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "great_lakes_energy_bill_back_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyCooperativeUtilityBill",
    "binary_header_simulation": "25504446",
    "payload": {
      "correspondence_address": {
        "extracted_string_or_numeric_value": "2183 N. WATER RD. Hart, MI 49420-9007",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [320, 500],
          "vertical_y_vertices": [78, 110]
        }
      },
      "payment_address": {
        "extracted_string_or_numeric_value": "P.O. Box 70 Boyne City, MI 49712-0070",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [580, 790],
          "vertical_y_vertices": [78, 110]
        }
      },
      "power_outage_address": {
        "extracted_string_or_numeric_value": "2183 N. WATER RD. Hart, MI 49420-9007",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [320, 500],
          "vertical_y_vertices": [78, 110]
        }
      },
      "toll_free_number": {
        "extracted_string_or_numeric_value": "1-888-485-2537",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 870],
          "vertical_y_vertices": [135, 148]
        }
      },
      "local_numbers": [
        {
          "extracted_string_or_numeric_value": "582-6521 (Boyne)",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 200],
            "vertical_y_vertices": [180, 192]
          }
        },
        {
          "extracted_string_or_numeric_value": "552-1651 (Newaygo)",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 200],
            "vertical_y_vertices": [200, 212]
          }
        }
      ],
      "website": {
        "extracted_string_or_numeric_value": "www.gtlakes.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 210],
          "vertical_y_vertices": [260, 275]
        }
      },
      "call_center_services": [
        {
          "service_name": {
            "extracted_string_or_numeric_value": "Electric billing questions",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 480], "vertical_y_vertices": [180, 190] }
          },
          "extension": {
            "extracted_string_or_numeric_value": "8924",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 540], "vertical_y_vertices": [180, 190] }
          },
          "notes": null
        },
        {
          "service_name": {
            "extracted_string_or_numeric_value": "Moving? Start or stop service",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 480], "vertical_y_vertices": [195, 205] }
          },
          "extension": {
            "extracted_string_or_numeric_value": "8924",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 540], "vertical_y_vertices": [195, 205] }
          },
          "notes": null
        },
        {
          "service_name": {
            "extracted_string_or_numeric_value": "Credit Card Payments",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 480], "vertical_y_vertices": [210, 220] }
          },
          "extension": {
            "extracted_string_or_numeric_value": "8924",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 540], "vertical_y_vertices": [210, 220] }
          },
          "notes": null
        },
        {
          "service_name": {
            "extracted_string_or_numeric_value": "Automated Bill Payment Plan Enrollment",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [580, 800], "vertical_y_vertices": [180, 190] }
          },
          "extension": {
            "extracted_string_or_numeric_value": "8924",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [820, 850], "vertical_y_vertices": [180, 190] }
          },
          "notes": null
        },
        {
          "service_name": {
            "extracted_string_or_numeric_value": "New Construction",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [580, 680], "vertical_y_vertices": [240, 250] }
          },
          "extension": {
            "extracted_string_or_numeric_value": "0",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [820, 850], "vertical_y_vertices": [240, 250] }
          },
          "notes": {
            "extracted_string_or_numeric_value": "varies by location",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [685, 780], "vertical_y_vertices": [240, 250] }
          }
        }
      ],
      "address_change_form": {
        "is_permanent_change": null,
        "is_temporary_change": null,
        "temporary_from_date": null,
        "temporary_to_date": null,
        "address": null,
        "city": null,
        "state": null,
        "zip_code": null,
        "phone": null,
        "email_address": null
      },
      "automated_checking_payment_plan_checkbox": null,
      "people_fund_support_checkbox": null,
      "signature": null,
      "signature_date": null
    }
  }
]
```