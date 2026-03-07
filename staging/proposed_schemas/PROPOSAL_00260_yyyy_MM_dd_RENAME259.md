An elegant and resilient Pydantic V2 schema has been crafted to parse the provided document variants, incorporating double-entry accounting principles for robust data validation.

### BLOCK 1 (Python Pydantic V2)
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

class Transaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    trans_date: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_balance: ForensicDataEntity
    payments: ForensicDataEntity
    other_credits: ForensicDataEntity
    purchases: ForensicDataEntity
    other_debits: ForensicDataEntity
    cash_adv_bal_transfer: ForensicDataEntity
    fees_charged: ForensicDataEntity
    interest_charged: ForensicDataEntity
    new_balance: ForensicDataEntity

class PaymentInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    new_balance: ForensicDataEntity
    minimum_payment_due: ForensicDataEntity
    payment_due_date: ForensicDataEntity
    late_fee: ForensicDataEntity
    min_payment_payoff_period: ForensicDataEntity
    min_payment_total_amount: ForensicDataEntity

class Rewards(BaseModel):
    model_config = ConfigDict(extra='forbid')
    current_total_points: ForensicDataEntity
    points_to_next_reward: ForensicDataEntity

class CreditDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    credit_limit: ForensicDataEntity
    available_credit: ForensicDataEntity
    cash_credit_limit: ForensicDataEntity
    available_cash: ForensicDataEntity

class InterestCharges(BaseModel):
    model_config = ConfigDict(extra='forbid')
    interest_charge_on_purchases: ForensicDataEntity
    interest_charge_on_cash_adv_bal_transfer: ForensicDataEntity
    total_interest_for_this_period: ForensicDataEntity

class MeijerCreditStatementV1(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_number: ForensicDataEntity
    statement_closing_date: ForensicDataEntity
    days_in_billing_cycle: ForensicDataEntity
    past_due_amount: ForensicDataEntity
    summary: AccountSummary
    payment_info: PaymentInfo
    rewards: Rewards
    credit_details: CreditDetails
    transactions: List[Transaction]
    total_fees_charged: ForensicDataEntity
    interest_charges: Optional[InterestCharges] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'MeijerCreditStatementV1':
        def get_val(entity: ForensicDataEntity) -> float:
            val = entity.extracted_string_or_numeric_value
            if isinstance(val, str):
                return float(val.replace('$', '').replace(',', ''))
            return float(val)

        # Check 1: New Balance Calculation
        calculated_new_balance = (
            get_val(self.summary.previous_balance) +
            get_val(self.summary.purchases) +
            get_val(self.summary.other_debits) +
            get_val(self.summary.cash_adv_bal_transfer) +
            get_val(self.summary.fees_charged) +
            get_val(self.summary.interest_charged) +
            get_val(self.summary.payments) +
            get_val(self.summary.other_credits)
        )
        if not math.isclose(calculated_new_balance, get_val(self.summary.new_balance), rel_tol=1e-4):
            raise ValueError(f"New Balance checksum failed. Calculated: {calculated_new_balance}, Stated: {get_val(self.summary.new_balance)}")

        # Check 2: Transaction Sum vs Summary Totals
        total_purchases_from_transactions = sum(get_val(t.amount) for t in self.transactions if get_val(t.amount) > 0)
        total_payments_from_transactions = sum(get_val(t.amount) for t in self.transactions if get_val(t.amount) < 0)
        if not math.isclose(total_purchases_from_transactions, get_val(self.summary.purchases), rel_tol=1e-4):
            raise ValueError(f"Sum of purchase transactions does not match summary. Calculated: {total_purchases_from_transactions}, Stated: {get_val(self.summary.purchases)}")
        if not math.isclose(total_payments_from_transactions, get_val(self.summary.payments), rel_tol=1e-4):
            raise ValueError(f"Sum of payment transactions does not match summary. Calculated: {total_payments_from_transactions}, Stated: {get_val(self.summary.payments)}")

        # Check 3: Fees consistency
        if not math.isclose(get_val(self.summary.fees_charged), get_val(self.total_fees_charged), rel_tol=1e-4):
            raise ValueError(f"Summary fees charged does not match total fees charged. Summary: {get_val(self.summary.fees_charged)}, Total: {get_val(self.total_fees_charged)}")

        # Check 4: Interest consistency
        if self.interest_charges:
            calculated_total_interest = get_val(self.interest_charges.interest_charge_on_purchases) + get_val(self.interest_charges.interest_charge_on_cash_adv_bal_transfer)
            if not math.isclose(calculated_total_interest, get_val(self.interest_charges.total_interest_for_this_period), rel_tol=1e-4):
                raise ValueError(f"Sum of interest charges does not match total interest. Calculated: {calculated_total_interest}, Stated: {get_val(self.interest_charges.total_interest_for_this_period)}")
            if not math.isclose(get_val(self.summary.interest_charged), get_val(self.interest_charges.total_interest_for_this_period), rel_tol=1e-4):
                raise ValueError(f"Summary interest charged does not match total interest. Summary: {get_val(self.summary.interest_charged)}, Total: {get_val(self.interest_charges.total_interest_for_this_period)}")
        elif not math.isclose(get_val(self.summary.interest_charged), 0.0, abs_tol=1e-9):
            raise ValueError(f"Interest charges section is missing, but summary interest charged is non-zero: {get_val(self.summary.interest_charged)}")

        # Check 5: Credit Limit vs Available Credit
        calculated_available_credit = get_val(self.credit_details.credit_limit) - get_val(self.summary.new_balance)
        if not math.isclose(calculated_available_credit, get_val(self.credit_details.available_credit), rel_tol=1e-4):
            raise ValueError(f"Available credit checksum failed. Calculated: {calculated_available_credit}, Stated: {get_val(self.credit_details.available_credit)}")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "00260_2014-12-15_complex_variant_test",
    "should_pass": true,
    "taxonomy_lane": "MeijerCreditStatementV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "account_number": {
        "extracted_string_or_numeric_value": "5127-1120-1346-5901",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [118, 300], "vertical_y_vertices": [250, 260] }
      },
      "statement_closing_date": {
        "extracted_string_or_numeric_value": "12/15/2014",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 440], "vertical_y_vertices": [480, 490] }
      },
      "days_in_billing_cycle": {
        "extracted_string_or_numeric_value": 31,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 440], "vertical_y_vertices": [495, 505] }
      },
      "past_due_amount": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 440], "vertical_y_vertices": [405, 415] }
      },
      "summary": {
        "previous_balance": { "extracted_string_or_numeric_value": 570.29, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "payments": { "extracted_string_or_numeric_value": -570.29, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "other_credits": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "purchases": { "extracted_string_or_numeric_value": 576.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "other_debits": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "cash_adv_bal_transfer": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "fees_charged": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "interest_charged": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "new_balance": { "extracted_string_or_numeric_value": 576.80, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }
      },
      "payment_info": {
        "new_balance": { "extracted_string_or_numeric_value": "$576.80", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "minimum_payment_due": { "extracted_string_or_numeric_value": "$25.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "payment_due_date": { "extracted_string_or_numeric_value": "01/10/2015", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "late_fee": { "extracted_string_or_numeric_value": "$35.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "min_payment_payoff_period": { "extracted_string_or_numeric_value": "2 years", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "min_payment_total_amount": { "extracted_string_or_numeric_value": 724, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }
      },
      "rewards": {
        "current_total_points": { "extracted_string_or_numeric_value": "1,095", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "points_to_next_reward": { "extracted_string_or_numeric_value": 405, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }
      },
      "credit_details": {
        "credit_limit": { "extracted_string_or_numeric_value": "$4,000.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "available_credit": { "extracted_string_or_numeric_value": "$3,423.20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "cash_credit_limit": { "extracted_string_or_numeric_value": "$800.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "available_cash": { "extracted_string_or_numeric_value": "$800.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }
      },
      "transactions": [
        { "trans_date": { "extracted_string_or_numeric_value": "11/07/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "RICO'S CAFE & PIZZERIA GRAWN MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 29.32, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "11/29/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "PAYMENT - THANK YOU", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": -570.29, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "12/08/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "MEIJER MASTERCARD PURCHASE - Cadillac-MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 154.83, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "12/08/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "MEIJER MASTERCARD PURCHASE - Cadillac-MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 42.54, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "11/20/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "MEIJER MASTERCARD PURCHASE - Cadillac-MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 61.12, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "11/20/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "MEIJER MASTERCARD PURCHASE - Cadillac-MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 204.98, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "12/01/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "MEIJER MASTERCARD PURCHASE - Cadillac-MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 31.93, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
        { "trans_date": { "extracted_string_or_numeric_value": "12/08/2014", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "MEIJER MASTERCARD PURCHASE - Cadillac-MI", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 52.08, "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
      ],
      "total_fees_charged": {
        "extracted_string_or_numeric_value": "$0.00",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [880, 890] }
      },
      "interest_charges": {
        "interest_charge_on_purchases": { "extracted_string_or_numeric_value": "$0.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "interest_charge_on_cash_adv_bal_transfer": { "extracted_string_or_numeric_value": "$0.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } },
        "total_interest_for_this_period": { "extracted_string_or_numeric_value": "$0.00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }
      }
    }
  }
]
```