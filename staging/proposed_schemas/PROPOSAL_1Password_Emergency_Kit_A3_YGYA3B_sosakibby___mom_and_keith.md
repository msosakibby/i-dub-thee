```python
import pydantic
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

# Base classes provided in the directive
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Main Pydantic V2 schema for the 1Password Emergency Kit
class OnePasswordEmergencyKitSchema(BaseModel):
    """
    Schema for parsing a 1Password Emergency Kit document.
    """
    model_config = ConfigDict(extra='forbid')

    created_for_name: ForensicDataEntity
    creation_date: ForensicDataEntity
    sign_in_address: ForensicDataEntity
    email_address: ForensicDataEntity
    account_key: ForensicDataEntity
    master_password: ForensicDataEntity
    support_email: ForensicDataEntity
    account_code_qr: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksum(self) -> 'OnePasswordEmergencyKitSchema':
        """
        No financial figures are present in a 1Password Emergency Kit.
        This validator is included to conform to the directive's requirements
        but performs no action as there are no numbers to checksum.
        """
        # This document type does not contain financial data for checksum validation.
        return self

```

```json
[
  {
    "test_identifier": "1password_emergency_kit_complex_variant_001",
    "should_pass": true,
    "taxonomy_lane": "OnePasswordEmergencyKitSchema",
    "binary_header_simulation": "25504446",
    "payload": {
      "created_for_name": {
        "extracted_string_or_numeric_value": "Judith Grandy",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [420.0, 525.0, 525.0, 420.0],
          "vertical_y_vertices": [168.0, 168.0, 180.0, 180.0]
        }
      },
      "creation_date": {
        "extracted_string_or_numeric_value": "March 1st, 2017",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [526.0, 640.0, 640.0, 526.0],
          "vertical_y_vertices": [168.0, 168.0, 180.0, 180.0]
        }
      },
      "sign_in_address": {
        "extracted_string_or_numeric_value": "https://sosakibby.1password.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [193.0, 460.0, 460.0, 193.0],
          "vertical_y_vertices": [450.0, 450.0, 470.0, 470.0]
        }
      },
      "email_address": {
        "extracted_string_or_numeric_value": "judygrandy@hotmail.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [193.0, 395.0, 395.0, 193.0],
          "vertical_y_vertices": [535.0, 535.0, 555.0, 555.0]
        }
      },
      "account_key": {
        "extracted_string_or_numeric_value": "A3-YGYA3B-MQJ8HH-AVPQQ-PZ9ZC-73QSP-X5FAC",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [193.0, 630.0, 630.0, 193.0],
          "vertical_y_vertices": [600.0, 600.0, 620.0, 620.0]
        }
      },
      "master_password": {
        "extracted_string_or_numeric_value": "",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [193.0, 700.0, 700.0, 193.0],
          "vertical_y_vertices": [660.0, 660.0, 695.0, 695.0]
        }
      },
      "support_email": {
        "extracted_string_or_numeric_value": "support@1password.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [160.0, 345.0, 345.0, 160.0],
          "vertical_y_vertices": [830.0, 830.0, 845.0, 845.0]
        }
      },
      "account_code_qr": {
        "extracted_string_or_numeric_value": "[QR_CODE_DATA_PLACEHOLDER_A3-YGYA3B-MQJ8HH-AVPQQ-PZ9ZC-73QSP-X5FAC]",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [405.0, 605.0, 605.0, 405.0],
          "vertical_y_vertices": [770.0, 770.0, 970.0, 970.0]
        }
      }
    }
  }
]
```