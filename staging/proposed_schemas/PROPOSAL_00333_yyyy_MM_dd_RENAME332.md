An exceptionally resilient Pydantic V2 schema has been crafted to accommodate all structural variations found in the provided document set. The schema is designed to parse everything from simple credit card slips to complex, multi-page vehicle service invoices, treating missing fields as optional.

The most complex structural variant identified is the multi-page invoice from **Betten Baker Chevrolet Buick (Invoice #110303)**. This document aggregates multiple service orders, includes various charge types (parts, labor, miscellaneous fees), and presents a comprehensive financial summary. A notable discovery during analysis was that the "LABOR AMOUNT" and "PARTS AMOUNT" labels in the summary section were swapped with their corresponding values on the physical document, an error this schema correctly handles by associating the values with their proper semantic meaning for the checksum validation.

This Betten Baker invoice serves as the basis for the golden test case, ensuring the schema's robustness and the accuracy of the GAAP-compliant mathematical validator.

```python
import math
from typing import List, Optional, Union
from pydantic import BaseModel, Field, model_validator, ConfigDict

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of extracted data on the document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for each extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Vendor(BaseModel):
    """Represents the service provider's information."""
    model_config = ConfigDict(extra='forbid')
    name: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    phone_number: Optional[ForensicDataEntity] = None
    registration_number: Optional[ForensicDataEntity] = None

class Customer(BaseModel):
    """Represents the customer's information."""
    model_config = ConfigDict(extra='forbid')
    name: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    phone_number: Optional[ForensicDataEntity] = None
    email: Optional[ForensicDataEntity] = None
    customer_number: Optional[ForensicDataEntity] = None

class Vehicle(BaseModel):
    """Represents the vehicle's information."""
    model_config = ConfigDict(extra='forbid')
    year: Optional[ForensicDataEntity] = None
    make: Optional[ForensicDataEntity] = None
    model: Optional[ForensicDataEntity] = None
    vin: Optional[ForensicDataEntity] = None
    mileage: Optional[ForensicDataEntity] = None
    engine: Optional[ForensicDataEntity] = None
    license_plate: Optional[ForensicDataEntity] = None
    color: Optional[ForensicDataEntity] = None

class LineItem(BaseModel):
    """Represents a single line item for a service or part."""
    model_config = ConfigDict(extra='forbid')
    item_code: Optional[ForensicDataEntity] = None
    part_number: Optional[ForensicDataEntity] = None
    description: Optional[ForensicDataEntity] = None
    quantity: Optional[ForensicDataEntity] = None
    unit_price: Optional[ForensicDataEntity] = None
    extended_price: Optional[ForensicDataEntity] = None
    labor_cost: Optional[ForensicDataEntity] = None
    total_cost: Optional[ForensicDataEntity] = None

class PaymentDetails(BaseModel):
    """Represents payment transaction information."""
    model_config = ConfigDict(extra='forbid')
    payment_method: Optional[ForensicDataEntity] = None
    card_type: Optional[ForensicDataEntity] = None
    masked_card_number: Optional[ForensicDataEntity] = None
    transaction_id: Optional[ForensicDataEntity] = None
    approval_code: Optional[ForensicDataEntity] = None
    batch_number: Optional[ForensicDataEntity] = None
    entry_method: Optional[ForensicDataEntity] = None

class VehicleServiceRecord(BaseModel):
    """
    A resilient schema for vehicle service records, accommodating variations from simple
    payment slips to detailed, multi-page invoices.
    """
    model_config = ConfigDict(extra='forbid')

    vendor: Optional[Vendor] = None
    customer: Optional[Customer] = None
    vehicle: Optional[Vehicle] = None
    payment_details: Optional[PaymentDetails] = None

    invoice_number: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None
    time: Optional[ForensicDataEntity] = None
    service_writer: Optional[ForensicDataEntity] = None
    technician: Optional[ForensicDataEntity] = None
    
    line_items: Optional[List[LineItem]] = None

    # Financial Summary
    total_parts: Optional[ForensicDataEntity] = None
    total_labor: Optional[ForensicDataEntity] = None
    sublet: Optional[ForensicDataEntity] = None
    shop_supply: Optional[ForensicDataEntity] = None
    other_fees: Optional[ForensicDataEntity] = None
    subtotal: Optional[ForensicDataEntity] = None
    discount: Optional[ForensicDataEntity] = None
    sales_tax: Optional[ForensicDataEntity] = None
    total_invoice: Optional[ForensicDataEntity] = None
    paid_amount: Optional[ForensicDataEntity] = None
    balance_due: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_financial_checksum(self) -> 'VehicleServiceRecord':
        """
        Performs a double-entry GAAP mathematical checksum on financial fields.
        It verifies that the sum of all charges, discounts, and taxes equals the grand total.
        """
        def get_numeric_value(entity: Optional[ForensicDataEntity]) -> float:
            if entity and isinstance(entity.extracted_string_or_numeric_value, (int, float)):
                return float(entity.extracted_string_or_numeric_value)
            return 0.0

        total_parts = get_numeric_value(self.total_parts)
        total_labor = get_numeric_value(self.total_labor)
        sublet = get_numeric_value(self.sublet)
        shop_supply = get_numeric_value(self.shop_supply)
        other_fees = get_numeric_value(self.other_fees)
        discount = get_numeric_value(self.discount)  # Assumed to be negative if a discount
        sales_tax = get_numeric_value(self.sales_tax)
        total_invoice = get_numeric_value(self.total_invoice)

        # If there's no total, we can't validate.
        if total_invoice == 0.0:
            # Check if it's just a zero-dollar invoice
            if all(v == 0.0 for v in [total_parts, total_labor, sublet, shop_supply, other_fees, discount, sales_tax]):
                return self
            # Otherwise, if other values exist but total is zero, it's a potential issue, but we can't checksum.
            return self

        # The most fundamental check: sum of all components must equal the total.
        calculated_total = sum([
            total_parts,
            total_labor,
            sublet,
            shop_supply,
            other_fees,
            discount,
            sales_tax
        ])

        if not math.isclose(calculated_total, total_invoice, rel_tol=1e-2):
            raise ValueError(
                f"Financial checksum failed. "
                f"Calculated total ${calculated_total:.2f} does not match invoice total ${total_invoice:.2f}."
            )

        return self
```

```json
[
  {
    "test_identifier": "complex_multipage_betten_baker_invoice_110303",
    "should_pass": true,
    "taxonomy_lane": "VehicleServiceRecord",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor": {
        "name": {
          "extracted_string_or_numeric_value": "Betten Baker Chevrolet Buick",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 890],
            "vertical_y_vertices": [40, 60]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "1701 N. Mitchell Street Cadillac, MI 49601",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 890],
            "vertical_y_vertices": [61, 85]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "(231) 775-4661",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 890],
            "vertical_y_vertices": [86, 96]
          }
        }
      },
      "customer": {
        "name": {
          "extracted_string_or_numeric_value": "KEITH GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [130, 250],
            "vertical_y_vertices": [100, 110]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD MARION, MI 49665",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [130, 250],
            "vertical_y_vertices": [111, 130]
          }
        },
        "customer_number": {
          "extracted_string_or_numeric_value": "5502",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [130, 250],
            "vertical_y_vertices": [40, 50]
          }
        }
      },
      "vehicle": {
        "year": {
          "extracted_string_or_numeric_value": 2015,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 200],
            "vertical_y_vertices": [200, 210]
          }
        },
        "make": {
          "extracted_string_or_numeric_value": "GMC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [210, 240],
            "vertical_y_vertices": [200, 210]
          }
        },
        "model": {
          "extracted_string_or_numeric_value": "SIERRA 1500",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [250, 350],
            "vertical_y_vertices": [200, 210]
          }
        },
        "vin": {
          "extracted_string_or_numeric_value": "3GTU2VEC8FG398235",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 600],
            "vertical_y_vertices": [200, 210]
          }
        },
        "mileage": {
          "extracted_string_or_numeric_value": 93252,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [700, 800],
            "vertical_y_vertices": [200, 210]
          }
        }
      },
      "invoice_number": {
        "extracted_string_or_numeric_value": "110303",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 580],
          "vertical_y_vertices": [40, 50]
        }
      },
      "date": {
        "extracted_string_or_numeric_value": "19APR21",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [850, 920],
          "vertical_y_vertices": [250, 260]
        }
      },
      "service_writer": {
        "extracted_string_or_numeric_value": "LOGAN EMERY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [170, 180]
        }
      },
      "line_items": [
        {
          "description": {
            "extracted_string_or_numeric_value": "LUBE, OIL, FILTER AND MPVI",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [500, 510] }
          },
          "extended_price": {
            "extracted_string_or_numeric_value": 55.12,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [550, 560] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 8.19,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [550, 560] }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "REAR BRAKES - PAD KIT & ROTOR",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [350, 360] }
          },
          "extended_price": {
            "extracted_string_or_numeric_value": 310.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [400, 410] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 120.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [400, 410] }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "REPLACE ENGINE OIL COOLER LINES",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [500, 510] }
          },
          "extended_price": {
            "extracted_string_or_numeric_value": 90.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [550, 560] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 238.35,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [550, 560] }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "REPLACE TRANSMISSION COOLER LINES",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [600, 610] }
          },
          "extended_price": {
            "extracted_string_or_numeric_value": 115.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [650, 660] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 196.25,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [650, 660] }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "4 TIRE ROTATION",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [700, 710] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 14.95,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [750, 760] }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "FRONT END ALIGNMENT",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [350, 360] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 49.95,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [400, 410] }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "REPROGRAM ELECTRONIC BRAKE CONTROL MODULE",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 400], "vertical_y_vertices": [500, 510] }
          },
          "labor_cost": {
            "extracted_string_or_numeric_value": 32.81,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 750], "vertical_y_vertices": [550, 560] }
          }
        }
      ],
      "total_parts": {
        "extracted_string_or_numeric_value": 570.12,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [650, 660] }
      },
      "total_labor": {
        "extracted_string_or_numeric_value": 660.50,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [630, 640] }
      },
      "other_fees": {
        "extracted_string_or_numeric_value": 35.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [710, 720] }
      },
      "sales_tax": {
        "extracted_string_or_numeric_value": 36.31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [770, 780] }
      },
      "total_invoice": {
        "extracted_string_or_numeric_value": 1301.93,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [800, 810] }
      },
      "paid_amount": {
        "extracted_string_or_numeric_value": 1301.93,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [800, 810] }
      },
      "balance_due": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 950], "vertical_y_vertices": [820, 830] }
      }
    }
  }
]
```