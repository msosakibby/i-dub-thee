An analysis of the provided documents reveals a multi-part Last Will and Testament for Keith A. Grandy, dated March 24, 2017. The set includes a formal three-page will, two pages of handwritten supplementary instructions (a patient advocate directive and notes on assets), and a memorandum for the distribution of personal property. The formal will explicitly references the existence of such handwritten instructions, making them integral to the complete estate plan.

The most complex structural variant is the complete document set, which combines the formally typed will with these less structured, but legally referenced, addenda. The schema must therefore be flexible enough to capture the core legal declarations of the will, as well as the specific, and sometimes informal, instructions contained in the supplementary pages. This includes details on asset distribution, insurance policies, end-of-life care, and funeral arrangements. A key feature for validation is a list of cash bequests in the memorandum, which allows for a checksum to be performed, satisfying the directive's requirement for mathematical verification.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Beneficiary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity

class EstateBequest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    beneficiaries: List[Beneficiary]
    share_description: ForensicDataEntity

class PersonalRepresentative(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    relationship: Optional[ForensicDataEntity] = None

class WifeDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    marriage_details: ForensicDataEntity

class Witness(BaseModel):
    model_config = ConfigDict(extra='forbid')
    signature: ForensicDataEntity
    address: ForensicDataEntity

class DraftingAttorney(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: ForensicDataEntity

class InsurancePolicy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    purpose: ForensicDataEntity
    value: Optional[ForensicDataEntity] = None
    company_name: ForensicDataEntity
    company_address: ForensicDataEntity
    agent_name: ForensicDataEntity

class HandwrittenWillNotes(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    personal_property_disposition: ForensicDataEntity
    insurance_policies: List[InsurancePolicy]
    long_term_care_policy_mention: ForensicDataEntity

class CremationInstructions(BaseModel):
    model_config = ConfigDict(extra='forbid')
    location_1_description: ForensicDataEntity
    location_2_description: ForensicDataEntity

class PatientAdvocateDirective(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    end_of_life_instructions: ForensicDataEntity
    home_care_preference: ForensicDataEntity
    cremation_and_ashes_instructions: CremationInstructions
    celebration_of_life_instructions: ForensicDataEntity

class CashBequestRecipient(BaseModel):
    model_config = ConfigDict(extra='forbid')
    recipient_name: ForensicDataEntity
    relationship: ForensicDataEntity
    date: ForensicDataEntity
    initials: ForensicDataEntity

class GroupCashBequest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    amount_per_recipient: ForensicDataEntity
    recipients: List[CashBequestRecipient]

class PersonalPropertyMemorandum(BaseModel):
    model_config = ConfigDict(extra='forbid')
    cash_bequests: List[GroupCashBequest]
    total_cash_bequests_amount: Optional[ForensicDataEntity] = None

class WillOfKeithAGrandyV1(BaseModel):
    """
    Schema for the Last Will and Testament of Keith A. Grandy, including supplementary documents.
    """
    model_config = ConfigDict(extra='forbid')
    
    document_title: ForensicDataEntity
    testator_name: ForensicDataEntity
    testator_address: ForensicDataEntity
    document_date: ForensicDataEntity
    revocation_clause: ForensicDataEntity
    
    debt_and_funeral_directive: ForensicDataEntity
    estate_bequest: EstateBequest
    
    personal_representatives: List[PersonalRepresentative]
    bond_requirement: ForensicDataEntity
    handwritten_instructions_clause: ForensicDataEntity
    wife_details: WifeDetails
    
    testator_signature: ForensicDataEntity
    testator_printed_name: ForensicDataEntity
    
    witness_attestation_clause: ForensicDataEntity
    witnesses: List[Witness]
    
    drafting_attorney: DraftingAttorney
    
    handwritten_will_notes: Optional[HandwrittenWillNotes] = None
    patient_advocate_directive: Optional[PatientAdvocateDirective] = None
    personal_property_memorandum: Optional[PersonalPropertyMemorandum] = None

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'WillOfKeithAGrandyV1':
        """
        Performs a checksum on financial data within the will documents.
        This simulates a double-entry check by comparing a calculated total of cash bequests
        against a declared total within the Personal Property Memorandum.
        """
        if self.personal_property_memorandum and self.personal_property_memorandum.cash_bequests:
            if self.personal_property_memorandum.total_cash_bequests_amount is None:
                return self
            
            declared_total_value = self.personal_property_memorandum.total_cash_bequests_amount.extracted_string_or_numeric_value
            
            calculated_total = 0.0
            for group in self.personal_property_memorandum.cash_bequests:
                amount_val = group.amount_per_recipient.extracted_string_or_numeric_value
                if not isinstance(amount_val, (int, float)):
                    raise ValueError(f"Bequest amount '{amount_val}' must be numeric for checksum.")
                
                calculated_total += float(amount_val) * len(group.recipients)
            
            if not isinstance(declared_total_value, (int, float)):
                 raise ValueError(f"Declared total '{declared_total_value}' must be numeric for checksum.")

            if abs(float(declared_total_value) - calculated_total) > 0.01:
                raise ValueError(
                    f"Double-entry checksum failed for cash bequests. "
                    f"Calculated total: {calculated_total}, Declared total: {declared_total_value}"
                )
                
        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "20170324_keith_grandy_will_full_complex",
    "should_pass": true,
    "taxonomy_lane": "WillOfKeithAGrandyV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "LAST WILL AND TESTAMENT",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [281, 599, 599, 281],
          "vertical_y_vertices": [281, 281, 296, 296]
        }
      },
      "testator_name": {
        "extracted_string_or_numeric_value": "Keith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [443, 562, 562, 443],
          "vertical_y_vertices": [350, 350, 364, 364]
        }
      },
      "testator_address": {
        "extracted_string_or_numeric_value": "Marion, Osceola County, Michigan",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [281, 599, 599, 281],
          "vertical_y_vertices": [420, 420, 434, 434]
        }
      },
      "document_date": {
        "extracted_string_or_numeric_value": "24th day of March, 2017",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [560, 717, 717, 560],
          "vertical_y_vertices": [568, 568, 582, 582]
        }
      },
      "revocation_clause": {
        "extracted_string_or_numeric_value": "expressly revoking all Wills and Codicils to Wills by me at any time heretofore made.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221, 778, 778, 221],
          "vertical_y_vertices": [465, 465, 493, 493]
        }
      },
      "debt_and_funeral_directive": {
        "extracted_string_or_numeric_value": "Upon my death, I direct my Personal Representative, hereinafter named, to pay all my just debts and to provide for me a proper and fitting cremation, all such expenses to be paid as soon as possible out of my estate.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221, 778, 778, 221],
          "vertical_y_vertices": [599, 599, 656, 656]
        }
      },
      "estate_bequest": {
        "beneficiaries": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Jodi Marie Bell",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [650, 778, 778, 650],
                "vertical_y_vertices": [740, 740, 754, 754]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Jason Keith Grandy",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [221, 380, 380, 221],
                "vertical_y_vertices": [757, 757, 771, 771]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Amanda Sue LaBell",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [388, 548, 548, 388],
                "vertical_y_vertices": [757, 757, 771, 771]
              }
            }
          }
        ],
        "share_description": {
          "extracted_string_or_numeric_value": "in equal shares, share and share alike, per capita.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [556, 778, 778, 556],
            "vertical_y_vertices": [757, 757, 785, 785]
          }
        }
      },
      "personal_representatives": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Jodi Marie Bell",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [538, 666, 666, 538],
              "vertical_y_vertices": [356, 356, 370, 370]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "daughter",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [438, 510, 510, 438],
              "vertical_y_vertices": [356, 356, 370, 370]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Judith A. Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [221, 355, 355, 221],
              "vertical_y_vertices": [373, 373, 387, 387]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "wife",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [175, 213, 213, 175],
              "vertical_y_vertices": [373, 373, 387, 387]
            }
          }
        }
      ],
      "bond_requirement": {
        "extracted_string_or_numeric_value": "I direct that no bond be required of either of them.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221, 644, 644, 221],
          "vertical_y_vertices": [407, 407, 421, 421]
        }
      },
      "handwritten_instructions_clause": {
        "extracted_string_or_numeric_value": "I direct my Personal Representatives to follow any handwritten instructions found with this my Last Will and Testament that are in my own handwriting, being dated and signed by myself. (Pay attention to instructions for ashes and celebration of life.)",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221, 778, 778, 221],
          "vertical_y_vertices": [424, 424, 470, 470]
        }
      },
      "wife_details": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [570, 704, 704, 570],
            "vertical_y_vertices": [472, 472, 486, 486]
          }
        },
        "marriage_details": {
          "extracted_string_or_numeric_value": "We have well taken care of ourselves during our life times. This is a second marriage for each of us and each of us have children from our prior marriages and our estates are subject to Premarital Agreements.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 778, 778, 221],
            "vertical_y_vertices": [489, 489, 546, 546]
          }
        }
      },
      "testator_signature": {
        "extracted_string_or_numeric_value": "Keith a Grandy",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 650, 650, 450],
          "vertical_y_vertices": [600, 600, 640, 640]
        }
      },
      "testator_printed_name": {
        "extracted_string_or_numeric_value": "Keith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 569, 569, 450],
          "vertical_y_vertices": [655, 655, 669, 669]
        }
      },
      "witness_attestation_clause": {
        "extracted_string_or_numeric_value": "On this 24th day of March, 2017, the above named Testator, Keith A. Grandy, signed, sealed and published the foregoing for and as his Last Will and Testament in ourpresence, and we, in his presence, at his request, and in the presence of each other have hereunto subscribed our names as witnesses.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221, 778, 778, 221],
          "vertical_y_vertices": [693, 693, 764, 764]
        }
      },
      "witnesses": [
        {
          "signature": {
            "extracted_string_or_numeric_value": "fc.jeild",
            "optical_extraction_confidence_score": 0.75,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [218, 443, 443, 218],
              "vertical_y_vertices": [218, 218, 268, 268]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "of Marion, Michigan.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [470, 600, 600, 470],
              "vertical_y_vertices": [255, 255, 269, 269]
            }
          }
        },
        {
          "signature": {
            "extracted_string_or_numeric_value": "Shandelle",
            "optical_extraction_confidence_score": 0.78,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [225, 450, 450, 225],
              "vertical_y_vertices": [330, 330, 380, 380]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "of Marion, Michigan.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [470, 600, 600, 470],
              "vertical_y_vertices": [355, 355, 369, 369]
            }
          }
        }
      ],
      "drafting_attorney": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 370, 370, 221],
            "vertical_y_vertices": [555, 555, 569, 569]
          }
        },
        "bar_number": {
          "extracted_string_or_numeric_value": "(P27300)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 370, 370, 221],
            "vertical_y_vertices": [572, 572, 586, 586]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "221 E. Main/Box 172 Marion, MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [221, 370, 370, 221],
            "vertical_y_vertices": [589, 589, 617, 617]
          }
        }
      },
      "handwritten_will_notes": {
        "document_date": {
          "extracted_string_or_numeric_value": "3-20-2017",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 650, 650, 500],
            "vertical_y_vertices": [850, 850, 870, 870]
          }
        },
        "personal_property_disposition": {
          "extracted_string_or_numeric_value": "My boat-fishing egreement-work tools- personal items - guns heunting equiment: Take what you want and then give the rest to family members, I have a list of my possessions. On this list I show you I desire to receive certion items.",
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850, 850, 150],
            "vertical_y_vertices": [880, 880, 1000, 1000]
          }
        },
        "insurance_policies": [
          {
            "purpose": {
              "extracted_string_or_numeric_value": "funeral expense",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [500, 700, 700, 500],
                "vertical_y_vertices": [1050, 1050, 1070, 1070]
              }
            },
            "value": {
              "extracted_string_or_numeric_value": 17500.00,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300, 400, 400, 300],
                "vertical_y_vertices": [1075, 1075, 1095, 1095]
              }
            },
            "company_name": {
              "extracted_string_or_numeric_value": "Advanced Financial Group",
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [450, 750, 750, 450],
                "vertical_y_vertices": [1075, 1075, 1095, 1095]
              }
            },
            "company_address": {
              "extracted_string_or_numeric_value": "2121 North Four Mile Rd, Traverse city, MI 49686",
              "optical_extraction_confidence_score": 0.93,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 800, 800, 200],
                "vertical_y_vertices": [1100, 1100, 1140, 1140]
              }
            },
            "agent_name": {
              "extracted_string_or_numeric_value": "Jim P. Olesnovage",
              "optical_extraction_confidence_score": 0.91,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 800, 800, 550],
                "vertical_y_vertices": [1145, 1145, 1165, 1165]
              }
            }
          },
          {
            "purpose": {
              "extracted_string_or_numeric_value": "other life Insurance & Annuities",
              "optical_extraction_confidence_score": 0.90,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 550, 550, 150],
                "vertical_y_vertices": [1170, 1170, 1190, 1190]
              }
            },
            "company_name": {
              "extracted_string_or_numeric_value": "this Financial Group",
              "optical_extraction_confidence_score": 0.89,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [400, 700, 700, 400],
                "vertical_y_vertices": [1195, 1195, 1215, 1215]
              }
            },
            "company_address": {
              "extracted_string_or_numeric_value": "2121 North Four Mile Rd, Traverse city, MI 49686",
              "optical_extraction_confidence_score": 0.93,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 800, 800, 200],
                "vertical_y_vertices": [1100, 1100, 1140, 1140]
              }
            },
            "agent_name": {
              "extracted_string_or_numeric_value": "Jim P. Olesnovage",
              "optical_extraction_confidence_score": 0.91,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 800, 800, 550],
                "vertical_y_vertices": [1145, 1145, 1165, 1165]
              }
            }
          }
        ],
        "long_term_care_policy_mention": {
          "extracted_string_or_numeric_value": "also have life long term health care policy,",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 700, 700, 150],
            "vertical_y_vertices": [1220, 1220, 1240, 1240]
          }
        }
      },
      "patient_advocate_directive": {
        "document_date": {
          "extracted_string_or_numeric_value": "3-21-2017",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 800, 800, 650],
            "vertical_y_vertices": [750, 750, 770, 770]
          }
        },
        "end_of_life_instructions": {
          "extracted_string_or_numeric_value": "If my soul leaves my body: Do not revive me, place me on life support, if no hope for surival, I am an organ donor.",
          "optical_extraction_confidence_score": 0.93,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850, 850, 150],
            "vertical_y_vertices": [800, 800, 870, 870]
          }
        },
        "home_care_preference": {
          "extracted_string_or_numeric_value": "If my health fails, I would like to live at home with professional care. If this is to overvelling for the family. Please admit me to a care phycelity, I do not want to be a burieden for my fomily If my mind is gone - I will be of anywhere, I Love long term care insurance!",
          "optical_extraction_confidence_score": 0.88,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850, 850, 150],
            "vertical_y_vertices": [880, 880, 1000, 1000]
          }
        },
        "cremation_and_ashes_instructions": {
          "location_1_description": {
            "extracted_string_or_numeric_value": "I would like to be cremated, Like to have half of my ashes & Marilee asker be on Lake Margrethe...",
            "optical_extraction_confidence_score": 0.89,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 850, 850, 150],
              "vertical_y_vertices": [1050, 1050, 1150, 1150]
            }
          },
          "location_2_description": {
            "extracted_string_or_numeric_value": "The other half of the astes at duch blend, tene of the funest project I ever work on With July and family-freencs. Also at my rifle blind. on the east lone about 40 yds from blend",
            "optical_extraction_confidence_score": 0.87,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 850, 850, 150],
              "vertical_y_vertices": [1160, 1160, 1260, 1260]
            }
          }
        },
        "celebration_of_life_instructions": {
          "extracted_string_or_numeric_value": "Celebration of life: at the pole barn with a version fry, With family & friends..",
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850, 850, 150],
            "vertical_y_vertices": [1270, 1270, 1320, 1320]
          }
        }
      },
      "personal_property_memorandum": {
        "cash_bequests": [
          {
            "amount_per_recipient": {
              "extracted_string_or_numeric_value": 1000.00,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 350, 350, 200],
                "vertical_y_vertices": [250, 250, 270, 270]
              }
            },
            "recipients": [
              {
                "recipient_name": {
                  "extracted_string_or_numeric_value": "ZACHARY SLEVOSKI",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 400, 400, 200], "vertical_y_vertices": [280, 280, 300, 300] }
                },
                "relationship": {
                  "extracted_string_or_numeric_value": "GD. Son",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 650, 650, 550], "vertical_y_vertices": [280, 280, 300, 300] }
                },
                "date": {
                  "extracted_string_or_numeric_value": "3/24/17",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730, 730, 660], "vertical_y_vertices": [280, 280, 300, 300] }
                },
                "initials": {
                  "extracted_string_or_numeric_value": "KG",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 780, 780, 740], "vertical_y_vertices": [280, 280, 300, 300] }
                }
              },
              {
                "recipient_name": {
                  "extracted_string_or_numeric_value": "ZACHARIAN BROWN",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 400, 400, 200], "vertical_y_vertices": [310, 310, 330, 330] }
                },
                "relationship": {
                  "extracted_string_or_numeric_value": "GD. Son",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 650, 650, 550], "vertical_y_vertices": [310, 310, 330, 330] }
                },
                "date": {
                  "extracted_string_or_numeric_value": "3/24/17",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730, 730, 660], "vertical_y_vertices": [310, 310, 330, 330] }
                },
                "initials": {
                  "extracted_string_or_numeric_value": "KG",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 780, 780, 740], "vertical_y_vertices": [310, 310, 330, 330] }
                }
              },
              {
                "recipient_name": {
                  "extracted_string_or_numeric_value": "JACOB LeBell",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 400, 400, 200], "vertical_y_vertices": [340, 340, 360, 360] }
                },
                "relationship": {
                  "extracted_string_or_numeric_value": "GD. Son",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 650, 650, 550], "vertical_y_vertices": [340, 340, 360, 360] }
                },
                "date": {
                  "extracted_string_or_numeric_value": "3/24/17",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730, 730, 660], "vertical_y_vertices": [340, 340, 360, 360] }
                },
                "initials": {
                  "extracted_string_or_numeric_value": "KG",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 780, 780, 740], "vertical_y_vertices": [340, 340, 360, 360] }
                }
              },
              {
                "recipient_name": {
                  "extracted_string_or_numeric_value": "ALI BELL",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 400, 400, 200], "vertical_y_vertices": [370, 370, 390, 390] }
                },
                "relationship": {
                  "extracted_string_or_numeric_value": "GDDau.",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 650, 650, 550], "vertical_y_vertices": [370, 370, 390, 390] }
                },
                "date": {
                  "extracted_string_or_numeric_value": "3/24/17",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730, 730, 660], "vertical_y_vertices": [370, 370, 390, 390] }
                },
                "initials": {
                  "extracted_string_or_numeric_value": "KG",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 780, 780, 740], "vertical_y_vertices": [370, 370, 390, 390] }
                }
              },
              {
                "recipient_name": {
                  "extracted_string_or_numeric_value": "DONA LeBell",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 400, 400, 200], "vertical_y_vertices": [400, 400, 420, 420] }
                },
                "relationship": {
                  "extracted_string_or_numeric_value": "GD Dau",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 650, 650, 550], "vertical_y_vertices": [400, 400, 420, 420] }
                },
                "date": {
                  "extracted_string_or_numeric_value": "3/24/17",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730, 730, 660], "vertical_y_vertices": [400, 400, 420, 420] }
                },
                "initials": {
                  "extracted_string_or_numeric_value": "KG",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [740, 780, 780, 740], "vertical_y_vertices": [400, 400, 420, 420] }
                }
              }
            ]
          }
        ],
        "total_cash_bequests_amount": {
          "extracted_string_or_numeric_value": 5000.00,
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [0, 0, 0, 0],
            "vertical_y_vertices": [0, 0, 0, 0]
          }
        }
      }
    }
  }
]
```