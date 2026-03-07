An expert forensic data architect, I have meticulously analyzed the provided bank statements from Chemical Bank. These documents, while representing a single class, exhibit structural variations typical of evolving financial reporting formats. One document is a partial statement with interest details and check images, while the other is a complete monthly summary.

To create a single, resilient schema, I have designed a Pydantic V2 model that incorporates all observed fields. Elements present in only one variant, such as the detailed transaction summary or the check image list, are typed as `Optional`. This ensures the schema can parse both complete and partial statements without error.

The cornerstone of this schema is a multi-level GAAP-compliant mathematical validator. It first verifies the high-level summary (Beginning Balance + Deposits - Debits = Ending Balance). It then performs a more rigorous check, ensuring that the sum of all itemized debits (cleared checks and other debits) and credits precisely matches the totals reported in the summary section. This double-entry checksum guarantees the internal consistency and financial integrity of the extracted data.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator
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

class InterestSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    interest_paid_ytd: ForensicDataEntity
    interest_earned_this_period: ForensicDataEntity
    apy_earned: ForensicDataEntity

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    deposits_and_credits: ForensicDataEntity
    checks_and_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    days_in_period: Optional[ForensicDataEntity] = None
    beginning_rate: Optional[ForensicDataEntity] = None

class CheckTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class DetailedTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class BalanceHistoryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class CheckImageDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    paid_date: ForensicDataEntity
    amount: ForensicDataEntity

class ChemicalBankStatement(BaseModel):
    """
    A Pydantic V2 schema for Chemical Bank checking account statements.
    This schema is designed to be resilient to structural variations between
    different statement periods, accommodating both summary and detailed views.
    """
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: ForensicDataEntity
    account_holders: List[ForensicDataEntity]
    recipient_address: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    cycle: Optional[ForensicDataEntity] = None
    payer_federal_id: Optional[ForensicDataEntity] = None
    
    interest_summary: Optional[InterestSummary] = None
    account_summary: Optional[AccountSummary] = None
    cleared_checks: Optional[List[CheckTransaction]] = None
    detailed_transactions: Optional[List[DetailedTransaction]] = None
    balance_history: Optional[List[BalanceHistoryItem]] = None
    check_images: Optional[List[CheckImageDetail]] = None

    @model_validator(mode='after')
    def double_entry_gaap_checksum(self) -> 'ChemicalBankStatement':
        """
        Performs double-entry accounting checks on the statement's financial data.
        1. Validates the main summary balance calculation.
        2. Validates that the sum of itemized transactions equals the summary totals.
        """
        if self.account_summary:
            summary = self.account_summary
            
            try:
                prev_bal = float(summary.previous_statement_balance.extracted_string_or_numeric_value)
                deposits = float(summary.deposits_and_credits.extracted_string_or_numeric_value)
                debits = float(summary.checks_and_debits.extracted_string_or_numeric_value)
                curr_bal = float(summary.current_statement_balance.extracted_string_or_numeric_value)
            except (ValueError, TypeError):
                # If any summary value is not a number, we cannot perform the check.
                return self

            # GAAP Check 1: Summary balance calculation
            if not math.isclose(prev_bal + deposits - debits, curr_bal, rel_tol=1e-4):
                raise ValueError(f"GAAP Check 1 Failed: Beginning Balance ({prev_bal}) + Deposits ({deposits}) - Debits ({debits}) != Ending Balance ({curr_bal})")

            # GAAP Check 2: Detailed transaction roll-up vs. summary totals
            total_cleared_checks_debit = 0.0
            if self.cleared_checks:
                total_cleared_checks_debit = sum(float(c.amount.extracted_string_or_numeric_value) for c in self.cleared_checks)
            
            total_other_debits = 0.0
            total_detailed_credits = 0.0
            if self.detailed_transactions:
                total_other_debits = sum(float(t.debit.extracted_string_or_numeric_value) for t in self.detailed_transactions if t.debit)
                total_detailed_credits = sum(float(t.credit.extracted_string_or_numeric_value) for t in self.detailed_transactions if t.credit)

            # Check total debits
            calculated_total_debits = total_cleared_checks_debit + total_other_debits
            if not math.isclose(calculated_total_debits, debits, rel_tol=1e-4):
                raise ValueError(f"GAAP Check 2a Failed: Sum of detailed debits ({calculated_total_debits}) does not match summary debits ({debits})")

            # Check total credits
            if not math.isclose(total_detailed_credits, deposits, rel_tol=1e-4):
                raise ValueError(f"GAAP Check 2b Failed: Sum of detailed credits ({total_detailed_credits}) does not match summary deposits ({deposits})")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "00237_2014-02-13_chemical_bank_statement_complex",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [153, 400],
          "vertical_y_vertices": [40, 55]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N ROLAND ST MC BAIN MI 49657",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [153, 400],
          "vertical_y_vertices": [56, 85]
        }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [153, 400],
          "vertical_y_vertices": [86, 98]
        }
      },
      "account_holders": [
        {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [153, 400],
            "vertical_y_vertices": [120, 130]
          }
        },
        {
          "extracted_string_or_numeric_value": "MARK W KIBBY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [153, 400],
            "vertical_y_vertices": [131, 141]
          }
        },
        {
          "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [153, 400],
            "vertical_y_vertices": [142, 152]
          }
        }
      ],
      "recipient_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD PO BOX 297 MARION MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [153, 400],
          "vertical_y_vertices": [153, 195]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "02/13/14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 800],
          "vertical_y_vertices": [120, 130]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2010277008",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 800],
          "vertical_y_vertices": [150, 160]
        }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "046",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 800],
          "vertical_y_vertices": [180, 190]
        }
      },
      "payer_federal_id": {
        "extracted_string_or_numeric_value": "38-0415896",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [300, 450],
          "vertical_y_vertices": [250, 260]
        }
      },
      "interest_summary": {
        "interest_paid_ytd": {
          "extracted_string_or_numeric_value": 0.66,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "interest_earned_this_period": {
          "extracted_string_or_numeric_value": 0.66,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "apy_earned": {
          "extracted_string_or_numeric_value": "0.05%",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        }
      },
      "account_summary": {
        "previous_statement_balance": {
          "extracted_string_or_numeric_value": 19333.96,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "deposits_and_credits": {
          "extracted_string_or_numeric_value": 13555.52,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "checks_and_debits": {
          "extracted_string_or_numeric_value": 12477.15,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "current_statement_balance": {
          "extracted_string_or_numeric_value": 20412.33,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        },
        "beginning_rate": {
          "extracted_string_or_numeric_value": 0.05000,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4] }
        }
      },
      "cleared_checks": [
        {"check_number": {"extracted_string_or_numeric_value": "4717*", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "02/11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4727*", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "01/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 20.83, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4728", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "01/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 2000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4729", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "01/15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4730", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "01/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 4269.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4731", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "01/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4738*", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "02/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 570.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4740*", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "02/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4741", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "02/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 608.27, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "20102770*", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "date": {"extracted_string_or_numeric_value": "01/28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}}
      ],
      "detailed_transactions": [
        {"date": {"extracted_string_or_numeric_value": "01/15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-SSA TREAS 310-XXSOC SEC", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "credit": {"extracted_string_or_numeric_value": 642.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-AT&T SERVICES-CHECKPAYMT CHECK#-4733", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "debit": {"extracted_string_or_numeric_value": 191.46, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-CAPITAL ONE ARC-CHECK PYMT CHECK#-4732", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "debit": {"extracted_string_or_numeric_value": 303.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "XFR CKG X008 TO CKG X232#6956", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "debit": {"extracted_string_or_numeric_value": 300.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-VERIZON WIRELESS-PAYMENT CHECK#-4734", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "debit": {"extracted_string_or_numeric_value": 92.60, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-BARCLAY CARD US-CREDITCARD CHECK#-4735", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "debit": {"extracted_string_or_numeric_value": 2600.49, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "credit": {"extracted_string_or_numeric_value": 2700.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-SPARTAN STORES-ACCTSPYBLE", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "credit": {"extracted_string_or_numeric_value": 8712.78, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "AC-MEIJER MC-CHECK PYMT CHECK#-4737", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "debit": {"extracted_string_or_numeric_value": 321.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "credit": {"extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "description": {"extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "credit": {"extracted_string_or_numeric_value": 0.74, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}}
      ],
      "balance_history": [
        {"date": {"extracted_string_or_numeric_value": "01/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "balance": {"extracted_string_or_numeric_value": 19333.96, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "01/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "balance": {"extracted_string_or_numeric_value": 16610.67, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "balance": {"extracted_string_or_numeric_value": 20139.86, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "balance": {"extracted_string_or_numeric_value": 20411.59, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"date": {"extracted_string_or_numeric_value": "02/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "balance": {"extracted_string_or_numeric_value": 20412.33, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}}
      ],
      "check_images": [
        {"check_number": {"extracted_string_or_numeric_value": "4705", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "paid_date": {"extracted_string_or_numeric_value": "12/16/2013", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 5500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}},
        {"check_number": {"extracted_string_or_numeric_value": "4709", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "paid_date": {"extracted_string_or_numeric_value": "12/18/2013", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}, "amount": {"extracted_string_or_numeric_value": 19.95, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [3,4]}}}
      ]
    }
  }
]
```