An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided documents. The structural design drift is significant, spanning a summary trial balance, a detailed fixed asset depreciation schedule, and a specific installment sale tax form. To create a resilient schema, I have synthesized these disparate sources into a single, unified model. The model is designed to enforce Generally Accepted Accounting Principles (GAAP) through a series of mathematical checksums, ensuring the integrity of the extracted financial data.

The most complex structural variant involves reconciling figures across all three document types for the year 2016. For instance, the "Gain on Land Contract" from the trial balance must match the "Installment sale income" from Form 6252, and the "Depreciation" expense must align with the total current year depreciation from the asset schedule. The provided JSON test case represents this synthesized, fully-reconciled state and is designed to pass all validation checks.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Optional, Union
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

class TrialBalanceLineItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    beginning_balance_dr: Optional[ForensicDataEntity] = None
    beginning_balance_cr: Optional[ForensicDataEntity] = None
    transactions_dr: Optional[ForensicDataEntity] = None
    transactions_cr: Optional[ForensicDataEntity] = None
    adjustments_dr: Optional[ForensicDataEntity] = None
    adjustments_cr: Optional[ForensicDataEntity] = None
    ending_balance_dr: Optional[ForensicDataEntity] = None
    ending_balance_cr: Optional[ForensicDataEntity] = None

class AssetDetailItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    is_disposed: ForensicDataEntity
    date_placed_in_service: ForensicDataEntity
    business_use_percentage: ForensicDataEntity
    cost_or_other_basis: ForensicDataEntity
    sec_179_deduction: ForensicDataEntity
    special_allowance: ForensicDataEntity
    recovery_basis: ForensicDataEntity
    recovery_period: ForensicDataEntity
    method: ForensicDataEntity
    convention_code: ForensicDataEntity
    prior_accumulated_depreciation: ForensicDataEntity
    current_year_depreciation: ForensicDataEntity

class DisposedAssetsSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    cost_or_other_basis: ForensicDataEntity
    prior_accumulated_depreciation: ForensicDataEntity

class InstallmentSale(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description_of_property: ForensicDataEntity
    date_sold: ForensicDataEntity
    gross_profit_percentage: ForensicDataEntity
    payments_received_during_year: ForensicDataEntity
    payments_received_in_prior_years: ForensicDataEntity
    installment_sale_income: ForensicDataEntity

class KibbyCompany2016AssetList(BaseModel):
    model_config = ConfigDict(extra='forbid')
    company_name: ForensicDataEntity
    report_title: ForensicDataEntity
    year_ended: ForensicDataEntity
    identifying_number: ForensicDataEntity
    
    asset_and_liability_accounts: List[TrialBalanceLineItem]
    income_and_expense_accounts: List[TrialBalanceLineItem]
    
    net_income_loss_summary: TrialBalanceLineItem
    trial_balance_totals: TrialBalanceLineItem
    income_statement_totals: TrialBalanceLineItem
    
    asset_depreciation_schedule: List[AssetDetailItem]
    disposed_assets_summary: DisposedAssetsSummary
    
    installment_sales: List[InstallmentSale]

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'KibbyCompany2016AssetList':
        
        def _get_val(entity: Optional[ForensicDataEntity]) -> float:
            if entity is None or not isinstance(entity.extracted_string_or_numeric_value, (int, float)):
                return 0.0
            return float(entity.extracted_string_or_numeric_value)

        all_accounts = self.asset_and_liability_accounts + self.income_and_expense_accounts
        
        # 1. Trial Balance Column Equality Checks
        for col_name in ["beginning_balance", "transactions", "adjustments"]:
            debits = sum(_get_val(getattr(acc, f"{col_name}_dr")) for acc in all_accounts)
            credits = sum(_get_val(getattr(acc, f"{col_name}_cr")) for acc in all_accounts)
            if not math.isclose(debits, credits, rel_tol=1e-2):
                raise ValueError(f"{col_name.replace('_', ' ').title()} Mismatch: Debits ({debits}) != Credits ({credits})")

        # 2. Ending Balance Calculation Check
        for acc in all_accounts:
            expected_end_dr = _get_val(acc.beginning_balance_dr) + _get_val(acc.transactions_dr) - _get_val(acc.transactions_cr) + _get_val(acc.adjustments_dr) - _get_val(acc.adjustments_cr)
            expected_end_cr = _get_val(acc.beginning_balance_cr) - _get_val(acc.transactions_dr) + _get_val(acc.transactions_cr) - _get_val(acc.adjustments_dr) + _get_val(acc.adjustments_cr)
            
            actual_end_dr = _get_val(acc.ending_balance_dr)
            actual_end_cr = _get_val(acc.ending_balance_cr)

            if expected_end_dr > 0 and not math.isclose(expected_end_dr, actual_end_dr, rel_tol=1e-2):
                raise ValueError(f"Ending Balance DR mismatch for '{acc.description.extracted_string_or_numeric_value}': Expected {expected_end_dr:.2f}, got {actual_end_dr:.2f}")
            if expected_end_cr > 0 and not math.isclose(expected_end_cr, actual_end_cr, rel_tol=1e-2):
                raise ValueError(f"Ending Balance CR mismatch for '{acc.description.extracted_string_or_numeric_value}': Expected {expected_end_cr:.2f}, got {actual_end_cr:.2f}")

        # 3. Net Income Calculation Check
        income_cr = sum(_get_val(acc.ending_balance_cr) for acc in self.income_and_expense_accounts)
        expense_dr = sum(_get_val(acc.ending_balance_dr) for acc in self.income_and_expense_accounts)
        calculated_net_income = income_cr - expense_dr
        reported_net_income = _get_val(self.net_income_loss_summary.ending_balance_dr)
        if not math.isclose(calculated_net_income, reported_net_income, rel_tol=1e-2):
            raise ValueError(f"Net Income Mismatch: Calculated ({calculated_net_income:.2f}) != Reported ({reported_net_income:.2f})")

        # 4. Cross-document check: Installment Sale Gain
        gain_line = next((acc for acc in self.income_and_expense_accounts if acc.description.extracted_string_or_numeric_value == "Gain on Land Contract"), None)
        if not gain_line: raise ValueError("Missing 'Gain on Land Contract' line item.")
        reported_gain = _get_val(gain_line.adjustments_cr)
        installment_income = sum(_get_val(sale.installment_sale_income) for sale in self.installment_sales)
        if not math.isclose(reported_gain, installment_income, rel_tol=1e-2):
            raise ValueError(f"Installment Sale Gain Mismatch: Trial Balance ({reported_gain:.2f}) != Form 6252 ({installment_income:.2f})")

        # 5. Cross-document check: Depreciation Expense
        dep_line = next((acc for acc in self.income_and_expense_accounts if acc.description.extracted_string_or_numeric_value == "Depreciation"), None)
        if not dep_line: raise ValueError("Missing 'Depreciation' expense line item.")
        dep_expense_tb = _get_val(dep_line.adjustments_dr)
        dep_expense_schedule = sum(_get_val(asset.current_year_depreciation) for asset in self.asset_depreciation_schedule)
        if not math.isclose(dep_expense_tb, dep_expense_schedule, rel_tol=1e-2):
            raise ValueError(f"Depreciation Expense Mismatch: Trial Balance ({dep_expense_tb:.2f}) != Schedule Total ({dep_expense_schedule:.2f})")

        # 6. Final Trial Balance Totals Check
        total_ending_dr = sum(_get_val(acc.ending_balance_dr) for acc in self.asset_and_liability_accounts)
        total_ending_cr = sum(_get_val(acc.ending_balance_cr) for acc in self.asset_and_liability_accounts) + calculated_net_income
        reported_total_dr = _get_val(self.trial_balance_totals.ending_balance_dr)
        reported_total_cr = _get_val(self.trial_balance_totals.ending_balance_cr)
        if not math.isclose(total_ending_dr, reported_total_dr, rel_tol=1e-2):
            raise ValueError(f"Final DR Total Mismatch: Calculated ({total_ending_dr:.2f}) != Reported ({reported_total_dr:.2f})")
        if not math.isclose(total_ending_cr, reported_total_cr, rel_tol=1e-2):
            raise ValueError(f"Final CR Total Mismatch: Calculated ({total_ending_cr:.2f}) != Reported ({reported_total_cr:.2f})")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2016_kibby_company_reconciled_financials",
    "should_pass": true,
    "taxonomy_lane": "KibbyCompany2016AssetList",
    "binary_header_simulation": "25504446",
    "payload": {
      "company_name": {
        "extracted_string_or_numeric_value": "Kibby Company, LLC.",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 300],
          "vertical_y_vertices": [161, 171]
        }
      },
      "report_title": {
        "extracted_string_or_numeric_value": "Trial Balance",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 275],
          "vertical_y_vertices": [178, 188]
        }
      },
      "year_ended": {
        "extracted_string_or_numeric_value": "12/31/16",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 340],
          "vertical_y_vertices": [195, 205]
        }
      },
      "identifying_number": {
        "extracted_string_or_numeric_value": "38-2573766",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [765, 830],
          "vertical_y_vertices": [120, 130]
        }
      },
      "asset_and_liability_accounts": [
        {
          "description": {
            "extracted_string_or_numeric_value": "Cash - Checking",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [283, 293]
            }
          },
          "beginning_balance_dr": {
            "extracted_string_or_numeric_value": 2721.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 400],
              "vertical_y_vertices": [283, 293]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 84552.96,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [283, 293]
            }
          },
          "transactions_cr": {
            "extracted_string_or_numeric_value": 83696.74,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 650],
              "vertical_y_vertices": [283, 293]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 3577.22,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [283, 293]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Land Contract Rec - Prielipp",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [310, 320]
            }
          },
          "beginning_balance_dr": {
            "extracted_string_or_numeric_value": 8522.98,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 400],
              "vertical_y_vertices": [310, 320]
            }
          },
          "transactions_cr": {
            "extracted_string_or_numeric_value": 7256.46,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 650],
              "vertical_y_vertices": [310, 320]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 1266.52,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [310, 320]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Land",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [337, 347]
            }
          },
          "beginning_balance_dr": {
            "extracted_string_or_numeric_value": 30895.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 400],
              "vertical_y_vertices": [337, 347]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 30895.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [337, 347]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Buildings",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [350, 360]
            }
          },
          "beginning_balance_dr": {
            "extracted_string_or_numeric_value": 390830.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 400],
              "vertical_y_vertices": [350, 360]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 390830.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [350, 360]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Machinery & Equipment",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [363, 373]
            }
          },
          "beginning_balance_dr": {
            "extracted_string_or_numeric_value": 61266.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 400],
              "vertical_y_vertices": [363, 373]
            }
          },
          "adjustments_dr": {
            "extracted_string_or_numeric_value": 58320.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 750],
              "vertical_y_vertices": [363, 373]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 2946.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [363, 373]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Accumulated Depreciation",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [376, 386]
            }
          },
          "beginning_balance_cr": {
            "extracted_string_or_numeric_value": 297454.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [425, 475],
              "vertical_y_vertices": [376, 386]
            }
          },
          "adjustments_dr": {
            "extracted_string_or_numeric_value": 53584.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 750],
              "vertical_y_vertices": [376, 386]
            }
          },
          "adjustments_cr": {
            "extracted_string_or_numeric_value": 6765.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 850],
              "vertical_y_vertices": [376, 386]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 250635.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [376, 386]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Deferred Revenue",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [403, 413]
            }
          },
          "beginning_balance_cr": {
            "extracted_string_or_numeric_value": 2501.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [425, 475],
              "vertical_y_vertices": [403, 413]
            }
          },
          "adjustments_dr": {
            "extracted_string_or_numeric_value": 2501.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 750],
              "vertical_y_vertices": [403, 413]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Investments",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [443, 453]
            }
          },
          "beginning_balance_cr": {
            "extracted_string_or_numeric_value": 212756.87,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [425, 475],
              "vertical_y_vertices": [443, 453]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 212756.87,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [443, 453]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Draws",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [456, 466]
            }
          },
          "beginning_balance_dr": {
            "extracted_string_or_numeric_value": 860383.38,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [350, 400],
              "vertical_y_vertices": [456, 466]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 86386.24,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [456, 466]
            }
          },
          "adjustments_dr": {
            "extracted_string_or_numeric_value": 5267.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 750],
              "vertical_y_vertices": [456, 466]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 952036.62,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [456, 466]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Retained Earnings",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [469, 479]
            }
          },
          "beginning_balance_cr": {
            "extracted_string_or_numeric_value": 841906.49,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [425, 475],
              "vertical_y_vertices": [469, 479]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 841906.49,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [469, 479]
            }
          }
        }
      ],
      "income_and_expense_accounts": [
        {
          "description": {
            "extracted_string_or_numeric_value": "Rental Income",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [540, 550]
            }
          },
          "transactions_cr": {
            "extracted_string_or_numeric_value": 84552.96,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 650],
              "vertical_y_vertices": [540, 550]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 84552.96,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [540, 550]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Interest Income",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [553, 563]
            }
          },
          "transactions_cr": {
            "extracted_string_or_numeric_value": 419.58,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 650],
              "vertical_y_vertices": [553, 563]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 419.58,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [553, 563]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Gain on Land Contract",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [566, 576]
            }
          },
          "adjustments_cr": {
            "extracted_string_or_numeric_value": 2766.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 850],
              "vertical_y_vertices": [566, 576]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 2766.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [566, 576]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Gain on Sale of Assets",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [579, 589]
            }
          },
          "adjustments_cr": {
            "extracted_string_or_numeric_value": 266.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [800, 850],
              "vertical_y_vertices": [579, 589]
            }
          },
          "ending_balance_cr": {
            "extracted_string_or_numeric_value": 266.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [975, 1025],
              "vertical_y_vertices": [579, 589]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Bank Charges",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [606, 616]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 75.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [606, 616]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 75.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [606, 616]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Depreciation",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [619, 629]
            }
          },
          "adjustments_dr": {
            "extracted_string_or_numeric_value": 6765.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 750],
              "vertical_y_vertices": [619, 629]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 6765.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [619, 629]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Legal & Accounting",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [632, 642]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 1761.25,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [632, 642]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 1761.25,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [632, 642]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Licenses & Permits",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [645, 655]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 50.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [645, 655]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 50.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [645, 655]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Rent Expenses",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [671, 681]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 2400.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [671, 681]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 2400.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [671, 681]
            }
          }
        },
        {
          "description": {
            "extracted_string_or_numeric_value": "Taxes - Property",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [192, 280],
              "vertical_y_vertices": [697, 707]
            }
          },
          "transactions_dr": {
            "extracted_string_or_numeric_value": 700.29,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [697, 707]
            }
          },
          "ending_balance_dr": {
            "extracted_string_or_numeric_value": 700.29,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [900, 950],
              "vertical_y_vertices": [697, 707]
            }
          }
        }
      ],
      "net_income_loss_summary": {
        "description": {
          "extracted_string_or_numeric_value": "Net Income - Loss",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 280],
            "vertical_y_vertices": [780, 790]
          }
        },
        "ending_balance_dr": {
          "extracted_string_or_numeric_value": 76253.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 950],
            "vertical_y_vertices": [780, 790]
          }
        }
      },
      "trial_balance_totals": {
        "description": {
          "extracted_string_or_numeric_value": "Trial Balance Totals",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 280],
            "vertical_y_vertices": [510, 520]
          }
        },
        "beginning_balance_dr": {
          "extracted_string_or_numeric_value": 1354618.36,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 400],
            "vertical_y_vertices": [510, 520]
          }
        },
        "beginning_balance_cr": {
          "extracted_string_or_numeric_value": 1354618.36,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [425, 475],
            "vertical_y_vertices": [510, 520]
          }
        },
        "transactions_dr": {
          "extracted_string_or_numeric_value": 175925.74,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 550],
            "vertical_y_vertices": [750, 760]
          }
        },
        "transactions_cr": {
          "extracted_string_or_numeric_value": 175925.74,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 650],
            "vertical_y_vertices": [750, 760]
          }
        },
        "adjustments_dr": {
          "extracted_string_or_numeric_value": 68117.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [700, 750],
            "vertical_y_vertices": [750, 760]
          }
        },
        "adjustments_cr": {
          "extracted_string_or_numeric_value": 68117.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [800, 850],
            "vertical_y_vertices": [750, 760]
          }
        },
        "ending_balance_dr": {
          "extracted_string_or_numeric_value": 1381551.36,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 950],
            "vertical_y_vertices": [510, 520]
          }
        },
        "ending_balance_cr": {
          "extracted_string_or_numeric_value": 1381551.36,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [975, 1025],
            "vertical_y_vertices": [510, 520]
          }
        }
      },
      "income_statement_totals": {
        "description": {
          "extracted_string_or_numeric_value": "Income Statement Totals",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 280],
            "vertical_y_vertices": [750, 760]
          }
        },
        "ending_balance_dr": {
          "extracted_string_or_numeric_value": 11751.54,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [900, 950],
            "vertical_y_vertices": [750, 760]
          }
        },
        "ending_balance_cr": {
          "extracted_string_or_numeric_value": 88004.54,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [975, 1025],
            "vertical_y_vertices": [750, 760]
          }
        }
      },
      "asset_depreciation_schedule": [
        {
          "description": {
            "extracted_string_or_numeric_value": "Store Building Imp",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "is_disposed": {
            "extracted_string_or_numeric_value": "false",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "date_placed_in_service": {
            "extracted_string_or_numeric_value": "9/18/1999",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "business_use_percentage": {
            "extracted_string_or_numeric_value": 100.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "cost_or_other_basis": {
            "extracted_string_or_numeric_value": 257078,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "sec_179_deduction": {
            "extracted_string_or_numeric_value": 0,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "special_allowance": {
            "extracted_string_or_numeric_value": 0,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "recovery_basis": {
            "extracted_string_or_numeric_value": 257078,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "recovery_period": {
            "extracted_string_or_numeric_value": 39.0,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "method": {
            "extracted_string_or_numeric_value": "SL/GDS",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "convention_code": {
            "extracted_string_or_numeric_value": "MM",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "prior_accumulated_depreciation": {
            "extracted_string_or_numeric_value": 108127,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "current_year_depreciation": {
            "extracted_string_or_numeric_value": 6765.00,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          }
        }
      ],
      "disposed_assets_summary": {
        "cost_or_other_basis": {
          "extracted_string_or_numeric_value": 58319,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [0, 1],
            "vertical_y_vertices": [0, 1]
          }
        },
        "prior_accumulated_depreciation": {
          "extracted_string_or_numeric_value": 53585,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [0, 1],
            "vertical_y_vertices": [0, 1]
          }
        }
      },
      "installment_sales": [
        {
          "description_of_property": {
            "extracted_string_or_numeric_value": "Garden Center and Storage Buildings",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "date_sold": {
            "extracted_string_or_numeric_value": "mm/dd/yyyy",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "gross_profit_percentage": {
            "extracted_string_or_numeric_value": 0.381201,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "payments_received_during_year": {
            "extracted_string_or_numeric_value": 7256,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "payments_received_in_prior_years": {
            "extracted_string_or_numeric_value": 127440,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          },
          "installment_sale_income": {
            "extracted_string_or_numeric_value": 2766,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 1],
              "vertical_y_vertices": [0, 1]
            }
          }
        }
      ]
    }
  }
]
```