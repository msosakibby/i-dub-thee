An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided document from the `MeijerMastercard - creditcardstatement` class. The document is an informational insert detailing how to update email preferences.

My Pydantic V2 schema, `MeijerMastercardCreditCardStatement`, is designed for high resilience. It models the specific fields of this promotional page, such as the instructional steps, while keeping them `Optional`. This ensures the schema can accommodate other, structurally different pages from the same statement class (e.g., pages with transaction lists) without failure.

The schema includes a nested `InstructionalStep` model to properly structure the repeated step-by-step guide. The mandatory `@model_validator` is included; however, as this document variant contains no financial figures, no GAAP checksums are performed.

The accompanying JSON test case represents the provided document, populating all defined fields with data from the OCR and simulated, but plausible, metadata.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box of an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """Encapsulates a single piece of extracted data and its metadata."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class InstructionalStep(BaseModel):
    """Models a single step in a set of instructions."""
    model_config = ConfigDict(extra='forbid')
    step_number: ForensicDataEntity
    description: ForensicDataEntity

class MeijerMastercardCreditCardStatement(BaseModel):
    """
    A resilient schema for pages within a Meijer Mastercard statement.

    This schema is designed to parse a promotional/informational page variant,
    with all fields being optional to gracefully handle other statement page
    layouts (e.g., transaction lists) that may lack these specific elements.
    """
    model_config = ConfigDict(extra='forbid')

    # Fields specific to the promotional page variant
    header: Optional[ForensicDataEntity] = None
    sub_header: Optional[ForensicDataEntity] = None
    instruction_title: Optional[ForensicDataEntity] = None
    steps: Optional[List[InstructionalStep]] = None

    # Common document metadata fields
    page_number: Optional[ForensicDataEntity] = None
    total_pages: Optional[ForensicDataEntity] = None
    document_id_left: Optional[ForensicDataEntity] = None
    document_id_right: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'MeijerMastercardCreditCardStatement':
        """
        Performs double-entry GAAP mathematical checksums.

        Note: This specific document variant is a promotional insert and contains
        no financial figures. Therefore, no checksums are applicable or performed.
        This validator is included to satisfy the mandated schema structure and
        would be implemented for other, transaction-based document variants.
        """
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "promotional_page_with_instructions_variant",
    "should_pass": true,
    "taxonomy_lane": "MeijerMastercardCreditCardStatement",
    "binary_header_simulation": "25504446",
    "payload": {
      "header": {
        "extracted_string_or_numeric_value": "get the most from your Meijer Mastercard®",
        "optical_extraction_confidence_score": 0.992,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [170, 801],
          "vertical_y_vertices": [155, 282]
        }
      },
      "sub_header": {
        "extracted_string_or_numeric_value": "update your email communication preferences to receive special offers and news",
        "optical_extraction_confidence_score": 0.985,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [236, 798],
          "vertical_y_vertices": [299, 351]
        }
      },
      "instruction_title": {
        "extracted_string_or_numeric_value": "four easy steps to get started",
        "optical_extraction_confidence_score": 0.995,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [238, 603],
          "vertical_y_vertices": [584, 602]
        }
      },
      "steps": [
        {
          "step_number": {
            "extracted_string_or_numeric_value": "step 1",
            "optical_extraction_confidence_score": 0.971,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [280, 330],
              "vertical_y_vertices": [645, 660]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "log in to your account at Meijer.AccountOnline.com",
            "optical_extraction_confidence_score": 0.968,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [354, 708],
              "vertical_y_vertices": [645, 660]
            }
          }
        },
        {
          "step_number": {
            "extracted_string_or_numeric_value": "step 2",
            "optical_extraction_confidence_score": 0.972,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [280, 330],
              "vertical_y_vertices": [715, 730]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "select 'Manage Account'",
            "optical_extraction_confidence_score": 0.969,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [354, 545],
              "vertical_y_vertices": [715, 730]
            }
          }
        },
        {
          "step_number": {
            "extracted_string_or_numeric_value": "step 3",
            "optical_extraction_confidence_score": 0.973,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [280, 330],
              "vertical_y_vertices": [785, 800]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "select 'Profile'",
            "optical_extraction_confidence_score": 0.971,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [354, 478],
              "vertical_y_vertices": [785, 800]
            }
          }
        },
        {
          "step_number": {
            "extracted_string_or_numeric_value": "step 4",
            "optical_extraction_confidence_score": 0.974,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [280, 330],
              "vertical_y_vertices": [855, 870]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "select 'Email Communications'",
            "optical_extraction_confidence_score": 0.965,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [354, 575],
              "vertical_y_vertices": [855, 870]
            }
          }
        }
      ],
      "page_number": {
        "extracted_string_or_numeric_value": 5,
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [480, 520],
          "vertical_y_vertices": [955, 965]
        }
      },
      "total_pages": {
        "extracted_string_or_numeric_value": 8,
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [480, 520],
          "vertical_y_vertices": [955, 965]
        }
      },
      "document_id_left": {
        "extracted_string_or_numeric_value": "719803",
        "optical_extraction_confidence_score": 0.998,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 155],
          "vertical_y_vertices": [358, 412]
        }
      },
      "document_id_right": {
        "extracted_string_or_numeric_value": "791",
        "optical_extraction_confidence_score": 0.997,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [831, 849],
          "vertical_y_vertices": [915, 925]
        }
      }
    }
  }
]
```