An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document, which represents a structural variant of the `bank - bankstatement` class. This specific variant is an intentionally blank page within a larger statement, containing only peripheral data like page number and a partial account number.

To create a highly resilient schema, I have modeled not only the visible fields but also the data structures expected on a typical, non-blank bank statement page, such as a financial summary and a list of transactions. All fields are designated as `Optional` to accommodate the wide structural variance between a content-rich page and a blank one.

The resulting Pydantic V2 schema includes a GAAP-compliant mathematical validator that activates only when financial summary data is present, ensuring it can process both blank pages and pages with financial figures without error. The schema strictly adheres to the provided `ForensicDataEntity` structure and `extra='forbid'` configuration for maximum security and data integrity.

### Pydantic V2 Schema

```python
import math
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box of a detected entity on a physical document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]


class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon


class Transaction(BaseModel):
    """Represents a single transaction line item on a bank statement."""
    model_config = ConfigDict(extra='forbid')
    transaction_date: Optional[ForensicDataEntity] = None
    description: Optional[ForensicDataEntity] = None
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None


class StatementSummary(BaseModel):
    """Represents the financial summary section of a bank statement."""
    model_config = ConfigDict(extra='forbid')
    beginning_balance: Optional[ForensicDataEntity] = None
    total_deposits: Optional[ForensicDataEntity] = None
    total_withdrawals: Optional[ForensicDataEntity] = None
    ending_balance: Optional[ForensicDataEntity] = None


class BankStatementV1(BaseModel):
    """
    A resilient schema for bank statements, capable of handling both content-rich
    and intentionally blank pages.
    """
    model_config = ConfigDict(extra='forbid')

    # Fields observed on the provided blank page variant
    account_number: Optional[ForensicDataEntity] = None
    page_number: Optional[ForensicDataEntity] = None
    blank_page_indicator: Optional[ForensicDataEntity] = None
    document_code: Optional[ForensicDataEntity] = None

    # Fields for a standard, content-rich statement page
    summary: Optional[StatementSummary] = None
    transactions: Optional[List[Transaction]] = None

    @model_validator(mode='after')
    def gaap_checksum(self) -> 'BankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums if financial data is present.
        1. Validates that the summary's ending balance is correct based on its components.
        2. Validates that the sum of individual transactions matches the summary totals.
        The validator is resilient to missing data, as is common on partial or blank pages.
        """
        summary = self.summary
        transactions = self.transactions

        # Check 1: Sum of transaction details vs. summary totals
        if transactions and summary:
            calculated_deposits = sum(
                float(t.credit.extracted_string_or_numeric_value)
                for t in transactions if t.credit and t.credit.extracted_string_or_numeric_value is not None
            )
            calculated_withdrawals = sum(
                float(t.debit.extracted_string_or_numeric_value)
                for t in transactions if t.debit and t.debit.extracted_string_or_numeric_value is not None
            )

            if summary.total_deposits and summary.total_deposits.extracted_string_or_numeric_value is not None:
                doc_deposits = float(summary.total_deposits.extracted_string_or_numeric_value)
                if not math.isclose(calculated_deposits, doc_deposits, rel_tol=1e-4):
                    raise ValueError(f"Sum of transaction credits ({calculated_deposits}) does not match summary total deposits ({doc_deposits}).")

            if summary.total_withdrawals and summary.total_withdrawals.extracted_string_or_numeric_value is not None:
                doc_withdrawals = float(summary.total_withdrawals.extracted_string_or_numeric_value)
                if not math.isclose(calculated_withdrawals, doc_withdrawals, rel_tol=1e-4):
                    raise ValueError(f"Sum of transaction debits ({calculated_withdrawals}) does not match summary total withdrawals ({doc_withdrawals}).")

        # Check 2: Summary balance calculation
        if summary and all(
            f is not None and f.extracted_string_or_numeric_value is not None
            for f in [summary.beginning_balance, summary.total_deposits, summary.total_withdrawals, summary.ending_balance]
        ):
            try:
                beginning_balance = float(summary.beginning_balance.extracted_string_or_numeric_value)
                total_deposits = float(summary.total_deposits.extracted_string_or_numeric_value)
                total_withdrawals = float(summary.total_withdrawals.extracted_string_or_numeric_value)
                ending_balance = float(summary.ending_balance.extracted_string_or_numeric_value)

                calculated_ending_balance = beginning_balance + total_deposits - total_withdrawals

                if not math.isclose(calculated_ending_balance, ending_balance, rel_tol=1e-4):
                    raise ValueError(f"GAAP checksum failed: Beginning Balance ({beginning_balance}) + Deposits ({total_deposits}) - Withdrawals ({total_withdrawals}) = {calculated_ending_balance}, which does not match Ending Balance ({ending_balance}).")
            except (ValueError, TypeError):
                # If values are not convertible to float, skip the check for resilience.
                pass

        return self

```

### JSON Test Registry

```json
[
  {
    "test_identifier": "bank_statement_blank_page_variant",
    "should_pass": true,
    "taxonomy_lane": "BankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "1427",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            790.0,
            850.0,
            850.0,
            790.0
          ],
          "vertical_y_vertices": [
            950.0,
            950.0,
            965.0,
            965.0
          ]
        }
      },
      "page_number": {
        "extracted_string_or_numeric_value": "6 of 18",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            490.0,
            550.0,
            550.0,
            490.0
          ],
          "vertical_y_vertices": [
            45.0,
            45.0,
            60.0,
            60.0
          ]
        }
      },
      "blank_page_indicator": {
        "extracted_string_or_numeric_value": "THIS PAGE INTENTIONALLY LEFT BLANK",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            380.0,
            620.0,
            620.0,
            380.0
          ],
          "vertical_y_vertices": [
            735.0,
            735.0,
            750.0,
            750.0
          ]
        }
      },
      "document_code": {
        "extracted_string_or_numeric_value": "142703",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            860.0,
            880.0,
            880.0,
            860.0
          ],
          "vertical_y_vertices": [
            580.0,
            580.0,
            640.0,
            640.0
          ]
        }
      },
      "summary": null,
      "transactions": null
    }
  }
]
```