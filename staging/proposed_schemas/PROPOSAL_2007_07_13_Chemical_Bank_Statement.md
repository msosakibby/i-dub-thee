An expert forensic data architect, I have meticulously analyzed the provided 2007 Chemical Bank Statement. The first document is a generic reconciliation guide, which, while informative for understanding the process, does not contain specific data points for schema definition. The second document is a populated statement and serves as the definitive source for creating a resilient data extraction schema.

The resulting Pydantic V2 schema captures the hierarchical structure of the bank statement, including account summaries, detailed transaction lists, and other metadata. A robust, multi-step GAAP validator ensures the mathematical integrity of the extracted financial data by cross-referencing summary totals with the sum of individual transaction line items and verifying the closing balance calculation.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

# MANDATORY: The exact ForensicDataEntity and SpatialCoordinatesPolygon classes.
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema definition starts here.
class AccountHolder(BaseModel):
    model_config = ConfigDict(extra='forbid')
    names: List[ForensicDataEntity]
    address: ForensicDataEntity

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    previous_statement_date: ForensicDataEntity
    total_deposits_and_credits: ForensicDataEntity
    total_checks_and_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    current_statement_date: ForensicDataEntity

class CheckTransactionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    serial: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class DetailedTransactionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class DailyBalanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class InterestAndFeeSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    payer_federal_id_number: ForensicDataEntity
    interest_paid_ytd: ForensicDataEntity
    statement_overdraft_charges: ForensicDataEntity
    statement_returned_item_charges: ForensicDataEntity
    ytd_overdraft_charges: ForensicDataEntity
    ytd_returned_item_charges: ForensicDataEntity

class ChemicalBankStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    
    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    cycle: ForensicDataEntity
    beginning_rate: ForensicDataEntity
    statement_period_days: ForensicDataEntity
    
    account_holder: AccountHolder
    account_summary: AccountSummary
    
    check_transactions: List[CheckTransactionItem]
    detailed_transactions: List[DetailedTransactionItem]
    daily_balances: List[DailyBalanceItem]
    
    interest_and_fee_summary: InterestAndFeeSummary

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'ChemicalBankStatement':
        """
        Performs double-entry accounting checks based on GAAP principles.
        1. Verifies that the sum of individual debits matches the summary total.
        2. Verifies that the sum of individual credits matches the summary total.
        3. Verifies the core balance equation: Prev Balance + Credits - Debits = Current Balance.
        """
        # 1. Sum individual debits from both transaction lists
        sum_of_check_debits = sum(
            item.amount.extracted_string_or_numeric_value
            for item in self.check_transactions
        )
        sum_of_other_debits = sum(
            item.debit.extracted_string_or_numeric_value
            for item in self.detailed_transactions if item.debit
        )
        calculated_total_debits = sum_of_check_debits + sum_of_other_debits
        summary_total_debits = self.account_summary.total_checks_and_debits.extracted_string_or_numeric_value

        if abs(calculated_total_debits - summary_total_debits) > 0.01:
            raise ValueError(f"Total Debits mismatch: Summary={summary_total_debits}, Calculated={calculated_total_debits}")

        # 2. Sum individual credits
        calculated_total_credits = sum(
            item.credit.extracted_string_or_numeric_value
            for item in self.detailed_transactions if item.credit
        )
        summary_total_credits = self.account_summary.total_deposits_and_credits.extracted_string_or_numeric_value

        if abs(calculated_total_credits - summary_total_credits) > 0.01:
            raise ValueError(f"Total Credits mismatch: Summary={summary_total_credits}, Calculated={calculated_total_credits}")

        # 3. Verify main balance equation
        prev_balance = self.account_summary.previous_statement_balance.extracted_string_or_numeric_value
        current_balance = self.account_summary.current_statement_balance.extracted_string_or_numeric_value
        
        calculated_end_balance = prev_balance + summary_total_credits - summary_total_debits
        
        if abs(calculated_end_balance - current_balance) > 0.01:
            raise ValueError(f"Ending Balance mismatch: Stated={current_balance}, Calculated={calculated_end_balance}")
            
        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "20070713-chemical-bank-grandy-kibby-0001019524",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 254], "vertical_y_vertices": [55, 65] }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N. ROLAND MCBAIN, MI 49657",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 254], "vertical_y_vertices": [68, 98] }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 254], "vertical_y_vertices": [110, 120] }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "07/13/07",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 850], "vertical_y_vertices": [130, 140] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "0001019524",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 850], "vertical_y_vertices": [160, 170] }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "ADVANTAGE CHECKING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 350], "vertical_y_vertices": [220, 230] }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "046",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 850], "vertical_y_vertices": [190, 200] }
      },
      "beginning_rate": {
        "extracted_string_or_numeric_value": 0.25000,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 850], "vertical_y_vertices": [220, 230] }
      },
      "statement_period_days": {
        "extracted_string_or_numeric_value": 30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 570], "vertical_y_vertices": [310, 320] }
      },
      "account_holder": {
        "names": [
          { "extracted_string_or_numeric_value": "JUDITH A GRANDY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 250], "vertical_y_vertices": [140, 150] } },
          { "extracted_string_or_numeric_value": "MARK W KIBBY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 250], "vertical_y_vertices": [151, 161] } },
          { "extracted_string_or_numeric_value": "MICHAEL J KIBBY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 250], "vertical_y_vertices": [162, 172] } }
        ],
        "address": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD PO BOX 297 MARION MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 250], "vertical_y_vertices": [173, 203] }
        }
      },
      "account_summary": {
        "previous_statement_balance": { "extracted_string_or_numeric_value": 17481.68, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [250, 260] } },
        "previous_statement_date": { "extracted_string_or_numeric_value": "06/13/07", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [250, 260] } },
        "total_deposits_and_credits": { "extracted_string_or_numeric_value": 16915.58, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [265, 275] } },
        "total_checks_and_debits": { "extracted_string_or_numeric_value": 22837.85, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [280, 290] } },
        "current_statement_balance": { "extracted_string_or_numeric_value": 11559.41, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [295, 305] } },
        "current_statement_date": { "extracted_string_or_numeric_value": "07/13/07", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [295, 305] } }
      },
      "check_transactions": [
        { "serial": { "extracted_string_or_numeric_value": 3271, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [350, 360] } }, "date": { "extracted_string_or_numeric_value": "06/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 230], "vertical_y_vertices": [350, 360] } }, "amount": { "extracted_string_or_numeric_value": 25.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 350], "vertical_y_vertices": [350, 360] } } },
        { "serial": { "extracted_string_or_numeric_value": 3277, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [361, 371] } }, "date": { "extracted_string_or_numeric_value": "06/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 230], "vertical_y_vertices": [361, 371] } }, "amount": { "extracted_string_or_numeric_value": 7500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 350], "vertical_y_vertices": [361, 371] } } },
        { "serial": { "extracted_string_or_numeric_value": 3278, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [372, 382] } }, "date": { "extracted_string_or_numeric_value": "06/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 230], "vertical_y_vertices": [372, 382] } }, "amount": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 350], "vertical_y_vertices": [372, 382] } } },
        { "serial": { "extracted_string_or_numeric_value": 3283, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [383, 393] } }, "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 230], "vertical_y_vertices": [383, 393] } }, "amount": { "extracted_string_or_numeric_value": 9675.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 350], "vertical_y_vertices": [383, 393] } } },
        { "serial": { "extracted_string_or_numeric_value": 3284, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580], "vertical_y_vertices": [350, 360] } }, "date": { "extracted_string_or_numeric_value": "06/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 630], "vertical_y_vertices": [350, 360] } }, "amount": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [350, 360] } } },
        { "serial": { "extracted_string_or_numeric_value": 3285, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580], "vertical_y_vertices": [361, 371] } }, "date": { "extracted_string_or_numeric_value": "07/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 630], "vertical_y_vertices": [361, 371] } }, "amount": { "extracted_string_or_numeric_value": 202.51, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [361, 371] } } },
        { "serial": { "extracted_string_or_numeric_value": 3286, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580], "vertical_y_vertices": [372, 382] } }, "date": { "extracted_string_or_numeric_value": "07/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 630], "vertical_y_vertices": [372, 382] } }, "amount": { "extracted_string_or_numeric_value": 327.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [372, 382] } } },
        { "serial": { "extracted_string_or_numeric_value": 3289, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 580], "vertical_y_vertices": [383, 393] } }, "date": { "extracted_string_or_numeric_value": "07/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 630], "vertical_y_vertices": [383, 393] } }, "amount": { "extracted_string_or_numeric_value": 19.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [383, 393] } } }
      ],
      "detailed_transactions": [
        { "date": { "extracted_string_or_numeric_value": "06/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [430, 440] } }, "description": { "extracted_string_or_numeric_value": "AC-RETAIL SERVICES3-CHECKPAYMT CK-00003275", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [430, 450] } }, "debit": { "extracted_string_or_numeric_value": 47.66, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [430, 440] } } },
        { "date": { "extracted_string_or_numeric_value": "06/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [451, 461] } }, "description": { "extracted_string_or_numeric_value": "AC-AT&T Consumer -CHECKPAYMT CK-00003276", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [451, 471] } }, "debit": { "extracted_string_or_numeric_value": 13.59, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [451, 461] } } },
        { "date": { "extracted_string_or_numeric_value": "06/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [472, 482] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [472, 482] } }, "credit": { "extracted_string_or_numeric_value": 5000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [472, 482] } } },
        { "date": { "extracted_string_or_numeric_value": "06/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [483, 493] } }, "description": { "extracted_string_or_numeric_value": "AC-CITICARD PAYMENT-CHECK PYMT CK-00003279", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [483, 503] } }, "debit": { "extracted_string_or_numeric_value": 1514.33, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [483, 493] } } },
        { "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [504, 514] } }, "description": { "extracted_string_or_numeric_value": "AC-SEARS PAYMENT -CHECK PYMT CK-00003280", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [504, 524] } }, "debit": { "extracted_string_or_numeric_value": 65.52, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [504, 514] } } },
        { "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [525, 535] } }, "description": { "extracted_string_or_numeric_value": "AC-AT&T Services -CHECKPAYMT CK-00003282", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [525, 545] } }, "debit": { "extracted_string_or_numeric_value": 101.98, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [525, 535] } } },
        { "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [546, 556] } }, "description": { "extracted_string_or_numeric_value": "AC-GM CARD 3 -CHECKPAYMT CK-00003281", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [546, 566] } }, "debit": { "extracted_string_or_numeric_value": 263.22, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [546, 556] } } },
        { "date": { "extracted_string_or_numeric_value": "07/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [567, 577] } }, "description": { "extracted_string_or_numeric_value": "AC-SPARTAN STORES -ACCTSPYBLE ISA*00* *00*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [567, 597] } }, "credit": { "extracted_string_or_numeric_value": 9470.42, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [567, 577] } } },
        { "date": { "extracted_string_or_numeric_value": "07/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [598, 608] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [598, 608] } }, "credit": { "extracted_string_or_numeric_value": 1000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [598, 608] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [609, 619] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [609, 619] } }, "credit": { "extracted_string_or_numeric_value": 735.62, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [609, 619] } } },
        { "date": { "extracted_string_or_numeric_value": "07/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [620, 630] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [620, 630] } }, "credit": { "extracted_string_or_numeric_value": 640.13, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [620, 630] } } },
        { "date": { "extracted_string_or_numeric_value": "07/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [631, 641] } }, "description": { "extracted_string_or_numeric_value": "AC-Allstate Ind Co-CHECKPAYMT CK-00003288", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [631, 651] } }, "debit": { "extracted_string_or_numeric_value": 554.70, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [631, 641] } } },
        { "date": { "extracted_string_or_numeric_value": "07/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [652, 662] } }, "description": { "extracted_string_or_numeric_value": "AC-Allstate Ins Co -CHECKPAYMT CK-00003287", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [652, 672] } }, "debit": { "extracted_string_or_numeric_value": 927.84, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 600], "vertical_y_vertices": [652, 662] } } },
        { "date": { "extracted_string_or_numeric_value": "07/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [673, 683] } }, "description": { "extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [673, 683] } }, "credit": { "extracted_string_or_numeric_value": 1.84, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [673, 683] } } },
        { "date": { "extracted_string_or_numeric_value": "07/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [684, 694] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 400], "vertical_y_vertices": [684, 694] } }, "credit": { "extracted_string_or_numeric_value": 67.57, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [684, 694] } } }
      ],
      "daily_balances": [
        { "date": { "extracted_string_or_numeric_value": "06/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [710, 720] } }, "balance": { "extracted_string_or_numeric_value": 17481.68, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 220], "vertical_y_vertices": [710, 720] } } },
        { "date": { "extracted_string_or_numeric_value": "06/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [230, 260], "vertical_y_vertices": [710, 720] } }, "balance": { "extracted_string_or_numeric_value": 17434.02, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 330], "vertical_y_vertices": [710, 720] } } },
        { "date": { "extracted_string_or_numeric_value": "06/19", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [710, 720] } }, "balance": { "extracted_string_or_numeric_value": 9920.43, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 550], "vertical_y_vertices": [710, 720] } } },
        { "date": { "extracted_string_or_numeric_value": "06/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 700], "vertical_y_vertices": [710, 720] } }, "balance": { "extracted_string_or_numeric_value": 13420.43, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [710, 770], "vertical_y_vertices": [710, 720] } } },
        { "date": { "extracted_string_or_numeric_value": "06/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [721, 731] } }, "balance": { "extracted_string_or_numeric_value": 11906.10, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 220], "vertical_y_vertices": [721, 731] } } },
        { "date": { "extracted_string_or_numeric_value": "06/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [230, 260], "vertical_y_vertices": [721, 731] } }, "balance": { "extracted_string_or_numeric_value": 1800.38, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 330], "vertical_y_vertices": [721, 731] } } },
        { "date": { "extracted_string_or_numeric_value": "06/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [721, 731] } }, "balance": { "extracted_string_or_numeric_value": 1775.38, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 550], "vertical_y_vertices": [721, 731] } } },
        { "date": { "extracted_string_or_numeric_value": "06/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 700], "vertical_y_vertices": [721, 731] } }, "balance": { "extracted_string_or_numeric_value": 1675.38, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [710, 770], "vertical_y_vertices": [721, 731] } } },
        { "date": { "extracted_string_or_numeric_value": "07/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [123, 150], "vertical_y_vertices": [732, 742] } }, "balance": { "extracted_string_or_numeric_value": 11943.29, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 220], "vertical_y_vertices": [732, 742] } } },
        { "date": { "extracted_string_or_numeric_value": "07/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [230, 260], "vertical_y_vertices": [732, 742] } }, "balance": { "extracted_string_or_numeric_value": 12678.91, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 330], "vertical_y_vertices": [732, 742] } } },
        { "date": { "extracted_string_or_numeric_value": "07/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [732, 742] } }, "balance": { "extracted_string_or_numeric_value": 11490.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 550], "vertical_y_vertices": [732, 742] } } },
        { "date": { "extracted_string_or_numeric_value": "07/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 700], "vertical_y_vertices": [732, 742] } }, "balance": { "extracted_string_or_numeric_value": 11559.41, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [710, 770], "vertical_y_vertices": [732, 742] } } }
      ],
      "interest_and_fee_summary": {
        "payer_federal_id_number": { "extracted_string_or_numeric_value": "38-0415896", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 700], "vertical_y_vertices": [750, 760] } },
        "interest_paid_ytd": { "extracted_string_or_numeric_value": 12.72, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [761, 771] } },
        "statement_overdraft_charges": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [772, 782] } },
        "statement_returned_item_charges": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [783, 793] } },
        "ytd_overdraft_charges": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [794, 804] } },
        "ytd_returned_item_charges": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [805, 815] } }
      }
    }
  }
]
```