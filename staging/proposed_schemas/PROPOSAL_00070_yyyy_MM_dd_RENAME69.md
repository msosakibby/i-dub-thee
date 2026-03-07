An expert forensic data architect, I have analyzed the provided document, a bank statement page containing cleared check images and handwritten calculations. The document exhibits a consistent structure for each check and a clear, albeit manual, financial calculation.

To create a resilient Pydantic V2 schema, I have identified the following key entities:
1.  **Header Information**: `page_number` and `account_number`.
2.  **Account Holder Address**: A consistent address block appearing on each check, which is best modeled as a single top-level entity.
3.  **Check Details**: A repeating block for each of the four checks, containing fields like check number, date, payee, amounts, memo, and processing information.
4.  **Handwritten Calculations**: A distinct section at the bottom of the page detailing a manual ledger calculation, which I've modeled to capture its arithmetic structure (additions leading to intermediate and final balances).

The schema includes a `model_validator` to perform two crucial GAAP-style checksums:
1.  It verifies that the numeric amount written on each check matches the "Paid" amount recorded by the bank.
2.  It validates the arithmetic of the handwritten calculations, ensuring the sums correctly lead to the documented intermediate and final balances.

This approach ensures both structural integrity and financial accuracy of the extracted data.

### BLOCK 1 (Python Pydantic V2):

```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class CheckDetail(BaseModel):
    """Represents a single cleared check image and its associated data."""
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    check_date: ForensicDataEntity
    payee: ForensicDataEntity
    amount_numeric: ForensicDataEntity
    amount_written: ForensicDataEntity
    memo: Optional[ForensicDataEntity] = None
    paid_date: ForensicDataEntity
    paid_amount: ForensicDataEntity
    bank_name: ForensicDataEntity
    signature_text: ForensicDataEntity
    micr_line: ForensicDataEntity

class LedgerItem(BaseModel):
    """Represents a single line item in a handwritten calculation."""
    model_config = ConfigDict(extra='forbid')
    amount: ForensicDataEntity
    annotation: Optional[ForensicDataEntity] = None

class HandwrittenCalculations(BaseModel):
    """Represents the block of handwritten financial calculations."""
    model_config = ConfigDict(extra='forbid')
    starting_balance: ForensicDataEntity
    additions: List[LedgerItem]
    intermediate_sum: ForensicDataEntity
    final_addition: LedgerItem
    final_balance: LedgerItem

class BankStatementV1(BaseModel):
    """
    Schema for a bank statement page containing images of cleared checks
    and handwritten notes.
    """
    model_config = ConfigDict(extra='forbid')
    page_number: ForensicDataEntity
    account_number: ForensicDataEntity
    account_holder_address: ForensicDataEntity
    checks: List[CheckDetail]
    handwritten_calculations: Optional[HandwrittenCalculations] = None

    @model_validator(mode='after')
    def validate_financial_checksums(self) -> 'BankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        1. Validates that the amount on each check matches its paid amount.
        2. Validates the arithmetic of any handwritten calculations.
        """
        # Check 1: Verify check amounts match paid amounts.
        for check in self.checks:
            numeric_val = check.amount_numeric.extracted_string_or_numeric_value
            paid_val = check.paid_amount.extracted_string_or_numeric_value

            if not isinstance(numeric_val, (int, float)) or not isinstance(paid_val, (int, float)):
                raise ValueError(f"Check #{check.check_number.extracted_string_or_numeric_value}: amount_numeric and paid_amount must be numeric for validation.")

            if not math.isclose(numeric_val, paid_val, rel_tol=1e-9):
                raise ValueError(
                    f"Check #{check.check_number.extracted_string_or_numeric_value}: "
                    f"Numeric amount ({numeric_val}) does not match paid amount ({paid_val})."
                )

        # Check 2: Verify handwritten calculations.
        if self.handwritten_calculations:
            calc = self.handwritten_calculations
            
            # Verify intermediate sum
            start_bal = calc.starting_balance.extracted_string_or_numeric_value
            additions_sum = sum(item.amount.extracted_string_or_numeric_value for item in calc.additions)
            intermediate_total = calc.intermediate_sum.extracted_string_or_numeric_value
            
            if not math.isclose(start_bal + additions_sum, intermediate_total, rel_tol=1e-9):
                raise ValueError(
                    f"Handwritten calculation error: Starting balance ({start_bal}) + additions ({additions_sum:.2f}) "
                    f"does not equal intermediate sum ({intermediate_total})."
                )

            # Verify final balance
            final_add_val = calc.final_addition.amount.extracted_string_or_numeric_value
            final_bal = calc.final_balance.amount.extracted_string_or_numeric_value

            if not math.isclose(intermediate_total + final_add_val, final_bal, rel_tol=1e-9):
                raise ValueError(
                    f"Handwritten calculation error: Intermediate sum ({intermediate_total}) + final addition ({final_add_val}) "
                    f"does not equal final balance ({final_bal})."
                )

        return self
```

### BLOCK 2 (JSON Test Registry):

```json
[
  {
    "test_identifier": "bank_statement_v1_full_page_00070",
    "should_pass": true,
    "taxonomy_lane": "BankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "page_number": {
        "extracted_string_or_numeric_value": "2",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [173, 231, 231, 173],
          "vertical_y_vertices": [41, 41, 56, 56]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "1024797",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [173, 376, 376, 173],
          "vertical_y_vertices": [63, 63, 78, 78]
        }
      },
      "account_holder_address": {
        "extracted_string_or_numeric_value": "K. Grandy\nP.O. Box 297\nMarion, MI 49653",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [194, 326, 326, 194],
          "vertical_y_vertices": [180, 180, 208, 208]
        }
      },
      "checks": [
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9814",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 490], "vertical_y_vertices": [165, 178] }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "Aug 20, 2010",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 490], "vertical_y_vertices": [180, 195] }
          },
          "payee": {
            "extracted_string_or_numeric_value": "Gama",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 290], "vertical_y_vertices": [210, 225] }
          },
          "amount_numeric": {
            "extracted_string_or_numeric_value": 40.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 490], "vertical_y_vertices": [210, 225] }
          },
          "amount_written": {
            "extracted_string_or_numeric_value": "Forty + no/100",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 350], "vertical_y_vertices": [228, 240] }
          },
          "memo": {
            "extracted_string_or_numeric_value": "Ultimate Deer Spook",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 400], "vertical_y_vertices": [260, 275] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/07/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 320], "vertical_y_vertices": [295, 305] }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 40.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 490], "vertical_y_vertices": [295, 305] }
          },
          "bank_name": {
            "extracted_string_or_numeric_value": "CHEMICAL BANK",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 280], "vertical_y_vertices": [245, 255] }
          },
          "signature_text": {
            "extracted_string_or_numeric_value": "Judith A Grandy",
            "optical_extraction_confidence_score": 0.89,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 490], "vertical_y_vertices": [240, 260] }
          },
          "micr_line": {
            "extracted_string_or_numeric_value": "⑆072410013⑆ 0001024797⑈ 9814",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 490], "vertical_y_vertices": [275, 285] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9815",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 820], "vertical_y_vertices": [165, 178] }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "Aug 26, 2010",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 820], "vertical_y_vertices": [180, 195] }
          },
          "payee": {
            "extracted_string_or_numeric_value": "Chemical Bank",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 680], "vertical_y_vertices": [210, 225] }
          },
          "amount_numeric": {
            "extracted_string_or_numeric_value": 233.26,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [770, 820], "vertical_y_vertices": [210, 225] }
          },
          "amount_written": {
            "extracted_string_or_numeric_value": "Two Hundred Thirty-Three & 26/100",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 750], "vertical_y_vertices": [228, 240] }
          },
          "memo": {
            "extracted_string_or_numeric_value": "Dearborn Acct 970229530",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [580, 750], "vertical_y_vertices": [260, 275] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "08/26/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [580, 650], "vertical_y_vertices": [295, 305] }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 233.26,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [770, 820], "vertical_y_vertices": [295, 305] }
          },
          "bank_name": {
            "extracted_string_or_numeric_value": "CHEMICAL BANK",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 610], "vertical_y_vertices": [245, 255] }
          },
          "signature_text": {
            "extracted_string_or_numeric_value": "Judith A Grandy",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 820], "vertical_y_vertices": [240, 260] }
          },
          "micr_line": {
            "extracted_string_or_numeric_value": "⑆072410013⑆ 0001024797⑈ 9815",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 820], "vertical_y_vertices": [275, 285] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9816",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 490], "vertical_y_vertices": [325, 338] }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "8-30-10",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 490], "vertical_y_vertices": [340, 355] }
          },
          "payee": {
            "extracted_string_or_numeric_value": "KIRK Brittos",
            "optical_extraction_confidence_score": 0.91,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 320], "vertical_y_vertices": [370, 385] }
          },
          "amount_numeric": {
            "extracted_string_or_numeric_value": 71.31,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 490], "vertical_y_vertices": [370, 385] }
          },
          "amount_written": {
            "extracted_string_or_numeric_value": "Seventy one dollars + 31/100",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 400], "vertical_y_vertices": [388, 400] }
          },
          "memo": {
            "extracted_string_or_numeric_value": "new 2",
            "optical_extraction_confidence_score": 0.85,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 490], "vertical_y_vertices": [400, 415] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/01/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 320], "vertical_y_vertices": [455, 465] }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 71.31,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 490], "vertical_y_vertices": [455, 465] }
          },
          "bank_name": {
            "extracted_string_or_numeric_value": "CHEMICAL BANK",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 280], "vertical_y_vertices": [405, 415] }
          },
          "signature_text": {
            "extracted_string_or_numeric_value": "Judith A Grandy",
            "optical_extraction_confidence_score": 0.88,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 490], "vertical_y_vertices": [420, 440] }
          },
          "micr_line": {
            "extracted_string_or_numeric_value": "⑆072410013⑆ 0001024797⑈ 9816",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 490], "vertical_y_vertices": [435, 445] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "9817",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 820], "vertical_y_vertices": [325, 338] }
          },
          "check_date": {
            "extracted_string_or_numeric_value": "Sept 2, 2010",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 820], "vertical_y_vertices": [340, 355] }
          },
          "payee": {
            "extracted_string_or_numeric_value": "Judy Grandy",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 680], "vertical_y_vertices": [370, 385] }
          },
          "amount_numeric": {
            "extracted_string_or_numeric_value": 1000.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [760, 820], "vertical_y_vertices": [370, 385] }
          },
          "amount_written": {
            "extracted_string_or_numeric_value": "One Thousand & no/100",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 750], "vertical_y_vertices": [388, 400] }
          },
          "memo": {
            "extracted_string_or_numeric_value": "Pur",
            "optical_extraction_confidence_score": 0.89,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 820], "vertical_y_vertices": [400, 415] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "09/07/2010",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [580, 650], "vertical_y_vertices": [455, 465] }
          },
          "paid_amount": {
            "extracted_string_or_numeric_value": 1000.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [760, 820], "vertical_y_vertices": [455, 465] }
          },
          "bank_name": {
            "extracted_string_or_numeric_value": "CHEMICAL BANK",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 610], "vertical_y_vertices": [405, 415] }
          },
          "signature_text": {
            "extracted_string_or_numeric_value": "Judith A Grandy",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 820], "vertical_y_vertices": [420, 440] }
          },
          "micr_line": {
            "extracted_string_or_numeric_value": "⑆072410013⑆ 0001024797⑈ 9817",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 820], "vertical_y_vertices": [435, 445] }
          }
        }
      ],
      "handwritten_calculations": {
        "starting_balance": {
          "extracted_string_or_numeric_value": 4102.84,
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 310], "vertical_y_vertices": [650, 665] }
        },
        "additions": [
          {
            "amount": {
              "extracted_string_or_numeric_value": 100.00,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 310], "vertical_y_vertices": [670, 685] }
            },
            "annotation": {
              "extracted_string_or_numeric_value": "CK# 9820",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 420], "vertical_y_vertices": [670, 685] }
            }
          },
          {
            "amount": {
              "extracted_string_or_numeric_value": 92.00,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 310], "vertical_y_vertices": [690, 705] }
            },
            "annotation": {
              "extracted_string_or_numeric_value": "9818",
              "optical_extraction_confidence_score": 0.91,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [425, 470], "vertical_y_vertices": [670, 685] }
            }
          },
          {
            "amount": {
              "extracted_string_or_numeric_value": 0.45,
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 310], "vertical_y_vertices": [710, 725] }
            },
            "annotation": {
              "extracted_string_or_numeric_value": "Qub",
              "optical_extraction_confidence_score": 0.80,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [425, 470], "vertical_y_vertices": [690, 705] }
            }
          }
        ],
        "intermediate_sum": {
          "extracted_string_or_numeric_value": 4295.29,
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 320], "vertical_y_vertices": [750, 765] }
        },
        "final_addition": {
          "amount": {
            "extracted_string_or_numeric_value": 1241.05,
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 320], "vertical_y_vertices": [770, 785] }
          },
          "annotation": {
            "extracted_string_or_numeric_value": "CK# 9819",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 430], "vertical_y_vertices": [770, 785] }
          }
        },
        "final_balance": {
          "amount": {
            "extracted_string_or_numeric_value": 5536.34,
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 320], "vertical_y_vertices": [800, 815] }
          },
          "annotation": {
            "extracted_string_or_numeric_value": "Bal",
            "optical_extraction_confidence_score": 0.90,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 480], "vertical_y_vertices": [800, 815] }
          }
        }
      }
    }
  }
]
```