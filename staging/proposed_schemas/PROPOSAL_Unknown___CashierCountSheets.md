An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document, a "Cashier Count Sheet," which contains multiple identical forms for tallying a cashier's till. The core structure of each form involves listing currency denominations and recording declared amounts, cash sales, and the resulting till balance (loan/till).

My design encapsulates this structure with a top-level `UnknownCashierCountSheets` model containing a list of `CashierCountDetails` objects, one for each form on the page. Each `CashierCountDetails` object includes header information like the cashier and date, a list of `DenominationRow`s for each currency type, and fields for the final totals.

The critical component is the `@model_validator` within `CashierCountDetails`. It enforces double-entry accounting principles through two rigorous checks:
1.  **Columnar Summation:** It verifies that the sum of individual denomination amounts in the 'Declare', 'Cash Sales', and 'Loan/Till' columns correctly matches their respective 'Total' fields at the bottom of the form.
2.  **Cross-Column Integrity:** It confirms the fundamental accounting equation for this process: `Total Declare - Total Cash Sales = Total Loan/Till`.

This dual-validation approach ensures high data integrity and resilience, gracefully handling partially filled forms while enforcing mathematical consistency where data is present. All fields are modeled as optional where appropriate to accommodate variations in document completion.

***

### BLOCK 1 (Python Pydantic V2)
```python
import math
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class DenominationRow(BaseModel):
    """Represents a single row for a currency denomination."""
    model_config = ConfigDict(extra='forbid')
    tender: ForensicDataEntity
    declare: Optional[ForensicDataEntity] = None
    cash_sales: Optional[ForensicDataEntity] = None
    loan_till: Optional[ForensicDataEntity] = None

class CashierCountDetails(BaseModel):
    """Represents a single cashier count form on the sheet."""
    model_config = ConfigDict(extra='forbid')
    cashier: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None
    denominations: List[DenominationRow]
    total_declare: Optional[ForensicDataEntity] = None
    total_cash_sales: Optional[ForensicDataEntity] = None
    total_loan_till: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def double_entry_gaap_checksum(self) -> 'CashierCountDetails':
        """
        Performs double-entry GAAP checksums.
        1. Validates that the sum of each column matches its total.
        2. Validates that Total Declare - Total Cash Sales = Total Loan/Till.
        """
        # Helper to safely extract float values from ForensicDataEntity
        def get_value(entity: Optional[ForensicDataEntity]) -> float:
            if entity and isinstance(entity.extracted_string_or_numeric_value, (int, float)):
                return float(entity.extracted_string_or_numeric_value)
            return 0.0

        # 1. Columnar Summation Validation
        sum_declare = sum(get_value(row.declare) for row in self.denominations)
        sum_cash_sales = sum(get_value(row.cash_sales) for row in self.denominations)
        sum_loan_till = sum(get_value(row.loan_till) for row in self.denominations)

        total_declare_val = get_value(self.total_declare)
        if self.total_declare and not math.isclose(sum_declare, total_declare_val, rel_tol=1e-5):
            raise ValueError(f"Sum of 'declare' column ({sum_declare:.2f}) does not match Total Declare ({total_declare_val:.2f}).")

        total_cash_sales_val = get_value(self.total_cash_sales)
        if self.total_cash_sales and not math.isclose(sum_cash_sales, total_cash_sales_val, rel_tol=1e-5):
            raise ValueError(f"Sum of 'cash_sales' column ({sum_cash_sales:.2f}) does not match Total Cash Sales ({total_cash_sales_val:.2f}).")

        total_loan_till_val = get_value(self.total_loan_till)
        if self.total_loan_till and not math.isclose(sum_loan_till, total_loan_till_val, rel_tol=1e-5):
            raise ValueError(f"Sum of 'loan_till' column ({sum_loan_till:.2f}) does not match Total Loan/Till ({total_loan_till_val:.2f}).")

        # 2. Cross-Column Integrity Check on Totals
        if self.total_declare and self.total_cash_sales and self.total_loan_till:
            calculated_loan_till = total_declare_val - total_cash_sales_val
            if not math.isclose(calculated_loan_till, total_loan_till_val, rel_tol=1e-5):
                raise ValueError(f"Cross-column check failed: Total Declare ({total_declare_val:.2f}) - Total Cash Sales ({total_cash_sales_val:.2f}) = {calculated_loan_till:.2f}, which does not match Total Loan/Till ({total_loan_till_val:.2f}).")

        return self

class UnknownCashierCountSheets(BaseModel):
    """The root model for the entire Cashier Count Sheets document."""
    model_config = ConfigDict(extra='forbid')
    document_title: Optional[ForensicDataEntity] = None
    count_sheets: List[CashierCountDetails]

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "cashier-count-sheet-fully-populated-passing-gaap",
    "should_pass": true,
    "taxonomy_lane": "UnknownCashierCountSheets",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "Cashier Count Sheets",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [350.0, 650.0],
          "vertical_y_vertices": [30.0, 50.0]
        }
      },
      "count_sheets": [
        {
          "cashier": {
            "extracted_string_or_numeric_value": "John Doe",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150.0, 250.0],
              "vertical_y_vertices": [70.0, 85.0]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "2023-10-27",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350.0, 450.0],
              "vertical_y_vertices": [70.0, 85.0]
            }
          },
          "denominations": [
            {
              "tender": { "extracted_string_or_numeric_value": "$0.01", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 0.05, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 0.0, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 0.05, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$0.05", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 0.50, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 0.05, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 0.45, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$0.10", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 1.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 0.50, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 0.50, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$0.25", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 2.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 1.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 1.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            { "tender": { "extracted_string_or_numeric_value": "$0.50", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}},
            {
              "tender": { "extracted_string_or_numeric_value": "$1.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 5.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 2.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 3.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            { "tender": { "extracted_string_or_numeric_value": "$2.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}},
            {
              "tender": { "extracted_string_or_numeric_value": "$5.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 10.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 5.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 5.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$10.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 20.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 0.0, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 20.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$20.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 60.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 40.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 20.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$50.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 50.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 0.0, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            },
            {
              "tender": { "extracted_string_or_numeric_value": "$100.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "declare": { "extracted_string_or_numeric_value": 200.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "cash_sales": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }},
              "loan_till": { "extracted_string_or_numeric_value": 100.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }}
            }
          ],
          "total_declare": {
            "extracted_string_or_numeric_value": 348.55,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }
          },
          "total_cash_sales": {
            "extracted_string_or_numeric_value": 198.55,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }
          },
          "total_loan_till": {
            "extracted_string_or_numeric_value": 150.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [10, 20], "vertical_y_vertices": [10, 20] }
          }
        }
      ]
    }
  }
]
```