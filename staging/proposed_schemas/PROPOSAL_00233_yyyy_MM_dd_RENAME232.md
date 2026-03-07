An expert forensic data architect, operating under a Zero-Trust mandate, has meticulously analyzed the provided document to engineer a resilient Pydantic V2 schema. This schema is designed to accommodate structural variations while enforcing strict data integrity and financial accuracy through GAAP-compliant mathematical checksums.

### BLOCK 1 (Python Pydantic V2)
```python
import math
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class CheckTransaction(BaseModel):
    """A model for individual check transactions."""
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class DetailedTransaction(BaseModel):
    """A model for detailed account transactions (non-check debits and all credits)."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class ChemicalBankStatementV1(BaseModel):
    """
    A Pydantic V2 schema for Chemical Bank statements.
    This model captures header information, account summary, and detailed transaction lists.
    It includes a GAAP-compliant validator to ensure financial integrity.
    """
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: ForensicDataEntity
    account_holders: List[ForensicDataEntity]
    account_holder_address: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    statement_period_days: ForensicDataEntity
    previous_statement_balance: ForensicDataEntity
    total_deposits_and_credits: ForensicDataEntity
    total_checks_and_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    check_transactions: List[CheckTransaction]
    detailed_transactions: List[DetailedTransaction]
    interest_payment: ForensicDataEntity
    total_overdraft_fees_ytd: ForensicDataEntity
    total_returned_item_fees_ytd: ForensicDataEntity

    @model_validator(mode='after')
    def validate_financial_integrity(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to validate financial data.
        1. Verifies that the sum of itemized credits matches the summary total.
        2. Verifies that the sum of itemized debits (checks + other debits) matches the summary total.
        3. Verifies the master balance equation: Prev Balance + Credits - Debits = Current Balance.
        4. Verifies the breakout interest payment amount matches the corresponding transaction.
        """
        # 1. Sum itemized credits and find the interest payment transaction
        sum_of_detailed_credits = 0.0
        interest_transaction_value = None
        for transaction in self.detailed_transactions:
            if transaction.credit:
                sum_of_detailed_credits += transaction.credit.extracted_string_or_numeric_value
                if "INTEREST PAYMENT" in transaction.description.extracted_string_or_numeric_value:
                    interest_transaction_value = transaction.credit.extracted_string_or_numeric_value
        
        # 2. Sum itemized debits (from both sections)
        sum_of_check_debits = sum(
            t.amount.extracted_string_or_numeric_value for t in self.check_transactions
        )
        sum_of_detailed_debits = sum(
            t.debit.extracted_string_or_numeric_value for t in self.detailed_transactions if t.debit
        )
        total_calculated_debits = sum_of_check_debits + sum_of_detailed_debits

        # --- ASSERTIONS ---
        
        # Assert breakout interest payment matches the transaction list
        if interest_transaction_value is not None:
            if not math.isclose(interest_transaction_value, self.interest_payment.extracted_string_or_numeric_value):
                raise ValueError(f"Interest payment mismatch: Transaction value {interest_transaction_value} != Summary value {self.interest_payment.extracted_string_or_numeric_value}")

        # Assert total credits match summary
        if not math.isclose(sum_of_detailed_credits, self.total_deposits_and_credits.extracted_string_or_numeric_value):
            raise ValueError(f"Total credits mismatch: Calculated {sum_of_detailed_credits} != Stated {self.total_deposits_and_credits.extracted_string_or_numeric_value}")

        # Assert total debits match summary
        if not math.isclose(total_calculated_debits, self.total_checks_and_debits.extracted_string_or_numeric_value):
            raise ValueError(f"Total debits mismatch: Calculated {total_calculated_debits} != Stated {self.total_checks_and_debits.extracted_string_or_numeric_value}")

        # Assert final balance calculation
        calculated_balance = (
            self.previous_statement_balance.extracted_string_or_numeric_value +
            self.total_deposits_and_credits.extracted_string_or_numeric_value -
            self.total_checks_and_debits.extracted_string_or_numeric_value
        )
        if not math.isclose(calculated_balance, self.current_statement_balance.extracted_string_or_numeric_value):
            raise ValueError(f"Current balance mismatch: Calculated {calculated_balance} != Stated {self.current_statement_balance.extracted_string_or_numeric_value}")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "chemical_bank_statement_20140913_complex",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [101.0, 200.0, 200.0, 101.0],
          "vertical_y_vertices": [50.0, 50.0, 65.0, 65.0]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N ROLAND ST\nMC BAIN MI 49657",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [101.0, 220.0, 220.0, 101.0],
          "vertical_y_vertices": [68.0, 68.0, 95.0, 95.0]
        }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [101.0, 200.0, 200.0, 101.0],
          "vertical_y_vertices": [105.0, 105.0, 115.0, 115.0]
        }
      },
      "account_holders": [
        {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 320.0, 320.0, 216.0],
            "vertical_y_vertices": [130.0, 130.0, 140.0, 140.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "MARK W KIBBY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 310.0, 310.0, 216.0],
            "vertical_y_vertices": [142.0, 142.0, 152.0, 152.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 325.0, 325.0, 216.0],
            "vertical_y_vertices": [154.0, 154.0, 164.0, 164.0]
          }
        }
      ],
      "account_holder_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [216.0, 330.0, 330.0, 216.0],
          "vertical_y_vertices": [166.0, 166.0, 188.0, 188.0]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "09/13/14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780.0, 850.0, 850.0, 780.0],
          "vertical_y_vertices": [135.0, 135.0, 145.0, 145.0]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2010277008",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780.0, 860.0, 860.0, 780.0],
          "vertical_y_vertices": [170.0, 170.0, 180.0, 180.0]
        }
      },
      "statement_period_days": {
        "extracted_string_or_numeric_value": 31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [510.0, 525.0, 525.0, 510.0],
          "vertical_y_vertices": [305.0, 305.0, 315.0, 315.0]
        }
      },
      "previous_statement_balance": {
        "extracted_string_or_numeric_value": 10964.16,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780.0, 860.0, 860.0, 780.0],
          "vertical_y_vertices": [250.0, 250.0, 260.0, 260.0]
        }
      },
      "total_deposits_and_credits": {
        "extracted_string_or_numeric_value": 15411.62,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780.0, 860.0, 860.0, 780.0],
          "vertical_y_vertices": [265.0, 265.0, 275.0, 275.0]
        }
      },
      "total_checks_and_debits": {
        "extracted_string_or_numeric_value": 13899.56,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780.0, 860.0, 860.0, 780.0],
          "vertical_y_vertices": [280.0, 280.0, 290.0, 290.0]
        }
      },
      "current_statement_balance": {
        "extracted_string_or_numeric_value": 12476.22,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780.0, 860.0, 860.0, 780.0],
          "vertical_y_vertices": [295.0, 295.0, 305.0, 305.0]
        }
      },
      "check_transactions": [
        {"check_number": {"extracted_string_or_numeric_value": "4842*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160.0, 200.0], "vertical_y_vertices": [370.0, 380.0]}}, "date": {"extracted_string_or_numeric_value": "08/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [220.0, 260.0], "vertical_y_vertices": [370.0, 380.0]}}, "amount": {"extracted_string_or_numeric_value": 850.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [400.0, 450.0], "vertical_y_vertices": [370.0, 380.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4848*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160.0, 200.0], "vertical_y_vertices": [385.0, 395.0]}}, "date": {"extracted_string_or_numeric_value": "09/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [220.0, 260.0], "vertical_y_vertices": [385.0, 395.0]}}, "amount": {"extracted_string_or_numeric_value": 570.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [400.0, 450.0], "vertical_y_vertices": [385.0, 395.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4849", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160.0, 200.0], "vertical_y_vertices": [400.0, 410.0]}}, "date": {"extracted_string_or_numeric_value": "08/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [220.0, 260.0], "vertical_y_vertices": [400.0, 410.0]}}, "amount": {"extracted_string_or_numeric_value": 5000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [400.0, 450.0], "vertical_y_vertices": [400.0, 410.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4850", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160.0, 200.0], "vertical_y_vertices": [415.0, 425.0]}}, "date": {"extracted_string_or_numeric_value": "09/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [220.0, 260.0], "vertical_y_vertices": [415.0, 425.0]}}, "amount": {"extracted_string_or_numeric_value": 25.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [400.0, 450.0], "vertical_y_vertices": [415.0, 425.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4852*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [550.0, 590.0], "vertical_y_vertices": [370.0, 380.0]}}, "date": {"extracted_string_or_numeric_value": "09/05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [610.0, 650.0], "vertical_y_vertices": [370.0, 380.0]}}, "amount": {"extracted_string_or_numeric_value": 484.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [790.0, 840.0], "vertical_y_vertices": [370.0, 380.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4854*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [550.0, 590.0], "vertical_y_vertices": [385.0, 395.0]}}, "date": {"extracted_string_or_numeric_value": "09/05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [610.0, 650.0], "vertical_y_vertices": [385.0, 395.0]}}, "amount": {"extracted_string_or_numeric_value": 90.48, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [790.0, 840.0], "vertical_y_vertices": [385.0, 395.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4856*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [550.0, 590.0], "vertical_y_vertices": [400.0, 410.0]}}, "date": {"extracted_string_or_numeric_value": "09/11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [610.0, 650.0], "vertical_y_vertices": [400.0, 410.0]}}, "amount": {"extracted_string_or_numeric_value": 60.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [790.0, 840.0], "vertical_y_vertices": [400.0, 410.0]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4857", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [550.0, 590.0], "vertical_y_vertices": [415.0, 425.0]}}, "date": {"extracted_string_or_numeric_value": "09/09", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [610.0, 650.0], "vertical_y_vertices": [415.0, 425.0]}}, "amount": {"extracted_string_or_numeric_value": 108.60, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [790.0, 840.0], "vertical_y_vertices": [415.0, 425.0]}}}
      ],
      "detailed_transactions": [
        {"date": {"extracted_string_or_numeric_value": "08/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [460.0, 470.0]}}, "description": {"extracted_string_or_numeric_value": "DEBIT MEMO", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 380.0], "vertical_y_vertices": [460.0, 470.0]}}, "debit": {"extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [460.0, 470.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [475.0, 485.0]}}, "description": {"extracted_string_or_numeric_value": "AC-VERIZON WIRELESS-PAYMENT\nCHECK#-4843", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [475.0, 495.0]}}, "debit": {"extracted_string_or_numeric_value": 154.02, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [475.0, 485.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [500.0, 510.0]}}, "description": {"extracted_string_or_numeric_value": "AC-SSA TREAS 310-XXSOC SEC", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [500.0, 510.0]}}, "credit": {"extracted_string_or_numeric_value": 642.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [500.0, 510.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [515.0, 525.0]}}, "description": {"extracted_string_or_numeric_value": "XFR CKG X121 TO CKG X008#6164", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [515.0, 525.0]}}, "credit": {"extracted_string_or_numeric_value": 4356.39, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [515.0, 525.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [530.0, 540.0]}}, "description": {"extracted_string_or_numeric_value": "XFR CKG X008 TO CKG X232#6148", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [530.0, 540.0]}}, "debit": {"extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [530.0, 540.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [545.0, 555.0]}}, "description": {"extracted_string_or_numeric_value": "AC-CAPITAL ONE ARC-CHECK PYMT\nCHECK#-4844", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [545.0, 565.0]}}, "debit": {"extracted_string_or_numeric_value": 228.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [545.0, 555.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [570.0, 580.0]}}, "description": {"extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 380.0], "vertical_y_vertices": [570.0, 580.0]}}, "credit": {"extracted_string_or_numeric_value": 700.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [570.0, 580.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [585.0, 595.0]}}, "description": {"extracted_string_or_numeric_value": "DEBIT MEMO", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 380.0], "vertical_y_vertices": [585.0, 595.0]}}, "debit": {"extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [585.0, 595.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [600.0, 610.0]}}, "description": {"extracted_string_or_numeric_value": "AC-AT&T SERVICES-CHECKPAYMT\nCHECK#-4845", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [600.0, 620.0]}}, "debit": {"extracted_string_or_numeric_value": 189.48, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [600.0, 610.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [625.0, 635.0]}}, "description": {"extracted_string_or_numeric_value": "PH TSFER PER JUDY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [625.0, 635.0]}}, "debit": {"extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [625.0, 635.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [640.0, 650.0]}}, "description": {"extracted_string_or_numeric_value": "AC-MEIJER MC-CHECK PYMT\nCHECK#-4847", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [640.0, 660.0]}}, "debit": {"extracted_string_or_numeric_value": 399.84, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [640.0, 650.0]}}},
        {"date": {"extracted_string_or_numeric_value": "08/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [665.0, 675.0]}}, "description": {"extracted_string_or_numeric_value": "AC-BARCLAY CARD US-CREDITCARD\nCHECK#-4846", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [665.0, 685.0]}}, "debit": {"extracted_string_or_numeric_value": 4192.14, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [665.0, 675.0]}}},
        {"date": {"extracted_string_or_numeric_value": "09/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [690.0, 700.0]}}, "description": {"extracted_string_or_numeric_value": "XFR CKG X354 TO CKG X008#6443", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [690.0, 700.0]}}, "credit": {"extracted_string_or_numeric_value": 4356.39, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [690.0, 700.0]}}},
        {"date": {"extracted_string_or_numeric_value": "09/04", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [705.0, 715.0]}}, "description": {"extracted_string_or_numeric_value": "AC-JC PENNEY-CHECK PYMT\nCHECK#-4853", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [705.0, 725.0]}}, "debit": {"extracted_string_or_numeric_value": 132.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [705.0, 715.0]}}},
        {"date": {"extracted_string_or_numeric_value": "09/05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [730.0, 740.0]}}, "description": {"extracted_string_or_numeric_value": "XFR CKG X797 TO CKG X008#3350", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [730.0, 740.0]}}, "credit": {"extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [730.0, 740.0]}}},
        {"date": {"extracted_string_or_numeric_value": "09/05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [745.0, 755.0]}}, "description": {"extracted_string_or_numeric_value": "XFR CKG X121 TO CKG X008#3312", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [745.0, 755.0]}}, "credit": {"extracted_string_or_numeric_value": 4356.39, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [745.0, 755.0]}}},
        {"date": {"extracted_string_or_numeric_value": "09/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [760.0, 770.0]}}, "description": {"extracted_string_or_numeric_value": "AC-AARP-AARP\nCHECK#-4855", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [760.0, 780.0]}}, "debit": {"extracted_string_or_numeric_value": 16.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [540.0, 590.0], "vertical_y_vertices": [760.0, 770.0]}}},
        {"date": {"extracted_string_or_numeric_value": "09/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [150.0, 190.0], "vertical_y_vertices": [785.0, 795.0]}}, "description": {"extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [300.0, 500.0], "vertical_y_vertices": [785.0, 795.0]}}, "credit": {"extracted_string_or_numeric_value": 0.45, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [690.0, 740.0], "vertical_y_vertices": [785.0, 795.0]}}}
      ],
      "interest_payment": {
        "extracted_string_or_numeric_value": 0.45,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [720.0, 750.0, 750.0, 720.0],
          "vertical_y_vertices": [785.0, 785.0, 795.0, 795.0]
        }
      },
      "total_overdraft_fees_ytd": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [690.0, 720.0, 720.0, 690.0],
          "vertical_y_vertices": [820.0, 820.0, 830.0, 830.0]
        }
      },
      "total_returned_item_fees_ytd": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [690.0, 720.0, 720.0, 690.0],
          "vertical_y_vertices": [840.0, 840.0, 850.0, 850.0]
        }
      }
    }
  }
]
```