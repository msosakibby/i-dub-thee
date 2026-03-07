An analysis of the provided documents reveals a collection of disparate tax-related materials, including W-2s, 1099s, donation receipts, and IRS correspondence, rather than variations of a single document class. The most structurally complex and suitable candidate for creating a resilient schema is the multi-page IRS Notice CP-2000, which details proposed changes to the recipient's 2002 tax return. This notice contains nested tables, multiple financial figures, and references to external payer information, making it an ideal subject for a robust Pydantic model with mathematical validation.

The following schema is designed to capture the hierarchical data within the IRS Notice CP-2000, with a `model_validator` that performs a GAAP-style checksum on the proposed tax computation.

```python
import math
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# DO NOT MODIFY THIS CLASS
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

# DO NOT MODIFY THIS CLASS
class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class TaxComputationLine(BaseModel):
    """Represents a single line item in the tax computation table with three columns."""
    model_config = ConfigDict(extra='forbid')
    shown_on_return: Optional[ForensicDataEntity] = None
    reported_to_irs: Optional[ForensicDataEntity] = None
    proposed_change: Optional[ForensicDataEntity] = None

class TaxComputationTable(BaseModel):
    """Models the 'Our Proposed Changes To Your Tax Computation' table."""
    model_config = ConfigDict(extra='forbid')
    taxable_income: TaxComputationLine
    tax: TaxComputationLine
    total_tax: TaxComputationLine
    income_tax_withheld: TaxComputationLine
    interest: ForensicDataEntity
    proposed_amount_you_owe_irs: ForensicDataEntity
    net_tax_decrease: Optional[TaxComputationLine] = None

class PayerInformation(BaseModel):
    """Models the payer information used by the IRS to determine the tax proposal."""
    model_config = ConfigDict(extra='forbid')
    payer_name: ForensicDataEntity
    payer_ein: ForensicDataEntity
    taxable_wages: ForensicDataEntity
    tax_withheld: ForensicDataEntity
    social_security_withheld: ForensicDataEntity
    social_security_wages: ForensicDataEntity
    deferred_compensation: ForensicDataEntity
    medicare_tax_withheld: ForensicDataEntity
    medicare_wages_and_tips: ForensicDataEntity

class IrsNoticeCp2000(BaseModel):
    """
    A resilient schema for an IRS Notice CP-2000, which proposes changes to a tax return.
    This document is the most complex structural variant in the provided set.
    """
    model_config = ConfigDict(extra='forbid')

    recipient_name: ForensicDataEntity
    recipient_address: ForensicDataEntity
    recipient_ssn: ForensicDataEntity
    notice_number: ForensicDataEntity
    notice_date: ForensicDataEntity
    aur_control_number: ForensicDataEntity
    tax_year: ForensicDataEntity
    tax_computation: TaxComputationTable
    payer_info: List[PayerInformation]

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'IrsNoticeCp2000':
        """
        Validates the core calculation in the tax computation table.
        The amount owed is the sum of the principal (the absolute value of the
        negative change in tax withheld) and the interest charged.
        """
        withheld_change_entity = self.tax_computation.income_tax_withheld.proposed_change
        interest_entity = self.tax_computation.interest
        proposed_due_entity = self.tax_computation.proposed_amount_you_owe_irs

        if not all([withheld_change_entity, interest_entity, proposed_due_entity]):
            # Not enough data to perform the check, so we pass.
            return self

        withheld_change = withheld_change_entity.extracted_string_or_numeric_value
        interest = interest_entity.extracted_string_or_numeric_value
        proposed_due = proposed_due_entity.extracted_string_or_numeric_value

        if not all(isinstance(v, (int, float)) for v in [withheld_change, interest, proposed_due]):
            raise ValueError("Checksum validation requires numeric values for withheld change, interest, and proposed due amount.")

        # The change in withholding is negative, meaning less was withheld than claimed.
        # This negative change amount is the principal of the debt.
        # abs(withheld_change) + interest = proposed_due
        calculated_due = abs(float(withheld_change)) + float(interest)

        if not math.isclose(calculated_due, float(proposed_due), rel_tol=0.01):
            raise ValueError(
                f"GAAP checksum failed. The sum of the absolute value of the withholding change ({abs(float(withheld_change))}) "
                f"and interest ({float(interest)}) should be {calculated_due}, but the proposed amount due is {float(proposed_due)}."
            )

        return self

```

```json
[
  {
    "test_identifier": "IRS_CP2000_Notice_50053-4279",
    "should_pass": true,
    "taxonomy_lane": "IrsNoticeCp2000",
    "binary_header_simulation": "25504446",
    "payload": {
      "recipient_name": {
        "extracted_string_or_numeric_value": "MARK W KIBBY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 318, 318, 188],
          "vertical_y_vertices": [229, 229, 240, 240]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "4618 N RACINE APT 7 CHICAGO IL 60640-4974992",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 400, 400, 188],
          "vertical_y_vertices": [241, 241, 263, 263]
        }
      },
      "recipient_ssn": {
        "extracted_string_or_numeric_value": "366-72-9323",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608, 700, 700, 608],
          "vertical_y_vertices": [108, 108, 118, 118]
        }
      },
      "notice_number": {
        "extracted_string_or_numeric_value": "CP-2000",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [598, 675, 675, 598],
          "vertical_y_vertices": [84, 84, 94, 94]
        }
      },
      "notice_date": {
        "extracted_string_or_numeric_value": "09/07/2004",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [598, 685, 685, 598],
          "vertical_y_vertices": [96, 96, 106, 106]
        }
      },
      "aur_control_number": {
        "extracted_string_or_numeric_value": "50053-4279",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [598, 700, 700, 598],
          "vertical_y_vertices": [59, 59, 70, 70]
        }
      },
      "tax_year": {
        "extracted_string_or_numeric_value": "2002",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608, 645, 645, 608],
          "vertical_y_vertices": [120, 120, 130, 130]
        }
      },
      "tax_computation": {
        "taxable_income": {
          "shown_on_return": {
            "extracted_string_or_numeric_value": 95730.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [430, 510], "vertical_y_vertices": [310, 320]}
          },
          "reported_to_irs": {
            "extracted_string_or_numeric_value": 95730.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [610, 690], "vertical_y_vertices": [310, 320]}
          },
          "proposed_change": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [800, 850], "vertical_y_vertices": [310, 320]}
          }
        },
        "tax": {
          "shown_on_return": {
            "extracted_string_or_numeric_value": 23033.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [430, 510], "vertical_y_vertices": [321, 331]}
          },
          "reported_to_irs": {
            "extracted_string_or_numeric_value": 23033.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [610, 690], "vertical_y_vertices": [321, 331]}
          },
          "proposed_change": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [800, 850], "vertical_y_vertices": [321, 331]}
          }
        },
        "total_tax": {
          "shown_on_return": {
            "extracted_string_or_numeric_value": 23033.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [430, 510], "vertical_y_vertices": [332, 342]}
          },
          "reported_to_irs": {
            "extracted_string_or_numeric_value": 23033.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [610, 690], "vertical_y_vertices": [332, 342]}
          },
          "proposed_change": {
            "extracted_string_or_numeric_value": 0.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [800, 850], "vertical_y_vertices": [332, 342]}
          }
        },
        "income_tax_withheld": {
          "shown_on_return": {
            "extracted_string_or_numeric_value": 26470.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [430, 510], "vertical_y_vertices": [354, 364]}
          },
          "reported_to_irs": {
            "extracted_string_or_numeric_value": 21082.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [610, 690], "vertical_y_vertices": [354, 364]}
          },
          "proposed_change": {
            "extracted_string_or_numeric_value": -5388.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [800, 850], "vertical_y_vertices": [354, 364]}
          }
        },
        "interest": {
          "extracted_string_or_numeric_value": 369.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {"horizontal_x_vertices": [800, 850], "vertical_y_vertices": [376, 386]}
        },
        "proposed_amount_you_owe_irs": {
          "extracted_string_or_numeric_value": 5757.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {"horizontal_x_vertices": [800, 850], "vertical_y_vertices": [408, 418]}
        }
      },
      "payer_info": [
        {
          "payer_name": {
            "extracted_string_or_numeric_value": "DIAMONDCLUSTER INTERNATIONAL NORTH",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 420], "vertical_y_vertices": [80, 90]}
          },
          "payer_ein": {
            "extracted_string_or_numeric_value": "36-4069586",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 250], "vertical_y_vertices": [135, 145]}
          },
          "taxable_wages": {
            "extracted_string_or_numeric_value": 107759.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [80, 90]}
          },
          "tax_withheld": {
            "extracted_string_or_numeric_value": 21082.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [91, 101]}
          },
          "social_security_withheld": {
            "extracted_string_or_numeric_value": 5263.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [102, 112]}
          },
          "social_security_wages": {
            "extracted_string_or_numeric_value": 84900.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [113, 123]}
          },
          "deferred_compensation": {
            "extracted_string_or_numeric_value": 2288.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [124, 134]}
          },
          "medicare_tax_withheld": {
            "extracted_string_or_numeric_value": 1595.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [135, 145]}
          },
          "medicare_wages_and_tips": {
            "extracted_string_or_numeric_value": 110048.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {"horizontal_x_vertices": [750, 820], "vertical_y_vertices": [146, 156]}
          }
        }
      ]
    }
  }
]
```