An expert forensic data architect, I have analyzed the provided documents, which include a bank statement and a corresponding reconciliation form. My analysis reveals a standard structure for a monthly checking account statement, supplemented by a blank, user-fillable form for account reconciliation.

To create a resilient Pydantic V2 schema, I have modeled both the populated statement and the blank form. The schema accounts for the detailed transaction lists (checks, deposits, other debits/credits), the summary calculations, and interest details. The reconciliation form is modeled with optional fields to accommodate its un-filled state.

The mandatory GAAP checksum validator cross-verifies the statement's arithmetic integrity in three ways:
1.  It confirms that the sum of itemized debits (checks and other debits) equals the total debits listed in the summary.
2.  It verifies that the sum of itemized credits (deposits and interest) matches the total credits in the summary.
3.  It ensures the fundamental accounting equation holds: `Previous Balance + Total Credits - Total Debits = Current Balance`.

This comprehensive approach ensures that the schema can accurately capture and validate data from this document class, maintaining high data integrity under a Zero-Trust framework.

### BLOCK 1 (Python Pydantic V2):
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

class StatementSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    deposits_and_other_credits: ForensicDataEntity
    checks_and_other_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity

class CheckTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    serial_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class OtherTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class DailyBalance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class InterestSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    payer_federal_id: Optional[ForensicDataEntity] = None
    interest_paid_ytd: ForensicDataEntity
    interest_earned: ForensicDataEntity
    apy_earned: ForensicDataEntity

class OutstandingCheck(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_or_date: Optional[ForensicDataEntity] = None
    amount: Optional[ForensicDataEntity] = None

class ReconciliationSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    balance_on_statement: Optional[ForensicDataEntity] = None
    deposits_not_on_statement: Optional[ForensicDataEntity] = None
    total_after_deposits: Optional[ForensicDataEntity] = None
    total_outstanding_checks: Optional[ForensicDataEntity] = None
    checkbook_balance: Optional[ForensicDataEntity] = None

class ReconciliationForm(BaseModel):
    model_config = ConfigDict(extra='forbid')
    outstanding_checks: List[OutstandingCheck]
    reconciliation_summary: ReconciliationSummary

class ChemicalBankWestBankStatementV1(BaseModel):
    model_config = ConfigDict(extra='forbid')
    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: ForensicDataEntity
    recipient_names: List[ForensicDataEntity]
    recipient_address: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    statement_period_days: ForensicDataEntity
    summary: StatementSummary
    check_transactions: List[CheckTransaction]
    other_transactions: List[OtherTransaction]
    daily_balances: List[DailyBalance]
    interest_summary: InterestSummary
    reconciliation_form: Optional[ReconciliationForm] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'ChemicalBankWestBankStatementV1':
        """
        Validates the financial integrity of the statement using double-entry accounting principles.
        1. Sum of itemized debits must equal the summary debit total.
        2. Sum of itemized credits must equal the summary credit total.
        3. Previous Balance + Total Credits - Total Debits must equal the Current Balance.
        """
        # 1. Calculate total itemized debits
        total_itemized_debits = 0.0
        for check in self.check_transactions:
            total_itemized_debits += check.amount.extracted_string_or_numeric_value
        for other_tran in self.other_transactions:
            if other_tran.debit:
                total_itemized_debits += other_tran.debit.extracted_string_or_numeric_value
        
        summary_debits = self.summary.checks_and_other_debits.extracted_string_or_numeric_value
        if not math.isclose(total_itemized_debits, summary_debits, rel_tol=1e-4):
            raise ValueError(f"Itemized debits sum ({total_itemized_debits:.2f}) does not match summary debits ({summary_debits:.2f}).")

        # 2. Calculate total itemized credits
        total_itemized_credits = 0.0
        for other_tran in self.other_transactions:
            if other_tran.credit:
                total_itemized_credits += other_tran.credit.extracted_string_or_numeric_value
        
        summary_credits = self.summary.deposits_and_other_credits.extracted_string_or_numeric_value
        if not math.isclose(total_itemized_credits, summary_credits, rel_tol=1e-4):
            raise ValueError(f"Itemized credits sum ({total_itemized_credits:.2f}) does not match summary credits ({summary_credits:.2f}).")

        # 3. Validate the main statement equation
        prev_bal = self.summary.previous_statement_balance.extracted_string_or_numeric_value
        curr_bal = self.summary.current_statement_balance.extracted_string_or_numeric_value
        
        calculated_balance = prev_bal + summary_credits - summary_debits
        if not math.isclose(calculated_balance, curr_bal, rel_tol=1e-4):
            raise ValueError(f"Balance calculation failed: {prev_bal} + {summary_credits} - {summary_debits} = {calculated_balance}, but current balance is {curr_bal}.")
            
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "CHEMICALBANKWEST_001_ADVANTAGE_CHECKING",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankWestBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK WEST",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [59, 239],
          "vertical_y_vertices": [59, 70]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "MCBAIN OFFICE 101 N. ROLAND MCBAIN, MI",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [59, 148],
          "vertical_y_vertices": [78, 106]
        }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "800-722-6050",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [59, 148],
          "vertical_y_vertices": [115, 123]
        }
      },
      "recipient_names": [
        {
          "extracted_string_or_numeric_value": "JUDITH A KIBBY",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [183, 272],
            "vertical_y_vertices": [183, 191]
          }
        },
        {
          "extracted_string_or_numeric_value": "MARK W KIBBY",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [183, 263],
            "vertical_y_vertices": [192, 200]
          }
        },
        {
          "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [183, 278],
            "vertical_y_vertices": [201, 209]
          }
        }
      ],
      "recipient_address": {
        "extracted_string_or_numeric_value": "PO BOX 297 MARION MI 49665-0297",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [183, 348],
          "vertical_y_vertices": [210, 227]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "02/13/05",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [884, 941],
          "vertical_y_vertices": [183, 191]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "0001019524",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [884, 941],
          "vertical_y_vertices": [201, 209]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "CHECKING *** ADVANTAGE CHECKING",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [59, 278],
          "vertical_y_vertices": [256, 264]
        }
      },
      "statement_period_days": {
        "extracted_string_or_numeric_value": 31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [471, 482],
          "vertical_y_vertices": [328, 336]
        }
      },
      "summary": {
        "previous_statement_balance": {
          "extracted_string_or_numeric_value": 11020.62,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [884, 941],
            "vertical_y_vertices": [274, 282]
          }
        },
        "deposits_and_other_credits": {
          "extracted_string_or_numeric_value": 9505.66,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [884, 941],
            "vertical_y_vertices": [292, 300]
          }
        },
        "checks_and_other_debits": {
          "extracted_string_or_numeric_value": 17094.10,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [884, 941],
            "vertical_y_vertices": [301, 309]
          }
        },
        "current_statement_balance": {
          "extracted_string_or_numeric_value": 3432.18,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [884, 941],
            "vertical_y_vertices": [310, 318]
          }
        }
      },
      "check_transactions": [
        {"serial_number": {"extracted_string_or_numeric_value": "2840", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [364, 372]}}, "date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [364, 372]}}, "amount": {"extracted_string_or_numeric_value": 1048.02, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [364, 372]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2841", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [373, 381]}}, "date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [373, 381]}}, "amount": {"extracted_string_or_numeric_value": 499.20, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [373, 381]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2842", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [382, 390]}}, "date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [382, 390]}}, "amount": {"extracted_string_or_numeric_value": 321.55, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [382, 390]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2843", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [391, 399]}}, "date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [391, 399]}}, "amount": {"extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [391, 399]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2844", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [400, 408]}}, "date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [400, 408]}}, "amount": {"extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [400, 408]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2845", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [409, 417]}}, "date": {"extracted_string_or_numeric_value": "01/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [409, 417]}}, "amount": {"extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [409, 417]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2846", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 86], "vertical_y_vertices": [418, 426]}}, "date": {"extracted_string_or_numeric_value": "01/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [418, 426]}}, "amount": {"extracted_string_or_numeric_value": 72.88, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [200, 250], "vertical_y_vertices": [418, 426]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2847", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [518, 544], "vertical_y_vertices": [364, 372]}}, "date": {"extracted_string_or_numeric_value": "01/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [582, 614], "vertical_y_vertices": [364, 372]}}, "amount": {"extracted_string_or_numeric_value": 3501.77, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [658, 708], "vertical_y_vertices": [364, 372]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2848", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [518, 544], "vertical_y_vertices": [373, 381]}}, "date": {"extracted_string_or_numeric_value": "02/01", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [582, 614], "vertical_y_vertices": [373, 381]}}, "amount": {"extracted_string_or_numeric_value": 471.72, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [658, 708], "vertical_y_vertices": [373, 381]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2849", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [518, 544], "vertical_y_vertices": [382, 390]}}, "date": {"extracted_string_or_numeric_value": "02/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [582, 614], "vertical_y_vertices": [382, 390]}}, "amount": {"extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [658, 708], "vertical_y_vertices": [382, 390]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2850", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [518, 544], "vertical_y_vertices": [391, 399]}}, "date": {"extracted_string_or_numeric_value": "02/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [582, 614], "vertical_y_vertices": [391, 399]}}, "amount": {"extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [658, 708], "vertical_y_vertices": [391, 399]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2851", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [518, 544], "vertical_y_vertices": [400, 408]}}, "date": {"extracted_string_or_numeric_value": "02/07", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [582, 614], "vertical_y_vertices": [400, 408]}}, "amount": {"extracted_string_or_numeric_value": 10000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [658, 708], "vertical_y_vertices": [400, 408]}}},
        {"serial_number": {"extracted_string_or_numeric_value": "2852", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [518, 544], "vertical_y_vertices": [409, 417]}}, "date": {"extracted_string_or_numeric_value": "02/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [582, 614], "vertical_y_vertices": [409, 417]}}, "amount": {"extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [658, 708], "vertical_y_vertices": [409, 417]}}}
      ],
      "other_transactions": [
        {"date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 92], "vertical_y_vertices": [464, 472]}}, "description": {"extracted_string_or_numeric_value": "AC-CONNGENERAL LIFE-INSURANCE", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 330], "vertical_y_vertices": [464, 472]}}, "debit": {"extracted_string_or_numeric_value": 222.68, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [600, 640], "vertical_y_vertices": [464, 472]}}, "credit": null},
        {"date": {"extracted_string_or_numeric_value": "01/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 92], "vertical_y_vertices": [473, 481]}}, "description": {"extracted_string_or_numeric_value": "AC-SPARTANS STORES -EDI ACH ISA*00*", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 330], "vertical_y_vertices": [473, 490]}}, "debit": null, "credit": {"extracted_string_or_numeric_value": 34.41, "optical_extraction_confidence_score": 0.90, "physical_evidence_coordinates": {"horizontal_x_vertices": [700, 740], "vertical_y_vertices": [491, 499]}}},
        {"date": {"extracted_string_or_numeric_value": "02/07", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 92], "vertical_y_vertices": [500, 508]}}, "description": {"extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 170], "vertical_y_vertices": [500, 508]}}, "debit": null, "credit": {"extracted_string_or_numeric_value": 9470.42, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [700, 740], "vertical_y_vertices": [500, 508]}}},
        {"date": {"extracted_string_or_numeric_value": "02/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [60, 92], "vertical_y_vertices": [518, 526]}}, "description": {"extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 230], "vertical_y_vertices": [518, 526]}}, "debit": null, "credit": {"extracted_string_or_numeric_value": 0.83, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [700, 740], "vertical_y_vertices": [518, 526]}}}
      ],
      "daily_balances": [
        {"date": {"extracted_string_or_numeric_value": "01/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [564, 572]}}, "balance": {"extracted_string_or_numeric_value": 11020.62, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160, 220], "vertical_y_vertices": [564, 572]}}},
        {"date": {"extracted_string_or_numeric_value": "01/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [230, 262], "vertical_y_vertices": [564, 572]}}, "balance": {"extracted_string_or_numeric_value": 8651.03, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [270, 330], "vertical_y_vertices": [564, 572]}}},
        {"date": {"extracted_string_or_numeric_value": "01/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [340, 372], "vertical_y_vertices": [564, 572]}}, "balance": {"extracted_string_or_numeric_value": 8451.03, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [380, 440], "vertical_y_vertices": [564, 572]}}},
        {"date": {"extracted_string_or_numeric_value": "01/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [450, 482], "vertical_y_vertices": [564, 572]}}, "balance": {"extracted_string_or_numeric_value": 4876.38, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [490, 550], "vertical_y_vertices": [564, 572]}}},
        {"date": {"extracted_string_or_numeric_value": "01/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [573, 581]}}, "balance": {"extracted_string_or_numeric_value": 14346.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160, 220], "vertical_y_vertices": [573, 581]}}},
        {"date": {"extracted_string_or_numeric_value": "02/01", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [230, 262], "vertical_y_vertices": [573, 581]}}, "balance": {"extracted_string_or_numeric_value": 13875.08, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [270, 330], "vertical_y_vertices": [573, 581]}}},
        {"date": {"extracted_string_or_numeric_value": "02/07", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [340, 372], "vertical_y_vertices": [573, 581]}}, "balance": {"extracted_string_or_numeric_value": 3909.49, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [380, 440], "vertical_y_vertices": [573, 581]}}},
        {"date": {"extracted_string_or_numeric_value": "02/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [450, 482], "vertical_y_vertices": [573, 581]}}, "balance": {"extracted_string_or_numeric_value": 3431.35, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [490, 550], "vertical_y_vertices": [573, 581]}}},
        {"date": {"extracted_string_or_numeric_value": "02/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [124, 156], "vertical_y_vertices": [591, 599]}}, "balance": {"extracted_string_or_numeric_value": 3432.18, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [160, 220], "vertical_y_vertices": [591, 599]}}}
      ],
      "interest_summary": {
        "payer_federal_id": {
          "extracted_string_or_numeric_value": "38-0740540",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [340, 410],
            "vertical_y_vertices": [618, 626]
          }
        },
        "interest_paid_ytd": {
          "extracted_string_or_numeric_value": 1.70,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [340, 410],
            "vertical_y_vertices": [636, 644]
          }
        },
        "interest_earned": {
          "extracted_string_or_numeric_value": 0.83,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [884, 941],
            "vertical_y_vertices": [663, 671]
          }
        },
        "apy_earned": {
          "extracted_string_or_numeric_value": "0.10%",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [884, 941],
            "vertical_y_vertices": [672, 680]
          }
        }
      },
      "reconciliation_form": {
        "outstanding_checks": [
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null},
          {"check_or_date": null, "amount": null}
        ],
        "reconciliation_summary": {
          "balance_on_statement": null,
          "deposits_not_on_statement": null,
          "total_after_deposits": null,
          "total_outstanding_checks": null,
          "checkbook_balance": null
        }
      }
    }
  }
]
```