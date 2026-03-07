BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class AsianEfficiencyNewsletter(BaseModel):
    """
    Schema for email newsletters from Asian Efficiency.
    """
    model_config = ConfigDict(extra='forbid')

    header_title: Optional[ForensicDataEntity] = None
    logo_text: Optional[ForensicDataEntity] = None
    article_title: Optional[ForensicDataEntity] = None
    greeting: Optional[ForensicDataEntity] = None
    body_paragraphs: Optional[List[ForensicDataEntity]] = None
    call_to_action_link_text: Optional[ForensicDataEntity] = None
    call_to_action_logo_text: Optional[List[ForensicDataEntity]] = None
    sign_off: Optional[ForensicDataEntity] = None
    senders: Optional[ForensicDataEntity] = None
    footer_copyright: Optional[ForensicDataEntity] = None
    footer_subscription_reason: Optional[ForensicDataEntity] = None
    footer_unsubscribe_prompt: Optional[ForensicDataEntity] = None
    footer_unsubscribe_link_text: Optional[ForensicDataEntity] = None
    footer_address: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'AsianEfficiencyNewsletter':
        """
        Executes double-entry GAAP mathematical checksums.
        This document class does not contain financial figures for checksum validation.
        The validator is included to meet structural requirements but performs no financial checks.
        """
        # No financial fields (e.g., subtotal, tax, total, debits, credits) were
        # identified in the provided document examples for this class.
        # If future document variants include such data, this validator
        # should be updated to perform relevant checksums.
        return self

```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "000079-20240401-001",
    "should_pass": true,
    "taxonomy_lane": "AsianEfficiencyNewsletter",
    "binary_header_simulation": "25504446",
    "payload": {
      "header_title": {
        "extracted_string_or_numeric_value": "How to hone your self-discipline",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [103.0, 378.0, 378.0, 103.0],
          "vertical_y_vertices": [103.0, 103.0, 118.0, 118.0]
        }
      },
      "logo_text": {
        "extracted_string_or_numeric_value": "ASIANEFFICIENCY",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [483.0, 742.0, 742.0, 483.0],
          "vertical_y_vertices": [184.0, 184.0, 215.0, 215.0]
        }
      },
      "article_title": {
        "extracted_string_or_numeric_value": "5AM Sunrise",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [216.0, 320.0, 320.0, 216.0],
          "vertical_y_vertices": [296.0, 296.0, 312.0, 312.0]
        }
      },
      "greeting": {
        "extracted_string_or_numeric_value": "Hi Mark,",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [216.0, 275.0, 275.0, 216.0],
          "vertical_y_vertices": [330.0, 330.0, 342.0, 342.0]
        }
      },
      "body_paragraphs": [
        {
          "extracted_string_or_numeric_value": "As I write this I'm sitting by the beach in Bali, watching the sunrise.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 630.0, 630.0, 216.0],
            "vertical_y_vertices": [364.0, 364.0, 376.0, 376.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "The reason that I can do this is because I've cultivated the habit of waking up early - at 5am, every day, no matter where I am.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 770.0, 770.0, 216.0],
            "vertical_y_vertices": [764.0, 764.0, 788.0, 788.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "It doesn't matter if I'm in a different city, a different timezone, if I'm at the beach, or if I'm staying in the middle of a large city - it's always 5am, whenever possible.",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 770.0, 770.0, 216.0],
            "vertical_y_vertices": [814.0, 814.0, 850.0, 850.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "Waking up at 5am has a lot of benefits to it.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 530.0, 530.0, 216.0],
            "vertical_y_vertices": [868.0, 868.0, 880.0, 880.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "You start the day early, and with a clarity of thought that just doesn't seem to arise if you wake up later.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [216.0, 770.0, 770.0, 216.0],
            "vertical_y_vertices": [900.0, 900.0, 928.0, 928.0]
          }
        }
      ],
      "call_to_action_link_text": {
        "extracted_string_or_numeric_value": "check out the Productivity Blueprint",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [485.0, 705.0, 705.0, 485.0],
          "vertical_y_vertices": [385.0, 385.0, 397.0, 397.0]
        }
      },
      "call_to_action_logo_text": [
        {
          "extracted_string_or_numeric_value": "PRODUCTIVITY",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220.0, 388.0, 388.0, 220.0],
            "vertical_y_vertices": [460.0, 460.0, 475.0, 475.0]
          }
        },
        {
          "extracted_string_or_numeric_value": "BLUEPRINT",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220.0, 388.0, 388.0, 220.0],
            "vertical_y_vertices": [490.0, 490.0, 505.0, 505.0]
          }
        }
      ],
      "sign_off": {
        "extracted_string_or_numeric_value": "All the best,",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [216.0, 295.0, 295.0, 216.0],
          "vertical_y_vertices": [618.0, 618.0, 630.0, 630.0]
        }
      },
      "senders": {
        "extracted_string_or_numeric_value": "Aaron & the AE team",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [216.0, 345.0, 345.0, 216.0],
          "vertical_y_vertices": [636.0, 636.0, 648.0, 648.0]
        }
      },
      "footer_copyright": {
        "extracted_string_or_numeric_value": "Copyright © Asian Efficiency Limited, All Rights Reserved.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221.0, 525.0, 525.0, 221.0],
          "vertical_y_vertices": [790.0, 790.0, 800.0, 800.0]
        }
      },
      "footer_subscription_reason": {
        "extracted_string_or_numeric_value": "You are receiving this because you subscribed to our newsletter and/or purchased the AE Primer.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [221.0, 720.0, 720.0, 221.0],
          "vertical_y_vertices": [818.0, 818.0, 828.0, 828.0]
        }
      },
      "footer_unsubscribe_prompt": {
        "extracted_string_or_numeric_value": "If you wish to stop receiving our emails or change your subscription options, please",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178.0, 740.0, 740.0, 178.0],
          "vertical_y_vertices": [85.0, 85.0, 96.0, 96.0]
        }
      },
      "footer_unsubscribe_link_text": {
        "extracted_string_or_numeric_value": "Manage Your Subscription",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178.0, 330.0, 330.0, 178.0],
          "vertical_y_vertices": [98.0, 98.0, 110.0, 110.0]
        }
      },
      "footer_address": {
        "extracted_string_or_numeric_value": "Asian Efficiency Limited, 10 Anson Road, #16-16/6920, International Plaza, Singapore,",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [178.0, 780.0, 780.0, 178.0],
          "vertical_y_vertices": [122.0, 122.0, 133.0, 133.0]
        }
      }
    }
  }
]
```