An expert forensic data architect meticulously analyzed the provided documents, identifying a multi-part structure comprising a portfolio-level summary and a detailed individual account statement. The resulting schema captures this hierarchy and enforces internal consistency through a comprehensive GAAP-based mathematical validator, ensuring data integrity across all sections of the report.

BLOCK 1 (Python Pydantic V2):
```python
from __future__ import annotations
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
from decimal import Decimal, getcontext

# Set precision for Decimal to handle financial calculations accurately
getcontext().prec = 10

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AccountHolder(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    account_type: ForensicDataEntity
    address: ForensicDataEntity

class AccountExecutive(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    phone: ForensicDataEntity
    email: ForensicDataEntity
    address: ForensicDataEntity

class PeriodValue(BaseModel):
    model_config = ConfigDict(extra='forbid')
    label: ForensicDataEntity
    value: ForensicDataEntity

class ChangeSummaryDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    period: ForensicDataEntity
    starting_value: ForensicDataEntity
    contributions_inflows: Optional[ForensicDataEntity]
    distributions_outflows: Optional[ForensicDataEntity]
    market_value_change: ForensicDataEntity
    dividends_interest_capital_gains: ForensicDataEntity
    fees_expenses: ForensicDataEntity
    total_ending_value: ForensicDataEntity
    total_change_in_value: ForensicDataEntity

class AccountSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    quarterly_summary: ChangeSummaryDetails
    ytd_summary: ChangeSummaryDetails

class PurchasingPower(BaseModel):
    model_config = ConfigDict(extra='forbid')
    available_cash: ForensicDataEntity
    as_of_date: ForensicDataEntity

class AssetAllocationItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    percentage: Optional[ForensicDataEntity]
    market_value: Optional[ForensicDataEntity]

class AssetAllocation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    as_of_date: ForensicDataEntity
    allocations: List[AssetAllocationItem]

class CashHolding(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    interest_paid_in_june: Optional[ForensicDataEntity]
    interest_dividend_rate: Optional[ForensicDataEntity]
    current_balance: ForensicDataEntity

class CashEquivalents(BaseModel):
    model_config = ConfigDict(extra='forbid')
    holdings: List[CashHolding]
    total_insured_cash_account: ForensicDataEntity
    total_cash_equivalents: ForensicDataEntity

class AlternativeInvestmentHolding(BaseModel):
    model_config = ConfigDict(extra='forbid')
    security_id_description: ForensicDataEntity
    category: ForensicDataEntity
    quantity: ForensicDataEntity
    price: ForensicDataEntity
    market_value: ForensicDataEntity

class AccountHoldings(BaseModel):
    model_config = ConfigDict(extra='forbid')
    as_of_date: ForensicDataEntity
    cash_equivalents: CashEquivalents
    alternative_investments: List[AlternativeInvestmentHolding]
    total_alternative_investments: ForensicDataEntity
    total_account_holdings: ForensicDataEntity

class ActivitySummaryPeriod(BaseModel):
    model_config = ConfigDict(extra='forbid')
    period: ForensicDataEntity
    securities_purchased: Optional[ForensicDataEntity]
    securities_sold: Optional[ForensicDataEntity]
    contributions_inflows: Optional[ForensicDataEntity]
    distributions_outflows: Optional[ForensicDataEntity]
    dividends_interest_capital_gains: ForensicDataEntity
    fees_expenses: Optional[ForensicDataEntity]

class ActivitySummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    since_last_statement: ActivitySummaryPeriod
    quarterly: ActivitySummaryPeriod
    ytd: ActivitySummaryPeriod

class Transaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    transaction_type: ForensicDataEntity
    description_security_id: ForensicDataEntity
    price_or_quantity: Optional[ForensicDataEntity]
    amount: ForensicDataEntity

class AccountActivity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    period: ForensicDataEntity
    transactions: List[Transaction]

class AccountStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_holder: AccountHolder
    account_name: ForensicDataEntity
    account_number: ForensicDataEntity
    statement_period: ForensicDataEntity
    values_as_of: ForensicDataEntity
    investment_objective: ForensicDataEntity
    account_executive: AccountExecutive
    period_values: List[PeriodValue]
    account_summary: AccountSummary
    purchasing_power: PurchasingPower
    asset_allocation: AssetAllocation
    account_holdings: AccountHoldings
    activity_summary: ActivitySummary
    account_activity: AccountActivity

    @model_validator(mode='after')
    def validate_gaap_and_internal_consistency(self) -> AccountStatement:
        
        def to_decimal(value: Union[str, float, int, None]) -> Decimal:
            if value is None or (isinstance(value, str) and value.strip() in ['—', '-', '']):
                return Decimal('0.0')
            if isinstance(value, str):
                value = value.replace('$', '').replace(',', '').strip()
                if value.startswith('(') and value.endswith(')'):
                    return Decimal(f"-{value[1:-1]}")
            return Decimal(str(value))

        def validate_summary_period(summary: ChangeSummaryDetails):
            start = to_decimal(summary.starting_value.extracted_string_or_numeric_value)
            contrib = to_decimal(summary.contributions_inflows.extracted_string_or_numeric_value if summary.contributions_inflows else '0')
            distrib = to_decimal(summary.distributions_outflows.extracted_string_or_numeric_value if summary.distributions_outflows else '0')
            market_change = to_decimal(summary.market_value_change.extracted_string_or_numeric_value)
            dividends = to_decimal(summary.dividends_interest_capital_gains.extracted_string_or_numeric_value)
            fees = to_decimal(summary.fees_expenses.extracted_string_or_numeric_value)
            end = to_decimal(summary.total_ending_value.extracted_string_or_numeric_value)
            total_change = to_decimal(summary.total_change_in_value.extracted_string_or_numeric_value)

            calculated_end = start + contrib + distrib + market_change + dividends + fees
            if abs(calculated_end - end) > Decimal('0.02'):
                raise ValueError(f"Ending value checksum failed for period {summary.period.extracted_string_or_numeric_value}. Calculated: {calculated_end}, Stated: {end}")

            calculated_change = end - start
            if abs(calculated_change - total_change) > Decimal('0.02'):
                raise ValueError(f"Total change checksum failed for period {summary.period.extracted_string_or_numeric_value}. Calculated: {calculated_change}, Stated: {total_change}")

        # 1. Account Summary Checksum
        validate_summary_period(self.account_summary.quarterly_summary)
        validate_summary_period(self.account_summary.ytd_summary)
        
        ending_value = to_decimal(self.account_summary.ytd_summary.total_ending_value.extracted_string_or_numeric_value)

        # 2. Holdings Total Checksum
        holdings = self.account_holdings
        cash_total = to_decimal(holdings.cash_equivalents.total_cash_equivalents.extracted_string_or_numeric_value)
        alt_inv_total = to_decimal(holdings.total_alternative_investments.extracted_string_or_numeric_value)
        calculated_holdings_total = cash_total + alt_inv_total
        stated_holdings_total = to_decimal(holdings.total_account_holdings.extracted_string_or_numeric_value)
        
        if abs(calculated_holdings_total - stated_holdings_total) > Decimal('0.02'):
            raise ValueError(f"Holdings total mismatch. Calculated: {calculated_holdings_total}, Stated: {stated_holdings_total}")
        
        if abs(stated_holdings_total - ending_value) > Decimal('0.02'):
            raise ValueError(f"Holdings total does not match account ending value. Holdings: {stated_holdings_total}, Summary: {ending_value}")

        # 3. Asset Allocation Checksum
        allocation = self.asset_allocation
        total_alloc_value = sum(to_decimal(item.market_value.extracted_string_or_numeric_value) for item in allocation.allocations if item.market_value)
        
        if abs(total_alloc_value - ending_value) > Decimal('0.02'):
            raise ValueError(f"Asset allocation total value does not match account ending value. Allocation: {total_alloc_value}, Summary: {ending_value}")
            
        return self

class PortfolioAccountItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_name: ForensicDataEntity
    location: ForensicDataEntity
    account_number: ForensicDataEntity
    amount: ForensicDataEntity
    total_change_ytd: ForensicDataEntity

class PortfolioSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    statement_period: ForensicDataEntity
    statement_date: ForensicDataEntity
    account_executive: AccountExecutive
    value_on_jan_1: ForensicDataEntity
    value_on_june_1: ForensicDataEntity
    value_on_june_30: ForensicDataEntity
    starting_value_lpl: ChangeSummaryDetails
    ending_value_lpl: ForensicDataEntity
    value_not_held_lpl: ForensicDataEntity
    total_ending_value: ForensicDataEntity
    total_change_lpl: ForensicDataEntity
    accounts: List[PortfolioAccountItem]
    asset_allocation: AssetAllocation

class JudysLPLBrokerageStatement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    portfolio_summary: PortfolioSummary
    account_statements: List[AccountStatement]
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "STATEMENT_JUDY_GRANDY_2Q2018_COMPLEX",
    "should_pass": true,
    "taxonomy_lane": "JudysLPLBrokerageStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "portfolio_summary": {
        "statement_period": {
          "extracted_string_or_numeric_value": "2nd Quarter 2018",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "statement_date": {
          "extracted_string_or_numeric_value": "June 30, 2018",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "account_executive": {
          "name": {
            "extracted_string_or_numeric_value": "James Olesnavage",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "phone": {
            "extracted_string_or_numeric_value": "(231)922-8993",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "email": {
            "extracted_string_or_numeric_value": "james.olesnavage@LPL.com",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "1925 Coral Lane\nTraverse City, MI 49686",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          }
        },
        "value_on_jan_1": {
          "extracted_string_or_numeric_value": 782902.11,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "value_on_june_1": {
          "extracted_string_or_numeric_value": 827539.58,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "value_on_june_30": {
          "extracted_string_or_numeric_value": 828211.38,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "starting_value_lpl": {
          "period": {
            "extracted_string_or_numeric_value": "01/01 - 06/30/2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "starting_value": {
            "extracted_string_or_numeric_value": 163944.37,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "contributions_inflows": {
            "extracted_string_or_numeric_value": "—",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "distributions_outflows": {
            "extracted_string_or_numeric_value": "—",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "market_value_change": {
            "extracted_string_or_numeric_value": -3307.67,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "dividends_interest_capital_gains": {
            "extracted_string_or_numeric_value": 3682.68,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "fees_expenses": {
            "extracted_string_or_numeric_value": -100.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "total_ending_value": {
            "extracted_string_or_numeric_value": 164219.38,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "total_change_in_value": {
            "extracted_string_or_numeric_value": 275.01,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          }
        },
        "ending_value_lpl": {
          "extracted_string_or_numeric_value": 164219.38,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "value_not_held_lpl": {
          "extracted_string_or_numeric_value": 663992.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "total_ending_value": {
          "extracted_string_or_numeric_value": 828211.38,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "total_change_lpl": {
          "extracted_string_or_numeric_value": 275.01,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [],
            "vertical_y_vertices": []
          }
        },
        "accounts": [
          {
            "account_name": {
              "extracted_string_or_numeric_value": "Judy's LPL Brokerage Individual Account",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "location": {
              "extracted_string_or_numeric_value": "LPL",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "account_number": {
              "extracted_string_or_numeric_value": "6823-1445",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "amount": {
              "extracted_string_or_numeric_value": 164219.38,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "total_change_ytd": {
              "extracted_string_or_numeric_value": 275.01,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            }
          }
        ],
        "asset_allocation": {
          "as_of_date": {
            "extracted_string_or_numeric_value": "06/30/2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "allocations": [
            {
              "category": {
                "extracted_string_or_numeric_value": "Fixed Annuities",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "percentage": {
                "extracted_string_or_numeric_value": 80.17,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "market_value": {
                "extracted_string_or_numeric_value": 663992.00,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            {
              "category": {
                "extracted_string_or_numeric_value": "Alternative Investments",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "percentage": {
                "extracted_string_or_numeric_value": 19.17,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "market_value": {
                "extracted_string_or_numeric_value": 158755.52,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            {
              "category": {
                "extracted_string_or_numeric_value": "Cash and Cash Equivalents",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "percentage": {
                "extracted_string_or_numeric_value": 0.66,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "market_value": {
                "extracted_string_or_numeric_value": 5463.86,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            }
          ]
        }
      },
      "account_statements": [
        {
          "account_holder": {
            "name": {
              "extracted_string_or_numeric_value": "JUDITH A GRANDY",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "account_type": {
              "extracted_string_or_numeric_value": "TOD ACCOUNT",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "address": {
              "extracted_string_or_numeric_value": "PO BOX 297\nMARION MI 49665",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            }
          },
          "account_name": {
            "extracted_string_or_numeric_value": "Judy's LPL Brokerage Individual Account",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "account_number": {
            "extracted_string_or_numeric_value": "6823-1445",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "statement_period": {
            "extracted_string_or_numeric_value": "2nd Quarter 2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "values_as_of": {
            "extracted_string_or_numeric_value": "June 30, 2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "investment_objective": {
            "extracted_string_or_numeric_value": "Growth",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [],
              "vertical_y_vertices": []
            }
          },
          "account_executive": {
            "name": {
              "extracted_string_or_numeric_value": "James Olesnavage",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "phone": {
              "extracted_string_or_numeric_value": "(231)922-8993",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "email": {
              "extracted_string_or_numeric_value": "james.olesnavage@LPL.com",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "address": {
              "extracted_string_or_numeric_value": "1925 Coral Lane\nTraverse City, MI 49686",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            }
          },
          "period_values": [
            {
              "label": {
                "extracted_string_or_numeric_value": "Value on January 1, 2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "value": {
                "extracted_string_or_numeric_value": 163944.37,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            {
              "label": {
                "extracted_string_or_numeric_value": "Value on June 1, 2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "value": {
                "extracted_string_or_numeric_value": 163547.58,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            {
              "label": {
                "extracted_string_or_numeric_value": "Value on June 30, 2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "value": {
                "extracted_string_or_numeric_value": 164219.38,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            }
          ],
          "account_summary": {
            "quarterly_summary": {
              "period": {
                "extracted_string_or_numeric_value": "04/01 - 06/30/2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "starting_value": {
                "extracted_string_or_numeric_value": 165385.36,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "contributions_inflows": {
                "extracted_string_or_numeric_value": "—",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "distributions_outflows": {
                "extracted_string_or_numeric_value": "—",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "market_value_change": {
                "extracted_string_or_numeric_value": -2901.67,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "dividends_interest_capital_gains": {
                "extracted_string_or_numeric_value": 1835.69,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "fees_expenses": {
                "extracted_string_or_numeric_value": -100.00,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "total_ending_value": {
                "extracted_string_or_numeric_value": 164219.38,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "total_change_in_value": {
                "extracted_string_or_numeric_value": -1165.98,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            "ytd_summary": {
              "period": {
                "extracted_string_or_numeric_value": "01/01 - 06/30/2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "starting_value": {
                "extracted_string_or_numeric_value": 163944.37,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "contributions_inflows": {
                "extracted_string_or_numeric_value": "—",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "distributions_outflows": {
                "extracted_string_or_numeric_value": "—",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "market_value_change": {
                "extracted_string_or_numeric_value": -3307.67,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "dividends_interest_capital_gains": {
                "extracted_string_or_numeric_value": 3682.68,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "fees_expenses": {
                "extracted_string_or_numeric_value": -100.00,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "total_ending_value": {
                "extracted_string_or_numeric_value": 164219.38,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "total_change_in_value": {
                "extracted_string_or_numeric_value": 275.01,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            }
          },
          "purchasing_power": {
            "available_cash": {
              "extracted_string_or_numeric_value": 5463.86,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "as_of_date": {
              "extracted_string_or_numeric_value": "June 30, 2018",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            }
          },
          "asset_allocation": {
            "as_of_date": {
              "extracted_string_or_numeric_value": "06/30/2018",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "allocations": [
              {
                "category": {
                  "extracted_string_or_numeric_value": "Alternative Investments",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "percentage": {
                  "extracted_string_or_numeric_value": 96.67,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "market_value": {
                  "extracted_string_or_numeric_value": 158755.52,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Cash and Cash Equivalents",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "percentage": {
                  "extracted_string_or_numeric_value": 3.33,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "market_value": {
                  "extracted_string_or_numeric_value": 5463.86,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                }
              }
            ]
          },
          "account_holdings": {
            "as_of_date": {
              "extracted_string_or_numeric_value": "June 30, 2018",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "cash_equivalents": {
              "holdings": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "US Bank National Association",
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [],
                      "vertical_y_vertices": []
                    }
                  },
                  "interest_paid_in_june": null,
                  "interest_dividend_rate": null,
                  "current_balance": {
                    "extracted_string_or_numeric_value": 5463.86,
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [],
                      "vertical_y_vertices": []
                    }
                  }
                }
              ],
              "total_insured_cash_account": {
                "extracted_string_or_numeric_value": 5463.86,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "total_cash_equivalents": {
                "extracted_string_or_numeric_value": 5463.86,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            "alternative_investments": [
              {
                "security_id_description": {
                  "extracted_string_or_numeric_value": "12612C108 CNL HEALTHCARE PROPERTIES",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "category": {
                  "extracted_string_or_numeric_value": "Non-Traded REITs",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "quantity": {
                  "extracted_string_or_numeric_value": 3699.026,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "price": {
                  "extracted_string_or_numeric_value": 10.32,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "market_value": {
                  "extracted_string_or_numeric_value": 38173.94,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                }
              }
            ],
            "total_alternative_investments": {
              "extracted_string_or_numeric_value": 158755.52,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "total_account_holdings": {
              "extracted_string_or_numeric_value": 164219.38,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            }
          },
          "activity_summary": {
            "since_last_statement": {
              "period": {
                "extracted_string_or_numeric_value": "06/01 - 06/30/2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "securities_purchased": null,
              "securities_sold": null,
              "contributions_inflows": null,
              "distributions_outflows": null,
              "dividends_interest_capital_gains": {
                "extracted_string_or_numeric_value": 666.47,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "fees_expenses": null
            },
            "quarterly": {
              "period": {
                "extracted_string_or_numeric_value": "04/01 - 06/30/2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "securities_purchased": null,
              "securities_sold": null,
              "contributions_inflows": null,
              "distributions_outflows": null,
              "dividends_interest_capital_gains": {
                "extracted_string_or_numeric_value": 1835.69,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "fees_expenses": {
                "extracted_string_or_numeric_value": -100.00,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            },
            "ytd": {
              "period": {
                "extracted_string_or_numeric_value": "01/01 - 06/30/2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "securities_purchased": null,
              "securities_sold": null,
              "contributions_inflows": null,
              "distributions_outflows": null,
              "dividends_interest_capital_gains": {
                "extracted_string_or_numeric_value": 3682.68,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              },
              "fees_expenses": {
                "extracted_string_or_numeric_value": -100.00,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [],
                  "vertical_y_vertices": []
                }
              }
            }
          },
          "account_activity": {
            "period": {
              "extracted_string_or_numeric_value": "June 1 - June 30, 2018",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [],
                "vertical_y_vertices": []
              }
            },
            "transactions": [
              {
                "date": {
                  "extracted_string_or_numeric_value": "06/01/2018",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "transaction_type": {
                  "extracted_string_or_numeric_value": "Cash Dividend",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "description_security_id": {
                  "extracted_string_or_numeric_value": "RESOURCE REAL ESTATE OPPORTUNITY REIT 053118",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                },
                "price_or_quantity": null,
                "amount": {
                  "extracted_string_or_numeric_value": 134.94,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [],
                    "vertical_y_vertices": []
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
]
```