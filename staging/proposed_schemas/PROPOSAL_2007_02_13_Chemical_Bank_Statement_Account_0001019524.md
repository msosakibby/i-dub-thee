An expert forensic data architect, I have meticulously analyzed the provided document, a 2007 Chemical Bank statement. Despite being a single instance, it presents a rich and complex structure, including multiple transaction lists, detailed summaries, and specific financial data points. My Pydantic V2 schema is designed for maximum resilience, anticipating potential variations by employing `Optional` types for non-essential sections. The schema enforces strict data integrity through a comprehensive GAAP-based mathematical validator, ensuring that the foundational accounting principle (`Assets = Liabilities + Equity`, or in this context, `End Balance = Start Balance + Credits - Debits`) holds true.

### BLOCK 1: Python Pydantic V2 Schema

```python
import math
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SpatialCoordinatesPolygon(BaseModel):
    """Defines the physical coordinates of an extracted entity on a document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]


class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon


class CheckTransaction(BaseModel):
    """Represents a single cleared check transaction."""
    model_config = ConfigDict(extra='forbid')
    serial_number: ForensicDataEntity
    date: ForensicDataEntity
    amount: ForensicDataEntity


class AccountTransaction(BaseModel):
    """Represents a single non-check transaction (e.g., deposit, ACH, fee)."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    description: ForensicDataEntity
    debit: Optional[ForensicDataEntity] = None
    credit: Optional[ForensicDataEntity] = None


class DailyBalance(BaseModel):
    """Represents the account balance on a specific date."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    amount: ForensicDataEntity


class AccountSummary(BaseModel):
    """Represents the top-level summary of account activity for the period."""
    model_config = ConfigDict(extra='forbid')
    previous_balance_date: ForensicDataEntity
    previous_balance: ForensicDataEntity
    total_credits_count: ForensicDataEntity
    total_credits_amount: ForensicDataEntity
    total_debits_count: ForensicDataEntity
    total_debits_amount: ForensicDataEntity
    current_balance_date: ForensicDataEntity
    current_balance: ForensicDataEntity
    period_days: ForensicDataEntity


class InterestAndFeesSummary(BaseModel):
    """Represents a summary of interest and fees for the statement period and year-to-date."""
    model_config = ConfigDict(extra='forbid')
    payer_federal_id: ForensicDataEntity
    interest_paid_ytd: ForensicDataEntity
    statement_overdraft_charges: ForensicDataEntity
    statement_returned_item_charges: ForensicDataEntity
    ytd_overdraft_charges: ForensicDataEntity
    ytd_returned_item_charges: ForensicDataEntity


class InterestEarnedSummary(BaseModel):
    """Represents a summary of interest earned during the statement period."""
    model_config = ConfigDict(extra='forbid')
    days_in_period: ForensicDataEntity
    interest_earned: ForensicDataEntity
    apy_earned: ForensicDataEntity


class ChemicalBankStatementV1(BaseModel):
    """
    A resilient Pydantic V2 schema for a Chemical Bank checking account statement from 2007.
    """
    model_config = ConfigDict(extra='forbid')

    issuer_name: ForensicDataEntity
    issuer_address: ForensicDataEntity
    issuer_phone: ForensicDataEntity
    recipient_names: List[ForensicDataEntity]
    recipient_address: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_number: ForensicDataEntity
    account_type: ForensicDataEntity
    cycle_code: Optional[ForensicDataEntity] = None
    beginning_rate: Optional[ForensicDataEntity] = None
    account_summary: AccountSummary
    check_transactions: Optional[List[CheckTransaction]] = None
    account_transactions: Optional[List[AccountTransaction]] = None
    daily_balances: Optional[List[DailyBalance]] = None
    interest_and_fees_summary: Optional[InterestAndFeesSummary] = None
    interest_earned_summary: Optional[InterestEarnedSummary] = None

    @model_validator(mode='after')
    def gapp_checksum_validator(self) -> 'ChemicalBankStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to ensure financial integrity.
        1. Validates the primary balance equation: Previous Balance + Credits - Debits = Current Balance.
        2. Validates that the sum of individual transaction amounts equals the summary totals.
        3. Validates that the interest earned summary figure matches the interest payment transaction.
        """
        def get_float(entity: Optional[ForensicDataEntity]) -> float:
            if entity is None or entity.extracted_string_or_numeric_value is None:
                return 0.0
            value = entity.extracted_string_or_numeric_value
            try:
                if isinstance(value, str):
                    return float(value.replace(',', ''))
                return float(value)
            except (ValueError, TypeError):
                return 0.0

        summary = self.account_summary
        prev_bal = get_float(summary.previous_balance)
        total_credits_summary = get_float(summary.total_credits_amount)
        total_debits_summary = get_float(summary.total_debits_amount)
        current_bal = get_float(summary.current_balance)
        epsilon = 0.01

        # 1. Primary Balance Check
        calculated_end_balance = prev_bal + total_credits_summary - total_debits_summary
        if not math.isclose(calculated_end_balance, current_bal, abs_tol=epsilon):
            raise ValueError(
                f"Balance check failed: Prev({prev_bal}) + Credits({total_credits_summary}) - Debits({total_debits_summary}) = {calculated_end_balance}, which does not equal Current({current_bal})."
            )

        # 2. Transaction Summation Check
        sum_of_check_debits = sum(get_float(tx.amount) for tx in self.check_transactions or [])
        sum_of_other_debits = sum(get_float(tx.debit) for tx in self.account_transactions or [])
        sum_of_other_credits = sum(get_float(tx.credit) for tx in self.account_transactions or [])

        total_calculated_debits = sum_of_check_debits + sum_of_other_debits
        total_calculated_credits = sum_of_other_credits

        if not math.isclose(total_calculated_debits, total_debits_summary, abs_tol=epsilon):
            raise ValueError(
                f"Total debits mismatch: Calculated sum of transactions ({total_calculated_debits}) does not match summary total ({total_debits_summary})."
            )
        if not math.isclose(total_calculated_credits, total_credits_summary, abs_tol=epsilon):
            raise ValueError(
                f"Total credits mismatch: Calculated sum of transactions ({total_calculated_credits}) does not match summary total ({total_credits_summary})."
            )

        # 3. Interest Earned Check
        if self.interest_earned_summary:
            interest_earned_summary_amount = get_float(self.interest_earned_summary.interest_earned)
            interest_payment_tx_amount = 0.0
            for tx in self.account_transactions or []:
                if tx.description and 'INTEREST PAYMENT' in str(tx.description.extracted_string_or_numeric_value).upper():
                    interest_payment_tx_amount = get_float(tx.credit)
                    break
            if not math.isclose(interest_earned_summary_amount, interest_payment_tx_amount, abs_tol=epsilon):
                raise ValueError(
                    f"Interest earned mismatch: Summary amount ({interest_earned_summary_amount}) does not match transaction amount ({interest_payment_tx_amount})."
                )

        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "20070213-chemical-bank-0001019524-complex",
    "should_pass": true,
    "taxonomy_lane": "ChemicalBankStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "issuer_name": {
        "extracted_string_or_numeric_value": "CHEMICAL BANK",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 250, 250, 120],
          "vertical_y_vertices": [50, 50, 65, 65]
        }
      },
      "issuer_address": {
        "extracted_string_or_numeric_value": "MCBAIN\n101 N. ROLAND\nMCBAIN, MI 49657",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 250, 250, 120],
          "vertical_y_vertices": [70, 70, 100, 100]
        }
      },
      "issuer_phone": {
        "extracted_string_or_numeric_value": "231-825-2451",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 250, 250, 120],
          "vertical_y_vertices": [110, 110, 120, 120]
        }
      },
      "recipient_names": [
        {
          "extracted_string_or_numeric_value": "JUDITH A GRANDY",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [120, 280, 280, 120],
            "vertical_y_vertices": [160, 160, 170, 170]
          }
        },
        {
          "extracted_string_or_numeric_value": "MARK W KIBBY",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [120, 280, 280, 120],
            "vertical_y_vertices": [171, 171, 181, 181]
          }
        },
        {
          "extracted_string_or_numeric_value": "MICHAEL J KIBBY",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [120, 280, 280, 120],
            "vertical_y_vertices": [182, 182, 192, 192]
          }
        }
      ],
      "recipient_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD\nPO BOX 297\nMARION MI 49665",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 280, 280, 120],
          "vertical_y_vertices": [193, 193, 223, 223]
        }
      },
      "statement_date": {
        "extracted_string_or_numeric_value": "02/13/07",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [150, 150, 160, 160]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "0001019524",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [180, 180, 190, 190]
        }
      },
      "account_type": {
        "extracted_string_or_numeric_value": "ADVANTAGE CHECKING",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [120, 300, 300, 120],
          "vertical_y_vertices": [250, 250, 260, 260]
        }
      },
      "cycle_code": {
        "extracted_string_or_numeric_value": "046",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [210, 210, 220, 220]
        }
      },
      "beginning_rate": {
        "extracted_string_or_numeric_value": 0.20000,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 850, 850, 750],
          "vertical_y_vertices": [230, 230, 240, 240]
        }
      },
      "account_summary": {
        "previous_balance_date": {
          "extracted_string_or_numeric_value": "01/13/07",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 480, 480, 400],
            "vertical_y_vertices": [270, 270, 280, 280]
          }
        },
        "previous_balance": {
          "extracted_string_or_numeric_value": 4540.15,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [270, 270, 280, 280]
          }
        },
        "total_credits_count": {
          "extracted_string_or_numeric_value": 4,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 210, 210, 200],
            "vertical_y_vertices": [281, 281, 291, 291]
          }
        },
        "total_credits_amount": {
          "extracted_string_or_numeric_value": 10389.96,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [281, 281, 291, 291]
          }
        },
        "total_debits_count": {
          "extracted_string_or_numeric_value": 9,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 210, 210, 200],
            "vertical_y_vertices": [292, 292, 302, 302]
          }
        },
        "total_debits_amount": {
          "extracted_string_or_numeric_value": 9817.20,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [292, 292, 302, 302]
          }
        },
        "current_balance_date": {
          "extracted_string_or_numeric_value": "02/13/07",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 480, 480, 400],
            "vertical_y_vertices": [303, 303, 313, 313]
          }
        },
        "current_balance": {
          "extracted_string_or_numeric_value": 5112.91,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [303, 303, 313, 313]
          }
        },
        "period_days": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 520, 520, 500],
            "vertical_y_vertices": [314, 314, 324, 324]
          }
        }
      },
      "check_transactions": [
        {
          "serial_number": {
            "extracted_string_or_numeric_value": "3214",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 180, 180, 120],
              "vertical_y_vertices": [360, 360, 370, 370]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "01/23",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 260, 260, 200],
              "vertical_y_vertices": [360, 360, 370, 370]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 62.79,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 380, 380, 300],
              "vertical_y_vertices": [360, 360, 370, 370]
            }
          }
        },
        {
          "serial_number": {
            "extracted_string_or_numeric_value": "3219*",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 180, 180, 120],
              "vertical_y_vertices": [371, 371, 381, 381]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "02/06",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 260, 260, 200],
              "vertical_y_vertices": [371, 371, 381, 381]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 500.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 380, 380, 300],
              "vertical_y_vertices": [371, 371, 381, 381]
            }
          }
        },
        {
          "serial_number": {
            "extracted_string_or_numeric_value": "3220",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 510, 510, 450],
              "vertical_y_vertices": [360, 360, 370, 370]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "02/07",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530, 590, 590, 530],
              "vertical_y_vertices": [360, 360, 370, 370]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 5000.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630, 710, 710, 630],
              "vertical_y_vertices": [360, 360, 370, 370]
            }
          }
        },
        {
          "serial_number": {
            "extracted_string_or_numeric_value": "3221",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 510, 510, 450],
              "vertical_y_vertices": [371, 371, 381, 381]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "02/09",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530, 590, 590, 530],
              "vertical_y_vertices": [371, 371, 381, 381]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": 178.14,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630, 710, 710, 630],
              "vertical_y_vertices": [371, 371, 381, 381]
            }
          }
        }
      ],
      "account_transactions": [
        {
          "date": {
            "extracted_string_or_numeric_value": "01/17",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [420, 420, 430, 430]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-CONNGENERAL LIFE-INSURANCE",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [420, 420, 430, 430]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 222.68,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 620, 620, 550],
              "vertical_y_vertices": [420, 420, 430, 430]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "01/19",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [431, 431, 441, 441]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [431, 431, 441, 441]
            }
          },
          "debit": null,
          "credit": {
            "extracted_string_or_numeric_value": 418.22,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 720, 720, 650],
              "vertical_y_vertices": [431, 431, 441, 441]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "01/22",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [442, 442, 452, 452]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-CITICARD PAYMENT-CHECK PYMT CK-00003213",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [442, 442, 462, 462]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 2948.28,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 620, 620, 550],
              "vertical_y_vertices": [442, 442, 452, 452]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "01/25",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [463, 463, 473, 473]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-SPARTAN STORES -ACCTSPYBLE ISA*00*",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [463, 463, 483, 483]
            }
          },
          "debit": null,
          "credit": {
            "extracted_string_or_numeric_value": 9470.42,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 720, 720, 650],
              "vertical_y_vertices": [463, 463, 473, 473]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "01/26",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [484, 484, 494, 494]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-GM CARD 3 -CHECKPAYMT CK-00003215",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [484, 484, 504, 504]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 764.01,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 620, 620, 550],
              "vertical_y_vertices": [484, 484, 494, 494]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "01/29",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [505, 505, 515, 515]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-AT&T Services CHECKPAYMT CK-00003216",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [505, 505, 525, 525]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 75.41,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 620, 620, 550],
              "vertical_y_vertices": [505, 505, 515, 515]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/05",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [526, 526, 536, 536]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "AC-JCPENNEY/GEMB -CHECKPAYMT CK-00003218",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [526, 526, 546, 546]
            }
          },
          "debit": {
            "extracted_string_or_numeric_value": 65.89,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 620, 620, 550],
              "vertical_y_vertices": [526, 526, 536, 536]
            }
          },
          "credit": null
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/09",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [547, 547, 557, 557]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "DEPOSIT",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [547, 547, 557, 557]
            }
          },
          "debit": null,
          "credit": {
            "extracted_string_or_numeric_value": 500.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 720, 720, 650],
              "vertical_y_vertices": [547, 547, 557, 557]
            }
          }
        },
        {
          "date": {
            "extracted_string_or_numeric_value": "02/13",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 160, 160, 120],
              "vertical_y_vertices": [558, 558, 568, 568]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "INTEREST PAYMENT",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [170, 450, 450, 170],
              "vertical_y_vertices": [558, 558, 568, 568]
            }
          },
          "debit": null,
          "credit": {
            "extracted_string_or_numeric_value": 1.32,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 720, 720, 650],
              "vertical_y_vertices": [558, 558, 568, 568]
            }
          }
        }
      ],
      "daily_balances": [],
      "interest_and_fees_summary": {
        "payer_federal_id": {
          "extracted_string_or_numeric_value": "38-0415896",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 600, 600, 500],
            "vertical_y_vertices": [680, 680, 690, 690]
          }
        },
        "interest_paid_ytd": {
          "extracted_string_or_numeric_value": 3.26,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [691, 691, 701, 701]
          }
        },
        "statement_overdraft_charges": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [702, 702, 712, 712]
          }
        },
        "statement_returned_item_charges": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [713, 713, 723, 723]
          }
        },
        "ytd_overdraft_charges": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [724, 724, 734, 734]
          }
        },
        "ytd_returned_item_charges": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [735, 735, 745, 745]
          }
        }
      },
      "interest_earned_summary": {
        "days_in_period": {
          "extracted_string_or_numeric_value": 31,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [770, 770, 780, 780]
          }
        },
        "interest_earned": {
          "extracted_string_or_numeric_value": 1.32,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [781, 781, 791, 791]
          }
        },
        "apy_earned": {
          "extracted_string_or_numeric_value": "0.23%",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [780, 850, 850, 780],
            "vertical_y_vertices": [792, 792, 802, 802]
          }
        }
      }
    }
  }
]
```