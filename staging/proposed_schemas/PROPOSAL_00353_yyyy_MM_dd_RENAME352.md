An expert forensic data architect, I've analyzed the provided documents. Despite the directive's claim of a single document class with design drift, the evidence points to two distinct document types: a 'Customer Purchase Order' and a 'Financing Insurance Verification'. To adhere to the Zero-Trust mandate of accommodating *all* provided documents, I have engineered a resilient, unified schema. This schema treats one document type as a structural variant of the other, utilizing optional fields to maintain flexibility. The most complex variant, the Purchase Order, serves as the foundational structure for the schema and the golden test case.

***

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


class UnifiedLineItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    quantity: Optional[ForensicDataEntity] = None
    description: ForensicDataEntity
    product_id: Optional[ForensicDataEntity] = None
    price: ForensicDataEntity


class JohnDeereUnifiedDocument(BaseModel):
    """
    A unified schema designed to be resilient to structural variations between
    John Deere Purchase Orders and related financial documents like financing letters.
    Fields that are not universally present are marked as Optional.
    """
    model_config = ConfigDict(extra='forbid')

    # Document Info
    document_date: ForensicDataEntity
    order_number: Optional[ForensicDataEntity] = None
    account_reference: Optional[ForensicDataEntity] = None
    delivery_date: Optional[ForensicDataEntity] = None

    # Parties
    customer_name: ForensicDataEntity
    customer_address: ForensicDataEntity
    customer_phone: Optional[ForensicDataEntity] = None
    seller_name: Optional[ForensicDataEntity] = None
    seller_address: Optional[ForensicDataEntity] = None
    seller_phone: Optional[ForensicDataEntity] = None
    lender_name: Optional[ForensicDataEntity] = None
    lender_address: Optional[ForensicDataEntity] = None
    insurance_provider_name: Optional[ForensicDataEntity] = None
    insurance_provider_address: Optional[ForensicDataEntity] = None

    # Items
    line_items: List[UnifiedLineItem]

    # Financials
    total_items_price: ForensicDataEntity
    trade_in_allowance: Optional[ForensicDataEntity] = None
    balance_after_trade: Optional[ForensicDataEntity] = None
    sales_tax: Optional[ForensicDataEntity] = None
    sub_total: Optional[ForensicDataEntity] = None
    cash_with_order: Optional[ForensicDataEntity] = None
    balance_due: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_financials_gaap_checksum(self) -> 'JohnDeereUnifiedDocument':
        """
        Performs double-entry GAAP mathematical checksums based on the document type inferred
        from the presence of specific fields.
        """
        def get_value(entity: Optional[ForensicDataEntity], default: float = 0.0) -> float:
            if entity and isinstance(entity.extracted_string_or_numeric_value, (int, float)):
                return float(entity.extracted_string_or_numeric_value)
            # Handle cases like 'N/A' or 'Farm Use' which imply zero value
            if entity and isinstance(entity.extracted_string_or_numeric_value, str):
                return 0.0
            return default

        # Path 1: Purchase Order validation (inferred by presence of 'balance_due')
        if self.balance_due is not None:
            total_cash_price = get_value(self.total_items_price)
            trade_in = get_value(self.trade_in_allowance)
            balance_after_trade = get_value(self.balance_after_trade)
            tax = get_value(self.sales_tax)
            cash_with_order = get_value(self.cash_with_order)
            balance_due = get_value(self.balance_due)

            # Check 1: Sum of line items must equal the total cash price.
            calculated_line_item_sum = sum(get_value(item.price) for item in self.line_items)
            if not math.isclose(calculated_line_item_sum, total_cash_price):
                raise ValueError(f"Line item sum ({calculated_line_item_sum}) does not match Total Cash Price ({total_cash_price})")

            # Check 2: Balance after trade-in must be correct.
            calculated_balance_after_trade = total_cash_price - trade_in
            if not math.isclose(calculated_balance_after_trade, balance_after_trade):
                raise ValueError(f"Calculated balance after trade ({calculated_balance_after_trade}) does not match Balance ({balance_after_trade})")

            # Check 3: Final balance due must be correct.
            # Sub-total is implicitly calculated as balance_after_trade + tax.
            calculated_sub_total = calculated_balance_after_trade + tax
            calculated_balance_due = calculated_sub_total - cash_with_order
            if not math.isclose(calculated_balance_due, balance_due):
                raise ValueError(f"Calculated balance due ({calculated_balance_due}) does not match Balance Due ({balance_due})")

        # Path 2: Financing Letter validation (simpler sum check)
        elif len(self.line_items) > 0:
            total_value = get_value(self.total_items_price)
            calculated_line_item_sum = sum(get_value(item.price) for item in self.line_items)
            if not math.isclose(calculated_line_item_sum, total_value):
                raise ValueError(f"Line item sum ({calculated_line_item_sum}) does not match Total Value ({total_value})")

        return self
```

***

```json
[
  {
    "test_identifier": "test_po_15706488_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "JohnDeereUnifiedDocument",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_date": {
        "extracted_string_or_numeric_value": "6-2-06",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [458, 535],
          "vertical_y_vertices": [78, 91]
        }
      },
      "order_number": {
        "extracted_string_or_numeric_value": "15 706488",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [758, 879],
          "vertical_y_vertices": [39, 58]
        }
      },
      "delivery_date": {
        "extracted_string_or_numeric_value": "6-2-06",
        "optical_extraction_confidence_score": 0.88,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 275],
          "vertical_y_vertices": [920, 935]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "Reel Grandy",
        "optical_extraction_confidence_score": 0.85,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [150, 420],
          "vertical_y_vertices": [60, 85]
        }
      },
      "customer_address": {
        "extracted_string_or_numeric_value": "3291 18 mile Rd Manor MI 49665",
        "optical_extraction_confidence_score": 0.87,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [110, 430],
          "vertical_y_vertices": [100, 150]
        }
      },
      "customer_phone": {
        "extracted_string_or_numeric_value": "743-6686",
        "optical_extraction_confidence_score": 0.91,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [370, 470],
          "vertical_y_vertices": [155, 170]
        }
      },
      "seller_name": {
        "extracted_string_or_numeric_value": "Voelker Implement Sales, Inc.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [505, 700],
          "vertical_y_vertices": [110, 125]
        }
      },
      "seller_address": {
        "extracted_string_or_numeric_value": "4363 S. Morey Rd. Lake City, MI 49651.8644",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [505, 700],
          "vertical_y_vertices": [130, 165]
        }
      },
      "seller_phone": {
        "extracted_string_or_numeric_value": "231-839-8660",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [505, 650],
          "vertical_y_vertices": [185, 200]
        }
      },
      "line_items": [
        {
          "quantity": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [40, 60],
              "vertical_y_vertices": [370, 390]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "John Deere 673 3pt Tiller",
            "optical_extraction_confidence_score": 0.89,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [210, 450],
              "vertical_y_vertices": [370, 390]
            }
          },
          "product_id": {
            "extracted_string_or_numeric_value": "LV0673A140096",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [560, 750],
              "vertical_y_vertices": [395, 415]
            }
          },
          "price": {
            "extracted_string_or_numeric_value": 2900.00,
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [780, 860],
              "vertical_y_vertices": [370, 390]
            }
          }
        }
      ],
      "total_items_price": {
        "extracted_string_or_numeric_value": 2900.00,
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 860],
          "vertical_y_vertices": [510, 530]
        }
      },
      "trade_in_allowance": {
        "extracted_string_or_numeric_value": "N/A",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 860],
          "vertical_y_vertices": [560, 580]
        }
      },
      "balance_after_trade": {
        "extracted_string_or_numeric_value": 2900.00,
        "optical_extraction_confidence_score": 0.93,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 860],
          "vertical_y_vertices": [610, 630]
        }
      },
      "sales_tax": {
        "extracted_string_or_numeric_value": "Farm Use",
        "optical_extraction_confidence_score": 0.90,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 860],
          "vertical_y_vertices": [635, 655]
        }
      },
      "cash_with_order": {
        "extracted_string_or_numeric_value": 2900.00,
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 860],
          "vertical_y_vertices": [685, 705]
        }
      },
      "balance_due": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [780, 860],
          "vertical_y_vertices": [710, 730]
        }
      }
    }
  }
]
```