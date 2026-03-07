An expert forensic data architect operating under a Zero-Trust mandate, I have meticulously analyzed the provided `MICHIGANFARMBUREAU - billingstatement` document. My analysis reveals a hierarchical structure where a single policy account contains details for distinct policy periods, each with its own set of financial activities and a subtotal. The grand total is a summation of these period-specific subtotals.

To ensure maximum resilience and accuracy, the Pydantic V2 schema below models this hierarchy precisely. It includes two levels of GAAP-compliant mathematical validators: one at the policy period level to verify activity sums, and another at the main document level to verify the grand total. This layered validation strategy ensures data integrity at every stage of extraction and processing.

The accompanying JSON test case represents the most complex variant identified—the provided document itself—and is structured to pass all validations, confirming the schema's correctness and robustness.

### BLOCK 1 (Python Pydantic V2)
```python
import math
from decimal import Decimal, InvalidOperation
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

# ----------------------------------------------------------------------------
# MANDATORY FORENSIC WRAPPER CLASSES
# ----------------------------------------------------------------------------

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of a detected entity on a document page."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """
    A wrapper for a single data point extracted from a document, including its
    value, confidence, and location.
    """
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# ----------------------------------------------------------------------------
# DOCUMENT-SPECIFIC SCHEMA
# ----------------------------------------------------------------------------

class ActivityItem(BaseModel):
    """Represents a single line item of financial activity."""
    model_config = ConfigDict(extra='forbid')
    effective_date: ForensicDataEntity
    activity_description: ForensicDataEntity
    amount: ForensicDataEntity

class PolicyPeriodDetail(BaseModel):
    """Details for a specific policy period, including all financial activities."""
    model_config = ConfigDict(extra='forbid')
    named_insured: ForensicDataEntity
    policy_period: ForensicDataEntity
    activities: List[ActivityItem]
    period_current_amount_due: ForensicDataEntity

    @model_validator(mode='after')
    def validate_period_amounts(self) -> 'PolicyPeriodDetail':
        """
        Ensures the sum of all activity amounts equals the period's current amount due.
        """
        try:
            activities_sum = sum(
                Decimal(str(activity.amount.extracted_string_or_numeric_value))
                for activity in self.activities
            )
            period_due = Decimal(str(self.period_current_amount_due.extracted_string_or_numeric_value))
        except (InvalidOperation, TypeError) as e:
            raise ValueError(f"Invalid numeric value for amount calculation in PolicyPeriodDetail: {e}")

        if not math.isclose(activities_sum, period_due, rel_tol=1e-4):
            raise ValueError(
                f"Sum of activities ({activities_sum}) does not match the period current amount due ({period_due})."
            )
        return self

class MichiganfarmbureauBillingstatement(BaseModel):
    """
    Represents the root schema for a Michigan Farm Bureau Billing Statement.
    """
    model_config = ConfigDict(extra='forbid')
    billing_account_number: ForensicDataEntity
    page_info: ForensicDataEntity
    policy_number: ForensicDataEntity
    payment_plan: ForensicDataEntity
    period_details: List[PolicyPeriodDetail]
    total_current_amount_due: ForensicDataEntity

    @model_validator(mode='after')
    def validate_total_amounts(self) -> 'MichiganfarmbureauBillingstatement':
        """
        Ensures the sum of all policy period amounts equals the total current amount due.
        """
        try:
            periods_due_sum = sum(
                Decimal(str(detail.period_current_amount_due.extracted_string_or_numeric_value))
                for detail in self.period_details
            )
            total_due = Decimal(str(self.total_current_amount_due.extracted_string_or_numeric_value))
        except (InvalidOperation, TypeError) as e:
            raise ValueError(f"Invalid numeric value for total amount calculation: {e}")

        if not math.isclose(periods_due_sum, total_due, rel_tol=1e-4):
            raise ValueError(
                f"Sum of period amounts due ({periods_due_sum}) does not match the total current amount due ({total_due})."
            )
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "billing_statement_complex_multi_period_001",
    "should_pass": true,
    "taxonomy_lane": "MichiganfarmbureauBillingstatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "billing_account_number": {
        "extracted_string_or_numeric_value": "1000 1506 91-01",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 850],
          "vertical_y_vertices": [60, 75]
        }
      },
      "page_info": {
        "extracted_string_or_numeric_value": "PAGE 3 of 3",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850],
          "vertical_y_vertices": [40, 55]
        }
      },
      "policy_number": {
        "extracted_string_or_numeric_value": "PA-10495253",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 280],
          "vertical_y_vertices": [170, 185]
        }
      },
      "payment_plan": {
        "extracted_string_or_numeric_value": "Full Pay",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [615, 665],
          "vertical_y_vertices": [170, 185]
        }
      },
      "period_details": [
        {
          "named_insured": {
            "extracted_string_or_numeric_value": "KEITH GRANDY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [185, 285],
              "vertical_y_vertices": [200, 215]
            }
          },
          "policy_period": {
            "extracted_string_or_numeric_value": "10/25/2018 to 04/25/2019",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [185, 340],
              "vertical_y_vertices": [225, 240]
            }
          },
          "activities": [
            {
              "effective_date": {
                "extracted_string_or_numeric_value": "03/26/2019",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [185, 245],
                  "vertical_y_vertices": [255, 270]
                }
              },
              "activity_description": {
                "extracted_string_or_numeric_value": "Policy Change",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [300, 380],
                  "vertical_y_vertices": [255, 270]
                }
              },
              "amount": {
                "extracted_string_or_numeric_value": 14.15,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [440, 480],
                  "vertical_y_vertices": [255, 270]
                }
              }
            }
          ],
          "period_current_amount_due": {
            "extracted_string_or_numeric_value": 14.15,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [660, 820],
              "vertical_y_vertices": [275, 295]
            }
          }
        },
        {
          "named_insured": {
            "extracted_string_or_numeric_value": "KEITH GRANDY",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [185, 285],
              "vertical_y_vertices": [305, 320]
            }
          },
          "policy_period": {
            "extracted_string_or_numeric_value": "04/25/2019 to 10/25/2019",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [185, 340],
              "vertical_y_vertices": [325, 340]
            }
          },
          "activities": [
            {
              "effective_date": {
                "extracted_string_or_numeric_value": "04/25/2019",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [185, 245],
                  "vertical_y_vertices": [360, 375]
                }
              },
              "activity_description": {
                "extracted_string_or_numeric_value": "Policy Change",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [300, 380],
                  "vertical_y_vertices": [360, 375]
                }
              },
              "amount": {
                "extracted_string_or_numeric_value": 86.60,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [440, 480],
                  "vertical_y_vertices": [360, 375]
                }
              }
            },
            {
              "effective_date": {
                "extracted_string_or_numeric_value": "04/25/2019",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [185, 245],
                  "vertical_y_vertices": [375, 390]
                }
              },
              "activity_description": {
                "extracted_string_or_numeric_value": "Renewal",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [300, 350],
                  "vertical_y_vertices": [375, 390]
                }
              },
              "amount": {
                "extracted_string_or_numeric_value": 964.66,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [440, 490],
                  "vertical_y_vertices": [375, 390]
                }
              }
            }
          ],
          "period_current_amount_due": {
            "extracted_string_or_numeric_value": 1051.26,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [660, 820],
              "vertical_y_vertices": [395, 415]
            }
          }
        }
      ],
      "total_current_amount_due": {
        "extracted_string_or_numeric_value": 1065.41,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [660, 820],
          "vertical_y_vertices": [445, 465]
        }
      }
    }
  }
]
```