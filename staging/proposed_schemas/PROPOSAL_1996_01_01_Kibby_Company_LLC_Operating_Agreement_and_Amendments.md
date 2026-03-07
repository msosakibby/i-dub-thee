An exceptional forensic architect recognizes that document structures are not static; they are living artifacts that evolve. The provided documents, spanning from a 1996 LLC formation to a 2024 succession amendment, showcase significant structural drift. The following Pydantic V2 schema is engineered to capture this evolution, treating each major document type as a potential, optional substructure within a unified model. This Zero-Trust approach ensures that no single document's layout is assumed to be the "correct" one, allowing for resilient data extraction across all variants.

The most complex variant identified is the 2024 amendment, which introduces a multi-level heir and contingent beneficiary structure, complete with percentage shares that are ideal for mathematical validation. The JSON test case is built from this document to rigorously test the schema's flexibility and the integrity of its internal checksums.

***

```python
# BLOCK 1 (Python Pydantic V2)

from typing import List, Optional, Union
from pydantic import BaseModel, Field, ConfigDict, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Signatory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    capacity: Optional[ForensicDataEntity] = None

class InitialMember(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    interest_in_capital: ForensicDataEntity
    initial_capital_contribution: ForensicDataEntity

class FormationDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    principal_place_of_business: ForensicDataEntity
    purpose: ForensicDataEntity
    initial_members: List[InitialMember]

class MembershipDecision(BaseModel):
    model_config = ConfigDict(extra='forbid')
    background_facts: List[ForensicDataEntity]
    resolution: ForensicDataEntity
    distributed_asset_parcel_id: Optional[ForensicDataEntity] = None

class Heir(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    share_percentage: ForensicDataEntity

class SuccessionAmendment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    designated_heir: Heir
    contingent_beneficiaries: List[Heir]
    transfer_procedure: ForensicDataEntity

class TransactionConsent(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transaction_type: ForensicDataEntity
    counterparty: ForensicDataEntity
    resolution: ForensicDataEntity

class PreparerInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    attorney_name: ForensicDataEntity
    firm_name: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: ForensicDataEntity

class KibbyCompanyLLCGovernanceDocument(BaseModel):
    """
    A schema for the Kibby Company LLC Operating Agreement and its subsequent
    amendments, decisions, and consents, accommodating structural drift over time.
    """
    model_config = ConfigDict(extra='forbid')

    document_title: ForensicDataEntity
    execution_date: ForensicDataEntity
    company_name: ForensicDataEntity
    signatories: List[Signatory]
    
    # Optional fields to handle structural variants
    formation_details: Optional[FormationDetails] = None
    membership_decision: Optional[MembershipDecision] = None
    succession_amendment: Optional[SuccessionAmendment] = None
    transaction_consent: Optional[TransactionConsent] = None
    preparer: Optional[PreparerInfo] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'KibbyCompanyLLCGovernanceDocument':
        """
        Performs double-entry GAAP-style mathematical checksums on financial percentages.
        """
        # 1. Validate Initial Member Capital Percentages
        if self.formation_details and self.formation_details.initial_members:
            total_interest = sum(
                member.interest_in_capital.extracted_string_or_numeric_value
                for member in self.formation_details.initial_members
                if isinstance(member.interest_in_capital.extracted_string_or_numeric_value, (int, float))
            )
            if not math.isclose(total_interest, 100.0, rel_tol=1e-9):
                raise ValueError(f"Initial member capital interests sum to {total_interest}, not 100.")

        # 2. Validate Succession Amendment Percentages
        if self.succession_amendment:
            # Check primary heir
            primary_heir_share = self.succession_amendment.designated_heir.share_percentage.extracted_string_or_numeric_value
            if isinstance(primary_heir_share, (int, float)) and not math.isclose(primary_heir_share, 100.0, rel_tol=1e-9):
                raise ValueError(f"Designated heir share is {primary_heir_share}%, not 100%.")

            # Check contingent beneficiaries
            total_contingent_share = sum(
                beneficiary.share_percentage.extracted_string_or_numeric_value
                for beneficiary in self.succession_amendment.contingent_beneficiaries
                if isinstance(beneficiary.share_percentage.extracted_string_or_numeric_value, (int, float))
            )
            if not math.isclose(total_contingent_share, 100.0, rel_tol=1e-9):
                raise ValueError(f"Contingent beneficiary shares sum to {total_contingent_share}%, not 100%.")
                
        return self
```

```json
# BLOCK 2 (JSON Test Registry)
[
  {
    "test_identifier": "kibby_llc_amendment_20241028_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "KibbyCompanyLLCGovernanceDocument",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "AMENDMENT TO THE OPERATING AGREEMENT OF KIBBY COMPANY, L.L.C.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 800],
          "vertical_y_vertices": [50, 70]
        }
      },
      "execution_date": {
        "extracted_string_or_numeric_value": "2024-10-28",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 850],
          "vertical_y_vertices": [100, 115]
        }
      },
      "company_name": {
        "extracted_string_or_numeric_value": "Kibby Company, L.L.C.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 700],
          "vertical_y_vertices": [80, 95]
        }
      },
      "signatories": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Judith A. Grandy",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 350],
              "vertical_y_vertices": [850, 870]
            }
          },
          "capacity": {
            "extracted_string_or_numeric_value": "Sole Member, Kibby Company, L.L.C.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 450],
              "vertical_y_vertices": [875, 890]
            }
          }
        }
      ],
      "formation_details": null,
      "membership_decision": null,
      "transaction_consent": null,
      "preparer": null,
      "succession_amendment": {
        "designated_heir": {
          "name": {
            "extracted_string_or_numeric_value": "Mark William Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [250, 500],
              "vertical_y_vertices": [400, 415]
            }
          },
          "share_percentage": {
            "extracted_string_or_numeric_value": 100.0,
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [400, 450],
              "vertical_y_vertices": [420, 435]
            }
          }
        },
        "contingent_beneficiaries": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Cole Mark Sosa-Kibby",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [500, 700],
                "vertical_y_vertices": [600, 615]
              }
            },
            "share_percentage": {
              "extracted_string_or_numeric_value": 50.0,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [800, 850],
                "vertical_y_vertices": [620, 635]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Parker Erik Sosa-Kibby",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [710, 900],
                "vertical_y_vertices": [600, 615]
              }
            },
            "share_percentage": {
              "extracted_string_or_numeric_value": 50.0,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [800, 850],
                "vertical_y_vertices": [640, 655]
              }
            }
          }
        ],
        "transfer_procedure": {
          "extracted_string_or_numeric_value": "The transfer of ownership to Mark shall be initiated, reviewed, and executed within three (3) business days of Judith A. Grandy's passing. This process shall be overseen by the executor of her will to ensure compliance with the terms set forth herein and to facilitate a smooth transition of ownership.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 900],
            "vertical_y_vertices": [500, 580]
          }
        }
      }
    }
  }
]
```