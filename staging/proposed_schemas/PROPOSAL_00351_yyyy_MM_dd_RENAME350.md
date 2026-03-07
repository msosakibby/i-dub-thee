An analysis of the provided documents reveals two distinct but related transaction records from a John Deere dealership, which appears to have changed ownership or name from "Bader & Sons Co." to "Hutson, Inc." over time. The documents are a 2021 Purchase Order and a 2023 Receipt. To fulfill the directive of creating a single, resilient schema that accommodates the structural realities of all documents, the following Pydantic V2 schema, `JohnDeereTransactionRecord`, has been designed.

This schema consolidates fields from both the Purchase Order and the Receipt, typing fields that are not universally present as `Optional`. This approach allows a single parser to handle both document types, treating them as variations within a broader "transaction record" class, thereby accommodating the observed "structural design drift". The schema includes nested models for clarity and a comprehensive `@model_validator` to perform conditional GAAP-compliant checksums for either the purchase order's financial summary or the receipt's payment breakdown, ensuring data integrity.

The JSON test case represents the most complex variant, the Purchase Order, and is structured to pass the validation logic, including the mathematical checksums.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class DealerInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone: ForensicDataEntity
    account_number: Optional[ForensicDataEntity] = None

class PurchaserInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    street: ForensicDataEntity
    town: Optional[ForensicDataEntity] = None
    state: Optional[ForensicDataEntity] = None
    zip_code: Optional[ForensicDataEntity] = None
    full_address_line: Optional[ForensicDataEntity] = None
    account_number: Optional[ForensicDataEntity] = None
    phone: Optional[ForensicDataEntity] = None

class LineItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    quantity: ForensicDataEntity
    description: ForensicDataEntity
    product_id: ForensicDataEntity
    hours: ForensicDataEntity
    price: ForensicDataEntity

class FinancialSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_cash_price: ForensicDataEntity
    total_trade_in_allowance: ForensicDataEntity
    total_trade_in_pay_off: ForensicDataEntity
    balance_before_tax: ForensicDataEntity
    sales_tax_rate: ForensicDataEntity
    sales_tax_amount: ForensicDataEntity
    est_service_agreement: ForensicDataEntity
    sub_total: ForensicDataEntity
    cash_with_order: ForensicDataEntity
    rental_applied: ForensicDataEntity
    cash_discount: ForensicDataEntity
    balance_due: ForensicDataEntity

class CreditCardTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    card_label: ForensicDataEntity
    masked_pan: ForensicDataEntity
    result: ForensicDataEntity
    auth_code: ForensicDataEntity
    amount: ForensicDataEntity

class PaymentDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    reference: ForensicDataEntity
    cash_payment: ForensicDataEntity
    check_payment: ForensicDataEntity
    credit_card_payment: ForensicDataEntity
    finance_payment: ForensicDataEntity
    total_payment: ForensicDataEntity
    credit_card_transactions: Optional[List[CreditCardTransaction]] = None

class JohnDeereTransactionRecord(BaseModel):
    model_config = ConfigDict(extra='forbid')
    dealer: DealerInfo
    purchaser: PurchaserInfo
    document_date: ForensicDataEntity
    po_number: Optional[ForensicDataEntity] = None
    receipt_number: Optional[ForensicDataEntity] = None
    transaction_type: Optional[ForensicDataEntity] = None
    line_items: Optional[List[LineItem]] = None
    financial_summary: Optional[FinancialSummary] = None
    salesperson: Optional[ForensicDataEntity] = None
    comments: Optional[List[ForensicDataEntity]] = None
    payment_details: Optional[PaymentDetails] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'JohnDeereTransactionRecord':
        # --- Purchase Order Validation ---
        if self.financial_summary and self.line_items:
            summary = self.financial_summary
            
            sum_of_lines = sum(float(item.price.extracted_string_or_numeric_value) for item in self.line_items)
            total_cash_price = float(summary.total_cash_price.extracted_string_or_numeric_value)
            if not math.isclose(sum_of_lines, total_cash_price, rel_tol=1e-4):
                raise ValueError(f"PO Checksum Failed: Sum of line items ({sum_of_lines}) != Total Cash Price ({total_cash_price}).")

            balance_before_tax = float(summary.balance_before_tax.extracted_string_or_numeric_value)
            trade_in_allowance = float(summary.total_trade_in_allowance.extracted_string_or_numeric_value)
            calculated_balance = total_cash_price - trade_in_allowance
            if not math.isclose(calculated_balance, balance_before_tax, rel_tol=1e-4):
                raise ValueError(f"PO Checksum Failed: Calculated balance before tax ({calculated_balance}) != Balance ({balance_before_tax}).")

            sales_tax_amount = float(summary.sales_tax_amount.extracted_string_or_numeric_value)
            sales_tax_rate_str = str(summary.sales_tax_rate.extracted_string_or_numeric_value)
            sales_tax_rate = float(sales_tax_rate_str.strip('()').replace('%','')) / 100.0
            calculated_tax = balance_before_tax * sales_tax_rate
            if not math.isclose(calculated_tax, sales_tax_amount, rel_tol=1e-4):
                raise ValueError(f"PO Checksum Failed: Calculated sales tax ({calculated_tax:.2f}) != Sales Tax Amount ({sales_tax_amount}).")

            sub_total = float(summary.sub_total.extracted_string_or_numeric_value)
            service_agreement = float(summary.est_service_agreement.extracted_string_or_numeric_value)
            calculated_sub_total = balance_before_tax + sales_tax_amount + service_agreement
            if not math.isclose(calculated_sub_total, sub_total, rel_tol=1e-4):
                raise ValueError(f"PO Checksum Failed: Calculated sub-total ({calculated_sub_total}) != Sub-Total ({sub_total}).")

            balance_due = float(summary.balance_due.extracted_string_or_numeric_value)
            cash_with_order = float(summary.cash_with_order.extracted_string_or_numeric_value)
            rental_applied = float(summary.rental_applied.extracted_string_or_numeric_value)
            cash_discount = float(summary.cash_discount.extracted_string_or_numeric_value)
            calculated_balance_due = sub_total - cash_with_order - rental_applied - cash_discount
            if not math.isclose(calculated_balance_due, balance_due, rel_tol=1e-4):
                raise ValueError(f"PO Checksum Failed: Calculated balance due ({calculated_balance_due}) != Balance Due ({balance_due}).")

        # --- Receipt Validation ---
        if self.payment_details:
            details = self.payment_details
            total_paid = float(details.total_payment.extracted_string_or_numeric_value)
            sum_of_payments = sum([
                float(details.cash_payment.extracted_string_or_numeric_value),
                float(details.check_payment.extracted_string_or_numeric_value),
                float(details.credit_card_payment.extracted_string_or_numeric_value),
                float(details.finance_payment.extracted_string_or_numeric_value)
            ])
            if not math.isclose(total_paid, sum_of_payments, rel_tol=1e-4):
                raise ValueError(f"Receipt Checksum Failed: Sum of payments ({sum_of_payments}) != Total Paid ({total_paid}).")

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "07939900_complex_po_variant",
    "should_pass": true,
    "taxonomy_lane": "JohnDeereTransactionRecord",
    "binary_header_simulation": "25504446",
    "payload": {
      "dealer": {
        "name": {
          "extracted_string_or_numeric_value": "Bader & Sons Co.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [398, 563],
            "vertical_y_vertices": [201, 213]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "4363 South Morey Road\nLake City, MI 49651",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [398, 563],
            "vertical_y_vertices": [214, 239]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "231-839-8660",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [398, 563],
            "vertical_y_vertices": [240, 250]
          }
        },
        "account_number": {
          "extracted_string_or_numeric_value": "032568",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [700, 750],
            "vertical_y_vertices": [120, 130]
          }
        }
      },
      "purchaser": {
        "name": {
          "extracted_string_or_numeric_value": "KIBBY COMPANY, LLC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [125, 300],
            "vertical_y_vertices": [125, 135]
          }
        },
        "street": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [125, 250],
            "vertical_y_vertices": [155, 165]
          }
        },
        "town": {
          "extracted_string_or_numeric_value": "MARION",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [125, 180],
            "vertical_y_vertices": [185, 195]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [330, 350],
            "vertical_y_vertices": [185, 195]
          }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [370, 410],
            "vertical_y_vertices": [185, 195]
          }
        },
        "account_number": {
          "extracted_string_or_numeric_value": "808812",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [260, 310],
            "vertical_y_vertices": [205, 215]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "231-743-6686",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [380, 460],
            "vertical_y_vertices": [205, 215]
          }
        }
      },
      "document_date": {
        "extracted_string_or_numeric_value": "2021-05-05",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [400, 480],
          "vertical_y_vertices": [120, 130]
        }
      },
      "po_number": {
        "extracted_string_or_numeric_value": "07939900",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 800],
          "vertical_y_vertices": [50, 60]
        }
      },
      "transaction_type": {
        "extracted_string_or_numeric_value": "Cash Sale",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [400, 480],
          "vertical_y_vertices": [185, 195]
        }
      },
      "line_items": [
        {
          "quantity": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [30, 50],
              "vertical_y_vertices": [450, 460]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "WESTENDORF BC-4215 St # 158700",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 450],
              "vertical_y_vertices": [450, 460]
            }
          },
          "product_id": {
            "extracted_string_or_numeric_value": "0020130",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 700],
              "vertical_y_vertices": [450, 460]
            }
          },
          "hours": {
            "extracted_string_or_numeric_value": 0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 580],
              "vertical_y_vertices": [450, 460]
            }
          },
          "price": {
            "extracted_string_or_numeric_value": 1750.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [750, 820],
              "vertical_y_vertices": [450, 460]
            }
          }
        }
      ],
      "financial_summary": {
        "total_cash_price": {
          "extracted_string_or_numeric_value": 1750.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [485, 495]
          }
        },
        "total_trade_in_allowance": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [520, 530]
          }
        },
        "total_trade_in_pay_off": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [565, 575]
          }
        },
        "balance_before_tax": {
          "extracted_string_or_numeric_value": 1750.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [580, 590]
          }
        },
        "sales_tax_rate": {
          "extracted_string_or_numeric_value": "(6.00%)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 650],
            "vertical_y_vertices": [595, 605]
          }
        },
        "sales_tax_amount": {
          "extracted_string_or_numeric_value": 105.00,
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [595, 605]
          }
        },
        "est_service_agreement": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [625, 635]
          }
        },
        "sub_total": {
          "extracted_string_or_numeric_value": 1855.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [655, 665]
          }
        },
        "cash_with_order": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [670, 680]
          }
        },
        "rental_applied": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [685, 695]
          }
        },
        "cash_discount": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [700, 710]
          }
        },
        "balance_due": {
          "extracted_string_or_numeric_value": 1855.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [750, 820],
            "vertical_y_vertices": [715, 725]
          }
        }
      },
      "salesperson": {
        "extracted_string_or_numeric_value": "BARRON, MITCH",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [150, 160]
        }
      },
      "comments": [
        {
          "extracted_string_or_numeric_value": "Paid in Full 5/5/21",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 500],
            "vertical_y_vertices": [600, 630]
          }
        },
        {
          "extracted_string_or_numeric_value": "* Keith reimbursed cash via EFT from 7008 5/5/2021",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 750],
            "vertical_y_vertices": [900, 930]
          }
        }
      ],
      "payment_details": null
    }
  }
]
```