An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document for class '001155'. The document is a multi-page correspondence letter from a law firm regarding estate planning. It includes structured data such as sender/recipient details, dated information, and itemized lists of documents and recommendations. The schema below is designed to be resilient, capturing all identified data points, including lists and an optional monetary value, while adhering to the strict requirements of the directive.

***

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of an extracted entity on the document page."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for each extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class EstatePlanningCorrespondence(BaseModel):
    """
    Schema for estate planning correspondence letters from law firms.
    This class captures sender, recipient, date, subject, and the body of the letter,
    which often includes lists of documents, recommendations, and action items.
    """
    model_config = ConfigDict(extra='forbid')

    # Header Information
    law_firm_name: ForensicDataEntity
    law_firm_address: ForensicDataEntity
    law_firm_phone_numbers: List[ForensicDataEntity]
    law_firm_fax_number: ForensicDataEntity
    law_firm_website: ForensicDataEntity

    # Letter Metadata
    letter_date: ForensicDataEntity
    subject: ForensicDataEntity

    # Recipient Information
    recipient_names: List[ForensicDataEntity]
    recipient_address: ForensicDataEntity
    salutation: ForensicDataEntity

    # Letter Body Content
    enclosed_documents_list: List[ForensicDataEntity]
    recommendations_and_questions: List[ForensicDataEntity]
    document_retrieval_fee: Optional[ForensicDataEntity] = None

    # Footer Information
    attorney_list: List[ForensicDataEntity]
    parent_organization_statement: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'EstatePlanningCorrespondence':
        """
        Performs double-entry GAAP mathematical checksums.
        
        In this document class, there are no complex financial calculations to validate.
        The only monetary value is a single, optional fee for document retrieval.
        As there are no totals, subtotals, or itemized lists to sum and cross-reference,
        this validator confirms the structural integrity without performing arithmetic checks.
        """
        # No arithmetic checksums are applicable for this document structure.
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "doc_001155_variant_001_complex",
    "should_pass": true,
    "taxonomy_lane": "EstatePlanningCorrespondence",
    "binary_header_simulation": "25504446",
    "payload": {
      "law_firm_name": {
        "extracted_string_or_numeric_value": "the LAW CENTER for CHILDREN & FAMILIES",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [308, 462],
          "vertical_y_vertices": [59, 109]
        }
      },
      "law_firm_address": {
        "extracted_string_or_numeric_value": "450 S. YELLOWSTONE DR.\nMADISON, WI 53719-1068",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [491, 620],
          "vertical_y_vertices": [59, 80]
        }
      },
      "law_firm_phone_numbers": [
        {
          "extracted_string_or_numeric_value": "TEL 608-821-8200",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [491, 569],
            "vertical_y_vertices": [83, 91]
          }
        },
        {
          "extracted_string_or_numeric_value": "888-860-KIDS (5437)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [491, 589],
            "vertical_y_vertices": [94, 102]
          }
        }
      ],
      "law_firm_fax_number": {
        "extracted_string_or_numeric_value": "FAX 608-821-8201",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [491, 569],
          "vertical_y_vertices": [105, 113]
        }
      },
      "law_firm_website": {
        "extracted_string_or_numeric_value": "www.law4kids.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [491, 575],
          "vertical_y_vertices": [116, 124]
        }
      },
      "letter_date": {
        "extracted_string_or_numeric_value": "May 31, 2012",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [203, 291],
          "vertical_y_vertices": [179, 188]
        }
      },
      "recipient_names": [
        {
          "extracted_string_or_numeric_value": "Mr. Mark Sosa-Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 333],
            "vertical_y_vertices": [203, 212]
          }
        },
        {
          "extracted_string_or_numeric_value": "Mr. Erik Sosa-Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 328],
            "vertical_y_vertices": [218, 227]
          }
        }
      ],
      "recipient_address": {
        "extracted_string_or_numeric_value": "15203 74th Street\nKenosha, WI 53142",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [203, 333],
          "vertical_y_vertices": [233, 257]
        }
      },
      "subject": {
        "extracted_string_or_numeric_value": "Life and Estate Planning",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [203, 378],
          "vertical_y_vertices": [287, 296]
        }
      },
      "salutation": {
        "extracted_string_or_numeric_value": "Dear Mark and Erik:",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [203, 333],
          "vertical_y_vertices": [317, 326]
        }
      },
      "enclosed_documents_list": [
        {
          "extracted_string_or_numeric_value": "Will (with Minor Support Trust for the children)",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 610],
            "vertical_y_vertices": [428, 438]
          }
        },
        {
          "extracted_string_or_numeric_value": "Document Disposing of My Tangible Personal Property",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 638],
            "vertical_y_vertices": [453, 463]
          }
        },
        {
          "extracted_string_or_numeric_value": "Nomination of Guardian for Minor Children",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 568],
            "vertical_y_vertices": [478, 488]
          }
        },
        {
          "extracted_string_or_numeric_value": "Power of Attorney for Finances and Property",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 580],
            "vertical_y_vertices": [503, 513]
          }
        },
        {
          "extracted_string_or_numeric_value": "Power of Attorney for Health Care and Living Will and Declaration to Physicians",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 788],
            "vertical_y_vertices": [528, 550]
          }
        },
        {
          "extracted_string_or_numeric_value": "Authorization for Visitation in Health Care Facilities and to Disclose Health Care Information and Records",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 788],
            "vertical_y_vertices": [565, 587]
          }
        }
      ],
      "recommendations_and_questions": [
        {
          "extracted_string_or_numeric_value": "Congratulations on your domestic partnership. Good work on getting that done. Please confirm that you have no other statuses, e.g., California marriage, Illinois civil union, etc. Please also confirm that you have not had a wedding/commitment ceremony.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 788],
            "vertical_y_vertices": [150, 215]
          }
        },
        {
          "extracted_string_or_numeric_value": "Enclosed please find a table listing all of your assets. It is based on the documents you emailed. Please confirm that this is a complete and accurate list. It is very important that I know about each and every asset, for tax planning and non-probate transfer purposes.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 788],
            "vertical_y_vertices": [227, 292]
          }
        },
        {
          "extracted_string_or_numeric_value": "I highly recommend a Cohabitation Agreement in your case. I recommend them for all couples, same- or opposite-sex. In your case, however, my recommendation is stronger because (1) you are a household with a sole breadwinner and a stay-at-home parent, and (2) only one of you is on the title to the family home. The Agreement would be similar to a post-nuptial agreement. It would address issues such as how expenses are paid during the relationship, ownership of your home and investment property and division of any sale proceeds, future property acquisitions, and support and property division rights after a break-up, for example, maintenance/alimony. Basically, it fills the vacuum that is LGBT property and break-up law in Wisconsin. Some argue, myself included, that it is more important for same-sex couples to execute break-up agreements than opposite-sex couples, because at least opposite-sex couples have divorce law to fall back upon. In Wisconsin, same-sex couples have a vacuum and often unfriendly judges. You would need separate representation for the Agreement; I could not jointly represent you. Upon request, we can discuss this Agreement, and the process of separate representation, in more detail.",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 788],
            "vertical_y_vertices": [304, 600]
          }
        },
        {
          "extracted_string_or_numeric_value": "I do not think a Co-Parenting Agreement is necessary in your case, as you are equal legal parents with a co-parent adoption from a state where such a thing is uncontroversial. Your adoption order should be recognized and respected in all states.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 788],
            "vertical_y_vertices": [624, 672]
          }
        },
        {
          "extracted_string_or_numeric_value": "When we complete your beneficiary designations (see above), we'll need to talk about how to fund the specific bequest to Erik's mom in your Wills. FYI for now.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 788],
            "vertical_y_vertices": [696, 728]
          }
        },
        {
          "extracted_string_or_numeric_value": "What was your family's gross income last year?",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [242, 630],
            "vertical_y_vertices": [752, 761]
          }
        },
        {
          "extracted_string_or_numeric_value": "I need a copy of the deed to your home. You sent me an appraisal and the closing documents, but not the deed. If you do not have the deed, let me know and we can obtain one online for approximately $7.00.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [203, 788],
            "vertical_y_vertices": [776, 824]
          }
        }
      ],
      "document_retrieval_fee": {
        "extracted_string_or_numeric_value": 7.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [680, 720],
          "vertical_y_vertices": [815, 824]
        }
      },
      "attorney_list": [
        {
          "extracted_string_or_numeric_value": "JUDITH SPERLING-NEWTON",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [208, 350],
            "vertical_y_vertices": [907, 915]
          }
        },
        {
          "extracted_string_or_numeric_value": "CAROL M. GAPEN",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [352, 440],
            "vertical_y_vertices": [907, 915]
          }
        },
        {
          "extracted_string_or_numeric_value": "LYNN J. BODI",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [442, 510],
            "vertical_y_vertices": [907, 915]
          }
        },
        {
          "extracted_string_or_numeric_value": "JALBERTO QUIROGA",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [512, 610],
            "vertical_y_vertices": [907, 915]
          }
        },
        {
          "extracted_string_or_numeric_value": "EMILY DUDAK TAYLOR",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [612, 720],
            "vertical_y_vertices": [907, 915]
          }
        },
        {
          "extracted_string_or_numeric_value": "SARA M. VANDEN BROOK",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [722, 850],
            "vertical_y_vertices": [907, 915]
          }
        }
      ],
      "parent_organization_statement": {
        "extracted_string_or_numeric_value": "THE LAW CENTER FOR CHILDREN & FAMILIES IS PART OF BODI, GAPEN AND SPERLING-NEWTON, S.C., A LIMITED LIABILITY ORGANIZATION",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [208, 850],
          "vertical_y_vertices": [918, 926]
        }
      }
    }
  }
]
```