```python
import pydantic
from typing import List, Optional, Union

# DO NOT MODIFY THESE CLASSES
class SpatialCoordinatesPolygon(pydantic.BaseModel):
    model_config = pydantic.ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(pydantic.BaseModel):
    model_config = pydantic.ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = pydantic.Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# START OF SCHEMA DEFINITION

class Attendee(pydantic.BaseModel):
    """Represents an individual's attendance status for a meeting."""
    model_config = pydantic.ConfigDict(extra='forbid')
    name: ForensicDataEntity
    status: ForensicDataEntity # e.g., "Accepted", "Declined"

class MeetingDetails(pydantic.BaseModel):
    """Detailed information about a specific meeting, often from an invite."""
    model_config = pydantic.ConfigDict(extra='forbid')
    
    title: ForensicDataEntity
    wbs_code: Optional[ForensicDataEntity] = None
    location_or_dial_in: Optional[ForensicDataEntity] = None
    webex_info: Optional[ForensicDataEntity] = None
    
    invited_count: Optional[ForensicDataEntity] = None
    accepted_count: Optional[ForensicDataEntity] = None
    declined_count: Optional[ForensicDataEntity] = None
    unknown_status_count: Optional[ForensicDataEntity] = None
    
    attendees: Optional[List[Attendee]] = None
    agenda: Optional[ForensicDataEntity] = None
    meeting_invite_content: Optional[ForensicDataEntity] = None
    program_details: Optional[ForensicDataEntity] = None

    @pydantic.model_validator(mode='after')
    def validate_attendee_counts_checksum(self) -> 'MeetingDetails':
        """
        Performs a double-entry style checksum on attendee counts.
        The number of invited people must equal the sum of accepted, declined, and unknown statuses.
        """
        # Proceed only if all necessary count fields are present
        if all([self.invited_count, self.accepted_count, self.declined_count, self.unknown_status_count]):
            invited = self.invited_count.extracted_string_or_numeric_value
            accepted = self.accepted_count.extracted_string_or_numeric_value
            declined = self.declined_count.extracted_string_or_numeric_value
            unknown = self.unknown_status_count.extracted_string_or_numeric_value

            # Ensure all values are numeric before performing the check
            if all(isinstance(v, (int, float)) for v in [invited, accepted, declined, unknown]):
                if invited != (accepted + declined + unknown):
                    raise ValueError(
                        f"Attendee count mismatch: Invited ({invited}) != "
                        f"Accepted ({accepted}) + Declined ({declined}) + Unknown ({unknown})"
                    )
        return self

class ScheduledEvent(pydantic.BaseModel):
    """Represents a single event on the daily calendar."""
    model_config = pydantic.ConfigDict(extra='forbid')
    
    start_time: ForensicDataEntity
    end_time: Optional[ForensicDataEntity] = None
    title: ForensicDataEntity
    location: Optional[ForensicDataEntity] = None
    details: Optional[MeetingDetails] = None

class HandwrittenNote(pydantic.BaseModel):
    """Represents unstructured, handwritten notes or diagrams."""
    model_config = pydantic.ConfigDict(extra='forbid')
    
    title: Optional[ForensicDataEntity] = None
    transcribed_text: ForensicDataEntity
    
class PresentationSlide(pydantic.BaseModel):
    """Represents a single slide from an associated presentation."""
    model_config = pydantic.ConfigDict(extra='forbid')
    
    slide_title: Optional[ForensicDataEntity] = None
    content_elements: List[ForensicDataEntity]
    annotations: Optional[List[ForensicDataEntity]] = None

class DailyRecordOfEventsab(pydantic.BaseModel):
    """
    A highly resilient schema for the 'Daily Record of Eventsab' document class,
    accommodating various layouts including daily schedules, detailed meeting invites,
    presentation slides, and handwritten notes.
    """
    model_config = pydantic.ConfigDict(extra='forbid')
    
    document_title: ForensicDataEntity
    record_date: ForensicDataEntity
    daily_schedule: List[ScheduledEvent]
    associated_notes: Optional[List[Union[HandwrittenNote, PresentationSlide]]] = None
    inspirational_content: Optional[List[ForensicDataEntity]] = None
```

```json
[
  {
    "test_identifier": "daily_record_2018-11-27_full_structure",
    "should_pass": true,
    "taxonomy_lane": "DailyRecordOfEventsab",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "2018-11-27 | Daily Record of Events | Planning & Solitude MasterNote | Prioritized Daily Task List",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [48, 792],
          "vertical_y_vertices": [46, 58]
        }
      },
      "record_date": {
        "extracted_string_or_numeric_value": "2018-11-27",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 218],
          "vertical_y_vertices": [260, 275]
        }
      },
      "daily_schedule": [
        {
          "start_time": {
            "extracted_string_or_numeric_value": "10:00",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [495, 528],
              "vertical_y_vertices": [490, 500]
            }
          },
          "title": {
            "extracted_string_or_numeric_value": "The Technique deck work",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [188, 350],
              "vertical_y_vertices": [490, 500]
            }
          }
        },
        {
          "start_time": {
            "extracted_string_or_numeric_value": "11:30",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [118, 148],
              "vertical_y_vertices": [645, 655]
            }
          },
          "title": {
            "extracted_string_or_numeric_value": "Mark + Nikita Touchpoint",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [188, 350],
              "vertical_y_vertices": [645, 655]
            }
          },
          "details": {
            "title": {
              "extracted_string_or_numeric_value": "2018-11-27 11:30 - Mark + Nikita Touchpoint",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [118, 450],
                "vertical_y_vertices": [30, 45]
              }
            },
            "wbs_code": {
              "extracted_string_or_numeric_value": "01326035001",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [118, 450],
                "vertical_y_vertices": [80, 95]
              }
            },
            "location_or_dial_in": {
              "extracted_string_or_numeric_value": "HCSC 10th Floor; Alt: Nikita to call Mark's cell",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [460, 800],
                "vertical_y_vertices": [80, 110]
              }
            },
            "invited_count": {
              "extracted_string_or_numeric_value": 2,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [118, 125],
                "vertical_y_vertices": [160, 170]
              }
            },
            "accepted_count": {
              "extracted_string_or_numeric_value": 2,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [300, 307],
                "vertical_y_vertices": [160, 170]
              }
            },
            "declined_count": {
              "extracted_string_or_numeric_value": 0,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 377],
                "vertical_y_vertices": [160, 170]
              }
            },
            "unknown_status_count": {
              "extracted_string_or_numeric_value": 0,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [440, 447],
                "vertical_y_vertices": [160, 170]
              }
            },
            "attendees": [
              {
                "name": {
                  "extracted_string_or_numeric_value": "Mark Kibby",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [120, 200],
                    "vertical_y_vertices": [250, 260]
                  }
                },
                "status": {
                  "extracted_string_or_numeric_value": "Accepted",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [300, 360],
                    "vertical_y_vertices": [250, 260]
                  }
                }
              },
              {
                "name": {
                  "extracted_string_or_numeric_value": "Nikita M Maladkar",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [120, 240],
                    "vertical_y_vertices": [265, 275]
                  }
                },
                "status": {
                  "extracted_string_or_numeric_value": "Accepted",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [300, 360],
                    "vertical_y_vertices": [265, 275]
                  }
                }
              }
            ],
            "program_details": {
              "extracted_string_or_numeric_value": "Enterprise Data and Analytics Operating Model Program|01326035001|Business Transformation|HCSC|PVR",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [118, 850],
                "vertical_y_vertices": [370, 385]
              }
            }
          }
        }
      ],
      "associated_notes": [
        {
          "slide_title": {
            "extracted_string_or_numeric_value": "DDA Journey - Execution Technique",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [120, 280],
              "vertical_y_vertices": [280, 300]
            }
          },
          "content_elements": [
            {
              "extracted_string_or_numeric_value": "Meeting Objective: Review DDA Delivery Execution Model, 'The Technique' discuss how it's being used today...",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [340, 650],
                "vertical_y_vertices": [450, 500]
              }
            }
          ],
          "annotations": [
            {
              "extracted_string_or_numeric_value": "Watch it for any perception for re-use",
              "optical_extraction_confidence_score": 0.85,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [125, 250],
                "vertical_y_vertices": [320, 350]
              }
            }
          ]
        },
        {
          "title": {
            "extracted_string_or_numeric_value": "Techmy Rollout",
            "optical_extraction_confidence_score": 0.80,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [420, 600],
              "vertical_y_vertices": [500, 550]
            }
          },
          "transcribed_text": {
            "extracted_string_or_numeric_value": "Enhancement of Tech Education for Tech Arsist. Is a plan. Add legend.",
            "optical_extraction_confidence_score": 0.75,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [450, 850],
              "vertical_y_vertices": [550, 700]
            }
          }
        }
      ],
      "inspirational_content": [
        {
          "extracted_string_or_numeric_value": "Justice - Archangel Raguel. This card comes to you because you're trying to make a decision...",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [695, 850],
            "vertical_y_vertices": [190, 440]
          }
        },
        {
          "extracted_string_or_numeric_value": "If you are really thankful, what do you do? You share. W. Clement Stone",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [695, 850],
            "vertical_y_vertices": [660, 750]
          }
        }
      ]
    }
  }
]
```