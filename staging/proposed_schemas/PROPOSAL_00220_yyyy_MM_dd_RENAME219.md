BLOCK 1 (Python Pydantic V2):
```python
from decimal import Decimal, ROUND_HALF_UP
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

class StatementSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    previous_statement_date: ForensicDataEntity
    deposits_credits_count: ForensicDataEntity
    deposits_credits_amount: ForensicDataEntity
    checks_debits_count: ForensicDataEntity
    checks_debits_amount: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    current_statement_date: ForensicDataEntity
    statement_period_days: ForensicDataEntity

class CheckTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity

class OtherTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class DailyBalance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class ChemicalBankStatementV1(BaseModel):
    """
    Represents a business checking statement from Chemical Bank.
    """
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: ForensicDataEntity
    customer_name: ForensicDataEntity
    customer_address: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    cycle: Optional[ForensicDataEntity] = None
    account_type: ForensicDataEntity
    summary: StatementSummary
    check_transactions: List[CheckTransaction]
    other_transactions: List[OtherTransaction]
    daily_balances: Optional[List[DailyBalance]] = None

    @model_validator(mode='after')
    def gaap_double_entry_checksum(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to validate financial integrity.
        1. Verifies that the sum of individual credit transactions equals the summary total.
        2. Verifies that the sum of individual debit transactions equals the summary total.
        3. Verifies that the opening balance plus credits minus debits equals the closing balance.
        """
        tolerance = Decimal('0.01')
        
        # Helper to convert ForensicDataEntity to Decimal
        def to_decimal(entity: ForensicDataEntity) -> Decimal:
            val = entity.extracted_string_or_numeric_value
            return Decimal(str(val)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)

        # 1. Sum individual credits
        calculated_credits = Decimal('0.00')
        for tx in self.other_transactions:
            if tx.credit:
                calculated_credits += to_decimal(tx.credit)
        
        summary_credits = to_decimal(self.summary.deposits_credits_amount)
        if abs(calculated_credits - summary_credits) > tolerance:
            raise ValueError(
                f"Credit checksum failed: Sum of individual credits ({calculated_credits}) "
                f"does not match summary total ({summary_credits})."
            )

        # 2. Sum individual debits
        calculated_debits = Decimal('0.00')
        for tx in self.check_transactions:
            calculated_debits += to_decimal(tx.amount)
        for tx in self.other_transactions:
            if tx.debit:
                calculated_debits += to_decimal(tx.debit)

        summary_debits = to_decimal(self.summary.checks_debits_amount)
        if abs(calculated_debits - summary_debits) > tolerance:
            raise ValueError(
                f"Debit checksum failed: Sum of individual debits ({calculated_debits}) "
                f"does not match summary total ({summary_debits})."
            )

        # 3. Verify closing balance
        previous_balance = to_decimal(self.summary.previous_statement_balance)
        current_balance = to_decimal(self.summary.current_statement_balance)
        
        expected_balance = previous_balance + summary_credits - summary_debits
        
        if abs(current_balance - expected_balance) > tolerance:
            raise ValueError(
                f"Balance checksum failed: Calculated closing balance ({expected_balance}) "
                f"does not match summary current balance ({current_balance})."
            )
            
        return self
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "00220_2014-09-30_RENAME219_001",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [118, 250],
          "vertical_y_vertices": [541, 552]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N ROLAND ST MC BAIN MI 49657",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [118, 250],
          "vertical_y_vertices": [562, 583]
        }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [118, 250],
          "vertical_y_vertices": [593, 602]
        }
      },
      "customer_name": {
        "extracted_string_or_numeric_value": "KIBBY COMPANY LLC",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [338, 498],
          "vertical_y_vertices": [552, 561]
        }
      },
      "customer_address": {
        "extracted_string_or_numeric_value": "PO BOX 297 MARION MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [338, 498],
          "vertical_y_vertices": [562, 582]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "09/30/14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [889, 954],
          "vertical_y_vertices": [340, 349]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2551029354",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [889, 954],
          "vertical_y_vertices": [370, 379]
        }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "029",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [924, 954],
          "vertical_y_vertices": [400, 409]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "CHECKING *** BUSINESS CHECKING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [118, 438],
          "vertical_y_vertices": [430, 439]
        }
      },
      "summary": {
        "previous_statement_balance": {
          "extracted_string_or_numeric_value": 2515.72,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [897, 954],
            "vertical_y_vertices": [450, 459]
          }
        },
        "previous_statement_date": {
          "extracted_string_or_numeric_value": "08/31/14",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [530, 587],
            "vertical_y_vertices": [450, 459]
          }
        },
        "deposits_credits_count": {
          "extracted_string_or_numeric_value": 2,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 187],
            "vertical_y_vertices": [470, 479]
          }
        },
        "deposits_credits_amount": {
          "extracted_string_or_numeric_value": 10352.45,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [889, 954],
            "vertical_y_vertices": [470, 479]
          }
        },
        "checks_debits_count": {
          "extracted_string_or_numeric_value": 6,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 187],
            "vertical_y_vertices": [480, 489]
          }
        },
        "checks_debits_amount": {
          "extracted_string_or_numeric_value": 11797.21,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [889, 954],
            "vertical_y_vertices": [480, 489]
          }
        },
        "current_statement_balance": {
          "extracted_string_or_numeric_value": 1070.96,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [897, 954],
            "vertical_y_vertices": [490, 499]
          }
        },
        "current_statement_date": {
          "extracted_string_or_numeric_value": "09/30/14",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [530, 587],
            "vertical_y_vertices": [490, 499]
          }
        },
        "statement_period_days": {
          "extracted_string_or_numeric_value": 30,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 515],
            "vertical_y_vertices": [520, 529]
          }
        }
      },
      "check_transactions": [
        {
          "check_number": {
            "extracted_string_or_numeric_value": "1001",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [630, 639]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "09/18",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 235],
              "vertical_y_vertices": [630, 639]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 2735.86,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 360],
              "vertical_y_vertices": [630, 639]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "1002",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [640, 649]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "09/17",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 235],
              "vertical_y_vertices": [640, 649]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 207.56,
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 360],
              "vertical_y_vertices": [640, 649]
            }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "1003",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [400, 430],
              "vertical_y_vertices": [630, 639]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "09/18",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 485],
              "vertical_y_vertices": [630, 639]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 134.59,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 560],
              "vertical_y_vertices": [630, 639]
            }
          }
        }
      ],
      "other_transactions": [
        {
          "date": {
            "extracted_string_or_numeric_value": "09/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [690, 699]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-SPARTAN STORES-ACCTSPYBLE",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 450],
              "vertical_y_vertices": [690, 699]
            }
          },
          "debit": null,
          "credit": {
            "extracted_string_or_numeric_value": 8712.78,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 860],
              "vertical_y_vertices": [690, 699]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/03",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [700, 709]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR CKG X354 TO CKG X008#6443",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 450],
              "vertical_y_vertices": [700, 709]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 4356.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710],
              "vertical_y_vertices": [700, 709]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/03",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [710, 719]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR CKG X354 TO CKG X121#6471",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 450],
              "vertical_y_vertices": [710, 719]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 4356.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710],
              "vertical_y_vertices": [710, 719]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/04",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [720, 729]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 450],
              "vertical_y_vertices": [720, 729]
            }
          },
          "debit": null,
          "credit": {
            "extracted_string_or_numeric_value": 1639.67,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 860],
              "vertical_y_vertices": [720, 729]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/30",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 150],
              "vertical_y_vertices": [730, 739]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "SERVICE CHG SEP ACTIVITY",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 450],
              "vertical_y_vertices": [730, 739]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 6.42,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710],
              "vertical_y_vertices": [730, 739]
            }
          },
          "credit": null
        }
      ],
      "daily_balances": [
        {
          "date": {
            "extracted_string_or_numeric_value": "08/31",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 158],
              "vertical_y_vertices": [780, 789]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 2515.72,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 220],
              "vertical_y_vertices": [780, 789]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 280],
              "vertical_y_vertices": [780, 789]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 3947.83,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [282, 342],
              "vertical_y_vertices": [780, 789]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/18",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [360, 400],
              "vertical_y_vertices": [780, 789]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 1077.38,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [402, 462],
              "vertical_y_vertices": [780, 789]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/03",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [480, 520],
              "vertical_y_vertices": [780, 789]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 11228.50,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [522, 582],
              "vertical_y_vertices": [780, 789]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/30",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 640],
              "vertical_y_vertices": [780, 789]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 1070.96,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [642, 702],
              "vertical_y_vertices": [780, 789]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/04",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [840, 880],
              "vertical_y_vertices": [780, 789]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 4155.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [882, 942],
              "vertical_y_vertices": [780, 789]
            }
          }
        }
      ]
    }
  }
]
```