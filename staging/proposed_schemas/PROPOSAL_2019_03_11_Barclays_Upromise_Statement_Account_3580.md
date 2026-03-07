An expert forensic data architect, I will now construct the Pydantic V2 schema and the corresponding JSON test case as per your directive, ensuring all financial calculations are validated through double-entry GAAP checksums.

### Block 1: Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

# DO NOT MODIFY THIS CLASS
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

# DO NOT MODIFY THIS CLASS
class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    payments: ForensicDataEntity
    purchases: ForensicDataEntity
    fees_charged: ForensicDataEntity
    interest_charged: ForensicDataEntity
    statement_balance: ForensicDataEntity

class PaymentInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    statement_balance: ForensicDataEntity
    minimum_payment_due: ForensicDataEntity

class CreditLine(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_revolving_credit_line: ForensicDataEntity
    cash_advance_limit: ForensicDataEntity
    available_revolving_credit_line: ForensicDataEntity
    available_cash_advance: ForensicDataEntity

class CashBackSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    cash_back_earned: ForensicDataEntity
    cash_back_sent_to_upromise: ForensicDataEntity

class TransactionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transaction_date: ForensicDataEntity
    posting_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class Transactions(BaseModel):
    model_config = ConfigDict(extra='forbid')
    payments: List[TransactionItem]
    total_payments: ForensicDataEntity
    purchases: List[TransactionItem]
    total_purchases: ForensicDataEntity

class BalanceTypeInterest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    balance_type: ForensicDataEntity
    balance_subject_to_interest_rate: ForensicDataEntity
    apr: ForensicDataEntity
    interest_charge: ForensicDataEntity

class InterestChargeCalculation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    days_in_billing_cycle: ForensicDataEntity
    balance_types: List[BalanceTypeInterest]

class FeesAndInterestSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_fees_for_period: ForensicDataEntity
    total_interest_for_period: ForensicDataEntity
    ytd_fees: ForensicDataEntity
    ytd_interest: ForensicDataEntity

class BarclaysUpromiseStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_holder_name: ForensicDataEntity
    account_number_last_4: ForensicDataEntity
    statement_period_start_date: ForensicDataEntity
    statement_period_end_date: ForensicDataEntity
    payment_due_date: ForensicDataEntity
    account_summary: AccountSummary
    payment_info: PaymentInfo
    credit_line: CreditLine
    cash_back_summary: CashBackSummary
    transactions: Transactions
    interest_charge_calculation: InterestChargeCalculation
    fees_and_interest_summary: FeesAndInterestSummary

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'BarclaysUpromiseStatement':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        """
        # Helper to extract float value
        def get_val(entity: ForensicDataEntity) -> float:
            val = entity.extracted_string_or_numeric_value
            return float(val) if isinstance(val, (int, float)) else 0.0

        # 1. Account Summary Calculation
        summary = self.account_summary
        calculated_balance = (
            get_val(summary.previous_balance)
            - get_val(summary.payments)
            + get_val(summary.purchases)
            + get_val(summary.fees_charged)
            + get_val(summary.interest_charged)
        )
        if abs(calculated_balance - get_val(summary.statement_balance)) > 0.01:
            raise ValueError(f"Account summary calculation failed: {calculated_balance:.2f} != {get_val(summary.statement_balance):.2f}")

        # 2. Transaction Sums
        total_calc_purchases = sum(get_val(p.amount) for p in self.transactions.purchases)
        if abs(total_calc_purchases - get_val(self.transactions.total_purchases)) > 0.01:
            raise ValueError(f"Sum of purchases ({total_calc_purchases:.2f}) does not match total purchases ({get_val(self.transactions.total_purchases):.2f})")

        total_calc_payments = sum(get_val(p.amount) for p in self.transactions.payments)
        if abs(total_calc_payments - get_val(self.transactions.total_payments)) > 0.01:
            raise ValueError(f"Sum of payments ({total_calc_payments:.2f}) does not match total payments ({get_val(self.transactions.total_payments):.2f})")

        # 3. Credit Line Calculation
        credit = self.credit_line
        calculated_available_credit = get_val(credit.total_revolving_credit_line) - get_val(summary.statement_balance)
        if abs(calculated_available_credit - get_val(credit.available_revolving_credit_line)) > 0.01:
            raise ValueError(f"Available credit calculation failed: {calculated_available_credit:.2f} != {get_val(credit.available_revolving_credit_line):.2f}")

        # 4. Data Consistency Checks
        if abs(get_val(summary.statement_balance) - get_val(self.payment_info.statement_balance)) > 0.01:
            raise ValueError("Statement balance in summary and payment info do not match.")
        
        if abs(get_val(summary.purchases) - get_val(self.transactions.total_purchases)) > 0.01:
            raise ValueError("Total purchases in summary and transactions do not match.")

        if abs(get_val(summary.payments) - abs(get_val(self.transactions.total_payments))) > 0.01:
            raise ValueError("Total payments in summary and transactions do not match.")
            
        if abs(get_val(summary.fees_charged) - get_val(self.fees_and_interest_summary.total_fees_for_period)) > 0.01:
            raise ValueError("Total fees in summary and fees/interest section do not match.")

        if abs(get_val(summary.interest_charged) - get_val(self.fees_and_interest_summary.total_interest_for_period)) > 0.01:
            raise ValueError("Total interest in summary and fees/interest section do not match.")

        return self
```

### Block 2: JSON Test Registry

```json
[
  {
    "test_identifier": "2019-03-11_barclays_upromise_3580_full_statement_validation",
    "should_pass": true,
    "taxonomy_lane": "BarclaysUpromiseStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_holder_name": {
        "extracted_string_or_numeric_value": "JUDITH GRANDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [70, 200],
          "vertical_y_vertices": [70, 80]
        }
      },
      "account_number_last_4": {
        "extracted_string_or_numeric_value": "3580",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [490, 530],
          "vertical_y_vertices": [70, 80]
        }
      },
      "statement_period_start_date": {
        "extracted_string_or_numeric_value": "02/12/19",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [630, 680],
          "vertical_y_vertices": [70, 80]
        }
      },
      "statement_period_end_date": {
        "extracted_string_or_numeric_value": "03/11/19",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [685, 735],
          "vertical_y_vertices": [70, 80]
        }
      },
      "payment_due_date": {
        "extracted_string_or_numeric_value": "04/08/19",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 860],
          "vertical_y_vertices": [250, 260]
        }
      },
      "account_summary": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 1061.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [200, 210]
          }
        },
        "payments": {
          "extracted_string_or_numeric_value": 1061.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [220, 230]
          }
        },
        "purchases": {
          "extracted_string_or_numeric_value": 1425.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [240, 250]
          }
        },
        "fees_charged": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [260, 270]
          }
        },
        "interest_charged": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [280, 290]
          }
        },
        "statement_balance": {
          "extracted_string_or_numeric_value": 1425.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [310, 320]
          }
        }
      },
      "payment_info": {
        "statement_balance": {
          "extracted_string_or_numeric_value": 1425.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 860],
            "vertical_y_vertices": [210, 220]
          }
        },
        "minimum_payment_due": {
          "extracted_string_or_numeric_value": 27.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 860],
            "vertical_y_vertices": [230, 240]
          }
        }
      },
      "credit_line": {
        "total_revolving_credit_line": {
          "extracted_string_or_numeric_value": 13500.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [450, 460]
          }
        },
        "cash_advance_limit": {
          "extracted_string_or_numeric_value": 5400.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 250],
            "vertical_y_vertices": [470, 480]
          }
        },
        "available_revolving_credit_line": {
          "extracted_string_or_numeric_value": 12074.86,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [490, 500]
          }
        },
        "available_cash_advance": {
          "extracted_string_or_numeric_value": 5400.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 420],
            "vertical_y_vertices": [530, 540]
          }
        }
      },
      "cash_back_summary": {
        "cash_back_earned": {
          "extracted_string_or_numeric_value": 17.83,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 850],
            "vertical_y_vertices": [130, 140]
          }
        },
        "cash_back_sent_to_upromise": {
          "extracted_string_or_numeric_value": 17.83,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 850],
            "vertical_y_vertices": [150, 160]
          }
        }
      },
      "transactions": {
        "payments": [
          {
            "transaction_date": {
              "extracted_string_or_numeric_value": "Feb 22",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            },
            "posting_date": {
              "extracted_string_or_numeric_value": "Feb 22",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            },
            "description": {
              "extracted_string_or_numeric_value": "ARC Payment Received Thank You",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            },
            "amount": {
              "extracted_string_or_numeric_value": -1061.14,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            }
          }
        ],
        "total_payments": {
          "extracted_string_or_numeric_value": -1061.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "purchases": [
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "ZIEBART BAY CITY", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 323.56, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 183.75, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "BIG BOY 56 CLARE", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 28.54, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "SUNOCO 0276572500 QPS FARWELL", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 23.70, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "LIFESMILES DENTISTRY CADILLAC", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 82.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 84.53, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "HIGHPOINT AUTO", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 61.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 14.83, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "SAFELITE AUTOGLASS", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 138.14, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "CASAIR INC", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 49.95, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "APL ITUNES.COM/BILL", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 2.99, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 38.82, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 170.79, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "SHANANJACS PIZZA DC P", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 32.99, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Feb 27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Feb 28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "WWW.CAREMARK.COM", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 3.89, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Mar 05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Mar 05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "BIG BOY 61 CADILLAC", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 27.28, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Mar 05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Mar 06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 48.95, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Mar 09", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Mar 11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 71.90, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Mar 09", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Mar 11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "VALU LAND 1529", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 6.69, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "transaction_date": { "extracted_string_or_numeric_value": "Mar 08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "posting_date": { "extracted_string_or_numeric_value": "Mar 11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "PIZZA HUT #14355", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 30.50, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_purchases": {
          "extracted_string_or_numeric_value": 1425.14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        }
      },
      "interest_charge_calculation": {
        "days_in_billing_cycle": {
          "extracted_string_or_numeric_value": 28,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "balance_types": [
          {
            "balance_type": {
              "extracted_string_or_numeric_value": "Standard Purchases",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            },
            "balance_subject_to_interest_rate": {
              "extracted_string_or_numeric_value": 1456.84,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            },
            "apr": {
              "extracted_string_or_numeric_value": "12.49%(v)",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            },
            "interest_charge": {
              "extracted_string_or_numeric_value": 0.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
            }
          }
        ]
      },
      "fees_and_interest_summary": {
        "total_fees_for_period": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "total_interest_for_period": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "ytd_fees": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "ytd_interest": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        }
      }
    }
  }
]
```