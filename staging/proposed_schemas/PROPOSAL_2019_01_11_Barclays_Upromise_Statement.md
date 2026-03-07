An expert forensic data architect, I have analyzed the provided document under a Zero-Trust mandate. The following Pydantic V2 schema is designed for maximum resilience, accommodating the structural realities of the `2019-01-11 Barclays Upromise Statement` document class, including its incomplete transaction data. The schema includes multi-point GAAP-compliant mathematical checksums to ensure data integrity.

### BLOCK 1 (Python Pydantic V2)
```python
import decimal
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

# Context: Using Decimal for financial calculations to prevent floating-point inaccuracies.
# The 'getcontext().prec = 10' sets a precision of 10 decimal places for calculations.
decimal.getcontext().prec = 10

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for a data entity on the source document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data point, including its value, confidence, and physical location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Transaction(BaseModel):
    """A generic model for a single transaction line item."""
    model_config = ConfigDict(extra='forbid')
    transaction_date: Optional[ForensicDataEntity] = None
    posting_date: Optional[ForensicDataEntity] = None
    description: ForensicDataEntity
    amount: ForensicDataEntity

class BarclaysUpromiseStatementV1(BaseModel):
    """
    Schema for a Barclays Upromise World Elite Mastercard statement.
    This model is designed to be resilient to OCR failures and structural variations by making
    most fields optional. The GAAP validator ensures financial integrity.
    """
    model_config = ConfigDict(extra='forbid')

    # Document Header and Account Holder Information
    cardholder_name: Optional[ForensicDataEntity] = None
    account_number_last4: Optional[ForensicDataEntity] = None
    statement_period_start_date: Optional[ForensicDataEntity] = None
    statement_period_end_date: Optional[ForensicDataEntity] = None

    # Payment Information Summary
    payment_due_date: Optional[ForensicDataEntity] = None
    statement_balance: Optional[ForensicDataEntity] = None
    minimum_payment_due: Optional[ForensicDataEntity] = None

    # Account Activity Summary
    previous_balance: Optional[ForensicDataEntity] = None
    payments_summary: Optional[ForensicDataEntity] = None
    other_credits_summary: Optional[ForensicDataEntity] = None
    purchases_summary: Optional[ForensicDataEntity] = None
    fees_charged: Optional[ForensicDataEntity] = None
    interest_charged: Optional[ForensicDataEntity] = None
    new_balance: Optional[ForensicDataEntity] = None

    # Credit Line Details
    total_revolving_credit_line: Optional[ForensicDataEntity] = None
    available_revolving_credit_line: Optional[ForensicDataEntity] = None
    cash_advance_line: Optional[ForensicDataEntity] = None
    available_for_cash_advances: Optional[ForensicDataEntity] = None

    # Rewards Summary
    total_cash_back_sent_to_upromise: Optional[ForensicDataEntity] = None

    # Transaction Lists
    payments: Optional[List[Transaction]] = None
    other_credits: Optional[List[Transaction]] = None
    purchase_activity: Optional[List[Transaction]] = None

    @model_validator(mode='after')
    def double_entry_gaap_checksums(self) -> 'BarclaysUpromiseStatementV1':
        """
        Performs double-entry accounting checks to validate the financial data's integrity.
        Each check is performed independently to allow for partial validation if some data is missing.
        """
        errors = []

        def _to_decimal(entity: Optional[ForensicDataEntity]) -> Optional[decimal.Decimal]:
            if entity and entity.extracted_string_or_numeric_value is not None:
                try:
                    # Handles numbers that might be strings (e.g., "$1,234.56")
                    value_str = str(entity.extracted_string_or_numeric_value).replace('$', '').replace(',', '')
                    return decimal.Decimal(value_str)
                except (ValueError, decimal.InvalidOperation):
                    return None
            return None

        # Check 1: Account Activity Summary Calculation
        # previous_balance - payments - credits + purchases + fees + interest = new_balance
        prev_bal = _to_decimal(self.previous_balance)
        payments = _to_decimal(self.payments_summary)
        credits = _to_decimal(self.other_credits_summary)
        purchases = _to_decimal(self.purchases_summary)
        fees = _to_decimal(self.fees_charged)
        interest = _to_decimal(self.interest_charged)
        new_bal = _to_decimal(self.new_balance)

        if all(v is not None for v in [prev_bal, payments, credits, purchases, fees, interest, new_bal]):
            if prev_bal - payments - credits + purchases + fees + interest != new_bal:
                errors.append(f"Account Activity checksum failed: {prev_bal} - {payments} - {credits} + {purchases} + {fees} + {interest} != {new_bal}")

        # Check 2: Balance Consistency
        # The 'Statement Balance' in Payment Info should equal the 'Statement Balance as of...' in Account Activity.
        stmt_bal = _to_decimal(self.statement_balance)
        if new_bal is not None and stmt_bal is not None and new_bal != stmt_bal:
            errors.append(f"Balance consistency failed: New Balance ({new_bal}) != Statement Balance ({stmt_bal})")

        # Check 3: Credit Line Calculation
        # total_revolving_credit_line - new_balance = available_revolving_credit_line
        total_credit = _to_decimal(self.total_revolving_credit_line)
        avail_credit = _to_decimal(self.available_revolving_credit_line)
        if all(v is not None for v in [total_credit, new_bal, avail_credit]):
            if total_credit - new_bal != avail_credit:
                errors.append(f"Credit Line checksum failed: {total_credit} - {new_bal} != {avail_credit}")

        # Check 4: Detailed Payments vs. Summary
        if self.payments and payments is not None:
            detailed_payments_sum = sum(_to_decimal(p.amount) or decimal.Decimal(0) for p in self.payments)
            # Detailed amounts are negative, summary is positive.
            if abs(detailed_payments_sum) != payments:
                errors.append(f"Payments detail sum ({abs(detailed_payments_sum)}) != summary ({payments})")

        # Check 5: Detailed Credits vs. Summary
        if self.other_credits and credits is not None:
            detailed_credits_sum = sum(_to_decimal(c.amount) or decimal.Decimal(0) for c in self.other_credits)
            # Detailed amounts are negative, summary is positive.
            if abs(detailed_credits_sum) != credits:
                errors.append(f"Credits detail sum ({abs(detailed_credits_sum)}) != summary ({credits})")

        if errors:
            raise ValueError("GAAP Checksum validation failed: " + "; ".join(errors))

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "20190111-barclays-upromise-3580-full-page-set",
    "should_pass": true,
    "taxonomy_lane": "BarclaysUpromiseStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "cardholder_name": {
        "extracted_string_or_numeric_value": "JUDITH GRANDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [36, 136],
          "vertical_y_vertices": [103, 114]
        }
      },
      "account_number_last4": {
        "extracted_string_or_numeric_value": "3580",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [498, 528],
          "vertical_y_vertices": [103, 114]
        }
      },
      "statement_period_start_date": {
        "extracted_string_or_numeric_value": "12/12/18",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 705],
          "vertical_y_vertices": [103, 114]
        }
      },
      "statement_period_end_date": {
        "extracted_string_or_numeric_value": "01/11/19",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [708, 763],
          "vertical_y_vertices": [103, 114]
        }
      },
      "payment_due_date": {
        "extracted_string_or_numeric_value": "02/08/19",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [898, 956],
          "vertical_y_vertices": [259, 270]
        }
      },
      "statement_balance": {
        "extracted_string_or_numeric_value": 1956.75,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [898, 956],
          "vertical_y_vertices": [213, 224]
        }
      },
      "minimum_payment_due": {
        "extracted_string_or_numeric_value": 27.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [898, 956],
          "vertical_y_vertices": [236, 247]
        }
      },
      "previous_balance": {
        "extracted_string_or_numeric_value": 1356.95,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [213, 224]
        }
      },
      "payments_summary": {
        "extracted_string_or_numeric_value": 1356.95,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [236, 247]
        }
      },
      "other_credits_summary": {
        "extracted_string_or_numeric_value": 15.17,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [259, 270]
        }
      },
      "purchases_summary": {
        "extracted_string_or_numeric_value": 1971.92,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [282, 293]
        }
      },
      "fees_charged": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [305, 316]
        }
      },
      "interest_charged": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [328, 339]
        }
      },
      "new_balance": {
        "extracted_string_or_numeric_value": 1956.75,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 390],
          "vertical_y_vertices": [351, 362]
        }
      },
      "total_revolving_credit_line": {
        "extracted_string_or_numeric_value": 13500.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 400],
          "vertical_y_vertices": [458, 469]
        }
      },
      "available_revolving_credit_line": {
        "extracted_string_or_numeric_value": 11543.25,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 400],
          "vertical_y_vertices": [504, 515]
        }
      },
      "cash_advance_line": {
        "extracted_string_or_numeric_value": 5400.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 280],
          "vertical_y_vertices": [481, 492]
        }
      },
      "available_for_cash_advances": {
        "extracted_string_or_numeric_value": 5400.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 400],
          "vertical_y_vertices": [527, 538]
        }
      },
      "total_cash_back_sent_to_upromise": {
        "extracted_string_or_numeric_value": 24.45,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 380],
          "vertical_y_vertices": [604, 615]
        }
      },
      "payments": [
        {
          "transaction_date": {
            "extracted_string_or_numeric_value": "Dec 19",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 199], "vertical_y_vertices": [188, 198] }
          },
          "posting_date": {
            "extracted_string_or_numeric_value": "Dec 20",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [259, 299], "vertical_y_vertices": [188, 198] }
          },
          "description": {
            "extracted_string_or_numeric_value": "ARC Payment Received Thank You",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [359, 580], "vertical_y_vertices": [188, 198] }
          },
          "amount": {
            "extracted_string_or_numeric_value": -1356.95,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 810], "vertical_y_vertices": [188, 198] }
          }
        }
      ],
      "other_credits": [
        {
          "transaction_date": {
            "extracted_string_or_numeric_value": "Dec 17",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 199], "vertical_y_vertices": [258, 268] }
          },
          "posting_date": {
            "extracted_string_or_numeric_value": "Dec 18",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [259, 299], "vertical_y_vertices": [258, 268] }
          },
          "description": {
            "extracted_string_or_numeric_value": "VALU LAND 1529 MARION MI",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [359, 580], "vertical_y_vertices": [258, 268] }
          },
          "amount": {
            "extracted_string_or_numeric_value": -15.17,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 810], "vertical_y_vertices": [258, 268] }
          }
        }
      ],
      "purchase_activity": [
        {
          "transaction_date": { "extracted_string_or_numeric_value": "Dec 11", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 199], "vertical_y_vertices": [328, 338] } },
          "posting_date": { "extracted_string_or_numeric_value": "Dec 12", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [259, 299], "vertical_y_vertices": [328, 338] } },
          "description": { "extracted_string_or_numeric_value": "TRACTOR-SUPPLY-CO #063 CADILLAC MI", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [359, 580], "vertical_y_vertices": [328, 338] } },
          "amount": { "extracted_string_or_numeric_value": 13.97, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 810], "vertical_y_vertices": [328, 338] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "Dec 12", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 199], "vertical_y_vertices": [348, 358] } },
          "posting_date": { "extracted_string_or_numeric_value": "Dec 12", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [259, 299], "vertical_y_vertices": [348, 358] } },
          "description": { "extracted_string_or_numeric_value": "BIG BOY 61 CADILLAC CADILLAC MI", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [359, 580], "vertical_y_vertices": [348, 358] } },
          "amount": { "extracted_string_or_numeric_value": 21.39, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 810], "vertical_y_vertices": [348, 358] } }
        }
      ]
    }
  }
]
```