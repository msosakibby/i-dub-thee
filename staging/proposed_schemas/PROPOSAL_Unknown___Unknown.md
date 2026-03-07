```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single extracted data point, including its metadata."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class SecurityWatermark(BaseModel):
    """
    Represents a document that consists entirely of a repeating security text pattern,
    often found on negotiable instruments to prevent fraud. The entire block of
    repeating text is treated as a single entity.
    """
    model_config = ConfigDict(extra='forbid')

    security_text_block: ForensicDataEntity

    @model_validator(mode='after')
    def gaap_checksum(self) -> 'SecurityWatermark':
        """
        Executes double-entry GAAP mathematical checksums.
        No financial figures are present in this document type, so this validator
        serves as a structural placeholder and always passes.
        """
        # No financial data to validate in this document type.
        return self

```
```json
[
  {
    "test_identifier": "watermark_single_block_001",
    "should_pass": true,
    "taxonomy_lane": "SecurityWatermark",
    "binary_header_simulation": "25504446",
    "payload": {
      "security_text_block": {
        "extracted_string_or_numeric_value": "THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE. THIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS\nNON-NEGOTIABLE THIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS NON-NEGOTIABLE\nTHIS PORTION IS NON-NEGOTIABLE. THIS PORTION IS NON-NEGOTIABLE",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [
            38.0,
            965.0,
            965.0,
            38.0
          ],
          "vertical_y_vertices": [
            35.0,
            35.0,
            950.0,
            950.0
          ]
        }
      }
    }
  }
]
```