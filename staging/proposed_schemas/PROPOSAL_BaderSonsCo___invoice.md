An expert forensic data architect, I have analyzed the provided document, a service invoice from Bader & Sons Co., to design a resilient Pydantic V2 schema. This schema accounts for the document's specific structure, including nested customer information, detailed service and equipment sections, itemized parts, and a multi-layered financial summary.

The design incorporates a robust mathematical validator that performs double-entry GAAP checksums, verifying the consistency of all financial calculations from individual line items up to the grand total. This ensures data integrity and accuracy. The schema is built to be flexible, with optional fields to accommodate potential variations in future invoices, adhering to the principle of preparing for structural drift even when analyzing a single document.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union
from pydantic import BaseModel, Field, ConfigDict, model_validator
import decimal

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AddressInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: Optional[ForensicDataEntity] = None
    owner: Optional[ForensicDataEntity] = None
    address_line_1: Optional[ForensicDataEntity] = None
    address_line_2: Optional[ForensicDataEntity] = None
    city_state_zip: Optional[ForensicDataEntity] = None
    business_phone: Optional[ForensicDataEntity] = None
    private_phone: Optional[ForensicDataEntity] = None

class EquipmentInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    make_model: Optional[ForensicDataEntity] = None
    meter_reading: Optional[ForensicDataEntity] = None
    serial_number: Optional[ForensicDataEntity] = None
    equipment_number: Optional[ForensicDataEntity] = None

class ServiceDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    complaint: Optional[ForensicDataEntity] = None
    cause: Optional[ForensicDataEntity] = None
    correction: Optional[ForensicDataEntity] = None

class InvoiceLineItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    part_number: Optional[ForensicDataEntity] = None
    description: ForensicDataEntity
    quantity: ForensicDataEntity
    unit_net_price: ForensicDataEntity
    value: ForensicDataEntity

class MiscellaneousCharge(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    amount: ForensicDataEntity

class BaderSonsCoInvoice(BaseModel):
    model_config = ConfigDict(extra='forbid')

    vendor_name: Optional[ForensicDataEntity] = None
    vendor_address: Optional[ForensicDataEntity] = None
    vendor_phone: Optional[ForensicDataEntity] = None
    vendor_website: Optional[ForensicDataEntity] = None

    invoice_to: AddressInfo
    deliver_to: Optional[AddressInfo] = None

    invoice_number: ForensicDataEntity
    invoice_date: ForensicDataEntity
    work_order_number: Optional[ForensicDataEntity] = None
    location: Optional[ForensicDataEntity] = None
    payment_type: Optional[ForensicDataEntity] = None
    account_number: Optional[ForensicDataEntity] = None
    advisor: Optional[ForensicDataEntity] = None
    customer_po_number: Optional[ForensicDataEntity] = None

    equipment_info: Optional[EquipmentInfo] = None
    service_details: Optional[ServiceDetails] = None

    line_items: Optional[List[InvoiceLineItem]] = None
    misc_charges: Optional[List[MiscellaneousCharge]] = None

    labor_subtotal: Optional[ForensicDataEntity] = None
    parts_subtotal: Optional[ForensicDataEntity] = None
    ol_and_m_subtotal: Optional[ForensicDataEntity] = None
    sub_total: Optional[ForensicDataEntity] = None
    misc_subtotal: Optional[ForensicDataEntity] = None
    sales_tax: Optional[ForensicDataEntity] = None
    grand_total: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'BaderSonsCoInvoice':
        ctx = decimal.Context(prec=10)

        def get_val(field: Optional[ForensicDataEntity]) -> decimal.Decimal:
            if field is None or not isinstance(field.extracted_string_or_numeric_value, (float, int, str)):
                return decimal.Decimal('0.0')
            try:
                return ctx.create_decimal(str(field.extracted_string_or_numeric_value))
            except (decimal.InvalidOperation, ValueError):
                return decimal.Decimal('0.0')

        # 1. Verify parts subtotal against sum of line items
        calculated_parts_total = decimal.Decimal('0.0')
        if self.line_items:
            for item in self.line_items:
                quantity = get_val(item.quantity)
                unit_price = get_val(item.unit_net_price)
                item_value = get_val(item.value)
                
                if not ctx.is_zero(quantity * unit_price - item_value):
                    raise ValueError(f"Line item '{item.description.extracted_string_or_numeric_value}' value mismatch: {quantity} * {unit_price} != {item_value}")
                
                calculated_parts_total += item_value
        
        declared_parts_subtotal = get_val(self.parts_subtotal)
        if self.parts_subtotal and not ctx.is_zero(calculated_parts_total - declared_parts_subtotal):
            raise ValueError(f"Parts subtotal mismatch: Calculated {calculated_parts_total}, Declared {declared_parts_subtotal}")

        # 2. Verify sub-total
        declared_labor_subtotal = get_val(self.labor_subtotal)
        declared_ol_and_m_subtotal = get_val(self.ol_and_m_subtotal)
        
        calculated_sub_total = declared_labor_subtotal + declared_parts_subtotal + declared_ol_and_m_subtotal
        declared_sub_total = get_val(self.sub_total)
        
        if self.sub_total and not ctx.is_zero(calculated_sub_total - declared_sub_total):
             raise ValueError(f"Sub-total mismatch: Calculated {calculated_sub_total}, Declared {declared_sub_total}")

        # 3. Verify misc charges total
        calculated_misc_total = decimal.Decimal('0.0')
        if self.misc_charges:
            for charge in self.misc_charges:
                calculated_misc_total += get_val(charge.amount)
        
        declared_misc_subtotal = get_val(self.misc_subtotal)
        if self.misc_subtotal and not ctx.is_zero(calculated_misc_total - declared_misc_subtotal):
            raise ValueError(f"Miscellaneous charges total mismatch: Calculated {calculated_misc_total}, Declared {declared_misc_subtotal}")

        # 4. Verify grand total
        declared_sales_tax = get_val(self.sales_tax)
        
        calculated_grand_total = declared_sub_total + declared_misc_subtotal + declared_sales_tax
        declared_grand_total = get_val(self.grand_total)

        if not ctx.is_zero(calculated_grand_total - declared_grand_total):
            raise ValueError(f"Grand total mismatch: Calculated {calculated_grand_total}, Declared {declared_grand_total}")

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "001_bader_sons_invoice_2302",
    "should_pass": true,
    "taxonomy_lane": "BaderSonsCoInvoice",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor_name": {
        "extracted_string_or_numeric_value": "Bader & Sons Co.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [157, 403],
          "vertical_y_vertices": [29, 66]
        }
      },
      "vendor_address": {
        "extracted_string_or_numeric_value": "4363 South Morey Rd. Lake City, MI 49651",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [157, 330],
          "vertical_y_vertices": [69, 98]
        }
      },
      "vendor_phone": {
        "extracted_string_or_numeric_value": "(231) 839-8660",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [157, 260],
          "vertical_y_vertices": [100, 113]
        }
      },
      "vendor_website": {
        "extracted_string_or_numeric_value": "www.GreenTractors.com",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [157, 320],
          "vertical_y_vertices": [142, 155]
        }
      },
      "invoice_to": {
        "name": {
          "extracted_string_or_numeric_value": "KIBBY CO.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 225],
            "vertical_y_vertices": [199, 209]
          }
        },
        "owner": {
          "extracted_string_or_numeric_value": "OWNER JUDY GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 280],
            "vertical_y_vertices": [210, 220]
          }
        },
        "address_line_1": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 260],
            "vertical_y_vertices": [221, 231]
          }
        },
        "address_line_2": {
          "extracted_string_or_numeric_value": "P.O. BOX 297",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 240],
            "vertical_y_vertices": [232, 242]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "MARION MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 265],
            "vertical_y_vertices": [243, 253]
          }
        },
        "business_phone": {
          "extracted_string_or_numeric_value": "231-743-6686",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220, 300],
            "vertical_y_vertices": [272, 282]
          }
        },
        "private_phone": {
          "extracted_string_or_numeric_value": "231-942-1552",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220, 300],
            "vertical_y_vertices": [283, 293]
          }
        }
      },
      "deliver_to": {
        "name": {
          "extracted_string_or_numeric_value": "KIBBY CO.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [375, 442],
            "vertical_y_vertices": [199, 209]
          }
        },
        "address_line_1": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [375, 477],
            "vertical_y_vertices": [221, 231]
          }
        },
        "address_line_2": {
          "extracted_string_or_numeric_value": "P.O. BOX 297",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [375, 457],
            "vertical_y_vertices": [232, 242]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "MARION MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [375, 482],
            "vertical_y_vertices": [243, 253]
          }
        },
        "business_phone": {
          "extracted_string_or_numeric_value": "231-743-6686",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [437, 517],
            "vertical_y_vertices": [272, 282]
          }
        },
        "private_phone": {
          "extracted_string_or_numeric_value": "231-942-1552",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [437, 517],
            "vertical_y_vertices": [283, 293]
          }
        }
      },
      "invoice_number": {
        "extracted_string_or_numeric_value": "2302",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 830],
          "vertical_y_vertices": [199, 209]
        }
      },
      "invoice_date": {
        "extracted_string_or_numeric_value": "3/17/2015",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 860],
          "vertical_y_vertices": [215, 225]
        }
      },
      "work_order_number": {
        "extracted_string_or_numeric_value": "2213",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 830],
          "vertical_y_vertices": [247, 257]
        }
      },
      "location": {
        "extracted_string_or_numeric_value": "09",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 815],
          "vertical_y_vertices": [231, 241]
        }
      },
      "payment_type": {
        "extracted_string_or_numeric_value": "Account",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [263, 273]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "808812",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [270, 320],
          "vertical_y_vertices": [175, 185]
        }
      },
      "advisor": {
        "extracted_string_or_numeric_value": "ZACH WAGNER",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [260, 340],
          "vertical_y_vertices": [700, 710]
        }
      },
      "customer_po_number": null,
      "equipment_info": {
        "make_model": {
          "extracted_string_or_numeric_value": "JOHN DEERE 4320",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [720, 840],
            "vertical_y_vertices": [320, 330]
          }
        },
        "meter_reading": {
          "extracted_string_or_numeric_value": "14450",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [720, 760],
            "vertical_y_vertices": [336, 346]
          }
        },
        "serial_number": {
          "extracted_string_or_numeric_value": "LV4320H320570",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [720, 820],
            "vertical_y_vertices": [352, 362]
          }
        },
        "equipment_number": {
          "extracted_string_or_numeric_value": "154978W",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [720, 780],
            "vertical_y_vertices": [368, 378]
          }
        }
      },
      "service_details": {
        "complaint": {
          "extracted_string_or_numeric_value": "Legacy WO #: 900309 3-Point Hitch will Not drop to the ground",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [160, 580],
            "vertical_y_vertices": [400, 420]
          }
        },
        "cause": {
          "extracted_string_or_numeric_value": "Clip that holds calble came unhooked and allowed cable to move freely instead of operating in the correct direction",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [160, 800],
            "vertical_y_vertices": [430, 455]
          }
        },
        "correction": {
          "extracted_string_or_numeric_value": "Install New Clip and test ops of 3-point hitch Everthing tests good at this time",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [160, 700],
            "vertical_y_vertices": [465, 490]
          }
        }
      },
      "line_items": [
        {
          "part_number": {
            "extracted_string_or_numeric_value": "R112612",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [190, 240],
              "vertical_y_vertices": [550, 560]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "Snap Ring",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 360],
              "vertical_y_vertices": [550, 560]
            }
          },
          "quantity": {
            "extracted_string_or_numeric_value": 1.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 650],
              "vertical_y_vertices": [550, 560]
            }
          },
          "unit_net_price": {
            "extracted_string_or_numeric_value": 1.30,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [680, 710],
              "vertical_y_vertices": [550, 560]
            }
          },
          "value": {
            "extracted_string_or_numeric_value": 1.30,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [740, 770],
              "vertical_y_vertices": [550, 560]
            }
          }
        }
      ],
      "misc_charges": [
        {
          "description": {
            "extracted_string_or_numeric_value": "ENVIRONMENTAL FEES",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 290],
              "vertical_y_vertices": [640, 650]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 3.53,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 830],
              "vertical_y_vertices": [640, 650]
            }
          }
        }
      ],
      "labor_subtotal": {
        "extracted_string_or_numeric_value": 87.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 840],
          "vertical_y_vertices": [510, 520]
        }
      },
      "parts_subtotal": {
        "extracted_string_or_numeric_value": 1.30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 830],
          "vertical_y_vertices": [580, 590]
        }
      },
      "ol_and_m_subtotal": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 480],
          "vertical_y_vertices": [600, 610]
        }
      },
      "sub_total": {
        "extracted_string_or_numeric_value": 88.30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 840],
          "vertical_y_vertices": [600, 610]
        }
      },
      "misc_subtotal": {
        "extracted_string_or_numeric_value": 3.53,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 830],
          "vertical_y_vertices": [705, 715]
        }
      },
      "sales_tax": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 830],
          "vertical_y_vertices": [720, 730]
        }
      },
      "grand_total": {
        "extracted_string_or_numeric_value": 91.83,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 840],
          "vertical_y_vertices": [750, 760]
        }
      }
    }
  }
]
```
