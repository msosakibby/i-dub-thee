An expert forensic data architect, I have analyzed the provided documents, which constitute a credit card receipt and a multi-page service invoice for a single transaction. Despite being presented as separate images, they form a cohesive whole. I have designed a Pydantic V2 schema that models this transaction, including vendor, customer, vehicle, and service details, along with a detailed financial summary and an optional nested payment receipt.

The schema is resilient, marking fields that might not be present on all variations (like the payment receipt or specific line item totals) as `Optional`. The included `@model_validator` performs a rigorous, multi-step GAAP checksum, verifying the mathematical integrity from individual part costs up to the final total, ensuring the data's accuracy and consistency.

The chosen JSON test case represents the complete transaction, incorporating data from all provided documents to serve as a comprehensive "golden record" for testing the schema's capabilities.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError

# DO NOT MODIFY THIS CLASS
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

# DO NOT MODIFY THIS CLASS
class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class PartItem(BaseModel):
    """Represents a single part used in a service line item."""
    model_config = ConfigDict(extra='forbid')
    quantity: ForensicDataEntity
    part_number: ForensicDataEntity
    description: ForensicDataEntity
    total: ForensicDataEntity

class ServiceLineItem(BaseModel):
    """Represents a single service or repair job on the invoice."""
    model_config = ConfigDict(extra='forbid')
    line_id: ForensicDataEntity
    description: ForensicDataEntity
    parts: List[PartItem]
    parts_total: Optional[ForensicDataEntity] = None
    labor_total: Optional[ForensicDataEntity] = None
    line_total: ForensicDataEntity

class PaymentReceipt(BaseModel):
    """Represents details from an attached payment receipt."""
    model_config = ConfigDict(extra='forbid')
    amount: ForensicDataEntity
    date: ForensicDataEntity
    time: ForensicDataEntity
    card_type: ForensicDataEntity
    card_last_four: ForensicDataEntity
    transaction_id: ForensicDataEntity
    approval_code: ForensicDataEntity

class HighpointAutoInvoice(BaseModel):
    """
    A schema for auto repair invoices from Highpoint Auto & Truck.
    It accommodates a detailed breakdown of services, parts, and a final summary,
    as well as an optional attached payment receipt.
    """
    model_config = ConfigDict(extra='forbid')

    vendor_name: ForensicDataEntity
    vendor_address: ForensicDataEntity
    vendor_phone: ForensicDataEntity
    
    customer_name: ForensicDataEntity
    customer_address: ForensicDataEntity
    customer_number: Optional[ForensicDataEntity] = None
    
    invoice_number: ForensicDataEntity
    invoice_date: ForensicDataEntity
    
    vehicle_vin: ForensicDataEntity
    vehicle_make_model: ForensicDataEntity
    vehicle_year: ForensicDataEntity
    mileage_in: ForensicDataEntity
    mileage_out: ForensicDataEntity
    
    service_advisor: ForensicDataEntity
    
    line_items: List[ServiceLineItem]
    
    summary_labor_amount: ForensicDataEntity
    summary_parts_amount: ForensicDataEntity
    summary_gas_oil_lube: Optional[ForensicDataEntity] = None
    summary_sublet_amount: ForensicDataEntity
    summary_misc_charges: ForensicDataEntity
    total_charges: ForensicDataEntity
    sales_tax: ForensicDataEntity
    total_due: ForensicDataEntity
    
    payment_receipt: Optional[PaymentReceipt] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'HighpointAutoInvoice':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        """
        def to_float(entity: Optional[ForensicDataEntity]) -> float:
            if entity is None or not isinstance(entity.extracted_string_or_numeric_value, (int, float)):
                return 0.0
            return float(entity.extracted_string_or_numeric_value)

        # 1. Verify line item totals
        total_labor_from_lines = 0.0
        total_parts_from_lines = 0.0
        for item in self.line_items:
            calculated_parts_sum = sum(to_float(part.total) for part in item.parts)
            
            # If line-specific parts total is given, it must match the sum of its parts
            if item.parts_total:
                if abs(calculated_parts_sum - to_float(item.parts_total)) > 0.01:
                    raise ValueError(f"Line {item.line_id.extracted_string_or_numeric_value} parts total mismatch.")
                total_parts_from_lines += to_float(item.parts_total)
            else: # Fallback if no explicit line parts total
                total_parts_from_lines += calculated_parts_sum

            # Verify line total is sum of its parts and labor
            calculated_line_total = calculated_parts_sum + to_float(item.labor_total)
            if abs(calculated_line_total - to_float(item.line_total)) > 0.01:
                raise ValueError(f"Line {item.line_id.extracted_string_or_numeric_value} total mismatch.")
            
            total_labor_from_lines += to_float(item.labor_total)

        # 2. Verify summary totals against line item aggregations
        if abs(total_parts_from_lines - to_float(self.summary_parts_amount)) > 0.01:
            raise ValueError("Summary parts amount does not match sum of line item parts.")
        
        if abs(total_labor_from_lines - to_float(self.summary_labor_amount)) > 0.01:
            raise ValueError("Summary labor amount does not match sum of line item labor.")

        # 3. Verify total charges (subtotal)
        calculated_subtotal = (to_float(self.summary_labor_amount) +
                               to_float(self.summary_parts_amount) +
                               to_float(self.summary_gas_oil_lube) +
                               to_float(self.summary_sublet_amount) +
                               to_float(self.summary_misc_charges))
        if abs(calculated_subtotal - to_float(self.total_charges)) > 0.01:
            raise ValueError("Total charges (subtotal) mismatch.")

        # 4. Verify final total due
        calculated_final_total = to_float(self.total_charges) + to_float(self.sales_tax)
        if abs(calculated_final_total - to_float(self.total_due)) > 0.01:
            raise ValueError("Total due mismatch.")

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "00316-2018-06-26-full-invoice-and-receipt",
    "should_pass": true,
    "taxonomy_lane": "HighpointAutoInvoice",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor_name": {
        "extracted_string_or_numeric_value": "HIGHPOINT AUTO & TRUCK",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [105, 720],
          "vertical_y_vertices": [100, 120]
        }
      },
      "vendor_address": {
        "extracted_string_or_numeric_value": "7555 S US 131 CADILLAC, MI 49601",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [130, 600],
          "vertical_y_vertices": [125, 165]
        }
      },
      "vendor_phone": {
        "extracted_string_or_numeric_value": "231-775-1222",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [190, 550],
          "vertical_y_vertices": [170, 190]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "KEITH GRANDY",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [125, 250],
          "vertical_y_vertices": [125, 135]
        }
      },
      "customer_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD MARION, MI 49665",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [125, 250],
          "vertical_y_vertices": [140, 160]
        }
      },
      "customer_number": {
        "extracted_string_or_numeric_value": "9421552",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [125, 250],
          "vertical_y_vertices": [50, 60]
        }
      },
      "invoice_number": {
        "extracted_string_or_numeric_value": "207437",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 570],
          "vertical_y_vertices": [50, 65]
        }
      },
      "invoice_date": {
        "extracted_string_or_numeric_value": "26JUN18",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 820],
          "vertical_y_vertices": [230, 240]
        }
      },
      "vehicle_vin": {
        "extracted_string_or_numeric_value": "3GTU2VEC8FG398235",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [460, 600],
          "vertical_y_vertices": [205, 220]
        }
      },
      "vehicle_make_model": {
        "extracted_string_or_numeric_value": "15 GMC SIERRA",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [280, 400],
          "vertical_y_vertices": [205, 220]
        }
      },
      "vehicle_year": {
        "extracted_string_or_numeric_value": "15",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 250],
          "vertical_y_vertices": [205, 220]
        }
      },
      "mileage_in": {
        "extracted_string_or_numeric_value": 54376,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 750],
          "vertical_y_vertices": [205, 220]
        }
      },
      "mileage_out": {
        "extracted_string_or_numeric_value": 54376,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 750],
          "vertical_y_vertices": [205, 220]
        }
      },
      "service_advisor": {
        "extracted_string_or_numeric_value": "97 DAVID PETROVICH",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [480, 650],
          "vertical_y_vertices": [160, 170]
        }
      },
      "line_items": [
        {
          "line_id": {
            "extracted_string_or_numeric_value": "A",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 130],
              "vertical_y_vertices": [300, 310]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "REAR VIEW CAMERA INOP",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [140, 350],
              "vertical_y_vertices": [300, 310]
            }
          },
          "parts": [
            {
              "quantity": {
                "extracted_string_or_numeric_value": 1,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [160, 170],
                  "vertical_y_vertices": [380, 390]
                }
              },
              "part_number": {
                "extracted_string_or_numeric_value": "23306741",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [180, 250],
                  "vertical_y_vertices": [380, 390]
                }
              },
              "description": {
                "extracted_string_or_numeric_value": "CAMERA",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [260, 320],
                  "vertical_y_vertices": [380, 390]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 0.00,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [800, 850],
                  "vertical_y_vertices": [380, 390]
                }
              }
            }
          ],
          "parts_total": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 220],
              "vertical_y_vertices": [470, 480]
            }
          },
          "labor_total": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [250, 310],
              "vertical_y_vertices": [470, 480]
            }
          },
          "line_total": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 850],
              "vertical_y_vertices": [470, 480]
            }
          }
        },
        {
          "line_id": {
            "extracted_string_or_numeric_value": "B",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 130],
              "vertical_y_vertices": [530, 540]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "A/C NOT COOLING FAN RUNS",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [140, 350],
              "vertical_y_vertices": [530, 540]
            }
          },
          "parts": [
            {
              "quantity": {
                "extracted_string_or_numeric_value": 1,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [160, 170],
                  "vertical_y_vertices": [580, 590]
                }
              },
              "part_number": {
                "extracted_string_or_numeric_value": "84496856",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [180, 250],
                  "vertical_y_vertices": [580, 590]
                }
              },
              "description": {
                "extracted_string_or_numeric_value": "(S)CONDENSER",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [260, 350],
                  "vertical_y_vertices": [580, 590]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 195.03,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [800, 850],
                  "vertical_y_vertices": [580, 590]
                }
              }
            },
            {
              "quantity": {
                "extracted_string_or_numeric_value": 1,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [160, 170],
                  "vertical_y_vertices": [595, 605]
                }
              },
              "part_number": {
                "extracted_string_or_numeric_value": "52474373",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [180, 250],
                  "vertical_y_vertices": [595, 605]
                }
              },
              "description": {
                "extracted_string_or_numeric_value": "(S) SEAL",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [260, 350],
                  "vertical_y_vertices": [595, 605]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 7.28,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [800, 850],
                  "vertical_y_vertices": [595, 605]
                }
              }
            },
            {
              "quantity": {
                "extracted_string_or_numeric_value": 1,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [160, 170],
                  "vertical_y_vertices": [610, 620]
                }
              },
              "part_number": {
                "extracted_string_or_numeric_value": "13579649",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [180, 250],
                  "vertical_y_vertices": [610, 620]
                }
              },
              "description": {
                "extracted_string_or_numeric_value": "(S) SEAL",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [260, 350],
                  "vertical_y_vertices": [610, 620]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 17.76,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [800, 850],
                  "vertical_y_vertices": [610, 620]
                }
              }
            },
            {
              "quantity": {
                "extracted_string_or_numeric_value": 2,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [160, 170],
                  "vertical_y_vertices": [625, 635]
                }
              },
              "part_number": {
                "extracted_string_or_numeric_value": "12356150",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [180, 250],
                  "vertical_y_vertices": [625, 635]
                }
              },
              "description": {
                "extracted_string_or_numeric_value": "R134 FREON",
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [260, 350],
                  "vertical_y_vertices": [625, 635]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 30.00,
                "optical_extraction_confidence_score": 1.0,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [800, 850],
                  "vertical_y_vertices": [625, 635]
                }
              }
            }
          ],
          "parts_total": {
            "extracted_string_or_numeric_value": 250.07,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 220],
              "vertical_y_vertices": [660, 670]
            }
          },
          "labor_total": {
            "extracted_string_or_numeric_value": 519.74,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [250, 310],
              "vertical_y_vertices": [660, 670]
            }
          },
          "line_total": {
            "extracted_string_or_numeric_value": 769.81,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 850],
              "vertical_y_vertices": [660, 670]
            }
          }
        }
      ],
      "summary_labor_amount": {
        "extracted_string_or_numeric_value": 519.74,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [800, 810]
        }
      },
      "summary_parts_amount": {
        "extracted_string_or_numeric_value": 250.07,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [815, 825]
        }
      },
      "summary_gas_oil_lube": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [830, 840]
        }
      },
      "summary_sublet_amount": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [845, 855]
        }
      },
      "summary_misc_charges": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [860, 870]
        }
      },
      "total_charges": {
        "extracted_string_or_numeric_value": 769.81,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [875, 885]
        }
      },
      "sales_tax": {
        "extracted_string_or_numeric_value": 15.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [905, 915]
        }
      },
      "total_due": {
        "extracted_string_or_numeric_value": 784.81,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [920, 930]
        }
      },
      "payment_receipt": {
        "amount": {
          "extracted_string_or_numeric_value": 100.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 705],
            "vertical_y_vertices": [610, 635]
          }
        },
        "date": {
          "extracted_string_or_numeric_value": "06/26/18",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [310, 410],
            "vertical_y_vertices": [430, 450]
          }
        },
        "time": {
          "extracted_string_or_numeric_value": "13:52:34",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [620, 710],
            "vertical_y_vertices": [430, 450]
          }
        },
        "card_type": {
          "extracted_string_or_numeric_value": "MASTERCARD",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [310, 460],
            "vertical_y_vertices": [510, 530]
          }
        },
        "card_last_four": {
          "extracted_string_or_numeric_value": "3580",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [310, 500],
            "vertical_y_vertices": [540, 560]
          }
        },
        "transaction_id": {
          "extracted_string_or_numeric_value": "0626MWEW6L4BF",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [310, 570],
            "vertical_y_vertices": [460, 480]
          }
        },
        "approval_code": {
          "extracted_string_or_numeric_value": "07006P",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [310, 500],
            "vertical_y_vertices": [485, 505]
          }
        }
      }
    }
  }
]
```