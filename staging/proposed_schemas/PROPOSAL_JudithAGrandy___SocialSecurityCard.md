BLOCK 1 (Python Pydantic V2):
```python
from pydantic import BaseModel, Field, ConfigDict, model_validator
from typing import List, Optional, Union

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class JudithAGrandySocialSecurityCard(BaseModel):
    """
    Schema for a Social Security card mailer, including the detachable card and surrounding information.
    This model accommodates variations where only the card or the full mailer is present.
    """
    model_config = ConfigDict(extra='forbid')

    recipient_name: Optional[ForensicDataEntity] = None
    recipient_address: Optional[ForensicDataEntity] = None
    social_security_number: ForensicDataEntity
    cardholder_name: ForensicDataEntity
    cardholder_signature: Optional[ForensicDataEntity] = None
    form_number: Optional[ForensicDataEntity] = None
    form_revision_date: Optional[ForensicDataEntity] = None
    control_number: Optional[ForensicDataEntity] = None
    ssa_contact_phone: Optional[ForensicDataEntity] = None
    ssa_website: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_consistency_checks(self) -> 'JudithAGrandySocialSecurityCard':
        """
        Performs consistency checks on the extracted data.

        Note: No financial data exists for a double-entry GAAP mathematical checksum.
        This validator instead performs a logical consistency check by verifying that
        the recipient name on the mailer stub matches the cardholder name on the
        Social Security card, if both are present.
        """
        if self.recipient_name and self.cardholder_name:
            # Ensure names are treated as strings for comparison
            recipient_name_str = str(self.recipient_name.extracted_string_or_numeric_value).upper()
            cardholder_name_str = str(self.cardholder_name.extracted_string_or_numeric_value).upper()
            
            if recipient_name_str != cardholder_name_str:
                raise ValueError(
                    "Recipient name on mailer stub does not match cardholder name on the card. "
                    f"Stub: '{recipient_name_str}', Card: '{cardholder_name_str}'"
                )
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "ssn_mailer_judith_grandy_2004_full_document",
    "should_pass": true,
    "taxonomy_lane": "JudithAGrandySocialSecurityCard",
    "binary_header_simulation": "25504446",
    "payload": {
      "recipient_name": {
        "extracted_string_or_numeric_value": "JUDITH A GRANDY",
        "optical_extraction_confidence_score": 0.991,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [226.0, 352.0, 352.0, 226.0],
          "vertical_y_vertices": [301.0, 301.0, 312.0, 312.0]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD MARION MI 49665",
        "optical_extraction_confidence_score": 0.985,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [226.0, 352.0, 352.0, 226.0],
          "vertical_y_vertices": [318.0, 318.0, 342.0, 342.0]
        }
      },
      "social_security_number": {
        "extracted_string_or_numeric_value": "375-52-1882",
        "optical_extraction_confidence_score": 0.999,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [669.0, 760.0, 760.0, 669.0],
          "vertical_y_vertices": [325.0, 325.0, 338.0, 338.0]
        }
      },
      "cardholder_name": {
        "extracted_string_or_numeric_value": "JUDITH A GRANDY",
        "optical_extraction_confidence_score": 0.998,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [669.0, 768.0, 768.0, 669.0],
          "vertical_y_vertices": [359.0, 359.0, 369.0, 369.0]
        }
      },
      "cardholder_signature": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 0.923,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [628.0, 795.0, 795.0, 628.0],
          "vertical_y_vertices": [378.0, 378.0, 401.0, 401.0]
        }
      },
      "form_number": {
        "extracted_string_or_numeric_value": "SSA-3000",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [158.0, 260.0, 260.0, 158.0],
          "vertical_y_vertices": [884.0, 884.0, 894.0, 894.0]
        }
      },
      "form_revision_date": {
        "extracted_string_or_numeric_value": "3-2004",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [261.0, 315.0, 315.0, 261.0],
          "vertical_y_vertices": [884.0, 884.0, 894.0, 894.0]
        }
      },
      "control_number": {
        "extracted_string_or_numeric_value": "E85080345",
        "optical_extraction_confidence_score": 0.995,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [320.0, 410.0, 410.0, 320.0],
          "vertical_y_vertices": [850.0, 850.0, 865.0, 865.0]
        }
      },
      "ssa_contact_phone": {
        "extracted_string_or_numeric_value": "1-800-772-1213",
        "optical_extraction_confidence_score": 0.992,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750.0, 850.0, 850.0, 750.0],
          "vertical_y_vertices": [880.0, 880.0, 890.0, 890.0]
        }
      },
      "ssa_website": {
        "extracted_string_or_numeric_value": "www.socialsecurity.gov",
        "optical_extraction_confidence_score": 0.996,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [750.0, 880.0, 880.0, 750.0],
          "vertical_y_vertices": [890.0, 890.0, 900.0, 900.0]
        }
      }
    }
  }
]
```