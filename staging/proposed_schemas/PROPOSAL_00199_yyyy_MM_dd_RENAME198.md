An expert forensic data architect, I have analyzed the provided documents, which exhibit significant structural drift from a financial statement to a table of contents. To accommodate this divergence, I have designed a single, resilient Pydantic V2 schema, `BankStatementOrPamphletV1`. This schema models the bank statement's detailed financial data and the table of contents' simple list structure by defining their respective fields as optional. This approach ensures that either document type can be parsed without validation errors. The schema includes a GAAP-compliant mathematical validator that activates only when financial data is present, ensuring the integrity of bank statement extractions while gracefully ignoring non-financial documents.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class BankStatementSummary(BaseModel):
    """Models the summary snapshot of a bank account statement."""
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    total_deposits: ForensicDataEntity
    total_withdrawals: ForensicDataEntity
    current_balance: ForensicDataEntity

class TransactionItem(BaseModel):
    """Models a single transaction line item from a bank statement."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None

class InterestSummary(BaseModel):
    """Models the interest-related information on a bank statement."""
    model_config = ConfigDict(extra='forbid')
    interest_earned_period: ForensicDataEntity
    interest_paid_ytd: ForensicDataEntity
    apy_earned: ForensicDataEntity

class TableOfContentsItem(BaseModel):
    """Models a single entry in a table of contents."""
    model_config = ConfigDict(extra='forbid')
    topic: ForensicDataEntity
    page_number: ForensicDataEntity

class BankStatementOrPamphletV1(BaseModel):
    """
    A resilient schema designed to parse either a structured bank statement or a simple
    table of contents document, accommodating significant structural drift.
    """
    model_config = ConfigDict(extra='forbid')

    # Fields common to bank statements
    issuer_name: Optional[ForensicDataEntity] = None
    issuer_address: Optional[ForensicDataEntity] = None
    issuer_phone: Optional[ForensicDataEntity] = None
    recipient_name: Optional[ForensicDataEntity] = None
    recipient_address: Optional[ForensicDataEntity] = None
    statement_date: Optional[ForensicDataEntity] = None
    account_number: Optional[ForensicDataEntity] = None
    account_type: Optional[ForensicDataEntity] = None
    summary: Optional[BankStatementSummary] = None
    transactions: Optional[List[TransactionItem]] = None
    interest_summary: Optional[InterestSummary] = None
    payer_federal_id: Optional[ForensicDataEntity] = None

    # Fields common to pamphlets or simple documents
    document_title: Optional[ForensicDataEntity] = None
    table_of_contents_items: Optional[List[TableOfContentsItem]] = None
    document_identifier: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def double_entry_gaap_checksum(self) -> 'BankStatementOrPamphletV1':
        """
        Performs double-entry accounting checks if the document is a bank statement.
        1. Verifies that the summary balances: Previous + Deposits - Withdrawals = Current.
        2. Verifies that the sum of transaction details matches the summary totals.
        """
        if self.summary and self.transactions:
            # Check 1: Summary balance calculation
            prev_bal = float(self.summary.previous_balance.extracted_string_or_numeric_value)
            deposits = float(self.summary.total_deposits.extracted_string_or_numeric_value)
            withdrawals = float(self.summary.total_withdrawals.extracted_string_or_numeric_value)
            curr_bal = float(self.summary.current_balance.extracted_string_or_numeric_value)

            if not math.isclose(prev_bal + deposits - withdrawals, curr_bal, rel_tol=1e-4):
                raise ValueError(f"Summary checksum failed: {prev_bal} + {deposits} - {withdrawals} != {curr_bal}")

            # Check 2: Transaction details vs. summary totals
            calculated_deposits = sum(
                float(t.credit.extracted_string_or_numeric_value) for t in self.transactions if t.credit
            )
            calculated_withdrawals = sum(
                float(t.debit.extracted_string_or_numeric_value) for t in self.transactions if t.debit
            )

            if not math.isclose(calculated_deposits, deposits, rel_tol=1e-4):
                raise ValueError(f"Transaction deposits sum ({calculated_deposits}) does not match summary total ({deposits})")

            if not math.isclose(calculated_withdrawals, withdrawals, rel_tol=1e-4):
                raise ValueError(f"Transaction withdrawals sum ({calculated_withdrawals}) does not match summary total ({withdrawals})")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "bank_statement_complex_variant_001",
    "should_pass": true,
    "taxonomy_lane": "BankStatementOrPamphletV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "issuer_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 300],
          "vertical_y_vertices": [45, 60]
        }
      },
      "issuer_address": {
        "extracted_string_or_numeric_value": "MCBAIN\n101 N ROLAND ST\nMC BAIN MI\n49657",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 260],
          "vertical_y_vertices": [62, 108]
        }
      },
      "issuer_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 352],
          "vertical_y_vertices": [110, 120]
        }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "KEITH A GRANDY\nJUDITH A GRANDY",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 310],
          "vertical_y_vertices": [145, 168]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 280],
          "vertical_y_vertices": [170, 192]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "08/31/14",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 795],
          "vertical_y_vertices": [140, 152]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "4550765020",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 795],
          "vertical_y_vertices": [180, 192]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "MI SAVINGS ACCOUNT",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [161, 450],
          "vertical_y_vertices": [230, 242]
        }
      },
      "summary": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [730, 800],
            "vertical_y_vertices": [250, 260]
          }
        },
        "total_deposits": {
          "extracted_string_or_numeric_value": 5000.16,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [730, 800],
            "vertical_y_vertices": [262, 272]
          }
        },
        "total_withdrawals": {
          "extracted_string_or_numeric_value": 4500.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [730, 800],
            "vertical_y_vertices": [274, 284]
          }
        },
        "current_balance": {
          "extracted_string_or_numeric_value": 500.16,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [730, 800],
            "vertical_y_vertices": [286, 296]
          }
        }
      },
      "transactions": [
        {
          "date": {
            "extracted_string_or_numeric_value": "07/29",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [360, 370]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 350],
              "vertical_y_vertices": [360, 370]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 5000.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710],
              "vertical_y_vertices": [360, 370]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "07/31",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [372, 382]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "INTEREST PAYMENT",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 350],
              "vertical_y_vertices": [372, 382]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 0.01,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710],
              "vertical_y_vertices": [372, 382]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "08/22",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [384, 394]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "XFR SAV X020 TO CKG X797#8768",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 450],
              "vertical_y_vertices": [384, 394]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 4500.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [520, 580],
              "vertical_y_vertices": [384, 394]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "08/31",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [161, 195],
              "vertical_y_vertices": [396, 406]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "INTEREST PAYMENT",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 350],
              "vertical_y_vertices": [396, 406]
            }
          },
          "credit": {
            "extracted_string_or_numeric_value": 0.15,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 710],
              "vertical_y_vertices": [396, 406]
            }
          }
        }
      ],
      "payer_federal_id": {
        "extracted_string_or_numeric_value": "38-0415896",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [550, 650],
          "vertical_y_vertices": [470, 480]
        }
      },
      "interest_summary": {
        "interest_earned_period": {
          "extracted_string_or_numeric_value": 0.16,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 700],
            "vertical_y_vertices": [515, 525]
          }
        },
        "interest_paid_ytd": {
          "extracted_string_or_numeric_value": 0.16,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550, 650],
            "vertical_y_vertices": [482, 492]
          }
        },
        "apy_earned": {
          "extracted_string_or_numeric_value": "0.05%",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 700],
            "vertical_y_vertices": [527, 537]
          }
        }
      }
    }
  }
]
```