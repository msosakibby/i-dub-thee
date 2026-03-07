An expert forensic data architect, I have meticulously analyzed the provided document, a variant of the '000117' class. My analysis reveals a consistent, albeit complex, structure comprising a header, a list of line items with some column variability, and a detailed financial summary including totals and payment breakdowns.

To ensure maximum resilience and data integrity, the following Pydantic V2 schema has been designed. It accommodates the observed structural variations in the line items by defining certain fields as `Optional`. Furthermore, it incorporates a rigorous GAAP-compliant mathematical validator to perform double-entry checksums on all financial data, guaranteeing the internal consistency of every extracted record.

### BLOCK 1: Python Pydantic V2 Schema

```python
from __future__ import annotations
import math
from decimal import Decimal, InvalidOperation
from typing import List, Union, Optional

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    model_validator,
    ValidationError,
)

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of a detected entity on a document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class LineItem(BaseModel):
    """Represents a single line item on the invoice."""
    model_config = ConfigDict(extra='forbid')
    line_number: ForensicDataEntity
    code1: Optional[ForensicDataEntity] = None
    code2: ForensicDataEntity
    description: ForensicDataEntity
    quantity: ForensicDataEntity
    unit_price: ForensicDataEntity
    total_price: ForensicDataEntity

class Invoice000117(BaseModel):
    """
    A resilient Pydantic V2 schema for invoice document class '000117'.
    This schema accommodates structural variations and enforces financial integrity.
    """
    model_config = ConfigDict(extra='forbid')

    invoice_history_record: ForensicDataEntity
    invoice_date: ForensicDataEntity
    invoice_no: ForensicDataEntity
    optician: ForensicDataEntity
    trans_type: ForensicDataEntity
    doctor: ForensicDataEntity
    market_code: ForensicDataEntity
    disc_plan: ForensicDataEntity
    line_items: List[LineItem]
    taxable: ForensicDataEntity
    non_taxable: ForensicDataEntity
    sales_tax: ForensicDataEntity
    total: ForensicDataEntity
    cash: ForensicDataEntity
    check: ForensicDataEntity
    cr_card: ForensicDataEntity
    third_party: ForensicDataEntity
    mgr_credit: ForensicDataEntity
    payment_total: ForensicDataEntity
    balance_due: ForensicDataEntity

    @model_validator(mode='after')
    def gaap_double_entry_checksum(self) -> 'Invoice000117':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        - Validates that each line item's total is correct (qty * unit_price).
        - Validates that the sum of line item totals equals the sum of taxable and non-taxable amounts.
        - Validates that the grand total equals the sum of subtotals and sales tax.
        - Validates that the payment total equals the sum of all payment methods.
        - Validates that the balance due is the difference between the grand total and payment total.
        """
        
        def to_decimal(entity: ForensicDataEntity) -> Decimal:
            try:
                return Decimal(str(entity.extracted_string_or_numeric_value))
            except (InvalidOperation, TypeError):
                raise ValueError(f"Invalid numeric value for checksum: {entity.extracted_string_or_numeric_value}")

        # Check 1: Line Item Calculations
        calculated_line_items_total = Decimal('0.0')
        for item in self.line_items:
            quantity = to_decimal(item.quantity)
            unit_price = to_decimal(item.unit_price)
            line_total = to_decimal(item.total_price)

            if not math.isclose(quantity * unit_price, line_total, rel_tol=1e-4):
                raise ValueError(
                    f"Line item {item.line_number.extracted_string_or_numeric_value} total mismatch: "
                    f"qty({quantity}) * unit_price({unit_price}) = {quantity * unit_price}, "
                    f"but found total_price({line_total})."
                )
            calculated_line_items_total += line_total

        # Check 2: Subtotal vs Line Items
        taxable = to_decimal(self.taxable)
        non_taxable = to_decimal(self.non_taxable)
        subtotal_from_summary = taxable + non_taxable
        if not math.isclose(calculated_line_items_total, subtotal_from_summary, rel_tol=1e-4):
            raise ValueError(
                f"Sum of line item totals ({calculated_line_items_total}) does not match "
                f"taxable + non-taxable ({subtotal_from_summary})."
            )

        # Check 3: Grand Total Calculation
        sales_tax = to_decimal(self.sales_tax)
        grand_total = to_decimal(self.total)
        calculated_grand_total = taxable + non_taxable + sales_tax
        if not math.isclose(calculated_grand_total, grand_total, rel_tol=1e-4):
            raise ValueError(
                f"Grand total mismatch: taxable({taxable}) + non_taxable({non_taxable}) + sales_tax({sales_tax}) = "
                f"{calculated_grand_total}, but found total({grand_total})."
            )

        # Check 4: Payment Reconciliation
        cash = to_decimal(self.cash)
        check = to_decimal(self.check)
        cr_card = to_decimal(self.cr_card)
        third_party = to_decimal(self.third_party)
        mgr_credit = to_decimal(self.mgr_credit)
        payment_total = to_decimal(self.payment_total)
        
        calculated_payment_total = cash + check + cr_card + third_party + mgr_credit
        if not math.isclose(calculated_payment_total, payment_total, rel_tol=1e-4):
            raise ValueError(
                f"Payment total mismatch: Sum of payments ({calculated_payment_total}) "
                f"does not match payment_total ({payment_total})."
            )

        # Check 5: Balance Due Calculation
        balance_due = to_decimal(self.balance_due)
        calculated_balance_due = grand_total - payment_total
        if not math.isclose(calculated_balance_due, balance_due, rel_tol=1e-4):
            raise ValueError(
                f"Balance due mismatch: total({grand_total}) - payment_total({payment_total}) = "
                f"{calculated_balance_due}, but found balance_due({balance_due})."
            )

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "invoice-000117-parker-sosa-kibby-210-1126212",
    "should_pass": true,
    "taxonomy_lane": "Invoice000117",
    "binary_header_simulation": "25504446",
    "payload": {
      "invoice_history_record": {
        "extracted_string_or_numeric_value": "210-024845 Parker Sosa-Kibby",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 600], "vertical_y_vertices": [70, 80] }
      },
      "invoice_date": {
        "extracted_string_or_numeric_value": "11/18/13",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 810], "vertical_y_vertices": [70, 80] }
      },
      "invoice_no": {
        "extracted_string_or_numeric_value": "210-1126212",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 250], "vertical_y_vertices": [98, 108] }
      },
      "optician": {
        "extracted_string_or_numeric_value": "140-016050 Gonzalez, Diana",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 650], "vertical_y_vertices": [98, 108] }
      },
      "trans_type": {
        "extracted_string_or_numeric_value": "Invoice",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 200], "vertical_y_vertices": [115, 125] }
      },
      "doctor": {
        "extracted_string_or_numeric_value": "210-016600 Sarrafzadeh, Yoseph",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 700], "vertical_y_vertices": [115, 125] }
      },
      "market_code": {
        "extracted_string_or_numeric_value": "EYEMD",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 200], "vertical_y_vertices": [130, 140] }
      },
      "disc_plan": {
        "extracted_string_or_numeric_value": "LST List Price",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 550], "vertical_y_vertices": [130, 140] }
      },
      "line_items": [
        {
          "line_number": { "extracted_string_or_numeric_value": "001)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 160], "vertical_y_vertices": [170, 180] } },
          "code2": { "extracted_string_or_numeric_value": "92014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 250], "vertical_y_vertices": [170, 180] } },
          "description": { "extracted_string_or_numeric_value": "EXAM COMP. Established", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 550], "vertical_y_vertices": [170, 180] } },
          "quantity": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [170, 180] } },
          "unit_price": { "extracted_string_or_numeric_value": 40.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [170, 180] } },
          "total_price": { "extracted_string_or_numeric_value": 40.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830], "vertical_y_vertices": [170, 180] } }
        },
        {
          "line_number": { "extracted_string_or_numeric_value": "002)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 160], "vertical_y_vertices": [185, 195] } },
          "code1": { "extracted_string_or_numeric_value": "-E1-", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [170, 200], "vertical_y_vertices": [185, 195] } },
          "code2": { "extracted_string_or_numeric_value": "125851314716", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 310], "vertical_y_vertices": [185, 195] } },
          "description": { "extracted_string_or_numeric_value": "NIKE 5513 001(BLACK)47", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 550], "vertical_y_vertices": [185, 195] } },
          "quantity": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [185, 195] } },
          "unit_price": { "extracted_string_or_numeric_value": 97.70, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [185, 195] } },
          "total_price": { "extracted_string_or_numeric_value": 97.70, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830], "vertical_y_vertices": [185, 195] } }
        },
        {
          "line_number": { "extracted_string_or_numeric_value": "003)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 160], "vertical_y_vertices": [200, 210] } },
          "code1": { "extracted_string_or_numeric_value": "-E1-", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [170, 200], "vertical_y_vertices": [200, 210] } },
          "code2": { "extracted_string_or_numeric_value": "21130000", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 280], "vertical_y_vertices": [200, 210] } },
          "description": { "extracted_string_or_numeric_value": "SV POLY", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 420], "vertical_y_vertices": [200, 210] } },
          "quantity": { "extracted_string_or_numeric_value": 2, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [200, 210] } },
          "unit_price": { "extracted_string_or_numeric_value": 37.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [200, 210] } },
          "total_price": { "extracted_string_or_numeric_value": 75.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830], "vertical_y_vertices": [200, 210] } }
        },
        {
          "line_number": { "extracted_string_or_numeric_value": "004)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 160], "vertical_y_vertices": [215, 225] } },
          "code2": { "extracted_string_or_numeric_value": "PLATINUM PLAN", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 320], "vertical_y_vertices": [215, 225] } },
          "description": { "extracted_string_or_numeric_value": "Platinum Protection Plan", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 550], "vertical_y_vertices": [215, 225] } },
          "quantity": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [215, 225] } },
          "unit_price": { "extracted_string_or_numeric_value": 29.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [215, 225] } },
          "total_price": { "extracted_string_or_numeric_value": 29.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830], "vertical_y_vertices": [215, 225] } }
        },
        {
          "line_number": { "extracted_string_or_numeric_value": "005)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 160], "vertical_y_vertices": [230, 240] } },
          "code2": { "extracted_string_or_numeric_value": "569412345674", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 310], "vertical_y_vertices": [230, 240] } },
          "description": { "extracted_string_or_numeric_value": "8 OZ. ALL PURPOSE LENS CLEANER", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 600], "vertical_y_vertices": [230, 240] } },
          "quantity": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [230, 240] } },
          "unit_price": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [230, 240] } },
          "total_price": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 830], "vertical_y_vertices": [230, 240] } }
        }
      ],
      "taxable": { "extracted_string_or_numeric_value": 29.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 250], "vertical_y_vertices": [680, 690] } },
      "non_taxable": { "extracted_string_or_numeric_value": 212.70, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 250], "vertical_y_vertices": [695, 705] } },
      "sales_tax": { "extracted_string_or_numeric_value": 1.60, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 250], "vertical_y_vertices": [710, 720] } },
      "total": { "extracted_string_or_numeric_value": 243.30, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 250], "vertical_y_vertices": [740, 750] } },
      "cash": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [680, 690] } },
      "check": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [695, 705] } },
      "cr_card": { "extracted_string_or_numeric_value": 65.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [710, 720] } },
      "third_party": { "extracted_string_or_numeric_value": 177.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [725, 735] } },
      "mgr_credit": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [680, 690] } },
      "payment_total": { "extracted_string_or_numeric_value": 243.30, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [755, 765] } },
      "balance_due": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [770, 780] } }
    }
  }
]
```