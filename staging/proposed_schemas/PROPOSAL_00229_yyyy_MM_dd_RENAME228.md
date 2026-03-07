An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document, a bank statement page displaying cleared checks. My structural analysis has resulted in the following resilient Pydantic V2 schema and a corresponding JSON test case.

The schema, `Document00229V1`, models the entire page, including the header account number and a list of individual check records. Each check record is further detailed, capturing data from both the summary line beneath the check image and the data within the check image itself, such as the MICR line.

To satisfy the double-entry GAAP checksum requirement, two `model_validator` functions are implemented:
1.  A page-level validator in `Document00229V1` cross-references the main account number with the account number found in the MICR line of each cleared check, ensuring page-wide consistency.
2.  A check-level validator in `ClearedCheck` ensures internal consistency by comparing the amount and check number from the summary line against the corresponding values from the check image and its MICR line.

This multi-layered validation approach provides high confidence in the integrity of the extracted data.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data entity, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class CheckImageDetails(BaseModel):
    """Models the data extracted directly from the image of a single check."""
    model_config = ConfigDict(extra='forbid')
    
    payer_name: ForensicDataEntity
    payer_address: ForensicDataEntity
    numeric_amount: ForensicDataEntity
    routing_number_micr: ForensicDataEntity
    account_number_micr: ForensicDataEntity
    check_number_micr: ForensicDataEntity
    
    # Handwritten fields are optional due to potential OCR challenges
    payee: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None
    written_amount: Optional[ForensicDataEntity] = None
    memo: Optional[ForensicDataEntity] = None
    
class ClearedCheck(BaseModel):
    """Models the information block for a single cleared check."""
    model_config = ConfigDict(extra='forbid')
    
    check_number_header: ForensicDataEntity
    paid_date: ForensicDataEntity
    amount_footer: ForensicDataEntity
    check_details: CheckImageDetails

    @model_validator(mode='after')
    def validate_check_data_consistency(self) -> 'ClearedCheck':
        """
        Performs double-entry validation within a single check's data.
        1. Compares the amount from the footer summary to the numeric amount on the check image.
        2. Compares the check number from the header to the check number in the MICR line.
        """
        # 1. Validate amount consistency
        footer_amount = self.amount_footer.extracted_string_or_numeric_value
        image_amount = self.check_details.numeric_amount.extracted_string_or_numeric_value
        if float(footer_amount) != float(image_amount):
            raise ValueError(f"Footer amount {footer_amount} does not match image amount {image_amount}")

        # 2. Validate check number consistency
        header_check_num_str = str(self.check_number_header.extracted_string_or_numeric_value)
        header_check_num = ''.join(filter(str.isdigit, header_check_num_str))
        micr_check_num = str(self.check_details.check_number_micr.extracted_string_or_numeric_value)
        
        if header_check_num != micr_check_num:
            raise ValueError(f"Header check number {header_check_num} does not match MICR check number {micr_check_num}")
            
        return self

class Document00229V1(BaseModel):
    """
    Schema for a bank statement page containing images of cleared checks.
    Taxonomy Lane: 00229 yyyy-MM-dd_RENAME228
    """
    model_config = ConfigDict(extra='forbid')
    
    page_number: ForensicDataEntity
    account_number: ForensicDataEntity
    cleared_checks: List[ClearedCheck]

    @model_validator(mode='after')
    def validate_account_number_consistency(self) -> 'Document00229V1':
        """
        Cross-references the account number in the document header against the
        account number in the MICR line of each cleared check.
        """
        header_account_num = self.account_number.extracted_string_or_numeric_value
        for i, check in enumerate(self.cleared_checks):
            micr_account_num = check.check_details.account_number_micr.extracted_string_or_numeric_value
            if str(header_account_num) != str(micr_account_num):
                check_num_str = check.check_number_header.extracted_string_or_numeric_value or f"at index {i}"
                raise ValueError(
                    f"Header account number '{header_account_num}' does not match MICR account number "
                    f"'{micr_account_num}' for check {check_num_str}"
                )
        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "00229_2014-06-13_full_page_check_images",
    "should_pass": true,
    "taxonomy_lane": "Document00229V1",
    "binary_header_simulation": "25504446",
    "payload": {
      "page_number": {
        "extracted_string_or_numeric_value": 4,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [180, 240],
          "vertical_y_vertices": [40, 55]
        }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "2010277008",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [180, 390],
          "vertical_y_vertices": [60, 75]
        }
      },
      "cleared_checks": [
        {
          "check_number_header": {
            "extracted_string_or_numeric_value": "Check #4810",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [180, 250],
              "vertical_y_vertices": [285, 295]
            }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "06/09/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 370],
              "vertical_y_vertices": [285, 295]
            }
          },
          "amount_footer": {
            "extracted_string_or_numeric_value": 60.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 500],
              "vertical_y_vertices": [285, 295]
            }
          },
          "check_details": {
            "payer_name": {
              "extracted_string_or_numeric_value": "J.A. GRANDY",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 260], "vertical_y_vertices": [180, 190] }
            },
            "payer_address": {
              "extracted_string_or_numeric_value": "P. O. BOX 297 MARION, MI 49665",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 300], "vertical_y_vertices": [190, 210] }
            },
            "numeric_amount": {
              "extracted_string_or_numeric_value": 60.00,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [430, 480], "vertical_y_vertices": [200, 215] }
            },
            "routing_number_micr": {
              "extracted_string_or_numeric_value": "072410013",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 270], "vertical_y_vertices": [260, 270] }
            },
            "account_number_micr": {
              "extracted_string_or_numeric_value": "2010277008",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 380], "vertical_y_vertices": [260, 270] }
            },
            "check_number_micr": {
              "extracted_string_or_numeric_value": "4810",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 430], "vertical_y_vertices": [260, 270] }
            }
          }
        },
        {
          "check_number_header": {
            "extracted_string_or_numeric_value": "Check #4811",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 610], "vertical_y_vertices": [285, 295] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "06/12/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730], "vertical_y_vertices": [285, 295] }
          },
          "amount_footer": {
            "extracted_string_or_numeric_value": 20.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [810, 860], "vertical_y_vertices": [285, 295] }
          },
          "check_details": {
            "payer_name": {
              "extracted_string_or_numeric_value": "J.A. GRANDY",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 620], "vertical_y_vertices": [180, 190] }
            },
            "payer_address": {
              "extracted_string_or_numeric_value": "P. O. BOX 297 MARION, MI 49665",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 660], "vertical_y_vertices": [190, 210] }
            },
            "payee": {
              "extracted_string_or_numeric_value": "Monster",
              "optical_extraction_confidence_score": 0.85,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [580, 650], "vertical_y_vertices": [215, 225] }
            },
            "numeric_amount": {
              "extracted_string_or_numeric_value": 20.00,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 840], "vertical_y_vertices": [200, 215] }
            },
            "routing_number_micr": {
              "extracted_string_or_numeric_value": "072410013",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 630], "vertical_y_vertices": [260, 270] }
            },
            "account_number_micr": {
              "extracted_string_or_numeric_value": "2010277008",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [640, 740], "vertical_y_vertices": [260, 270] }
            },
            "check_number_micr": {
              "extracted_string_or_numeric_value": "4811",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 790], "vertical_y_vertices": [260, 270] }
            }
          }
        },
        {
          "check_number_header": {
            "extracted_string_or_numeric_value": "Check #4812",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 250], "vertical_y_vertices": [420, 430] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "06/10/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 370], "vertical_y_vertices": [420, 430] }
          },
          "amount_footer": {
            "extracted_string_or_numeric_value": 2155.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 500], "vertical_y_vertices": [420, 430] }
          },
          "check_details": {
            "payer_name": {
              "extracted_string_or_numeric_value": "J.A. GRANDY",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 260], "vertical_y_vertices": [315, 325] }
            },
            "payer_address": {
              "extracted_string_or_numeric_value": "P. O. BOX 297 MARION, MI 49665",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 300], "vertical_y_vertices": [325, 345] }
            },
            "numeric_amount": {
              "extracted_string_or_numeric_value": 2155.00,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [430, 480], "vertical_y_vertices": [335, 350] }
            },
            "routing_number_micr": {
              "extracted_string_or_numeric_value": "072410013",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 270], "vertical_y_vertices": [395, 405] }
            },
            "account_number_micr": {
              "extracted_string_or_numeric_value": "2010277008",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [280, 380], "vertical_y_vertices": [395, 405] }
            },
            "check_number_micr": {
              "extracted_string_or_numeric_value": "4812",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 430], "vertical_y_vertices": [395, 405] }
            }
          }
        },
        {
          "check_number_header": {
            "extracted_string_or_numeric_value": "Check #4813",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 610], "vertical_y_vertices": [420, 430] }
          },
          "paid_date": {
            "extracted_string_or_numeric_value": "06/13/2014",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [660, 730], "vertical_y_vertices": [420, 430] }
          },
          "amount_footer": {
            "extracted_string_or_numeric_value": 6.96,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [810, 860], "vertical_y_vertices": [420, 430] }
          },
          "check_details": {
            "payer_name": {
              "extracted_string_or_numeric_value": "J.A. GRANDY",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 620], "vertical_y_vertices": [315, 325] }
            },
            "payer_address": {
              "extracted_string_or_numeric_value": "P. O. BOX 297 MARION, MI 49665",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 660], "vertical_y_vertices": [325, 345] }
            },
            "numeric_amount": {
              "extracted_string_or_numeric_value": 6.96,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [790, 840], "vertical_y_vertices": [335, 350] }
            },
            "routing_number_micr": {
              "extracted_string_or_numeric_value": "072410013",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 630], "vertical_y_vertices": [395, 405] }
            },
            "account_number_micr": {
              "extracted_string_or_numeric_value": "2010277008",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [640, 740], "vertical_y_vertices": [395, 405] }
            },
            "check_number_micr": {
              "extracted_string_or_numeric_value": "4813",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 790], "vertical_y_vertices": [395, 405] }
            }
          }
        }
      ]
    }
  }
]
```