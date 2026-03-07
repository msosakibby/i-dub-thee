BLOCK 1 (Python Pydantic V2):
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box of a detected text area."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class UscisChangeOfAddressConfirmationV1(BaseModel):
    """
    Schema for a U.S. Citizenship and Immigration Services (USCIS)
    Online Change of Address confirmation page from 2008.
    """
    model_config = ConfigDict(extra='forbid')

    confirmation_number: ForensicDataEntity
    form_number: ForensicDataEntity
    transaction_datetime: ForensicDataEntity
    customer_service_phone: ForensicDataEntity
    footer_date: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'UscisChangeOfAddressConfirmationV1':
        """
        A placeholder for double-entry GAAP mathematical checksums.
        No financial fields are present in this document type for validation.
        """
        # This validator is included to meet the structural requirement of the directive.
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "uscis-coa-confirmation-001",
    "should_pass": true,
    "taxonomy_lane": "UscisChangeOfAddressConfirmationV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "confirmation_number": {
        "extracted_string_or_numeric_value": "CA10550800178NSC",
        "optical_extraction_confidence_score": 0.991,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            365.0,
            535.0
          ],
          "vertical_y_vertices": [
            320.0,
            335.0
          ]
        }
      },
      "form_number": {
        "extracted_string_or_numeric_value": "N565",
        "optical_extraction_confidence_score": 0.985,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            320.0,
            350.0
          ],
          "vertical_y_vertices": [
            320.0,
            335.0
          ]
        }
      },
      "transaction_datetime": {
        "extracted_string_or_numeric_value": "02-24-2008 03:46 PM EST",
        "optical_extraction_confidence_score": 0.94,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            518.0,
            660.0
          ],
          "vertical_y_vertices": [
            723.0,
            734.0
          ]
        }
      },
      "customer_service_phone": {
        "extracted_string_or_numeric_value": "1-800-375-5283",
        "optical_extraction_confidence_score": 0.972,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            650.0,
            745.0
          ],
          "vertical_y_vertices": [
            495.0,
            508.0
          ]
        }
      },
      "footer_date": {
        "extracted_string_or_numeric_value": "2/24/2008",
        "optical_extraction_confidence_score": 0.966,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            750.0,
            805.0
          ],
          "vertical_y_vertices": [
            983.0,
            995.0
          ]
        }
      }
    }
  }
]
```