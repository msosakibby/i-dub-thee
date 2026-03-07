An expert forensic data architect, I have analyzed the provided `2019-03-26 Farm Bureau Policy Change Declarations` document. The following Pydantic V2 schema is designed for maximum resilience, accommodating the document's structure and incorporating double-entry accounting principles for financial validation.

### BLOCK 1: Python Pydantic V2 Schema

```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

# BASE CLASSES (Do not modify)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# SCHEMA FOR '2019-03-26 Farm Bureau Policy Change Declarations'
class Address(BaseModel):
    model_config = ConfigDict(extra='forbid')
    line1: ForensicDataEntity
    city_state_zip: ForensicDataEntity

class Agent(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    phone_number: ForensicDataEntity
    address: Address

class PremiumImpact(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transaction_amount: ForensicDataEntity
    revised_policy_period_total: ForensicDataEntity

class VehicleInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    vehicle_number: ForensicDataEntity
    year: ForensicDataEntity
    make: ForensicDataEntity
    model: ForensicDataEntity
    vin: ForensicDataEntity
    vehicle_type: ForensicDataEntity
    garage_location: ForensicDataEntity

class DriverInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    driver_name: ForensicDataEntity
    driver_status: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    assignment: ForensicDataEntity
    vehicle_usage: ForensicDataEntity

class PolicyFormEndorsement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    form_number: ForensicDataEntity
    form_date: ForensicDataEntity
    description: ForensicDataEntity

class VehicleDiscount(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    applied_to_vehicles: ForensicDataEntity

class CoverageLimits(BaseModel):
    model_config = ConfigDict(extra='forbid')
    bodily_injury_liability_person: ForensicDataEntity
    bodily_injury_liability_accident: ForensicDataEntity
    property_damage_liability_accident: ForensicDataEntity
    funeral_expenses: ForensicDataEntity
    property_protection_ins_accident: ForensicDataEntity
    uninsured_underinsured_motorists_person: ForensicDataEntity
    uninsured_underinsured_motorists_accident: ForensicDataEntity
    comprehensive_deductible: ForensicDataEntity
    collision_deductible: ForensicDataEntity
    limited_prop_damage_liab: ForensicDataEntity

class VehicleCoveragePremiums(BaseModel):
    model_config = ConfigDict(extra='forbid')
    vehicle_number: ForensicDataEntity
    vehicle_description: ForensicDataEntity
    bodily_injury_liability: ForensicDataEntity
    property_damage_liability: ForensicDataEntity
    primary_medical: ForensicDataEntity
    excess_work_loss: ForensicDataEntity
    survivors_loss: ForensicDataEntity
    funeral_expenses: ForensicDataEntity
    property_protection_ins: ForensicDataEntity
    uninsured_underinsured_motorists: ForensicDataEntity
    comprehensive: ForensicDataEntity
    collision: Optional[ForensicDataEntity]
    emergency_road_service: ForensicDataEntity
    limited_prop_damage_liab: ForensicDataEntity
    mi_catastrophic_claims_assessment: ForensicDataEntity
    other_statutory_assessments: ForensicDataEntity
    vehicle_total: ForensicDataEntity

class FarmBureauPolicyChangeDeclarations(BaseModel):
    model_config = ConfigDict(extra='forbid')
    policy_number: ForensicDataEntity
    effective_date: ForensicDataEntity
    policy_period_start: ForensicDataEntity
    policy_period_end: ForensicDataEntity
    named_insureds: List[ForensicDataEntity]
    mailing_address: Address
    agent: Agent
    policy_premium_6_months: ForensicDataEntity
    payment_plan: ForensicDataEntity
    payment_method: ForensicDataEntity
    account_number: ForensicDataEntity
    billing_account_number: ForensicDataEntity
    premium_impact: PremiumImpact
    vehicles: List[VehicleInformation]
    drivers: List[DriverInformation]
    policy_forms_and_endorsements: List[PolicyFormEndorsement]
    policy_discounts: List[ForensicDataEntity]
    vehicle_discounts: List[VehicleDiscount]
    coverage_limits: CoverageLimits
    vehicle_coverages: List[VehicleCoveragePremiums]

    @model_validator(mode='after')
    def validate_financials(self) -> 'FarmBureauPolicyChangeDeclarations':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        1. Verifies that the sum of individual premiums for each vehicle equals its stated total.
        2. Verifies that the sum of all vehicle totals equals the total policy premium.
        """
        def get_numeric_value(entity: Optional[ForensicDataEntity]) -> float:
            if not entity or not hasattr(entity, 'extracted_string_or_numeric_value'):
                return 0.0
            value = entity.extracted_string_or_numeric_value
            return float(value) if isinstance(value, (int, float)) else 0.0

        # Checksum 1: Verify each vehicle's total premium
        calculated_grand_total = 0.0
        for vehicle_coverage in self.vehicle_coverages:
            calculated_vehicle_sum = (
                get_numeric_value(vehicle_coverage.bodily_injury_liability) +
                get_numeric_value(vehicle_coverage.property_damage_liability) +
                get_numeric_value(vehicle_coverage.primary_medical) +
                get_numeric_value(vehicle_coverage.excess_work_loss) +
                get_numeric_value(vehicle_coverage.property_protection_ins) +
                get_numeric_value(vehicle_coverage.uninsured_underinsured_motorists) +
                get_numeric_value(vehicle_coverage.comprehensive) +
                get_numeric_value(vehicle_coverage.collision) +
                get_numeric_value(vehicle_coverage.limited_prop_damage_liab) +
                get_numeric_value(vehicle_coverage.mi_catastrophic_claims_assessment) +
                get_numeric_value(vehicle_coverage.other_statutory_assessments)
            )
            
            vehicle_total_from_doc = get_numeric_value(vehicle_coverage.vehicle_total)
            
            if not math.isclose(calculated_vehicle_sum, vehicle_total_from_doc, abs_tol=0.01):
                raise ValueError(
                    f"Vehicle {vehicle_coverage.vehicle_number.extracted_string_or_numeric_value} total mismatch. "
                    f"Calculated: {calculated_vehicle_sum:.2f}, Document: {vehicle_total_from_doc:.2f}"
                )
            
            calculated_grand_total += vehicle_total_from_doc

        # Checksum 2: Verify the grand total against the policy premium
        policy_premium_from_doc = get_numeric_value(self.policy_premium_6_months)
        
        if not math.isclose(calculated_grand_total, policy_premium_from_doc, abs_tol=0.01):
            raise ValueError(
                f"Grand total premium mismatch. "
                f"Sum of vehicle totals: {calculated_grand_total:.2f}, "
                f"Policy Premium (6 months): {policy_premium_from_doc:.2f}"
            )
            
        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "20190326-farm-bureau-pa-10495253-golden-test",
    "should_pass": true,
    "taxonomy_lane": "FarmBureauPolicyChangeDeclarations",
    "binary_header_simulation": "25504446",
    "payload": {
      "policy_number": {
        "extracted_string_or_numeric_value": "PA-10495253",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [658, 753], "vertical_y_vertices": [105, 116] }
      },
      "effective_date": {
        "extracted_string_or_numeric_value": "March 26, 2019",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 263], "vertical_y_vertices": [105, 116] }
      },
      "policy_period_start": {
        "extracted_string_or_numeric_value": "10/25/2018",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 498], "vertical_y_vertices": [105, 116] }
      },
      "policy_period_end": {
        "extracted_string_or_numeric_value": "04/25/2019",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 498], "vertical_y_vertices": [105, 116] }
      },
      "named_insureds": [
        {
          "extracted_string_or_numeric_value": "KEITH GRANDY",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 270], "vertical_y_vertices": [165, 174] }
        },
        {
          "extracted_string_or_numeric_value": "JUDITH GRANDY",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 278], "vertical_y_vertices": [177, 186] }
        }
      ],
      "mailing_address": {
        "line1": {
          "extracted_string_or_numeric_value": "PO BOX 297",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 255], "vertical_y_vertices": [189, 198] }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "MARION Michigan 49665-0297",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 365], "vertical_y_vertices": [201, 210] }
        }
      },
      "agent": {
        "name": {
          "extracted_string_or_numeric_value": "DAN LEE",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 610], "vertical_y_vertices": [225, 234] }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-832-3283",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 620], "vertical_y_vertices": [261, 270] }
        },
        "address": {
          "line1": {
            "extracted_string_or_numeric_value": "850 S CHESTNUT ST",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 660], "vertical_y_vertices": [237, 246] }
          },
          "city_state_zip": {
            "extracted_string_or_numeric_value": "REED CITY MI 49677-8297",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690], "vertical_y_vertices": [249, 258] }
          }
        }
      },
      "policy_premium_6_months": {
        "extracted_string_or_numeric_value": 1001.85,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 720], "vertical_y_vertices": [141, 150] }
      },
      "payment_plan": {
        "extracted_string_or_numeric_value": "Full Pay",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [153, 162] }
      },
      "payment_method": {
        "extracted_string_or_numeric_value": "Manual",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 590], "vertical_y_vertices": [165, 174] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "1000150691",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 650], "vertical_y_vertices": [177, 186] }
      },
      "billing_account_number": {
        "extracted_string_or_numeric_value": "1000150691-01",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 680], "vertical_y_vertices": [189, 198] }
      },
      "premium_impact": {
        "transaction_amount": {
          "extracted_string_or_numeric_value": 14.15,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [320, 330] }
        },
        "revised_policy_period_total": {
          "extracted_string_or_numeric_value": 930.18,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [340, 350] }
        }
      },
      "vehicles": [
        {
          "vehicle_number": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 190], "vertical_y_vertices": [600, 610] } },
          "year": { "extracted_string_or_numeric_value": 1999, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 250], "vertical_y_vertices": [600, 610] } },
          "make": { "extracted_string_or_numeric_value": "CHEV", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 320], "vertical_y_vertices": [600, 610] } },
          "model": { "extracted_string_or_numeric_value": "TAHOE", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 400], "vertical_y_vertices": [600, 610] } },
          "vin": { "extracted_string_or_numeric_value": "1GNEK13R0XJ549032", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 680], "vertical_y_vertices": [600, 610] } },
          "vehicle_type": { "extracted_string_or_numeric_value": "Pickup/Jeep", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 780], "vertical_y_vertices": [600, 610] } },
          "garage_location": { "extracted_string_or_numeric_value": "3291 18 Mile Rd, MARION, MI 49665-0297", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 600], "vertical_y_vertices": [640, 650] } }
        },
        {
          "vehicle_number": { "extracted_string_or_numeric_value": 2, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 190], "vertical_y_vertices": [615, 625] } },
          "year": { "extracted_string_or_numeric_value": 2015, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 250], "vertical_y_vertices": [615, 625] } },
          "make": { "extracted_string_or_numeric_value": "GMC", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 310], "vertical_y_vertices": [615, 625] } },
          "model": { "extracted_string_or_numeric_value": "SIERRA", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 400], "vertical_y_vertices": [615, 625] } },
          "vin": { "extracted_string_or_numeric_value": "3GTU2VEC8FG398235", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 680], "vertical_y_vertices": [615, 625] } },
          "vehicle_type": { "extracted_string_or_numeric_value": "Pickup/Jeep", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 780], "vertical_y_vertices": [615, 625] } },
          "garage_location": { "extracted_string_or_numeric_value": "3291 18 Mile Rd, MARION, MI 49665-0297", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 600], "vertical_y_vertices": [655, 665] } }
        }
      ],
      "drivers": [
        {
          "driver_name": { "extracted_string_or_numeric_value": "JUDITH GRANDY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 280], "vertical_y_vertices": [720, 730] } },
          "driver_status": { "extracted_string_or_numeric_value": "Principal", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 240], "vertical_y_vertices": [740, 750] } },
          "date_of_birth": { "extracted_string_or_numeric_value": "08/18/1947", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 420], "vertical_y_vertices": [740, 750] } },
          "assignment": { "extracted_string_or_numeric_value": "Vehicle #1 Primary", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 600], "vertical_y_vertices": [740, 750] } },
          "vehicle_usage": { "extracted_string_or_numeric_value": "Pleasure", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [740, 750] } }
        },
        {
          "driver_name": { "extracted_string_or_numeric_value": "KEITH GRANDY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 270], "vertical_y_vertices": [790, 800] } },
          "driver_status": { "extracted_string_or_numeric_value": "Principal", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 240], "vertical_y_vertices": [810, 820] } },
          "date_of_birth": { "extracted_string_or_numeric_value": "07/21/1951", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 420], "vertical_y_vertices": [810, 820] } },
          "assignment": { "extracted_string_or_numeric_value": "Vehicle #2 Primary", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 600], "vertical_y_vertices": [810, 820] } },
          "vehicle_usage": { "extracted_string_or_numeric_value": "Pleasure", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [810, 820] } }
        }
      ],
      "policy_forms_and_endorsements": [
        {
          "form_number": { "extracted_string_or_numeric_value": "1352", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 240], "vertical_y_vertices": [150, 160] } },
          "form_date": { "extracted_string_or_numeric_value": "(07-17)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 300], "vertical_y_vertices": [150, 160] } },
          "description": { "extracted_string_or_numeric_value": "Underinsured Motorists Coverage Endorsement", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 680], "vertical_y_vertices": [150, 160] } }
        },
        {
          "form_number": { "extracted_string_or_numeric_value": "1147", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 240], "vertical_y_vertices": [165, 175] } },
          "form_date": { "extracted_string_or_numeric_value": "(01-03)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 300], "vertical_y_vertices": [165, 175] } },
          "description": { "extracted_string_or_numeric_value": "Limited Property Damage Liability Coverage Endorsement", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 720], "vertical_y_vertices": [165, 175] } }
        },
        {
          "form_number": { "extracted_string_or_numeric_value": "A5", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 225], "vertical_y_vertices": [180, 190] } },
          "form_date": { "extracted_string_or_numeric_value": "(07-17)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 300], "vertical_y_vertices": [180, 190] } },
          "description": { "extracted_string_or_numeric_value": "Personal Auto Policy", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 520], "vertical_y_vertices": [180, 190] } }
        },
        {
          "form_number": { "extracted_string_or_numeric_value": "637", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 235], "vertical_y_vertices": [195, 205] } },
          "form_date": { "extracted_string_or_numeric_value": "(01-11)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 300], "vertical_y_vertices": [195, 205] } },
          "description": { "extracted_string_or_numeric_value": "Broadened/Limited Collision Coverage Endorsement", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 700], "vertical_y_vertices": [195, 205] } }
        }
      ],
      "policy_discounts": [
        { "extracted_string_or_numeric_value": "FB Advantage (Insurance Score: 869)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 450], "vertical_y_vertices": [110, 120] } },
        { "extracted_string_or_numeric_value": "Multi-Policy (Policy that qualified you for this discount: Farmowners)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 650], "vertical_y_vertices": [125, 135] } },
        { "extracted_string_or_numeric_value": "SmartPay Discount", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 320], "vertical_y_vertices": [140, 150] } }
      ],
      "vehicle_discounts": [
        {
          "name": { "extracted_string_or_numeric_value": "Anti-Theft Device VATS or Passkey Device", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 450], "vertical_y_vertices": [180, 200] } },
          "applied_to_vehicles": { "extracted_string_or_numeric_value": "1, 2", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 540], "vertical_y_vertices": [180, 190] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Multi-Auto Discount", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 330], "vertical_y_vertices": [210, 220] } },
          "applied_to_vehicles": { "extracted_string_or_numeric_value": "1, 2", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 540], "vertical_y_vertices": [210, 220] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Select Customer Discount", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 360], "vertical_y_vertices": [225, 235] } },
          "applied_to_vehicles": { "extracted_string_or_numeric_value": "1, 2", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 540], "vertical_y_vertices": [225, 235] } }
        }
      ],
      "coverage_limits": {
        "bodily_injury_liability_person": { "extracted_string_or_numeric_value": 500000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 500], "vertical_y_vertices": [390, 400] } },
        "bodily_injury_liability_accident": { "extracted_string_or_numeric_value": 500000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 500], "vertical_y_vertices": [405, 415] } },
        "property_damage_liability_accident": { "extracted_string_or_numeric_value": 1000000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 500], "vertical_y_vertices": [430, 440] } },
        "funeral_expenses": { "extracted_string_or_numeric_value": "up to $3,000", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 460], "vertical_y_vertices": [520, 530] } },
        "property_protection_ins_accident": { "extracted_string_or_numeric_value": 1000000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 500], "vertical_y_vertices": [545, 555] } },
        "uninsured_underinsured_motorists_person": { "extracted_string_or_numeric_value": 500000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 500], "vertical_y_vertices": [580, 590] } },
        "uninsured_underinsured_motorists_accident": { "extracted_string_or_numeric_value": 500000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 500], "vertical_y_vertices": [595, 605] } },
        "comprehensive_deductible": { "extracted_string_or_numeric_value": "$ 100 Deductible", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 480], "vertical_y_vertices": [630, 640] } },
        "collision_deductible": { "extracted_string_or_numeric_value": "$ 500 Ded. Broadened", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 520], "vertical_y_vertices": [660, 670] } },
        "limited_prop_damage_liab": { "extracted_string_or_numeric_value": 1000, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 420], "vertical_y_vertices": [700, 710] } }
      },
      "vehicle_coverages": [
        {
          "vehicle_number": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 550], "vertical_y_vertices": [350, 360] } },
          "vehicle_description": { "extracted_string_or_numeric_value": "CHEV TAHOE", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 600], "vertical_y_vertices": [360, 380] } },
          "bodily_injury_liability": { "extracted_string_or_numeric_value": 45.98, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [405, 415] } },
          "property_damage_liability": { "extracted_string_or_numeric_value": 3.14, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [430, 440] } },
          "primary_medical": { "extracted_string_or_numeric_value": 122.41, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [470, 480] } },
          "excess_work_loss": { "extracted_string_or_numeric_value": 8.05, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [485, 495] } },
          "survivors_loss": { "extracted_string_or_numeric_value": "Included", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 590], "vertical_y_vertices": [500, 510] } },
          "funeral_expenses": { "extracted_string_or_numeric_value": "Included", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 590], "vertical_y_vertices": [520, 530] } },
          "property_protection_ins": { "extracted_string_or_numeric_value": 6.63, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [545, 555] } },
          "uninsured_underinsured_motorists": { "extracted_string_or_numeric_value": 20.26, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [595, 605] } },
          "comprehensive": { "extracted_string_or_numeric_value": 55.46, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [630, 640] } },
          "collision": null,
          "emergency_road_service": { "extracted_string_or_numeric_value": "Included", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 590], "vertical_y_vertices": [680, 690] } },
          "limited_prop_damage_liab": { "extracted_string_or_numeric_value": 2.19, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [700, 710] } },
          "mi_catastrophic_claims_assessment": { "extracted_string_or_numeric_value": 95.74, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [720, 730] } },
          "other_statutory_assessments": { "extracted_string_or_numeric_value": 1.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 580], "vertical_y_vertices": [735, 745] } },
          "vehicle_total": { "extracted_string_or_numeric_value": 361.36, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 590], "vertical_y_vertices": [760, 770] } }
        },
        {
          "vehicle_number": { "extracted_string_or_numeric_value": 2, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 660], "vertical_y_vertices": [350, 360] } },
          "vehicle_description": { "extracted_string_or_numeric_value": "GMC SIERRA", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 720], "vertical_y_vertices": [360, 380] } },
          "bodily_injury_liability": { "extracted_string_or_numeric_value": 34.61, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [405, 415] } },
          "property_damage_liability": { "extracted_string_or_numeric_value": 3.07, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [430, 440] } },
          "primary_medical": { "extracted_string_or_numeric_value": 95.04, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [470, 480] } },
          "excess_work_loss": { "extracted_string_or_numeric_value": 7.88, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [485, 495] } },
          "survivors_loss": { "extracted_string_or_numeric_value": "Included", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [500, 510] } },
          "funeral_expenses": { "extracted_string_or_numeric_value": "Included", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [520, 530] } },
          "property_protection_ins": { "extracted_string_or_numeric_value": 6.49, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [545, 555] } },
          "uninsured_underinsured_motorists": { "extracted_string_or_numeric_value": 20.26, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [595, 605] } },
          "comprehensive": { "extracted_string_or_numeric_value": 101.78, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [630, 640] } },
          "collision": { "extracted_string_or_numeric_value": 271.93, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [660, 670] } },
          "emergency_road_service": { "extracted_string_or_numeric_value": "Included", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [680, 690] } },
          "limited_prop_damage_liab": { "extracted_string_or_numeric_value": 2.19, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [700, 710] } },
          "mi_catastrophic_claims_assessment": { "extracted_string_or_numeric_value": 95.74, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [720, 730] } },
          "other_statutory_assessments": { "extracted_string_or_numeric_value": 1.50, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 690], "vertical_y_vertices": [735, 745] } },
          "vehicle_total": { "extracted_string_or_numeric_value": 640.49, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [760, 770] } }
        }
      ]
    }
  }
]
```