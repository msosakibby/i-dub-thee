An expert forensic data architect, I have analyzed the provided document, a 'UpromisebySallieMae - statement', and designed a resilient Pydantic V2 schema to capture its structure. The schema accounts for the distinct data sections, including summaries and a detailed interest calculation table, and incorporates a double-entry accounting validator to ensure financial integrity.

### BLOCK 1 (Python Pydantic V2)
```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of a detected entity on a document page."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single data entity, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class InterestChargeDetail(BaseModel):
    """Represents a single line item in the Interest Charge Calculation table."""
    model_config = ConfigDict(extra='forbid')
    type: ForensicDataEntity
    promotional_rate_end_date: Optional[ForensicDataEntity] = None
    balance_subject_to_interest_rate: ForensicDataEntity
    apr: ForensicDataEntity
    interest_charge: ForensicDataEntity

class UpromisebySallieMaeStatement(BaseModel):
    """
    Schema for a Upromise by Sallie Mae statement, focusing on fees and interest.
    """
    model_config = ConfigDict(extra='forbid')

    page_number: ForensicDataEntity
    total_pages: ForensicDataEntity
    total_interest_for_period: ForensicDataEntity
    ytd_total_fees_charged_year: ForensicDataEntity
    ytd_total_fees_charged_amount: ForensicDataEntity
    ytd_total_interest_charged_year: ForensicDataEntity
    ytd_total_interest_charged_amount: ForensicDataEntity
    billing_cycle_days: ForensicDataEntity
    interest_charge_details: List[InterestChargeDetail]
    total_interest_charge: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'UpromisebySallieMaeStatement':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        1. Verifies that the sum of individual interest charges equals the total interest charge.
        2. Verifies that the total interest charge matches the total interest for the period.
        """
        # Check 1: Sum of individual interest charges vs. total interest charge
        calculated_interest_sum = sum(
            float(item.interest_charge.extracted_string_or_numeric_value)
            for item in self.interest_charge_details
        )
        
        total_interest_charge = float(self.total_interest_charge.extracted_string_or_numeric_value)
        
        if not math.isclose(calculated_interest_sum, total_interest_charge, abs_tol=0.01):
            raise ValueError(
                f"Interest charge checksum failed: Sum of details ({calculated_interest_sum:.2f}) "
                f"does not match total ({total_interest_charge:.2f})."
            )

        # Check 2: Total interest charge vs. total interest for the period
        total_interest_for_period = float(self.total_interest_for_period.extracted_string_or_numeric_value)
        
        if not math.isclose(total_interest_charge, total_interest_for_period, abs_tol=0.01):
            raise ValueError(
                f"Period interest checksum failed: Calculation total ({total_interest_charge:.2f}) "
                f"does not match period total ({total_interest_for_period:.2f})."
            )
            
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "upromise_salliemae_page3_interest_summary_01",
    "should_pass": true,
    "taxonomy_lane": "UpromisebySallieMaeStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "page_number": {
        "extracted_string_or_numeric_value": 3,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [794.0, 800.0],
          "vertical_y_vertices": [31.0, 39.0]
        }
      },
      "total_pages": {
        "extracted_string_or_numeric_value": 6,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [810.0, 816.0],
          "vertical_y_vertices": [31.0, 39.0]
        }
      },
      "total_interest_for_period": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [795.0, 820.0],
          "vertical_y_vertices": [163.0, 172.0]
        }
      },
      "ytd_total_fees_charged_year": {
        "extracted_string_or_numeric_value": "2015",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [195.0, 225.0],
          "vertical_y_vertices": [217.0, 226.0]
        }
      },
      "ytd_total_fees_charged_amount": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [228.0, 253.0],
          "vertical_y_vertices": [217.0, 226.0]
        }
      },
      "ytd_total_interest_charged_year": {
        "extracted_string_or_numeric_value": "2015",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [570.0, 600.0],
          "vertical_y_vertices": [217.0, 226.0]
        }
      },
      "ytd_total_interest_charged_amount": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [795.0, 820.0],
          "vertical_y_vertices": [217.0, 226.0]
        }
      },
      "billing_cycle_days": {
        "extracted_string_or_numeric_value": 31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [475.0, 490.0],
          "vertical_y_vertices": [287.0, 297.0]
        }
      },
      "interest_charge_details": [
        {
          "type": {
            "extracted_string_or_numeric_value": "Current Purchases",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [363.0, 450.0],
              "vertical_y_vertices": [373.0, 381.0]
            }
          },
          "balance_subject_to_interest_rate": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 555.0],
              "vertical_y_vertices": [373.0, 381.0]
            }
          },
          "apr": {
            "extracted_string_or_numeric_value": "10.24% (v)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630.0, 685.0],
              "vertical_y_vertices": [373.0, 381.0]
            }
          },
          "interest_charge": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [795.0, 820.0],
              "vertical_y_vertices": [373.0, 381.0]
            }
          }
        },
        {
          "type": {
            "extracted_string_or_numeric_value": "Current Balance Transfers/Checks",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [363.0, 515.0],
              "vertical_y_vertices": [400.0, 408.0]
            }
          },
          "balance_subject_to_interest_rate": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 555.0],
              "vertical_y_vertices": [400.0, 408.0]
            }
          },
          "apr": {
            "extracted_string_or_numeric_value": "10.24% (v)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630.0, 685.0],
              "vertical_y_vertices": [400.0, 408.0]
            }
          },
          "interest_charge": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [795.0, 820.0],
              "vertical_y_vertices": [400.0, 408.0]
            }
          }
        },
        {
          "type": {
            "extracted_string_or_numeric_value": "Current Cash Advance",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [363.0, 465.0],
              "vertical_y_vertices": [427.0, 435.0]
            }
          },
          "balance_subject_to_interest_rate": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 555.0],
              "vertical_y_vertices": [427.0, 435.0]
            }
          },
          "apr": {
            "extracted_string_or_numeric_value": "19.24% (v)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630.0, 685.0],
              "vertical_y_vertices": [427.0, 435.0]
            }
          },
          "interest_charge": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [795.0, 820.0],
              "vertical_y_vertices": [427.0, 435.0]
            }
          }
        }
      ],
      "total_interest_charge": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [795.0, 820.0],
          "vertical_y_vertices": [454.0, 463.0]
        }
      }
    }
  }
]
```