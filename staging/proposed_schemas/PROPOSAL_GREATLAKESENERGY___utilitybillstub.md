An expert forensic data architect, I have meticulously analyzed the provided document variant for the 'GREATLAKESENERGY - utilitybillstub' class. My design adheres to a Zero-Trust mandate, ensuring structural resilience and data integrity.

### Key Architectural Decisions:

1.  **Document Scope:** The provided image is the informational reverse side of a utility bill payment stub. It contains contact information, customer rights, and regulatory notices, but no transactional financial data.
2.  **Data Segmentation:** I have identified and segmented key informational blocks:
    *   Vendor Identification and Payment Address.
    *   Contact Information (Phone, Web).
    *   A significant, multi-paragraph section detailing customer rights regarding disconnection for non-payment. This has been captured as a single, coherent text block (`disconnection_policy_details`) to maintain context and avoid brittle, sentence-level parsing.
    *   Regulatory and complaint registration notices at the bottom of the document.
3.  **Address Structure:** The payment address is presented in a distinct three-part visual grouping (`street`, `po_box`, `city_state_zip`). The schema's nested `GreatlakesenergyUtilitybillstubAddress` model reflects this physical layout for precise data mapping.
4.  **GAAP Validator:** As mandated, a `model_validator` for GAAP checksums is included. However, since this document variant contains no financial figures (e.g., charges, payments, balances), the validator correctly performs no mathematical operations and serves as a placeholder for document variants that might include such data.
5.  **Resilience:** Given only a single document version was provided, all fields are modeled as required. The prompt's directive to use `Optional` for fields not present in older layouts could not be applied, but the schema is structured to easily accommodate this by changing fields to `Optional[...` as new variants are discovered.

The resulting schema is robust, accurately models the provided document's structure, and is prepared for future evolution of the document class.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class GreatlakesenergyUtilitybillstubAddress(BaseModel):
    """A structured representation of the payment address."""
    model_config = ConfigDict(extra='forbid')
    street: ForensicDataEntity
    po_box: ForensicDataEntity
    city_state_zip: ForensicDataEntity

class GreatlakesenergyUtilitybillstub(BaseModel):
    """
    Schema for the informational back of a Great Lakes Energy utility bill stub.
    This side contains contact details, customer rights, and regulatory notices.
    """
    model_config = ConfigDict(extra='forbid')

    vendor_name: ForensicDataEntity
    payment_address: GreatlakesenergyUtilitybillstubAddress
    business_hours: ForensicDataEntity
    toll_free_number: ForensicDataEntity
    outage_reporting_number: ForensicDataEntity
    website: ForensicDataEntity
    disconnection_policy_details: ForensicDataEntity
    regulatory_body_info: ForensicDataEntity
    complaint_registration_notice: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatlakesenergyUtilitybillstub':
        """
        Performs double-entry GAAP mathematical checksums.
        
        Note: This document is the informational back of a utility bill stub.
        It does not contain any financial figures, so no GAAP checksums can be performed.
        This validator is included to meet the mandatory requirements and will pass through.
        """
        # No financial fields are present on this document variant to validate.
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "golden-test-01-single-variant",
    "should_pass": true,
    "taxonomy_lane": "GreatlakesenergyUtilitybillstub",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor_name": {
        "extracted_string_or_numeric_value": "GREAT LAKES ENERGY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [388, 611],
          "vertical_y_vertices": [121, 137]
        }
      },
      "payment_address": {
        "street": {
          "extracted_string_or_numeric_value": "525 W. US 10",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [208, 350],
            "vertical_y_vertices": [144, 160]
          }
        },
        "po_box": {
          "extracted_string_or_numeric_value": "P.O. BOX 248",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [360, 499],
            "vertical_y_vertices": [144, 160]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "SCOTTVILLE, MI 49454-0248",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [518, 789],
            "vertical_y_vertices": [144, 160]
          }
        }
      },
      "business_hours": {
        "extracted_string_or_numeric_value": "Business office open between 8:00 a.m. and 5:00 p.m. Monday through Friday except holidays.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [300, 699],
          "vertical_y_vertices": [169, 196]
        }
      },
      "toll_free_number": {
        "extracted_string_or_numeric_value": "1-888-GT LAKES (485-2537)",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [518, 759],
          "vertical_y_vertices": [220, 236]
        }
      },
      "outage_reporting_number": {
        "extracted_string_or_numeric_value": "1-800-678-0411",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [620, 759],
          "vertical_y_vertices": [251, 267]
        }
      },
      "website": {
        "extracted_string_or_numeric_value": "http://www.gtlakes.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [389, 609],
          "vertical_y_vertices": [293, 307]
        }
      },
      "disconnection_policy_details": {
        "extracted_string_or_numeric_value": "If a \"DISCONNECT NOTICE FOR NON-PAYMENT\" message appears on the bottom of your bill, please review the following information:\nYou, the customer, have the right to:\nEnter into a settlement agreement with Great Lakes Energy if the claim is for monies not in dispute and the customer is presently unable to pay in full amount due Great Lakes Energy.\nFile a complaint disputing the claim of the utility before the date of the proposed discontinuation of service.\nRequest a hearing before a utility hearing officer if the complaint cannot be otherwise resolved, providing that you, the customer, pay to the utility that portion of the bill not in dispute within 3 days of the date that the hearing is requested.\nRepresent yourself or to be represented by counsel or other person of your choice in the complaint process.\nContact Great Lakes Energy for information about the Winter Protection Plan if the date on or after which shut-off of service may occur between Nov. 15 and March 31.\nService will not be discontinued pending the resolution of a complaint filed with Great Lakes Energy in accordance with the Rules of the Michigan Public Service Commission.\nIf you believe you may be eligible for emergency economic assistance, contact a social service office immediately.\nDiscontinuance of service may be postponed if a medical emergency exists in your residence by producing a physician's statement.\nIn accordance with the Rules of the Michigan Public Service Commission a collection fee, reconnect fee and a deposit may be required if you are disconnected for non-payment of a delinquent account.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [34, 965],
          "vertical_y_vertices": [505, 855]
        }
      },
      "regulatory_body_info": {
        "extracted_string_or_numeric_value": "GREAT LAKES ENERGY IS REGULATED BY THE MICHIGAN PUBLIC SERVICE COMMISSION LANSING, MICH.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [122, 876],
          "vertical_y_vertices": [903, 916]
        }
      },
      "complaint_registration_notice": {
        "extracted_string_or_numeric_value": "REGISTER ANY INQUIRY OR COMPLAINT ABOUT YOUR BILL PRIOR TO DUE DATE.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [190, 808],
          "vertical_y_vertices": [922, 935]
        }
      }
    }
  }
]
```