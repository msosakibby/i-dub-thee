An expert forensic data architect, operating under a Zero-Trust mandate, has meticulously analyzed the provided document variants. The following Pydantic V2 schema and JSON test case have been generated to ensure maximum resilience and data integrity across all observed structural drifts.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for a data entity on the physical document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single data entity, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class FinancialInstitutionInfo(BaseModel):
    """Details of the financial institution."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    city_state_zip: ForensicDataEntity
    branch_number: ForensicDataEntity

class AccountInfo(BaseModel):
    """Core information about the new or modified account."""
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    is_temporary: Optional[ForensicDataEntity] = None
    is_replacement: Optional[ForensicDataEntity] = None
    amount_of_deposit: ForensicDataEntity
    title_of_account: ForensicDataEntity
    account_address: ForensicDataEntity
    account_city_state_zip: ForensicDataEntity
    ownership_type: ForensicDataEntity
    product_name: ForensicDataEntity
    opened_by: ForensicDataEntity
    account_number: ForensicDataEntity
    account_tin: ForensicDataEntity
    plan_number: Optional[ForensicDataEntity] = None

class AccountOwner(BaseModel):
    """Information for a single account owner."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    street_address: Optional[ForensicDataEntity] = None
    po_box: Optional[ForensicDataEntity] = None
    city_state_zip: ForensicDataEntity
    title_capacity: ForensicDataEntity
    tax_id_number: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    primary_phone: Optional[ForensicDataEntity] = None
    secondary_phone: Optional[ForensicDataEntity] = None
    cell_phone: Optional[ForensicDataEntity] = None
    email_address: Optional[ForensicDataEntity] = None
    employer_name_and_address: Optional[ForensicDataEntity] = None
    id_type: ForensicDataEntity
    id_number: ForensicDataEntity
    id_issuing_location: ForensicDataEntity
    id_issue_date: Optional[ForensicDataEntity] = None
    id_expiration: ForensicDataEntity
    id_issued_by: Optional[ForensicDataEntity] = None
    verification_unique_identifier: Optional[ForensicDataEntity] = None
    ofac_checked: ForensicDataEntity
    chexsystems_checked: ForensicDataEntity

class TaxpayerIdCertification(BaseModel):
    """Certification of the taxpayer identification number."""
    model_config = ConfigDict(extra='forbid')
    signature: ForensicDataEntity
    date: ForensicDataEntity
    taxpayer_identification_number: ForensicDataEntity
    exempt_payee_code: Optional[ForensicDataEntity] = None
    exemption_from_fatca_code: Optional[ForensicDataEntity] = None

class AuthorizedSignerDesignation(BaseModel):
    """Details for a designated authorized signer or agent."""
    model_config = ConfigDict(extra='forbid')
    agent_name: Optional[ForensicDataEntity] = None
    tax_id_number: Optional[ForensicDataEntity] = None
    date_of_birth: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None
    has_power_after_disability_or_incapacity: Optional[ForensicDataEntity] = None

class AcknowledgmentSignature(BaseModel):
    """Represents a single signature in the acknowledgment section."""
    model_config = ConfigDict(extra='forbid')
    signer_name: ForensicDataEntity
    signer_title: ForensicDataEntity
    date: ForensicDataEntity

class Acknowledgment(BaseModel):
    """The final acknowledgment and signature section of the form."""
    model_config = ConfigDict(extra='forbid')
    number_of_signatures_required: Optional[ForensicDataEntity] = None
    facsimile_allowed: ForensicDataEntity
    signatures: List[AcknowledgmentSignature]

class KibbycoChemicalBankAddToMomsAccount1(BaseModel):
    """
    Pydantic V2 schema for Chemical Bank's 'New Account Information - Consumer' form.
    This model accommodates structural variations observed in document class '1947-08-18 1947-08-18 KibbyCo_Chemical_Bank_-_add_to_moms_account_1'.
    """
    model_config = ConfigDict(extra='forbid')
    
    financial_institution: FinancialInstitutionInfo
    account_info: AccountInfo
    owner_1: AccountOwner
    owner_2: Optional[AccountOwner] = None
    owner_3: Optional[AccountOwner] = None
    owner_4: Optional[AccountOwner] = None
    taxpayer_id_certification: TaxpayerIdCertification
    authorized_signer_designation: Optional[AuthorizedSignerDesignation] = None
    acknowledgment: Acknowledgment

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'KibbycoChemicalBankAddToMomsAccount1':
        """
        Performs double-entry GAAP-style mathematical checksums.
        In this document, only a single financial value ('amount_of_deposit') is present.
        As there are no other values to balance against (e.g., a total, debits/credits),
        no checksum is performed. The validator is included to meet structural requirements.
        """
        # No calculation possible with a single financial value.
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "complex_multi_owner_replacement_form_001",
    "should_pass": true,
    "taxonomy_lane": "KibbycoChemicalBankAddToMomsAccount1",
    "binary_header_simulation": "25504446",
    "payload": {
      "financial_institution": {
        "name": {
          "extracted_string_or_numeric_value": "Chemical Bank a div of TCP National Bank",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [517, 786, 786, 517], "vertical_y_vertices": [101, 101, 112, 112] }
        },
        "address": {
          "extracted_string_or_numeric_value": "101 # Roland Street",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [517, 650, 650, 517], "vertical_y_vertices": [123, 123, 134, 134] }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "McBain, KI 49657-9683",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [517, 665, 665, 517], "vertical_y_vertices": [145, 145, 156, 156] }
        },
        "branch_number": {
          "extracted_string_or_numeric_value": "1402",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [517, 549, 549, 517], "vertical_y_vertices": [167, 167, 178, 178] }
        }
      },
      "account_info": {
        "document_date": {
          "extracted_string_or_numeric_value": "08/01/1978",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [188, 258, 258, 188], "vertical_y_vertices": [129, 129, 140, 140] }
        },
        "is_replacement": {
          "extracted_string_or_numeric_value": "True",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [358, 368, 368, 358], "vertical_y_vertices": [151, 151, 161, 161] }
        },
        "amount_of_deposit": {
          "extracted_string_or_numeric_value": 85950.96,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [245, 325, 325, 245], "vertical_y_vertices": [203, 203, 214, 214] }
        },
        "title_of_account": {
          "extracted_string_or_numeric_value": "Judith A Grandy Mark W Kibby",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 400, 400, 190], "vertical_y_vertices": [225, 225, 248, 248] }
        },
        "account_address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 410, 410, 280], "vertical_y_vertices": [250, 250, 261, 261] }
        },
        "account_city_state_zip": {
          "extracted_string_or_numeric_value": "Marion MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 400, 400, 280], "vertical_y_vertices": [262, 262, 273, 273] }
        },
        "ownership_type": {
          "extracted_string_or_numeric_value": "Joint with ROS",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 285, 285, 189], "vertical_y_vertices": [284, 284, 295, 295] }
        },
        "product_name": {
          "extracted_string_or_numeric_value": "Advantage Checking",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 315, 315, 189], "vertical_y_vertices": [300, 300, 311, 311] }
        },
        "opened_by": {
          "extracted_string_or_numeric_value": "Courtney Culp",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 580, 580, 490], "vertical_y_vertices": [300, 300, 311, 311] }
        },
        "account_number": {
          "extracted_string_or_numeric_value": "02010277008",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 780, 780, 670], "vertical_y_vertices": [187, 187, 198, 198] }
        },
        "account_tin": {
          "extracted_string_or_numeric_value": "375-52-10882",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 780, 780, 700], "vertical_y_vertices": [203, 203, 214, 214] }
        }
      },
      "owner_1": {
        "name": { "extracted_string_or_numeric_value": "Judith A Grandy", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 290, 290, 189], "vertical_y_vertices": [350, 350, 361, 361] } },
        "street_address": { "extracted_string_or_numeric_value": "3291 18 Mile Rd", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 295, 295, 189], "vertical_y_vertices": [370, 370, 381, 381] } },
        "city_state_zip": { "extracted_string_or_numeric_value": "Marion, ΜΙ 49665", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 300, 300, 189], "vertical_y_vertices": [382, 382, 393, 393] } },
        "title_capacity": { "extracted_string_or_numeric_value": "Joint (Or)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 250, 250, 189], "vertical_y_vertices": [400, 400, 411, 411] } },
        "tax_id_number": { "extracted_string_or_numeric_value": "375-52-1882", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 270, 270, 189], "vertical_y_vertices": [455, 455, 466, 466] } },
        "date_of_birth": { "extracted_string_or_numeric_value": "08/18/1947", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 260, 260, 189], "vertical_y_vertices": [467, 467, 478, 478] } },
        "primary_phone": { "extracted_string_or_numeric_value": "231-743-6686", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 275, 275, 189], "vertical_y_vertices": [479, 479, 490, 490] } },
        "cell_phone": { "extracted_string_or_numeric_value": "(231) 499-3904", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 280, 280, 189], "vertical_y_vertices": [503, 503, 514, 514] } },
        "email_address": { "extracted_string_or_numeric_value": "Judygrandy@hotmail.com", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 710, 710, 570], "vertical_y_vertices": [503, 503, 514, 514] } },
        "id_type": { "extracted_string_or_numeric_value": "Driver's License", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 660, 660, 570], "vertical_y_vertices": [340, 340, 351, 351] } },
        "id_number": { "extracted_string_or_numeric_value": "G653454067645", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 670, 670, 570], "vertical_y_vertices": [364, 364, 375, 375] } },
        "id_issuing_location": { "extracted_string_or_numeric_value": "MI", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 590, 590, 570], "vertical_y_vertices": [376, 376, 387, 387] } },
        "id_expiration": { "extracted_string_or_numeric_value": "08/18/2014", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 640, 640, 570], "vertical_y_vertices": [400, 400, 411, 411] } },
        "verification_unique_identifier": { "extracted_string_or_numeric_value": "Foss", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 600, 600, 570], "vertical_y_vertices": [491, 491, 502, 502] } },
        "ofac_checked": { "extracted_string_or_numeric_value": "True", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 550, 550, 540], "vertical_y_vertices": [515, 515, 525, 525] } },
        "chexsystems_checked": { "extracted_string_or_numeric_value": "True", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660, 660, 650], "vertical_y_vertices": [515, 515, 525, 525] } }
      },
      "owner_2": {
        "name": { "extracted_string_or_numeric_value": "Mark W Kibby", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 280, 280, 189], "vertical_y_vertices": [538, 538, 549, 549] } },
        "po_box": { "extracted_string_or_numeric_value": "297", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 250, 250, 189], "vertical_y_vertices": [562, 562, 573, 573] } },
        "city_state_zip": { "extracted_string_or_numeric_value": "Marion, MI 49665-0297", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 320, 320, 189], "vertical_y_vertices": [580, 580, 591, 591] } },
        "title_capacity": { "extracted_string_or_numeric_value": "Joint (Or)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 250, 250, 189], "vertical_y_vertices": [598, 598, 609, 609] } },
        "tax_id_number": { "extracted_string_or_numeric_value": "366-72-9323", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 270, 270, 189], "vertical_y_vertices": [653, 653, 664, 664] } },
        "date_of_birth": { "extracted_string_or_numeric_value": "08/08/1973", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 260, 260, 189], "vertical_y_vertices": [665, 665, 676, 676] } },
        "id_type": { "extracted_string_or_numeric_value": "Driver's License", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 660, 660, 570], "vertical_y_vertices": [528, 528, 539, 539] } },
        "id_number": { "extracted_string_or_numeric_value": "S221-5597-3288-04", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 800, 800, 660], "vertical_y_vertices": [538, 538, 555, 555] } },
        "id_issuing_location": { "extracted_string_or_numeric_value": "WI", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 620, 620, 570], "vertical_y_vertices": [575, 575, 586, 586] } },
        "id_expiration": { "extracted_string_or_numeric_value": "8/8/27", "optical_extraction_confidence_score": 0.93, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 680, 680, 630], "vertical_y_vertices": [587, 587, 598, 598] } },
        "ofac_checked": { "extracted_string_or_numeric_value": "True", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 550, 550, 540], "vertical_y_vertices": [713, 713, 723, 723] } },
        "chexsystems_checked": { "extracted_string_or_numeric_value": "True", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660, 660, 650], "vertical_y_vertices": [713, 713, 723, 723] } }
      },
      "taxpayer_id_certification": {
        "signature": { "extracted_string_or_numeric_value": "Judith A Grandy", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 420, 420, 180], "vertical_y_vertices": [450, 450, 480, 480] } },
        "date": { "extracted_string_or_numeric_value": "5/9/2019", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [430, 510, 510, 430], "vertical_y_vertices": [450, 450, 480, 480] } },
        "taxpayer_identification_number": { "extracted_string_or_numeric_value": "375-52-1882", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 780, 780, 630], "vertical_y_vertices": [480, 480, 495, 495] } }
      },
      "acknowledgment": {
        "facsimile_allowed": { "extracted_string_or_numeric_value": "True", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 710, 710, 700], "vertical_y_vertices": [800, 800, 810, 810] } },
        "signatures": [
          {
            "signer_name": { "extracted_string_or_numeric_value": "Judith A Grandy", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 300, 300, 180], "vertical_y_vertices": [820, 820, 835, 835] } },
            "signer_title": { "extracted_string_or_numeric_value": "Joint (Or)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 250, 250, 180], "vertical_y_vertices": [836, 836, 847, 847] } },
            "date": { "extracted_string_or_numeric_value": "9/6/2019", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 380, 380, 310], "vertical_y_vertices": [805, 805, 825, 825] } }
          },
          {
            "signer_name": { "extracted_string_or_numeric_value": "Mark W Kibby", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 600, 600, 480], "vertical_y_vertices": [820, 820, 835, 835] } },
            "signer_title": { "extracted_string_or_numeric_value": "Joint (Or)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 550, 550, 480], "vertical_y_vertices": [836, 836, 847, 847] } },
            "date": { "extracted_string_or_numeric_value": "10/21/2019", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 690, 690, 610], "vertical_y_vertices": [805, 805, 825, 825] } }
          }
        ]
      }
    }
  }
]
```