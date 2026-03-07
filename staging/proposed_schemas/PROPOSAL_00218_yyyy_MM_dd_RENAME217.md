An expert forensic data architect, I will now construct the requested Pydantic V2 schema and a corresponding JSON test case based on the provided Chemical Bank statement. The second document, a HUD-1 form, is disregarded as it belongs to a different document class and contradicts the directive to analyze a single class with structural drift.

The schema is designed for resilience, capturing the hierarchical structure of the bank statement. It includes a rigorous double-entry accounting validator to ensure financial integrity, cross-referencing the summary totals with the sum of individual transactions.

***

### BLOCK 1 (Python Pydantic V2):
```python
import pydantic
from pydantic import BaseModel, Field, ConfigDict, model_validator
from typing import List, Optional, Union
from decimal import Decimal, ROUND_HALF_UP

# MANDATORY ForensicDataEntity and SpatialCoordinatesPolygon classes
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema for the Chemical Bank Statement
class BankInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    branch: ForensicDataEntity
    street: ForensicDataEntity
    city_state_zip: ForensicDataEntity
    phone: ForensicDataEntity

class RecipientInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name_line_1: ForensicDataEntity
    name_line_2: ForensicDataEntity
    street_address: ForensicDataEntity
    po_box: ForensicDataEntity
    city_state_zip: ForensicDataEntity

class StatementSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    deposits_credits_count: ForensicDataEntity
    deposits_credits_total: ForensicDataEntity
    debits_count: ForensicDataEntity
    debits_total: ForensicDataEntity
    current_balance: ForensicDataEntity
    days_in_period: ForensicDataEntity

class TransactionDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class ChemicalBankStatementV1(BaseModel):
    """
    A Pydantic V2 schema for extracting data from a Chemical Bank statement.
    """
    model_config = ConfigDict(extra='forbid')

    bank_info: BankInfo
    recipient_info: RecipientInfo
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    cycle: ForensicDataEntity
    beginning_rate: ForensicDataEntity
    summary: StatementSummary
    transactions: List[TransactionDetail]
    payer_federal_id: ForensicDataEntity
    interest_paid_ytd: ForensicDataEntity

    @model_validator(mode='after')
    def validate_financials(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        1. Validates that summary totals match the transaction roll-up.
        2. Validates that the opening and closing balances are consistent with totals.
        """
        # Use Decimal for precise financial calculations
        quantizer = Decimal('0.01')
        
        # Extract summary values
        summary = self.summary
        previous_balance = Decimal(str(summary.previous_balance.extracted_string_or_numeric_value)).quantize(quantizer, rounding=ROUND_HALF_UP)
        summary_credits = Decimal(str(summary.deposits_credits_total.extracted_string_or_numeric_value)).quantize(quantizer, rounding=ROUND_HALF_UP)
        summary_debits = Decimal(str(summary.debits_total.extracted_string_or_numeric_value)).quantize(quantizer, rounding=ROUND_HALF_UP)
        current_balance = Decimal(str(summary.current_balance.extracted_string_or_numeric_value)).quantize(quantizer, rounding=ROUND_HALF_UP)

        # 1. Transaction Roll-up Check: Sum individual transactions
        calculated_debits = Decimal('0.00')
        for txn in self.transactions:
            if txn.debit:
                calculated_debits += Decimal(str(txn.debit.extracted_string_or_numeric_value))

        calculated_credits = Decimal('0.00')
        for txn in self.transactions:
            if txn.credit:
                calculated_credits += Decimal(str(txn.credit.extracted_string_or_numeric_value))
        
        calculated_debits = calculated_debits.quantize(quantizer, rounding=ROUND_HALF_UP)
        calculated_credits = calculated_credits.quantize(quantizer, rounding=ROUND_HALF_UP)

        if calculated_debits != summary_debits:
            raise ValueError(f"Sum of transaction debits ({calculated_debits}) does not match summary debits total ({summary_debits}).")

        if calculated_credits != summary_credits:
            raise ValueError(f"Sum of transaction credits ({calculated_credits}) does not match summary credits total ({summary_credits}).")

        # 2. Summary Balance Check
        expected_current_balance = (previous_balance + summary_credits - summary_debits).quantize(quantizer, rounding=ROUND_HALF_UP)
        if expected_current_balance != current_balance:
            raise ValueError(f"Summary balance check failed. Expected {expected_current_balance}, but got {current_balance}.")

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "chemical_bank_statement_08-31-14",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_info": {
        "name": {
          "extracted_string_or_numeric_value": "CHEMICAL BANK",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 286],
            "vertical_y_vertices": [41, 52]
          }
        },
        "branch": {
          "extracted_string_or_numeric_value": "MCBAIN",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 210],
            "vertical_y_vertices": [56, 65]
          }
        },
        "street": {
          "extracted_string_or_numeric_value": "101 N ROLAND ST",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 286],
            "vertical_y_vertices": [70, 79]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "MC BAIN MI 49657",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 420],
            "vertical_y_vertices": [84, 93]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "231-825-2451",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 265],
            "vertical_y_vertices": [109, 118]
          }
        }
      },
      "recipient_info": {
        "name_line_1": {
          "extracted_string_or_numeric_value": "MAX R KIBBY TRUST AMENDED 5/2/93",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 438],
            "vertical_y_vertices": [138, 147]
          }
        },
        "name_line_2": {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY TRUSTEE",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 350],
            "vertical_y_vertices": [152, 161]
          }
        },
        "street_address": {
          "extracted_string_or_numeric_value": "3291 18 MILE RD",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 288],
            "vertical_y_vertices": [166, 175]
          }
        },
        "po_box": {
          "extracted_string_or_numeric_value": "PO BOX 297",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 245],
            "vertical_y_vertices": [180, 189]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "MARION MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 305],
            "vertical_y_vertices": [194, 203]
          }
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "08/31/14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 770],
          "vertical_y_vertices": [140, 149]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2140091121",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 770],
          "vertical_y_vertices": [182, 191]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "ADVANTAGE CHECKING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 350],
          "vertical_y_vertices": [238, 247]
        }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "049",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [740, 770],
          "vertical_y_vertices": [224, 233]
        }
      },
      "beginning_rate": {
        "extracted_string_or_numeric_value": 0.05000,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [725, 770],
          "vertical_y_vertices": [238, 247]
        }
      },
      "summary": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 4539.15,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [710, 770],
            "vertical_y_vertices": [257, 266]
          }
        },
        "deposits_credits_count": {
          "extracted_string_or_numeric_value": 3,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220, 225],
            "vertical_y_vertices": [271, 280]
          }
        },
        "deposits_credits_total": {
          "extracted_string_or_numeric_value": 4915.49,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [710, 770],
            "vertical_y_vertices": [271, 280]
          }
        },
        "debits_count": {
          "extracted_string_or_numeric_value": 1,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220, 225],
            "vertical_y_vertices": [285, 294]
          }
        },
        "debits_total": {
          "extracted_string_or_numeric_value": 4356.39,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [710, 770],
            "vertical_y_vertices": [285, 294]
          }
        },
        "current_balance": {
          "extracted_string_or_numeric_value": 5098.25,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [710, 770],
            "vertical_y_vertices": [299, 308]
          }
        },
        "days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 515],
            "vertical_y_vertices": [313, 322]
          }
        }
      },
      "transactions": [
        {
          "date": {
            "extracted_string_or_numeric_value": "08/18",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [365, 374]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR CKG X354 TO CKG X121#9146",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 460],
              "vertical_y_vertices": [365, 374]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 4356.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [520, 580],
              "vertical_y_vertices": [365, 374]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "08/21",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [379, 388]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR CKG X121 TO CKG X008#6164",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 460],
              "vertical_y_vertices": [379, 388]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 4356.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680],
              "vertical_y_vertices": [365, 374]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "08/27",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [393, 402]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 460],
              "vertical_y_vertices": [393, 402]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 558.89,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680],
              "vertical_y_vertices": [393, 402]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "08/31",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [407, 416]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "INTEREST PAYMENT",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 460],
              "vertical_y_vertices": [407, 416]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 0.21,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680],
              "vertical_y_vertices": [407, 416]
            }
          }
        }
      ],
      "payer_federal_id": {
        "extracted_string_or_numeric_value": "38-0415896",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [590, 670],
          "vertical_y_vertices": [465, 474]
        }
      },
      "interest_paid_ytd": {
        "extracted_string_or_numeric_value": 1.96,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [640, 670],
          "vertical_y_vertices": [479, 488]
        }
      }
    }
  }
]
```