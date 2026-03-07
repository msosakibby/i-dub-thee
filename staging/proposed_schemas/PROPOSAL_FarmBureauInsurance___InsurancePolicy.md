An exhaustive analysis of the provided documents reveals significant structural drift, including the introduction of new policy types (Umbrella vs. Auto), new financial summaries (Transaction Summary vs. Premium Schedule), and evolving declaration formats. The resulting schema accommodates these variations by utilizing optional sub-models and fields, ensuring that data from any of the supplied document layouts can be successfully parsed.

The most complex structural variant is the 2015 renewal for the Farmowners Umbrella Liability Policy (found within the second document set). It contains a detailed Declarations page with a premium schedule, a list of underlying policies, and a schedule of policy forms, making it the ideal candidate for the golden test case. The schema includes two distinct GAAP checksums within the `model_validator`: one for validating the premium schedule against the total premium, and another for reconciling the transaction ledger.

***

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
from math import isclose

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """Encapsulates a single data point with its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class PremiumItem(BaseModel):
    """Represents a single line item in a premium schedule."""
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    amount: ForensicDataEntity

class UnderlyingPolicy(BaseModel):
    """Details of an underlying insurance policy covered by an umbrella policy."""
    model_config = ConfigDict(extra='forbid')
    policy_type: ForensicDataEntity
    insurer: ForensicDataEntity
    policy_number: ForensicDataEntity
    limits_of_liability: Optional[ForensicDataEntity] = None
    bodily_injury_per_person: Optional[ForensicDataEntity] = None
    bodily_injury_per_occurrence: Optional[ForensicDataEntity] = None
    property_damage_per_occurrence: Optional[ForensicDataEntity] = None
    combined_single_limit: Optional[ForensicDataEntity] = None

class Declarations(BaseModel):
    """Contains the core declarations of an umbrella policy."""
    model_config = ConfigDict(extra='forbid')
    business_organization_type: Optional[ForensicDataEntity] = None
    business_profession: Optional[ForensicDataEntity] = None
    each_occurrence_limit: ForensicDataEntity
    aggregate_limit: ForensicDataEntity
    retained_limit: ForensicDataEntity
    underlying_policies: List[UnderlyingPolicy]

class Transaction(BaseModel):
    """Represents a single financial transaction in a ledger."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity
    is_informational_allocation: bool = False

class TransactionsSummary(BaseModel):
    """Summarizes financial transactions over a period."""
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    current_balance: ForensicDataEntity
    balance_as_of_date: ForensicDataEntity
    transactions: List[Transaction]
    next_scheduled_payment: Optional[ForensicDataEntity] = None

class BodilyInjuryLimitOption(BaseModel):
    """Describes an available option for bodily injury liability coverage."""
    model_config = ConfigDict(extra='forbid')
    limit_description: ForensicDataEntity
    price_for_period: ForensicDataEntity
    is_current_selection: bool

class AutoPolicyDetails(BaseModel):
    """Contains details specific to an auto policy."""
    model_config = ConfigDict(extra='forbid')
    bodily_injury_limit_options: List[BodilyInjuryLimitOption]

class TerrorismCoverageNotice(BaseModel):
    """Details from the Terrorism Risk Insurance Act disclosure."""
    model_config = ConfigDict(extra='forbid')
    premium_attributable_to_terrorism: ForensicDataEntity
    issuing_companies: List[ForensicDataEntity]

class PolicyForm(BaseModel):
    """Represents a form or endorsement included in the policy."""
    model_config = ConfigDict(extra='forbid')
    form_number: ForensicDataEntity
    edition_date: ForensicDataEntity
    description: ForensicDataEntity

class FarmBureauInsurancePolicy(BaseModel):
    """
    A resilient schema for Farm Bureau Insurance policy documents, accommodating
    structural variations across different years and policy types (Umbrella, Auto).
    """
    model_config = ConfigDict(extra='forbid')

    policy_number: ForensicDataEntity
    policy_type: ForensicDataEntity
    account_number: Optional[ForensicDataEntity] = None
    named_insureds: List[ForensicDataEntity]
    mailing_address: ForensicDataEntity
    policy_period_from: Optional[ForensicDataEntity] = None
    policy_period_to: Optional[ForensicDataEntity] = None
    effective_date: Optional[ForensicDataEntity] = None
    issue_date: Optional[ForensicDataEntity] = None
    agent_name: Optional[ForensicDataEntity] = None
    agent_number: Optional[ForensicDataEntity] = None
    agent_phone: Optional[ForensicDataEntity] = None

    total_annual_premium: Optional[ForensicDataEntity] = None
    premium_schedule: Optional[List[PremiumItem]] = None

    declarations: Optional[Declarations] = None
    transactions_summary: Optional[TransactionsSummary] = None
    auto_policy_details: Optional[AutoPolicyDetails] = None
    terrorism_coverage_notice: Optional[TerrorismCoverageNotice] = None
    forms_schedule: Optional[List[PolicyForm]] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'FarmBureauInsurancePolicy':
        """
        Performs double-entry accounting checks on financial data within the policy.
        1. Validates that the sum of premium items equals the total annual premium.
        2. Validates that transaction ledger balances are consistent.
        """
        # Check 1: Premium Schedule vs. Total Premium
        if self.premium_schedule and self.total_annual_premium:
            if not all(isinstance(item.amount.extracted_string_or_numeric_value, (int, float)) for item in self.premium_schedule):
                raise ValueError("All premium schedule amounts must be numeric for validation.")
            if not isinstance(self.total_annual_premium.extracted_string_or_numeric_value, (int, float)):
                raise ValueError("Total annual premium must be numeric for validation.")

            calculated_total = sum(item.amount.extracted_string_or_numeric_value for item in self.premium_schedule)
            declared_total = self.total_annual_premium.extracted_string_or_numeric_value
            
            if not isclose(calculated_total, declared_total, rel_tol=1e-9, abs_tol=1e-9):
                raise ValueError(f"Premium schedule total ({calculated_total}) does not match declared total annual premium ({declared_total}).")

        # Check 2: Transaction Ledger
        if self.transactions_summary:
            summary = self.transactions_summary
            
            if not isinstance(summary.previous_balance.extracted_string_or_numeric_value, (int, float)) or \
               not isinstance(summary.current_balance.extracted_string_or_numeric_value, (int, float)) or \
               not all(isinstance(t.amount.extracted_string_or_numeric_value, (int, float)) for t in summary.transactions):
                 raise ValueError("All transaction summary financial values must be numeric for validation.")

            balance_affecting_transactions = [t for t in summary.transactions if not t.is_informational_allocation]
            
            calculated_balance = summary.previous_balance.extracted_string_or_numeric_value
            for t in balance_affecting_transactions:
                calculated_balance += t.amount.extracted_string_or_numeric_value

            declared_balance = summary.current_balance.extracted_string_or_numeric_value
            
            if not isclose(calculated_balance, declared_balance, rel_tol=1e-9, abs_tol=1e-9):
                raise ValueError(
                    f"Transaction ledger calculation error. Starting with {summary.previous_balance.extracted_string_or_numeric_value}, "
                    f"the calculated balance is {calculated_balance}, but the declared current balance is {declared_balance}."
                )
                
        return self
```
***
```json
[
  {
    "test_identifier": "doc_2_2015_renewal_umbrella_complex",
    "should_pass": true,
    "taxonomy_lane": "FarmBureauInsurancePolicy",
    "binary_header_simulation": "25504446",
    "payload": {
      "policy_number": {
        "extracted_string_or_numeric_value": "U -2850613-13",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 810], "vertical_y_vertices": [40, 55] }
      },
      "policy_type": {
        "extracted_string_or_numeric_value": "FARMOWNERS UMBRELLA LIABILITY POLICY",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 650], "vertical_y_vertices": [58, 70] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "C000974783-001-00001",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 810], "vertical_y_vertices": [160, 170] }
      },
      "named_insureds": [
        {
          "extracted_string_or_numeric_value": "GRANDY KEITH",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 320], "vertical_y_vertices": [180, 190] }
        },
        {
          "extracted_string_or_numeric_value": "GRANDY JUDITH",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 320], "vertical_y_vertices": [192, 202] }
        }
      ],
      "mailing_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 320], "vertical_y_vertices": [204, 226] }
      },
      "policy_period_from": {
        "extracted_string_or_numeric_value": "05/08/2015",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 550], "vertical_y_vertices": [110, 120] }
      },
      "policy_period_to": {
        "extracted_string_or_numeric_value": "05/08/2016",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 690], "vertical_y_vertices": [110, 120] }
      },
      "effective_date": {
        "extracted_string_or_numeric_value": "MAY 8, 2015",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 810], "vertical_y_vertices": [98, 108] }
      },
      "issue_date": {
        "extracted_string_or_numeric_value": "APRIL 9, 2015",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 810], "vertical_y_vertices": [136, 146] }
      },
      "agent_name": {
        "extracted_string_or_numeric_value": "LEE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 650], "vertical_y_vertices": [198, 208] }
      },
      "agent_number": {
        "extracted_string_or_numeric_value": "4457",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 720], "vertical_y_vertices": [198, 208] }
      },
      "agent_phone": {
        "extracted_string_or_numeric_value": "231-832-3283",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 810], "vertical_y_vertices": [210, 220] }
      },
      "total_annual_premium": {
        "extracted_string_or_numeric_value": 301.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 800], "vertical_y_vertices": [540, 550] }
      },
      "premium_schedule": [
        {
          "description": {
            "extracted_string_or_numeric_value": "Premium for Farmowners Liability",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 400], "vertical_y_vertices": [520, 530] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 301.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 800], "vertical_y_vertices": [520, 530] }
          }
        }
      ],
      "declarations": {
        "business_organization_type": {
          "extracted_string_or_numeric_value": "INDIVIDUAL",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 400], "vertical_y_vertices": [325, 335] }
        },
        "business_profession": {
          "extracted_string_or_numeric_value": "RETIRED/STORE OWNER",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 550], "vertical_y_vertices": [340, 350] }
        },
        "each_occurrence_limit": {
          "extracted_string_or_numeric_value": 2000000.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 380], "vertical_y_vertices": [380, 390] }
        },
        "aggregate_limit": {
          "extracted_string_or_numeric_value": 2000000.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 600], "vertical_y_vertices": [380, 390] }
        },
        "retained_limit": {
          "extracted_string_or_numeric_value": 250.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 800], "vertical_y_vertices": [380, 390] }
        },
        "underlying_policies": [
          {
            "policy_type": { "extracted_string_or_numeric_value": "FARMOWNERS LIABILITY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [175, 250], "vertical_y_vertices": [250, 270] } },
            "insurer": { "extracted_string_or_numeric_value": "FARM BUREAU MUTUAL INSURANCE COMPANY OF MICHIGAN", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 680], "vertical_y_vertices": [250, 270] } },
            "policy_number": { "extracted_string_or_numeric_value": "FO 2846580", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770], "vertical_y_vertices": [250, 270] } },
            "limits_of_liability": { "extracted_string_or_numeric_value": "300,000 each occurrence", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 450], "vertical_y_vertices": [250, 270] } }
          },
          {
            "policy_type": { "extracted_string_or_numeric_value": "AUTOMOBILE LIABILITY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [175, 250], "vertical_y_vertices": [410, 420] } },
            "insurer": { "extracted_string_or_numeric_value": "FARM BUREAU MUTUAL INSURANCE COMPANY OF MICHIGAN", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 680], "vertical_y_vertices": [410, 430] } },
            "policy_number": { "extracted_string_or_numeric_value": "1 0470T76", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770], "vertical_y_vertices": [410, 420] } },
            "bodily_injury_per_person": { "extracted_string_or_numeric_value": 500000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 450], "vertical_y_vertices": [425, 435] } },
            "bodily_injury_per_occurrence": { "extracted_string_or_numeric_value": 500000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 450], "vertical_y_vertices": [437, 447] } },
            "property_damage_per_occurrence": { "extracted_string_or_numeric_value": 1000000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 450], "vertical_y_vertices": [460, 470] } }
          },
          {
            "policy_type": { "extracted_string_or_numeric_value": "AUTOMOBILE LIABILITY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [175, 250], "vertical_y_vertices": [510, 520] } },
            "insurer": { "extracted_string_or_numeric_value": "PROGRESSIVE MICHIGAN INSURANCE COMPANY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 680], "vertical_y_vertices": [510, 530] } },
            "policy_number": { "extracted_string_or_numeric_value": "28727188", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770], "vertical_y_vertices": [510, 520] } },
            "combined_single_limit": { "extracted_string_or_numeric_value": 500000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 450], "vertical_y_vertices": [550, 560] } }
          }
        ]
      },
      "terrorism_coverage_notice": {
        "premium_attributable_to_terrorism": {
          "extracted_string_or_numeric_value": 0.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [660, 670] }
        },
        "issuing_companies": [
          {
            "extracted_string_or_numeric_value": "Farm Bureau General Insurance Company of Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 520], "vertical_y_vertices": [690, 700] }
          },
          {
            "extracted_string_or_numeric_value": "Farm Bureau Mutual Insurance Company of Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 520], "vertical_y_vertices": [705, 715] }
          }
        ]
      },
      "forms_schedule": [
        {
          "form_number": { "extracted_string_or_numeric_value": "926", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 240], "vertical_y_vertices": [280, 290] } },
          "edition_date": { "extracted_string_or_numeric_value": "01 10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 360], "vertical_y_vertices": [280, 290] } },
          "description": { "extracted_string_or_numeric_value": "Farmowners Umbrella Liability Policy", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 650], "vertical_y_vertices": [280, 290] } }
        },
        {
          "form_number": { "extracted_string_or_numeric_value": "PC 205", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 250], "vertical_y_vertices": [500, 510] } },
          "edition_date": { "extracted_string_or_numeric_value": "01 14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 360], "vertical_y_vertices": [500, 510] } },
          "description": { "extracted_string_or_numeric_value": "Conditional Exclusion of Terrorism", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 650], "vertical_y_vertices": [500, 510] } }
        }
      ]
    }
  }
]
```