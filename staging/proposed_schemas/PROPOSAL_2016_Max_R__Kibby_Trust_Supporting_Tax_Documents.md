An analysis of the provided documents reveals a collection of financial records for the 2016 tax year, centered around the Max R. Kibby Trust and related entities. The documents include official tax forms (1099-MISC, 1099-R), internal financial summaries (Income Statement, Transaction Ledgers), and supporting invoices/contracts.

The most structurally complex document is the "Kibby Co. Income Statement" (page 2), which provides a clear hierarchical summary of income and expenses, along with totals that can be mathematically verified. This document serves as the ideal basis for a resilient schema. The proposed schema, `KibbyTrustTaxDocument`, is designed to model this income statement structure, while using `Optional` fields to gracefully accommodate the simpler, flatter structures of the other supporting documents like 1099s and invoices.

The schema includes a `LineItem` model to capture individual financial entries, which can be nested to represent subtotals and their constituent parts. The primary `KibbyTrustTaxDocument` model contains sections for income, expenses, and totals. A `model_validator` implements double-entry accounting principles by performing three key checksums:
1.  Verifying that the sum of `income_items` matches the `total_income`.
2.  Verifying that the sum of `expense_items` matches the `total_expenses`.
3.  Verifying that `total_income` minus `total_expenses` equals the `net_total`.

This approach creates a single, robust schema capable of representing all provided document variants while enforcing financial integrity.

```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# MANDATORY: Do not change these base classes
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema design starts here
class LineItem(BaseModel):
    """Represents a single line item in a financial document, which can be nested."""
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    amount: ForensicDataEntity
    category: Optional[ForensicDataEntity] = None
    sub_items: Optional[List['LineItem']] = None

class KibbyTrustTaxDocument(BaseModel):
    """
    A resilient schema for various financial and tax-supporting documents,
    based on the structure of an income statement.
    """
    model_config = ConfigDict(extra='forbid')

    document_type: ForensicDataEntity
    primary_party: ForensicDataEntity
    secondary_party: Optional[ForensicDataEntity] = None
    document_date: Optional[ForensicDataEntity] = None
    period_start_date: Optional[ForensicDataEntity] = None
    period_end_date: Optional[ForensicDataEntity] = None

    income_items: Optional[List[LineItem]] = None
    total_income: Optional[ForensicDataEntity] = None

    expense_items: Optional[List[LineItem]] = None
    total_expenses: Optional[ForensicDataEntity] = None

    net_total: Optional[ForensicDataEntity] = None

    other_values: Optional[List[LineItem]] = None

    @model_validator(mode='after')
    def gaap_double_entry_checksum(self) -> 'KibbyTrustTaxDocument':
        """
        Performs double-entry GAAP checksums if enough data is present.
        1. Validates sum of income items against total income.
        2. Validates sum of expense items against total expenses.
        3. Validates that (total income - total expenses) equals net total.
        """
        TOLERANCE = 0.01

        # --- Income Items vs. Total Income Check ---
        if self.income_items and self.total_income:
            calculated_income = sum(
                item.amount.extracted_string_or_numeric_value
                for item in self.income_items
                if isinstance(item.amount.extracted_string_or_numeric_value, (int, float))
            )
            reported_income = self.total_income.extracted_string_or_numeric_value
            if not isinstance(reported_income, (int, float)):
                raise ValueError("total_income must be a numeric value for validation.")
            if abs(calculated_income - reported_income) > TOLERANCE:
                raise ValueError(
                    f"Income checksum failed: Sum of income_items ({calculated_income:.2f}) "
                    f"does not match total_income ({reported_income:.2f})."
                )

        # --- Expense Items vs. Total Expenses Check ---
        if self.expense_items and self.total_expenses:
            calculated_expenses = sum(
                item.amount.extracted_string_or_numeric_value
                for item in self.expense_items
                if isinstance(item.amount.extracted_string_or_numeric_value, (int, float))
            )
            reported_expenses = self.total_expenses.extracted_string_or_numeric_value
            if not isinstance(reported_expenses, (int, float)):
                raise ValueError("total_expenses must be a numeric value for validation.")
            if abs(calculated_expenses - reported_expenses) > TOLERANCE:
                raise ValueError(
                    f"Expense checksum failed: Sum of expense_items ({calculated_expenses:.2f}) "
                    f"does not match total_expenses ({reported_expenses:.2f})."
                )

        # --- Net Total Check ---
        if self.total_income and self.total_expenses and self.net_total:
            reported_income = self.total_income.extracted_string_or_numeric_value
            reported_expenses = self.total_expenses.extracted_string_or_numeric_value
            reported_net = self.net_total.extracted_string_or_numeric_value

            if all(isinstance(v, (int, float)) for v in [reported_income, reported_expenses, reported_net]):
                if abs((reported_income - reported_expenses) - reported_net) > TOLERANCE:
                    raise ValueError(
                        f"Net total checksum failed: total_income ({reported_income:.2f}) - "
                        f"total_expenses ({reported_expenses:.2f}) does not equal net_total ({reported_net:.2f})."
                    )
        
        return self
```

```json
[
  {
    "test_identifier": "kibby_income_statement_2016_full_validation",
    "should_pass": true,
    "taxonomy_lane": "KibbyTrustTaxDocument",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_type": {
        "extracted_string_or_numeric_value": "Income Statement",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [340, 560, 560, 340],
          "vertical_y_vertices": [45, 45, 60, 60]
        }
      },
      "primary_party": {
        "extracted_string_or_numeric_value": "Kibby Co.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [340, 415, 415, 340],
          "vertical_y_vertices": [45, 45, 60, 60]
        }
      },
      "period_start_date": {
        "extracted_string_or_numeric_value": "1/1/2016",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 550, 550, 450],
          "vertical_y_vertices": [65, 65, 78, 78]
        }
      },
      "period_end_date": {
        "extracted_string_or_numeric_value": "12/31/2016",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [600, 680, 680, 600],
          "vertical_y_vertices": [95, 95, 108, 108]
        }
      },
      "income_items": [
        {
          "description": {
            "extracted_string_or_numeric_value": "TOTAL Prielipp Lnd Co",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 480, 480, 338],
              "vertical_y_vertices": [205, 205, 218, 218]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 7676.04,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680, 680, 620],
              "vertical_y_vertices": [205, 205, 218, 218]
            }
          },
          "category": {
            "extracted_string_or_numeric_value": "Prielipp Lnd Co",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 430, 430, 338],
              "vertical_y_vertices": [155, 155, 168, 168]
            }
          },
          "sub_items": [
            {
              "description": {
                "extracted_string_or_numeric_value": "Interest",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [350, 410, 410, 350],
                  "vertical_y_vertices": [170, 170, 183, 183]
                }
              },
              "amount": {
                "extracted_string_or_numeric_value": 419.58,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [620, 680, 680, 620],
                  "vertical_y_vertices": [170, 170, 183, 183]
                }
              }
            },
            {
              "description": {
                "extracted_string_or_numeric_value": "Principal",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [350, 420, 420, 350],
                  "vertical_y_vertices": [188, 188, 201, 201]
                }
              },
              "amount": {
                "extracted_string_or_numeric_value": 7256.46,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [620, 680, 680, 620],
                  "vertical_y_vertices": [188, 188, 201, 201]
                }
              }
            }
          ]
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Salary - Spartan",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 460, 460, 338],
              "vertical_y_vertices": [223, 223, 236, 236]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 84552.96,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680, 680, 620],
              "vertical_y_vertices": [223, 223, 236, 236]
            }
          }
        }
      ],
      "total_income": {
        "extracted_string_or_numeric_value": 92229.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [620, 680, 680, 620],
          "vertical_y_vertices": [240, 240, 255, 255]
        }
      },
      "expense_items": [
        {
          "description": {
            "extracted_string_or_numeric_value": "TOTAL Accounting Fees",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 500, 500, 338],
              "vertical_y_vertices": [325, 325, 338, 338]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 1561.25,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680, 680, 620],
              "vertical_y_vertices": [325, 325, 338, 338]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "TOTAL Bank Charges",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 480, 480, 338],
              "vertical_y_vertices": [360, 360, 373, 373]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 75.87,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680, 680, 620],
              "vertical_y_vertices": [360, 360, 373, 373]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Fees",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 375, 375, 338],
              "vertical_y_vertices": [378, 378, 391, 391]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 50.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680, 680, 620],
              "vertical_y_vertices": [378, 378, 391, 391]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "TOTAL Taxes",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 440, 440, 338],
              "vertical_y_vertices": [455, 455, 468, 468]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 6631.06,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [620, 680, 680, 620],
              "vertical_y_vertices": [455, 455, 468, 468]
            }
          }
        }
      ],
      "total_expenses": {
        "extracted_string_or_numeric_value": 8318.18,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [620, 680, 680, 620],
          "vertical_y_vertices": [473, 473, 486, 486]
        }
      },
      "net_total": {
        "extracted_string_or_numeric_value": 83910.82,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [620, 680, 680, 620],
          "vertical_y_vertices": [505, 505, 518, 518]
        }
      }
    }
  }
]
```