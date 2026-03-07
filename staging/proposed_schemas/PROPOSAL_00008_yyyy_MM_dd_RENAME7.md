An expert forensic data architect, I have analyzed the provided document and designed a resilient Pydantic V2 schema to capture its structure, including potential variations. The schema enforces data integrity through double-entry accounting principles via a GAAP-compliant mathematical validator.

***

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices for physical location on a document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Transaction(BaseModel):
    """Represents a single transaction line item."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debits: Optional[ForensicDataEntity] = None
    credits: Optional[ForensicDataEntity] = None

class BalanceByDate(BaseModel):
    """Represents a snapshot of the account balance on a specific date."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    balance: ForensicDataEntity

class ChemicalBankStatementV1(BaseModel):
    """
    Schema for Chemical Bank checking account statements, circa 2010.
    This model is designed to be resilient to minor structural changes over time.
    """
    model_config = ConfigDict(extra='forbid')

    # Document Header Information
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    cycle: Optional[ForensicDataEntity] = None

    # Recipient Information
    recipient_name: ForensicDataEntity
    recipient_trustee: Optional[ForensicDataEntity] = None
    recipient_address: ForensicDataEntity

    # Account Summary Section
    account_category: ForensicDataEntity
    account_type: ForensicDataEntity
    previous_statement_balance: ForensicDataEntity
    deposits_count: ForensicDataEntity
    deposits_and_other_credits: ForensicDataEntity
    checks_count: ForensicDataEntity
    checks_and_other_debits: ForensicDataEntity
    current_statement_balance: ForensicDataEntity
    statement_period_days: ForensicDataEntity
    beginning_rate: Optional[ForensicDataEntity] = None

    # Transaction Details
    transactions: List[Transaction]
    balance_by_date: List[BalanceByDate]

    # Tax and Footer Information
    payer_federal_id: ForensicDataEntity
    interest_paid_ytd: ForensicDataEntity

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP validation on the statement's financial figures.
        1. Summary Check: Verifies that Previous Balance + Credits - Debits = Current Balance.
        2. Detail Check: Verifies that the sum of individual transactions matches the summary totals.
        """
        # 1. Summary Check
        prev_bal = self.previous_statement_balance.extracted_string_or_numeric_value
        credits_summary = self.deposits_and_other_credits.extracted_string_or_numeric_value
        debits_summary = self.checks_and_other_debits.extracted_string_or_numeric_value
        current_bal = self.current_statement_balance.extracted_string_or_numeric_value

        if not all(isinstance(v, (int, float)) for v in [prev_bal, credits_summary, debits_summary, current_bal]):
            raise ValueError("Summary balance fields must be numeric for validation.")

        calculated_balance = prev_bal + credits_summary - debits_summary
        if not math.isclose(calculated_balance, current_bal, rel_tol=1e-9, abs_tol=0.01):
            raise ValueError(
                f"Balance summary mismatch: Previous({prev_bal}) + Credits({credits_summary}) - Debits({debits_summary}) = {calculated_balance}, "
                f"but Current Balance is {current_bal}."
            )

        # 2. Detail Check
        total_transaction_credits = sum(
            t.credits.extracted_string_or_numeric_value
            for t in self.transactions
            if t.credits and isinstance(t.credits.extracted_string_or_numeric_value, (int, float))
        )
        total_transaction_debits = sum(
            t.debits.extracted_string_or_numeric_value
            for t in self.transactions
            if t.debits and isinstance(t.debits.extracted_string_or_numeric_value, (int, float))
        )

        if not math.isclose(total_transaction_credits, credits_summary, rel_tol=1e-9, abs_tol=0.01):
            raise ValueError(
                f"Transaction credits sum mismatch: Sum of transaction credits is {total_transaction_credits}, "
                f"but summary shows {credits_summary}."
            )

        if not math.isclose(total_transaction_debits, debits_summary, rel_tol=1e-9, abs_tol=0.01):
            raise ValueError(
                f"Transaction debits sum mismatch: Sum of transaction debits is {total_transaction_debits}, "
                f"but summary shows {debits_summary}."
            )

        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "00008_2010-06-30_ChemicalBank_Trust_Statement",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "statement_date": {
        "extracted_string_or_numeric_value": "06/30/10",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [661, 719, 719, 661],
          "vertical_y_vertices": [125, 125, 135, 135]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2140091121",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [661, 738, 738, 661],
          "vertical_y_vertices": [156, 156, 166, 166]
        }
      },
      "cycle": {
        "extracted_string_or_numeric_value": "049",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [683, 710, 710, 683],
          "vertical_y_vertices": [187, 187, 197, 197]
        }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "MAX R KIBBY TRUST AMENDED 5/2/93",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [215, 430, 430, 215],
          "vertical_y_vertices": [139, 139, 149, 149]
        }
      },
      "recipient_trustee": {
        "extracted_string_or_numeric_value": "JUDITH A GRANDY TRUSTEE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [215, 375, 375, 215],
          "vertical_y_vertices": [150, 150, 160, 160]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD PO BOX 297 MARION MI 49665",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [215, 370, 370, 215],
          "vertical_y_vertices": [161, 161, 193, 193]
        }
      },
      "account_category": {
        "extracted_string_or_numeric_value": "CHECKING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 200, 200, 120],
          "vertical_y_vertices": [225, 225, 235, 235]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "ADVANTAGE CHECKING",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [230, 370, 370, 230],
          "vertical_y_vertices": [225, 225, 235, 235]
        }
      },
      "previous_statement_balance": {
        "extracted_string_or_numeric_value": 10438.19,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 720, 720, 650],
          "vertical_y_vertices": [240, 240, 250, 250]
        }
      },
      "deposits_count": {
        "extracted_string_or_numeric_value": 1,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [210, 220, 220, 210],
          "vertical_y_vertices": [251, 251, 261, 261]
        }
      },
      "deposits_and_other_credits": {
        "extracted_string_or_numeric_value": 1.03,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 720, 720, 650],
          "vertical_y_vertices": [251, 251, 261, 261]
        }
      },
      "checks_count": {
        "extracted_string_or_numeric_value": 0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [210, 220, 220, 210],
          "vertical_y_vertices": [262, 262, 272, 272]
        }
      },
      "checks_and_other_debits": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 720, 720, 650],
          "vertical_y_vertices": [262, 262, 272, 272]
        }
      },
      "current_statement_balance": {
        "extracted_string_or_numeric_value": 10439.22,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 720, 720, 650],
          "vertical_y_vertices": [273, 273, 283, 283]
        }
      },
      "statement_period_days": {
        "extracted_string_or_numeric_value": 30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 465, 465, 450],
          "vertical_y_vertices": [284, 284, 294, 294]
        }
      },
      "beginning_rate": {
        "extracted_string_or_numeric_value": 0.12000,
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [661, 720, 720, 661],
          "vertical_y_vertices": [198, 198, 208, 208]
        }
      },
      "transactions": [
        {
          "date": {
            "extracted_string_or_numeric_value": "06/30",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 155, 155, 120],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "INTEREST PAYMENT",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [210, 330, 330, 210],
              "vertical_y_vertices": [330, 330, 340, 340]
            }
          },
          "credits": {
            "extracted_string_or_numeric_value": 1.03,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [590, 630, 630, 590],
              "vertical_y_vertices": [320, 320, 330, 330]
            }
          }
        }
      ],
      "balance_by_date": [
        {
          "date": {
            "extracted_string_or_numeric_value": "05/31",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 155, 155, 120],
              "vertical_y_vertices": [370, 370, 380, 380]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 10438.19,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [160, 220, 220, 160],
              "vertical_y_vertices": [370, 370, 380, 380]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "06/30",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [230, 265, 265, 230],
              "vertical_y_vertices": [370, 370, 380, 380]
            }
          },
          "balance": {
            "extracted_string_or_numeric_value": 10439.22,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [270, 330, 330, 270],
              "vertical_y_vertices": [370, 370, 380, 380]
            }
          }
        }
      ],
      "payer_federal_id": {
        "extracted_string_or_numeric_value": "38-0415896",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [530, 600, 600, 530],
          "vertical_y_vertices": [400, 400, 410, 410]
        }
      },
      "interest_paid_ytd": {
        "extracted_string_or_numeric_value": 2.22,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [530, 560, 560, 530],
          "vertical_y_vertices": [411, 411, 421, 421]
        }
      }
    }
  }
]
```