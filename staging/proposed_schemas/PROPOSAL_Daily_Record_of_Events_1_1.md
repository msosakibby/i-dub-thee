An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided documents and designed the following resilient Pydantic V2 schema and corresponding test case. The schema accommodates the structural drift and varied content by leveraging optional fields and discriminated unions, while the validator performs a double-entry GAAP-style checksum on the financial data discovered within an embedded presentation.

### **BLOCK 1 (Python Pydantic V2)**
```python
import re
from typing import List, Optional, Union, Literal
from pydantic import BaseModel, Field, ConfigDict, model_validator

# Utility function for financial parsing
def parse_financial_string(value: Union[str, int, float]) -> float:
    """Converts financial strings like '$1.5M' or '500K' to a float."""
    if isinstance(value, (int, float)):
        return float(value)
    
    if not isinstance(value, str):
        raise TypeError("Input must be a string, integer, or float.")

    text = value.replace('$', '').replace(',', '').strip()
    
    multiplier = 1.0
    if text.upper().endswith('M'):
        multiplier = 1_000_000.0
        text = text[:-1]
    elif text.upper().endswith('K'):
        multiplier = 1_000.0
        text = text[:-1]
        
    try:
        return float(text) * multiplier
    except (ValueError, TypeError):
        return 0.0

# Provided Forensic Wrapper Classes
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema for Planning Section (Page 1)
class TaskItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    link: Optional[ForensicDataEntity] = None

class SubTask(BaseModel):
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    items: List[TaskItem]

class TaskDetailGroup(BaseModel):
    model_config = ConfigDict(extra='forbid')
    task_id: ForensicDataEntity
    title: ForensicDataEntity
    sub_tasks: List[SubTask]

class HighLevelTask(BaseModel):
    model_config = ConfigDict(extra='forbid')
    task_id: ForensicDataEntity
    description: ForensicDataEntity

class PlanningAndSolitude(BaseModel):
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    high_level_tasks: List[HighLevelTask]
    task_details: List[TaskDetailGroup]

# Schema for Attachments (Pages 14-16, 22)
class RevenueSource(BaseModel):
    model_config = ConfigDict(extra='forbid')
    source: ForensicDataEntity
    fy2018_projected: ForensicDataEntity
    fy2019_budget: ForensicDataEntity
    yoy_growth: Optional[ForensicDataEntity] = None

class DecomposingRevenueTable(BaseModel):
    model_config = ConfigDict(extra='forbid')
    revenue_sources: List[RevenueSource]
    total: RevenueSource

class PresentationAttachment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    attachment_type: ForensicDataEntity
    title: ForensicDataEntity
    date: ForensicDataEntity
    dial_in: ForensicDataEntity
    decomposing_revenue: Optional[DecomposingRevenueTable] = None

    @model_validator(mode='after')
    def validate_revenue_decomposition(self) -> 'PresentationAttachment':
        if not self.decomposing_revenue:
            return self
        
        table = self.decomposing_revenue
        total_row = table.total
        sources = table.revenue_sources
        
        try:
            # Check FY2018 Projected Sum
            fy2018_sum = sum(parse_financial_string(s.fy2018_projected.extracted_string_or_numeric_value) for s in sources)
            fy2018_total = parse_financial_string(total_row.fy2018_projected.extracted_string_or_numeric_value)
            
            if abs(fy2018_sum - fy2018_total) > 1_000_000: # Allow tolerance for rounding (e.g., $0.7M vs $700K)
                 raise ValueError(f"FY2018 revenue decomposition checksum failed. Sum of sources ({fy2018_sum}) does not match total ({fy2018_total}).")

            # Check FY2019 Budget Sum
            fy2019_sum = sum(parse_financial_string(s.fy2019_budget.extracted_string_or_numeric_value) for s in sources)
            fy2019_total = parse_financial_string(total_row.fy2019_budget.extracted_string_or_numeric_value)

            if abs(fy2019_sum - fy2019_total) > 1000: # Tighter tolerance for exact match
                 raise ValueError(f"FY2019 revenue decomposition checksum failed. Sum of sources ({fy2019_sum}) does not match total ({fy2019_total}).")
        
        except (TypeError, ValueError) as e:
            raise ValueError(f"Error during financial checksum: {e}") from e
        
        return self

# Schema for Core Event/Meeting Structure
class Attendee(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    status: ForensicDataEntity
    mobile: Optional[ForensicDataEntity] = None

class AttendeeSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    invited: ForensicDataEntity
    accepted: ForensicDataEntity
    declined: ForensicDataEntity
    unknown: ForensicDataEntity

class HandwrittenNotes(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transcribed_text: ForensicDataEntity

class EventDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    attendee_summary: AttendeeSummary
    attendees: List[Attendee]
    agenda: Optional[Union[List[ForensicDataEntity], HandwrittenNotes]] = None
    key_points_follow_ups: Optional[Union[List[ForensicDataEntity], HandwrittenNotes]] = None
    meeting_invite_content: Optional[ForensicDataEntity] = None
    attachments: Optional[List[PresentationAttachment]] = None # Simplified to one attachment type for clarity

class ScheduleEvent(BaseModel):
    model_config = ConfigDict(extra='forbid')
    start_time: ForensicDataEntity
    title: ForensicDataEntity
    duration: Optional[ForensicDataEntity] = None
    wbs_code: Optional[ForensicDataEntity] = None
    location_or_dial_in: Optional[ForensicDataEntity] = None
    webex_status: Optional[ForensicDataEntity] = None
    category: Optional[ForensicDataEntity] = None
    sub_category: Optional[ForensicDataEntity] = None
    event_details: Optional[EventDetail] = None

# Schema for Time Entry Table (Page 5)
class TimeEntry(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    wbs_time_code: ForensicDataEntity
    tax_area: ForensicDataEntity
    duration: ForensicDataEntity
    quick_text: ForensicDataEntity
    long_text: ForensicDataEntity
    expense_wbs: ForensicDataEntity

# Top-level Document Schema
class DailyRecordOfEvents_1_1(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    document_title: ForensicDataEntity
    planning_section: Optional[PlanningAndSolitude] = None
    schedule_events: List[ScheduleEvent]
    time_entries: Optional[List[TimeEntry]] = None

```

### **BLOCK 2 (JSON Test Registry)**
```json
[
  {
    "test_identifier": "test_daily_record_2018_06_22_complex",
    "should_pass": true,
    "taxonomy_lane": "DailyRecordOfEvents_1_1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_date": {
        "extracted_string_or_numeric_value": "2018-06-22",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 229], "vertical_y_vertices": [47, 58] }
      },
      "document_title": {
        "extracted_string_or_numeric_value": "Daily Record of Events | Planning & Solitude MasterNote",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [235, 612], "vertical_y_vertices": [47, 58] }
      },
      "planning_section": {
        "title": {
          "extracted_string_or_numeric_value": "Planning and Solitude",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 310], "vertical_y_vertices": [107, 118] }
        },
        "high_level_tasks": [
          {
            "task_id": { "extracted_string_or_numeric_value": "A|01.", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [184, 218], "vertical_y_vertices": [144, 154] } },
            "description": { "extracted_string_or_numeric_value": "Complete Wellness Activities", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 421], "vertical_y_vertices": [144, 154] } }
          }
        ],
        "task_details": []
      },
      "schedule_events": [
        {
          "start_time": { "extracted_string_or_numeric_value": "11:00", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 180], "vertical_y_vertices": [450, 460] } },
          "title": { "extracted_string_or_numeric_value": "Call: HS & NEI Advisory Partner+MD", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 450], "vertical_y_vertices": [450, 460] } },
          "duration": { "extracted_string_or_numeric_value": "50:00", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 650], "vertical_y_vertices": [450, 460] } },
          "wbs_code": { "extracted_string_or_numeric_value": "80094007001", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 850], "vertical_y_vertices": [450, 460] } },
          "event_details": {
            "attendee_summary": {
              "invited": { "extracted_string_or_numeric_value": 34, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 160], "vertical_y_vertices": [450, 460] } },
              "accepted": { "extracted_string_or_numeric_value": 12, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 350], "vertical_y_vertices": [450, 460] } },
              "declined": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 430], "vertical_y_vertices": [450, 460] } },
              "unknown": { "extracted_string_or_numeric_value": 0, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 490], "vertical_y_vertices": [450, 460] } }
            },
            "attendees": [
              {
                "name": { "extracted_string_or_numeric_value": "Mark Kibby", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 220], "vertical_y_vertices": [580, 590] } },
                "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 550], "vertical_y_vertices": [580, 590] } },
                "mobile": { "extracted_string_or_numeric_value": "Call (773) 251-0539", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 450], "vertical_y_vertices": [580, 590] } }
              }
            ],
            "attachments": [
              {
                "attachment_type": { "extracted_string_or_numeric_value": "Presentation", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0], "vertical_y_vertices": [0,0] } },
                "title": { "extracted_string_or_numeric_value": "Health Services and NEI Advisory Partner/ MD Call", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [80, 270], "vertical_y_vertices": [160, 200] } },
                "date": { "extracted_string_or_numeric_value": "June 22, 2018", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [80, 150], "vertical_y_vertices": [220, 230] } },
                "dial_in": { "extracted_string_or_numeric_value": "888-331-9770,,,1251882#", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [80, 250], "vertical_y_vertices": [250, 260] } },
                "decomposing_revenue": {
                  "revenue_sources": [
                    {
                      "source": { "extracted_string_or_numeric_value": "Core", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [370, 400], "vertical_y_vertices": [740, 750] } },
                      "fy2018_projected": { "extracted_string_or_numeric_value": "$636M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [740, 750] } },
                      "fy2019_budget": { "extracted_string_or_numeric_value": "$706M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 550], "vertical_y_vertices": [740, 750] } },
                      "yoy_growth": { "extracted_string_or_numeric_value": "11%", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 610], "vertical_y_vertices": [740, 750] } }
                    },
                    {
                      "source": { "extracted_string_or_numeric_value": "VBO", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [370, 400], "vertical_y_vertices": [755, 765] } },
                      "fy2018_projected": { "extracted_string_or_numeric_value": "$36M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [755, 765] } },
                      "fy2019_budget": { "extracted_string_or_numeric_value": "$40M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 550], "vertical_y_vertices": [755, 765] } },
                      "yoy_growth": { "extracted_string_or_numeric_value": "11%", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 610], "vertical_y_vertices": [755, 765] } }
                    },
                    {
                      "source": { "extracted_string_or_numeric_value": "DoubleJump", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [370, 420], "vertical_y_vertices": [770, 780] } },
                      "fy2018_projected": { "extracted_string_or_numeric_value": "$700K", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [770, 780] } },
                      "fy2019_budget": { "extracted_string_or_numeric_value": "$10M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 550], "vertical_y_vertices": [770, 780] } },
                      "yoy_growth": { "extracted_string_or_numeric_value": "NM", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 610], "vertical_y_vertices": [770, 780] } }
                    },
                    {
                      "source": { "extracted_string_or_numeric_value": "SMART", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [370, 400], "vertical_y_vertices": [785, 795] } },
                      "fy2018_projected": { "extracted_string_or_numeric_value": "$12M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [785, 795] } },
                      "fy2019_budget": { "extracted_string_or_numeric_value": "$14M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 550], "vertical_y_vertices": [785, 795] } },
                      "yoy_growth": { "extracted_string_or_numeric_value": "17%", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 610], "vertical_y_vertices": [785, 795] } }
                    }
                  ],
                  "total": {
                    "source": { "extracted_string_or_numeric_value": "Total", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [370, 400], "vertical_y_vertices": [800, 810] } },
                    "fy2018_projected": { "extracted_string_or_numeric_value": "$685M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 480], "vertical_y_vertices": [800, 810] } },
                    "fy2019_budget": { "extracted_string_or_numeric_value": "$770M", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 550], "vertical_y_vertices": [800, 810] } },
                    "yoy_growth": { "extracted_string_or_numeric_value": "12%", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 610], "vertical_y_vertices": [800, 810] } }
                  }
                }
              }
            ]
          }
        }
      ],
      "time_entries": [
        {
          "date": { "extracted_string_or_numeric_value": "2018-06-22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 280], "vertical_y_vertices": [700, 710] } },
          "wbs_time_code": { "extracted_string_or_numeric_value": "80094007001", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 380], "vertical_y_vertices": [700, 710] } },
          "tax_area": { "extracted_string_or_numeric_value": "IL", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 420], "vertical_y_vertices": [700, 710] } },
          "duration": { "extracted_string_or_numeric_value": "50:00", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 480], "vertical_y_vertices": [700, 710] } },
          "quick_text": { "extracted_string_or_numeric_value": "Call: HS & NEI Advisory Partner+MD", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 650], "vertical_y_vertices": [700, 710] } },
          "long_text": { "extracted_string_or_numeric_value": "Health Industries Advisory", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 800], "vertical_y_vertices": [700, 710] } },
          "expense_wbs": { "extracted_string_or_numeric_value": "HIA G&A", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [820, 880], "vertical_y_vertices": [700, 710] } }
        }
      ]
    }
  }
]
```