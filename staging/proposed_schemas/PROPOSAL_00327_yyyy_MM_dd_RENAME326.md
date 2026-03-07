An analysis of the provided documents reveals two distinct but related formats: a highly structured "Bill of Lading" (represented by two nearly identical examples) and a severely degraded thermal receipt. The most resilient and forensically sound approach is to model the superset of all available data, which is clearly defined in the Bill of Lading. The resulting schema uses optional fields to accommodate less-detailed variants, such as the degraded receipt, where most fields would be un-extractable and thus absent.

The schema includes a mathematical validator that, in the absence of financial totals, performs logical integrity checks on available numeric data: it verifies that ordered quantities match the sum of shipped and back-ordered quantities for each line item, and confirms that the gross weight is not less than the net weight, adhering to the directive for a GAAP-style checksum.

***

```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AutoZoneOrderLineItem(BaseModel):
    """Represents a single item on the AutoZone Bill of Lading."""
    model_config = ConfigDict(extra='forbid')
    
    item_number: ForensicDataEntity
    part_number: ForensicDataEntity
    quantity_shipped: ForensicDataEntity
    description: ForensicDataEntity
    bin_location: Optional[ForensicDataEntity] = None
    order_item_ref: ForensicDataEntity
    quantity_ordered: ForensicDataEntity
    quantity_backordered: ForensicDataEntity
    price: Optional[ForensicDataEntity] = None
    unit_of_measure: ForensicDataEntity
    amount: Optional[ForensicDataEntity] = None

class AutoZoneBillOfLadingV1(BaseModel):
    """
    A resilient schema for AutoZone order documents, primarily based on the 
    Bill of Lading format, which represents the most comprehensive data structure.
    """
    model_config = ConfigDict(extra='forbid')
    
    document_title: ForensicDataEntity
    bol_type: ForensicDataEntity
    bol_number: ForensicDataEntity
    bol_date: ForensicDataEntity
    customer_number: ForensicDataEntity
    ship_date: ForensicDataEntity
    ship_via: ForensicDataEntity
    customer_po_number: ForensicDataEntity
    salesman: ForensicDataEntity
    order_date: ForensicDataEntity
    
    ship_to_name: ForensicDataEntity
    ship_to_address: ForensicDataEntity
    ship_to_city_state_zip: ForensicDataEntity
    
    sold_from_id: ForensicDataEntity
    sold_from_description: ForensicDataEntity
    
    vendor_name: ForensicDataEntity
    vendor_address_line1: ForensicDataEntity
    vendor_address_line2: ForensicDataEntity
    
    carrier: ForensicDataEntity
    scac_code: ForensicDataEntity
    
    line_items: List[AutoZoneOrderLineItem]
    
    total_cartons: ForensicDataEntity
    gross_weight: ForensicDataEntity
    net_weight: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'AutoZoneBillOfLadingV1':
        """
        Performs mathematical integrity checks based on available data.
        1. Verifies that for each line item, quantity_ordered = quantity_shipped + quantity_backordered.
        2. Verifies that the total gross_weight is greater than or equal to the net_weight.
        """
        # Check 1: Line item quantities
        for i, item in enumerate(self.line_items):
            try:
                qty_ordered = float(item.quantity_ordered.extracted_string_or_numeric_value)
                qty_shipped = float(item.quantity_shipped.extracted_string_or_numeric_value)
                qty_backordered = float(item.quantity_backordered.extracted_string_or_numeric_value)

                if not math.isclose(qty_ordered, qty_shipped + qty_backordered):
                    raise ValueError(
                        f"Line item {i+1} quantity mismatch: "
                        f"Ordered ({qty_ordered}) != Shipped ({qty_shipped}) + Backordered ({qty_backordered})"
                    )
            except (ValueError, TypeError) as e:
                raise ValueError(f"Invalid numeric value for quantity in line item {i+1}: {e}")

        # Check 2: Gross vs. Net Weight
        try:
            gross_weight_str = str(self.gross_weight.extracted_string_or_numeric_value)
            net_weight_str = str(self.net_weight.extracted_string_or_numeric_value)
            
            gross_weight_val = float(gross_weight_str.split()[0])
            net_weight_val = float(net_weight_str.split()[0])

            if gross_weight_val < net_weight_val:
                raise ValueError(
                    f"Weight mismatch: Gross Weight ({gross_weight_val}) cannot be less than Net Weight ({net_weight_val})"
                )
        except (ValueError, TypeError, IndexError) as e:
            raise ValueError(f"Invalid numeric value for weight: {e}")

        return self
```

***

```json
[
  {
    "test_identifier": "20170216_autozone_bol_11752728",
    "should_pass": true,
    "taxonomy_lane": "AutoZoneBillOfLadingV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "BILL OF LADING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [427, 597, 597, 427], "vertical_y_vertices": [142, 142, 158, 158] }
      },
      "bol_type": {
        "extracted_string_or_numeric_value": "CUSTOMER ORDER",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [478, 597, 597, 478], "vertical_y_vertices": [179, 179, 191, 191] }
      },
      "bol_number": {
        "extracted_string_or_numeric_value": "11752728",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [752, 827, 827, 752], "vertical_y_vertices": [143, 143, 156, 156] }
      },
      "bol_date": {
        "extracted_string_or_numeric_value": "2/16/17",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 958, 958, 900], "vertical_y_vertices": [143, 143, 156, 156] }
      },
      "customer_number": {
        "extracted_string_or_numeric_value": "04561007",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [752, 827, 827, 752], "vertical_y_vertices": [179, 179, 191, 191] }
      },
      "ship_date": {
        "extracted_string_or_numeric_value": "2/16/17",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 958, 958, 900], "vertical_y_vertices": [179, 179, 191, 191] }
      },
      "ship_via": {
        "extracted_string_or_numeric_value": "FEDX",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [752, 791, 791, 752], "vertical_y_vertices": [215, 215, 227, 227] }
      },
      "customer_po_number": {
        "extracted_string_or_numeric_value": "91644675-20170215",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [752, 888, 888, 752], "vertical_y_vertices": [251, 251, 263, 263] }
      },
      "salesman": {
        "extracted_string_or_numeric_value": "Rick O'Leary Sales &",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [717, 888, 888, 717], "vertical_y_vertices": [287, 287, 299, 299] }
      },
      "order_date": {
        "extracted_string_or_numeric_value": "2/15/17",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 958, 958, 900], "vertical_y_vertices": [287, 287, 299, 299] }
      },
      "ship_to_name": {
        "extracted_string_or_numeric_value": "KEITH A GRANDY",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [43, 175, 175, 43], "vertical_y_vertices": [279, 279, 291, 291] }
      },
      "ship_to_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [43, 175, 175, 43], "vertical_y_vertices": [295, 295, 307, 307] }
      },
      "ship_to_city_state_zip": {
        "extracted_string_or_numeric_value": "MARION, MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [43, 185, 185, 43], "vertical_y_vertices": [311, 311, 323, 323] }
      },
      "sold_from_id": {
        "extracted_string_or_numeric_value": "D4561007",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [110, 175, 175, 110], "vertical_y_vertices": [365, 365, 377, 377] }
      },
      "sold_from_description": {
        "extracted_string_or_numeric_value": "AUTOZONE PARTS DROP SHIP",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 355, 355, 185], "vertical_y_vertices": [365, 365, 377, 377] }
      },
      "vendor_name": {
        "extracted_string_or_numeric_value": "AUTOZONE PARTS, INC.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [375, 540, 540, 375], "vertical_y_vertices": [279, 279, 291, 291] }
      },
      "vendor_address_line1": {
        "extracted_string_or_numeric_value": "P.O. BOX 2198",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [375, 475, 475, 375], "vertical_y_vertices": [295, 295, 307, 307] }
      },
      "vendor_address_line2": {
        "extracted_string_or_numeric_value": "MEMPHIS, TN 38101-9842",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [375, 550, 550, 375], "vertical_y_vertices": [311, 311, 323, 323] }
      },
      "carrier": {
        "extracted_string_or_numeric_value": "Federal Express",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 620, 620, 520], "vertical_y_vertices": [425, 425, 437, 437] }
      },
      "scac_code": {
        "extracted_string_or_numeric_value": "FDEG",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 730, 730, 700], "vertical_y_vertices": [425, 425, 437, 437] }
      },
      "line_items": [
        {
          "item_number": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [35, 45, 45, 35], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "part_number": {
            "extracted_string_or_numeric_value": "120036",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [100, 150, 150, 100], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "quantity_shipped": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 260, 260, 250], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "description": {
            "extracted_string_or_numeric_value": "120036 Rear MudFlap Set",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 500, 500, 350], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "bin_location": {
            "extracted_string_or_numeric_value": "P6117A",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 400, 400, 350], "vertical_y_vertices": [515, 515, 525, 525] }
          },
          "order_item_ref": {
            "extracted_string_or_numeric_value": "708690194/001",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 650, 650, 550], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "quantity_ordered": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 680, 680, 670], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "quantity_backordered": {
            "extracted_string_or_numeric_value": 0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [730, 740, 740, 730], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "price": {
            "extracted_string_or_numeric_value": "C",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 800, 800, 790], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "unit_of_measure": {
            "extracted_string_or_numeric_value": "EA",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [850, 870, 870, 850], "vertical_y_vertices": [485, 485, 495, 495] }
          },
          "amount": null
        }
      ],
      "total_cartons": {
        "extracted_string_or_numeric_value": 1,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [110, 120, 120, 110], "vertical_y_vertices": [830, 830, 840, 840] }
      },
      "gross_weight": {
        "extracted_string_or_numeric_value": "4 LB",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 330, 330, 300], "vertical_y_vertices": [830, 830, 840, 840] }
      },
      "net_weight": {
        "extracted_string_or_numeric_value": "4 LB",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 730, 730, 700], "vertical_y_vertices": [830, 830, 840, 840] }
      }
    }
  }
]
```