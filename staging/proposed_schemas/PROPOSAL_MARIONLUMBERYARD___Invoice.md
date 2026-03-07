An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document fragments. The extreme degradation of the source material necessitates a schema design that prioritizes resilience and optionality. While the OCR data is largely indecipherable, the document class `MARIONLUMBERYARD - Invoice` implies a standard invoice structure.

My approach is to define a schema that represents a complete, ideal invoice from this vendor, but with every field designated as optional. This ensures that the schema can gracefully handle both high-quality scans and worst-case scenarios like the one provided, where most data points are absent. The GAAP-compliant mathematical validator is designed to execute only when the requisite numerical fields (subtotal, total, tax, line item amounts) are present and correctly typed, preventing errors on incomplete data.

The accompanying JSON test case represents a "golden record" or the most complex structural variant this schema can handle—a fully populated invoice. This allows for robust testing of the schema's capabilities, including the successful execution of the financial checksums, which is impossible with the provided degraded document alone.

### BLOCK 1 (Python Pydantic V2):
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

class MarionLumberyardInvoiceLineItem(BaseModel):
    """Represents a single line item on the invoice."""
    model_config = ConfigDict(extra='forbid')
    
    quantity: Optional[ForensicDataEntity] = None
    description: Optional[ForensicDataEntity] = None
    unit_price: Optional[ForensicDataEntity] = None
    amount: Optional[ForensicDataEntity] = None

class MarionLumberyardInvoice(BaseModel):
    """
    A resilient schema for MARIONLUMBERYARD - Invoice documents,
    designed to handle significant structural drift and data degradation.
    """
    model_config = ConfigDict(extra='forbid')

    vendor_name: Optional[ForensicDataEntity] = None
    customer_name: Optional[ForensicDataEntity] = None
    customer_address: Optional[ForensicDataEntity] = None
    invoice_number: Optional[ForensicDataEntity] = None
    invoice_date: Optional[ForensicDataEntity] = None
    po_number: Optional[ForensicDataEntity] = None
    
    line_items: Optional[List[MarionLumberyardInvoiceLineItem]] = None
    
    subtotal: Optional[ForensicDataEntity] = None
    tax: Optional[ForensicDataEntity] = None
    total: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def gaap_compliance_check(self) -> 'MarionLumberyardInvoice':
        """
        Performs double-entry GAAP mathematical checksums if financial data is present.
        1. Verifies that the sum of line item amounts equals the subtotal.
        2. Verifies that subtotal + tax equals the total.
        """
        # Check 1: Sum of line item amounts vs. Subtotal
        if self.line_items and self.subtotal:
            subtotal_val = self.subtotal.extracted_string_or_numeric_value
            if isinstance(subtotal_val, (int, float)):
                calculated_subtotal = sum(
                    item.amount.extracted_string_or_numeric_value
                    for item in self.line_items
                    if item.amount and isinstance(item.amount.extracted_string_or_numeric_value, (int, float))
                )
                if not math.isclose(calculated_subtotal, subtotal_val, rel_tol=0.01):
                    raise ValueError(f"Subtotal {subtotal_val} does not match sum of line item amounts {calculated_subtotal}.")

        # Check 2: Subtotal + Tax vs. Total
        if self.subtotal and self.tax and self.total:
            subtotal_val = self.subtotal.extracted_string_or_numeric_value
            tax_val = self.tax.extracted_string_or_numeric_value
            total_val = self.total.extracted_string_or_numeric_value

            if all(isinstance(v, (int, float)) for v in [subtotal_val, tax_val, total_val]):
                if not math.isclose(subtotal_val + tax_val, total_val, rel_tol=0.01):
                    raise ValueError(f"Total {total_val} does not match Subtotal {subtotal_val} + Tax {tax_val}.")
        
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "golden-record-marion-lumberyard-full-invoice",
    "should_pass": true,
    "taxonomy_lane": "MarionLumberyardInvoice",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor_name": {
        "extracted_string_or_numeric_value": "MARION LUMBER YARD",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 400],
          "vertical_y_vertices": [50, 80]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "John Doe Construction",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300],
          "vertical_y_vertices": [150, 165]
        }
      },
      "customer_address": {
        "extracted_string_or_numeric_value": "123 Builder Lane, Marion, IN 46952",
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 350],
          "vertical_y_vertices": [166, 180]
        }
      },
      "invoice_number": {
        "extracted_string_or_numeric_value": "INV-1234",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [600, 700],
          "vertical_y_vertices": [120, 135]
        }
      },
      "invoice_date": {
        "extracted_string_or_numeric_value": "2023-10-26",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [600, 700],
          "vertical_y_vertices": [140, 155]
        }
      },
      "po_number": {
        "extracted_string_or_numeric_value": "PO-5678",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [600, 700],
          "vertical_y_vertices": [160, 175]
        }
      },
      "line_items": [
        {
          "quantity": {
            "extracted_string_or_numeric_value": 10.0,
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [50, 100], "vertical_y_vertices": [300, 315] }
          },
          "description": {
            "extracted_string_or_numeric_value": "2x4x8' Pine Stud",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [110, 400], "vertical_y_vertices": [300, 315] }
          },
          "unit_price": {
            "extracted_string_or_numeric_value": 3.50,
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 580], "vertical_y_vertices": [300, 315] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 35.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 750], "vertical_y_vertices": [300, 315] }
          }
        },
        {
          "quantity": {
            "extracted_string_or_numeric_value": 5.0,
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [50, 100], "vertical_y_vertices": [320, 335] }
          },
          "description": {
            "extracted_string_or_numeric_value": "4x8' Plywood Sheet",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [110, 400], "vertical_y_vertices": [320, 335] }
          },
          "unit_price": {
            "extracted_string_or_numeric_value": 45.00,
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 580], "vertical_y_vertices": [320, 335] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 225.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 750], "vertical_y_vertices": [320, 335] }
          }
        }
      ],
      "subtotal": {
        "extracted_string_or_numeric_value": 260.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [600, 615]
        }
      },
      "tax": {
        "extracted_string_or_numeric_value": 20.80,
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [620, 635]
        }
      },
      "total": {
        "extracted_string_or_numeric_value": 280.80,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [640, 655]
        }
      }
    }
  }
]
```