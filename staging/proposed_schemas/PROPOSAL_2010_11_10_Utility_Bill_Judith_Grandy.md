An expert forensic data architect, I have analyzed the provided utility bill document. Below is the resilient Pydantic V2 schema designed to accommodate its structure, along with a JSON test case representing the document's data, fully compliant with the specified directives.

### BLOCK 1: Python Pydantic V2 Schema

```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class PreviousActivity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    payment_received: ForensicDataEntity
    payment_date: ForensicDataEntity
    account_balance_before_current_charges: ForensicDataEntity

class MeterReading(BaseModel):
    model_config = ConfigDict(extra='forbid')
    meter_number: ForensicDataEntity
    current_read_date: ForensicDataEntity
    current_read_value: ForensicDataEntity
    previous_read_date: ForensicDataEntity
    previous_read_value: ForensicDataEntity
    kwh_multiplier: ForensicDataEntity
    kwh_usage: ForensicDataEntity
    number_of_days: ForensicDataEntity

class LineItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    details: Optional[ForensicDataEntity] = None
    amount: ForensicDataEntity

class CurrentActivity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    line_items: List[LineItem]
    total_current_activity: ForensicDataEntity

class UtilityBillJudithGrandy(BaseModel):
    """
    Schema for a utility bill for Judith Grandy dated 11/10/10.
    """
    model_config = ConfigDict(extra='forbid')

    billing_date: ForensicDataEntity
    account_number: ForensicDataEntity
    customer_name: ForensicDataEntity
    service_address: ForensicDataEntity
    full_account_number: ForensicDataEntity
    rate_plan: Optional[ForensicDataEntity] = None
    previous_activity: PreviousActivity
    meters: List[MeterReading]
    current_activity: CurrentActivity
    total_due: ForensicDataEntity
    page_info: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'UtilityBillJudithGrandy':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        """
        # 1. Previous Activity Check
        prev_balance = self.previous_activity.previous_balance.extracted_string_or_numeric_value
        payment = self.previous_activity.payment_received.extracted_string_or_numeric_value
        balance_before_charges = self.previous_activity.account_balance_before_current_charges.extracted_string_or_numeric_value

        if not math.isclose(float(prev_balance) - float(payment), float(balance_before_charges), abs_tol=0.01):
            raise ValueError(
                f"Previous balance checksum failed: {prev_balance} - {payment} != {balance_before_charges}"
            )

        # 2. Current Activity Check
        calculated_current_total = sum(
            float(item.amount.extracted_string_or_numeric_value) for item in self.current_activity.line_items
        )
        billed_current_total = self.current_activity.total_current_activity.extracted_string_or_numeric_value

        if not math.isclose(calculated_current_total, float(billed_current_total), abs_tol=0.01):
            raise ValueError(
                f"Sum of line items ({calculated_current_total}) does not match total current activity ({billed_current_total})"
            )

        # 3. Total Due Check
        total_due = self.total_due.extracted_string_or_numeric_value
        
        if not math.isclose(float(balance_before_charges) + float(billed_current_total), float(total_due), abs_tol=0.01):
            raise ValueError(
                f"Total due checksum failed: {balance_before_charges} + {billed_current_total} != {total_due}"
            )

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "2010-11-10-judith-grandy-utility-bill",
    "should_pass": true,
    "taxonomy_lane": "UtilityBillJudithGrandy",
    "binary_header_simulation": "25504446",
    "payload": {
      "billing_date": {
        "extracted_string_or_numeric_value": "11/10/10",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [491, 560],
          "vertical_y_vertices": [20, 31]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "100074416",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608, 688],
          "vertical_y_vertices": [43, 54]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "JUDITH GRANDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608, 703],
          "vertical_y_vertices": [67, 78]
        }
      },
      "service_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [123, 350],
          "vertical_y_vertices": [123, 134]
        }
      },
      "full_account_number": {
        "extracted_string_or_numeric_value": "100074416-002",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [652, 794],
          "vertical_y_vertices": [123, 134]
        }
      },
      "rate_plan": {
        "extracted_string_or_numeric_value": "Residential - RES",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [716, 834],
          "vertical_y_vertices": [147, 158]
        }
      },
      "previous_activity": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 152.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [778, 834],
            "vertical_y_vertices": [171, 182]
          }
        },
        "payment_received": {
          "extracted_string_or_numeric_value": 152.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [778, 834],
            "vertical_y_vertices": [187, 198]
          }
        },
        "payment_date": {
          "extracted_string_or_numeric_value": "11/03/10",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [520, 575],
            "vertical_y_vertices": [187, 198]
          }
        },
        "account_balance_before_current_charges": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [791, 834],
            "vertical_y_vertices": [203, 214]
          }
        }
      },
      "meters": [
        {
          "meter_number": {
            "extracted_string_or_numeric_value": "30303620",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [133, 260], "vertical_y_vertices": [159, 170] }
          },
          "current_read_date": {
            "extracted_string_or_numeric_value": "11/08/10",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 275], "vertical_y_vertices": [175, 186] }
          },
          "current_read_value": {
            "extracted_string_or_numeric_value": 59429,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [285, 328], "vertical_y_vertices": [175, 186] }
          },
          "previous_read_date": {
            "extracted_string_or_numeric_value": "10/11/10",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 275], "vertical_y_vertices": [191, 202] }
          },
          "previous_read_value": {
            "extracted_string_or_numeric_value": 58787,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [285, 328], "vertical_y_vertices": [191, 202] }
          },
          "kwh_multiplier": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [307, 314], "vertical_y_vertices": [207, 218] }
          },
          "kwh_usage": {
            "extracted_string_or_numeric_value": 642,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [299, 321], "vertical_y_vertices": [223, 234] }
          },
          "number_of_days": {
            "extracted_string_or_numeric_value": 28,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [207, 222], "vertical_y_vertices": [239, 250] }
          }
        },
        {
          "meter_number": {
            "extracted_string_or_numeric_value": "30303624",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [133, 260], "vertical_y_vertices": [263, 274] }
          },
          "current_read_date": {
            "extracted_string_or_numeric_value": "11/08/10",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 275], "vertical_y_vertices": [279, 290] }
          },
          "current_read_value": {
            "extracted_string_or_numeric_value": 93686,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [285, 328], "vertical_y_vertices": [279, 290] }
          },
          "previous_read_date": {
            "extracted_string_or_numeric_value": "10/11/10",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 275], "vertical_y_vertices": [295, 306] }
          },
          "previous_read_value": {
            "extracted_string_or_numeric_value": 92851,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [285, 328], "vertical_y_vertices": [295, 306] }
          },
          "kwh_multiplier": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [307, 314], "vertical_y_vertices": [311, 322] }
          },
          "kwh_usage": {
            "extracted_string_or_numeric_value": 835,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [299, 321], "vertical_y_vertices": [327, 338] }
          },
          "number_of_days": {
            "extracted_string_or_numeric_value": 28,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [207, 222], "vertical_y_vertices": [343, 354] }
          }
        }
      ],
      "current_activity": {
        "line_items": [
          {
            "description": { "extracted_string_or_numeric_value": "Monthly Charge", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 520], "vertical_y_vertices": [239, 250] } },
            "amount": { "extracted_string_or_numeric_value": 12.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [785, 834], "vertical_y_vertices": [239, 250] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "Energy Usage", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 510], "vertical_y_vertices": [255, 266] } },
            "details": { "extracted_string_or_numeric_value": "642 kWh x 00.099810", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [585, 730], "vertical_y_vertices": [255, 266] } },
            "amount": { "extracted_string_or_numeric_value": 64.08, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [785, 834], "vertical_y_vertices": [255, 266] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "Heat Energy Usage", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 538], "vertical_y_vertices": [271, 282] } },
            "details": { "extracted_string_or_numeric_value": "835 kWh x 00.099810", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [585, 730], "vertical_y_vertices": [271, 282] } },
            "amount": { "extracted_string_or_numeric_value": 83.34, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [785, 834], "vertical_y_vertices": [271, 282] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "Heat Energy Credit", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 542], "vertical_y_vertices": [287, 298] } },
            "details": { "extracted_string_or_numeric_value": "835 kWh x 00.030000", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [585, 730], "vertical_y_vertices": [287, 298] } },
            "amount": { "extracted_string_or_numeric_value": -25.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [775, 834], "vertical_y_vertices": [287, 298] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "PSCR on Energy Use", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 550], "vertical_y_vertices": [303, 314] } },
            "details": { "extracted_string_or_numeric_value": "1477 kWh x 00.009810", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [585, 730], "vertical_y_vertices": [303, 314] } },
            "amount": { "extracted_string_or_numeric_value": 14.49, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [785, 834], "vertical_y_vertices": [303, 314] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "Energy Optimization Surcharge", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 620], "vertical_y_vertices": [319, 330] } },
            "details": { "extracted_string_or_numeric_value": "1477 kWh x 00.001580", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [585, 730], "vertical_y_vertices": [319, 330] } },
            "amount": { "extracted_string_or_numeric_value": 2.33, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [791, 834], "vertical_y_vertices": [319, 330] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "State Sales Tax", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 525], "vertical_y_vertices": [335, 346] } },
            "details": { "extracted_string_or_numeric_value": "151.19 x 00.040000", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [585, 730], "vertical_y_vertices": [335, 346] } },
            "amount": { "extracted_string_or_numeric_value": 6.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [791, 834], "vertical_y_vertices": [335, 346] } }
          },
          {
            "description": { "extracted_string_or_numeric_value": "People Fund", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [424, 500], "vertical_y_vertices": [351, 362] } },
            "amount": { "extracted_string_or_numeric_value": 0.76, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [791, 834], "vertical_y_vertices": [351, 362] } }
          }
        ],
        "total_current_activity": {
          "extracted_string_or_numeric_value": 158.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [778, 834],
            "vertical_y_vertices": [367, 378]
          }
        }
      },
      "total_due": {
        "extracted_string_or_numeric_value": 158.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [778, 834],
          "vertical_y_vertices": [383, 394]
        }
      },
      "page_info": {
        "extracted_string_or_numeric_value": "Page 3 of 3",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [790, 850],
          "vertical_y_vertices": [940, 950]
        }
      }
    }
  }
]
```