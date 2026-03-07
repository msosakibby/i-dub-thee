An expert forensic data architect, I have analyzed the provided document, a multi-page bank statement, to design a resilient Pydantic V2 schema. The schema accommodates the document's structure, including a main statement, detailed transaction lists, and an image of a cancelled check. The design anticipates structural variations by making non-essential sections optional and includes a robust, multi-level GAAP-compliant mathematical validator to ensure financial integrity.

### BLOCK 1 (Python Pydantic V2):
```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon for physical evidence coordinates."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for extracted data, including metadata."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class BankInfo(BaseModel):
    """Model for the financial institution's details."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone: ForensicDataEntity

class RecipientInfo(BaseModel):
    """Model for the account holder's details."""
    model_config = ConfigDict(extra='forbid')
    account_holders: List[ForensicDataEntity]
    address: ForensicDataEntity

class StatementSummary(BaseModel):
    """Model for the account summary section."""
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    deposits_and_credits_count: ForensicDataEntity
    deposits_and_credits_total: ForensicDataEntity
    checks_and_debits_count: ForensicDataEntity
    checks_and_debits_total: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    statement_period_days: ForensicDataEntity

class CheckTransaction(BaseModel):
    """Model for a single cleared check transaction."""
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class OtherTransaction(BaseModel):
    """Model for non-check transactions (e.g., deposits, ACH)."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class DailyBalance(BaseModel):
    """Model for the running balance on a specific date."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class CancelledCheckImage(BaseModel):
    """Model for the details from a cancelled check image."""
    model_config = ConfigDict(extra='forbid')
    page_number: ForensicDataEntity
    account_number: ForensicDataEntity
    check_number: ForensicDataEntity
    written_date: ForensicDataEntity
    paid_date: ForensicDataEntity
    payee: ForensicDataEntity
    amount_numeric: ForensicDataEntity
    amount_text: ForensicDataEntity

class ChemicalBankStatementV1(BaseModel):
    """
    Represents a Chemical Bank checking account statement, document class '00236'.
    This schema is designed to be resilient to structural variations over time.
    """
    model_config = ConfigDict(extra='forbid')
    
    bank_info: BankInfo
    recipient_info: RecipientInfo
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    summary: StatementSummary
    check_transactions: List[CheckTransaction] = []
    other_transactions: List[OtherTransaction] = []
    daily_balances: List[DailyBalance] = []
    cancelled_checks: Optional[List[CancelledCheckImage]] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to ensure financial data integrity.
        1. Verifies that the sum of detailed debit transactions equals the summary total.
        2. Verifies that the sum of detailed credit transactions equals the summary total.
        3. Verifies that the opening balance plus credits minus debits equals the closing balance.
        """
        # Check 1: Sum of detailed debits vs. summary debit total
        total_debits_from_details = 0.0
        for check in self.check_transactions:
            total_debits_from_details += float(check.amount.extracted_string_or_numeric_value)
        for transaction in self.other_transactions:
            if transaction.debit:
                total_debits_from_details += float(transaction.debit.extracted_string_or_numeric_value)
        
        summary_debits = float(self.summary.checks_and_debits_total.extracted_string_or_numeric_value)
        if not math.isclose(total_debits_from_details, summary_debits, rel_tol=1e-4):
            raise ValueError(f"Detailed debits sum ({total_debits_from_details:.2f}) does not match summary debits total ({summary_debits:.2f}).")

        # Check 2: Sum of detailed credits vs. summary credit total
        total_credits_from_details = 0.0
        for transaction in self.other_transactions:
            if transaction.credit:
                total_credits_from_details += float(transaction.credit.extracted_string_or_numeric_value)
            
        summary_credits = float(self.summary.deposits_and_credits_total.extracted_string_or_numeric_value)
        if not math.isclose(total_credits_from_details, summary_credits, rel_tol=1e-4):
            raise ValueError(f"Detailed credits sum ({total_credits_from_details:.2f}) does not match summary credits total ({summary_credits:.2f}).")

        # Check 3: Overall balance calculation
        previous_balance = float(self.summary.previous_statement_balance.extracted_string_or_numeric_value)
        current_balance = float(self.summary.current_statement_balance.extracted_string_or_numeric_value)
        
        calculated_balance = previous_balance + summary_credits - summary_debits
        if not math.isclose(calculated_balance, current_balance, rel_tol=1e-4):
            raise ValueError(f"Calculated ending balance ({calculated_balance:.2f}) does not match summary current balance ({current_balance:.2f}).")
            
        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "00236-2014-01-13-chemical-bank-2010277008",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_info": {
        "name": { "extracted_string_or_numeric_value": "CHEMICAL BANK", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [545, 545, 556, 556] } },
        "address": { "extracted_string_or_numeric_value": "101 N ROLAND ST MC BAIN MI 49657", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [560, 560, 580, 580] } },
        "phone": { "extracted_string_or_numeric_value": "231-825-2451", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [600, 600, 610, 610] } }
      },
      "recipient_info": {
        "account_holders": [
          { "extracted_string_or_numeric_value": "JUDITH A GRANDY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [630, 630, 640, 640] } },
          { "extracted_string_or_numeric_value": "MICHAEL J KIBBY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [642, 642, 652, 652] } },
          { "extracted_string_or_numeric_value": "MARK W KIBBY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [654, 654, 664, 664] } }
        ],
        "address": { "extracted_string_or_numeric_value": "3291 18 MILE RD PO BOX 297 MARION MI 49665", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [77, 205, 205, 77], "vertical_y_vertices": [666, 666, 690, 690] } }
      },
      "statement_date": { "extracted_string_or_numeric_value": "01/13/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 850, 850, 790], "vertical_y_vertices": [600, 600, 610, 610] } },
      "account_number": { "extracted_string_or_numeric_value": "2010277008", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 850, 850, 790], "vertical_y_vertices": [620, 620, 630, 630] } },
      "account_type": { "extracted_string_or_numeric_value": "CHECKING ADVANTAGE CHECKING", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [40, 250, 250, 40], "vertical_y_vertices": [740, 740, 750, 750] } },
      "summary": {
        "previous_statement_balance": { "extracted_string_or_numeric_value": 17803.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 870, 870, 800], "vertical_y_vertices": [760, 760, 770, 770] } },
        "deposits_and_credits_count": { "extracted_string_or_numeric_value": 5, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 260, 260, 250], "vertical_y_vertices": [775, 775, 785, 785] } },
        "deposits_and_credits_total": { "extracted_string_or_numeric_value": 12044.44, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 870, 870, 800], "vertical_y_vertices": [775, 775, 785, 785] } },
        "checks_and_debits_count": { "extracted_string_or_numeric_value": 18, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 260, 260, 250], "vertical_y_vertices": [790, 790, 800, 800] } },
        "checks_and_debits_total": { "extracted_string_or_numeric_value": 10513.53, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 870, 870, 800], "vertical_y_vertices": [790, 790, 800, 800] } },
        "current_statement_balance": { "extracted_string_or_numeric_value": 19333.96, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 870, 870, 800], "vertical_y_vertices": [805, 805, 815, 815] } },
        "statement_period_days": { "extracted_string_or_numeric_value": 31, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 520, 520, 500], "vertical_y_vertices": [820, 820, 830, 830] } }
      },
      "check_transactions": [
        { "check_number": { "extracted_string_or_numeric_value": "4705*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "12/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 5500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4708*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "12/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4709", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "12/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 19.95, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4712*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "12/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4713", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "12/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4716*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "01/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4718*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "01/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4722*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "12/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 120.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4723", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "01/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 570.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4725*", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "01/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 46.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "check_number": { "extracted_string_or_numeric_value": "4726", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "date": { "extracted_string_or_numeric_value": "01/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "amount": { "extracted_string_or_numeric_value": 640.66, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } }
      ],
      "other_transactions": [
        { "date": { "extracted_string_or_numeric_value": "12/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-SSA TREAS 310-XXSOC SEC", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "credit": { "extracted_string_or_numeric_value": 631.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "credit": { "extracted_string_or_numeric_value": 1200.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-VERIZON WIRELESS-PAYMENT CHECK#-4721", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 92.40, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-AT&T SERVICES-CHECKPAYMT CHECK#-4714", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 188.94, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-CAPITAL ONE ARC-CHECK PYMT CHECK#-4720", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 272.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-BARCLAY CARD US-CREDITCARD CHECK#-4719", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 1349.86, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-SPARTAN STORES-ACCTSPYBLE", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "credit": { "extracted_string_or_numeric_value": 8712.78, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "DEPOSIT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "credit": { "extracted_string_or_numeric_value": 1500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "DEBIT MEMO", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "AC-MEIJER MC-CHECK PYMT CHECK#-4724", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 313.72, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "XFR CKG X008 TO CKG X232#4140", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "debit": { "extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "description": { "extracted_string_or_numeric_value": "INTEREST PAYMENT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "credit": { "extracted_string_or_numeric_value": 0.66, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } }
      ],
      "daily_balances": [
        { "date": { "extracted_string_or_numeric_value": "12/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 17803.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 12303.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 12253.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 12864.10, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 13864.10, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 11910.90, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "12/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 11790.90, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/02", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 20407.68, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/03", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 21093.96, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/06", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 19283.30, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } },
        { "date": { "extracted_string_or_numeric_value": "01/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } }, "balance": { "extracted_string_or_numeric_value": 19333.96, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 1, 1, 1], "vertical_y_vertices": [1, 1, 1, 1] } } }
      ],
      "cancelled_checks": [
        {
          "page_number": { "extracted_string_or_numeric_value": 4, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [225, 270, 270, 225], "vertical_y_vertices": [25, 25, 35, 35] } },
          "account_number": { "extracted_string_or_numeric_value": "2010277008", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [188, 400, 400, 188], "vertical_y_vertices": [55, 55, 65, 65] } },
          "check_number": { "extracted_string_or_numeric_value": "4710", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [205, 250, 250, 205], "vertical_y_vertices": [285, 285, 295, 295] } },
          "written_date": { "extracted_string_or_numeric_value": "10-15-13", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 430, 430, 380], "vertical_y_vertices": [170, 170, 180, 180] } },
          "paid_date": { "extracted_string_or_numeric_value": "12/12/2013", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [315, 370, 370, 315], "vertical_y_vertices": [285, 285, 295, 295] } },
          "payee": { "extracted_string_or_numeric_value": "Alec Postal Service", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 370, 370, 220], "vertical_y_vertices": [190, 190, 205, 205] } },
          "amount_numeric": { "extracted_string_or_numeric_value": 45.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450, 450, 400], "vertical_y_vertices": [190, 190, 205, 205] } },
          "amount_text": { "extracted_string_or_numeric_value": "Forty five and 00/100", "optical_extraction_confidence_score": 0.90, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 350, 350, 180], "vertical_y_vertices": [210, 210, 225, 225] } }
        }
      ]
    }
  }
]
```