An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided document. Below is the resilient Pydantic V2 schema and a corresponding JSON test case designed to accommodate the document's structural realities and ensure data integrity through mathematical validation.

### BLOCK 1: Python Pydantic V2 Schema

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError
from typing import List, Optional, Union
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

class TransactionsSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_fees_for_this_period: Optional[ForensicDataEntity] = None
    total_interest_for_this_period: Optional[ForensicDataEntity] = None

class YearToDateTotals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    year: Optional[ForensicDataEntity] = None
    total_fees_charged_in_year: Optional[ForensicDataEntity] = None
    total_interest_charged_in_year: Optional[ForensicDataEntity] = None

class ActivityDetailItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    original_promotion_amount: Optional[ForensicDataEntity] = None
    promo_trans_date: Optional[ForensicDataEntity] = None
    previous_balance: Optional[ForensicDataEntity] = None
    payments_and_other_credits: Optional[ForensicDataEntity] = None
    purchases_cash_adv_fees_other_debits: Optional[ForensicDataEntity] = None
    interest_charged: Optional[ForensicDataEntity] = None
    new_balance: Optional[ForensicDataEntity] = None
    promotion_minimum_payment_due: Optional[ForensicDataEntity] = None
    deferred_interest_charges: Optional[ForensicDataEntity] = None
    promotion_expiration_date: Optional[ForensicDataEntity] = None

class InterestChargeItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    type_of_balance: ForensicDataEntity
    annual_percentage_rate_apr: ForensicDataEntity
    balance_subject_to_interest_rate: ForensicDataEntity
    interest_charge: ForensicDataEntity

class ExpiringReward(BaseModel):
    model_config = ConfigDict(extra='forbid')
    amount: ForensicDataEntity
    expiration_date: ForensicDataEntity

class RewardsSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_dollars_spent_balance: Optional[ForensicDataEntity] = None
    net_eligible_dollars_spent: Optional[ForensicDataEntity] = None
    adjusted_dollars_spent_balance: Optional[ForensicDataEntity] = None
    expired_dollars_spent_balance: Optional[ForensicDataEntity] = None
    redeemed_dollars_spent_balance: Optional[ForensicDataEntity] = None
    bonus_dollars_accrued: Optional[ForensicDataEntity] = None
    ending_dollars_spent_balance: Optional[ForensicDataEntity] = None
    dollars_spent_balance_expiring_on: Optional[List[ExpiringReward]] = None

class CreditCardStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_number: Optional[ForensicDataEntity] = None
    transactions_summary: Optional[TransactionsSummary] = None
    year_to_date_totals: Optional[YearToDateTotals] = None
    activity_details: Optional[List[ActivityDetailItem]] = None
    activity_details_total: Optional[ActivityDetailItem] = None
    interest_charge_calculation: Optional[List[InterestChargeItem]] = None
    rewards_summary: Optional[RewardsSummary] = None
    page_info: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def double_entry_gaap_checksum(self) -> 'CreditCardStatement':
        
        def get_val(entity: Optional[ForensicDataEntity]) -> float:
            if entity is None or entity.extracted_string_or_numeric_value is None:
                return 0.0
            
            val = entity.extracted_string_or_numeric_value
            if isinstance(val, (int, float)):
                return float(val)
            
            val_str = str(val).strip().replace('$', '').replace(',', '')
            if not val_str:
                return 0.0
            
            if val_str.endswith('-'):
                return -float(val_str[:-1])
            if val_str.startswith('(') and val_str.endswith(')'):
                return -float(val_str[1:-1])
            
            return float(val_str)

        tolerance = 0.01

        # Check 1: Activity Details Total Row Calculation
        if self.activity_details_total:
            total = self.activity_details_total
            prev_bal = get_val(total.previous_balance)
            payments = get_val(total.payments_and_other_credits)
            debits = get_val(total.purchases_cash_adv_fees_other_debits)
            interest = get_val(total.interest_charged)
            new_bal = get_val(total.new_balance)

            calculated_new_balance = prev_bal + payments + debits + interest
            if not math.isclose(calculated_new_balance, new_bal, abs_tol=tolerance):
                raise ValueError(f"Activity total checksum failed: {prev_bal} + {payments} + {debits} + {interest} = {calculated_new_balance}, expected {new_bal}")

        # Check 2: Rewards Summary Calculation
        if self.rewards_summary:
            rewards = self.rewards_summary
            prev_spent = get_val(rewards.previous_dollars_spent_balance)
            net_eligible = get_val(rewards.net_eligible_dollars_spent)
            adjusted = get_val(rewards.adjusted_dollars_spent_balance)
            expired = get_val(rewards.expired_dollars_spent_balance)
            redeemed = get_val(rewards.redeemed_dollars_spent_balance)
            bonus = get_val(rewards.bonus_dollars_accrued)
            ending_bal = get_val(rewards.ending_dollars_spent_balance)

            calculated_ending_balance = prev_spent + net_eligible + adjusted - expired - redeemed + bonus
            if not math.isclose(calculated_ending_balance, ending_bal, abs_tol=tolerance):
                raise ValueError(f"Rewards summary checksum failed: {prev_spent} + {net_eligible} + {adjusted} - {expired} - {redeemed} + {bonus} = {calculated_ending_balance}, expected {ending_bal}")

        # Check 3: Interest Charge Calculation vs Summary
        if self.interest_charge_calculation and self.transactions_summary:
            total_interest_from_calc = sum(get_val(item.interest_charge) for item in self.interest_charge_calculation)
            total_interest_from_summary = get_val(self.transactions_summary.total_interest_for_this_period)
            
            if not math.isclose(total_interest_from_calc, total_interest_from_summary, abs_tol=tolerance):
                raise ValueError(f"Interest charge checksum failed: Sum of interest charges ({total_interest_from_calc}) does not match total interest for period ({total_interest_from_summary})")

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "complex_credit_card_statement_with_rewards_and_activity",
    "should_pass": true,
    "taxonomy_lane": "CreditCardStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "7198",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [299, 335],
          "vertical_y_vertices": [26, 38]
        }
      },
      "transactions_summary": {
        "total_fees_for_this_period": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [818, 829],
            "vertical_y_vertices": [89, 97]
          }
        },
        "total_interest_for_this_period": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [818, 829],
            "vertical_y_vertices": [119, 127]
          }
        }
      },
      "year_to_date_totals": {
        "year": {
          "extracted_string_or_numeric_value": 2022,
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [226, 258],
            "vertical_y_vertices": [151, 161]
          }
        },
        "total_fees_charged_in_year": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [499, 529],
            "vertical_y_vertices": [171, 179]
          }
        },
        "total_interest_charged_in_year": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [499, 529],
            "vertical_y_vertices": [188, 196]
          }
        }
      },
      "activity_details": [
        {
          "description": {
            "extracted_string_or_numeric_value": "PURCHASES REGULAR",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [169, 320],
              "vertical_y_vertices": [308, 330]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "CASH ADVANCES REGULAR",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [169, 320],
              "vertical_y_vertices": [340, 360]
            }
          }
        }
      ],
      "activity_details_total": {
        "description": {
          "extracted_string_or_numeric_value": "TOTAL",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [159, 190],
            "vertical_y_vertices": [369, 377]
          }
        },
        "previous_balance": {
          "extracted_string_or_numeric_value": 153.41,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [335, 375],
            "vertical_y_vertices": [369, 377]
          }
        },
        "payments_and_other_credits": {
          "extracted_string_or_numeric_value": "153.41-",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 445],
            "vertical_y_vertices": [369, 377]
          }
        },
        "purchases_cash_adv_fees_other_debits": {
          "extracted_string_or_numeric_value": 37.26,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [480, 515],
            "vertical_y_vertices": [369, 377]
          }
        },
        "interest_charged": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550, 580],
            "vertical_y_vertices": [369, 377]
          }
        },
        "new_balance": {
          "extracted_string_or_numeric_value": 37.26,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [610, 640],
            "vertical_y_vertices": [369, 377]
          }
        },
        "promotion_minimum_payment_due": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [670, 700],
            "vertical_y_vertices": [369, 377]
          }
        },
        "deferred_interest_charges": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [730, 760],
            "vertical_y_vertices": [369, 377]
          }
        }
      },
      "interest_charge_calculation": [
        {
          "type_of_balance": {
            "extracted_string_or_numeric_value": "PURCHASES REGULAR",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 300],
              "vertical_y_vertices": [420, 440]
            }
          },
          "annual_percentage_rate_apr": {
            "extracted_string_or_numeric_value": "19.99% (M)(V)",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [420, 490],
              "vertical_y_vertices": [430, 440]
            }
          },
          "balance_subject_to_interest_rate": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630, 660],
              "vertical_y_vertices": [430, 440]
            }
          },
          "interest_charge": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 830],
              "vertical_y_vertices": [430, 440]
            }
          }
        },
        {
          "type_of_balance": {
            "extracted_string_or_numeric_value": "CASH ADVANCES REGULAR",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 300],
              "vertical_y_vertices": [450, 470]
            }
          },
          "annual_percentage_rate_apr": {
            "extracted_string_or_numeric_value": "26.99% (M)(V)",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [420, 490],
              "vertical_y_vertices": [460, 470]
            }
          },
          "balance_subject_to_interest_rate": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630, 660],
              "vertical_y_vertices": [460, 470]
            }
          },
          "interest_charge": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 830],
              "vertical_y_vertices": [460, 470]
            }
          }
        }
      ],
      "rewards_summary": {
        "previous_dollars_spent_balance": {
          "extracted_string_or_numeric_value": 348,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [530, 540]
          }
        },
        "net_eligible_dollars_spent": {
          "extracted_string_or_numeric_value": 37,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [545, 555]
          }
        },
        "adjusted_dollars_spent_balance": {
          "extracted_string_or_numeric_value": 0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [560, 570]
          }
        },
        "expired_dollars_spent_balance": {
          "extracted_string_or_numeric_value": 0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [575, 585]
          }
        },
        "redeemed_dollars_spent_balance": {
          "extracted_string_or_numeric_value": 0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [590, 600]
          }
        },
        "bonus_dollars_accrued": {
          "extracted_string_or_numeric_value": 0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [605, 615]
          }
        },
        "ending_dollars_spent_balance": {
          "extracted_string_or_numeric_value": 385,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 520],
            "vertical_y_vertices": [620, 630]
          }
        },
        "dollars_spent_balance_expiring_on": [
          {
            "amount": {
              "extracted_string_or_numeric_value": 89,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [450, 480],
                "vertical_y_vertices": [640, 650]
              }
            },
            "expiration_date": {
              "extracted_string_or_numeric_value": "12/2022",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [485, 530],
                "vertical_y_vertices": [640, 650]
              }
            }
          },
          {
            "amount": {
              "extracted_string_or_numeric_value": 201,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [450, 480],
                "vertical_y_vertices": [655, 665]
              }
            },
            "expiration_date": {
              "extracted_string_or_numeric_value": "01/2023",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [485, 530],
                "vertical_y_vertices": [655, 665]
              }
            }
          },
          {
            "amount": {
              "extracted_string_or_numeric_value": 58,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [450, 480],
                "vertical_y_vertices": [670, 680]
              }
            },
            "expiration_date": {
              "extracted_string_or_numeric_value": "02/2023",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [485, 530],
                "vertical_y_vertices": [670, 680]
              }
            }
          }
        ]
      },
      "page_info": {
        "extracted_string_or_numeric_value": "Page 3 of 8",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [457, 510],
          "vertical_y_vertices": [958, 968]
        }
      }
    }
  }
]
```