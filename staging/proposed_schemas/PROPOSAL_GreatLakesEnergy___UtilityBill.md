An analysis of the provided utility bills from Great Lakes Energy reveals significant structural drift over the years (2000, 2001, 2002). Key variations include the introduction, removal, and renaming of charge line items such as `OPERATION ROUND-UP`, `PEOPLE FUND CONTRIBUTION`, and `2001 POWER COST REFUND`. Additionally, identifying metadata like `Sub Meter2` and `Meter Mfg#` are not consistently present.

To create a resilient schema, all unique fields observed across the documents are included, with fields not present in every document typed as `Optional`. The financial structure is modeled with explicit fields for recurring charges and lists for variable-length items like meter readings and energy charge tiers.

A `model_validator` implements double-entry accounting principles to ensure the integrity of the extracted financial data. It verifies three core calculations:
1.  The sum of energy used per meter equals the total kWh billed.
2.  The sum of all charge and credit line items (energy tiers, availability, PSCR, tax, refunds) correctly totals the `service_subtotal`.
3.  The `service_subtotal` plus any final adjustments (like round-ups or contributions) correctly totals the `service_total` and the final `amount_due`.

The most structurally complex document, the bill from October 2002, was selected for the golden test case. It includes a multi-tiered energy charge, a negative line item (refund), and a voluntary contribution, exercising the full flexibility of the proposed schema.

***

```python
import decimal
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# MANDATED BASE CLASSES (DO NOT MODIFY)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# DERIVED SCHEMA
class ElectricDetail(BaseModel):
    """Represents a single meter's reading and usage."""
    model_config = ConfigDict(extra='forbid')
    service_rate: ForensicDataEntity
    beginning_meter_reading_date: ForensicDataEntity
    beginning_meter_reading_value: ForensicDataEntity
    ending_meter_reading_date: ForensicDataEntity
    ending_meter_reading_value: ForensicDataEntity
    meter_multiplier: ForensicDataEntity
    days_billed: ForensicDataEntity
    energy_used_kwh: ForensicDataEntity

class EnergyChargeTier(BaseModel):
    """Represents a single tier of the energy charge calculation."""
    model_config = ConfigDict(extra='forbid')
    kwh_used: ForensicDataEntity
    rate: ForensicDataEntity
    cost: ForensicDataEntity

class GreatLakesEnergyUtilityBill(BaseModel):
    """
    A resilient schema for Great Lakes Energy utility bills from 2000-2002.
    Accommodates structural drift in charge items and metadata.
    """
    model_config = ConfigDict(extra='forbid')

    # Common Header Information
    customer_name: ForensicDataEntity
    account_number: ForensicDataEntity
    billing_date: ForensicDataEntity
    due_date: ForensicDataEntity
    amount_due: ForensicDataEntity
    service_location: ForensicDataEntity
    cycle: ForensicDataEntity

    # Optional Header Information (due to document drift)
    sub_meter_number: Optional[ForensicDataEntity] = None
    meter_mfg_number: Optional[ForensicDataEntity] = None

    # Usage Details
    electric_details: List[ElectricDetail]
    total_kwh_billed: ForensicDataEntity

    # Charge & Credit Line Items
    energy_charge_tiers: List[EnergyChargeTier]
    availability_charge: ForensicDataEntity
    power_supply_cost_recovery: ForensicDataEntity
    michigan_sales_tax: ForensicDataEntity
    
    # Optional Charges/Credits (due to document drift)
    power_cost_refund: Optional[ForensicDataEntity] = None
    operation_round_up: Optional[ForensicDataEntity] = None
    people_fund_contribution: Optional[ForensicDataEntity] = None
    
    # Financial Totals
    service_subtotal: ForensicDataEntity
    service_total: ForensicDataEntity

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'GreatLakesEnergyUtilityBill':
        """
        Performs mathematical validation of financial data using double-entry principles.
        """
        # Use Decimal for precise financial calculations, avoiding float inaccuracies.
        ctx = decimal.Context(rounding=decimal.ROUND_HALF_UP)

        def to_decimal(entity: Optional[ForensicDataEntity], precision: str = '0.01') -> decimal.Decimal:
            if entity is None or entity.extracted_string_or_numeric_value is None:
                return decimal.Decimal('0.00')
            val = decimal.Decimal(str(entity.extracted_string_or_numeric_value))
            return val.quantize(decimal.Decimal(precision), context=ctx)

        # 1. Verify Total kWh Billed
        calculated_kwh = sum(to_decimal(detail.energy_used_kwh, '1') for detail in self.electric_details)
        billed_kwh = to_decimal(self.total_kwh_billed, '1')
        if calculated_kwh != billed_kwh:
            raise ValueError(f"kWh Mismatch: Sum of details ({calculated_kwh}) != Total billed ({billed_kwh})")

        # 2. Verify Service Subtotal
        total_energy_cost = sum(to_decimal(tier.cost) for tier in self.energy_charge_tiers)
        
        calculated_subtotal = (
            total_energy_cost +
            to_decimal(self.availability_charge) +
            to_decimal(self.power_supply_cost_recovery) +
            to_decimal(self.michigan_sales_tax) +
            to_decimal(self.power_cost_refund)  # Handles credits (negative values)
        )
        billed_subtotal = to_decimal(self.service_subtotal)
        
        if calculated_subtotal != billed_subtotal:
            raise ValueError(f"Subtotal Mismatch: Calculated ({calculated_subtotal}) != Billed ({billed_subtotal})")

        # 3. Verify Service Total and Amount Due
        calculated_total = (
            billed_subtotal +
            to_decimal(self.operation_round_up) +
            to_decimal(self.people_fund_contribution)
        )
        billed_total = to_decimal(self.service_total)
        amount_due = to_decimal(self.amount_due)

        if calculated_total != billed_total:
            raise ValueError(f"Service Total Mismatch: Calculated ({calculated_total}) != Billed ({billed_total})")
        
        if calculated_total != amount_due:
            raise ValueError(f"Amount Due Mismatch: Calculated Total ({calculated_total}) != Billed Amount Due ({amount_due})")

        return self
```
```json
[
  {
    "test_identifier": "bill_2002_10_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyUtilityBill",
    "binary_header_simulation": "25504446",
    "payload": {
      "customer_name": {
        "extracted_string_or_numeric_value": "JUDITH KIBBY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [35, 135],
          "vertical_y_vertices": [180, 195]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "1903260900",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 350],
          "vertical_y_vertices": [240, 255]
        }
      },
      "billing_date": {
        "extracted_string_or_numeric_value": "10/09/02",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 750],
          "vertical_y_vertices": [180, 195]
        }
      },
      "due_date": {
        "extracted_string_or_numeric_value": "10/30/02",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [880, 950],
          "vertical_y_vertices": [880, 895]
        }
      },
      "amount_due": {
        "extracted_string_or_numeric_value": 44.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [880, 950],
          "vertical_y_vertices": [830, 845]
        }
      },
      "service_location": {
        "extracted_string_or_numeric_value": "18 MILE RD 03291",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 820],
          "vertical_y_vertices": [240, 255]
        }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "05",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [830, 850],
          "vertical_y_vertices": [180, 195]
        }
      },
      "sub_meter_number": {
        "extracted_string_or_numeric_value": "15294246",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 550],
          "vertical_y_vertices": [240, 255]
        }
      },
      "electric_details": [
        {
          "service_rate": {
            "extracted_string_or_numeric_value": "1",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [30, 40], "vertical_y_vertices": [270, 280] }
          },
          "beginning_meter_reading_date": {
            "extracted_string_or_numeric_value": "08/20/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 210], "vertical_y_vertices": [270, 280] }
          },
          "beginning_meter_reading_value": {
            "extracted_string_or_numeric_value": 20136,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [270, 280] }
          },
          "ending_meter_reading_date": {
            "extracted_string_or_numeric_value": "09/17/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 480], "vertical_y_vertices": [270, 280] }
          },
          "ending_meter_reading_value": {
            "extracted_string_or_numeric_value": 20625,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 540], "vertical_y_vertices": [270, 280] }
          },
          "meter_multiplier": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 690], "vertical_y_vertices": [270, 280] }
          },
          "days_billed": {
            "extracted_string_or_numeric_value": 28,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 740], "vertical_y_vertices": [270, 280] }
          },
          "energy_used_kwh": {
            "extracted_string_or_numeric_value": 489,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [880, 940], "vertical_y_vertices": [270, 280] }
          }
        },
        {
          "service_rate": {
            "extracted_string_or_numeric_value": "15",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [30, 40], "vertical_y_vertices": [285, 295] }
          },
          "beginning_meter_reading_date": {
            "extracted_string_or_numeric_value": "08/20/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 210], "vertical_y_vertices": [285, 295] }
          },
          "beginning_meter_reading_value": {
            "extracted_string_or_numeric_value": 37744,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [285, 295] }
          },
          "ending_meter_reading_date": {
            "extracted_string_or_numeric_value": "09/17/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 480], "vertical_y_vertices": [285, 295] }
          },
          "ending_meter_reading_value": {
            "extracted_string_or_numeric_value": 38833,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 540], "vertical_y_vertices": [285, 295] }
          },
          "meter_multiplier": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 690], "vertical_y_vertices": [285, 295] }
          },
          "days_billed": {
            "extracted_string_or_numeric_value": 28,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 740], "vertical_y_vertices": [285, 295] }
          },
          "energy_used_kwh": {
            "extracted_string_or_numeric_value": 1089,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [880, 940], "vertical_y_vertices": [285, 295] }
          }
        }
      ],
      "total_kwh_billed": {
        "extracted_string_or_numeric_value": 1578,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [880, 940], "vertical_y_vertices": [300, 310] }
      },
      "energy_charge_tiers": [
        {
          "kwh_used": {
            "extracted_string_or_numeric_value": 489,
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 430], "vertical_y_vertices": [330, 340] }
          },
          "rate": {
            "extracted_string_or_numeric_value": 0.083500,
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 520], "vertical_y_vertices": [330, 340] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 40.83,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [330, 340] }
          }
        },
        {
          "kwh_used": {
            "extracted_string_or_numeric_value": 1089,
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 430], "vertical_y_vertices": [345, 355] }
          },
          "rate": {
            "extracted_string_or_numeric_value": 0.053500,
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 520], "vertical_y_vertices": [345, 355] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 58.26,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [345, 355] }
          }
        }
      ],
      "availability_charge": {
        "extracted_string_or_numeric_value": 10.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [360, 370] }
      },
      "power_supply_cost_recovery": {
        "extracted_string_or_numeric_value": 3.98,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [375, 385] }
      },
      "michigan_sales_tax": {
        "extracted_string_or_numeric_value": 1.69,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [405, 415] }
      },
      "power_cost_refund": {
        "extracted_string_or_numeric_value": -70.88,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [390, 400] }
      },
      "people_fund_contribution": {
        "extracted_string_or_numeric_value": 0.12,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [435, 445] }
      },
      "service_subtotal": {
        "extracted_string_or_numeric_value": 43.88,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [420, 430] }
      },
      "service_total": {
        "extracted_string_or_numeric_value": 44.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [450, 460] }
      }
    }
  }
]
```
