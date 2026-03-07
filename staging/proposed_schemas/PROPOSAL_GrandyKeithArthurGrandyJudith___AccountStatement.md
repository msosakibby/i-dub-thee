An expert forensic data architect, I have analyzed the provided documents, which represent two distinct statement layouts for the same account over different years. My analysis reveals structural drift in the policy and transaction summary sections. The following Pydantic V2 schema is designed to be resilient to these variations, ensuring data integrity through a multi-layered, double-entry GAAP validation approach.

### Python Pydantic V2 Schema

This schema accommodates both document structures. The 2018 statement lacks the 'Family Auto' and 'F.B. Membership' policies present in the 2017 statement; the schema handles this with a flexible list. Similarly, the transaction summary correctly models payments and their informational breakdowns, ensuring accurate financial validation across both layouts. The final model validator cross-references the balances from the two main sections of the statement, providing a comprehensive integrity check.

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError
from typing import List, Union, Optional
from decimal import Decimal, InvalidOperation

# MANDATORY: Provided ForensicDataEntity and SpatialCoordinatesPolygon classes
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Helper function for safe Decimal conversion
def to_decimal(value: Union[str, float]) -> Decimal:
    try:
        return Decimal(str(value).replace(',', ''))
    except (InvalidOperation, TypeError, ValueError):
        raise ValueError(f"Could not convert '{value}' to Decimal.")

# Schema for individual policy lines in the Account Summary
class PolicySummaryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    policy_type: ForensicDataEntity
    policy_number: Optional[ForensicDataEntity] = None
    term_dates: ForensicDataEntity
    payment_plan: ForensicDataEntity
    account_balance: ForensicDataEntity
    minimum_amount_due: ForensicDataEntity

# Schema for the main billing statement section
class AccountBillingStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    minimum_amount_due: ForensicDataEntity
    due_date: ForensicDataEntity
    policy_summary: List[PolicySummaryItem]
    total_account_balance: ForensicDataEntity
    total_minimum_amount_due: ForensicDataEntity

    @model_validator(mode='after')
    def validate_account_summary_totals(self) -> 'AccountBillingStatement':
        """Validates that the sum of individual policy amounts equals the reported totals."""
        calculated_balance = sum(to_decimal(item.account_balance.extracted_string_or_numeric_value) for item in self.policy_summary)
        reported_total_balance = to_decimal(self.total_account_balance.extracted_string_or_numeric_value)

        if not calculated_balance.isclose(reported_total_balance):
            raise ValueError(f"Account Balance Mismatch: Sum of policy balances ({calculated_balance}) does not equal total balance ({reported_total_balance}).")

        calculated_min_due = sum(to_decimal(item.minimum_amount_due.extracted_string_or_numeric_value) for item in self.policy_summary)
        reported_total_min_due = to_decimal(self.total_minimum_amount_due.extracted_string_or_numeric_value)

        if not calculated_min_due.isclose(reported_total_min_due):
            raise ValueError(f"Minimum Due Mismatch: Sum of policy minimums ({calculated_min_due}) does not equal total minimum due ({reported_total_min_due}).")

        return self

# Schema for individual transaction lines
class TransactionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    effective_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

# Schema for the transaction summary section
class TransactionsSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_account_balance: ForensicDataEntity
    transactions: List[TransactionItem]
    account_balance_as_of_date: ForensicDataEntity
    next_scheduled_payment: ForensicDataEntity

    @model_validator(mode='after')
    def validate_transaction_summary_balance(self) -> 'TransactionsSummary':
        """Validates the transaction log against the previous and current balances."""
        # Primary balance calculation
        previous_balance = to_decimal(self.previous_account_balance.extracted_string_or_numeric_value)
        
        # The "APPLIED TO" lines are informational breakdowns. Only non-applied lines affect the balance.
        # Typically, this is just the "PAYMENT RECEIVED" line.
        balance_affecting_transactions = [
            t for t in self.transactions 
            if "APPLIED TO" not in str(t.description.extracted_string_or_numeric_value).upper()
        ]
        
        transaction_sum = sum(to_decimal(t.amount.extracted_string_or_numeric_value) for t in balance_affecting_transactions)
        
        calculated_balance = previous_balance + transaction_sum
        reported_balance = to_decimal(self.account_balance_as_of_date.extracted_string_or_numeric_value)

        if not calculated_balance.isclose(reported_balance):
            raise ValueError(f"Transaction Balance Mismatch: Previous Balance ({previous_balance}) + Transactions ({transaction_sum}) = {calculated_balance}, which does not equal Reported Balance ({reported_balance}).")

        # Secondary check: Verify payment breakdown
        payment_transactions = [
            t for t in self.transactions 
            if "PAYMENT RECEIVED" in str(t.description.extracted_string_or_numeric_value).upper()
        ]
        applied_transactions = [
            t for t in self.transactions 
            if "APPLIED TO" in str(t.description.extracted_string_or_numeric_value).upper()
        ]

        if payment_transactions and applied_transactions:
            total_payment = sum(to_decimal(t.amount.extracted_string_or_numeric_value) for t in payment_transactions)
            total_applied = sum(to_decimal(t.amount.extracted_string_or_numeric_value) for t in applied_transactions)
            if not total_payment.isclose(total_applied):
                 raise ValueError(f"Payment Breakdown Mismatch: Total Payment Received ({total_payment}) does not equal sum of Applied amounts ({total_applied}).")

        return self

# Top-level schema for the entire document
class GrandyKeithArthurGrandyJudithAccountStatementV1(BaseModel):
    model_config = ConfigDict(extra='forbid')
    
    issuer_name: ForensicDataEntity
    issuer_address: ForensicDataEntity
    recipient_names: List[ForensicDataEntity]
    recipient_address: ForensicDataEntity
    account_number: ForensicDataEntity
    statement_date: ForensicDataEntity
    agent_name: ForensicDataEntity
    agent_phone: ForensicDataEntity
    account_billing_statement: AccountBillingStatement
    transactions_summary: TransactionsSummary

    @model_validator(mode='after')
    def validate_cross_section_balances(self) -> 'GrandyKeithArthurGrandyJudithAccountStatementV1':
        """Ensures the final balance is consistent across different document sections."""
        transaction_balance = to_decimal(self.transactions_summary.account_balance_as_of_date.extracted_string_or_numeric_value)
        billing_balance = to_decimal(self.account_billing_statement.total_account_balance.extracted_string_or_numeric_value)

        if not transaction_balance.isclose(billing_balance):
            raise ValueError(f"Cross-Section Balance Mismatch: Transaction Summary Balance ({transaction_balance}) does not match Billing Statement Total Balance ({billing_balance}).")
        
        return self
```

### JSON Test Registry

This JSON object represents the most structurally complex variant identified (the 2017 statement), which includes multiple policy types and a detailed payment breakdown. It is designed to pass all validators in the schema above, serving as a golden test case for data extraction and validation systems.

```json
[
  {
    "test_identifier": "2017-05-11-statement-complex-variant",
    "should_pass": true,
    "taxonomy_lane": "GrandyKeithArthurGrandyJudithAccountStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "issuer_name": {
        "extracted_string_or_numeric_value": "MICHIGAN FARM BUREAU FAMILY OF COMPANIES®",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [58.0, 480.0],
          "vertical_y_vertices": [40.0, 70.0]
        }
      },
      "issuer_address": {
        "extracted_string_or_numeric_value": "7373 West Saginaw Highway, PO Box 30400, Lansing, Michigan 48909-7900",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [73.0, 465.0],
          "vertical_y_vertices": [100.0, 110.0]
        }
      },
      "recipient_names": [
        {
          "extracted_string_or_numeric_value": "GRANDY KEITH ARTHUR",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [88.0, 300.0],
            "vertical_y_vertices": [160.0, 170.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "GRANDY JUDITH",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [88.0, 220.0],
            "vertical_y_vertices": [171.0, 181.0]
          }
        }
      ],
      "recipient_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [88.0, 250.0],
          "vertical_y_vertices": [182.0, 202.0]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "C000974783-001-00001",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [250.0, 450.0],
          "vertical_y_vertices": [250.0, 260.0]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "05/11/2017",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [670.0, 750.0],
          "vertical_y_vertices": [290.0, 300.0]
        }
      },
      "agent_name": {
        "extracted_string_or_numeric_value": "DAN LEE",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [88.0, 180.0],
          "vertical_y_vertices": [310.0, 320.0]
        }
      },
      "agent_phone": {
        "extracted_string_or_numeric_value": "(231) 832-3283",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [88.0, 220.0],
          "vertical_y_vertices": [321.0, 331.0]
        }
      },
      "account_billing_statement": {
        "minimum_amount_due": {
          "extracted_string_or_numeric_value": 287.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800.0, 850.0],
            "vertical_y_vertices": [150.0, 160.0]
          }
        },
        "due_date": {
          "extracted_string_or_numeric_value": "05/25/2017",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800.0, 880.0],
            "vertical_y_vertices": [170.0, 180.0]
          }
        },
        "policy_summary": [
          {
            "policy_type": {
              "extracted_string_or_numeric_value": "FAMILY AUTO",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "policy_number": {
              "extracted_string_or_numeric_value": "100-0470T76-20",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "term_dates": {
              "extracted_string_or_numeric_value": "04/25/2017-10/25/2017",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "payment_plan": {
              "extracted_string_or_numeric_value": "FULL PAY",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "account_balance": {
              "extracted_string_or_numeric_value": 0.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "minimum_amount_due": {
              "extracted_string_or_numeric_value": 0.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          },
          {
            "policy_type": {
              "extracted_string_or_numeric_value": "FARMOWNERS\n3291 18 MILE RD",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "policy_number": {
              "extracted_string_or_numeric_value": "FO -2846580-15",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "term_dates": {
              "extracted_string_or_numeric_value": "04/25/2017-04/25/2018",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "payment_plan": {
              "extracted_string_or_numeric_value": "SEMI-ANNUAL",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "account_balance": {
              "extracted_string_or_numeric_value": 1207.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "minimum_amount_due": {
              "extracted_string_or_numeric_value": 0.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          },
          {
            "policy_type": {
              "extracted_string_or_numeric_value": "UMBRELLA",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "policy_number": {
              "extracted_string_or_numeric_value": "U -2850613-15",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "term_dates": {
              "extracted_string_or_numeric_value": "05/08/2017-05/08/2018",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "payment_plan": {
              "extracted_string_or_numeric_value": "FULL PAY",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "account_balance": {
              "extracted_string_or_numeric_value": 287.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "minimum_amount_due": {
              "extracted_string_or_numeric_value": 287.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          },
          {
            "policy_type": {
              "extracted_string_or_numeric_value": "F. B. MEMBERSHIP",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "policy_number": {
              "extracted_string_or_numeric_value": "AMS-0090517-34",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "term_dates": {
              "extracted_string_or_numeric_value": "01/06/2017-01/06/2018",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "payment_plan": {
              "extracted_string_or_numeric_value": "FULL PAY",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "account_balance": {
              "extracted_string_or_numeric_value": 0.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "minimum_amount_due": {
              "extracted_string_or_numeric_value": 0.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          }
        ],
        "total_account_balance": {
          "extracted_string_or_numeric_value": 1494.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
        },
        "total_minimum_amount_due": {
          "extracted_string_or_numeric_value": 287.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
        }
      },
      "transactions_summary": {
        "previous_account_balance": {
          "extracted_string_or_numeric_value": 3483.56,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
        },
        "transactions": [
          {
            "effective_date": {
              "extracted_string_or_numeric_value": "04/19/2017",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "description": {
              "extracted_string_or_numeric_value": "PAYMENT RECEIVED THANK YOU",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "amount": {
              "extracted_string_or_numeric_value": -1989.56,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          },
          {
            "effective_date": {
              "extracted_string_or_numeric_value": "04/19/2017",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "description": {
              "extracted_string_or_numeric_value": "APPLIED TO FAMILY AUTO 100-0470T76-20",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "amount": {
              "extracted_string_or_numeric_value": -777.56,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          },
          {
            "effective_date": {
              "extracted_string_or_numeric_value": "04/19/2017",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "description": {
              "extracted_string_or_numeric_value": "APPLIED TO FARMOWNERS FO -2846580-15",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "amount": {
              "extracted_string_or_numeric_value": -1207.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          },
          {
            "effective_date": {
              "extracted_string_or_numeric_value": "04/19/2017",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "description": {
              "extracted_string_or_numeric_value": "APPLIED TO PAYMENT PLAN FEE",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            },
            "amount": {
              "extracted_string_or_numeric_value": -5.00,
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
            }
          }
        ],
        "account_balance_as_of_date": {
          "extracted_string_or_numeric_value": 1494.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
        },
        "next_scheduled_payment": {
          "extracted_string_or_numeric_value": 1207.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
        }
      }
    }
  }
]
```