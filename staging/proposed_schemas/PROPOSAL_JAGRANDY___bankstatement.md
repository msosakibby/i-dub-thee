BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class ClearedCheck(BaseModel):
    """Represents a single cleared check from the bank statement."""
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    paid_date: ForensicDataEntity
    amount: ForensicDataEntity

class JAGRANDYBankStatement(BaseModel):
    """
    Schema for bank statements from Chemical Bank for J.A. Grandy.
    This schema accommodates multiple pages, including a summary page and a page with check images.
    """
    model_config = ConfigDict(extra='forbid')

    # Document metadata
    account_number: ForensicDataEntity
    statement_date: ForensicDataEntity

    # Bank and account holder info
    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: Optional[ForensicDataEntity] = None
    account_holders: List[ForensicDataEntity]
    mailing_address: ForensicDataEntity

    # Interest details (optional as they might not be on every statement type)
    interest_paid_ytd: Optional[ForensicDataEntity] = None
    interest_earned_period: Optional[ForensicDataEntity] = None
    apy_earned: Optional[ForensicDataEntity] = None
    days_in_period: Optional[ForensicDataEntity] = None

    # Financial details
    cleared_checks: List[ClearedCheck]
    # This field is for the checksum. It represents a summary value that may or may not be explicit on the document.
    total_cleared_checks_amount: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'JAGRANDYBankStatement':
        """
        Performs double-entry GAAP mathematical checksums.
        This validator verifies that the sum of individual cleared check amounts
        matches a provided total, if available.
        """
        if self.cleared_checks and self.total_cleared_checks_amount:
            # Sum of individual check amounts
            calculated_sum = sum(
                check.amount.extracted_string_or_numeric_value
                for check in self.cleared_checks
                if isinstance(check.amount.extracted_string_or_numeric_value, (int, float))
            )

            # The total from the document (or derived for validation)
            total_from_doc = self.total_cleared_checks_amount.extracted_string_or_numeric_value
            if not isinstance(total_from_doc, (int, float)):
                # If the total is not a number, we cannot validate.
                return self

            # Check if the calculated sum is close to the document's total (allowing for floating point inaccuracies)
            if not abs(calculated_sum - total_from_doc) < 0.01:
                raise ValueError(
                    f"Checksum failed: Sum of cleared checks ({calculated_sum:.2f}) "
                    f"does not match the total cleared checks amount ({total_from_doc:.2f})."
                )

        return self
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "jagrandy_statement_combined_pages",
    "should_pass": true,
    "taxonomy_lane": "JAGRANDYBankStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "2010277008",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [796, 897, 897, 796],
          "vertical_y_vertices": [179, 179, 191, 191]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "09/13/10",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [809, 897, 897, 809],
          "vertical_y_vertices": [129, 129, 140, 140]
        }
      },
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [154, 289, 289, 154],
          "vertical_y_vertices": [41, 41, 52, 52]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N. ROLAND MCBAIN, MI 49657",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [154, 320, 320, 154],
          "vertical_y_vertices": [69, 69, 92, 92]
        }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [260, 359, 359, 260],
          "vertical_y_vertices": [110, 110, 121, 121]
        }
      },
      "account_holders": [
        {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [222, 359, 359, 222],
            "vertical_y_vertices": [130, 130, 141, 141]
          }
        },
        {
          "extracted_string_or_numeric_value": "MARK W KIBBY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [222, 336, 336, 222],
            "vertical_y_vertices": [145, 145, 156, 156]
          }
        },
        {
          "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [222, 354, 354, 222],
            "vertical_y_vertices": [160, 160, 171, 171]
          }
        }
      ],
      "mailing_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD PO BOX 297 MARION MI 49665",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [222, 380, 380, 222],
          "vertical_y_vertices": [175, 175, 216, 216]
        }
      },
      "interest_paid_ytd": {
        "extracted_string_or_numeric_value": 58.47,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [698, 738, 738, 698],
          "vertical_y_vertices": [257, 257, 268, 268]
        }
      },
      "interest_earned_period": {
        "extracted_string_or_numeric_value": 4.28,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [706, 738, 738, 706],
          "vertical_y_vertices": [316, 316, 327, 327]
        }
      },
      "apy_earned": {
        "extracted_string_or_numeric_value": "0.15%",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [698, 738, 738, 698],
          "vertical_y_vertices": [331, 331, 342, 342]
        }
      },
      "days_in_period": {
        "extracted_string_or_numeric_value": 31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [714, 738, 738, 714],
          "vertical_y_vertices": [301, 301, 312, 312]
        }
      },
      "cleared_checks": [
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4049",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 210, 210, 160],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "08/18/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 280, 280, 220],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 380.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4052",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [590, 640, 640, 590],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "08/20/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710, 710, 650],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 28.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [730, 780, 780, 730],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4053",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 210, 210, 160],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "08/20/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 280, 280, 220],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 210.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4054",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [590, 640, 640, 590],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/03/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710, 710, 650],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 89.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [730, 780, 780, 730],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4056",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 210, 210, 160],
              "vertical_y_vertices": [450, 450, 460, 460]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/07/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 280, 280, 220],
              "vertical_y_vertices": [450, 450, 460, 460]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 178.14,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [450, 450, 460, 460]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4057",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [590, 640, 640, 590],
              "vertical_y_vertices": [450, 450, 460, 460]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/08/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710, 710, 650],
              "vertical_y_vertices": [450, 450, 460, 460]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 16.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [730, 780, 780, 730],
              "vertical_y_vertices": [450, 450, 460, 460]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "4059",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 210, 210, 160],
              "vertical_y_vertices": [290, 290, 300, 300]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/13/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220, 280, 280, 220],
              "vertical_y_vertices": [290, 290, 300, 300]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 195.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [290, 290, 300, 300]
            }
          }
        }
      ],
      "total_cleared_checks_amount": {
        "extracted_string_or_numeric_value": 1096.14,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [0, 0, 0, 0],
          "vertical_y_vertices": [0, 0, 0, 0]
        }
      }
    }
  }
]
```