An expert forensic data architect, I have analyzed the provided documents and designed a resilient Pydantic V2 schema to accommodate all structural variations. The schema correctly models the core policy declarations, associated schedules, and the complex transaction summary, incorporating a robust double-entry GAAP checksum validator as required.

### BLOCK 1: Python Pydantic V2 Schema

```python
import math
from decimal import Decimal, InvalidOperation
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon for the spatial coordinates of an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data entity, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class FormScheduleItem(BaseModel):
    """Represents a single form or endorsement listed in the policy's Forms Schedule."""
    model_config = ConfigDict(extra='forbid')
    is_enclosed: Optional[ForensicDataEntity] = None
    form_number: ForensicDataEntity
    edition_date: ForensicDataEntity
    form_name: ForensicDataEntity

class UnderlyingPolicyItem(BaseModel):
    """Represents a single underlying insurance policy providing primary coverage."""
    model_config = ConfigDict(extra='forbid')
    policy_type: ForensicDataEntity
    insurer: ForensicDataEntity
    policy_number: ForensicDataEntity
    limit_of_liability: Optional[ForensicDataEntity] = None
    bodily_injury_limit_person: Optional[ForensicDataEntity] = None
    bodily_injury_limit_occurrence: Optional[ForensicDataEntity] = None
    property_damage_limit_occurrence: Optional[ForensicDataEntity] = None

class TransactionItem(BaseModel):
    """Represents a single line item in the transaction summary."""
    model_config = ConfigDict(extra='forbid')
    effective_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class TransactionSummary(BaseModel):
    """Represents the account transaction summary section."""
    model_config = ConfigDict(extra='forbid')
    account_holder_name_1: ForensicDataEntity
    account_holder_name_2: Optional[ForensicDataEntity] = None
    summary_date: ForensicDataEntity
    previous_account_balance: ForensicDataEntity
    transactions: List[TransactionItem]
    account_balance: ForensicDataEntity
    next_scheduled_payment: Optional[ForensicDataEntity] = None

class PremiumSchedule(BaseModel):
    """Represents the premium breakdown for the policy."""
    model_config = ConfigDict(extra='forbid')
    premium_for_farmowners_liability: ForensicDataEntity
    total_annual_premium: ForensicDataEntity

class FarmBureauInsurancePolicyDisclosure(BaseModel):
    """
    A resilient schema for Farm Bureau Insurance policy documents, including declarations,
    schedules, and transaction summaries.
    """
    model_config = ConfigDict(extra='forbid')

    # Main Declarations
    policy_number: ForensicDataEntity
    policy_period_from: ForensicDataEntity
    policy_period_to: ForensicDataEntity
    effective_date: ForensicDataEntity
    issue_date: ForensicDataEntity
    named_insured_name_1: ForensicDataEntity
    named_insured_name_2: Optional[ForensicDataEntity] = None
    mailing_address: ForensicDataEntity
    account_number: ForensicDataEntity
    annual_premium: ForensicDataEntity
    payment_plan: ForensicDataEntity
    agent_name: ForensicDataEntity
    agent_number: ForensicDataEntity
    agent_phone_number: ForensicDataEntity
    business_organization_type: ForensicDataEntity
    business_profession: ForensicDataEntity
    each_occurrence_limit: ForensicDataEntity
    aggregate_limit: ForensicDataEntity
    retained_limit: ForensicDataEntity
    
    # Schedules and Optional Sections
    premium_schedule: PremiumSchedule
    terrorism_premium: Optional[ForensicDataEntity] = None
    forms_schedule: List[FormScheduleItem]
    underlying_policies: List[UnderlyingPolicyItem]
    transaction_summary: Optional[TransactionSummary] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'FarmBureauInsurancePolicyDisclosure':
        """
        Performs double-entry GAAP mathematical checksums on financial sections
        of the policy document.
        """
        # Check 1: Premium Schedule consistency.
        try:
            # In this document, there's only one premium item, so it should equal the total.
            # This logic can be expanded to sum multiple items if the structure changes.
            item_premium = Decimal(str(self.premium_schedule.premium_for_farmowners_liability.extracted_string_or_numeric_value))
            total_premium = Decimal(str(self.premium_schedule.total_annual_premium.extracted_string_or_numeric_value))
            
            if not math.isclose(item_premium, total_premium):
                raise ValueError(f"Premium schedule checksum failed: Sum of items ({item_premium}) does not equal total premium ({total_premium}).")
        except (InvalidOperation, TypeError) as e:
            raise ValueError(f"Could not perform premium schedule checksum due to invalid data: {e}")

        # Check 2: Transaction Summary balance calculation.
        if self.transaction_summary:
            try:
                summary = self.transaction_summary
                previous_balance = Decimal(str(summary.previous_account_balance.extracted_string_or_numeric_value))
                ending_balance = Decimal(str(summary.account_balance.extracted_string_or_numeric_value))
                
                payment_transactions = []
                applied_transactions = []

                for t in summary.transactions:
                    desc = str(t.description.extracted_string_or_numeric_value).upper()
                    amount_val = t.amount.extracted_string_or_numeric_value
                    
                    # Normalize amount to a Decimal, handling string formats like '1,234.56-'
                    if isinstance(amount_val, str):
                        amount_str = amount_val.replace(',', '').replace('$', '').strip()
                        if amount_str.endswith('-'):
                            amount_str = '-' + amount_str[:-1]
                        amount = Decimal(amount_str)
                    else:
                        amount = Decimal(str(amount_val))

                    if 'PAYMENT RECEIVED' in desc:
                        payment_transactions.append(amount)
                    elif 'APPLIED TO' in desc:
                        applied_transactions.append(amount)
                
                # Check 2a: Payment application consistency (memos must sum to payment).
                # Payments are credits (negative), applications are shown as debits (also negative in this doc).
                # We compare the absolute values.
                total_payment = sum(abs(p) for p in payment_transactions)
                total_applied = sum(abs(a) for a in applied_transactions)
                
                if not math.isclose(total_payment, total_applied, rel_tol=1e-9, abs_tol=1e-9):
                    raise ValueError(f"Transaction summary checksum failed: Total payments ({total_payment}) does not match total applied amounts ({total_applied}).")
                    
                # Check 2b: Main account balance (Start Balance + Credits - Debits = End Balance).
                # Here, only payments affect the balance; applications are memos.
                calculated_balance = previous_balance + sum(payment_transactions)
                
                if not math.isclose(calculated_balance, ending_balance, rel_tol=1e-9, abs_tol=1e-9):
                    raise ValueError(f"Transaction summary checksum failed: Calculated balance ({calculated_balance:.2f}) does not match stated account balance ({ending_balance:.2f}).")

            except (InvalidOperation, TypeError, IndexError) as e:
                raise ValueError(f"Could not perform transaction summary checksum due to invalid data: {e}")

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "FarmBureau_UmbrellaPolicy_With_TransactionSummary",
    "should_pass": true,
    "taxonomy_lane": "FarmBureauInsurancePolicyDisclosure",
    "binary_header_simulation": "25504446",
    "payload": {
      "policy_number": {
        "extracted_string_or_numeric_value": "U -2850613-14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [699, 819],
          "vertical_y_vertices": [45, 69]
        }
      },
      "policy_period_from": {
        "extracted_string_or_numeric_value": "05/08/2016",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [382, 558],
          "vertical_y_vertices": [103, 116]
        }
      },
      "policy_period_to": {
        "extracted_string_or_numeric_value": "05/08/2017",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [565, 668],
          "vertical_y_vertices": [103, 116]
        }
      },
      "effective_date": {
        "extracted_string_or_numeric_value": "MAY 8, 2016",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [629, 720],
          "vertical_y_vertices": [86, 99]
        }
      },
      "issue_date": {
        "extracted_string_or_numeric_value": "MARCH 30, 2016",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [629, 749],
          "vertical_y_vertices": [139, 150]
        }
      },
      "named_insured_name_1": {
        "extracted_string_or_numeric_value": "GRANDY KEITH",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [222, 320],
          "vertical_y_vertices": [169, 180]
        }
      },
      "named_insured_name_2": {
        "extracted_string_or_numeric_value": "GRANDY JUDITH",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [222, 328],
          "vertical_y_vertices": [183, 194]
        }
      },
      "mailing_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [222, 340],
          "vertical_y_vertices": [197, 222]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "C000974783-001-00001",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [629, 810],
          "vertical_y_vertices": [167, 178]
        }
      },
      "annual_premium": {
        "extracted_string_or_numeric_value": 250.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [708, 756],
          "vertical_y_vertices": [153, 164]
        }
      },
      "payment_plan": {
        "extracted_string_or_numeric_value": "FULL PAY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [629, 691],
          "vertical_y_vertices": [181, 192]
        }
      },
      "agent_name": {
        "extracted_string_or_numeric_value": "LEE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [629, 654],
          "vertical_y_vertices": [209, 220]
        }
      },
      "agent_number": {
        "extracted_string_or_numeric_value": "#4457",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 738],
          "vertical_y_vertices": [209, 220]
        }
      },
      "agent_phone_number": {
        "extracted_string_or_numeric_value": "231-832-3283",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [629, 718],
          "vertical_y_vertices": [223, 234]
        }
      },
      "business_organization_type": {
        "extracted_string_or_numeric_value": "INDIVIDUAL",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178, 378],
          "vertical_y_vertices": [318, 328]
        }
      },
      "business_profession": {
        "extracted_string_or_numeric_value": "RETIRED/STORE OWNER",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178, 548],
          "vertical_y_vertices": [332, 342]
        }
      },
      "each_occurrence_limit": {
        "extracted_string_or_numeric_value": 2000000.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [174, 410],
          "vertical_y_vertices": [382, 393]
        }
      },
      "aggregate_limit": {
        "extracted_string_or_numeric_value": 2000000.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [420, 608],
          "vertical_y_vertices": [382, 393]
        }
      },
      "retained_limit": {
        "extracted_string_or_numeric_value": 250.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [618, 780],
          "vertical_y_vertices": [382, 393]
        }
      },
      "premium_schedule": {
        "premium_for_farmowners_liability": {
          "extracted_string_or_numeric_value": 250.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [199, 756],
            "vertical_y_vertices": [508, 519]
          }
        },
        "total_annual_premium": {
          "extracted_string_or_numeric_value": 250.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [199, 756],
            "vertical_y_vertices": [529, 540]
          }
        }
      },
      "terrorism_premium": {
        "extracted_string_or_numeric_value": 0.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [199, 660],
          "vertical_y_vertices": [679, 690]
        }
      },
      "forms_schedule": [
        {
          "form_number": { "extracted_string_or_numeric_value": "PC 203", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [248, 290], "vertical_y_vertices": [471, 481] } },
          "is_enclosed": { "extracted_string_or_numeric_value": "✓", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 231], "vertical_y_vertices": [471, 481] } },
          "edition_date": { "extracted_string_or_numeric_value": "01 15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [315, 348], "vertical_y_vertices": [471, 481] } },
          "form_name": { "extracted_string_or_numeric_value": "Exclusion of Punitive Damages-Cert. Act of Terrorism", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [372, 678], "vertical_y_vertices": [471, 481] } }
        },
        {
          "form_number": { "extracted_string_or_numeric_value": "PC 204", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [248, 290], "vertical_y_vertices": [490, 500] } },
          "is_enclosed": { "extracted_string_or_numeric_value": "✓", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 231], "vertical_y_vertices": [490, 500] } },
          "edition_date": { "extracted_string_or_numeric_value": "01 15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [315, 348], "vertical_y_vertices": [490, 500] } },
          "form_name": { "extracted_string_or_numeric_value": "Limited Terrorism Exclusion; Cap on Losses", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [372, 640], "vertical_y_vertices": [490, 500] } }
        }
      ],
      "underlying_policies": [
        {
          "policy_type": { "extracted_string_or_numeric_value": "FARMOWNERS LIABILITY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [199, 270], "vertical_y_vertices": [240, 265] } },
          "insurer": { "extracted_string_or_numeric_value": "FARM BUREAU MUTUAL INSURANCE COMPANY OF MICHIGAN", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [545, 678], "vertical_y_vertices": [248, 273] } },
          "policy_number": { "extracted_string_or_numeric_value": "FO 2846580", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [710, 775], "vertical_y_vertices": [248, 258] } },
          "limit_of_liability": { "extracted_string_or_numeric_value": "300,000 each occurrence", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 480], "vertical_y_vertices": [248, 258] } }
        },
        {
          "policy_type": { "extracted_string_or_numeric_value": "AUTOMOBILE LIABILITY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [184, 310], "vertical_y_vertices": [420, 430] } },
          "insurer": { "extracted_string_or_numeric_value": "FARM BUREAU MUTUAL INSURANCE COMPANY OF MICHIGAN", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [545, 678], "vertical_y_vertices": [440, 465] } },
          "policy_number": { "extracted_string_or_numeric_value": "1 0470T76", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [709, 775], "vertical_y_vertices": [420, 430] } },
          "bodily_injury_limit_person": { "extracted_string_or_numeric_value": 500000.0, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 440], "vertical_y_vertices": [435, 445] } },
          "bodily_injury_limit_occurrence": { "extracted_string_or_numeric_value": 500000.0, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 440], "vertical_y_vertices": [450, 460] } },
          "property_damage_limit_occurrence": { "extracted_string_or_numeric_value": 1000000.0, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 440], "vertical_y_vertices": [475, 485] } }
        }
      ],
      "transaction_summary": {
        "account_holder_name_1": { "extracted_string_or_numeric_value": "GRANDY KEITH ARTHUR", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [188, 360], "vertical_y_vertices": [108, 118] } },
        "account_holder_name_2": { "extracted_string_or_numeric_value": "GRANDY JUDITH", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [188, 285], "vertical_y_vertices": [120, 130] } },
        "summary_date": { "extracted_string_or_numeric_value": "05/11/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 520], "vertical_y_vertices": [185, 195] } },
        "previous_account_balance": { "extracted_string_or_numeric_value": 3265.56, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 800], "vertical_y_vertices": [255, 265] } },
        "transactions": [
          {
            "effective_date": { "extracted_string_or_numeric_value": "04/20/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 240], "vertical_y_vertices": [280, 290] } },
            "description": { "extracted_string_or_numeric_value": "PAYMENT RECEIVED THANK YOU", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 460], "vertical_y_vertices": [280, 290] } },
            "amount": { "extracted_string_or_numeric_value": -1834.06, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 800], "vertical_y_vertices": [280, 290] } }
          },
          {
            "effective_date": { "extracted_string_or_numeric_value": "04/20/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 240], "vertical_y_vertices": [295, 305] } },
            "description": { "extracted_string_or_numeric_value": "APPLIED TO FAMILY AUTO 100-0470T76-18", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 550], "vertical_y_vertices": [295, 305] } },
            "amount": { "extracted_string_or_numeric_value": -647.56, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 660], "vertical_y_vertices": [295, 305] } }
          },
          {
            "effective_date": { "extracted_string_or_numeric_value": "04/20/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 240], "vertical_y_vertices": [310, 320] } },
            "description": { "extracted_string_or_numeric_value": "APPLIED TO FARMOWNERS FO -2846580-14", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 550], "vertical_y_vertices": [310, 320] } },
            "amount": { "extracted_string_or_numeric_value": -1181.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 660], "vertical_y_vertices": [310, 320] } }
          },
          {
            "effective_date": { "extracted_string_or_numeric_value": "04/20/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 240], "vertical_y_vertices": [325, 335] } },
            "description": { "extracted_string_or_numeric_value": "APPLIED TO PAYMENT PLAN FEE", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 500], "vertical_y_vertices": [325, 335] } },
            "amount": { "extracted_string_or_numeric_value": -5.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 660], "vertical_y_vertices": [325, 335] } }
          }
        ],
        "account_balance": { "extracted_string_or_numeric_value": 1431.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 800], "vertical_y_vertices": [360, 370] } },
        "next_scheduled_payment": { "extracted_string_or_numeric_value": 1181.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 550], "vertical_y_vertices": [450, 460] } }
      }
    }
  }
]
```