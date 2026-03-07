An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided document class '00121 yyyy-MM-dd_RENAME120'. The primary document is a Upromise MasterCard statement, which includes transactional data, summaries, and personal identifiers. A secondary, unrelated marketing letter was also present but has been correctly identified as extraneous and excluded from the schema design.

The following Pydantic V2 schema is designed for maximum resilience, accommodating the specific structure of the provided statement while being flexible enough for potential variations. It enforces strict data integrity through a `forbid` extra fields policy and validates the document's financial arithmetic using double-entry accounting principles within a model validator.

### BLOCK 1 (Python Pydantic V2):
```python
from __future__ import annotations
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
from decimal import Decimal, ROUND_HALF_UP

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class UpromiseEarningsSummary(BaseModel):
    """Models the earnings summary section of the statement."""
    model_config = ConfigDict(extra='forbid')
    earnings_this_period: ForensicDataEntity
    adjustments: ForensicDataEntity
    earnings_sent_to_upromise: ForensicDataEntity

class PaymentTransaction(BaseModel):
    """Models a single payment transaction."""
    model_config = ConfigDict(extra='forbid')
    transaction_date: ForensicDataEntity
    posting_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class PurchaseTransaction(BaseModel):
    """Models a single purchase or credit transaction."""
    model_config = ConfigDict(extra='forbid')
    transaction_date: ForensicDataEntity
    posting_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class UpromiseCreditCardStatement(BaseModel):
    """
    Represents a Upromise MasterCard statement, capturing account activity,
    earnings, and transaction details.
    """
    model_config = ConfigDict(extra='forbid')

    account_holder_name: ForensicDataEntity
    card_last_digits: ForensicDataEntity
    earnings_summary: UpromiseEarningsSummary
    payments: List[PaymentTransaction]
    total_payments: ForensicDataEntity
    purchases: List[PurchaseTransaction]
    total_purchases: ForensicDataEntity

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'UpromiseCreditCardStatement':
        """
        Performs double-entry GAAP mathematical checksums on financial data.
        1. Validates that the sum of individual payments equals the reported total payment.
        2. Validates that the sum of individual purchases/credits equals the reported total purchase activity.
        3. Validates the earnings summary calculation.
        """
        quantizer = Decimal("0.01")

        # 1. Payments Check
        calculated_payments_sum = sum(
            Decimal(str(p.amount.extracted_string_or_numeric_value)) for p in self.payments
        )
        reported_total_payments = Decimal(str(self.total_payments.extracted_string_or_numeric_value))

        if calculated_payments_sum.quantize(quantizer, rounding=ROUND_HALF_UP) != reported_total_payments.quantize(quantizer, rounding=ROUND_HALF_UP):
            raise ValueError(
                f"Payment sum mismatch: Calculated sum '{calculated_payments_sum}' does not match "
                f"reported total '{reported_total_payments}'."
            )

        # 2. Purchases Check
        calculated_purchases_sum = sum(
            Decimal(str(p.amount.extracted_string_or_numeric_value)) for p in self.purchases
        )
        reported_total_purchases = Decimal(str(self.total_purchases.extracted_string_or_numeric_value))

        if calculated_purchases_sum.quantize(quantizer, rounding=ROUND_HALF_UP) != reported_total_purchases.quantize(quantizer, rounding=ROUND_HALF_UP):
            raise ValueError(
                f"Purchase sum mismatch: Calculated sum '{calculated_purchases_sum}' does not match "
                f"reported total '{reported_total_purchases}'."
            )

        # 3. Earnings Summary Check
        earnings = Decimal(str(self.earnings_summary.earnings_this_period.extracted_string_or_numeric_value))
        adjustments = Decimal(str(self.earnings_summary.adjustments.extracted_string_or_numeric_value))
        sent_to_upromise = Decimal(str(self.earnings_summary.earnings_sent_to_upromise.extracted_string_or_numeric_value))

        if (earnings + adjustments).quantize(quantizer, rounding=ROUND_HALF_UP) != sent_to_upromise.quantize(quantizer, rounding=ROUND_HALF_UP):
            raise ValueError(
                f"Earnings summary mismatch: Calculated sum of earnings and adjustments '{earnings + adjustments}' "
                f"does not match reported 'Earnings Sent to Upromise' '{sent_to_upromise}'."
            )

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "upromise_statement_2014_11_3032_full_activity",
    "should_pass": true,
    "taxonomy_lane": "UpromiseCreditCardStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_holder_name": {
        "extracted_string_or_numeric_value": "JUDITH GRANDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [361, 530],
          "vertical_y_vertices": [343, 352]
        }
      },
      "card_last_digits": {
        "extracted_string_or_numeric_value": "3032",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [638, 670],
          "vertical_y_vertices": [343, 352]
        }
      },
      "earnings_summary": {
        "earnings_this_period": {
          "extracted_string_or_numeric_value": 26.29,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [784, 818],
            "vertical_y_vertices": [113, 122]
          }
        },
        "adjustments": {
          "extracted_string_or_numeric_value": 0.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [784, 818],
            "vertical_y_vertices": [126, 135]
          }
        },
        "earnings_sent_to_upromise": {
          "extracted_string_or_numeric_value": 26.29,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [784, 818],
            "vertical_y_vertices": [139, 148]
          }
        }
      },
      "payments": [
        {
          "transaction_date": {
            "extracted_string_or_numeric_value": "10/26",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [109, 138],
              "vertical_y_vertices": [409, 418]
            }
          },
          "posting_date": {
            "extracted_string_or_numeric_value": "10/28",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [158, 187],
              "vertical_y_vertices": [409, 418]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "ARC Payment Received Thank You",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 470],
              "vertical_y_vertices": [409, 418]
            }
          },
          "amount": {
            "extracted_string_or_numeric_value": -2898.45,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [769, 818],
              "vertical_y_vertices": [409, 418]
            }
          }
        }
      ],
      "total_payments": {
        "extracted_string_or_numeric_value": -2898.45,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [761, 818],
          "vertical_y_vertices": [422, 431]
        }
      },
      "purchases": [
        {"transaction_date": {"extracted_string_or_numeric_value": "10/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [460, 469]}}, "posting_date": {"extracted_string_or_numeric_value": "10/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [460, 469]}}, "description": {"extracted_string_or_numeric_value": "BIG ΒΟΥ 0046 CEDAR SPRINGSMI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [460, 469]}}, "amount": {"extracted_string_or_numeric_value": 22.62, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [460, 469]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [473, 482]}}, "posting_date": {"extracted_string_or_numeric_value": "10/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [473, 482]}}, "description": {"extracted_string_or_numeric_value": "CROUCHING LION INN KAAAWA HI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [473, 482]}}, "amount": {"extracted_string_or_numeric_value": 56.26, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [473, 482]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/12", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [486, 495]}}, "posting_date": {"extracted_string_or_numeric_value": "10/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [486, 495]}}, "description": {"extracted_string_or_numeric_value": "DOLE PLANTATION WAHIAWA HI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [486, 495]}}, "amount": {"extracted_string_or_numeric_value": 10.99, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [486, 495]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/13", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [499, 508]}}, "posting_date": {"extracted_string_or_numeric_value": "10/15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [499, 508]}}, "description": {"extracted_string_or_numeric_value": "TUMI STORES INC HONOLULU HI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [499, 508]}}, "amount": {"extracted_string_or_numeric_value": 141.36, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [777, 818], "vertical_y_vertices": [499, 508]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [512, 521]}}, "posting_date": {"extracted_string_or_numeric_value": "10/15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [512, 521]}}, "description": {"extracted_string_or_numeric_value": "VALULAND 1529 MARION MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [512, 521]}}, "amount": {"extracted_string_or_numeric_value": 73.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [512, 521]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [525, 534]}}, "posting_date": {"extracted_string_or_numeric_value": "10/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [525, 534]}}, "description": {"extracted_string_or_numeric_value": "MIDAS OF CADILLAC LLC CADILLAC MIK. Breaks + Axels", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [525, 534]}}, "amount": {"extracted_string_or_numeric_value": 293.74, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [777, 818], "vertical_y_vertices": [525, 534]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [538, 547]}}, "posting_date": {"extracted_string_or_numeric_value": "10/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [538, 547]}}, "description": {"extracted_string_or_numeric_value": "SURF LANΑΙ HONOLULU HI CAM-LAND", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [538, 547]}}, "amount": {"extracted_string_or_numeric_value": 32.43, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [538, 547]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/14", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [551, 560]}}, "posting_date": {"extracted_string_or_numeric_value": "10/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [551, 560]}}, "description": {"extracted_string_or_numeric_value": "TRH INSPIRED #1407 HONOLULU HI Souviners", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [551, 560]}}, "amount": {"extracted_string_or_numeric_value": 149.74, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [777, 818], "vertical_y_vertices": [551, 560]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/15", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [564, 573]}}, "posting_date": {"extracted_string_or_numeric_value": "10/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [564, 573]}}, "description": {"extracted_string_or_numeric_value": "BOB EVANS REST #0063 GRAND RAPID MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [564, 573]}}, "amount": {"extracted_string_or_numeric_value": 24.31, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [564, 573]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [577, 586]}}, "posting_date": {"extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [577, 586]}}, "description": {"extracted_string_or_numeric_value": "LIFE LINE SCREENING 800-4392350 OH", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [577, 586]}}, "amount": {"extracted_string_or_numeric_value": -224.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [770, 818], "vertical_y_vertices": [577, 586]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/18", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [590, 599]}}, "posting_date": {"extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [590, 599]}}, "description": {"extracted_string_or_numeric_value": "VALULAND 1529 MARION MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [590, 599]}}, "amount": {"extracted_string_or_numeric_value": 77.69, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [590, 599]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [603, 612]}}, "posting_date": {"extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [603, 612]}}, "description": {"extracted_string_or_numeric_value": "MACKENZIES BIG BOY HOUGHTON LAKEMI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [603, 612]}}, "amount": {"extracted_string_or_numeric_value": 17.29, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [603, 612]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/17", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [616, 625]}}, "posting_date": {"extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [616, 625]}}, "description": {"extracted_string_or_numeric_value": "SHELL OIL 521580900QPS MARION MI K-J Sue whir.", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [616, 625]}}, "amount": {"extracted_string_or_numeric_value": 25.44, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [616, 625]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [629, 638]}}, "posting_date": {"extracted_string_or_numeric_value": "10/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [629, 638]}}, "description": {"extracted_string_or_numeric_value": "BOB EVANS REST #2063 CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [629, 638]}}, "amount": {"extracted_string_or_numeric_value": 30.40, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [629, 638]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [642, 651]}}, "posting_date": {"extracted_string_or_numeric_value": "10/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [642, 651]}}, "description": {"extracted_string_or_numeric_value": "BIRCHWOOD RESTAURANT FARWELL MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [642, 651]}}, "amount": {"extracted_string_or_numeric_value": 24.88, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [642, 651]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/21", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [655, 664]}}, "posting_date": {"extracted_string_or_numeric_value": "10/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [655, 664]}}, "description": {"extracted_string_or_numeric_value": "SUNOCO 0276572500 FARWELL MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [655, 664]}}, "amount": {"extracted_string_or_numeric_value": 32.24, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [655, 664]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [668, 677]}}, "posting_date": {"extracted_string_or_numeric_value": "10/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [668, 677]}}, "description": {"extracted_string_or_numeric_value": "TRENDZ BY CK DESIGN MCBAIN MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [668, 677]}}, "amount": {"extracted_string_or_numeric_value": 17.97, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [668, 677]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [681, 690]}}, "posting_date": {"extracted_string_or_numeric_value": "10/23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [681, 690]}}, "description": {"extracted_string_or_numeric_value": "VALULAND 1529 MARION MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [681, 690]}}, "amount": {"extracted_string_or_numeric_value": 60.64, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [681, 690]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [694, 703]}}, "posting_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [694, 703]}}, "description": {"extracted_string_or_numeric_value": "YOUR SISTERS CLOSET CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [694, 703]}}, "amount": {"extracted_string_or_numeric_value": 93.28, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [694, 703]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [707, 716]}}, "posting_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [707, 716]}}, "description": {"extracted_string_or_numeric_value": "MIDAS OF CADILLAC LLC CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [707, 716]}}, "amount": {"extracted_string_or_numeric_value": 31.30, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [707, 716]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [720, 729]}}, "posting_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [720, 729]}}, "description": {"extracted_string_or_numeric_value": "REEDY SRESTAURANT MCBAIN MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [720, 729]}}, "amount": {"extracted_string_or_numeric_value": 6.51, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [720, 729]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [733, 742]}}, "posting_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [733, 742]}}, "description": {"extracted_string_or_numeric_value": "BLARNEY CASTLE OIL CO. 2318643111 MI K-J Diesel", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [733, 742]}}, "amount": {"extracted_string_or_numeric_value": 603.25, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [777, 818], "vertical_y_vertices": [733, 742]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [746, 755]}}, "posting_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [746, 755]}}, "description": {"extracted_string_or_numeric_value": "RICO'S CAFE & PIZZERIA GRAWN MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [746, 755]}}, "amount": {"extracted_string_or_numeric_value": 26.98, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [746, 755]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [759, 768]}}, "posting_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [759, 768]}}, "description": {"extracted_string_or_numeric_value": "TRACTOR-SUPPLY-CO #064 TRAVERSECITYMI 大ーレ", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [759, 768]}}, "amount": {"extracted_string_or_numeric_value": 8.47, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [759, 768]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [772, 781]}}, "posting_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [772, 781]}}, "description": {"extracted_string_or_numeric_value": "THE OLIVE GARD00016709 TRAVERSECITYMI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [772, 781]}}, "amount": {"extracted_string_or_numeric_value": 12.05, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [772, 781]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/26", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [785, 794]}}, "posting_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [785, 794]}}, "description": {"extracted_string_or_numeric_value": "THE TIMBERS RESTAURANT CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [785, 794]}}, "amount": {"extracted_string_or_numeric_value": 37.45, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [785, 794]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/24", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [798, 807]}}, "posting_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [798, 807]}}, "description": {"extracted_string_or_numeric_value": "LONG LAKE MARINA INTERLOCHEN MI K-G Fish", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [798, 807]}}, "amount": {"extracted_string_or_numeric_value": 167.39, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [777, 818], "vertical_y_vertices": [798, 807]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [811, 820]}}, "posting_date": {"extracted_string_or_numeric_value": "10/28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [811, 820]}}, "description": {"extracted_string_or_numeric_value": "VALULAND 1529 MARION MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [811, 820]}}, "amount": {"extracted_string_or_numeric_value": 67.51, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [811, 820]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [824, 833]}}, "posting_date": {"extracted_string_or_numeric_value": "10/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [824, 833]}}, "description": {"extracted_string_or_numeric_value": "BIG BOY 0061 CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [824, 833]}}, "amount": {"extracted_string_or_numeric_value": 16.16, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [824, 833]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [837, 846]}}, "posting_date": {"extracted_string_or_numeric_value": "10/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [837, 846]}}, "description": {"extracted_string_or_numeric_value": "NORTHLAND TRAILERS CADILLAC MI New TK-Topper", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [837, 846]}}, "amount": {"extracted_string_or_numeric_value": 500.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [777, 818], "vertical_y_vertices": [837, 846]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/29", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [850, 859]}}, "posting_date": {"extracted_string_or_numeric_value": "10/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [850, 859]}}, "description": {"extracted_string_or_numeric_value": "ESI MAIL PHARMACY S 8003325455 ΜΟ med", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 720], "vertical_y_vertices": [850, 859]}}, "amount": {"extracted_string_or_numeric_value": 15.61, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [850, 859]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "10/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [863, 872]}}, "posting_date": {"extracted_string_or_numeric_value": "10/31", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [863, 872]}}, "description": {"extracted_string_or_numeric_value": "VALULAND 1529 MARION MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [863, 872]}}, "amount": {"extracted_string_or_numeric_value": 90.31, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [863, 872]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "11/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [876, 885]}}, "posting_date": {"extracted_string_or_numeric_value": "11/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [876, 885]}}, "description": {"extracted_string_or_numeric_value": "VALULAND 1529 MARION MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [876, 885]}}, "amount": {"extracted_string_or_numeric_value": 28.75, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [876, 885]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "11/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [889, 898]}}, "posting_date": {"extracted_string_or_numeric_value": "11/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [889, 898]}}, "description": {"extracted_string_or_numeric_value": "RUBY TUESDAY #7044 CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [889, 898]}}, "amount": {"extracted_string_or_numeric_value": 8.97, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [889, 898]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "11/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [902, 911]}}, "posting_date": {"extracted_string_or_numeric_value": "11/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [902, 911]}}, "description": {"extracted_string_or_numeric_value": "WAL-MART #1432 CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [902, 911]}}, "amount": {"extracted_string_or_numeric_value": 41.64, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [902, 911]}}},
        {"transaction_date": {"extracted_string_or_numeric_value": "11/10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [110, 138], "vertical_y_vertices": [915, 924]}}, "posting_date": {"extracted_string_or_numeric_value": "11/11", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [158, 187], "vertical_y_vertices": [915, 924]}}, "description": {"extracted_string_or_numeric_value": "TRACTOR-SUPPLY-CO #063 CADILLAC MI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": {"horizontal_x_vertices": [221, 550], "vertical_y_vertices": [915, 924]}}, "amount": {"extracted_string_or_numeric_value": 8.47, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": {"horizontal_x_vertices": [784, 818], "vertical_y_vertices": [915, 924]}}}
      ],
      "total_purchases": {
        "extracted_string_or_numeric_value": 2631.10,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [769, 818],
          "vertical_y_vertices": [939, 948]
        }
      }
    }
  }
]
```