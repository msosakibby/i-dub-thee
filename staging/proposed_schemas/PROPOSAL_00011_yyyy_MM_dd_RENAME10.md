An expert forensic data architect, I have analyzed the provided document, a Chemical Bank statement, and designed a resilient Pydantic V2 schema to capture its structure and financial data. The schema includes nested models for clarity and a robust `model_validator` to perform double-entry GAAP checksums, ensuring the integrity of the extracted financial figures. The design accounts for the various sections of the statement, including summaries, transaction lists, and check images, preparing it for automated, high-confidence data extraction.

### BLOCK 1 (Python Pydantic V2)
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

class BankInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: ForensicDataEntity

class RecipientInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    names: List[ForensicDataEntity]
    address: ForensicDataEntity

class StatementInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    cycle: ForensicDataEntity
    beginning_rate: ForensicDataEntity

class BalanceSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_type: ForensicDataEntity
    previous_balance_date: ForensicDataEntity
    previous_balance: ForensicDataEntity
    deposits_count: ForensicDataEntity
    deposits_and_other_credits: ForensicDataEntity
    checks_count: ForensicDataEntity
    checks_and_other_debits: ForensicDataEntity
    current_balance_date: ForensicDataEntity
    current_balance: ForensicDataEntity
    days_in_period: ForensicDataEntity

class ClearedCheckSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    serial: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class TransactionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None
    check_number: Optional[ForensicDataEntity] = None

class FeeTotals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    overdraft_fees_period: ForensicDataEntity
    overdraft_fees_ytd: ForensicDataEntity
    returned_item_fees_period: ForensicDataEntity
    returned_item_fees_ytd: ForensicDataEntity

class DailyBalanceEntry(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class InterestDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    payer_federal_id_number: ForensicDataEntity
    interest_paid_ytd: ForensicDataEntity
    days_in_period: ForensicDataEntity
    interest_earned: ForensicDataEntity
    apy_earned: ForensicDataEntity

class ClearedCheck(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    paid_date: ForensicDataEntity
    amount: ForensicDataEntity

class ChemicalBankStatementV1(BaseModel):
    """
    Schema for Chemical Bank checking account statements.
    """
    model_config = ConfigDict(extra='forbid')
    
    bank_info: BankInfo
    recipient_info: RecipientInfo
    statement_info: StatementInfo
    balance_summary: BalanceSummary
    cleared_check_summaries: List[ClearedCheckSummary]
    transactions: List[TransactionItem]
    fee_totals: FeeTotals
    daily_balances: List[DailyBalanceEntry]
    interest_details: InterestDetails
    cleared_checks: List[ClearedCheck]

    @model_validator(mode='after')
    def validate_financials(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        """
        TWOPLACES = Decimal('0.01')

        # 1. Validate main balance summary equation
        prev_bal = Decimal(str(self.balance_summary.previous_balance.extracted_string_or_numeric_value)).quantize(TWOPLACES)
        curr_bal = Decimal(str(self.balance_summary.current_balance.extracted_string_or_numeric_value)).quantize(TWOPLACES)
        total_credits_summary = Decimal(str(self.balance_summary.deposits_and_other_credits.extracted_string_or_numeric_value)).quantize(TWOPLACES)
        total_debits_summary = Decimal(str(self.balance_summary.checks_and_other_debits.extracted_string_or_numeric_value)).quantize(TWOPLACES)

        calculated_balance = prev_bal + total_credits_summary - total_debits_summary
        if calculated_balance != curr_bal:
            raise ValueError(f"Balance summary mismatch: {prev_bal} + {total_credits_summary} - {total_debits_summary} = {calculated_balance}, but current balance is {curr_bal}")

        # 2. Validate that itemized transactions sum to the summary totals
        calculated_total_credits = sum(
            Decimal(str(tx.credit.extracted_string_or_numeric_value)).quantize(TWOPLACES)
            for tx in self.transactions if tx.credit
        )
        if calculated_total_credits != total_credits_summary:
            raise ValueError(f"Sum of credit transactions ({calculated_total_credits}) does not match summary credits ({total_credits_summary})")

        calculated_detailed_debits = sum(
            Decimal(str(tx.debit.extracted_string_or_numeric_value)).quantize(TWOPLACES)
            for tx in self.transactions if tx.debit
        )
        calculated_check_debits = sum(
            Decimal(str(check.amount.extracted_string_or_numeric_value)).quantize(TWOPLACES)
            for check in self.cleared_check_summaries
        )
        calculated_total_debits = (calculated_detailed_debits + calculated_check_debits).quantize(TWOPLACES)
        if calculated_total_debits != total_debits_summary:
            raise ValueError(f"Sum of all debit transactions ({calculated_total_debits}) does not match summary debits ({total_debits_summary})")

        # 3. Validate interest consistency between summary and transaction list
        interest_earned_detail = Decimal(str(self.interest_details.interest_earned.extracted_string_or_numeric_value)).quantize(TWOPLACES)
        interest_transaction_amount = next(
            (Decimal(str(tx.credit.extracted_string_or_numeric_value)).quantize(TWOPLACES)
             for tx in self.transactions if "INTEREST PAYMENT" in str(tx.description.extracted_string_or_numeric_value) and tx.credit),
            None
        )
        
        if interest_transaction_amount is None and interest_earned_detail != Decimal('0.00'):
            raise ValueError("Interest earned is non-zero, but no 'INTEREST PAYMENT' transaction was found.")
        
        if interest_transaction_amount is not None and interest_earned_detail != interest_transaction_amount:
            raise ValueError(f"Interest earned in summary ({interest_earned_detail}) does not match interest payment transaction amount ({interest_transaction_amount})")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2010277008_2010-11-13_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_info": {
        "name": {
          "extracted_string_or_numeric_value": "CHEMICAL BANK",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 295, 295, 130], "vertical_y_vertices": [29, 29, 41, 41] }
        },
        "address": {
          "extracted_string_or_numeric_value": "MCBAIN\n101 N. ROLAND\nMCBAIN, MI 49657",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 295, 295, 130], "vertical_y_vertices": [45, 45, 81, 81] }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-825-2451",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 328, 328, 219], "vertical_y_vertices": [100, 100, 111, 111] }
        }
      },
      "recipient_info": {
        "names": [
          {
            "extracted_string_or_numeric_value": "JUDITH A GRANDY",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 355, 355, 220], "vertical_y_vertices": [125, 125, 136, 136] }
          },
          {
            "extracted_string_or_numeric_value": "MARK W KIBBY",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 328, 328, 220], "vertical_y_vertices": [138, 138, 148, 148] }
          },
          {
            "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 343, 343, 220], "vertical_y_vertices": [150, 150, 160, 160] }
          }
        ],
        "address": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD\nPO BOX 297\nMARION MI 49665",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 355, 355, 220], "vertical_y_vertices": [162, 162, 198, 198] }
        }
      },
      "statement_info": {
        "statement_date": {
          "extracted_string_or_numeric_value": "11/13/10",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [746, 835, 835, 746], "vertical_y_vertices": [125, 125, 138, 138] }
        },
        "account_number": {
          "extracted_string_or_numeric_value": "2010277008",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [746, 850, 850, 746], "vertical_y_vertices": [162, 162, 174, 174] }
        },
        "cycle": {
          "extracted_string_or_numeric_value": "046",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [788, 825, 825, 788], "vertical_y_vertices": [210, 210, 221, 221] }
        },
        "beginning_rate": {
          "extracted_string_or_numeric_value": 0.15000,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 835, 835, 765], "vertical_y_vertices": [223, 223, 234, 234] }
        }
      },
      "balance_summary": {
        "account_type": {
          "extracted_string_or_numeric_value": "CHECKING *** ADVANTAGE CHECKING",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 500, 500, 160], "vertical_y_vertices": [238, 238, 249, 249] }
        },
        "previous_balance_date": {
          "extracted_string_or_numeric_value": "10/13/10",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 545, 545, 480], "vertical_y_vertices": [252, 252, 263, 263] }
        },
        "previous_balance": {
          "extracted_string_or_numeric_value": 26689.34,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 849, 849, 765], "vertical_y_vertices": [252, 252, 263, 263] }
        },
        "deposits_count": {
          "extracted_string_or_numeric_value": 5,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 258, 258, 250], "vertical_y_vertices": [265, 265, 276, 276] }
        },
        "deposits_and_other_credits": {
          "extracted_string_or_numeric_value": 10864.81,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 849, 849, 765], "vertical_y_vertices": [265, 265, 276, 276] }
        },
        "checks_count": {
          "extracted_string_or_numeric_value": 14,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 267, 267, 250], "vertical_y_vertices": [278, 278, 289, 289] }
        },
        "checks_and_other_debits": {
          "extracted_string_or_numeric_value": 11421.90,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 849, 849, 765], "vertical_y_vertices": [278, 278, 289, 289] }
        },
        "current_balance_date": {
          "extracted_string_or_numeric_value": "11/13/10",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 545, 545, 480], "vertical_y_vertices": [291, 291, 302, 302] }
        },
        "current_balance": {
          "extracted_string_or_numeric_value": 26132.25,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 849, 849, 765], "vertical_y_vertices": [291, 291, 302, 302] }
        },
        "days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 556, 556, 540], "vertical_y_vertices": [304, 304, 315, 315] }
        }
      },
      "cleared_check_summaries": [
        { "serial": { "extracted_string_or_numeric_value": "4061*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [360, 360, 371, 371] } }, "date": { "extracted_string_or_numeric_value": "11/05", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260, 260, 220], "vertical_y_vertices": [360, 360, 371, 371] } }, "amount": { "extracted_string_or_numeric_value": 1770.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 460, 460, 390], "vertical_y_vertices": [360, 360, 371, 371] } } },
        { "serial": { "extracted_string_or_numeric_value": "4080*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [373, 373, 384, 384] } }, "date": { "extracted_string_or_numeric_value": "10/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260, 260, 220], "vertical_y_vertices": [373, 373, 384, 384] } }, "amount": { "extracted_string_or_numeric_value": 80.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 460, 460, 400], "vertical_y_vertices": [373, 373, 384, 384] } } },
        { "serial": { "extracted_string_or_numeric_value": "4082*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [386, 386, 397, 397] } }, "date": { "extracted_string_or_numeric_value": "10/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260, 260, 220], "vertical_y_vertices": [386, 386, 397, 397] } }, "amount": { "extracted_string_or_numeric_value": 400.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 460, 460, 390], "vertical_y_vertices": [386, 386, 397, 397] } } },
        { "serial": { "extracted_string_or_numeric_value": "4087*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [399, 399, 410, 410] } }, "date": { "extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260, 260, 220], "vertical_y_vertices": [399, 399, 410, 410] } }, "amount": { "extracted_string_or_numeric_value": 600.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 460, 460, 390], "vertical_y_vertices": [399, 399, 410, 410] } } },
        { "serial": { "extracted_string_or_numeric_value": "4088", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 195, 195, 160], "vertical_y_vertices": [412, 412, 423, 423] } }, "date": { "extracted_string_or_numeric_value": "11/04", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260, 260, 220], "vertical_y_vertices": [412, 412, 423, 423] } }, "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 460, 460, 390], "vertical_y_vertices": [412, 412, 423, 423] } } },
        { "serial": { "extracted_string_or_numeric_value": "4089", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 585, 585, 550], "vertical_y_vertices": [360, 360, 371, 371] } }, "date": { "extracted_string_or_numeric_value": "11/08", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 650, 650, 610], "vertical_y_vertices": [360, 360, 371, 371] } }, "amount": { "extracted_string_or_numeric_value": 2822.38, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 849, 849, 765], "vertical_y_vertices": [360, 360, 371, 371] } } },
        { "serial": { "extracted_string_or_numeric_value": "4090", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 585, 585, 550], "vertical_y_vertices": [373, 373, 384, 384] } }, "date": { "extracted_string_or_numeric_value": "11/05", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 650, 650, 610], "vertical_y_vertices": [373, 373, 384, 384] } }, "amount": { "extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [775, 849, 849, 775], "vertical_y_vertices": [373, 373, 384, 384] } } },
        { "serial": { "extracted_string_or_numeric_value": "4091", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 585, 585, 550], "vertical_y_vertices": [386, 386, 397, 397] } }, "date": { "extracted_string_or_numeric_value": "11/09", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 650, 650, 610], "vertical_y_vertices": [386, 386, 397, 397] } }, "amount": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 849, 849, 765], "vertical_y_vertices": [386, 386, 397, 397] } } },
        { "serial": { "extracted_string_or_numeric_value": "4093*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 590, 590, 550], "vertical_y_vertices": [399, 399, 410, 410] } }, "date": { "extracted_string_or_numeric_value": "11/12", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 650, 650, 610], "vertical_y_vertices": [399, 399, 410, 410] } }, "amount": { "extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [775, 849, 849, 775], "vertical_y_vertices": [399, 399, 410, 410] } } }
      ],
      "transactions": [
        { "date": { "extracted_string_or_numeric_value": "10/15", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [460, 460, 471, 471] } }, "description": { "extracted_string_or_numeric_value": "AC-LINCOLN NATL -LIFE", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 420, 420, 220], "vertical_y_vertices": [460, 460, 471, 471] } }, "debit": { "extracted_string_or_numeric_value": 1666.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 610, 610, 540], "vertical_y_vertices": [473, 473, 484, 484] } } },
        { "date": { "extracted_string_or_numeric_value": "10/19", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [473, 473, 484, 484] } }, "description": { "extracted_string_or_numeric_value": "AC-PACIFIC LIFE -INS PMT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 420, 420, 220], "vertical_y_vertices": [473, 473, 484, 484] } }, "debit": { "extracted_string_or_numeric_value": 1666.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 610, 610, 540], "vertical_y_vertices": [486, 486, 497, 497] } } },
        { "date": { "extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [499, 499, 510, 510] } }, "description": { "extracted_string_or_numeric_value": "AC-US TREASURY 303 -SOC SEC", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 450, 450, 220], "vertical_y_vertices": [499, 499, 510, 510] } }, "credit": { "extracted_string_or_numeric_value": 699.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750, 750, 700], "vertical_y_vertices": [499, 499, 510, 510] } } },
        { "date": { "extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [512, 512, 523, 523] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 290, 290, 220], "vertical_y_vertices": [512, 512, 523, 523] } }, "credit": { "extracted_string_or_numeric_value": 450.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750, 750, 700], "vertical_y_vertices": [512, 512, 523, 523] } } },
        { "date": { "extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [525, 525, 536, 536] } }, "description": { "extracted_string_or_numeric_value": "AC-AT&T SERVICES -CHECKPAYMT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 480, 480, 220], "vertical_y_vertices": [525, 525, 536, 536] } }, "debit": { "extracted_string_or_numeric_value": 77.69, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 610, 610, 560], "vertical_y_vertices": [525, 525, 536, 536] } }, "check_number": { "extracted_string_or_numeric_value": "CK-00004083", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 420, 420, 320], "vertical_y_vertices": [538, 538, 549, 549] } } },
        { "date": { "extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [551, 551, 562, 562] } }, "description": { "extracted_string_or_numeric_value": "AC-GM CARD 3 -CHECKPAYMT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 460, 460, 220], "vertical_y_vertices": [551, 551, 562, 562] } }, "debit": { "extracted_string_or_numeric_value": 343.58, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 610, 610, 550], "vertical_y_vertices": [551, 551, 562, 562] } }, "check_number": { "extracted_string_or_numeric_value": "CK-00004084", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 420, 420, 320], "vertical_y_vertices": [564, 564, 575, 575] } } },
        { "date": { "extracted_string_or_numeric_value": "10/25", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [577, 577, 588, 588] } }, "description": { "extracted_string_or_numeric_value": "AC-KOHLS CHG PMT -CHECK PMT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 470, 470, 220], "vertical_y_vertices": [577, 577, 588, 588] } }, "debit": { "extracted_string_or_numeric_value": 18.11, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 610, 610, 560], "vertical_y_vertices": [577, 577, 588, 588] } }, "check_number": { "extracted_string_or_numeric_value": "CK-000000000004085", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 480, 480, 320], "vertical_y_vertices": [590, 590, 601, 601] } } },
        { "date": { "extracted_string_or_numeric_value": "11/01", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [616, 616, 627, 627] } }, "description": { "extracted_string_or_numeric_value": "AC-SPARTAN STORES -ACCTSPYBLE", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 500, 500, 220], "vertical_y_vertices": [616, 616, 627, 627] } }, "credit": { "extracted_string_or_numeric_value": 8712.78, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 760, 760, 680], "vertical_y_vertices": [616, 616, 627, 627] } } },
        { "date": { "extracted_string_or_numeric_value": "11/08", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [642, 642, 653, 653] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 290, 290, 220], "vertical_y_vertices": [642, 642, 653, 653] } }, "credit": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 760, 760, 680], "vertical_y_vertices": [642, 642, 653, 653] } } },
        { "date": { "extracted_string_or_numeric_value": "11/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [655, 655, 666, 666] } }, "description": { "extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 370, 370, 220], "vertical_y_vertices": [655, 655, 666, 666] } }, "credit": { "extracted_string_or_numeric_value": 3.03, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 760, 760, 720], "vertical_y_vertices": [655, 655, 666, 666] } } }
      ],
      "fee_totals": {
        "overdraft_fees_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 570, 570, 550], "vertical_y_vertices": [710, 710, 721, 721] } },
        "overdraft_fees_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 700, 700, 680], "vertical_y_vertices": [710, 710, 721, 721] } },
        "returned_item_fees_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 570, 570, 550], "vertical_y_vertices": [736, 736, 747, 747] } },
        "returned_item_fees_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 700, 700, 680], "vertical_y_vertices": [736, 736, 747, 747] } }
      },
      "daily_balances": [
        { "date": { "extracted_string_or_numeric_value": "10/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [785, 785, 796, 796] } }, "balance": { "extracted_string_or_numeric_value": 26689.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 290, 290, 210], "vertical_y_vertices": [785, 785, 796, 796] } } },
        { "date": { "extracted_string_or_numeric_value": "10/15", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 340, 340, 300], "vertical_y_vertices": [785, 785, 796, 796] } }, "balance": { "extracted_string_or_numeric_value": 25023.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 490, 490, 410], "vertical_y_vertices": [785, 785, 796, 796] } } },
        { "date": { "extracted_string_or_numeric_value": "10/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 540, 540, 500], "vertical_y_vertices": [785, 785, 796, 796] } }, "balance": { "extracted_string_or_numeric_value": 24543.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 670, 670, 590], "vertical_y_vertices": [785, 785, 796, 796] } } },
        { "date": { "extracted_string_or_numeric_value": "10/19", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 720, 720, 680], "vertical_y_vertices": [785, 785, 796, 796] } }, "balance": { "extracted_string_or_numeric_value": 22877.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 860, 860, 780], "vertical_y_vertices": [785, 785, 796, 796] } } },
        { "date": { "extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [798, 798, 809, 809] } }, "balance": { "extracted_string_or_numeric_value": 23576.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 290, 290, 210], "vertical_y_vertices": [798, 798, 809, 809] } } },
        { "date": { "extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 340, 340, 300], "vertical_y_vertices": [798, 798, 809, 809] } }, "balance": { "extracted_string_or_numeric_value": 23605.07, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 490, 490, 410], "vertical_y_vertices": [798, 798, 809, 809] } } },
        { "date": { "extracted_string_or_numeric_value": "10/25", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 540, 540, 500], "vertical_y_vertices": [798, 798, 809, 809] } }, "balance": { "extracted_string_or_numeric_value": 23586.96, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 670, 670, 590], "vertical_y_vertices": [798, 798, 809, 809] } } },
        { "date": { "extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 720, 720, 680], "vertical_y_vertices": [798, 798, 809, 809] } }, "balance": { "extracted_string_or_numeric_value": 22986.96, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 860, 860, 780], "vertical_y_vertices": [798, 798, 809, 809] } } },
        { "date": { "extracted_string_or_numeric_value": "11/01", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [811, 811, 822, 822] } }, "balance": { "extracted_string_or_numeric_value": 31699.74, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 290, 290, 210], "vertical_y_vertices": [811, 811, 822, 822] } } },
        { "date": { "extracted_string_or_numeric_value": "11/04", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 340, 340, 300], "vertical_y_vertices": [811, 811, 822, 822] } }, "balance": { "extracted_string_or_numeric_value": 31599.74, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 490, 490, 410], "vertical_y_vertices": [811, 811, 822, 822] } } },
        { "date": { "extracted_string_or_numeric_value": "11/05", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 540, 540, 500], "vertical_y_vertices": [811, 811, 822, 822] } }, "balance": { "extracted_string_or_numeric_value": 29651.60, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 670, 670, 590], "vertical_y_vertices": [811, 811, 822, 822] } } },
        { "date": { "extracted_string_or_numeric_value": "11/08", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 720, 720, 680], "vertical_y_vertices": [811, 811, 822, 822] } }, "balance": { "extracted_string_or_numeric_value": 27829.22, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 860, 860, 780], "vertical_y_vertices": [811, 811, 822, 822] } } },
        { "date": { "extracted_string_or_numeric_value": "11/09", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 200, 200, 160], "vertical_y_vertices": [824, 824, 835, 835] } }, "balance": { "extracted_string_or_numeric_value": 26329.22, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 290, 290, 210], "vertical_y_vertices": [824, 824, 835, 835] } } },
        { "date": { "extracted_string_or_numeric_value": "11/12", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 340, 340, 300], "vertical_y_vertices": [824, 824, 835, 835] } }, "balance": { "extracted_string_or_numeric_value": 26129.22, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 490, 490, 410], "vertical_y_vertices": [824, 824, 835, 835] } } },
        { "date": { "extracted_string_or_numeric_value": "11/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 540, 540, 500], "vertical_y_vertices": [824, 824, 835, 835] } }, "balance": { "extracted_string_or_numeric_value": 26132.25, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 670, 670, 590], "vertical_y_vertices": [824, 824, 835, 835] } } }
      ],
      "interest_details": {
        "payer_federal_id_number": { "extracted_string_or_numeric_value": "38-0415896", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 850, 850, 750], "vertical_y_vertices": [750, 750, 760, 760] } },
        "interest_paid_ytd": { "extracted_string_or_numeric_value": 64.89, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 840, 840, 790], "vertical_y_vertices": [765, 765, 775, 775] } },
        "days_in_period": { "extracted_string_or_numeric_value": 31, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [810, 830, 830, 810], "vertical_y_vertices": [800, 800, 810, 810] } },
        "interest_earned": { "extracted_string_or_numeric_value": 3.03, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 830, 830, 800], "vertical_y_vertices": [813, 813, 823, 823] } },
        "apy_earned": { "extracted_string_or_numeric_value": "0.14%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 830, 830, 790], "vertical_y_vertices": [826, 826, 836, 836] } }
      },
      "cleared_checks": [
        { "check_number": { "extracted_string_or_numeric_value": "4061", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 810, 810, 780], "vertical_y_vertices": [170, 170, 185, 185] } }, "paid_date": { "extracted_string_or_numeric_value": "11/05/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 380, 380, 310], "vertical_y_vertices": [280, 280, 290, 290] } }, "amount": { "extracted_string_or_numeric_value": 1770.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 460, 460, 400], "vertical_y_vertices": [280, 280, 290, 290] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4080", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 810, 810, 780], "vertical_y_vertices": [170, 170, 185, 185] } }, "paid_date": { "extracted_string_or_numeric_value": "10/18/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770, 770, 700], "vertical_y_vertices": [280, 280, 290, 290] } }, "amount": { "extracted_string_or_numeric_value": 80.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 830, 830, 790], "vertical_y_vertices": [280, 280, 290, 290] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4082", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 430, 430, 400], "vertical_y_vertices": [310, 310, 325, 325] } }, "paid_date": { "extracted_string_or_numeric_value": "10/18/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 380, 380, 310], "vertical_y_vertices": [410, 410, 420, 420] } }, "amount": { "extracted_string_or_numeric_value": 400.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 460, 460, 400], "vertical_y_vertices": [410, 410, 420, 420] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4087", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 810, 810, 780], "vertical_y_vertices": [310, 310, 325, 325] } }, "paid_date": { "extracted_string_or_numeric_value": "10/27/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770, 770, 700], "vertical_y_vertices": [410, 410, 420, 420] } }, "amount": { "extracted_string_or_numeric_value": 600.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 840, 840, 790], "vertical_y_vertices": [410, 410, 420, 420] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4088", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 430, 430, 400], "vertical_y_vertices": [440, 440, 455, 455] } }, "paid_date": { "extracted_string_or_numeric_value": "11/04/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 380, 380, 310], "vertical_y_vertices": [540, 540, 550, 550] } }, "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 460, 460, 400], "vertical_y_vertices": [540, 540, 550, 550] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4089", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 810, 810, 780], "vertical_y_vertices": [440, 440, 455, 455] } }, "paid_date": { "extracted_string_or_numeric_value": "11/08/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770, 770, 700], "vertical_y_vertices": [540, 540, 550, 550] } }, "amount": { "extracted_string_or_numeric_value": 2822.38, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 840, 840, 780], "vertical_y_vertices": [540, 540, 550, 550] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4090", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 430, 430, 400], "vertical_y_vertices": [570, 570, 585, 585] } }, "paid_date": { "extracted_string_or_numeric_value": "11/05/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 380, 380, 310], "vertical_y_vertices": [670, 670, 680, 680] } }, "amount": { "extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 460, 460, 400], "vertical_y_vertices": [670, 670, 680, 680] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4091", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 810, 810, 780], "vertical_y_vertices": [570, 570, 585, 585] } }, "paid_date": { "extracted_string_or_numeric_value": "11/09/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 770, 770, 700], "vertical_y_vertices": [670, 670, 680, 680] } }, "amount": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 850, 850, 790], "vertical_y_vertices": [670, 670, 680, 680] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4093", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 430, 430, 400], "vertical_y_vertices": [700, 700, 715, 715] } }, "paid_date": { "extracted_string_or_numeric_value": "11/12/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 380, 380, 310], "vertical_y_vertices": [800, 800, 810, 810] } }, "amount": { "extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 460, 460, 400], "vertical_y_vertices": [800, 800, 810, 810] } } }
      ]
    }
  }
]
```