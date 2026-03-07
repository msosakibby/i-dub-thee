An expert forensic data architect, operating under a Zero-Trust mandate, has meticulously analyzed the provided document specimen. The following Pydantic V2 schema and corresponding JSON test case have been engineered for maximum resilience and data integrity, adhering to the strict directives provided.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

# --- Provided Forensic Data Primitives ---

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# --- Document-Specific Schema ---

class Address(BaseModel):
    """A structured representation of a physical address."""
    model_config = ConfigDict(extra='forbid')
    street_line_1: ForensicDataEntity
    street_line_2: Optional[ForensicDataEntity] = None
    city_state_zip: ForensicDataEntity

class AdvancedFinancialGroupIncLetterV1(BaseModel):
    """
    Schema for letters issued by Advanced Financial Group, Inc.
    This schema is designed to be resilient to structural drift over time.
    """
    model_config = ConfigDict(extra='forbid')

    # Header Information
    company_name: ForensicDataEntity
    company_tagline: ForensicDataEntity
    staff_list: List[ForensicDataEntity]
    company_address: Address
    company_phone_numbers: List[ForensicDataEntity]
    company_fax_number: ForensicDataEntity
    company_website: ForensicDataEntity

    # Letter Core
    letter_date: ForensicDataEntity
    recipient_names: List[ForensicDataEntity]
    recipient_address: Address
    salutation: ForensicDataEntity
    letter_body: ForensicDataEntity
    closing: ForensicDataEntity
    
    # Sender and Enclosures
    sender_name_and_title: ForensicDataEntity
    sender_company: ForensicDataEntity
    enclosure_details: Optional[ForensicDataEntity] = None
    typist_initials: Optional[ForensicDataEntity] = None

    # Footer
    securities_offering_statement: ForensicDataEntity
    membership_statement: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'AdvancedFinancialGroupIncLetterV1':
        """
        A model validator for performing double-entry GAAP mathematical checksums.
        This template does not contain financial figures, so no calculations are performed.
        This validator serves as a placeholder for future versions or related document
        taxonomies that may include financial data tables.
        """
        # Example logic for a future schema with financial data:
        # if self.total_assets and self.total_liabilities and self.equity:
        #     if self.total_assets.value != self.total_liabilities.value + self.equity.value:
        #         raise ValueError("Balance sheet checksum failed: Assets != Liabilities + Equity")
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "AFG-LTR-20100423-001",
    "should_pass": true,
    "taxonomy_lane": "AdvancedFinancialGroupIncLetterV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "company_name": {
        "extracted_string_or_numeric_value": "ADVANCED Financial Group, Inc.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [64, 394],
          "vertical_y_vertices": [64, 124]
        }
      },
      "company_tagline": {
        "extracted_string_or_numeric_value": "A Registered Investment Advisor",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [148, 298],
          "vertical_y_vertices": [148, 158]
        }
      },
      "staff_list": [
        {
          "extracted_string_or_numeric_value": "John A. Ehardt, CPA, CFP",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 838],
            "vertical_y_vertices": [24, 34]
          }
        },
        {
          "extracted_string_or_numeric_value": "James P. Olesnavage, CFP",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 838],
            "vertical_y_vertices": [40, 50]
          }
        },
        {
          "extracted_string_or_numeric_value": "Tod M. Taylor, ChFC",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 810],
            "vertical_y_vertices": [56, 66]
          }
        },
        {
          "extracted_string_or_numeric_value": "Randy Brothers",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 780],
            "vertical_y_vertices": [72, 82]
          }
        },
        {
          "extracted_string_or_numeric_value": "Richard S. White",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 795],
            "vertical_y_vertices": [88, 98]
          }
        },
        {
          "extracted_string_or_numeric_value": "Louis J. Wojtowicz",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 805],
            "vertical_y_vertices": [104, 114]
          }
        },
        {
          "extracted_string_or_numeric_value": "Larry Avery",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [703, 765],
            "vertical_y_vertices": [120, 130]
          }
        }
      ],
      "company_address": {
        "street_line_1": {
          "extracted_string_or_numeric_value": "1925 Coral Lane",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [664, 838],
            "vertical_y_vertices": [150, 160]
          }
        },
        "street_line_2": {
          "extracted_string_or_numeric_value": "(formerly 2121 North Four Mile Rd.)",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [664, 838],
            "vertical_y_vertices": [166, 176]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "Traverse City, MI 49686",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [664, 838],
            "vertical_y_vertices": [182, 192]
          }
        }
      },
      "company_phone_numbers": [
        {
          "extracted_string_or_numeric_value": "(800) 968-0983",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [760, 838],
            "vertical_y_vertices": [198, 208]
          }
        },
        {
          "extracted_string_or_numeric_value": "(231) 922-8993",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [760, 838],
            "vertical_y_vertices": [214, 224]
          }
        }
      ],
      "company_fax_number": {
        "extracted_string_or_numeric_value": "Fax: (231) 922-8994",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750, 838],
          "vertical_y_vertices": [230, 240]
        }
      },
      "company_website": {
        "extracted_string_or_numeric_value": "www.advancedfinancialtc.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [695, 838],
          "vertical_y_vertices": [246, 256]
        }
      },
      "letter_date": {
        "extracted_string_or_numeric_value": "Friday, April 23, 2010",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 320],
          "vertical_y_vertices": [290, 300]
        }
      },
      "recipient_names": [
        {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [201, 310],
            "vertical_y_vertices": [355, 365]
          }
        },
        {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [201, 312],
            "vertical_y_vertices": [371, 381]
          }
        }
      ],
      "recipient_address": {
        "street_line_1": {
          "extracted_string_or_numeric_value": "P.O. Box 297",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [201, 285],
            "vertical_y_vertices": [387, 397]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "Marion, MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [201, 315],
            "vertical_y_vertices": [403, 413]
          }
        }
      },
      "salutation": {
        "extracted_string_or_numeric_value": "Dear Keith & Judy,",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 325],
          "vertical_y_vertices": [450, 460]
        }
      },
      "letter_body": {
        "extracted_string_or_numeric_value": "Here is a form that we forgot to mail to you when we sent you your Genworth Long Term Care policy. It is your copy to file with your long-term care policy records.\n\nFeel free to call me if you have any questions or if I can assist you in any way.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 838],
          "vertical_y_vertices": [485, 555]
        }
      },
      "closing": {
        "extracted_string_or_numeric_value": "Sincerely,",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 270],
          "vertical_y_vertices": [570, 580]
        }
      },
      "sender_name_and_title": {
        "extracted_string_or_numeric_value": "James P. Olesnavage, CFP™",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 380],
          "vertical_y_vertices": [645, 655]
        }
      },
      "sender_company": {
        "extracted_string_or_numeric_value": "Advanced Financial Group, Inc.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 395],
          "vertical_y_vertices": [661, 671]
        }
      },
      "enclosure_details": {
        "extracted_string_or_numeric_value": "Enclosure: Genworth LTC Disclosure Form",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 480],
          "vertical_y_vertices": [690, 700]
        }
      },
      "typist_initials": {
        "extracted_string_or_numeric_value": "/vfw",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [201, 225],
          "vertical_y_vertices": [720, 730]
        }
      },
      "securities_offering_statement": {
        "extracted_string_or_numeric_value": "Securities offered through LPL Financial",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [335, 500],
          "vertical_y_vertices": [940, 950]
        }
      },
      "membership_statement": {
        "extracted_string_or_numeric_value": "Member FINRA/SIPC",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [570, 660],
          "vertical_y_vertices": [940, 950]
        }
      }
    }
  }
]
```