An expert forensic data architect, I have meticulously analyzed the provided Antenuptial Agreement. The document, while a single instance, is structurally complex, containing detailed legal clauses and two comprehensive financial inventories. This complexity serves as an excellent basis for a resilient schema, anticipating variations in data completeness, such as the fully detailed finances for one party versus the partially completed sections for the other.

The Pydantic V2 schema below is designed to capture this complexity. It uses nested models to mirror the document's hierarchical structure, from the high-level parties and dates down to individual line items in the financial worksheets. `Optional` types are used for fields that may not be present in all instances, such as Keith Grandy's missing expense summary. The mandatory `model_validator` implements double-entry accounting principles, performing checksums on assets, debts, income, and expenses to ensure mathematical integrity, a critical function under a Zero-Trust mandate.

The accompanying JSON test case represents this "most complex structural variant," populating the entire schema with data extracted from the document. It includes both financial disclosures, testing the schema's ability to handle complete and incomplete data sets within the same document structure, and is designed to pass the rigorous mathematical validation.

***

### BLOCK 1 (Python Pydantic V2)
```python
from pydantic import BaseModel, Field, ConfigDict, model_validator
from typing import List, Union, Optional
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

class Child(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    age: ForensicDataEntity

class Attorney(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity

class Party(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    role: str
    residence: ForensicDataEntity
    occupation: Optional[ForensicDataEntity] = None
    children: List[Child]
    attorney: Attorney
    signature: ForensicDataEntity

class Notary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    county: ForensicDataEntity
    state: ForensicDataEntity

class AssetItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    value: ForensicDataEntity
    ownership_percentage: Optional[ForensicDataEntity] = None

class BusinessAssetItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    form: ForensicDataEntity
    ownership_percentage: ForensicDataEntity
    value: ForensicDataEntity

class Assets(BaseModel):
    model_config = ConfigDict(extra='forbid')
    real_estate: List[AssetItem]
    cash_and_bank_accounts: List[AssetItem]
    investments: List[AssetItem]
    retirement: List[AssetItem]
    personal_property: List[AssetItem]
    business_ownership: List[BusinessAssetItem]
    money_owed_to_party: List[AssetItem]

class DebtItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    owed_to: ForensicDataEntity
    description: Optional[ForensicDataEntity] = None
    balance: ForensicDataEntity

class Debts(BaseModel):
    model_config = ConfigDict(extra='forbid')
    secured_loans: Optional[List[DebtItem]] = None
    credit_card_debts: Optional[List[DebtItem]] = None
    bank_loans: Optional[List[DebtItem]] = None
    private_loans: Optional[List[DebtItem]] = None

class IncomeItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    type: ForensicDataEntity
    amount: ForensicDataEntity

class Income(BaseModel):
    model_config = ConfigDict(extra='forbid')
    income_items: List[IncomeItem]

class ExpenseItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    description: ForensicDataEntity
    annual_amount: ForensicDataEntity

class Expenses(BaseModel):
    model_config = ConfigDict(extra='forbid')
    expense_items: List[ExpenseItem]

class FinancialDisclosure(BaseModel):
    model_config = ConfigDict(extra='forbid')
    party_name: ForensicDataEntity
    worksheet_date: ForensicDataEntity
    assets: Assets
    debts: Debts
    income: Income
    expenses: Optional[Expenses] = None
    total_assets: ForensicDataEntity
    total_debts: ForensicDataEntity
    total_income: ForensicDataEntity
    total_expenses: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_financials(self) -> 'FinancialDisclosure':
        # Asset checksum
        calculated_assets = 0.0
        asset_lists = [
            self.assets.real_estate,
            self.assets.cash_and_bank_accounts,
            self.assets.investments,
            self.assets.retirement,
            self.assets.personal_property,
            self.assets.money_owed_to_party
        ]
        for asset_list in asset_lists:
            for item in asset_list:
                if isinstance(item.value.extracted_string_or_numeric_value, (int, float)):
                    calculated_assets += item.value.extracted_string_or_numeric_value
        
        for item in self.assets.business_ownership:
            if isinstance(item.value.extracted_string_or_numeric_value, (int, float)):
                calculated_assets += item.value.extracted_string_or_numeric_value

        reported_assets = self.total_assets.extracted_string_or_numeric_value
        if not isinstance(reported_assets, (int, float)) or not math.isclose(calculated_assets, reported_assets, abs_tol=1.0):
            raise ValueError(f"Asset checksum failed for {self.party_name.extracted_string_or_numeric_value}. Calculated: {calculated_assets}, Reported: {reported_assets}")

        # Debt checksum
        calculated_debts = 0.0
        debt_lists = [
            self.debts.secured_loans,
            self.debts.credit_card_debts,
            self.debts.bank_loans,
            self.debts.private_loans
        ]
        for debt_list in debt_lists:
            if debt_list:
                for item in debt_list:
                    if isinstance(item.balance.extracted_string_or_numeric_value, (int, float)):
                        calculated_debts += item.balance.extracted_string_or_numeric_value
        
        reported_debts = self.total_debts.extracted_string_or_numeric_value
        if not isinstance(reported_debts, (int, float)) or not math.isclose(calculated_debts, reported_debts, rel_tol=1e-5):
            raise ValueError(f"Debt checksum failed for {self.party_name.extracted_string_or_numeric_value}. Calculated: {calculated_debts}, Reported: {reported_debts}")

        # Income checksum
        calculated_income = sum(
            item.amount.extracted_string_or_numeric_value
            for item in self.income.income_items
            if isinstance(item.amount.extracted_string_or_numeric_value, (int, float))
        )
        reported_income = self.total_income.extracted_string_or_numeric_value
        if not isinstance(reported_income, (int, float)) or not math.isclose(calculated_income, reported_income, rel_tol=1e-5):
            raise ValueError(f"Income checksum failed for {self.party_name.extracted_string_or_numeric_value}. Calculated: {calculated_income}, Reported: {reported_income}")

        # Expense checksum (optional)
        if self.expenses and self.total_expenses:
            calculated_expenses = sum(
                item.annual_amount.extracted_string_or_numeric_value
                for item in self.expenses.expense_items
                if isinstance(item.annual_amount.extracted_string_or_numeric_value, (int, float))
            )
            reported_expenses = self.total_expenses.extracted_string_or_numeric_value
            if not isinstance(reported_expenses, (int, float)) or not math.isclose(calculated_expenses, reported_expenses, rel_tol=1e-5):
                raise ValueError(f"Expense checksum failed for {self.party_name.extracted_string_or_numeric_value}. Calculated: {calculated_expenses}, Reported: {reported_expenses}")

        return self

class AntenuptialAgreement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    parties: List[Party]
    marriage_date: ForensicDataEntity
    agreement_date: ForensicDataEntity
    governing_law_state: ForensicDataEntity
    financial_disclosures: List[FinancialDisclosure]
    notary: Notary
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "antenuptial_agreement_grandy_kibby_2005_07_16.pdf",
    "should_pass": true,
    "taxonomy_lane": "AntenuptialAgreement",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "Antenuptial Agreement",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300, 300, 100],
          "vertical_y_vertices": [100, 100, 120, 120]
        }
      },
      "parties": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Judith A. Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "role": "Spouse1",
          "residence": {
            "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Michigan 49665",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "occupation": {
            "extracted_string_or_numeric_value": "Retired",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "children": [
            {
              "name": {
                "extracted_string_or_numeric_value": "Mark",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              },
              "age": {
                "extracted_string_or_numeric_value": 31,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              }
            },
            {
              "name": {
                "extracted_string_or_numeric_value": "Michael",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              },
              "age": {
                "extracted_string_or_numeric_value": 30,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              }
            }
          ],
          "attorney": {
            "name": {
              "extracted_string_or_numeric_value": "John Martin",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [100, 300, 300, 100],
                "vertical_y_vertices": [100, 100, 120, 120]
              }
            }
          },
          "signature": {
            "extracted_string_or_numeric_value": "Judith A. Kibby",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Keith A. Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "role": "Spouse2",
          "residence": {
            "extracted_string_or_numeric_value": "4316 21 Mile Road, Marion, Michigan 49665",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "occupation": {
            "extracted_string_or_numeric_value": "Station Mechanic A at Consumers Energy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "children": [
            {
              "name": {
                "extracted_string_or_numeric_value": "Jody",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              },
              "age": {
                "extracted_string_or_numeric_value": 34,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              }
            },
            {
              "name": {
                "extracted_string_or_numeric_value": "Jason",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              },
              "age": {
                "extracted_string_or_numeric_value": 31,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              }
            },
            {
              "name": {
                "extracted_string_or_numeric_value": "Amanda",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              },
              "age": {
                "extracted_string_or_numeric_value": 29,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [100, 300, 300, 100],
                  "vertical_y_vertices": [100, 100, 120, 120]
                }
              }
            }
          ],
          "attorney": {
            "name": {
              "extracted_string_or_numeric_value": "Greg Merrifield",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [100, 300, 300, 100],
                "vertical_y_vertices": [100, 100, 120, 120]
              }
            }
          },
          "signature": {
            "extracted_string_or_numeric_value": "Keith A. Grandy",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          }
        }
      ],
      "marriage_date": {
        "extracted_string_or_numeric_value": "July 23, 2005",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300, 300, 100],
          "vertical_y_vertices": [100, 100, 120, 120]
        }
      },
      "agreement_date": {
        "extracted_string_or_numeric_value": "July 16, 2005",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300, 300, 100],
          "vertical_y_vertices": [100, 100, 120, 120]
        }
      },
      "governing_law_state": {
        "extracted_string_or_numeric_value": "Michigan",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300, 300, 100],
          "vertical_y_vertices": [100, 100, 120, 120]
        }
      },
      "financial_disclosures": [
        {
          "party_name": {
            "extracted_string_or_numeric_value": "Judith Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "worksheet_date": {
            "extracted_string_or_numeric_value": "07-16-2005",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "assets": {
            "real_estate": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Michigan 49665 house",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 375000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "100%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Farm 258.5 acres",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 522000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "25%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Driftwood time share Vero Beach Fl",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 2000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "100%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "cash_and_bank_accounts": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Chemical Bank Checking Account #1019524",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 9931.71,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "GMAC Money Market Account #90009011505063",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 63231.34,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "GMAC Money Market Account #90009012657185 Max R. Kibby Trust",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 318819.59,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Fifth Third Bank - Kibby Company Account #0004273451",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 4148.20,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "investments": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Chemical Bank Stock Account# C0000023449",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 20000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Chemical BankStock Account# C0000023451 MRK Trust",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 20000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "General Motors Stock Account# 10437901",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 4286.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Delphi Stock Account# 1043-7901",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 270.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "American General Flexible Premium Annuity Policy #VA217791",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 10000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Connecticut General Life Insurance Policy #1915614",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 350401.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "American United Life Insurance #19-5163376",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 10000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Prudential #28-954-250",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 5000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "retirement": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Retirement Assets",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 0.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "personal_property": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "1999 GM Tahoe 40,000 Miles",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 12000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "1985 Corvette 112,000",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 5000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "1998 Polaris Six Wheeler",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 5000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "1993 Dyna-wide Glide Harley-Davidson",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 15000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "1998 Heritage Softtail Classic Harley-Davidson",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 15000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "1970 Camero",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 25000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Jewelry",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 20000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Watercolor Art",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 500.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Brass Art",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 1000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Antiques",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 10000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Gun Collection and supplies",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 10000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Household Goods",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 80000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "business_ownership": [
              {
                "name": {
                  "extracted_string_or_numeric_value": "Kibby Co. LLC Member Judith A. Kibby",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "form": {
                  "extracted_string_or_numeric_value": "LLC",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "50%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 484500.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "name": {
                  "extracted_string_or_numeric_value": "Kibby Co. LLC Member Max R. Kibby Trust",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "form": {
                  "extracted_string_or_numeric_value": "LLC",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "50%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 484500.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "money_owed_to_party": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Christie and Fred Prielipp Land contract",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 96477.48,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "311 South Mill Street Land Contract",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 76375.67,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ]
          },
          "debts": {
            "private_loans": [
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "Emily Ida Kibby",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Farm Land Contract",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 35854.90,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "Max R Kibby Estate",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Home Construction",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 60000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ]
          },
          "income": {
            "income_items": [
              {
                "type": {
                  "extracted_string_or_numeric_value": "Dividends, Interest",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "amount": {
                  "extracted_string_or_numeric_value": 27145.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "type": {
                  "extracted_string_or_numeric_value": "Capital Gain (or Loss) Income",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "amount": {
                  "extracted_string_or_numeric_value": 1333.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "type": {
                  "extracted_string_or_numeric_value": "Rental or Partnership, S-Corporation Income",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "amount": {
                  "extracted_string_or_numeric_value": 82667.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "type": {
                  "extracted_string_or_numeric_value": "Election Worker",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "amount": {
                  "extracted_string_or_numeric_value": 117.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ]
          },
          "expenses": {
            "expense_items": [
              {
                "category": {
                  "extracted_string_or_numeric_value": "Housing",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Property Tax",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 2500.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Housing",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Insurance",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 1100.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Housing",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Utilities and Maintenance",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 8808.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Transportation",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Registration and Insurance",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 2184.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Transportation",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Repairs and Maintenance",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 1600.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Transportation",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Gas, Parking",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 1860.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Necessities",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Food and Supplies",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 6114.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Necessities",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Clothing",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 1200.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Necessities",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Medical/Dental",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 824.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Necessities",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Personal Hygiene",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 540.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Necessities",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Mike student loan and car insurance",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 5712.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Other",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Entertainment and Travel",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 546.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Other",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Dues, Subscriptions, and Hobbies",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 100.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Other",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Gifts and Donations",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 2200.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Other",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Insurance",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 3245.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "category": {
                  "extracted_string_or_numeric_value": "Other",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Estimate income tax",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "annual_amount": {
                  "extracted_string_or_numeric_value": 18600.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ]
          },
          "total_assets": {
            "extracted_string_or_numeric_value": 3055440.63,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "total_debts": {
            "extracted_string_or_numeric_value": 95854.90,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "total_income": {
            "extracted_string_or_numeric_value": 111262.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "total_expenses": {
            "extracted_string_or_numeric_value": 57133.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          }
        },
        {
          "party_name": {
            "extracted_string_or_numeric_value": "Keith Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "worksheet_date": {
            "extracted_string_or_numeric_value": "07-16-2005",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "assets": {
            "real_estate": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "4316 21 Mile Road, Marion, Michigan 49665",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 175000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "8 acres",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 16000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "cash_and_bank_accounts": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Chemical Bank checking account# 0001024797",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 1389.44,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Citizens Bank checking# 4528322268",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 187.16,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "CP Federal Credit Union Saving # 664150",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 747.47,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "investments": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Aetna Life Insurance Policy #608622-30-001 Company paid",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 25000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Atena Life Insurance Policy#608622-30-001 Employee paid",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 127500.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "retirement": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "401 (k)",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 0.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Consumers Energy Co. pension # 376-48-9851",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 97000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "personal_property": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "Misc. power tools etc.",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 3000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "2000 Chevy Pick-up",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 12000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "description": {
                  "extracted_string_or_numeric_value": "Rifles, Shotgun and Supplies",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 5000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "business_ownership": [
              {
                "name": {
                  "extracted_string_or_numeric_value": "KG Fishing Equipment",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "form": {
                  "extracted_string_or_numeric_value": "Sole Proprietorship",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "100%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 20000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "name": {
                  "extracted_string_or_numeric_value": "2000 Javlin 200 Renegade Bass Boat",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "form": {
                  "extracted_string_or_numeric_value": "Sole Proprietorship",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "ownership_percentage": {
                  "extracted_string_or_numeric_value": "45%",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "value": {
                  "extracted_string_or_numeric_value": 20000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "money_owed_to_party": []
          },
          "debts": {
            "secured_loans": [
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "Chemical Bank #702073827",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "House mortgage",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 73942.02,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "Chemical Bank #914087122",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "Home Equity",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 10024.32,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "Chemical Bank #914093417",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "description": {
                  "extracted_string_or_numeric_value": "2000 Chevy pick up",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 12065.50,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "credit_card_debts": [
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "MBNA America #5490-3534-3602-5455",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 7457.88,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "Citi #5424-1807-5484-9104",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 4100.00,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              },
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "GE Money Bank #6019-1818-3542-4833",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 1400.00,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "bank_loans": [
              {
                "owed_to": {
                  "extracted_string_or_numeric_value": "CP Federal Credit Union #L62 KG Fishing Boat",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "balance": {
                  "extracted_string_or_numeric_value": 11006.41,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ],
            "private_loans": []
          },
          "income": {
            "income_items": [
              {
                "type": {
                  "extracted_string_or_numeric_value": "Salary/Wages",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                },
                "amount": {
                  "extracted_string_or_numeric_value": 65000.0,
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [100, 300, 300, 100],
                    "vertical_y_vertices": [100, 100, 120, 120]
                  }
                }
              }
            ]
          },
          "expenses": null,
          "total_assets": {
            "extracted_string_or_numeric_value": 502824.07,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "total_debts": {
            "extracted_string_or_numeric_value": 119996.13,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "total_income": {
            "extracted_string_or_numeric_value": 65000.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 300, 300, 100],
              "vertical_y_vertices": [100, 100, 120, 120]
            }
          },
          "total_expenses": null
        }
      ],
      "notary": {
        "name": {
          "extracted_string_or_numeric_value": "Denise L. Jernstadt",
          "optical_extraction_confidence_score": 0.85,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 300, 300, 100],
            "vertical_y_vertices": [100, 100, 120, 120]
          }
        },
        "county": {
          "extracted_string_or_numeric_value": "Osceola",
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 300, 300, 100],
            "vertical_y_vertices": [100, 100, 120, 120]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "Michigan",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 300, 300, 100],
            "vertical_y_vertices": [100, 100, 120, 120]
          }
        }
      }
    }
  }
]
```