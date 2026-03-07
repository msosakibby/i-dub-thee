BLOCK 1 (Python Pydantic V2):
```python
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError
from typing import List, Union, Optional, Dict
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

class AgentDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: ForensicDataEntity

class VehicleDiscount(BaseModel):
    model_config = ConfigDict(extra='forbid')
    discount_name: ForensicDataEntity
    applied_to_vehicle_numbers: List[ForensicDataEntity]

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
    name: ForensicDataEntity
    driver_status: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    assignment: ForensicDataEntity
    vehicle_usage: ForensicDataEntity

class PremiumForVehicle(BaseModel):
    model_config = ConfigDict(extra='forbid')
    vehicle_number: int
    premium: ForensicDataEntity

class CoverageRow(BaseModel):
    model_config = ConfigDict(extra='forbid')
    coverage_name: ForensicDataEntity
    details: Optional[ForensicDataEntity] = None
    limits: Optional[ForensicDataEntity] = None
    premiums: List[PremiumForVehicle]

class CoverageInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    mandatory_coverages: List[CoverageRow]
    optional_coverages: List[CoverageRow]
    other_charges: List[CoverageRow]
    vehicle_totals: List[PremiumForVehicle]

class FarmBureauInsurancePolicy(BaseModel):
    """
    A resilient schema for Farm Bureau Personal Auto Policy Renewal Declarations.
    """
    model_config = ConfigDict(extra='forbid')

    policy_number: ForensicDataEntity
    account_number: ForensicDataEntity
    policy_period_start: ForensicDataEntity
    policy_period_end: ForensicDataEntity
    policy_premium: ForensicDataEntity
    payment_plan: ForensicDataEntity
    payment_method: ForensicDataEntity
    named_insureds: List[ForensicDataEntity]
    mailing_address: ForensicDataEntity
    agent_details: AgentDetails
    date_issued: ForensicDataEntity
    policy_discounts: List[ForensicDataEntity]
    vehicle_discounts: List[VehicleDiscount]
    vehicles: List[VehicleInformation]
    drivers: List[DriverInformation]
    coverage_information: CoverageInformation

    @model_validator(mode='after')
    def double_entry_gaap_checksum(self) -> 'FarmBureauInsurancePolicy':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        1. Verifies that the sum of individual premiums for each vehicle equals its stated total.
        2. Verifies that the sum of all vehicle totals equals the overall policy premium.
        """
        
        # Helper to safely extract numeric values
        def to_float(entity: ForensicDataEntity) -> float:
            val = entity.extracted_string_or_numeric_value
            if isinstance(val, (int, float)):
                return float(val)
            if isinstance(val, str):
                try:
                    return float(val)
                except (ValueError, TypeError):
                    return 0.0
            return 0.0

        # 1. Sum individual premiums for each vehicle
        calculated_vehicle_totals: Dict[int, float] = {}
        all_coverage_rows = (
            self.coverage_information.mandatory_coverages +
            self.coverage_information.optional_coverages +
            self.coverage_information.other_charges
        )

        for row in all_coverage_rows:
            for premium_entry in row.premiums:
                vehicle_num = premium_entry.vehicle_number
                if vehicle_num not in calculated_vehicle_totals:
                    calculated_vehicle_totals[vehicle_num] = 0.0
                
                premium_val = to_float(premium_entry.premium)
                calculated_vehicle_totals[vehicle_num] += premium_val

        # 2. Compare calculated sums with stated vehicle totals
        stated_vehicle_totals: Dict[int, float] = {
            vt.vehicle_number: to_float(vt.premium) for vt in self.coverage_information.vehicle_totals
        }

        if set(calculated_vehicle_totals.keys()) != set(stated_vehicle_totals.keys()):
            raise ValueError("Mismatch between vehicles in coverage rows and vehicle totals section.")

        for vehicle_num, calculated_total in calculated_vehicle_totals.items():
            stated_total = stated_vehicle_totals[vehicle_num]
            if not math.isclose(calculated_total, stated_total, rel_tol=1e-2):
                raise ValueError(
                    f"Checksum failed for Vehicle #{vehicle_num}: "
                    f"Sum of premiums ({calculated_total:.2f}) does not match VEHICLE TOTAL ({stated_total:.2f})."
                )

        # 3. Sum stated vehicle totals and compare with the overall policy premium
        calculated_policy_premium = sum(stated_vehicle_totals.values())
        stated_policy_premium = to_float(self.policy_premium)

        if not math.isclose(calculated_policy_premium, stated_policy_premium, rel_tol=1e-2):
            raise ValueError(
                f"Policy premium checksum failed: "
                f"Sum of vehicle totals ({calculated_policy_premium:.2f}) does not match "
                f"Policy Premium ({stated_policy_premium:.2f})."
            )

        return self
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "policy_2018_PA-10495253_full_declaration",
    "should_pass": true,
    "taxonomy_lane": "FarmBureauInsurancePolicy",
    "binary_header_simulation": "25504446",
    "payload": {
      "policy_number": {
        "extracted_string_or_numeric_value": "PA-10495253",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [689, 768],
          "vertical_y_vertices": [118, 128]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "1000150691",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [689, 768],
          "vertical_y_vertices": [188, 198]
        }
      },
      "policy_period_start": {
        "extracted_string_or_numeric_value": "04/25/2018",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [365, 550],
          "vertical_y_vertices": [118, 128]
        }
      },
      "policy_period_end": {
        "extracted_string_or_numeric_value": "10/25/2018",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [365, 550],
          "vertical_y_vertices": [118, 128]
        }
      },
      "policy_premium": {
        "extracted_string_or_numeric_value": 870.31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [689, 800],
          "vertical_y_vertices": [148, 158]
        }
      },
      "payment_plan": {
        "extracted_string_or_numeric_value": "Full Pay",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [689, 750],
          "vertical_y_vertices": [158, 168]
        }
      },
      "payment_method": {
        "extracted_string_or_numeric_value": "Manual",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [689, 740],
          "vertical_y_vertices": [168, 178]
        }
      },
      "named_insureds": [
        {
          "extracted_string_or_numeric_value": "KEITH GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 275],
            "vertical_y_vertices": [175, 185]
          }
        },
        {
          "extracted_string_or_numeric_value": "JUDITH GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 280],
            "vertical_y_vertices": [185, 195]
          }
        }
      ],
      "mailing_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION Michigan 49665-0297",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [175, 380],
          "vertical_y_vertices": [195, 220]
        }
      },
      "agent_details": {
        "name": {
          "extracted_string_or_numeric_value": "DAN LEE",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [689, 750],
            "vertical_y_vertices": [208, 218]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "850 S CHESTNUT ST\nREED CITY MI 49677-8297",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [689, 850],
            "vertical_y_vertices": [218, 238]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "231-832-3283",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [689, 770],
            "vertical_y_vertices": [238, 248]
          }
        }
      },
      "date_issued": {
        "extracted_string_or_numeric_value": "March 8, 2018 01:15 p.m.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [175, 350],
          "vertical_y_vertices": [955, 965]
        }
      },
      "policy_discounts": [
        {
          "extracted_string_or_numeric_value": "FB Advantage (Insurance Score: 869)",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 450],
            "vertical_y_vertices": [130, 140]
          }
        },
        {
          "extracted_string_or_numeric_value": "Multi-Policy (Policy that qualified you for this discount: Farmowner)",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 650],
            "vertical_y_vertices": [140, 150]
          }
        },
        {
          "extracted_string_or_numeric_value": "SmartPay Discount",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [175, 300],
            "vertical_y_vertices": [150, 160]
          }
        }
      ],
      "vehicle_discounts": [
        {
          "discount_name": {
            "extracted_string_or_numeric_value": "Anti-Theft Device",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [205, 300],
              "vertical_y_vertices": [210, 220]
            }
          },
          "applied_to_vehicle_numbers": [
            {
              "extracted_string_or_numeric_value": "1, 2",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [520, 540],
                "vertical_y_vertices": [210, 220]
              }
            }
          ]
        },
        {
          "discount_name": {
            "extracted_string_or_numeric_value": "Multi-Auto Discount",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [205, 320],
              "vertical_y_vertices": [240, 250]
            }
          },
          "applied_to_vehicle_numbers": [
            {
              "extracted_string_or_numeric_value": "1, 2",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [520, 540],
                "vertical_y_vertices": [240, 250]
              }
            }
          ]
        },
        {
          "discount_name": {
            "extracted_string_or_numeric_value": "Select Customer Discount",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [205, 350],
              "vertical_y_vertices": [250, 260]
            }
          },
          "applied_to_vehicle_numbers": [
            {
              "extracted_string_or_numeric_value": "1, 2",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [520, 540],
                "vertical_y_vertices": [250, 260]
              }
            }
          ]
        }
      ],
      "vehicles": [
        {
          "vehicle_number": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 185],
              "vertical_y_vertices": [650, 660]
            }
          },
          "year": {
            "extracted_string_or_numeric_value": "1999",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 250],
              "vertical_y_vertices": [650, 660]
            }
          },
          "make": {
            "extracted_string_or_numeric_value": "CHEV",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 340],
              "vertical_y_vertices": [650, 660]
            }
          },
          "model": {
            "extracted_string_or_numeric_value": "TAHOE",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [400, 450],
              "vertical_y_vertices": [650, 660]
            }
          },
          "vin": {
            "extracted_string_or_numeric_value": "1GNEK13R0XJ549032",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 700],
              "vertical_y_vertices": [650, 660]
            }
          },
          "vehicle_type": {
            "extracted_string_or_numeric_value": "Pickup/Jeep",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [750, 830],
              "vertical_y_vertices": [650, 660]
            }
          },
          "garage_location": {
            "extracted_string_or_numeric_value": "3291 18 Mile Rd, MARION, MI 49665-0297",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [390, 650],
              "vertical_y_vertices": [690, 700]
            }
          }
        },
        {
          "vehicle_number": {
            "extracted_string_or_numeric_value": 2,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 185],
              "vertical_y_vertices": [660, 670]
            }
          },
          "year": {
            "extracted_string_or_numeric_value": "2015",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 250],
              "vertical_y_vertices": [660, 670]
            }
          },
          "make": {
            "extracted_string_or_numeric_value": "GMC",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 330],
              "vertical_y_vertices": [660, 670]
            }
          },
          "model": {
            "extracted_string_or_numeric_value": "SIERRA",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [400, 450],
              "vertical_y_vertices": [660, 670]
            }
          },
          "vin": {
            "extracted_string_or_numeric_value": "3GTU2VEC8FG398235",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 700],
              "vertical_y_vertices": [660, 670]
            }
          },
          "vehicle_type": {
            "extracted_string_or_numeric_value": "Pickup/Jeep",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [750, 830],
              "vertical_y_vertices": [660, 670]
            }
          },
          "garage_location": {
            "extracted_string_or_numeric_value": "3291 18 Mile Rd, MARION, MI 49665-0297",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [390, 650],
              "vertical_y_vertices": [700, 710]
            }
          }
        }
      ],
      "drivers": [
        {
          "name": {
            "extracted_string_or_numeric_value": "KEITH GRANDY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 280],
              "vertical_y_vertices": [750, 760]
            }
          },
          "driver_status": {
            "extracted_string_or_numeric_value": "Principal",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 230],
              "vertical_y_vertices": [760, 770]
            }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "07/21/1951",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 420],
              "vertical_y_vertices": [760, 770]
            }
          },
          "assignment": {
            "extracted_string_or_numeric_value": "Vehicle #2 Primary",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [480, 600],
              "vertical_y_vertices": [760, 770]
            }
          },
          "vehicle_usage": {
            "extracted_string_or_numeric_value": "Pleasure",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [680, 740],
              "vertical_y_vertices": [760, 770]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "JUDITH GRANDY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 280],
              "vertical_y_vertices": [810, 820]
            }
          },
          "driver_status": {
            "extracted_string_or_numeric_value": "Principal",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 230],
              "vertical_y_vertices": [820, 830]
            }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "08/18/1947",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 420],
              "vertical_y_vertices": [820, 830]
            }
          },
          "assignment": {
            "extracted_string_or_numeric_value": "Vehicle #1 Primary",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [480, 600],
              "vertical_y_vertices": [820, 830]
            }
          },
          "vehicle_usage": {
            "extracted_string_or_numeric_value": "Pleasure",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [680, 740],
              "vertical_y_vertices": [820, 830]
            }
          }
        }
      ],
      "coverage_information": {
        "mandatory_coverages": [
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Bodily Injury Liability",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 350],
                "vertical_y_vertices": [430, 440]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "500,000 Each Person/500,000 Each Accident",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 550],
                "vertical_y_vertices": [440, 460]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 40.85,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [450, 460]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 33.57,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [450, 460]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Property Damage Liability",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 360],
                "vertical_y_vertices": [470, 480]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "1,000,000 Each Accident",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 520],
                "vertical_y_vertices": [470, 480]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 2.89,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [470, 480]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 2.89,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [470, 480]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Personal Injury Protection",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 360],
                "vertical_y_vertices": [490, 500]
              }
            },
            "details": {
              "extracted_string_or_numeric_value": "Excess Medical",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [220, 310],
                "vertical_y_vertices": [510, 520]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 70.00,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [510, 520]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 57.76,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [510, 520]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Personal Injury Protection",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 360],
                "vertical_y_vertices": [490, 500]
              }
            },
            "details": {
              "extracted_string_or_numeric_value": "Excess Work Loss",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [220, 320],
                "vertical_y_vertices": [520, 530]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 7.70,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [520, 530]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 7.70,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [520, 530]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Personal Injury Protection",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 360],
                "vertical_y_vertices": [490, 500]
              }
            },
            "details": {
              "extracted_string_or_numeric_value": "Survivors' Loss",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [220, 320],
                "vertical_y_vertices": [530, 540]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": "Included",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 610],
                    "vertical_y_vertices": [530, 540]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": "Included",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 680],
                    "vertical_y_vertices": [530, 540]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Personal Injury Protection",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 360],
                "vertical_y_vertices": [490, 500]
              }
            },
            "details": {
              "extracted_string_or_numeric_value": "Funeral Expenses",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [220, 320],
                "vertical_y_vertices": [540, 550]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "up to $3,000",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [410, 480],
                "vertical_y_vertices": [540, 550]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": "Included",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 610],
                    "vertical_y_vertices": [540, 550]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": "Included",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 680],
                    "vertical_y_vertices": [540, 550]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Property Protection Ins.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 350],
                "vertical_y_vertices": [570, 580]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "1,000,000 Each Accident",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 520],
                "vertical_y_vertices": [570, 580]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 6.17,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [570, 580]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 6.17,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [570, 580]
                  }
                }
              }
            ]
          }
        ],
        "optional_coverages": [
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Uninsured/Underinsured Motorists",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 400],
                "vertical_y_vertices": [610, 630]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "500,000 Each Person/500,000 Each Accident",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 550],
                "vertical_y_vertices": [610, 630]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 19.78,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [620, 630]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 19.78,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [620, 630]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Comprehensive",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 300],
                "vertical_y_vertices": [640, 650]
              }
            },
            "details": {
              "extracted_string_or_numeric_value": "Actual Cash Value",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [220, 320],
                "vertical_y_vertices": [660, 670]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "$ 100 Deductible",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [410, 500],
                "vertical_y_vertices": [660, 670]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 53.11,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [660, 670]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 94.22,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [660, 670]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Collision",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 260],
                "vertical_y_vertices": [680, 690]
              }
            },
            "details": {
              "extracted_string_or_numeric_value": "Actual Cash Value",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [220, 320],
                "vertical_y_vertices": [700, 710]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "$ 500 Ded. Broadened",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [410, 520],
                "vertical_y_vertices": [700, 710]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": "--",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [700, 710]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 270.48,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [700, 710]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Emergency Road Service",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 360],
                "vertical_y_vertices": [720, 730]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": "Included",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 610],
                    "vertical_y_vertices": [720, 730]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": "Included",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 680],
                    "vertical_y_vertices": [720, 730]
                  }
                }
              }
            ]
          }
        ],
        "other_charges": [
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Limited Prop. Damage Liab.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 380],
                "vertical_y_vertices": [740, 750]
              }
            },
            "limits": {
              "extracted_string_or_numeric_value": "1,000",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [410, 450],
                "vertical_y_vertices": [740, 750]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 2.09,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [740, 750]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 2.09,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [740, 750]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "MI Catastrophic Claims Assoc. Statutory Assessment",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 550],
                "vertical_y_vertices": [760, 770]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 85.23,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [760, 770]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 85.23,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [760, 770]
                  }
                }
              }
            ]
          },
          {
            "coverage_name": {
              "extracted_string_or_numeric_value": "Other Statutory Assessments",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [205, 380],
                "vertical_y_vertices": [780, 790]
              }
            },
            "premiums": [
              {
                "vehicle_number": 1,
                "premium": {
                  "extracted_string_or_numeric_value": 1.30,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [560, 600],
                    "vertical_y_vertices": [780, 790]
                  }
                }
              },
              {
                "vehicle_number": 2,
                "premium": {
                  "extracted_string_or_numeric_value": 1.30,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [630, 670],
                    "vertical_y_vertices": [780, 790]
                  }
                }
              }
            ]
          }
        ],
        "vehicle_totals": [
          {
            "vehicle_number": 1,
            "premium": {
              "extracted_string_or_numeric_value": 289.12,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [560, 610],
                "vertical_y_vertices": [800, 810]
              }
            }
          },
          {
            "vehicle_number": 2,
            "premium": {
              "extracted_string_or_numeric_value": 581.19,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [630, 680],
                "vertical_y_vertices": [800, 810]
              }
            }
          }
        ]
      }
    }
  }
]
```