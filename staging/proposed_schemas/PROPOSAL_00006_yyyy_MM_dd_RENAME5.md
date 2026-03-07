An expert forensic data architect, I have meticulously analyzed the provided document to engineer a Pydantic V2 schema. This schema is designed for maximum resilience, anticipating structural variations by making non-essential sections and fields optional. It incorporates a rigorous double-entry GAAP financial checksum within a `model_validator` to ensure the mathematical integrity of the extracted data.

### BLOCK 1: Pydantic V2 Schema

```python
import pydantic
from pydantic import BaseModel, Field, ConfigDict, model_validator
from typing import List, Optional, Union
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

class Issuer(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: Optional[ForensicDataEntity] = None

class Recipient(BaseModel):
    model_config = ConfigDict(extra='forbid')
    names: List[ForensicDataEntity]
    address: ForensicDataEntity

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    deposits_and_other_credits_count: ForensicDataEntity
    deposits_and_other_credits_amount: ForensicDataEntity
    checks_and_other_debits_count: ForensicDataEntity
    checks_and_other_debits_amount: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    number_of_days_in_period: ForensicDataEntity

class CheckTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    serial: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class AccountTransaction(BaseModel):
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
    interest_paid_ytd: Optional[ForensicDataEntity] = None
    days_in_period: ForensicDataEntity
    interest_earned: ForensicDataEntity
    apy_earned: ForensicDataEntity

class FeesSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    overdraft_fees_period: Optional[ForensicDataEntity] = None
    overdraft_fees_ytd: Optional[ForensicDataEntity] = None
    returned_item_fees_period: Optional[ForensicDataEntity] = None
    returned_item_fees_ytd: Optional[ForensicDataEntity] = None

class ChemicalBankStatement_00006(BaseModel):
    """
    A Pydantic V2 schema for parsing Chemical Bank statements.
    This schema is designed to be resilient to structural variations and includes
    a GAAP-based financial consistency validator.
    """
    model_config = ConfigDict(extra='forbid')
    
    issuer: Issuer
    recipient: Recipient
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    cycle_code: Optional[ForensicDataEntity] = None
    beginning_rate: Optional[ForensicDataEntity] = None
    account_summary: AccountSummary
    check_transactions: Optional[List[CheckTransaction]] = None
    account_transactions: Optional[List[AccountTransaction]] = None
    daily_balances: Optional[List[DailyBalance]] = None
    interest_summary: Optional[InterestSummary] = None
    fees_summary: Optional[FeesSummary] = None

    @model_validator(mode='after')
    def validate_financial_consistency(self) -> 'ChemicalBankStatement_00006':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        1. Validates: Previous Balance + Credits - Debits = Current Balance.
        2. Validates: Sum of detailed transactions matches summary totals.
        3. Validates: Interest earned in summary matches interest transaction.
        """
        TOLERANCE = Decimal('0.02')

        # 1. Validate summary balance equation
        summary = self.account_summary
        prev_bal = Decimal(str(summary.previous_statement_balance.extracted_string_or_numeric_value))
        curr_bal = Decimal(str(summary.current_statement_balance.extracted_string_or_numeric_value))
        summary_credits = Decimal(str(summary.deposits_and_other_credits_amount.extracted_string_or_numeric_value))
        summary_debits = Decimal(str(summary.checks_and_other_debits_amount.extracted_string_or_numeric_value))

        if abs((prev_bal + summary_credits - summary_debits) - curr_bal) > TOLERANCE:
            raise ValueError(f"Balance calculation failed: {prev_bal} + {summary_credits} - {summary_debits} != {curr_bal}")

        # 2. Validate detailed transactions against summary totals
        calculated_debits = Decimal('0.00')
        if self.check_transactions:
            for check in self.check_transactions:
                calculated_debits += Decimal(str(check.amount.extracted_string_or_numeric_value))
        
        if self.account_transactions:
            for trans in self.account_transactions:
                if trans.debit:
                    calculated_debits += Decimal(str(trans.debit.extracted_string_or_numeric_value))

        if abs(calculated_debits - summary_debits) > TOLERANCE:
            raise ValueError(f"Sum of detailed debits ({calculated_debits}) does not match summary debits ({summary_debits})")

        calculated_credits = Decimal('0.00')
        if self.account_transactions:
            for trans in self.account_transactions:
                if trans.credit:
                    calculated_credits += Decimal(str(trans.credit.extracted_string_or_numeric_value))

        if abs(calculated_credits - summary_credits) > TOLERANCE:
            raise ValueError(f"Sum of detailed credits ({calculated_credits}) does not match summary credits ({summary_credits})")
        
        # 3. Validate interest consistency
        if self.interest_summary:
            interest_earned_summary = Decimal(str(self.interest_summary.interest_earned.extracted_string_or_numeric_value))
            interest_earned_transaction = Decimal('0.00')
            if self.account_transactions:
                for trans in self.account_transactions:
                    if 'INTEREST PAYMENT' in str(trans.description.extracted_string_or_numeric_value) and trans.credit:
                        interest_earned_transaction = Decimal(str(trans.credit.extracted_string_or_numeric_value))
                        break
            
            if abs(interest_earned_summary - interest_earned_transaction) > TOLERANCE:
                raise ValueError(f"Interest earned in summary ({interest_earned_summary}) does not match interest payment transaction ({interest_earned_transaction})")

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "00006_2010-06-13_full_statement_test",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatement_00006",
    "binary_header_simulation": "25504446",
    "payload": {
      "issuer": {
        "name": {
          "extracted_string_or_numeric_value": "CHEMICAL BANK",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [40, 50] }
        },
        "address": {
          "extracted_string_or_numeric_value": "MCBAIN\n101 N. ROLAND\nMCBAIN, MI 49657",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [120, 220], "vertical_y_vertices": [55, 95] }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-825-2451",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [230, 330], "vertical_y_vertices": [110, 120] }
        }
      },
      "recipient": {
        "names": [
          {
            "extracted_string_or_numeric_value": "JUDITH A GRANDY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 280], "vertical_y_vertices": [140, 150] }
          },
          {
            "extracted_string_or_numeric_value": "MARK W KIBBY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 260], "vertical_y_vertices": [155, 165] }
          },
          {
            "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 270], "vertical_y_vertices": [170, 180] }
          }
        ],
        "address": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD\nPO BOX 297\nMARION MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 280], "vertical_y_vertices": [185, 225] }
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "06/13/10",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 850], "vertical_y_vertices": [135, 145] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2010277008",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 870], "vertical_y_vertices": [180, 190] }
      },
      "cycle_code": {
        "extracted_string_or_numeric_value": "046",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 870], "vertical_y_vertices": [210, 220] }
      },
      "beginning_rate": {
        "extracted_string_or_numeric_value": 0.15000,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 870], "vertical_y_vertices": [225, 235] }
      },
      "account_summary": {
        "previous_statement_balance": {
          "extracted_string_or_numeric_value": 53148.93,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 760], "vertical_y_vertices": [255, 265] }
        },
        "deposits_and_other_credits_count": {
          "extracted_string_or_numeric_value": "6",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 220], "vertical_y_vertices": [270, 280] }
        },
        "deposits_and_other_credits_amount": {
          "extracted_string_or_numeric_value": 12416.97,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 760], "vertical_y_vertices": [270, 280] }
        },
        "checks_and_other_debits_count": {
          "extracted_string_or_numeric_value": "17",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 220], "vertical_y_vertices": [285, 295] }
        },
        "checks_and_other_debits_amount": {
          "extracted_string_or_numeric_value": 21891.14,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 760], "vertical_y_vertices": [285, 295] }
        },
        "current_statement_balance": {
          "extracted_string_or_numeric_value": 43674.76,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 760], "vertical_y_vertices": [300, 310] }
        },
        "number_of_days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 540], "vertical_y_vertices": [315, 325] }
        }
      },
      "check_transactions": [
        { "serial": { "extracted_string_or_numeric_value": "3696", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 190], "vertical_y_vertices": [365, 375] } }, "date": { "extracted_string_or_numeric_value": "05/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260], "vertical_y_vertices": [365, 375] } }, "amount": { "extracted_string_or_numeric_value": 475.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [365, 375] } } },
        { "serial": { "extracted_string_or_numeric_value": "3697", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 190], "vertical_y_vertices": [380, 390] } }, "date": { "extracted_string_or_numeric_value": "05/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260], "vertical_y_vertices": [380, 390] } }, "amount": { "extracted_string_or_numeric_value": 1300.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [380, 390] } } },
        { "serial": { "extracted_string_or_numeric_value": "4002*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 190], "vertical_y_vertices": [395, 405] } }, "date": { "extracted_string_or_numeric_value": "05/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260], "vertical_y_vertices": [395, 405] } }, "amount": { "extracted_string_or_numeric_value": 19.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [395, 405] } } },
        { "serial": { "extracted_string_or_numeric_value": "4003", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 190], "vertical_y_vertices": [410, 420] } }, "date": { "extracted_string_or_numeric_value": "05/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260], "vertical_y_vertices": [410, 420] } }, "amount": { "extracted_string_or_numeric_value": 174.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [410, 420] } } },
        { "serial": { "extracted_string_or_numeric_value": "4004", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 190], "vertical_y_vertices": [425, 435] } }, "date": { "extracted_string_or_numeric_value": "05/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260], "vertical_y_vertices": [425, 435] } }, "amount": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [425, 435] } } },
        { "serial": { "extracted_string_or_numeric_value": "4005", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 190], "vertical_y_vertices": [440, 450] } }, "date": { "extracted_string_or_numeric_value": "05/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 260], "vertical_y_vertices": [440, 450] } }, "amount": { "extracted_string_or_numeric_value": 175.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [440, 450] } } },
        { "serial": { "extracted_string_or_numeric_value": "4006", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 590], "vertical_y_vertices": [365, 375] } }, "date": { "extracted_string_or_numeric_value": "05/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 660], "vertical_y_vertices": [365, 375] } }, "amount": { "extracted_string_or_numeric_value": 3236.08, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [365, 375] } } },
        { "serial": { "extracted_string_or_numeric_value": "4009*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 590], "vertical_y_vertices": [380, 390] } }, "date": { "extracted_string_or_numeric_value": "05/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 660], "vertical_y_vertices": [380, 390] } }, "amount": { "extracted_string_or_numeric_value": 7940.88, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [380, 390] } } },
        { "serial": { "extracted_string_or_numeric_value": "4010", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 590], "vertical_y_vertices": [395, 405] } }, "date": { "extracted_string_or_numeric_value": "05/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 660], "vertical_y_vertices": [395, 405] } }, "amount": { "extracted_string_or_numeric_value": 2500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [395, 405] } } },
        { "serial": { "extracted_string_or_numeric_value": "4011", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 590], "vertical_y_vertices": [410, 420] } }, "date": { "extracted_string_or_numeric_value": "06/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 660], "vertical_y_vertices": [410, 420] } }, "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [410, 420] } } },
        { "serial": { "extracted_string_or_numeric_value": "4012", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 590], "vertical_y_vertices": [425, 435] } }, "date": { "extracted_string_or_numeric_value": "06/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 660], "vertical_y_vertices": [425, 435] } }, "amount": { "extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [425, 435] } } },
        { "serial": { "extracted_string_or_numeric_value": "4013", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 590], "vertical_y_vertices": [440, 450] } }, "date": { "extracted_string_or_numeric_value": "06/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 660], "vertical_y_vertices": [440, 450] } }, "amount": { "extracted_string_or_numeric_value": 18.09, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [440, 450] } } }
      ],
      "account_transactions": [
        { "date": { "extracted_string_or_numeric_value": "05/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [485, 495] } }, "description": { "extracted_string_or_numeric_value": "AC-LINCOLN NATL. -LIFE", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [485, 495] } }, "debit": { "extracted_string_or_numeric_value": 1666.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [485, 495] } }, "credit": null },
        { "date": { "extracted_string_or_numeric_value": "05/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [500, 510] } }, "description": { "extracted_string_or_numeric_value": "AC-US TREASURY 303 -SOC SEC", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [500, 510] } }, "debit": null, "credit": { "extracted_string_or_numeric_value": 699.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 750], "vertical_y_vertices": [500, 510] } } },
        { "date": { "extracted_string_or_numeric_value": "05/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [515, 525] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [515, 525] } }, "debit": null, "credit": { "extracted_string_or_numeric_value": 1200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 750], "vertical_y_vertices": [515, 525] } } },
        { "date": { "extracted_string_or_numeric_value": "05/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [530, 540] } }, "description": { "extracted_string_or_numeric_value": "AC-PACIFIC LIFE -INS PMT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [530, 540] } }, "debit": { "extracted_string_or_numeric_value": 1666.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [530, 540] } }, "credit": null },
        { "date": { "extracted_string_or_numeric_value": "05/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [545, 555] } }, "description": { "extracted_string_or_numeric_value": "WITHDRAWAL", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [545, 555] } }, "debit": { "extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [545, 555] } }, "credit": null },
        { "date": { "extracted_string_or_numeric_value": "05/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [560, 570] } }, "description": { "extracted_string_or_numeric_value": "AC-GM CARD 3 -CHECKPAYMT CK-00004008", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [560, 580] } }, "debit": { "extracted_string_or_numeric_value": 365.58, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [560, 570] } }, "credit": null },
        { "date": { "extracted_string_or_numeric_value": "05/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [590, 600] } }, "description": { "extracted_string_or_numeric_value": "AC-AT&T SERVICES -CHECKPAYMT CK-00004007", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [590, 610] } }, "debit": { "extracted_string_or_numeric_value": 77.37, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [590, 600] } }, "credit": null },
        { "date": { "extracted_string_or_numeric_value": "06/01", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [620, 630] } }, "description": { "extracted_string_or_numeric_value": "AC-SPARTAN STORES -ACCTSPYBLE ISA*00* *00*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [620, 650] } }, "debit": null, "credit": { "extracted_string_or_numeric_value": 8712.78, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 750], "vertical_y_vertices": [620, 630] } } },
        { "date": { "extracted_string_or_numeric_value": "06/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [655, 665] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [655, 665] } }, "debit": null, "credit": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 750], "vertical_y_vertices": [655, 665] } } },
        { "date": { "extracted_string_or_numeric_value": "06/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [670, 680] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [670, 680] } }, "debit": null, "credit": { "extracted_string_or_numeric_value": 800.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 750], "vertical_y_vertices": [670, 680] } } },
        { "date": { "extracted_string_or_numeric_value": "06/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [685, 695] } }, "description": { "extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 400], "vertical_y_vertices": [685, 695] } }, "debit": null, "credit": { "extracted_string_or_numeric_value": 5.19, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 750], "vertical_y_vertices": [685, 695] } } }
      ],
      "fees_summary": {
        "overdraft_fees_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580], "vertical_y_vertices": [750, 760] } },
        "overdraft_fees_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 720], "vertical_y_vertices": [750, 760] } },
        "returned_item_fees_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580], "vertical_y_vertices": [765, 775] } },
        "returned_item_fees_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 720], "vertical_y_vertices": [765, 775] } }
      },
      "daily_balances": [
        { "date": { "extracted_string_or_numeric_value": "05/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [820, 830] } }, "balance": { "extracted_string_or_numeric_value": 53148.93, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 270], "vertical_y_vertices": [820, 830] } } },
        { "date": { "extracted_string_or_numeric_value": "05/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [820, 830] } }, "balance": { "extracted_string_or_numeric_value": 49738.85, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 400], "vertical_y_vertices": [820, 830] } } },
        { "date": { "extracted_string_or_numeric_value": "05/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 450], "vertical_y_vertices": [820, 830] } }, "balance": { "extracted_string_or_numeric_value": 46397.85, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 530], "vertical_y_vertices": [820, 830] } } },
        { "date": { "extracted_string_or_numeric_value": "05/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [820, 830] } }, "balance": { "extracted_string_or_numeric_value": 46111.85, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 660], "vertical_y_vertices": [820, 830] } } },
        { "date": { "extracted_string_or_numeric_value": "05/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [835, 845] } }, "balance": { "extracted_string_or_numeric_value": 36030.39, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 270], "vertical_y_vertices": [835, 845] } } },
        { "date": { "extracted_string_or_numeric_value": "05/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [835, 845] } }, "balance": { "extracted_string_or_numeric_value": 35953.02, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 400], "vertical_y_vertices": [835, 845] } } },
        { "date": { "extracted_string_or_numeric_value": "05/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 450], "vertical_y_vertices": [835, 845] } }, "balance": { "extracted_string_or_numeric_value": 33453.02, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 530], "vertical_y_vertices": [835, 845] } } },
        { "date": { "extracted_string_or_numeric_value": "06/01", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [835, 845] } }, "balance": { "extracted_string_or_numeric_value": 42165.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 660], "vertical_y_vertices": [835, 845] } } },
        { "date": { "extracted_string_or_numeric_value": "06/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [850, 860] } }, "balance": { "extracted_string_or_numeric_value": 42065.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 270], "vertical_y_vertices": [850, 860] } } },
        { "date": { "extracted_string_or_numeric_value": "06/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [850, 860] } }, "balance": { "extracted_string_or_numeric_value": 43065.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 400], "vertical_y_vertices": [850, 860] } } },
        { "date": { "extracted_string_or_numeric_value": "06/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 450], "vertical_y_vertices": [850, 860] } }, "balance": { "extracted_string_or_numeric_value": 43687.66, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 530], "vertical_y_vertices": [850, 860] } } },
        { "date": { "extracted_string_or_numeric_value": "06/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [850, 860] } }, "balance": { "extracted_string_or_numeric_value": 43669.57, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 660], "vertical_y_vertices": [850, 860] } } },
        { "date": { "extracted_string_or_numeric_value": "06/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 190], "vertical_y_vertices": [865, 875] } }, "balance": { "extracted_string_or_numeric_value": 43674.76, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 270], "vertical_y_vertices": [865, 875] } } }
      ],
      "interest_summary": {
        "payer_federal_id": {
          "extracted_string_or_numeric_value": "38-0415896",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 600], "vertical_y_vertices": [740, 750] }
        },
        "interest_paid_ytd": {
          "extracted_string_or_numeric_value": 45.48,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 600], "vertical_y_vertices": [755, 765] }
        },
        "days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 600], "vertical_y_vertices": [790, 800] }
        },
        "interest_earned": {
          "extracted_string_or_numeric_value": 5.19,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 600], "vertical_y_vertices": [805, 815] }
        },
        "apy_earned": {
          "extracted_string_or_numeric_value": "0.15%",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 600], "vertical_y_vertices": [820, 830] }
        }
      }
    }
  }
]
```