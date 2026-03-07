An expert forensic data architect, I have meticulously analyzed the provided document variants for 'JUDITHGRANDY - UtilityBill'. The following Pydantic V2 schema and corresponding JSON test case are designed for maximum resilience and data integrity, adhering to the strict Zero-Trust mandate.

The schema accommodates the structural drift observed, notably by making the `capital_credit_refund` field optional, as it is present in the 12/10/10 bill but absent in the 11/10/10 version. The integrated GAAP-style mathematical validator ensures the internal consistency of all financial and metered data, cross-verifying totals and usage calculations to prevent data corruption.

The chosen JSON test case represents the most complex variant (12/10/10 bill), ensuring that all fields, including optional ones, are validated against a known-good state.

### BLOCK 1 (Python Pydantic V2)
```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

# MANDATORY: Do not modify these base classes
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema for the utility bill
class MeterUsageHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    meter_number: ForensicDataEntity
    monthly_kwh_usage: List[ForensicDataEntity]

class MeterDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    meter_number: ForensicDataEntity
    current_read_date: ForensicDataEntity
    current_read_value: ForensicDataEntity
    previous_read_date: ForensicDataEntity
    previous_read_value: ForensicDataEntity
    kwh_multiplier: ForensicDataEntity
    kwh_usage: ForensicDataEntity
    num_of_days: ForensicDataEntity
    usage_history: MeterUsageHistory

class CurrentActivity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    monthly_charge: ForensicDataEntity
    energy_usage: ForensicDataEntity
    heat_energy_usage: ForensicDataEntity
    heat_energy_credit: ForensicDataEntity
    capital_credit_refund: Optional[ForensicDataEntity] = None
    pscr_on_energy_use: ForensicDataEntity
    energy_optimization_surcharge: ForensicDataEntity
    state_sales_tax: ForensicDataEntity
    people_fund: ForensicDataEntity

class UtilityBillJudithGrandy(BaseModel):
    """
    A resilient Pydantic V2 schema for Judith Grandy's utility bills,
    accommodating structural variations over time.
    """
    model_config = ConfigDict(extra='forbid')

    account_number: ForensicDataEntity
    service_account_number: ForensicDataEntity
    billing_date: ForensicDataEntity
    customer_name: ForensicDataEntity
    service_address: ForensicDataEntity
    rate_class: ForensicDataEntity
    
    previous_balance: ForensicDataEntity
    payment_received: ForensicDataEntity
    account_balance_before_current_charges: ForensicDataEntity
    
    meters: List[MeterDetails]
    
    current_activity: CurrentActivity
    total_current_activity: ForensicDataEntity
    total_due: ForensicDataEntity
    
    mpsc_savings_estimate: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'UtilityBillJudithGrandy':
        """
        Performs double-entry GAAP mathematical checksums to ensure data integrity.
        """
        # Helper to safely extract float values
        def get_val(entity: Optional[ForensicDataEntity]) -> float:
            if entity is None or not isinstance(entity.extracted_string_or_numeric_value, (int, float)):
                return 0.0
            return float(entity.extracted_string_or_numeric_value)

        # 1. Previous Balance Check
        prev_bal = get_val(self.previous_balance)
        payment = get_val(self.payment_received)
        bal_before_charges = get_val(self.account_balance_before_current_charges)
        
        if not math.isclose(prev_bal - payment, bal_before_charges, rel_tol=1e-5):
            raise ValueError(
                f"Previous balance check failed: {prev_bal} - {payment} != {bal_before_charges}"
            )

        # 2. Current Activity Summation
        activity = self.current_activity
        calculated_activity_sum = sum([
            get_val(activity.monthly_charge),
            get_val(activity.energy_usage),
            get_val(activity.heat_energy_usage),
            get_val(activity.heat_energy_credit),
            get_val(activity.capital_credit_refund), # Handles None by returning 0.0
            get_val(activity.pscr_on_energy_use),
            get_val(activity.energy_optimization_surcharge),
            get_val(activity.state_sales_tax),
            get_val(activity.people_fund)
        ])
        total_activity = get_val(self.total_current_activity)

        if not math.isclose(calculated_activity_sum, total_activity, rel_tol=1e-5):
            raise ValueError(
                f"Current activity sum failed: Calculated {calculated_activity_sum} != Stated {total_activity}"
            )

        # 3. Total Due Check
        total_due = get_val(self.total_due)
        if not math.isclose(bal_before_charges + total_activity, total_due, rel_tol=1e-5):
            raise ValueError(
                f"Total due check failed: {bal_before_charges} + {total_activity} != {total_due}"
            )
            
        # 4. Meter Usage Check
        for meter in self.meters:
            current_read = get_val(meter.current_read_value)
            previous_read = get_val(meter.previous_read_value)
            multiplier = get_val(meter.kwh_multiplier)
            stated_usage = get_val(meter.kwh_usage)
            
            calculated_usage = (current_read - previous_read) * multiplier
            if not math.isclose(calculated_usage, stated_usage, rel_tol=1e-5):
                raise ValueError(
                    f"Meter {get_val(meter.meter_number)} usage check failed: "
                    f"({current_read} - {previous_read}) * {multiplier} = {calculated_usage} != Stated {stated_usage}"
                )

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "100074416_2010-12-10_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "UtilityBillJudithGrandy",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "100074416",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [622, 700], "vertical_y_vertices": [40, 52] }
      },
      "service_account_number": {
        "extracted_string_or_numeric_value": "100074416-002",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [652, 820], "vertical_y_vertices": [120, 132] }
      },
      "billing_date": {
        "extracted_string_or_numeric_value": "12/10/10",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [622, 680], "vertical_y_vertices": [20, 32] }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "JUDITH GRANDY",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [601, 730], "vertical_y_vertices": [60, 72] }
      },
      "service_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [120, 300], "vertical_y_vertices": [120, 132] }
      },
      "rate_class": {
        "extracted_string_or_numeric_value": "Residential - RES",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [715, 820], "vertical_y_vertices": [140, 152] }
      },
      "previous_balance": {
        "extracted_string_or_numeric_value": 158.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 820], "vertical_y_vertices": [170, 182] }
      },
      "payment_received": {
        "extracted_string_or_numeric_value": 158.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 820], "vertical_y_vertices": [185, 197] }
      },
      "account_balance_before_current_charges": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 820], "vertical_y_vertices": [200, 212] }
      },
      "meters": [
        {
          "meter_number": { "extracted_string_or_numeric_value": "30303620", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [120, 200], "vertical_y_vertices": [155, 167] } },
          "current_read_date": { "extracted_string_or_numeric_value": "12/08/10", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [170, 182] } },
          "current_read_value": { "extracted_string_or_numeric_value": 60271, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [170, 182] } },
          "previous_read_date": { "extracted_string_or_numeric_value": "11/08/10", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [185, 197] } },
          "previous_read_value": { "extracted_string_or_numeric_value": 59429, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [185, 197] } },
          "kwh_multiplier": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 310], "vertical_y_vertices": [200, 212] } },
          "kwh_usage": { "extracted_string_or_numeric_value": 842, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 325], "vertical_y_vertices": [215, 227] } },
          "num_of_days": { "extracted_string_or_numeric_value": 30, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 315], "vertical_y_vertices": [230, 242] } },
          "usage_history": {
            "meter_number": { "extracted_string_or_numeric_value": "30303620", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 300], "vertical_y_vertices": [355, 367] } },
            "monthly_kwh_usage": [
              { "extracted_string_or_numeric_value": 1235, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 170], "vertical_y_vertices": [380, 420] } },
              { "extracted_string_or_numeric_value": 994, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [170, 190], "vertical_y_vertices": [380, 420] } }
            ]
          }
        },
        {
          "meter_number": { "extracted_string_or_numeric_value": "30303624", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [120, 200], "vertical_y_vertices": [260, 272] } },
          "current_read_date": { "extracted_string_or_numeric_value": "12/08/10", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [275, 287] } },
          "current_read_value": { "extracted_string_or_numeric_value": 95048, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [275, 287] } },
          "previous_read_date": { "extracted_string_or_numeric_value": "11/08/10", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [290, 302] } },
          "previous_read_value": { "extracted_string_or_numeric_value": 93686, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [290, 302] } },
          "kwh_multiplier": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 310], "vertical_y_vertices": [305, 317] } },
          "kwh_usage": { "extracted_string_or_numeric_value": 1362, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 330], "vertical_y_vertices": [320, 332] } },
          "num_of_days": { "extracted_string_or_numeric_value": 30, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 315], "vertical_y_vertices": [335, 347] } },
          "usage_history": {
            "meter_number": { "extracted_string_or_numeric_value": "30303624", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 300], "vertical_y_vertices": [455, 467] } },
            "monthly_kwh_usage": [
              { "extracted_string_or_numeric_value": 2028, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 170], "vertical_y_vertices": [480, 520] } },
              { "extracted_string_or_numeric_value": 1706, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [170, 190], "vertical_y_vertices": [480, 520] } }
            ]
          }
        }
      ],
      "current_activity": {
        "monthly_charge": { "extracted_string_or_numeric_value": 12.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 820], "vertical_y_vertices": [240, 252] } },
        "energy_usage": { "extracted_string_or_numeric_value": 84.04, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 820], "vertical_y_vertices": [255, 267] } },
        "heat_energy_usage": { "extracted_string_or_numeric_value": 135.94, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [775, 820], "vertical_y_vertices": [270, 282] } },
        "heat_energy_credit": { "extracted_string_or_numeric_value": -40.86, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [770, 820], "vertical_y_vertices": [285, 297] } },
        "capital_credit_refund": { "extracted_string_or_numeric_value": -12.84, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [770, 820], "vertical_y_vertices": [300, 312] } },
        "pscr_on_energy_use": { "extracted_string_or_numeric_value": 21.62, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [780, 820], "vertical_y_vertices": [315, 327] } },
        "energy_optimization_surcharge": { "extracted_string_or_numeric_value": 3.48, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 820], "vertical_y_vertices": [330, 342] } },
        "state_sales_tax": { "extracted_string_or_numeric_value": 8.65, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 820], "vertical_y_vertices": [345, 357] } },
        "people_fund": { "extracted_string_or_numeric_value": 0.97, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 820], "vertical_y_vertices": [360, 372] } }
      },
      "total_current_activity": {
        "extracted_string_or_numeric_value": 213.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [775, 820], "vertical_y_vertices": [380, 392] }
      },
      "total_due": {
        "extracted_string_or_numeric_value": 213.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [775, 820], "vertical_y_vertices": [395, 407] }
      },
      "mpsc_savings_estimate": {
        "extracted_string_or_numeric_value": 2.92,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [120, 500], "vertical_y_vertices": [560, 580] }
      }
    }
  }
]
```