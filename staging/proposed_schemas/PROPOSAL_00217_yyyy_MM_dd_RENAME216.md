An expert forensic data architect, I have analyzed the provided document under a Zero-Trust mandate. The following Pydantic V2 schema is designed for maximum resilience, accommodating the structural realities of the document class `00217 yyyy-MM-dd_RENAME216`. The schema includes a GAAP-compliant mathematical validator to ensure financial integrity.

### BLOCK 1 (Python Pydantic V2)
```python
import math
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


class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    previous_statement_date: ForensicDataEntity
    total_deposits_and_credits: ForensicDataEntity
    total_checks_and_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    current_statement_date: ForensicDataEntity
    number_of_days: ForensicDataEntity
    beginning_rate: Optional[ForensicDataEntity] = None
    cycle: Optional[ForensicDataEntity] = None


class Transaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None


class DailyBalance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity


class RecipientInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_holder: ForensicDataEntity
    trustee: Optional[ForensicDataEntity] = None
    address_lines: List[ForensicDataEntity]


class ChemicalBankStatementV1(BaseModel):
    """
    A Pydantic V2 schema for parsing Chemical Bank statements.
    This schema is designed to be resilient to structural variations and includes
    double-entry GAAP mathematical checksums for financial validation.
    """
    model_config = ConfigDict(extra='forbid')

    bank_name: ForensicDataEntity
    bank_address: ForensicDataEntity
    bank_phone: ForensicDataEntity
    recipient_info: RecipientInfo
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    account_summary: AccountSummary
    transactions: List[Transaction]
    balance_by_date: Optional[List[DailyBalance]] = None
    payer_federal_id: Optional[ForensicDataEntity] = None
    interest_paid_ytd: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'ChemicalBankStatementV1':
        """
        Executes double-entry GAAP mathematical checksums.
        1. Validates: Previous Balance + Credits - Debits = Current Balance.
        2. Validates: Sum of individual transaction debits/credits matches summary totals.
        """
        summary = self.account_summary
        prev_balance = float(summary.previous_statement_balance.extracted_string_or_numeric_value)
        total_credits_summary = float(summary.total_deposits_and_credits.extracted_string_or_numeric_value)
        total_debits_summary = float(summary.total_checks_and_debits.extracted_string_or_numeric_value)
        current_balance = float(summary.current_statement_balance.extracted_string_or_numeric_value)

        # Check 1: Summary balance calculation
        calculated_balance = prev_balance + total_credits_summary - total_debits_summary
        if not math.isclose(calculated_balance, current_balance, rel_tol=1e-5):
            raise ValueError(
                f"Summary balance mismatch: "
                f"Previous({prev_balance}) + Credits({total_credits_summary}) - Debits({total_debits_summary}) = {calculated_balance}, "
                f"but Current Balance is {current_balance}."
            )

        # Check 2: Transaction totals vs. summary totals
        calculated_total_debits_trans = sum(
            float(t.debit.extracted_string_or_numeric_value) for t in self.transactions if t.debit
        )
        calculated_total_credits_trans = sum(
            float(t.credit.extracted_string_or_numeric_value) for t in self.transactions if t.credit
        )

        if not math.isclose(calculated_total_debits_trans, total_debits_summary, rel_tol=1e-5):
            raise ValueError(
                f"Transaction debits sum mismatch: "
                f"Sum of transaction debits is {calculated_total_debits_trans}, "
                f"but summary total is {total_debits_summary}."
            )

        if not math.isclose(calculated_total_credits_trans, total_credits_summary, rel_tol=1e-5):
            raise ValueError(
                f"Transaction credits sum mismatch: "
                f"Sum of transaction credits is {calculated_total_credits_trans}, "
                f"but summary total is {total_credits_summary}."
            )

        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "chemical_bank_20140930_2140091121_complex",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "bank_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 251],
          "vertical_y_vertices": [43, 52]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "101 N ROLAND ST MC BAIN MI 49657",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 251],
          "vertical_y_vertices": [72, 91]
        }
      },
      "bank_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [169, 249],
          "vertical_y_vertices": [101, 109]
        }
      },
      "recipient_info": {
        "account_holder": {
          "extracted_string_or_numeric_value": "MAX R KIBBY TRUST AMENDED 5/2/93",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 420],
            "vertical_y_vertices": [133, 141]
          }
        },
        "trustee": {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY TRUSTEE",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [161, 320],
            "vertical_y_vertices": [148, 156]
          }
        },
        "address_lines": [
          {
            "extracted_string_or_numeric_value": "3291 18 MILE RD",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 315],
              "vertical_y_vertices": [162, 170]
            }
          },
          {
            "extracted_string_or_numeric_value": "PO BOX 297",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 290],
              "vertical_y_vertices": [177, 185]
            }
          },
          {
            "extracted_string_or_numeric_value": "MARION MI 49665",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 325],
              "vertical_y_vertices": [192, 200]
            }
          }
        ]
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "09/30/14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [725, 793],
          "vertical_y_vertices": [148, 156]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2140091121",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [725, 793],
          "vertical_y_vertices": [183, 191]
        }
      },
      "account_summary": {
        "previous_statement_balance": {
          "extracted_string_or_numeric_value": 5098.25,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [740, 793],
            "vertical_y_vertices": [257, 265]
          }
        },
        "previous_statement_date": {
          "extracted_string_or_numeric_value": "08/31/14",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [410, 465],
            "vertical_y_vertices": [257, 265]
          }
        },
        "total_deposits_and_credits": {
          "extracted_string_or_numeric_value": 5115.51,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [740, 793],
            "vertical_y_vertices": [272, 280]
          }
        },
        "total_checks_and_debits": {
          "extracted_string_or_numeric_value": 4356.39,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [740, 793],
            "vertical_y_vertices": [287, 295]
          }
        },
        "current_statement_balance": {
          "extracted_string_or_numeric_value": 5857.37,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [740, 793],
            "vertical_y_vertices": [302, 310]
          }
        },
        "current_statement_date": {
          "extracted_string_or_numeric_value": "09/30/14",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [410, 465],
            "vertical_y_vertices": [302, 310]
          }
        },
        "number_of_days": {
          "extracted_string_or_numeric_value": 30,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [505, 520],
            "vertical_y_vertices": [317, 325]
          }
        },
        "beginning_rate": {
          "extracted_string_or_numeric_value": 0.05000,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [740, 793],
            "vertical_y_vertices": [234, 242]
          }
        },
        "cycle": {
          "extracted_string_or_numeric_value": "049",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [765, 793],
            "vertical_y_vertices": [220, 228]
          }
        }
      },
      "transactions": [
        {
          "date": {
            "extracted_string_or_numeric_value": "09/03",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 190],
              "vertical_y_vertices": [362, 370]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR CKG X354 TO CKG X121#6471",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 420],
              "vertical_y_vertices": [362, 370]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 4356.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 700],
              "vertical_y_vertices": [362, 370]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/04",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 190],
              "vertical_y_vertices": [377, 385]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 270],
              "vertical_y_vertices": [377, 385]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 200.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 700],
              "vertical_y_vertices": [377, 385]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/05",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 190],
              "vertical_y_vertices": [392, 400]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR CKG X121 TO CKG X008#3312",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 420],
              "vertical_y_vertices": [392, 400]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 4356.39,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [525, 575],
              "vertical_y_vertices": [392, 400]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/23",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 190],
              "vertical_y_vertices": [407, 415]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 270],
              "vertical_y_vertices": [407, 415]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 558.89,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 700],
              "vertical_y_vertices": [407, 415]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/30",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 190],
              "vertical_y_vertices": [422, 430]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "INTEREST PAYMENT",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 330],
              "vertical_y_vertices": [422, 430]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 0.23,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 700],
              "vertical_y_vertices": [422, 430]
            }
          }
        }
      ],
      "balance_by_date": [
        {
          "date": {
            "extracted_string_or_numeric_value": "08/31",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 190],
              "vertical_y_vertices": [452, 460]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 5098.25,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 250],
              "vertical_y_vertices": [452, 460]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "09/30",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 330],
              "vertical_y_vertices": [467, 475]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 5857.37,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [340, 390],
              "vertical_y_vertices": [467, 475]
            }
          }
        }
      ],
      "payer_federal_id": {
        "extracted_string_or_numeric_value": "38-0415896",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [630, 700],
          "vertical_y_vertices": [485, 493]
        }
      },
      "interest_paid_ytd": {
        "extracted_string_or_numeric_value": 2.19,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [630, 700],
          "vertical_y_vertices": [498, 506]
        }
      }
    }
  }
]
```