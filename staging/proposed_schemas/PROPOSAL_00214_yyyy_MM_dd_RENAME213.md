BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of a detected entity on a document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class ClearedCheck(BaseModel):
    """Represents a single cleared check image and its associated metadata from a bank statement."""
    model_config = ConfigDict(extra='forbid')
    
    check_number: ForensicDataEntity
    paid_date: ForensicDataEntity
    paid_amount: ForensicDataEntity
    check_date: ForensicDataEntity
    check_amount_numeric: ForensicDataEntity
    payee_name: Optional[ForensicDataEntity] = None
    check_amount_written: Optional[ForensicDataEntity] = None
    signature: Optional[ForensicDataEntity] = None
    micr_line: Optional[ForensicDataEntity] = None

class ClearedChecksStatementV1(BaseModel):
    """
    Schema for a bank statement page containing images of cleared checks.
    The document class is '00214 yyyy-MM-dd_RENAME213'.
    """
    model_config = ConfigDict(extra='forbid')

    page_number: ForensicDataEntity
    account_number: ForensicDataEntity
    cleared_checks: List[ClearedCheck]

    @model_validator(mode='after')
    def validate_check_amounts(self) -> 'ClearedChecksStatementV1':
        """
        Performs a double-entry checksum for each check.
        It verifies that the amount written on the check matches the amount recorded as paid by the bank.
        """
        for check in self.cleared_checks:
            paid_amount = check.paid_amount.extracted_string_or_numeric_value
            check_amount = check.check_amount_numeric.extracted_string_or_numeric_value

            if not isinstance(paid_amount, (int, float)) or not isinstance(check_amount, (int, float)):
                raise ValueError(
                    f"Check #{check.check_number.extracted_string_or_numeric_value}: Amounts must be numeric for validation."
                )

            if paid_amount != check_amount:
                raise ValueError(
                    f"GAAP Checksum Failed for Check #{check.check_number.extracted_string_or_numeric_value}: "
                    f"Paid amount ({paid_amount}) does not match check amount ({check_amount})."
                )
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "00214_full_page_all_checks",
    "should_pass": true,
    "taxonomy_lane": "ClearedChecksStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "page_number": {
        "extracted_string_or_numeric_value": "2",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178, 260],
          "vertical_y_vertices": [41, 56]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "1024797",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178, 375],
          "vertical_y_vertices": [57, 71]
        }
      },
      "cleared_checks": [
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9972",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [425, 460],
              "vertical_y_vertices": [185, 198]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "01/29/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 375],
              "vertical_y_vertices": [290, 300]
            }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 1500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [430, 485],
              "vertical_y_vertices": [290, 300]
            }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "Jan 27, 2014",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 460],
              "vertical_y_vertices": [199, 212]
            }
          },
          "check_amount_numeric": {
            "extracted_string_or_numeric_value": 1500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [390, 460],
              "vertical_y_vertices": [215, 228]
            }
          },
          "payee_name": {
            "extracted_string_or_numeric_value": "Judith Grendy",
            "optical_extraction_confidence_score": 0.85,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 320],
              "vertical_y_vertices": [215, 228]
            }
          },
          "check_amount_written": {
            "extracted_string_or_numeric_value": "One thousand five hundred & 00/100",
            "optical_extraction_confidence_score": 0.88,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [180, 450],
              "vertical_y_vertices": [230, 245]
            }
          },
          "signature": {
            "extracted_string_or_numeric_value": "Judith Grendy",
            "optical_extraction_confidence_score": 0.82,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [320, 460],
              "vertical_y_vertices": [250, 265]
            }
          },
          "micr_line": {
            "extracted_string_or_numeric_value": "⑆072410013⑆ 0001024797⑈ 9972",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [180, 460],
              "vertical_y_vertices": [270, 285]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9973",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 835],
              "vertical_y_vertices": [185, 198]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "02/03/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [675, 750],
              "vertical_y_vertices": [290, 300]
            }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [805, 860],
              "vertical_y_vertices": [290, 300]
            }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "1-30 2014",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [725, 835],
              "vertical_y_vertices": [199, 212]
            }
          },
          "check_amount_numeric": {
            "extracted_string_or_numeric_value": 500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [765, 835],
              "vertical_y_vertices": [215, 228]
            }
          },
          "payee_name": {
            "extracted_string_or_numeric_value": "D. Merrifield",
            "optical_extraction_confidence_score": 0.86,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [575, 695],
              "vertical_y_vertices": [215, 228]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9975",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [425, 460],
              "vertical_y_vertices": [320, 333]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "02/12/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 375],
              "vertical_y_vertices": [425, 435]
            }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 1500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [430, 485],
              "vertical_y_vertices": [425, 435]
            }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "2-10 2014",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 460],
              "vertical_y_vertices": [334, 347]
            }
          },
          "check_amount_numeric": {
            "extracted_string_or_numeric_value": 1500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [390, 460],
              "vertical_y_vertices": [350, 363]
            }
          },
          "signature": {
            "extracted_string_or_numeric_value": "Keith Grendy",
            "optical_extraction_confidence_score": 0.81,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [320, 460],
              "vertical_y_vertices": [385, 400]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9976",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 835],
              "vertical_y_vertices": [320, 333]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "02/12/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [675, 750],
              "vertical_y_vertices": [425, 435]
            }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 200.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [805, 860],
              "vertical_y_vertices": [425, 435]
            }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "Feb. 12, 2014",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [725, 835],
              "vertical_y_vertices": [334, 347]
            }
          },
          "check_amount_numeric": {
            "extracted_string_or_numeric_value": 200.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [765, 835],
              "vertical_y_vertices": [350, 363]
            }
          },
          "payee_name": {
            "extracted_string_or_numeric_value": "Judith Grendy",
            "optical_extraction_confidence_score": 0.84,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [575, 695],
              "vertical_y_vertices": [350, 363]
            }
          }
        }
      ]
    }
  }
]
```