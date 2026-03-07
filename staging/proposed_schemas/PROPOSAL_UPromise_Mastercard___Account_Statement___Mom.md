An expert forensic data architect, I have analyzed the provided document variants for 'UPromise Mastercard - Account Statement - Mom'. The structural design has remained remarkably stable over the years, with the primary evolution being the addition of a scheduled payment notification on the payment coupon in later versions.

My Pydantic V2 schema accommodates this by defining the scheduled payment details as an `Optional` nested model. The schema enforces Zero-Trust principles through `extra='forbid'` and includes a comprehensive GAAP-based mathematical validator to ensure the internal consistency and integrity of the extracted financial data.

The following schema and test case represent a resilient and accurate model for this document class.

```python
from __future__ import annotations
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
from decimal import Decimal, ROUND_HALF_UP

# MANDATORY: Do not change these base classes
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Helper function for financial calculations in the validator
def to_decimal(field: Optional[ForensicDataEntity], precision: str = '0.01') -> Decimal:
    """Safely convert a ForensicDataEntity's value to a Decimal for precise calculations."""
    if field is None or field.extracted_string_or_numeric_value is None:
        return Decimal('0.00')
    
    value_str = str(field.extracted_string_or_numeric_value).strip().replace('$', '').replace(',', '')
    
    # Handle negative values represented by parentheses
    if value_str.startswith('(') and value_str.endswith(')'):
        value_str = '-' + value_str[1:-1]
        
    try:
        return Decimal(value_str).quantize(Decimal(precision), rounding=ROUND_HALF_UP)
    except:
        return Decimal('0.00')

# Schema for UPromise Mastercard Statements
class AccountActivitySummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    payments: ForensicDataEntity
    purchases: ForensicDataEntity
    fees_charged: ForensicDataEntity
    interest_charged: ForensicDataEntity
    new_balance: ForensicDataEntity

class PaymentInfoSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    statement_balance: ForensicDataEntity
    minimum_payment_due: ForensicDataEntity
    payment_due_date: ForensicDataEntity

class CreditLineSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_revolving_credit_line: ForensicDataEntity
    cash_advance_line: ForensicDataEntity
    available_revolving_credit_line: ForensicDataEntity
    available_cash_advances: ForensicDataEntity

class CashBackSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_cash_back_sent_to_upromise: ForensicDataEntity

class PaymentScenario(BaseModel):
    model_config = ConfigDict(extra='forbid')
    payment_description: ForensicDataEntity
    monthly_payment: Optional[ForensicDataEntity] = None
    payoff_time_years: ForensicDataEntity
    total_paid: ForensicDataEntity
    savings: Optional[ForensicDataEntity] = None

class Transaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transaction_date: ForensicDataEntity
    posting_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class BalanceTypeInterest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    balance_type: ForensicDataEntity
    balance_subject_to_interest: ForensicDataEntity
    apr: ForensicDataEntity
    interest_charge: ForensicDataEntity

class InterestChargeCalculation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    days_in_billing_cycle: ForensicDataEntity
    balance_types: List[BalanceTypeInterest]
    total_interest_charge: ForensicDataEntity

class CashBackDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    cash_back_earned_on_purchases: ForensicDataEntity
    cash_back_sent_to_upromise: ForensicDataEntity

class ScheduledPayment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    scheduled_payment_amount: ForensicDataEntity
    scheduled_payment_date: ForensicDataEntity

class UPromiseMastercardStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    
    account_holder_name: ForensicDataEntity
    account_number_last4: ForensicDataEntity
    statement_period_start: ForensicDataEntity
    statement_period_end: ForensicDataEntity
    
    account_activity: AccountActivitySummary
    payment_info: PaymentInfoSummary
    credit_line: CreditLineSummary
    cash_back_summary: CashBackSummary
    payment_scenarios: List[PaymentScenario]
    
    payments: List[Transaction]
    purchases: List[Transaction]
    
    interest_charge_calculation: InterestChargeCalculation
    cash_back_details: CashBackDetails
    
    # This field was added in later statement versions
    scheduled_payment: Optional[ScheduledPayment] = None

    @model_validator(mode='after')
    def validate_financial_integrity(self) -> 'UPromiseMastercardStatement':
        errors = []

        # 1. Account Activity Checksum
        activity = self.account_activity
        calc_new_balance = (to_decimal(activity.previous_balance) - 
                            to_decimal(activity.payments) + 
                            to_decimal(activity.purchases) + 
                            to_decimal(activity.fees_charged) + 
                            to_decimal(activity.interest_charged))
        if calc_new_balance != to_decimal(activity.new_balance):
            errors.append(f"Account Activity checksum failed: "
                          f"Calculated New Balance {calc_new_balance} != "
                          f"Stated New Balance {to_decimal(activity.new_balance)}")

        # 2. Transaction Totals Checksum
        total_payments_trans = sum(to_decimal(p.amount) for p in self.payments)
        if abs(total_payments_trans) != to_decimal(activity.payments):
            errors.append(f"Payments transaction total mismatch: "
                          f"Sum of transactions {abs(total_payments_trans)} != "
                          f"Summary total {to_decimal(activity.payments)}")

        total_purchases_trans = sum(to_decimal(p.amount) for p in self.purchases)
        if total_purchases_trans != to_decimal(activity.purchases):
            errors.append(f"Purchases transaction total mismatch: "
                          f"Sum of transactions {total_purchases_trans} != "
                          f"Summary total {to_decimal(activity.purchases)}")

        # 3. Credit Line Checksum
        credit = self.credit_line
        calc_available_credit = to_decimal(credit.total_revolving_credit_line) - to_decimal(activity.new_balance)
        if calc_available_credit != to_decimal(credit.available_revolving_credit_line):
            errors.append(f"Available Credit checksum failed: "
                          f"Calculated {calc_available_credit} != "
                          f"Stated {to_decimal(credit.available_revolving_credit_line)}")

        # 4. Cash Back Checksum
        summary_cash_back = to_decimal(self.cash_back_summary.total_cash_back_sent_to_upromise)
        details_earned = to_decimal(self.cash_back_details.cash_back_earned_on_purchases)
        details_sent = to_decimal(self.cash_back_details.cash_back_sent_to_upromise)
        if not (summary_cash_back == details_earned == details_sent):
            errors.append(f"Cash Back mismatch: Summary Sent ({summary_cash_back}), "
                          f"Details Earned ({details_earned}), Details Sent ({details_sent}) must all be equal.")

        # 5. Interest Charge Checksum
        interest_calc = self.interest_charge_calculation
        calc_total_interest = sum(to_decimal(bt.interest_charge) for bt in interest_calc.balance_types)
        if calc_total_interest != to_decimal(interest_calc.total_interest_charge):
            errors.append(f"Total Interest checksum failed: "
                          f"Sum of charges {calc_total_interest} != "
                          f"Stated total {to_decimal(interest_calc.total_interest_charge)}")

        if errors:
            raise ValueError("Financial integrity checks failed: " + "; ".join(errors))
            
        return self
```
```json
[
  {
    "test_identifier": "upromise-mastercard-2022-05-11",
    "should_pass": true,
    "taxonomy_lane": "UPromiseMastercardStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_holder_name": {
        "extracted_string_or_numeric_value": "JUDITH GRANDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0, 250.0], "vertical_y_vertices": [120.0, 135.0] }
      },
      "account_number_last4": {
        "extracted_string_or_numeric_value": "3580",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [450.0, 490.0], "vertical_y_vertices": [120.0, 135.0] }
      },
      "statement_period_start": {
        "extracted_string_or_numeric_value": "04/12/22",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [580.0, 640.0], "vertical_y_vertices": [120.0, 135.0] }
      },
      "statement_period_end": {
        "extracted_string_or_numeric_value": "05/11/22",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [645.0, 705.0], "vertical_y_vertices": [120.0, 135.0] }
      },
      "account_activity": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 1374.99,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [180.0, 195.0] }
        },
        "payments": {
          "extracted_string_or_numeric_value": 1374.99,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [200.0, 215.0] }
        },
        "purchases": {
          "extracted_string_or_numeric_value": 2375.89,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [220.0, 235.0] }
        },
        "fees_charged": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [240.0, 255.0] }
        },
        "interest_charged": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [260.0, 275.0] }
        },
        "new_balance": {
          "extracted_string_or_numeric_value": 2375.89,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [280.0, 295.0] }
        }
      },
      "payment_info": {
        "statement_balance": {
          "extracted_string_or_numeric_value": 2375.89,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [850.0, 920.0], "vertical_y_vertices": [180.0, 195.0] }
        },
        "minimum_payment_due": {
          "extracted_string_or_numeric_value": 29.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [850.0, 920.0], "vertical_y_vertices": [200.0, 215.0] }
        },
        "payment_due_date": {
          "extracted_string_or_numeric_value": "06/08/22",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [850.0, 920.0], "vertical_y_vertices": [220.0, 235.0] }
        }
      },
      "credit_line": {
        "total_revolving_credit_line": {
          "extracted_string_or_numeric_value": 13500.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [380.0, 395.0] }
        },
        "cash_advance_line": {
          "extracted_string_or_numeric_value": 2700.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [400.0, 415.0] }
        },
        "available_revolving_credit_line": {
          "extracted_string_or_numeric_value": 11124.11,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [420.0, 435.0] }
        },
        "available_cash_advances": {
          "extracted_string_or_numeric_value": 2700.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [440.0, 455.0] }
        }
      },
      "cash_back_summary": {
        "total_cash_back_sent_to_upromise": {
          "extracted_string_or_numeric_value": 29.69,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [350.0, 420.0], "vertical_y_vertices": [500.0, 515.0] }
        }
      },
      "payment_scenarios": [
        {
          "payment_description": {
            "extracted_string_or_numeric_value": "Only the minimum payment",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [480.0, 580.0], "vertical_y_vertices": [450.0, 480.0] }
          },
          "payoff_time_years": {
            "extracted_string_or_numeric_value": "10 years",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650.0, 720.0], "vertical_y_vertices": [450.0, 480.0] }
          },
          "total_paid": {
            "extracted_string_or_numeric_value": 3658.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 880.0], "vertical_y_vertices": [450.0, 480.0] }
          }
        },
        {
          "payment_description": {
            "extracted_string_or_numeric_value": "Monthly Payment",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [480.0, 580.0], "vertical_y_vertices": [490.0, 520.0] }
          },
          "monthly_payment": {
            "extracted_string_or_numeric_value": 77.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [480.0, 580.0], "vertical_y_vertices": [490.0, 520.0] }
          },
          "payoff_time_years": {
            "extracted_string_or_numeric_value": "3 years",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650.0, 720.0], "vertical_y_vertices": [490.0, 520.0] }
          },
          "total_paid": {
            "extracted_string_or_numeric_value": 2772.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 880.0], "vertical_y_vertices": [490.0, 520.0] }
          },
          "savings": {
            "extracted_string_or_numeric_value": 886.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 880.0], "vertical_y_vertices": [510.0, 525.0] }
          }
        }
      ],
      "payments": [
        {
          "transaction_date": {
            "extracted_string_or_numeric_value": "May 07",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0, 150.0], "vertical_y_vertices": [300.0, 315.0] }
          },
          "posting_date": {
            "extracted_string_or_numeric_value": "May 08",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180.0, 230.0], "vertical_y_vertices": [300.0, 315.0] }
          },
          "description": {
            "extracted_string_or_numeric_value": "Payment Received HORIZON BK, A",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [260.0, 500.0], "vertical_y_vertices": [300.0, 315.0] }
          },
          "amount": {
            "extracted_string_or_numeric_value": -1374.99,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 880.0], "vertical_y_vertices": [300.0, 315.0] }
          }
        }
      ],
      "purchases": [
        {
          "transaction_date": { "extracted_string_or_numeric_value": "Apr 11", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
          "posting_date": { "extracted_string_or_numeric_value": "Apr 12", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
          "description": { "extracted_string_or_numeric_value": "CULVERS CADILLAC2 CADILLAC MI", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
          "amount": { "extracted_string_or_numeric_value": 14.58, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "May 07", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
          "posting_date": { "extracted_string_or_numeric_value": "May 08", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
          "description": { "extracted_string_or_numeric_value": "MARION VILLAGE MARKET MARION MI", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
          "amount": { "extracted_string_or_numeric_value": 2361.31, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } }
        }
      ],
      "interest_charge_calculation": {
        "days_in_billing_cycle": {
          "extracted_string_or_numeric_value": 30,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 850.0], "vertical_y_vertices": [550.0, 565.0] }
        },
        "balance_types": [
          {
            "balance_type": { "extracted_string_or_numeric_value": "Standard Purchases", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "balance_subject_to_interest": { "extracted_string_or_numeric_value": 2010.36, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "apr": { "extracted_string_or_numeric_value": "10.49%(v)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "interest_charge": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } }
          },
          {
            "balance_type": { "extracted_string_or_numeric_value": "Standard Balance Transfers/Checks", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "balance_subject_to_interest": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "apr": { "extracted_string_or_numeric_value": "10.49%(v)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "interest_charge": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } }
          },
          {
            "balance_type": { "extracted_string_or_numeric_value": "Standard Cash Advance", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "balance_subject_to_interest": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "apr": { "extracted_string_or_numeric_value": "19.49%(v)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } },
            "interest_charge": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] } }
          }
        ],
        "total_interest_charge": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 850.0], "vertical_y_vertices": [750.0, 765.0] }
        }
      },
      "cash_back_details": {
        "cash_back_earned_on_purchases": {
          "extracted_string_or_numeric_value": 29.69,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 850.0], "vertical_y_vertices": [120.0, 135.0] }
        },
        "cash_back_sent_to_upromise": {
          "extracted_string_or_numeric_value": 29.69,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800.0, 850.0], "vertical_y_vertices": [140.0, 155.0] }
        }
      },
      "scheduled_payment": {
        "scheduled_payment_amount": {
          "extracted_string_or_numeric_value": 2375.89,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [400.0, 500.0], "vertical_y_vertices": [150.0, 165.0] }
        },
        "scheduled_payment_date": {
          "extracted_string_or_numeric_value": "06/07/2022",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [600.0, 700.0], "vertical_y_vertices": [150.0, 165.0] }
        }
      }
    }
  }
]
```