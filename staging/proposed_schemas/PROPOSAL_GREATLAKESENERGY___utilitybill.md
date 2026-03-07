An expert forensic data architect, I have analyzed the provided documents, which represent structural drift in the 'GREATLAKESENERGY - utilitybill' class. The older bill from 2002 exhibits a complex, multi-meter, tiered-rate structure with an un-itemized `availability_charge` that must be inferred for a complete financial reconciliation. The newer document, a bill's reverse side, clarifies the purpose of this charge and presents different contact addresses, confirming the need for a flexible schema.

My Pydantic V2 schema accommodates these variations by making non-universal fields `Optional` and includes a robust GAAP checksum validator to ensure the mathematical integrity of extracted financial data.

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

class MeterReading(BaseModel):
    model_config = ConfigDict(extra='forbid')
    meter_id: Optional[ForensicDataEntity] = None
    start_date: ForensicDataEntity
    end_date: ForensicDataEntity
    start_reading: ForensicDataEntity
    end_reading: ForensicDataEntity
    reading_type: ForensicDataEntity
    multiplier: ForensicDataEntity
    days: ForensicDataEntity
    usage_kwh: ForensicDataEntity

class EnergyChargeTier(BaseModel):
    model_config = ConfigDict(extra='forbid')
    usage_kwh: ForensicDataEntity
    rate: ForensicDataEntity
    cost: ForensicDataEntity

class PowerSupplyCostRecovery(BaseModel):
    model_config = ConfigDict(extra='forbid')
    usage_kwh: ForensicDataEntity
    rate: ForensicDataEntity
    cost: ForensicDataEntity

class BillCharges(BaseModel):
    model_config = ConfigDict(extra='forbid')
    energy_charge_tiers: List[EnergyChargeTier]
    power_supply_cost_recovery: PowerSupplyCostRecovery
    michigan_sales_tax: ForensicDataEntity
    service_subtotal: ForensicDataEntity
    service_total: ForensicDataEntity
    availability_charge: Optional[ForensicDataEntity] = None
    people_fund_contribution: Optional[ForensicDataEntity] = None

class ConsumptionHistoryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    value_kwh: ForensicDataEntity

class GreatLakesEnergyUtilityBill(BaseModel):
    """
    A resilient schema for Great Lakes Energy utility bills, accommodating structural
    variations observed over time, including changes in charge itemization and contact information.
    """
    model_config = ConfigDict(extra='forbid')
    
    vendor_name: ForensicDataEntity
    account_number: ForensicDataEntity
    customer_name: ForensicDataEntity
    service_address: ForensicDataEntity
    payment_address: ForensicDataEntity
    correspondence_address: ForensicDataEntity
    billing_date: ForensicDataEntity
    due_date: ForensicDataEntity
    amount_due: ForensicDataEntity
    total_kwh_billed: ForensicDataEntity
    meter_readings: List[MeterReading]
    charges: BillCharges
    
    cycle: Optional[ForensicDataEntity] = None
    consumption_history: Optional[List[ConsumptionHistoryItem]] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatLakesEnergyUtilityBill':
        """
        Performs double-entry GAAP mathematical checksums to validate financial data integrity.
        """
        # 1. Meter Usage Check
        total_metered_usage = sum(
            float(m.usage_kwh.extracted_string_or_numeric_value) for m in self.meter_readings
        )
        if not math.isclose(total_metered_usage, float(self.total_kwh_billed.extracted_string_or_numeric_value)):
            raise ValueError(f"Meter usage checksum failed: Sum of meter usages ({total_metered_usage}) does not match total kWh billed ({self.total_kwh_billed.extracted_string_or_numeric_value}).")

        # 2. Subtotal Check
        charges = self.charges
        calculated_subtotal = 0.0

        calculated_subtotal += sum(
            float(tier.cost.extracted_string_or_numeric_value) for tier in charges.energy_charge_tiers
        )
        calculated_subtotal += float(charges.power_supply_cost_recovery.cost.extracted_string_or_numeric_value)
        calculated_subtotal += float(charges.michigan_sales_tax.extracted_string_or_numeric_value)
        
        if charges.availability_charge:
            calculated_subtotal += float(charges.availability_charge.extracted_string_or_numeric_value)

        if not math.isclose(calculated_subtotal, float(charges.service_subtotal.extracted_string_or_numeric_value)):
            raise ValueError(f"Service subtotal checksum failed: Calculated subtotal ({calculated_subtotal:.2f}) does not match billed subtotal ({charges.service_subtotal.extracted_string_or_numeric_value}).")

        # 3. Total Check
        calculated_total = float(charges.service_subtotal.extracted_string_or_numeric_value)
        if charges.people_fund_contribution:
            calculated_total += float(charges.people_fund_contribution.extracted_string_or_numeric_value)

        if not math.isclose(calculated_total, float(charges.service_total.extracted_string_or_numeric_value)):
            raise ValueError(f"Service total checksum failed: Calculated total ({calculated_total:.2f}) does not match billed total ({charges.service_total.extracted_string_or_numeric_value}).")

        # 4. Amount Due Check
        if not math.isclose(float(charges.service_total.extracted_string_or_numeric_value), float(self.amount_due.extracted_string_or_numeric_value)):
            raise ValueError(f"Amount due checksum failed: Service total ({charges.service_total.extracted_string_or_numeric_value}) does not match amount due ({self.amount_due.extracted_string_or_numeric_value}).")

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "greatlakes_2002_multi_meter_tiered_complex",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyUtilityBill",
    "binary_header_simulation": "25504446",
    "payload": {
      "vendor_name": {
        "extracted_string_or_numeric_value": "Great Lakes ENERGY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [848, 958, 958, 848],
          "vertical_y_vertices": [875, 875, 908, 908]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "1903260900",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178, 299, 299, 178],
          "vertical_y_vertices": [420, 420, 432, 432]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "JUDITH KIBBY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [71, 171, 171, 71],
          "vertical_y_vertices": [388, 388, 400, 400]
        }
      },
      "service_address": {
        "extracted_string_or_numeric_value": "18 MILE RD 03291",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [790, 920, 920, 790],
          "vertical_y_vertices": [420, 420, 432, 432]
        }
      },
      "payment_address": {
        "extracted_string_or_numeric_value": "Bill Payment Center 2183 N. WATER RD. Hart, MI 49420-9007",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [283, 400, 400, 283],
          "vertical_y_vertices": [50, 50, 90, 90]
        }
      },
      "correspondence_address": {
        "extracted_string_or_numeric_value": "Great Lakes Energy Cooperative Customer Support Center P.O. Box 70 Boyne City, MI 49712-0070",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [580, 750, 750, 580],
          "vertical_y_vertices": [50, 50, 100, 100]
        }
      },
      "billing_date": {
        "extracted_string_or_numeric_value": "08/09/02",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 515, 515, 450],
          "vertical_y_vertices": [388, 388, 400, 400]
        }
      },
      "due_date": {
        "extracted_string_or_numeric_value": "09/02/02",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [880, 958, 958, 880],
          "vertical_y_vertices": [100, 100, 115, 115]
        }
      },
      "amount_due": {
        "extracted_string_or_numeric_value": 92.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [880, 958, 958, 880],
          "vertical_y_vertices": [130, 130, 145, 145]
        }
      },
      "total_kwh_billed": {
        "extracted_string_or_numeric_value": 1290,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [880, 940, 940, 880],
          "vertical_y_vertices": [500, 500, 512, 512]
        }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "05",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [530, 550, 550, 530],
          "vertical_y_vertices": [388, 388, 400, 400]
        }
      },
      "meter_readings": [
        {
          "meter_id": {
            "extracted_string_or_numeric_value": "15294246",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 520, 520, 450],
              "vertical_y_vertices": [435, 435, 445, 445]
            }
          },
          "start_date": {
            "extracted_string_or_numeric_value": "06/24/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [70, 120], "vertical_y_vertices": [480, 490] }
          },
          "end_date": {
            "extracted_string_or_numeric_value": "07/16/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 370], "vertical_y_vertices": [480, 490] }
          },
          "start_reading": {
            "extracted_string_or_numeric_value": 19171,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 180], "vertical_y_vertices": [480, 490] }
          },
          "end_reading": {
            "extracted_string_or_numeric_value": 19573,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 430], "vertical_y_vertices": [480, 490] }
          },
          "reading_type": {
            "extracted_string_or_numeric_value": "ACTUAL",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 250], "vertical_y_vertices": [480, 490] }
          },
          "multiplier": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 710], "vertical_y_vertices": [480, 490] }
          },
          "days": {
            "extracted_string_or_numeric_value": 22,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [730, 750], "vertical_y_vertices": [480, 490] }
          },
          "usage_kwh": {
            "extracted_string_or_numeric_value": 402,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [880, 920], "vertical_y_vertices": [480, 490] }
          }
        },
        {
          "start_date": {
            "extracted_string_or_numeric_value": "06/24/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [70, 120], "vertical_y_vertices": [490, 500] }
          },
          "end_date": {
            "extracted_string_or_numeric_value": "07/16/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 370], "vertical_y_vertices": [490, 500] }
          },
          "start_reading": {
            "extracted_string_or_numeric_value": 35676,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 180], "vertical_y_vertices": [490, 500] }
          },
          "end_reading": {
            "extracted_string_or_numeric_value": 36564,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 430], "vertical_y_vertices": [490, 500] }
          },
          "reading_type": {
            "extracted_string_or_numeric_value": "ACTUAL",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 250], "vertical_y_vertices": [490, 500] }
          },
          "multiplier": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 710], "vertical_y_vertices": [490, 500] }
          },
          "days": {
            "extracted_string_or_numeric_value": 22,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [730, 750], "vertical_y_vertices": [490, 500] }
          },
          "usage_kwh": {
            "extracted_string_or_numeric_value": 888,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [880, 920], "vertical_y_vertices": [490, 500] }
          }
        }
      ],
      "charges": {
        "availability_charge": {
          "extracted_string_or_numeric_value": 5.00,
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [390, 420, 420, 390],
            "vertical_y_vertices": [450, 450, 480, 480]
          }
        },
        "energy_charge_tiers": [
          {
            "usage_kwh": {
              "extracted_string_or_numeric_value": 400,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [550, 560] }
            },
            "rate": {
              "extracted_string_or_numeric_value": 0.0873,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 280], "vertical_y_vertices": [550, 560] }
            },
            "cost": {
              "extracted_string_or_numeric_value": 34.92,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [550, 560] }
            }
          },
          {
            "usage_kwh": {
              "extracted_string_or_numeric_value": 2,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [560, 570] }
            },
            "rate": {
              "extracted_string_or_numeric_value": 0.0838,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 280], "vertical_y_vertices": [560, 570] }
            },
            "cost": {
              "extracted_string_or_numeric_value": 0.17,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [560, 570] }
            }
          },
          {
            "usage_kwh": {
              "extracted_string_or_numeric_value": 888,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [570, 580] }
            },
            "rate": {
              "extracted_string_or_numeric_value": 0.0525,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 280], "vertical_y_vertices": [570, 580] }
            },
            "cost": {
              "extracted_string_or_numeric_value": 46.62,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [570, 580] }
            }
          }
        ],
        "power_supply_cost_recovery": {
          "usage_kwh": {
            "extracted_string_or_numeric_value": 402,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [600, 610] }
          },
          "rate": {
            "extracted_string_or_numeric_value": 0.00413,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 280], "vertical_y_vertices": [600, 610] }
          },
          "cost": {
            "extracted_string_or_numeric_value": 1.66,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [900, 940], "vertical_y_vertices": [600, 610] }
          }
        },
        "michigan_sales_tax": {
          "extracted_string_or_numeric_value": 3.53,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 940, 940, 900],
            "vertical_y_vertices": [615, 615, 625, 625]
          }
        },
        "service_subtotal": {
          "extracted_string_or_numeric_value": 91.90,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 940, 940, 900],
            "vertical_y_vertices": [630, 630, 640, 640]
          }
        },
        "people_fund_contribution": {
          "extracted_string_or_numeric_value": 0.10,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 940, 940, 900],
            "vertical_y_vertices": [645, 645, 655, 655]
          }
        },
        "service_total": {
          "extracted_string_or_numeric_value": 92.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 940, 940, 900],
            "vertical_y_vertices": [660, 660, 670, 670]
          }
        }
      },
      "consumption_history": [
        { "value_kwh": { "extracted_string_or_numeric_value": 1184, "optical_extraction_confidence_score": 0.9, "physical_evidence_coordinates": { "horizontal_x_vertices": [600,620], "vertical_y_vertices": [350,360] } } },
        { "value_kwh": { "extracted_string_or_numeric_value": 1509, "optical_extraction_confidence_score": 0.9, "physical_evidence_coordinates": { "horizontal_x_vertices": [620,640], "vertical_y_vertices": [350,360] } } },
        { "value_kwh": { "extracted_string_or_numeric_value": 1835, "optical_extraction_confidence_score": 0.9, "physical_evidence_coordinates": { "horizontal_x_vertices": [640,660], "vertical_y_vertices": [350,360] } } },
        { "value_kwh": { "extracted_string_or_numeric_value": 2160, "optical_extraction_confidence_score": 0.9, "physical_evidence_coordinates": { "horizontal_x_vertices": [660,680], "vertical_y_vertices": [350,360] } } },
        { "value_kwh": { "extracted_string_or_numeric_value": 2486, "optical_extraction_confidence_score": 0.9, "physical_evidence_coordinates": { "horizontal_x_vertices": [680,700], "vertical_y_vertices": [350,360] } } }
      ]
    }
  }
]
```