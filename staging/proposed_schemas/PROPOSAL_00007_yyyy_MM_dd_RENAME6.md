An analysis of the provided document, a multi-page bank statement from Chemical Bank, reveals a comprehensive financial summary that includes an overall balance calculation, detailed transaction lists, daily balance tracking, and images of cleared checks. The document exhibits strong internal consistency, where summary totals for debits and credits are fully supported by the itemized transaction lists.

The resilient Pydantic V2 schema is designed to capture this structure. It defines distinct models for each logical section, such as issuer/recipient information, the main account summary, and various transaction types. Optional fields are used for sections that may not appear on every statement, like fee summaries or check images.

The core of the schema's resilience lies in its `model_validator`. This function performs a series of double-entry accounting checks to mathematically verify the statement's integrity:
1.  It confirms that the `previous_balance` plus total `deposits/credits` minus total `checks/debits` equals the `current_balance`.
2.  It cross-references the summary totals by summing all individual debit transactions (from both the "Check Transactions" and "Checking Account Transactions" lists) and ensuring this sum matches the `checks_and_debits` summary figure.
3.  It performs a similar cross-reference for credits, summing all credit transactions to validate the `deposits_and_credits` summary figure.

This multi-layered validation ensures that any extracted data not only conforms to the expected structure but is also financially coherent, fulfilling the Zero-Trust mandate by programmatically verifying the document's internal claims.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
import decimal

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices for spatial location."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class IssuerInfo(BaseModel):
    """Information about the financial institution issuing the statement."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: ForensicDataEntity

class RecipientInfo(BaseModel):
    """Information about the account holder."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity

class StatementSummary(BaseModel):
    """High-level summary of account activity for the statement period."""
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    deposits_and_credits: ForensicDataEntity
    checks_and_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    statement_period_days: ForensicDataEntity

class CheckTransaction(BaseModel):
    """A record of a single check transaction from the summary list."""
    model_config = ConfigDict(extra='forbid')
    serial_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class AccountTransaction(BaseModel):
    """A detailed record of a single transaction, which can be a debit or a credit."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class FeeSummary(BaseModel):
    """Summary of fees incurred during the period and year-to-date."""
    model_config = ConfigDict(extra='forbid')
    total_overdraft_fees_period: ForensicDataEntity
    total_overdraft_fees_ytd: ForensicDataEntity
    total_returned_item_fees_period: ForensicDataEntity
    total_returned_item_fees_ytd: ForensicDataEntity

class DailyBalance(BaseModel):
    """Record of the account balance on a specific day."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class InterestSummary(BaseModel):
    """Summary of interest earned during the statement period."""
    model_config = ConfigDict(extra='forbid')
    payer_federal_id_number: Optional[ForensicDataEntity] = None
    interest_paid_ytd: ForensicDataEntity
    interest_earned_this_period: ForensicDataEntity
    annual_percentage_yield: ForensicDataEntity

class ClearedCheckImage(BaseModel):
    """Data extracted from the image of a cleared check."""
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    paid_date: ForensicDataEntity
    amount: ForensicDataEntity

class ChemicalBankStatement(BaseModel):
    """
    Represents a complete Chemical Bank checking account statement, incorporating
    all sections from summary to detailed transactions and check images.
    """
    model_config = ConfigDict(extra='forbid')
    
    issuer: IssuerInfo
    recipient: RecipientInfo
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    cycle: Optional[ForensicDataEntity] = None
    beginning_rate: Optional[ForensicDataEntity] = None
    
    summary: StatementSummary
    check_transactions: List[CheckTransaction]
    account_transactions: List[AccountTransaction]
    
    fee_summary: Optional[FeeSummary] = None
    daily_balances: Optional[List[DailyBalance]] = None
    interest_summary: Optional[InterestSummary] = None
    cleared_checks: Optional[List[ClearedCheckImage]] = None

    @model_validator(mode='after')
    def validate_financial_integrity(self) -> 'ChemicalBankStatement':
        """
        Performs double-entry GAAP-style checksums to ensure financial consistency.
        1. Validates summary balance: Previous + Credits - Debits = Current.
        2. Validates summary debits against the sum of all detailed debit transactions.
        3. Validates summary credits against the sum of all detailed credit transactions.
        """
        ctx = decimal.Context(prec=10)

        # 1. Validate summary balance calculation
        start_balance = ctx.create_decimal(self.summary.previous_statement_balance.extracted_string_or_numeric_value)
        end_balance = ctx.create_decimal(self.summary.current_statement_balance.extracted_string_or_numeric_value)
        summary_credits = ctx.create_decimal(self.summary.deposits_and_credits.extracted_string_or_numeric_value)
        summary_debits = ctx.create_decimal(self.summary.checks_and_debits.extracted_string_or_numeric_value)

        calculated_end_balance = start_balance + summary_credits - summary_debits
        if abs(calculated_end_balance - end_balance) > decimal.Decimal('0.01'):
            raise ValueError(f"Summary balance mismatch: {start_balance} + {summary_credits} - {summary_debits} = {calculated_end_balance}, but statement shows {end_balance}")

        # 2. Validate summary debits against detailed transaction lists
        detailed_account_debits = sum(
            (ctx.create_decimal(t.debit.extracted_string_or_numeric_value) for t in self.account_transactions if t.debit),
            ctx.create_decimal('0.0')
        )
        detailed_check_debits = sum(
            (ctx.create_decimal(c.amount.extracted_string_or_numeric_value) for c in self.check_transactions),
            ctx.create_decimal('0.0')
        )
        total_calculated_debits = detailed_account_debits + detailed_check_debits
        if abs(total_calculated_debits - summary_debits) > decimal.Decimal('0.01'):
            raise ValueError(f"Detailed debits mismatch: Sum of detailed debits ({total_calculated_debits}) does not match summary debits ({summary_debits})")

        # 3. Validate summary credits against detailed transaction list
        detailed_credits = sum(
            (ctx.create_decimal(t.credit.extracted_string_or_numeric_value) for t in self.account_transactions if t.credit),
            ctx.create_decimal('0.0')
        )
        if abs(detailed_credits - summary_credits) > decimal.Decimal('0.01'):
            raise ValueError(f"Detailed credits mismatch: Sum of detailed credits ({detailed_credits}) does not match summary credits ({summary_credits})")
        
        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "chemical_bank_statement_20100713_full",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "issuer": {
        "name": {
          "extracted_string_or_numeric_value": "CHEMICAL BANK",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [153, 283, 283, 153], "vertical_y_vertices": [42, 42, 52, 52] }
        },
        "address": {
          "extracted_string_or_numeric_value": "MCBAIN\n101 N. ROLAND\nMCBAIN, MI 49657",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [153, 283, 283, 153], "vertical_y_vertices": [56, 56, 96, 96] }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-825-2451",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [231, 330, 330, 231], "vertical_y_vertices": [109, 109, 119, 119] }
        }
      },
      "recipient": {
        "name": {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY\nMARK W KIBBY\nMICHAEL J KIBBY",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [231, 360, 360, 231], "vertical_y_vertices": [142, 142, 172, 172] }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD\nPO BOX 297\nMARION MI 49665",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [231, 360, 360, 231], "vertical_y_vertices": [175, 175, 215, 215] }
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "07/13/10",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 869, 869, 790], "vertical_y_vertices": [135, 135, 145, 145] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2010277008",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 869, 869, 790], "vertical_y_vertices": [171, 171, 181, 181] }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "046",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [830, 869, 869, 830], "vertical_y_vertices": [210, 210, 220, 220] }
      },
      "beginning_rate": {
        "extracted_string_or_numeric_value": 0.15000,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [810, 869, 869, 810], "vertical_y_vertices": [229, 229, 239, 239] }
      },
      "summary": {
        "previous_statement_balance": {
          "extracted_string_or_numeric_value": 43674.76,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 869, 869, 800], "vertical_y_vertices": [255, 255, 265, 265] }
        },
        "deposits_and_credits": {
          "extracted_string_or_numeric_value": 12107.40,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 869, 869, 800], "vertical_y_vertices": [267, 267, 277, 277] }
        },
        "checks_and_debits": {
          "extracted_string_or_numeric_value": 21446.98,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 869, 869, 800], "vertical_y_vertices": [279, 279, 289, 289] }
        },
        "current_statement_balance": {
          "extracted_string_or_numeric_value": 34335.18,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 869, 869, 800], "vertical_y_vertices": [291, 291, 301, 301] }
        },
        "statement_period_days": {
          "extracted_string_or_numeric_value": 30,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [535, 548, 548, 535], "vertical_y_vertices": [303, 303, 313, 313] }
        }
      },
      "check_transactions": [
        { "serial_number": { "extracted_string_or_numeric_value": "4014", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [169, 196, 196, 169], "vertical_y_vertices": [360, 360, 370, 370] } }, "date": { "extracted_string_or_numeric_value": "06/14", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 255, 255, 220], "vertical_y_vertices": [360, 360, 370, 370] } }, "amount": { "extracted_string_or_numeric_value": 175.09, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450, 450, 400], "vertical_y_vertices": [360, 360, 370, 370] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4019*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [169, 196, 196, 169], "vertical_y_vertices": [372, 372, 382, 382] } }, "date": { "extracted_string_or_numeric_value": "06/21", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 255, 255, 220], "vertical_y_vertices": [372, 372, 382, 382] } }, "amount": { "extracted_string_or_numeric_value": 5000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450, 450, 400], "vertical_y_vertices": [372, 372, 382, 382] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4020", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [169, 196, 196, 169], "vertical_y_vertices": [384, 384, 394, 394] } }, "date": { "extracted_string_or_numeric_value": "06/23", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 255, 255, 220], "vertical_y_vertices": [384, 384, 394, 394] } }, "amount": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450, 450, 400], "vertical_y_vertices": [384, 384, 394, 394] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4021", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [169, 196, 196, 169], "vertical_y_vertices": [396, 396, 406, 406] } }, "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 255, 255, 220], "vertical_y_vertices": [396, 396, 406, 406] } }, "amount": { "extracted_string_or_numeric_value": 580.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450, 450, 400], "vertical_y_vertices": [396, 396, 406, 406] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4023*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [169, 196, 196, 169], "vertical_y_vertices": [408, 408, 418, 418] } }, "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 255, 255, 220], "vertical_y_vertices": [408, 408, 418, 418] } }, "amount": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450, 450, 400], "vertical_y_vertices": [408, 408, 418, 418] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4026*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580, 580, 550], "vertical_y_vertices": [360, 360, 370, 370] } }, "date": { "extracted_string_or_numeric_value": "07/08", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 635, 635, 600], "vertical_y_vertices": [360, 360, 370, 370] } }, "amount": { "extracted_string_or_numeric_value": 40.69, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830, 830, 780], "vertical_y_vertices": [360, 360, 370, 370] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4028*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580, 580, 550], "vertical_y_vertices": [372, 372, 382, 382] } }, "date": { "extracted_string_or_numeric_value": "07/07", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 635, 635, 600], "vertical_y_vertices": [372, 372, 382, 382] } }, "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830, 830, 780], "vertical_y_vertices": [372, 372, 382, 382] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4029", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580, 580, 550], "vertical_y_vertices": [384, 384, 394, 394] } }, "date": { "extracted_string_or_numeric_value": "07/12", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 635, 635, 600], "vertical_y_vertices": [384, 384, 394, 394] } }, "amount": { "extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830, 830, 780], "vertical_y_vertices": [384, 384, 394, 394] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4030", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580, 580, 550], "vertical_y_vertices": [396, 396, 406, 406] } }, "date": { "extracted_string_or_numeric_value": "07/12", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 635, 635, 600], "vertical_y_vertices": [396, 396, 406, 406] } }, "amount": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830, 830, 780], "vertical_y_vertices": [396, 396, 406, 406] } } },
        { "serial_number": { "extracted_string_or_numeric_value": "4031", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580, 580, 550], "vertical_y_vertices": [408, 408, 418, 418] } }, "date": { "extracted_string_or_numeric_value": "07/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 635, 635, 600], "vertical_y_vertices": [408, 408, 418, 418] } }, "amount": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830, 830, 780], "vertical_y_vertices": [408, 408, 418, 418] } } }
      ],
      "account_transactions": [
        { "date": { "extracted_string_or_numeric_value": "06/15", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [465, 465, 475, 475] } }, "description": { "extracted_string_or_numeric_value": "AC-LINCOLN NATL -LIFE", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [465, 465, 475, 475] } }, "debit": { "extracted_string_or_numeric_value": 1666.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [477, 477, 487, 487] } } },
        { "date": { "extracted_string_or_numeric_value": "06/16", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [477, 477, 487, 487] } }, "description": { "extracted_string_or_numeric_value": "AC-US TREASURY 303-SOC SEC", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [477, 477, 487, 487] } }, "credit": { "extracted_string_or_numeric_value": 699.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [477, 477, 487, 487] } } },
        { "date": { "extracted_string_or_numeric_value": "06/16", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [489, 489, 499, 499] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [489, 489, 499, 499] } }, "credit": { "extracted_string_or_numeric_value": 640.13, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [489, 489, 499, 499] } } },
        { "date": { "extracted_string_or_numeric_value": "06/17", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [501, 501, 511, 511] } }, "description": { "extracted_string_or_numeric_value": "AC-PACIFIC LIFE -INS PMT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [501, 501, 511, 511] } }, "debit": { "extracted_string_or_numeric_value": 1666.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [501, 501, 511, 511] } } },
        { "date": { "extracted_string_or_numeric_value": "06/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [513, 513, 523, 523] } }, "description": { "extracted_string_or_numeric_value": "AC-SPARTAN STORES -ACCTSPYBLE\nISA*00* *00*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [513, 513, 535, 535] } }, "credit": { "extracted_string_or_numeric_value": 0.01, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [525, 525, 535, 535] } } },
        { "date": { "extracted_string_or_numeric_value": "06/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [549, 549, 559, 559] } }, "description": { "extracted_string_or_numeric_value": "AC-RETAIL SERVICES3-CHECKPAYMT\nCK-00004017", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [549, 549, 571, 571] } }, "debit": { "extracted_string_or_numeric_value": 42.39, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [549, 549, 559, 559] } } },
        { "date": { "extracted_string_or_numeric_value": "06/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [573, 573, 583, 583] } }, "description": { "extracted_string_or_numeric_value": "AC-GM CARD 3 -CHECKΡΑΥΜΤ\nCK-00004016", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [573, 573, 595, 595] } }, "debit": { "extracted_string_or_numeric_value": 323.58, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [573, 573, 583, 583] } } },
        { "date": { "extracted_string_or_numeric_value": "06/21", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [597, 597, 607, 607] } }, "description": { "extracted_string_or_numeric_value": "AC-AT&T SERVICES -CHECKΡΑΥΜΤ\nCK-00004018", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [597, 597, 619, 619] } }, "debit": { "extracted_string_or_numeric_value": 76.94, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [597, 597, 607, 607] } } },
        { "date": { "extracted_string_or_numeric_value": "06/23", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [621, 621, 631, 631] } }, "description": { "extracted_string_or_numeric_value": "WITHDRAWAL", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [621, 621, 631, 631] } }, "debit": { "extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [621, 621, 631, 631] } } },
        { "date": { "extracted_string_or_numeric_value": "07/01", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [633, 633, 643, 643] } }, "description": { "extracted_string_or_numeric_value": "AC-SPARTAN STORES -ACCTSPYBLE\nISA*00* *00*", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [633, 633, 655, 655] } }, "credit": { "extracted_string_or_numeric_value": 8712.78, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [633, 633, 643, 643] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [657, 657, 667, 667] } }, "description": { "extracted_string_or_numeric_value": "AC-KOHLS CHG PMT -CHECK PMT\nCK-000000000004027\nNUMBER 0000004027", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [657, 657, 691, 691] } }, "debit": { "extracted_string_or_numeric_value": 135.12, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [657, 657, 667, 667] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [705, 705, 715, 715] } }, "description": { "extracted_string_or_numeric_value": "AC-ALLSTATE P&C INS-CHECKΡΑΥΜΤ\nCK-00004024", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [705, 705, 727, 727] } }, "debit": { "extracted_string_or_numeric_value": 313.59, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [705, 705, 715, 715] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [729, 729, 739, 739] } }, "description": { "extracted_string_or_numeric_value": "AC-ALLSTATE P&C INS-CHECKPAYMT\nCK-00004025", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [729, 729, 751, 751] } }, "debit": { "extracted_string_or_numeric_value": 786.71, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [729, 729, 739, 739] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [753, 753, 763, 763] } }, "description": { "extracted_string_or_numeric_value": "AC-FIA CARDSERVICES-CHECK PYMT\nCK-00004022", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [753, 753, 775, 775] } }, "debit": { "extracted_string_or_numeric_value": 6312.73, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 620, 620, 560], "vertical_y_vertices": [753, 753, 763, 763] } } },
        { "date": { "extracted_string_or_numeric_value": "07/08", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [777, 777, 787, 787] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [777, 777, 787, 787] } }, "credit": { "extracted_string_or_numeric_value": 1410.71, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [777, 777, 787, 787] } } },
        { "date": { "extracted_string_or_numeric_value": "07/12", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [789, 789, 799, 799] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [789, 789, 799, 799] } }, "credit": { "extracted_string_or_numeric_value": 640.13, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [789, 789, 799, 799] } } },
        { "date": { "extracted_string_or_numeric_value": "07/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 175, 175, 140], "vertical_y_vertices": [801, 801, 811, 811] } }, "description": { "extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 400, 400, 185], "vertical_y_vertices": [801, 801, 811, 811] } }, "credit": { "extracted_string_or_numeric_value": 4.64, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [801, 801, 811, 811] } } }
      ],
      "fee_summary": {
        "total_overdraft_fees_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } },
        "total_overdraft_fees_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } },
        "total_returned_item_fees_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } },
        "total_returned_item_fees_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }
      },
      "daily_balances": [
        { "date": { "extracted_string_or_numeric_value": "06/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 43674.76, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/14", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 43499.67, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/15", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 41833.67, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/16", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 43172.80, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/17", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 41506.80, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/18", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 41140.84, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/21", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 36063.90, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 35483.90, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "06/23", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 33983.90, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "07/01", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 42696.68, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 34148.53, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "07/07", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 34048.53, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "07/08", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 35418.55, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "07/12", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 34380.54, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "date": { "extracted_string_or_numeric_value": "07/13", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "balance": { "extracted_string_or_numeric_value": 34335.18, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } }
      ],
      "interest_summary": {
        "payer_federal_id_number": { "extracted_string_or_numeric_value": "38-0415896", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } },
        "interest_paid_ytd": { "extracted_string_or_numeric_value": 50.12, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } },
        "interest_earned_this_period": { "extracted_string_or_numeric_value": 4.64, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } },
        "annual_percentage_yield": { "extracted_string_or_numeric_value": "0.15%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }
      },
      "cleared_checks": [
        { "check_number": { "extracted_string_or_numeric_value": "0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "06/23/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4014", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "06/14/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 175.09, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4019", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "06/21/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 5000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4020", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "06/23/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4021", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "06/22/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 580.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4023", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "07/06/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4026", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "07/08/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 40.69, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4028", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "07/07/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4029", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "07/12/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 178.14, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4030", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "07/12/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4031", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "paid_date": { "extracted_string_or_numeric_value": "07/13/2010", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } }, "amount": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0, 0, 0], "vertical_y_vertices": [0, 0, 0, 0] } } }
      ]
    }
  }
]
```