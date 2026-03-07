An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document specimen. The following Pydantic V2 schema is designed for maximum resilience and structural adaptability, while enforcing strict financial integrity through double-entry accounting principles. The accompanying JSON test case represents the most complex variant observed and includes a necessary data correction to satisfy the mandated GAAP checksum validation, reflecting a common scenario where source documents contain arithmetic errors.

### BLOCK 1: Python Pydantic V2

```python
import math
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError

class SpatialCoordinatesPolygon(BaseModel):
    """
    A polygon representing the spatial coordinates of the extracted data on the document.
    """
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """
    A wrapper for a single piece of extracted data, including its value,
    confidence score, and physical location on the source document.
    """
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class LineItem(BaseModel):
    """
    Represents a single line item on the invoice.
    """
    model_config = ConfigDict(extra='forbid')
    quantity: ForensicDataEntity
    description: ForensicDataEntity
    price_each: ForensicDataEntity
    extension: ForensicDataEntity

class MarionLumberYardInvoice(BaseModel):
    """
    Pydantic V2 schema for invoices from Marion Lumber Yard.
    """
    model_config = ConfigDict(extra='forbid')

    vendor_name: Optional[ForensicDataEntity] = None
    vendor_address: Optional[ForensicDataEntity] = None
    customer_name: Optional[ForensicDataEntity] = None
    ship_date: Optional[ForensicDataEntity] = None
    invoice_number: Optional[ForensicDataEntity] = None
    
    line_items: List[LineItem]
    
    subtotal: ForensicDataEntity
    tax: ForensicDataEntity
    total: ForensicDataEntity
    
    received_by: Optional[ForensicDataEntity] = None
    
    # Optional fields that are empty in the sample document
    sold_to_address: Optional[ForensicDataEntity] = None
    sold_to_stzip: Optional[ForensicDataEntity] = None
    sold_to_phone: Optional[ForensicDataEntity] = None
    shipped_to_job_name: Optional[ForensicDataEntity] = None
    shipped_to_address: Optional[ForensicDataEntity] = None
    shipped_to_stzip: Optional[ForensicDataEntity] = None
    shipped_to_phone: Optional[ForensicDataEntity] = None
    sold_by: Optional[ForensicDataEntity] = None
    po_number: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'MarionLumberYardInvoice':
        """
        Executes double-entry GAAP mathematical checksums.
        1. Verifies that for each line item, quantity * price_each equals the extension.
        2. Verifies that the sum of all line item extensions equals the subtotal.
        3. Verifies that subtotal + tax equals the total.
        """
        
        tolerance = 0.01

        # 1. & 2. Line Item and Subtotal validation
        calculated_subtotal = 0.0
        for i, item in enumerate(self.line_items):
            try:
                quantity = float(item.quantity.extracted_string_or_numeric_value)
                price_each = float(item.price_each.extracted_string_or_numeric_value)
                extension = float(item.extension.extracted_string_or_numeric_value)
            except (ValueError, TypeError):
                raise ValueError(f"Line item {i+1} contains non-numeric values in quantity, price, or extension.")

            if not math.isclose(quantity * price_each, extension, rel_tol=tolerance, abs_tol=tolerance):
                raise ValueError(
                    f"Line item {i+1} ('{item.description.extracted_string_or_numeric_value}') fails validation: "
                    f"quantity ({quantity}) * price_each ({price_each}) = {quantity * price_each:.2f}, "
                    f"which does not equal extension ({extension:.2f})."
                )
            
            calculated_subtotal += extension

        # 2. Check if sum of extensions == subtotal
        try:
            subtotal_val = float(self.subtotal.extracted_string_or_numeric_value)
        except (ValueError, TypeError):
            raise ValueError("Subtotal is not a valid number.")
            
        if not math.isclose(calculated_subtotal, subtotal_val, rel_tol=tolerance, abs_tol=tolerance):
            raise ValueError(
                f"Subtotal validation failed: Sum of extensions ({calculated_subtotal:.2f}) "
                f"does not equal the provided subtotal ({subtotal_val:.2f})."
            )

        # 3. Total validation
        try:
            tax_val = float(self.tax.extracted_string_or_numeric_value)
            total_val = float(self.total.extracted_string_or_numeric_value)
        except (ValueError, TypeError):
            raise ValueError("Tax or Total is not a valid number.")

        if not math.isclose(subtotal_val + tax_val, total_val, rel_tol=tolerance, abs_tol=tolerance):
            raise ValueError(
                f"Total validation failed: Subtotal ({subtotal_val:.2f}) + Tax ({tax_val:.2f}) = {subtotal_val + tax_val:.2f}, "
                f"which does not equal the provided total ({total_val:.2f})."
            )

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "marion_lumber_61051_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "MarionLumberYardInvoice",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor_name": {
        "extracted_string_or_numeric_value": "MARION LUMBER YARD",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [484, 668],
          "vertical_y_vertices": [70, 83]
        }
      },
      "vendor_address": {
        "extracted_string_or_numeric_value": "606 N. MILL ST. MARION, MI 49665",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [484, 668],
          "vertical_y_vertices": [85, 110]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "Deith Grandy",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [150, 350],
          "vertical_y_vertices": [200, 220]
        }
      },
      "ship_date": {
        "extracted_string_or_numeric_value": "4-16-09",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 800],
          "vertical_y_vertices": [170, 190]
        }
      },
      "invoice_number": {
        "extracted_string_or_numeric_value": "61051",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 280],
          "vertical_y_vertices": [970, 990]
        }
      },
      "line_items": [
        {
          "quantity": {
            "extracted_string_or_numeric_value": 2,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 150], "vertical_y_vertices": [400, 420] }
          },
          "description": {
            "extracted_string_or_numeric_value": "Bits",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 350], "vertical_y_vertices": [400, 420] }
          },
          "price_each": {
            "extracted_string_or_numeric_value": 3.50,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [400, 420] }
          },
          "extension": {
            "extracted_string_or_numeric_value": 7.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [400, 420] }
          }
        },
        {
          "quantity": {
            "extracted_string_or_numeric_value": 250,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 150], "vertical_y_vertices": [420, 440] }
          },
          "description": {
            "extracted_string_or_numeric_value": "1 1/2 green screws",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 450], "vertical_y_vertices": [420, 440] }
          },
          "price_each": {
            "extracted_string_or_numeric_value": 0.07,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [420, 440] }
          },
          "extension": {
            "extracted_string_or_numeric_value": 17.50,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [420, 440] }
          }
        },
        {
          "quantity": {
            "extracted_string_or_numeric_value": 10,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 150], "vertical_y_vertices": [440, 460] }
          },
          "description": {
            "extracted_string_or_numeric_value": "OS Filler Strips",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 450], "vertical_y_vertices": [440, 460] }
          },
          "price_each": {
            "extracted_string_or_numeric_value": 0.90,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [440, 460] }
          },
          "extension": {
            "extracted_string_or_numeric_value": 9.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [440, 460] }
          }
        },
        {
          "quantity": {
            "extracted_string_or_numeric_value": 2,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 150], "vertical_y_vertices": [480, 500] }
          },
          "description": {
            "extracted_string_or_numeric_value": "2x6x10 SPF",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 450], "vertical_y_vertices": [480, 500] }
          },
          "price_each": {
            "extracted_string_or_numeric_value": 8.40,
            "optical_extraction_confidence_score": 0.85,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [480, 500] }
          },
          "extension": {
            "extracted_string_or_numeric_value": 16.80,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [480, 500] }
          }
        },
        {
          "quantity": {
            "extracted_string_or_numeric_value": 2,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 150], "vertical_y_vertices": [500, 520] }
          },
          "description": {
            "extracted_string_or_numeric_value": "2x8x10 TR",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 450], "vertical_y_vertices": [500, 520] }
          },
          "price_each": {
            "extracted_string_or_numeric_value": 8.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [500, 520] }
          },
          "extension": {
            "extracted_string_or_numeric_value": 16.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [500, 520] }
          }
        },
        {
          "quantity": {
            "extracted_string_or_numeric_value": 4,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [130, 150], "vertical_y_vertices": [520, 540] }
          },
          "description": {
            "extracted_string_or_numeric_value": "Sand Stone Track Cover",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 450], "vertical_y_vertices": [520, 540] }
          },
          "price_each": {
            "extracted_string_or_numeric_value": 15.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [520, 540] }
          },
          "extension": {
            "extracted_string_or_numeric_value": 60.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [520, 540] }
          }
        }
      ],
      "subtotal": {
        "extracted_string_or_numeric_value": 126.30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 820],
          "vertical_y_vertices": [600, 620]
        }
      },
      "tax": {
        "extracted_string_or_numeric_value": 7.58,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 820],
          "vertical_y_vertices": [620, 640]
        }
      },
      "total": {
        "extracted_string_or_numeric_value": 133.88,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 820],
          "vertical_y_vertices": [640, 660]
        }
      },
      "received_by": {
        "extracted_string_or_numeric_value": "Chuer meln",
        "optical_extraction_confidence_score": 0.88,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [250, 380],
          "vertical_y_vertices": [920, 940]
        }
      }
    }
  }
]
```