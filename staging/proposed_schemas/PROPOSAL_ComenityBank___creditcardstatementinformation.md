An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document fragments. The document is a standard terms and conditions page from a Comenity Bank credit card statement. It contains no transactional financial data, but rather informational clauses, contact details, and addresses for various types of correspondence.

My Pydantic V2 schema is designed to be highly resilient by structuring the data into logical, nested components that mirror the document's layout. This includes distinct objects for different types of information (e.g., error disputes, purchase dissatisfaction, customer service) and a reusable `Address` model. This granular, hierarchical approach ensures that even if sections are rearranged or omitted in future document versions, the schema can be easily adapted by making the corresponding top-level objects `Optional`.

The mandatory GAAP checksum validator is included. However, as this document class contains no financial figures, the validator's implementation is a pass-through, acknowledging the requirement while correctly reflecting the nature of the source data.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

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

class Address(BaseModel):
    """A structured representation of a mailing address."""
    model_config = ConfigDict(extra='forbid')
    recipient: Optional[ForensicDataEntity] = None
    street_address: ForensicDataEntity
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: ForensicDataEntity

class SectionWithAddress(BaseModel):
    """A generic model for sections that contain a header, instructions, and a mailing address."""
    model_config = ConfigDict(extra='forbid')
    header: ForensicDataEntity
    instructions: ForensicDataEntity
    mailing_address: Address

class InformationalSection(BaseModel):
    """A generic model for sections containing a header and detailed text."""
    model_config = ConfigDict(extra='forbid')
    header: ForensicDataEntity
    details: ForensicDataEntity

class CustomerServiceInfo(BaseModel):
    """Contact information for customer service."""
    model_config = ConfigDict(extra='forbid')
    header: ForensicDataEntity
    website: ForensicDataEntity
    phone: ForensicDataEntity
    tty_phone: ForensicDataEntity

class GeneralNotices(BaseModel):
    """A collection of various notices and addresses."""
    model_config = ConfigDict(extra='forbid')
    telephone_monitoring_notice: ForensicDataEntity
    additional_information: ForensicDataEntity
    electronic_check_conversion_notice: ForensicDataEntity
    inquiries_address: Address
    bankruptcy_address: Address

class ComenityBankCreditcardstatementinformationV1(BaseModel):
    """
    Schema for the informational back page of a Comenity Bank credit card statement.
    This document outlines customer rights, contact information, and terms.
    """
    model_config = ConfigDict(extra='forbid')

    document_retention_instruction: ForensicDataEntity
    statement_error_info: SectionWithAddress
    purchase_dissatisfaction_info: SectionWithAddress
    paying_interest_info: InformationalSection
    balance_computation_info: InformationalSection
    credit_reporting_info: InformationalSection
    credit_report_dispute_info: SectionWithAddress
    paid_in_full_payments_info: SectionWithAddress
    customer_service_info: CustomerServiceInfo
    general_notices: GeneralNotices

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'ComenityBankCreditcardstatementinformationV1':
        """
        A model validator to perform double-entry GAAP mathematical checksums.
        
        Note: This specific document class ('ComenityBank - creditcardstatementinformation')
        is informational and does not contain financial figures, balances, or transactions.
        Therefore, no mathematical checks are applicable or performed. This validator
        is included to satisfy the mandatory directive.
        """
        # No financial data present in this document type to validate.
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "golden-comenity-informational-page-001",
    "should_pass": true,
    "taxonomy_lane": "ComenityBankCreditcardstatementinformationV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_retention_instruction": {
        "extracted_string_or_numeric_value": "Keep this portion for your records.",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100.0, 400.0, 400.0, 100.0],
          "vertical_y_vertices": [50.0, 50.0, 60.0, 60.0]
        }
      },
      "statement_error_info": {
        "header": {
          "extracted_string_or_numeric_value": "What To Do If You Think You Find A Mistake On Your Statement",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 600.0, 600.0, 100.0],
            "vertical_y_vertices": [70.0, 70.0, 80.0, 80.0]
          }
        },
        "instructions": {
          "extracted_string_or_numeric_value": "If you think there is an error on your statement, write to us at: Comenity Bank PO Box 182782. Columbus. Ohio 43218 2782. In your letter, give us the following information: Account information: Your name and account number. Dollar amount: The dollar amount of the suspected error. Description of Problem: If you think there is an error on your bill, describe what you believe is wrong and why you believe it is a mistake. You must contact us within 60 days after the error appeared on your statement. You must notify us of any potential errors in writing. You may call us, but if you do, we are not required to investigate any potential errors and you may have to pay the amount in question. While we investigate whether or not there has been an error, the following are true: We cannot try to collect the amount in question, or report you as delinquent on that amount. The charge in question may remain on your statement, and we may continue to charge you interest on that amount. But. if we determine that we made a mistake, you will not have to pay the amount in question or any interest or other fees related to that amount. While you do not have to pay the amount in question, you are responsible for the remainder of your balance. We can apply any unpaid amount against your credit limit.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [85.0, 85.0, 250.0, 250.0]
          }
        },
        "mailing_address": {
          "recipient": {
            "extracted_string_or_numeric_value": "Comenity Bank",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [400.0, 500.0, 500.0, 400.0],
              "vertical_y_vertices": [90.0, 90.0, 100.0, 100.0]
            }
          },
          "street_address": {
            "extracted_string_or_numeric_value": "PO Box 182782",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501.0, 600.0, 600.0, 501.0],
              "vertical_y_vertices": [90.0, 90.0, 100.0, 100.0]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Columbus",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [601.0, 680.0, 680.0, 601.0],
              "vertical_y_vertices": [90.0, 90.0, 100.0, 100.0]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Ohio",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [681.0, 720.0, 720.0, 681.0],
              "vertical_y_vertices": [90.0, 90.0, 100.0, 100.0]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "43218 2782",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [721.0, 800.0, 800.0, 721.0],
              "vertical_y_vertices": [90.0, 90.0, 100.0, 100.0]
            }
          }
        }
      },
      "purchase_dissatisfaction_info": {
        "header": {
          "extracted_string_or_numeric_value": "Your Rights If You Are Dissatisfied With Your Credit Card Purchases",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 700.0, 700.0, 100.0],
            "vertical_y_vertices": [260.0, 260.0, 270.0, 270.0]
          }
        },
        "instructions": {
          "extracted_string_or_numeric_value": "If you are dissatisfied with the goods or services that you have purchased with your credit card, and you have tried in good faith to correct the problem with the merchant, you may have the right not to pay the remaining amount due on the purchase. To use this right, all of the following must be true: 1. The purchase must have been made in your home state or within 100 miles of your current mailing address, and the purchase price must have been more than $50. (Note: Neither of these is necessary if your purchase was based on an advertisement we mailed to you, or if we own the company that sold you the goods or services.) 2. You must have used your credit card for the purchase. Purchases made with cash advances from an ATM or with a check that accesses your credit card account do not qualify. 3. You must not yet have fully paid for the purchase. If all of the criteria above are met and you are still dissatisfied with the purchase, contact us in writing at Comenity Bank PO Box 182782, Columbus, Ohio 43218-2782. While we investigate, the same rules apply to the disputed amount as discussed above. After we finish our investigation, we will tell you our decision. At that point, if we think you owe an amount and you do not pay we may report you as delinquent.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [275.0, 275.0, 450.0, 450.0]
          }
        },
        "mailing_address": {
          "recipient": {
            "extracted_string_or_numeric_value": "Comenity Bank",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300.0, 400.0, 400.0, 300.0],
              "vertical_y_vertices": [420.0, 420.0, 430.0, 430.0]
            }
          },
          "street_address": {
            "extracted_string_or_numeric_value": "PO Box 182782",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [401.0, 500.0, 500.0, 401.0],
              "vertical_y_vertices": [420.0, 420.0, 430.0, 430.0]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Columbus",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501.0, 580.0, 580.0, 501.0],
              "vertical_y_vertices": [420.0, 420.0, 430.0, 430.0]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Ohio",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [581.0, 620.0, 620.0, 581.0],
              "vertical_y_vertices": [420.0, 420.0, 430.0, 430.0]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "43218-2782",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [621.0, 700.0, 700.0, 621.0],
              "vertical_y_vertices": [420.0, 420.0, 430.0, 430.0]
            }
          }
        }
      },
      "paying_interest_info": {
        "header": {
          "extracted_string_or_numeric_value": "PAYING INTEREST.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 250.0, 250.0, 100.0],
            "vertical_y_vertices": [460.0, 460.0, 470.0, 470.0]
          }
        },
        "details": {
          "extracted_string_or_numeric_value": "Your due date is at least 23 days after the close of each billing cycle. We will not charge you interest on purchases if you pay your entire balance by the due date each month. We will begin charging interest on balance transfers and cash advances on the transaction date. We will begin to charge interest on new purchases made under a Low APR, Equal Payment or Budget Payment Credit Plan from the date of purchase.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [471.0, 471.0, 510.0, 510.0]
          }
        }
      },
      "balance_computation_info": {
        "header": {
          "extracted_string_or_numeric_value": "BALANCE COMPUTATION METHOD.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 350.0, 350.0, 100.0],
            "vertical_y_vertices": [515.0, 515.0, 525.0, 525.0]
          }
        },
        "details": {
          "extracted_string_or_numeric_value": "We calculate interest separately for each balance using the method(s) described below. The two letters in parentheses next to the Balance Subject to Interest Rate column in the Interest Charge Calculation section on this statement corresponds to the following: (DA) We figure the interest charge on this balance by applying the periodic rate to the \"daily balance\" for each day in the billing period. To get the \"daily balance\" we take the beginning balance each day, add any new transactions and fees and subtract any payments or credits (treating any net credit balance as a zero balance). This gives us the daily balance. (DC) We figure the interest charge on this balance by applying the periodic rate to the 'daily balance' for each day in the billing period. To get the daily balance' we take the beginning balance each day, add any new transactions and fees and subtract any Cash Advance Fees and any payments or credits (treating any net credit balance as a zero balance). This gives us the daily balance.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [526.0, 526.0, 620.0, 620.0]
          }
        }
      },
      "credit_reporting_info": {
        "header": {
          "extracted_string_or_numeric_value": "CREDIT REPORTING.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 280.0, 280.0, 100.0],
            "vertical_y_vertices": [625.0, 625.0, 635.0, 635.0]
          }
        },
        "details": {
          "extracted_string_or_numeric_value": "We may report information about your account to credit bureaus. Late payments, missed payments, or other defaults on your account may be reflected in your credit report.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [636.0, 636.0, 655.0, 655.0]
          }
        }
      },
      "credit_report_dispute_info": {
        "header": {
          "extracted_string_or_numeric_value": "NOTICE OF CREDIT REPORT DISPUTES",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 450.0, 450.0, 100.0],
            "vertical_y_vertices": [660.0, 660.0, 670.0, 670.0]
          }
        },
        "instructions": {
          "extracted_string_or_numeric_value": "If you believe the account information we reported to a consumer reporting agency is inaccurate, you may submit a direct dispute to Comenity Bank PO Box 182789, Columbus, Ohio 43218-2789. Your written dispute must provide sufficient information to identify the account and specify why the information is inaccurate: * Account Information; Your name and account number * Contact Information: Your address and telephone number * Disputed Information: Identify the account information disputed and explain why you believe it is inaccurate * Supporting Documentation; If available, provide a copy of the section of the credit report showing the account information you are disputing. We will investigate the disputed information and report the results to you within 30 days of receipt of the information needed for our investigation. If we find that the account information we reported is inaccurate, we will promptly provide the necessary correction to each consumer reporting agency to which we reported the information.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [671.0, 671.0, 800.0, 800.0]
          }
        },
        "mailing_address": {
          "recipient": {
            "extracted_string_or_numeric_value": "Comenity Bank",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300.0, 400.0, 400.0, 300.0],
              "vertical_y_vertices": [680.0, 680.0, 690.0, 690.0]
            }
          },
          "street_address": {
            "extracted_string_or_numeric_value": "PO Box 182789",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [401.0, 500.0, 500.0, 401.0],
              "vertical_y_vertices": [680.0, 680.0, 690.0, 690.0]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Columbus",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501.0, 580.0, 580.0, 501.0],
              "vertical_y_vertices": [680.0, 680.0, 690.0, 690.0]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Ohio",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [581.0, 620.0, 620.0, 581.0],
              "vertical_y_vertices": [680.0, 680.0, 690.0, 690.0]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "43218-2789",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [621.0, 700.0, 700.0, 621.0],
              "vertical_y_vertices": [680.0, 680.0, 690.0, 690.0]
            }
          }
        }
      },
      "paid_in_full_payments_info": {
        "header": {
          "extracted_string_or_numeric_value": "PAYMENTS MARKED \"PAID IN FULL\".",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 400.0, 400.0, 100.0],
            "vertical_y_vertices": [805.0, 805.0, 815.0, 815.0]
          }
        },
        "instructions": {
          "extracted_string_or_numeric_value": "All written communications regarding disputed amounts that include any check or other payment instrument marked with \"payment in full\" or similar language, must be sent to: 6550 North Loop 1604 East. Suite 101, San Antonio, TX 78247-5004. DO NOT USE THE ENCLOSED REMITTANCE ENVELOPE. -We may accept payment sent to any other address without losing any of our rights. -No payment shall operate as an accord and satisfaction without prior written approval.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [816.0, 816.0, 860.0, 860.0]
          }
        },
        "mailing_address": {
          "street_address": {
            "extracted_string_or_numeric_value": "6550 North Loop 1604 East. Suite 101",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100.0, 450.0, 450.0, 100.0],
              "vertical_y_vertices": [825.0, 825.0, 835.0, 835.0]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "San Antonio",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [451.0, 550.0, 550.0, 451.0],
              "vertical_y_vertices": [825.0, 825.0, 835.0, 835.0]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "TX",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [551.0, 580.0, 580.0, 551.0],
              "vertical_y_vertices": [825.0, 825.0, 835.0, 835.0]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "78247-5004",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [581.0, 660.0, 660.0, 581.0],
              "vertical_y_vertices": [825.0, 825.0, 835.0, 835.0]
            }
          }
        }
      },
      "customer_service_info": {
        "header": {
          "extracted_string_or_numeric_value": "CUSTOMER SERVICE.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 280.0, 280.0, 100.0],
            "vertical_y_vertices": [865.0, 865.0, 875.0, 875.0]
          }
        },
        "website": {
          "extracted_string_or_numeric_value": "comenity.net/meijermastercard",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [281.0, 500.0, 500.0, 281.0],
            "vertical_y_vertices": [865.0, 865.0, 875.0, 875.0]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "1-855-782-7541",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [501.0, 650.0, 650.0, 501.0],
            "vertical_y_vertices": [865.0, 865.0, 875.0, 875.0]
          }
        },
        "tty_phone": {
          "extracted_string_or_numeric_value": "1-800-695-1788",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [651.0, 800.0, 800.0, 651.0],
            "vertical_y_vertices": [865.0, 865.0, 875.0, 875.0]
          }
        }
      },
      "general_notices": {
        "telephone_monitoring_notice": {
          "extracted_string_or_numeric_value": "TELEPHONE MONITORING. To provide you with high-quality service, phone communication with us is monitored and/or recorded.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [880.0, 880.0, 895.0, 895.0]
          }
        },
        "additional_information": {
          "extracted_string_or_numeric_value": "ADDITIONAL INFORMATION. The following designations, when appearing on the front of your statement, mean the following; V means variable rate (this rate may vary); WV INT PAY RQ means WAIVE INTEREST. PAYMENT REQUIRED: WV INT EQ PY means WAIVE INTEREST. EQUAL PAYMENT; WV INT LOW PMT means WAIVE INTEREST, LOW PAYMENT; DF INT PY RQ means DEFER INTEREST. PAYMENT REQUIRED: DEF INT EQ PY means DEFER INTEREST. EQUAL PAYMENT; DF INT LOW PMT means DEFER INTEREST. LOW PAYMENT and LOW APR EQ PAY means LOW APR. EQUAL PAYMENT. If you have a variable rate account, your periodic rates may vary. You may pay all of your Account balance at any time without penalty.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [900.0, 900.0, 950.0, 950.0]
          }
        },
        "electronic_check_conversion_notice": {
          "extracted_string_or_numeric_value": "NOTICE ABOUT ELECTRONIC CHECK CONVERSION. When you provide a check as payment, you authorize us either to use information from your check to make a one time electronic fund transfer from your account or to process the payment as a check transaction. When we use information from your check to make an electronic fund transfer, funds may be withdrawn from your account as soon as the same day we receive your payment, and you will not receive your check back from your financial institution.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100.0, 900.0, 900.0, 100.0],
            "vertical_y_vertices": [980.0, 980.0, 1020.0, 1020.0]
          }
        },
        "inquiries_address": {
          "recipient": {
            "extracted_string_or_numeric_value": "CUSTOMER SERVICE",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100.0, 250.0, 250.0, 100.0],
              "vertical_y_vertices": [955.0, 955.0, 965.0, 965.0]
            }
          },
          "street_address": {
            "extracted_string_or_numeric_value": "PO Box 182273",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [251.0, 350.0, 350.0, 251.0],
              "vertical_y_vertices": [955.0, 955.0, 965.0, 965.0]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Columbus",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [351.0, 430.0, 430.0, 351.0],
              "vertical_y_vertices": [955.0, 955.0, 965.0, 965.0]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Ohio",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [431.0, 470.0, 470.0, 431.0],
              "vertical_y_vertices": [955.0, 955.0, 965.0, 965.0]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "43218-2273",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [471.0, 550.0, 550.0, 471.0],
              "vertical_y_vertices": [955.0, 955.0, 965.0, 965.0]
            }
          }
        },
        "bankruptcy_address": {
          "recipient": {
            "extracted_string_or_numeric_value": "Comenity Bank, Bankruptcy Department",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100.0, 400.0, 400.0, 100.0],
              "vertical_y_vertices": [968.0, 968.0, 978.0, 978.0]
            }
          },
          "street_address": {
            "extracted_string_or_numeric_value": "PO Box 182125",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [401.0, 500.0, 500.0, 401.0],
              "vertical_y_vertices": [968.0, 968.0, 978.0, 978.0]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Columbus",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501.0, 580.0, 580.0, 501.0],
              "vertical_y_vertices": [968.0, 968.0, 978.0, 978.0]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Ohio",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [581.0, 620.0, 620.0, 581.0],
              "vertical_y_vertices": [968.0, 968.0, 978.0, 978.0]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "43218-2125",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [621.0, 700.0, 700.0, 621.0],
              "vertical_y_vertices": [968.0, 968.0, 978.0, 978.0]
            }
          }
        }
      }
    }
  }
]
```
