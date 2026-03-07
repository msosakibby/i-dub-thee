An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document images to design a resilient Pydantic V2 schema. This schema accommodates the structural layout of the Meijer Platinum MasterCard statement issued by Synchrony Bank, ensuring data integrity through strict validation and double-entry accounting principles.

### BLOCK 1 (Python Pydantic V2)
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional
import decimal

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the physical coordinates of an extracted data entity on the source document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single data point, containing its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AccountSummary(BaseModel):
    """Models the 'Summary of Account Activity' section."""
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    payments: ForensicDataEntity
    purchases_debits: ForensicDataEntity
    new_balance: ForensicDataEntity

class CreditDetails(BaseModel):
    """Models the credit limit and availability section."""
    model_config = ConfigDict(extra='forbid')
    credit_limit: ForensicDataEntity
    available_credit: ForensicDataEntity
    cash_limit: ForensicDataEntity
    available_cash: ForensicDataEntity

class MinimumPaymentExample(BaseModel):
    """Models a single row from the 'Minimum Payment Warning' example table."""
    model_config = ConfigDict(extra='forbid')
    payment_amount_description: ForensicDataEntity
    payoff_time_estimate: ForensicDataEntity
    total_paid_estimate: ForensicDataEntity

class PaymentInformation(BaseModel):
    """Models the 'Payment Information' section."""
    model_config = ConfigDict(extra='forbid')
    new_balance: ForensicDataEntity
    total_minimum_payment_due: ForensicDataEntity
    payment_due_date: ForensicDataEntity
    late_payment_fee: ForensicDataEntity
    minimum_payment_warnings: List[MinimumPaymentExample]

class RewardsSummary(BaseModel):
    """Models the 'Meijer Rewards Summary' section."""
    model_config = ConfigDict(extra='forbid')
    prior_points_balance: ForensicDataEntity
    points_earned_this_period: ForensicDataEntity
    points_redeemed_this_period: ForensicDataEntity
    new_points_total: ForensicDataEntity
    meijer_base_points: ForensicDataEntity
    outside_base_points: ForensicDataEntity

class MeijerCreditStatementV1(BaseModel):
    """
    A resilient Pydantic V2 schema for Meijer Platinum MasterCard statements.
    This schema enforces Zero-Trust principles through strict data validation and
    double-entry GAAP checksums.
    """
    model_config = ConfigDict(extra='forbid')
    
    card_name: ForensicDataEntity
    cardholder_name: ForensicDataEntity
    account_number: ForensicDataEntity
    customer_service_phone: ForensicDataEntity
    website: ForensicDataEntity
    
    statement_closing_date: ForensicDataEntity
    days_in_billing_cycle: ForensicDataEntity
    
    account_summary: AccountSummary
    credit_details: CreditDetails
    payment_information: PaymentInformation
    rewards_summary: RewardsSummary
    
    page_info: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'MeijerCreditStatementV1':
        """
        Performs double-entry GAAP mathematical checksums to ensure data integrity.
        This validator checks the main account summary and the rewards points calculation.
        """
        # Use Decimal for financial calculations to avoid floating point inaccuracies
        ctx = decimal.Context(prec=10)

        # Check 1: Account Activity Summary
        previous_balance = ctx.create_decimal(self.account_summary.previous_balance.extracted_string_or_numeric_value)
        payments = ctx.create_decimal(self.account_summary.payments.extracted_string_or_numeric_value)
        purchases_debits = ctx.create_decimal(self.account_summary.purchases_debits.extracted_string_or_numeric_value)
        new_balance = ctx.create_decimal(self.account_summary.new_balance.extracted_string_or_numeric_value)
        
        calculated_new_balance = previous_balance - payments + purchases_debits
        
        if not abs(calculated_new_balance - new_balance) <= decimal.Decimal('0.01'):
            raise ValueError(
                f"Account summary checksum failed: "
                f"Previous Balance ({previous_balance}) - Payments ({payments}) + Purchases/Debits ({purchases_debits}) = {calculated_new_balance}, "
                f"which does not match the New Balance ({new_balance})."
            )
            
        # Check 2: Rewards Points Summary
        prior_points = ctx.create_decimal(self.rewards_summary.prior_points_balance.extracted_string_or_numeric_value)
        points_earned = ctx.create_decimal(self.rewards_summary.points_earned_this_period.extracted_string_or_numeric_value)
        points_redeemed = ctx.create_decimal(self.rewards_summary.points_redeemed_this_period.extracted_string_or_numeric_value)
        new_points = ctx.create_decimal(self.rewards_summary.new_points_total.extracted_string_or_numeric_value)
        
        calculated_new_points = prior_points + points_earned - points_redeemed
        
        if not abs(calculated_new_points - new_points) <= decimal.Decimal('0.01'):
            raise ValueError(
                f"Rewards points checksum failed: "
                f"Prior Points ({prior_points}) + Points Earned ({points_earned}) - Points Redeemed ({points_redeemed}) = {calculated_new_points}, "
                f"which does not match the New Points Total ({new_points})."
            )

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "meijer-statement-2014-09-17-complex-variant",
    "should_pass": true,
    "taxonomy_lane": "MeijerCreditStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "card_name": {
        "extracted_string_or_numeric_value": "Meijer Platinum MasterCard®",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [29, 278],
          "vertical_y_vertices": [21, 55]
        }
      },
      "cardholder_name": {
        "extracted_string_or_numeric_value": "JUDITH A GRANDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [357, 484],
          "vertical_y_vertices": [21, 32]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "5148 6550 0484 4885",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [357, 649],
          "vertical_y_vertices": [34, 45]
        }
      },
      "customer_service_phone": {
        "extracted_string_or_numeric_value": "1-866-789-6041",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [855, 960],
          "vertical_y_vertices": [55, 66]
        }
      },
      "website": {
        "extracted_string_or_numeric_value": "www.meijer.com/creditcard",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 960],
          "vertical_y_vertices": [21, 32]
        }
      },
      "statement_closing_date": {
        "extracted_string_or_numeric_value": "09/17/2014",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [417, 499],
          "vertical_y_vertices": [309, 320]
        }
      },
      "days_in_billing_cycle": {
        "extracted_string_or_numeric_value": 30,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [479, 499],
          "vertical_y_vertices": [329, 340]
        }
      },
      "page_info": {
        "extracted_string_or_numeric_value": "PAGE 1 of 5",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [477, 550],
          "vertical_y_vertices": [979, 990]
        }
      },
      "account_summary": {
        "previous_balance": {
          "extracted_string_or_numeric_value": 399.84,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [440, 499],
            "vertical_y_vertices": [117, 128]
          }
        },
        "payments": {
          "extracted_string_or_numeric_value": 399.84,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [440, 499],
            "vertical_y_vertices": [137, 148]
          }
        },
        "purchases_debits": {
          "extracted_string_or_numeric_value": 67.70,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [447, 499],
            "vertical_y_vertices": [157, 168]
          }
        },
        "new_balance": {
          "extracted_string_or_numeric_value": 67.70,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [447, 499],
            "vertical_y_vertices": [177, 188]
          }
        }
      },
      "credit_details": {
        "credit_limit": {
          "extracted_string_or_numeric_value": 4000.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [428, 499],
            "vertical_y_vertices": [229, 240]
          }
        },
        "available_credit": {
          "extracted_string_or_numeric_value": 3855.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [428, 499],
            "vertical_y_vertices": [249, 260]
          }
        },
        "cash_limit": {
          "extracted_string_or_numeric_value": 800.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [440, 499],
            "vertical_y_vertices": [269, 280]
          }
        },
        "available_cash": {
          "extracted_string_or_numeric_value": 800.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [440, 499],
            "vertical_y_vertices": [289, 300]
          }
        }
      },
      "payment_information": {
        "new_balance": {
          "extracted_string_or_numeric_value": 67.70,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [909, 960],
            "vertical_y_vertices": [107, 118]
          }
        },
        "total_minimum_payment_due": {
          "extracted_string_or_numeric_value": 25.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [909, 960],
            "vertical_y_vertices": [127, 138]
          }
        },
        "payment_due_date": {
          "extracted_string_or_numeric_value": "10/10/2014",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [897, 960],
            "vertical_y_vertices": [147, 158]
          }
        },
        "late_payment_fee": {
          "extracted_string_or_numeric_value": 35.00,
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [890, 960],
            "vertical_y_vertices": [199, 210]
          }
        },
        "minimum_payment_warnings": [
          {
            "payment_amount_description": {
              "extracted_string_or_numeric_value": "Only the minimum payment",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [540, 680],
                "vertical_y_vertices": [410, 440]
              }
            },
            "payoff_time_estimate": {
              "extracted_string_or_numeric_value": "3 months",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [700, 790],
                "vertical_y_vertices": [420, 430]
              }
            },
            "total_paid_estimate": {
              "extracted_string_or_numeric_value": 70.00,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [860, 920],
                "vertical_y_vertices": [420, 430]
              }
            }
          }
        ]
      },
      "rewards_summary": {
        "prior_points_balance": {
          "extracted_string_or_numeric_value": 1452,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 499],
            "vertical_y_vertices": [555, 566]
          }
        },
        "points_earned_this_period": {
          "extracted_string_or_numeric_value": 68,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [475, 499],
            "vertical_y_vertices": [575, 586]
          }
        },
        "points_redeemed_this_period": {
          "extracted_string_or_numeric_value": 1500,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 499],
            "vertical_y_vertices": [595, 606]
          }
        },
        "new_points_total": {
          "extracted_string_or_numeric_value": 20,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [481, 499],
            "vertical_y_vertices": [615, 626]
          }
        },
        "meijer_base_points": {
          "extracted_string_or_numeric_value": 68,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [481, 499],
            "vertical_y_vertices": [665, 676]
          }
        },
        "outside_base_points": {
          "extracted_string_or_numeric_value": 0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [488, 499],
            "vertical_y_vertices": [685, 696]
          }
        }
      }
    }
  }
]
```