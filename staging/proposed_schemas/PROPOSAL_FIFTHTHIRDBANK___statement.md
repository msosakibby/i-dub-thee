An expert forensic data architect, I have meticulously analyzed the provided document variants for the 'FIFTHTHIRDBANK - statement' class. My design prioritizes resilience by identifying a core, stable data structure while treating peripheral information as optional, thus accommodating potential structural drift. The resulting Pydantic V2 schema ensures strict data validation and includes a double-entry GAAP checksum for financial integrity, operating under a Zero-Trust mandate.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# MANDATORY: These are the exact base classes you must use.
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Resilient Schema for 'FIFTHTHIRDBANK - statement'
class CheckTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    check_number: ForensicDataEntity
    date_paid: ForensicDataEntity
    amount: ForensicDataEntity

class WithdrawalTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    amount: ForensicDataEntity
    description: ForensicDataEntity

class DepositTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    amount: ForensicDataEntity
    description: ForensicDataEntity

class DailyBalance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    amount: ForensicDataEntity

class FifthThirdBankStatementV1(BaseModel):
    """
    A resilient schema for Fifth Third Bank checking account statements.
    """
    model_config = ConfigDict(extra='forbid')

    # Header Information
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    statement_period_start_date: ForensicDataEntity
    statement_period_end_date: ForensicDataEntity

    # Party Information
    recipient_name: ForensicDataEntity
    recipient_address: ForensicDataEntity
    bank_address: ForensicDataEntity

    # Account Summary
    beginning_balance: ForensicDataEntity
    ending_balance: ForensicDataEntity
    summary_total_checks: ForensicDataEntity
    summary_total_withdrawals: ForensicDataEntity
    summary_total_deposits: ForensicDataEntity

    # Transaction Details
    checks: List[CheckTransaction]
    withdrawals: List[WithdrawalTransaction]
    deposits: List[DepositTransaction]

    # Optional Information
    banking_center: Optional[ForensicDataEntity] = None
    banking_center_phone: Optional[ForensicDataEntity] = None
    commercial_client_services_phone: Optional[ForensicDataEntity] = None
    daily_balances: Optional[List[DailyBalance]] = None

    @model_validator(mode='after')
    def validate_financial_integrity(self) -> 'FifthThirdBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to ensure financial integrity.
        1. Verifies that the sum of itemized transactions matches the summary totals.
        2. Verifies that the ending balance is correctly calculated from the beginning balance and summary totals.
        """
        epsilon = 0.01

        # 1. Sum itemized transactions
        calculated_total_deposits = sum(d.amount.extracted_string_or_numeric_value for d in self.deposits)
        calculated_total_checks = sum(c.amount.extracted_string_or_numeric_value for c in self.checks)
        calculated_total_withdrawals = sum(w.amount.extracted_string_or_numeric_value for w in self.withdrawals)

        # 2. Check itemized sums against summary totals
        summary_deposits = self.summary_total_deposits.extracted_string_or_numeric_value
        if abs(summary_deposits - calculated_total_deposits) > epsilon:
            raise ValueError(f"Sum of itemized deposits ({calculated_total_deposits:.2f}) does not match summary total ({summary_deposits:.2f})")

        summary_checks = self.summary_total_checks.extracted_string_or_numeric_value
        if abs(summary_checks - calculated_total_checks) > epsilon:
            raise ValueError(f"Sum of itemized checks ({calculated_total_checks:.2f}) does not match summary total ({summary_checks:.2f})")

        summary_withdrawals = self.summary_total_withdrawals.extracted_string_or_numeric_value
        if abs(summary_withdrawals - calculated_total_withdrawals) > epsilon:
            raise ValueError(f"Sum of itemized withdrawals ({calculated_total_withdrawals:.2f}) does not match summary total ({summary_withdrawals:.2f})")

        # 3. Check overall balance calculation
        beginning_balance = self.beginning_balance.extracted_string_or_numeric_value
        ending_balance = self.ending_balance.extracted_string_or_numeric_value
        
        calculated_ending_balance = beginning_balance + summary_deposits - summary_checks - summary_withdrawals
        
        if abs(ending_balance - calculated_ending_balance) > epsilon:
            raise ValueError(f"Calculated ending balance ({calculated_ending_balance:.2f}) does not match statement ending balance ({ending_balance:.2f})")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2010-02-kibby-company-statement-full",
    "should_pass": true,
    "taxonomy_lane": "FifthThirdBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "4273451",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [738, 833, 833, 738],
          "vertical_y_vertices": [65, 65, 75, 75]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "Bus Basics Checking",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [738, 869, 869, 738],
          "vertical_y_vertices": [53, 53, 63, 63]
        }
      },
      "statement_period_start_date": {
        "extracted_string_or_numeric_value": "2/1/2010",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [738, 790, 790, 738],
          "vertical_y_vertices": [41, 41, 51, 51]
        }
      },
      "statement_period_end_date": {
        "extracted_string_or_numeric_value": "2/26/2010",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 859, 859, 800],
          "vertical_y_vertices": [41, 41, 51, 51]
        }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "KIBBY COMPANY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [231, 331, 331, 231],
          "vertical_y_vertices": [91, 91, 100, 100]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665-0297",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [231, 385, 385, 231],
          "vertical_y_vertices": [103, 103, 124, 124]
        }
      },
      "bank_address": {
        "extracted_string_or_numeric_value": "P.O. BOX 630900 CINCINNATI OH 45263-0900",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [231, 510, 510, 231],
          "vertical_y_vertices": [67, 67, 76, 76]
        }
      },
      "banking_center": {
        "extracted_string_or_numeric_value": "Cadillac Downtown",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [668, 786, 786, 668],
          "vertical_y_vertices": [121, 121, 130, 130]
        }
      },
      "banking_center_phone": {
        "extracted_string_or_numeric_value": "231-779-2700",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [668, 758, 758, 668],
          "vertical_y_vertices": [133, 133, 142, 142]
        }
      },
      "commercial_client_services_phone": {
        "extracted_string_or_numeric_value": "1-800-589-5355",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [668, 770, 770, 668],
          "vertical_y_vertices": [145, 145, 154, 154]
        }
      },
      "beginning_balance": {
        "extracted_string_or_numeric_value": 1711.83,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [424, 484, 484, 424],
          "vertical_y_vertices": [259, 259, 268, 268]
        }
      },
      "ending_balance": {
        "extracted_string_or_numeric_value": 1147.93,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [424, 484, 484, 424],
          "vertical_y_vertices": [319, 319, 328, 328]
        }
      },
      "summary_total_checks": {
        "extracted_string_or_numeric_value": 4255.17,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [424, 484, 484, 424],
          "vertical_y_vertices": [271, 271, 280, 280]
        }
      },
      "summary_total_withdrawals": {
        "extracted_string_or_numeric_value": 89.30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [424, 484, 484, 424],
          "vertical_y_vertices": [283, 283, 292, 292]
        }
      },
      "summary_total_deposits": {
        "extracted_string_or_numeric_value": 3780.57,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [424, 484, 484, 424],
          "vertical_y_vertices": [307, 307, 316, 316]
        }
      },
      "checks": [
        {
          "check_number": {
            "extracted_string_or_numeric_value": "3409 i",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 196, 196, 159], "vertical_y_vertices": [405, 405, 414, 414] }
          },
          "date_paid": {
            "extracted_string_or_numeric_value": "02/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [228, 260, 260, 228], "vertical_y_vertices": [405, 405, 414, 414] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 516.09,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [288, 328, 328, 288], "vertical_y_vertices": [405, 405, 414, 414] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "3410 i",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 196, 196, 159], "vertical_y_vertices": [417, 417, 426, 426] }
          },
          "date_paid": {
            "extracted_string_or_numeric_value": "02/04",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [228, 260, 260, 228], "vertical_y_vertices": [417, 417, 426, 426] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 1876.25,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [288, 335, 335, 288], "vertical_y_vertices": [417, 417, 426, 426] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "3411 i",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [381, 418, 418, 381], "vertical_y_vertices": [405, 405, 414, 414] }
          },
          "date_paid": {
            "extracted_string_or_numeric_value": "02/08",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 482, 482, 450], "vertical_y_vertices": [405, 405, 414, 414] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 1633.23,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 557, 557, 510], "vertical_y_vertices": [405, 405, 414, 414] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "3412 i",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [381, 418, 418, 381], "vertical_y_vertices": [417, 417, 426, 426] }
          },
          "date_paid": {
            "extracted_string_or_numeric_value": "02/05",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 482, 482, 450], "vertical_y_vertices": [417, 417, 426, 426] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 60.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [510, 543, 543, 510], "vertical_y_vertices": [417, 417, 426, 426] }
          }
        },
        {
          "check_number": {
            "extracted_string_or_numeric_value": "3415*i",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [603, 644, 644, 603], "vertical_y_vertices": [405, 405, 414, 414] }
          },
          "date_paid": {
            "extracted_string_or_numeric_value": "02/24",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [672, 704, 704, 672], "vertical_y_vertices": [405, 405, 414, 414] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 169.60,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [732, 772, 772, 732], "vertical_y_vertices": [405, 405, 414, 414] }
          }
        }
      ],
      "withdrawals": [
        {
          "date": {
            "extracted_string_or_numeric_value": "02/16",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 191, 191, 159], "vertical_y_vertices": [481, 481, 490, 490] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 89.30,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [228, 261, 261, 228], "vertical_y_vertices": [481, 481, 490, 490] }
          },
          "description": {
            "extracted_string_or_numeric_value": "CHECK #3414 CONVERTED TO ELECTRONIC TRANSACTION BY Alltel CHECK PYMT 021610",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [357, 850, 850, 357], "vertical_y_vertices": [481, 481, 490, 490] }
          }
        }
      ],
      "deposits": [
        {
          "date": {
            "extracted_string_or_numeric_value": "02/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 191, 191, 159], "vertical_y_vertices": [547, 547, 556, 556] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 3780.57,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [228, 275, 275, 228], "vertical_y_vertices": [547, 547, 556, 556] }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [357, 405, 405, 357], "vertical_y_vertices": [547, 547, 556, 556] }
          }
        }
      ],
      "daily_balances": [
        {
          "date": {
            "extracted_string_or_numeric_value": "02/02",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 191, 191, 159], "vertical_y_vertices": [613, 613, 622, 622] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 4976.31,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [228, 275, 275, 228], "vertical_y_vertices": [613, 613, 622, 622] }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/04",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [159, 191, 191, 159], "vertical_y_vertices": [625, 625, 634, 634] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 3100.06,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [228, 275, 275, 228], "vertical_y_vertices": [625, 625, 634, 634] }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/05",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [381, 413, 413, 381], "vertical_y_vertices": [613, 613, 622, 622] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 3040.06,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 497, 497, 450], "vertical_y_vertices": [613, 613, 622, 622] }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/08",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [381, 413, 413, 381], "vertical_y_vertices": [625, 625, 634, 634] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 1406.83,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 497, 497, 450], "vertical_y_vertices": [625, 625, 634, 634] }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/16",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [603, 635, 635, 603], "vertical_y_vertices": [613, 613, 622, 622] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 1317.53,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [672, 719, 719, 672], "vertical_y_vertices": [613, 613, 622, 622] }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/24",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [603, 635, 635, 603], "vertical_y_vertices": [625, 625, 634, 634] }
          },
          "amount": {
            "extracted_string_or_numeric_value": 1147.93,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [672, 719, 719, 672], "vertical_y_vertices": [625, 625, 634, 634] }
          }
        }
      ]
    }
  }
]
```