An expert forensic data architect's analysis of the provided document has yielded a resilient Pydantic V2 schema and a corresponding JSON test case. The schema is designed to handle the specific structural and financial nuances of the Fifth Third Bank statement, including a robust double-entry GAAP validator to ensure data integrity.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
from decimal import Decimal, ROUND_HALF_UP

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class CheckItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    date_paid: ForensicDataEntity
    amount: ForensicDataEntity

class TransactionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    amount: ForensicDataEntity
    description: ForensicDataEntity

class DailyBalanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    amount: ForensicDataEntity

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    beginning_balance: ForensicDataEntity
    ending_balance: ForensicDataEntity
    number_of_days: ForensicDataEntity
    total_checks_count: ForensicDataEntity
    total_checks_amount: ForensicDataEntity
    total_withdrawals_count: ForensicDataEntity
    total_withdrawals_amount: ForensicDataEntity
    total_deposits_count: ForensicDataEntity
    total_deposits_amount: ForensicDataEntity

class FifthThirdBankStatementV1(BaseModel):
    """
    Schema for a Fifth Third Bank business checking statement.
    """
    model_config = ConfigDict(extra='forbid')

    account_number: ForensicDataEntity
    statement_period_start_date: ForensicDataEntity
    statement_period_end_date: ForensicDataEntity
    account_type: ForensicDataEntity
    recipient_name: ForensicDataEntity
    recipient_address: ForensicDataEntity
    bank_address: ForensicDataEntity
    banking_center: ForensicDataEntity
    banking_center_phone: ForensicDataEntity
    commercial_client_services_phone: ForensicDataEntity
    account_summary: AccountSummary
    checks: List[CheckItem]
    total_checks_summary_amount: ForensicDataEntity
    withdrawals: List[TransactionItem]
    total_withdrawals_summary_amount: ForensicDataEntity
    deposits: List[TransactionItem]
    total_deposits_summary_amount: ForensicDataEntity
    daily_balances: List[DailyBalanceItem]

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'FifthThirdBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to validate financial data integrity.
        This validator reconciles the main summary, section totals, and individual transaction items.
        """
        def to_decimal(value: Union[str, float, int]) -> Decimal:
            return Decimal(str(value)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)

        # --- Extract values from main summary ---
        summary = self.account_summary
        beginning_balance = to_decimal(summary.beginning_balance.extracted_string_or_numeric_value)
        ending_balance = to_decimal(summary.ending_balance.extracted_string_or_numeric_value)
        summary_deposits = to_decimal(summary.total_deposits_amount.extracted_string_or_numeric_value)
        # Summary debits are stored as negative values
        summary_checks_debit = to_decimal(summary.total_checks_amount.extracted_string_or_numeric_value)
        summary_withdrawals_debit = to_decimal(summary.total_withdrawals_amount.extracted_string_or_numeric_value)

        # 1. Main Account Summary Balance Check
        calculated_ending_balance = beginning_balance + summary_deposits + summary_checks_debit + summary_withdrawals_debit
        if calculated_ending_balance != ending_balance:
            raise ValueError(
                f"Account summary balance check failed: "
                f"Beginning({beginning_balance}) + Deposits({summary_deposits}) + Checks({summary_checks_debit}) + Withdrawals({summary_withdrawals_debit}) = {calculated_ending_balance}, "
                f"but statement ending balance is {ending_balance}."
            )

        # --- Detailed Transaction Sums vs. Section Summaries (all positive values) ---
        # 2. Checks
        sum_of_checks = sum(to_decimal(c.amount.extracted_string_or_numeric_value) for c in self.checks)
        total_checks_summary = to_decimal(self.total_checks_summary_amount.extracted_string_or_numeric_value)
        if sum_of_checks != total_checks_summary:
            raise ValueError(f"Sum of detailed checks ({sum_of_checks}) does not match checks section total ({total_checks_summary}).")

        # 3. Withdrawals
        sum_of_withdrawals = sum(to_decimal(w.amount.extracted_string_or_numeric_value) for w in self.withdrawals)
        total_withdrawals_summary = to_decimal(self.total_withdrawals_summary_amount.extracted_string_or_numeric_value)
        if sum_of_withdrawals != total_withdrawals_summary:
            raise ValueError(f"Sum of detailed withdrawals ({sum_of_withdrawals}) does not match withdrawals section total ({total_withdrawals_summary}).")

        # 4. Deposits
        sum_of_deposits = sum(to_decimal(d.amount.extracted_string_or_numeric_value) for d in self.deposits)
        total_deposits_summary = to_decimal(self.total_deposits_summary_amount.extracted_string_or_numeric_value)
        if sum_of_deposits != total_deposits_summary:
            raise ValueError(f"Sum of detailed deposits ({sum_of_deposits}) does not match deposits section total ({total_deposits_summary}).")

        # --- Section Summaries (positive) vs. Main Account Summary (negative debits) ---
        # 5. Reconcile Checks
        if abs(summary_checks_debit) != total_checks_summary:
            raise ValueError(f"Main summary checks total ({abs(summary_checks_debit)}) does not match checks section total ({total_checks_summary}).")
        
        # 6. Reconcile Withdrawals
        if abs(summary_withdrawals_debit) != total_withdrawals_summary:
            raise ValueError(f"Main summary withdrawals total ({abs(summary_withdrawals_debit)}) does not match withdrawals section total ({total_withdrawals_summary}).")
            
        # 7. Reconcile Deposits
        if summary_deposits != total_deposits_summary:
            raise ValueError(f"Main summary deposits total ({summary_deposits}) does not match deposits section total ({total_deposits_summary}).")

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "fifth_third_bank_statement_2010-04-30",
    "should_pass": true,
    "taxonomy_lane": "FifthThirdBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "4273451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 788, 849 ], "vertical_y_vertices": [ 160, 170 ] }
      },
      "statement_period_start_date": {
        "extracted_string_or_numeric_value": "4/1/2010",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 700, 765 ], "vertical_y_vertices": [ 130, 140 ] }
      },
      "statement_period_end_date": {
        "extracted_string_or_numeric_value": "4/30/2010",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 775, 845 ], "vertical_y_vertices": [ 130, 140 ] }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "Bus Basics Checking",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 675, 849 ], "vertical_y_vertices": [ 145, 155 ] }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "KIBBY COMPANY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 115, 230 ], "vertical_y_vertices": [ 95, 105 ] }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665-0297",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 115, 280 ], "vertical_y_vertices": [ 108, 130 ] }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "P.O. BOX 630900 CINCINNATI OH 45263-0900",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 230, 400 ], "vertical_y_vertices": [ 60, 70 ] }
      },
      "banking_center": {
        "extracted_string_or_numeric_value": "Cadillac Downtown",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 640, 849 ], "vertical_y_vertices": [ 185, 195 ] }
      },
      "banking_center_phone": {
        "extracted_string_or_numeric_value": "231-779-2700",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 750, 849 ], "vertical_y_vertices": [ 198, 208 ] }
      },
      "commercial_client_services_phone": {
        "extracted_string_or_numeric_value": "1-800-589-5355",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 750, 849 ], "vertical_y_vertices": [ 210, 220 ] }
      },
      "account_summary": {
        "beginning_balance": {
          "extracted_string_or_numeric_value": 661.46,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 420, 470 ], "vertical_y_vertices": [ 250, 260 ] }
        },
        "ending_balance": {
          "extracted_string_or_numeric_value": 1170.78,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 420, 480 ], "vertical_y_vertices": [ 315, 325 ] }
        },
        "number_of_days": {
          "extracted_string_or_numeric_value": 30,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 810, 825 ], "vertical_y_vertices": [ 250, 260 ] }
        },
        "total_checks_count": {
          "extracted_string_or_numeric_value": 4,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 165 ], "vertical_y_vertices": [ 275, 285 ] }
        },
        "total_checks_amount": {
          "extracted_string_or_numeric_value": -681.57,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 420, 480 ], "vertical_y_vertices": [ 275, 285 ] }
        },
        "total_withdrawals_count": {
          "extracted_string_or_numeric_value": 1,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 165 ], "vertical_y_vertices": [ 288, 298 ] }
        },
        "total_withdrawals_amount": {
          "extracted_string_or_numeric_value": -89.68,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 420, 480 ], "vertical_y_vertices": [ 288, 298 ] }
        },
        "total_deposits_count": {
          "extracted_string_or_numeric_value": 1,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 165 ], "vertical_y_vertices": [ 300, 310 ] }
        },
        "total_deposits_amount": {
          "extracted_string_or_numeric_value": 1280.57,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [ 420, 480 ], "vertical_y_vertices": [ 300, 310 ] }
        }
      },
      "checks": [
        {
          "check_number": { "extracted_string_or_numeric_value": "3421 i", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 190 ], "vertical_y_vertices": [ 400, 410 ] } },
          "date_paid": { "extracted_string_or_numeric_value": "04/09", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 220, 250 ], "vertical_y_vertices": [ 400, 410 ] } },
          "amount": { "extracted_string_or_numeric_value": 516.09, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 290, 330 ], "vertical_y_vertices": [ 400, 410 ] } }
        },
        {
          "check_number": { "extracted_string_or_numeric_value": "3422 i", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 190 ], "vertical_y_vertices": [ 425, 435 ] } },
          "date_paid": { "extracted_string_or_numeric_value": "04/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 220, 250 ], "vertical_y_vertices": [ 425, 435 ] } },
          "amount": { "extracted_string_or_numeric_value": 44.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 290, 330 ], "vertical_y_vertices": [ 425, 435 ] } }
        },
        {
          "check_number": { "extracted_string_or_numeric_value": "3423 i", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 385, 420 ], "vertical_y_vertices": [ 400, 410 ] } },
          "date_paid": { "extracted_string_or_numeric_value": "04/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 450, 480 ], "vertical_y_vertices": [ 400, 410 ] } },
          "amount": { "extracted_string_or_numeric_value": 21.48, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 520, 560 ], "vertical_y_vertices": [ 400, 410 ] } }
        },
        {
          "check_number": { "extracted_string_or_numeric_value": "3426*i", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 615, 650 ], "vertical_y_vertices": [ 400, 410 ] } },
          "date_paid": { "extracted_string_or_numeric_value": "04/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 680, 710 ], "vertical_y_vertices": [ 400, 410 ] } },
          "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 785, 825 ], "vertical_y_vertices": [ 400, 410 ] } }
        }
      ],
      "total_checks_summary_amount": {
        "extracted_string_or_numeric_value": 681.57,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 770, 849 ], "vertical_y_vertices": [ 350, 360 ] }
      },
      "withdrawals": [
        {
          "date": { "extracted_string_or_numeric_value": "04/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 185 ], "vertical_y_vertices": [ 480, 490 ] } },
          "amount": { "extracted_string_or_numeric_value": 89.68, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 285, 325 ], "vertical_y_vertices": [ 480, 490 ] } },
          "description": { "extracted_string_or_numeric_value": "CHECK #3424 CONVERTED TO ELECTRONIC TRANSACTION BY Alltel CHECK PYMT 041610", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 360, 849 ], "vertical_y_vertices": [ 480, 490 ] } }
        }
      ],
      "total_withdrawals_summary_amount": {
        "extracted_string_or_numeric_value": 89.68,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 780, 849 ], "vertical_y_vertices": [ 455, 465 ] }
      },
      "deposits": [
        {
          "date": { "extracted_string_or_numeric_value": "04/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 185 ], "vertical_y_vertices": [ 545, 555 ] } },
          "amount": { "extracted_string_or_numeric_value": 1280.57, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 285, 340 ], "vertical_y_vertices": [ 545, 555 ] } },
          "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 360, 410 ], "vertical_y_vertices": [ 545, 555 ] } }
        }
      ],
      "total_deposits_summary_amount": {
        "extracted_string_or_numeric_value": 1280.57,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [ 770, 849 ], "vertical_y_vertices": [ 520, 530 ] }
      },
      "daily_balances": [
        {
          "date": { "extracted_string_or_numeric_value": "04/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 185 ], "vertical_y_vertices": [ 610, 620 ] } },
          "amount": { "extracted_string_or_numeric_value": 1942.03, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 300, 350 ], "vertical_y_vertices": [ 610, 620 ] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/09", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 155, 185 ], "vertical_y_vertices": [ 625, 635 ] } },
          "amount": { "extracted_string_or_numeric_value": 1425.94, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 300, 350 ], "vertical_y_vertices": [ 625, 635 ] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 380, 410 ], "vertical_y_vertices": [ 610, 620 ] } },
          "amount": { "extracted_string_or_numeric_value": 1360.46, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 525, 575 ], "vertical_y_vertices": [ 610, 620 ] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 380, 410 ], "vertical_y_vertices": [ 625, 635 ] } },
          "amount": { "extracted_string_or_numeric_value": 1270.78, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 525, 575 ], "vertical_y_vertices": [ 625, 635 ] } }
        },
        {
          "date": { "extracted_string_or_numeric_value": "04/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 605, 635 ], "vertical_y_vertices": [ 610, 620 ] } },
          "amount": { "extracted_string_or_numeric_value": 1170.78, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [ 750, 800 ], "vertical_y_vertices": [ 610, 620 ] } }
        }
      ]
    }
  }
]
```