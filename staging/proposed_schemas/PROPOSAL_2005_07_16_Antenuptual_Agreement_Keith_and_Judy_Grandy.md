An exceptionally well-preserved and internally consistent document. The primary structural variation is the different types of assets and debts declared by each party, which is easily handled by typing the corresponding list fields as `Optional`. The double-entry accounting checksums for both parties' financial disclosures are valid, with a minor and acceptable rounding discrepancy of $0.36 on one party's total assets.

***

### BLOCK 1: Python Pydantic V2

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
import math

# DO NOT MODIFY THIS CLASS
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

# DO NOT MODIFY THIS CLASS
class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class RealEstateAsset(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    percentage_owned: ForensicDataEntity
    market_value: ForensicDataEntity

class BankAccount(BaseModel):
    model_config = ConfigDict(extra='forbid')
    account_type: ForensicDataEntity
    balance: ForensicDataEntity

class InvestmentAsset(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    market_value: ForensicDataEntity

class RetirementAsset(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    market_value: ForensicDataEntity

class PersonalPropertyAsset(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    market_value: ForensicDataEntity

class BusinessOwnership(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    form: ForensicDataEntity
    percentage_owned: ForensicDataEntity
    market_value: ForensicDataEntity

class OtherAssetOwed(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    market_value: ForensicDataEntity

class SecuredLoan(BaseModel):
    model_config = ConfigDict(extra='forbid')
    owed_to: ForensicDataEntity
    secured_by: ForensicDataEntity
    balance: ForensicDataEntity

class CreditCardDebt(BaseModel):
    model_config = ConfigDict(extra='forbid')
    owed_to: ForensicDataEntity
    balance: ForensicDataEntity

class BankLoanLineOfCredit(BaseModel):
    model_config = ConfigDict(extra='forbid')
    owed_to: ForensicDataEntity
    balance: ForensicDataEntity

class PrivateLoan(BaseModel):
    model_config = ConfigDict(extra='forbid')
    owed_to: ForensicDataEntity
    description: ForensicDataEntity
    balance: ForensicDataEntity
    due_date: ForensicDataEntity

class IncomeItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    type: ForensicDataEntity
    amount: ForensicDataEntity

class ExpenseItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class FinancialDisclosure(BaseModel):
    model_config = ConfigDict(extra='forbid')
    party_name: ForensicDataEntity
    disclosure_date: ForensicDataEntity
    real_estate_assets: Optional[List[RealEstateAsset]] = None
    bank_accounts: Optional[List[BankAccount]] = None
    investment_assets: Optional[List[InvestmentAsset]] = None
    retirement_assets: Optional[List[RetirementAsset]] = None
    personal_property_assets: Optional[List[PersonalPropertyAsset]] = None
    business_ownerships: Optional[List[BusinessOwnership]] = None
    other_assets_owed: Optional[List[OtherAssetOwed]] = None
    total_assets: ForensicDataEntity
    secured_loans: Optional[List[SecuredLoan]] = None
    credit_card_debts: Optional[List[CreditCardDebt]] = None
    bank_loans_lines_of_credit: Optional[List[BankLoanLineOfCredit]] = None
    private_loans: Optional[List[PrivateLoan]] = None
    total_debts: ForensicDataEntity
    income_items: Optional[List[IncomeItem]] = None
    total_income: ForensicDataEntity
    expense_items: Optional[List[ExpenseItem]] = None
    total_expenses: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_financial_totals(self) -> 'FinancialDisclosure':
        # Asset Calculation
        calculated_assets = 0.0
        asset_lists = [
            self.real_estate_assets, self.investment_assets, self.retirement_assets,
            self.personal_property_assets, self.business_ownerships, self.other_assets_owed
        ]
        for asset_list in asset_lists:
            if asset_list:
                for item in asset_list:
                    calculated_assets += item.market_value.extracted_string_or_numeric_value
        if self.bank_accounts:
            for item in self.bank_accounts:
                calculated_assets += item.balance.extracted_string_or_numeric_value
        
        if not math.isclose(calculated_assets, self.total_assets.extracted_string_or_numeric_value, rel_tol=1e-5, abs_tol=1.0):
            raise ValueError(f"Asset checksum failed: Calculated={calculated_assets}, Stated={self.total_assets.extracted_string_or_numeric_value}")

        # Debt Calculation
        calculated_debts = 0.0
        debt_lists = [
            self.secured_loans, self.credit_card_debts,
            self.bank_loans_lines_of_credit, self.private_loans
        ]
        for debt_list in debt_lists:
            if debt_list:
                for item in debt_list:
                    calculated_debts += item.balance.extracted_string_or_numeric_value
        
        if not math.isclose(calculated_debts, self.total_debts.extracted_string_or_numeric_value, rel_tol=1e-5, abs_tol=1.0):
            raise ValueError(f"Debt checksum failed: Calculated={calculated_debts}, Stated={self.total_debts.extracted_string_or_numeric_value}")

        # Income Calculation
        calculated_income = 0.0
        if self.income_items:
            for item in self.income_items:
                calculated_income += item.amount.extracted_string_or_numeric_value
        
        if not math.isclose(calculated_income, self.total_income.extracted_string_or_numeric_value, rel_tol=1e-5, abs_tol=1.0):
            raise ValueError(f"Income checksum failed: Calculated={calculated_income}, Stated={self.total_income.extracted_string_or_numeric_value}")

        # Expense Calculation
        if self.total_expenses and self.expense_items:
            calculated_expenses = 0.0
            for item in self.expense_items:
                calculated_expenses += item.amount.extracted_string_or_numeric_value
            
            if not math.isclose(calculated_expenses, self.total_expenses.extracted_string_or_numeric_value, rel_tol=1e-5, abs_tol=1.0):
                raise ValueError(f"Expense checksum failed: Calculated={calculated_expenses}, Stated={self.total_expenses.extracted_string_or_numeric_value}")

        return self

class KeithDisclosureSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_assets: ForensicDataEntity
    total_debts: ForensicDataEntity
    annual_income_year: ForensicDataEntity
    annual_income_amount: ForensicDataEntity

class AntenuptualAgreement(BaseModel):
    model_config = ConfigDict(extra='forbid')
    party_one_name: ForensicDataEntity
    party_two_name: ForensicDataEntity
    marriage_date: ForensicDataEntity
    agreement_date: ForensicDataEntity
    party_one_attorney: ForensicDataEntity
    party_two_attorney: ForensicDataEntity
    notary_name: ForensicDataEntity
    notary_state: ForensicDataEntity
    notary_county: ForensicDataEntity
    party_one_financials: FinancialDisclosure
    party_two_financials: FinancialDisclosure
    keith_disclosure_summary: Optional[KeithDisclosureSummary] = None

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "20050716_grandy_antenuptial_full.pdf",
    "should_pass": true,
    "taxonomy_lane": "AntenuptualAgreement",
    "binary_header_simulation": "25504446",
    "payload": {
      "party_one_name": {
        "extracted_string_or_numeric_value": "Judith A. Kibby",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 400],
          "vertical_y_vertices": [220, 230]
        }
      },
      "party_two_name": {
        "extracted_string_or_numeric_value": "Keith A Grandy",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [405, 550],
          "vertical_y_vertices": [220, 230]
        }
      },
      "marriage_date": {
        "extracted_string_or_numeric_value": "July 23, 2005",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [330, 420],
          "vertical_y_vertices": [300, 310]
        }
      },
      "agreement_date": {
        "extracted_string_or_numeric_value": "July 16, 2005",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 350],
          "vertical_y_vertices": [220, 230]
        }
      },
      "party_one_attorney": {
        "extracted_string_or_numeric_value": "John Martin",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [380, 480],
          "vertical_y_vertices": [220, 230]
        }
      },
      "party_two_attorney": {
        "extracted_string_or_numeric_value": "Greg Merrifield",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [380, 520],
          "vertical_y_vertices": [220, 230]
        }
      },
      "notary_name": {
        "extracted_string_or_numeric_value": "Diana Salisbury",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [220, 230]
        }
      },
      "notary_state": {
        "extracted_string_or_numeric_value": "Michigan",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [600, 680],
          "vertical_y_vertices": [250, 260]
        }
      },
      "notary_county": {
        "extracted_string_or_numeric_value": "Osceola",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 780],
          "vertical_y_vertices": [250, 260]
        }
      },
      "party_one_financials": {
        "party_name": {
          "extracted_string_or_numeric_value": "Judith Kibby",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "disclosure_date": {
          "extracted_string_or_numeric_value": "07-16-2005",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "real_estate_assets": [
          { "description": { "extracted_string_or_numeric_value": "3291 18 Mile Road", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "100%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 375000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Farm 258.5 acres", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "25%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 522000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Driftwood time share", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "100%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 2000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "bank_accounts": [
          { "account_type": { "extracted_string_or_numeric_value": "Chemical Bank Checking", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 9931.71, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "account_type": { "extracted_string_or_numeric_value": "GMAC Money Market", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 63231.34, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "account_type": { "extracted_string_or_numeric_value": "GMAC Money Market Max R. Kibby Trust", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 318819.59, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "account_type": { "extracted_string_or_numeric_value": "Fifth Third Bank - Kibby Company", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 4148.20, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "investment_assets": [
          { "description": { "extracted_string_or_numeric_value": "Chemical Bank Stock", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 20000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Chemical BankStock MRK Trust", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 20000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "General Motors Stock", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 4286.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Delphi Stock", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 270.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "American General Annuity", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 10000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Connecticut General Life Insurance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 350401.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "American United Life Insurance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 10000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Prudential", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 5000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "personal_property_assets": [
          { "description": { "extracted_string_or_numeric_value": "1999 GM Tahoe", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 12000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "1985 Corvette", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 5000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "1998 Polaris Six Wheeler", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 5000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "1993 Dyna-wide Glide Harley-Davidson", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 15000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "1998 Heritage Softtail Classic Harley-Davidson", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 15000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "1970 Camero", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 25000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Jewelry", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 20000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Watercolor Art", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 500.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Brass Art", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 1000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Antiques", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 10000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Gun Collection and supplies", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 10000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Household Goods", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 80000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "business_ownerships": [
          { "name": { "extracted_string_or_numeric_value": "Kibby Co. LLC Member Judith A. Kibby", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "form": { "extracted_string_or_numeric_value": "LLC", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "50%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 484500.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "name": { "extracted_string_or_numeric_value": "Kibby Co. LLC Member Max R. Kibby Trust", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "form": { "extracted_string_or_numeric_value": "LLC", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "50%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 484500.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "other_assets_owed": [
          { "description": { "extracted_string_or_numeric_value": "Christie and Fred Prielipp Land contract", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 96477.48, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "311 South Mill Street Land Contract", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 76375.67, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_assets": {
          "extracted_string_or_numeric_value": 3055440.63,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "private_loans": [
          { "owed_to": { "extracted_string_or_numeric_value": "Emily Ida Kibby", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Farm Land Contract", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 35854.90, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "due_date": { "extracted_string_or_numeric_value": "2025", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "owed_to": { "extracted_string_or_numeric_value": "Max R Kibby Estate", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Home Construction", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 60000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "due_date": { "extracted_string_or_numeric_value": "2009", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_debts": {
          "extracted_string_or_numeric_value": 95854.90,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "income_items": [
          { "type": { "extracted_string_or_numeric_value": "Dividends, Interest", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 27145.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "type": { "extracted_string_or_numeric_value": "Capital Gain (or Loss) Income", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 1333.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "type": { "extracted_string_or_numeric_value": "Rental or Partnership, S-Corporation Income", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 82667.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "type": { "extracted_string_or_numeric_value": "Other (specify): Election Worker", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 117.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_income": {
          "extracted_string_or_numeric_value": 111262.0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "expense_items": [
          { "category": { "extracted_string_or_numeric_value": "Housing", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Property Tax", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 2500.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Housing", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Insurance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 1100.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Housing", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Utilities and Maintenance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 8808.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Transportation", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Registration and Insurance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 2184.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Transportation", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Repairs and Maintenance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 1600.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Transportation", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Gas, Parking", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 1860.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Necessities", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Food and Supplies", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 6114.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Necessities", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Clothing", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 1200.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Necessities", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Medical/Dental", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 824.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Necessities", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Personal Hygiene", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 540.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Necessities", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Mike student loan and car insurance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 5712.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Other", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Entertainment and Travel", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 546.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Other", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Dues, Subscriptions, and Hobbies", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 100.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Other", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Gifts and Donations", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 2200.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Other", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Insurance", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 3245.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "category": { "extracted_string_or_numeric_value": "Other", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "description": { "extracted_string_or_numeric_value": "Estimate income tax", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 18600.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_expenses": {
          "extracted_string_or_numeric_value": 57133.0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        }
      },
      "party_two_financials": {
        "party_name": {
          "extracted_string_or_numeric_value": "Keith Grandy",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "disclosure_date": {
          "extracted_string_or_numeric_value": "07-16-2005",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "real_estate_assets": [
          { "description": { "extracted_string_or_numeric_value": "4316 21 Mile Road", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "100%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 175000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "8 acres", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "100%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 16000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "bank_accounts": [
          { "account_type": { "extracted_string_or_numeric_value": "Chemical Bank checking", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 1389.44, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "account_type": { "extracted_string_or_numeric_value": "Citizens Bank checking", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 187.16, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "account_type": { "extracted_string_or_numeric_value": "CP Federal Credit Union Saving", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 747.47, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "investment_assets": [
          { "description": { "extracted_string_or_numeric_value": "Aetna Life Insurance Company paid", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 25000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Atena Life Insurance Employee paid", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 127500.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "retirement_assets": [
          { "description": { "extracted_string_or_numeric_value": "Consumers Energy Co. pension", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 97000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "personal_property_assets": [
          { "description": { "extracted_string_or_numeric_value": "Misc. power tools etc.", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 3000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "2000 Chevy Pick-up", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 12000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "description": { "extracted_string_or_numeric_value": "Rifles, Shotgun and Supplies", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 5000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "business_ownerships": [
          { "name": { "extracted_string_or_numeric_value": "KG Fishing Equipment", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "form": { "extracted_string_or_numeric_value": "Sole Proprietorship", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "100%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 20000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "name": { "extracted_string_or_numeric_value": "2000 Javlin 200 Renegade Bass Boat", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "form": { "extracted_string_or_numeric_value": "N/A", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "percentage_owned": { "extracted_string_or_numeric_value": "45%", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "market_value": { "extracted_string_or_numeric_value": 20000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_assets": {
          "extracted_string_or_numeric_value": 502824.07,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "secured_loans": [
          { "owed_to": { "extracted_string_or_numeric_value": "Chemical Bank", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "secured_by": { "extracted_string_or_numeric_value": "House mortgage", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 73942.02, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "owed_to": { "extracted_string_or_numeric_value": "Chemical Bank", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "secured_by": { "extracted_string_or_numeric_value": "Home Equity", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 10024.32, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "owed_to": { "extracted_string_or_numeric_value": "Chemical Bank", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "secured_by": { "extracted_string_or_numeric_value": "2000 Chevy pick up", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 12065.50, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "credit_card_debts": [
          { "owed_to": { "extracted_string_or_numeric_value": "MBNA America", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 7457.88, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "owed_to": { "extracted_string_or_numeric_value": "Citi", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 4100.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } },
          { "owed_to": { "extracted_string_or_numeric_value": "GE Money Bank", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 1400.00, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "bank_loans_lines_of_credit": [
          { "owed_to": { "extracted_string_or_numeric_value": "CP Federal Credit Union", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "balance": { "extracted_string_or_numeric_value": 11006.41, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_debts": {
          "extracted_string_or_numeric_value": 119996.13,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "income_items": [
          { "type": { "extracted_string_or_numeric_value": "Salary/Wages", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } }, "amount": { "extracted_string_or_numeric_value": 65000.0, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] } } }
        ],
        "total_income": {
          "extracted_string_or_numeric_value": 65000.0,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        }
      },
      "keith_disclosure_summary": {
        "total_assets": {
          "extracted_string_or_numeric_value": 502824.07,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "total_debts": {
          "extracted_string_or_numeric_value": 119996.13,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "annual_income_year": {
          "extracted_string_or_numeric_value": "2004",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        },
        "annual_income_amount": {
          "extracted_string_or_numeric_value": 65000.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [1, 2], "vertical_y_vertices": [3, 4] }
        }
      }
    }
  }
]
```