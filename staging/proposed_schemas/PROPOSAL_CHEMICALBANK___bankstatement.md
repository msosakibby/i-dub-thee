An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided documents. The documents represent bank statements from Chemical Bank from 2007 and 2010, plus a page of handwritten calculations. The 2010 statement is the most structurally complex, containing a detailed summary, multiple transaction types (checks, withdrawals, POS, electronic transfers), and fee summaries. The 2007 statement is simpler, while the handwritten notes appear to be a manual reconciliation.

My Pydantic V2 schema is designed to be resilient to these variations. It consolidates all possible fields, marking those not present in every document as `Optional`. The most complex variant, the 2010 statement, is used as the foundation. A single, unified `transactions` list captures all debits and credits, including checks, to simplify validation. The `@model_validator` implements double-entry GAAP checksums, ensuring that the summary figures align with the detailed transaction list and that the opening and closing balances are arithmetically sound.

### BLOCK 1 (Python Pydantic V2)
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError
from typing import List, Optional, Union
from decimal import Decimal, getcontext

# Set precision for Decimal calculations
getcontext().prec = 10

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    total_deposits_credits: ForensicDataEntity
    total_checks_debits: ForensicDataEntity
    current_balance: ForensicDataEntity
    days_in_period: ForensicDataEntity
    previous_balance_date: Optional[ForensicDataEntity] = None
    current_balance_date: Optional[ForensicDataEntity] = None
    deposits_credits_count: Optional[ForensicDataEntity] = None
    checks_debits_count: Optional[ForensicDataEntity] = None

class Transaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    check_number: Optional[ForensicDataEntity] = None
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class InterestSummary(BaseModel):
    """Catpures the specific interest summary block from older statements."""
    model_config = ConfigDict(extra='forbid')
    days_in_period: ForensicDataEntity
    interest_earned: ForensicDataEntity
    apy_earned: Optional[ForensicDataEntity] = None

class ChemicalBankStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: Optional[ForensicDataEntity] = None
    recipient_name: ForensicDataEntity
    recipient_address: ForensicDataEntity
    account_number: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_type: Optional[ForensicDataEntity] = None
    
    summary: Optional[AccountSummary] = None
    transactions: Optional[List[Transaction]] = None
    interest_summary: Optional[InterestSummary] = None # For older formats
    
    interest_paid_ytd: Optional[ForensicDataEntity] = None
    overdraft_fees: Optional[ForensicDataEntity] = None
    returned_item_fees: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'ChemicalBankStatement':
        """
        Performs double-entry accounting checks on the statement's financial data.
        1. Verifies that the sum of detailed transactions matches the summary totals.
        2. Verifies that the opening/closing balance equation holds true.
        """
        if not self.summary or not self.transactions:
            # Not enough information to perform a full validation.
            return self

        summary = self.summary
        transactions = self.transactions
        tolerance = Decimal('0.001')

        # Extract summary values
        try:
            prev_bal = Decimal(str(summary.previous_balance.extracted_string_or_numeric_value))
            total_dep = Decimal(str(summary.total_deposits_credits.extracted_string_or_numeric_value))
            total_deb = Decimal(str(summary.total_checks_debits.extracted_string_or_numeric_value))
            curr_bal = Decimal(str(summary.current_balance.extracted_string_or_numeric_value))
        except (TypeError, AttributeError) as e:
            raise ValueError(f"Invalid or missing numeric value in summary fields: {e}")

        # 1. Check if summary balance calculation is correct
        calculated_balance = prev_bal + total_dep - total_deb
        if abs(calculated_balance - curr_bal) > tolerance:
            raise ValueError(
                f"Balance Mismatch: Previous Balance ({prev_bal}) + Deposits ({total_dep}) - "
                f"Debits ({total_deb}) = {calculated_balance}, but Current Balance is {curr_bal}."
            )

        # 2. Sum detailed transactions and compare with summary totals
        sum_of_credits = sum(
            Decimal(str(t.credit.extracted_string_or_numeric_value))
            for t in transactions if t.credit and t.credit.extracted_string_or_numeric_value is not None
        )
        sum_of_debits = sum(
            Decimal(str(t.debit.extracted_string_or_numeric_value))
            for t in transactions if t.debit and t.debit.extracted_string_or_numeric_value is not None
        )

        if abs(sum_of_credits - total_dep) > tolerance:
            raise ValueError(
                f"Credits Mismatch: Sum of transaction credits ({sum_of_credits}) does not match "
                f"summary total deposits/credits ({total_dep})."
            )

        if abs(sum_of_debits - total_deb) > tolerance:
            raise ValueError(
                f"Debits Mismatch: Sum of transaction debits ({sum_of_debits}) does not match "
                f"summary total checks/debits ({total_deb})."
            )

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "chemical_bank_statement_20100412_complex",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0], "vertical_y_vertices": [45.0] }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N. ROLAND MCBAIN, MI 49657",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0], "vertical_y_vertices": [55.0] }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0], "vertical_y_vertices": [85.0] }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "KEITH A GRANDY JUDITH GRANDY",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0], "vertical_y_vertices": [155.0] }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD PO BOX 297 MARION MI 49665",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0], "vertical_y_vertices": [165.0] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "0001024797",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [165.0] }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "04/12/10",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [145.0] }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "ADVANTAGE CHECKING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123.0], "vertical_y_vertices": [225.0] }
      },
      "summary": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 2657.02,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [250.0] }
        },
        "total_deposits_credits": {
          "extracted_string_or_numeric_value": 2401.67,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [260.0] }
        },
        "total_checks_debits": {
          "extracted_string_or_numeric_value": 2487.32,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [270.0] }
        },
        "current_balance": {
          "extracted_string_or_numeric_value": 2571.37,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [280.0] }
        },
        "days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [290.0] }
        },
        "previous_balance_date": {
          "extracted_string_or_numeric_value": "03/12/10",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [400.0], "vertical_y_vertices": [250.0] }
        }
      },
      "transactions": [
        {
          "date": { "extracted_string_or_numeric_value": "03/15", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [350.0] } },
          "description": { "extracted_string_or_numeric_value": "CHECK #9782", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [350.0] } },
          "check_number": { "extracted_string_or_numeric_value": "9782", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [350.0] } },
          "debit": { "extracted_string_or_numeric_value": 357.20, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400.0], "vertical_y_vertices": [350.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "03/15", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [450.0] } },
          "description": { "extracted_string_or_numeric_value": "WTHDRL DDA 03/15 14:56", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [450.0] } },
          "debit": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [450.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "03/18", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [340.0] } },
          "description": { "extracted_string_or_numeric_value": "CHECK #9781", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [340.0] } },
          "check_number": { "extracted_string_or_numeric_value": "9781", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [340.0] } },
          "debit": { "extracted_string_or_numeric_value": 42.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400.0], "vertical_y_vertices": [340.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "03/24", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [470.0] } },
          "description": { "extracted_string_or_numeric_value": "AC-GEMB RSF -CHECKPAYMT CK-00009784", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [470.0] } },
          "debit": { "extracted_string_or_numeric_value": 125.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [470.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "03/31", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [490.0] } },
          "description": { "extracted_string_or_numeric_value": "POS DEBIT 03/31 12:19 GLENS MARKET 15 MARION MI", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [490.0] } },
          "debit": { "extracted_string_or_numeric_value": 121.75, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [490.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/01", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [510.0] } },
          "description": { "extracted_string_or_numeric_value": "AC-FIDELITY INVESTM-PENSION", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [510.0] } },
          "credit": { "extracted_string_or_numeric_value": 743.57, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600.0], "vertical_y_vertices": [510.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/05", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [520.0] } },
          "description": { "extracted_string_or_numeric_value": "AC-LPL -CREDIT", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [520.0] } },
          "credit": { "extracted_string_or_numeric_value": 1657.89, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600.0], "vertical_y_vertices": [520.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/07", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [360.0] } },
          "description": { "extracted_string_or_numeric_value": "CHECK #9786", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [360.0] } },
          "check_number": { "extracted_string_or_numeric_value": "9786", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [360.0] } },
          "debit": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [360.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/08", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [530.0] } },
          "description": { "extracted_string_or_numeric_value": "WTHDRL DDA 04/08 11:31", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [530.0] } },
          "debit": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [530.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/08", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [550.0] } },
          "description": { "extracted_string_or_numeric_value": "AC-FIA CARDSERVICES-CHECK PYMT CK-00009785", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [550.0] } },
          "debit": { "extracted_string_or_numeric_value": 475.02, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [550.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/09", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [370.0] } },
          "description": { "extracted_string_or_numeric_value": "CHECK #9787", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [370.0] } },
          "check_number": { "extracted_string_or_numeric_value": "9787", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [370.0] } },
          "debit": { "extracted_string_or_numeric_value": 166.35, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [370.0] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/12", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [100.0], "vertical_y_vertices": [570.0] } },
          "description": { "extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200.0], "vertical_y_vertices": [570.0] } },
          "credit": { "extracted_string_or_numeric_value": 0.21, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600.0], "vertical_y_vertices": [570.0] } }
        }
      ],
      "interest_paid_ytd": {
        "extracted_string_or_numeric_value": 1.24,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0], "vertical_y_vertices": [800.0] }
      },
      "overdraft_fees": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [650.0] }
      },
      "returned_item_fees": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [500.0], "vertical_y_vertices": [670.0] }
      }
    }
  }
]
```