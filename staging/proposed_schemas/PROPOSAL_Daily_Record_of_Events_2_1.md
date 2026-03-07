```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

# MANDATORY: Provided base classes for all data fields.
class SpatialCoordinatesPolygon(BaseModel):
    """Defines the physical coordinates of an extracted entity on a document page."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for any extracted data point, containing the value and its forensic metadata."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema for the 'Daily Record of Events-2-1' document class.

class TaskDetail(BaseModel):
    """Represents a category and its items within a planning task."""
    model_config = ConfigDict(extra='forbid')
    category: Optional[ForensicDataEntity] = None
    items: List[ForensicDataEntity]

class PlanningTask(BaseModel):
    """Represents a major task in the planning section (e.g., A01, A02)."""
    model_config = ConfigDict(extra='forbid')
    task_id: ForensicDataEntity
    task_title: ForensicDataEntity
    details: List[TaskDetail]

class PlanningSection(BaseModel):
    """Captures the 'Planning and Solitude' section of the document."""
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    tasks: List[PlanningTask]

class AttendeeSummary(BaseModel):
    """Statistical summary of meeting attendance."""
    model_config = ConfigDict(extra='forbid')
    invited: ForensicDataEntity
    accepted: ForensicDataEntity
    declined: ForensicDataEntity
    unknown: ForensicDataEntity

class MeetingAttendee(BaseModel):
    """Represents a single attendee of a meeting."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    status: ForensicDataEntity
    contact_info: Optional[ForensicDataEntity] = None

class Meeting(BaseModel):
    """Represents a single meeting entry in the daily record."""
    model_config = ConfigDict(extra='forbid')
    timestamp: ForensicDataEntity
    title: ForensicDataEntity
    wbs: Optional[ForensicDataEntity] = None
    location_or_dial_in: ForensicDataEntity
    webex_info: ForensicDataEntity
    attendee_summary: Optional[AttendeeSummary] = None
    attendees: List[MeetingAttendee]
    invite_content_raw: Optional[ForensicDataEntity] = None

class RevenueSummaryLine(BaseModel):
    """A single line item in the revenue summary table (e.g., by Line of Service)."""
    model_config = ConfigDict(extra='forbid')
    los: ForensicDataEntity
    fy18_revenue: ForensicDataEntity
    fy18_revenue_goals: ForensicDataEntity
    fy19_ytd_revenue: ForensicDataEntity
    fy19_goals: ForensicDataEntity

class ActiveProject(BaseModel):
    """Represents a single active project listed in the presentation."""
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    work_effort: ForensicDataEntity
    sold_revenue_amount: ForensicDataEntity
    opportunity_lead: ForensicDataEntity

class ProjectsAndRevenue(BaseModel):
    """Models the 'Current projects and where we are to date' slide, including the financial table."""
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    report_date: ForensicDataEntity
    revenue_summary_lines: List[RevenueSummaryLine]
    revenue_summary_total: RevenueSummaryLine
    active_projects: List[ActiveProject]

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'ProjectsAndRevenue':
        """Performs double-entry GAAP mathematical checksums on the revenue summary table."""
        
        def get_numeric_value(entity: ForensicDataEntity) -> float:
            val = entity.extracted_string_or_numeric_value
            return float(val) if isinstance(val, (int, float)) else 0.0

        # Checksum for FY18 Revenue
        calculated_fy18_revenue = sum(get_numeric_value(line.fy18_revenue) for line in self.revenue_summary_lines)
        total_fy18_revenue = get_numeric_value(self.revenue_summary_total.fy18_revenue)
        if not math.isclose(calculated_fy18_revenue, total_fy18_revenue, rel_tol=1e-5):
            raise ValueError(f"FY18 Revenue checksum failed: Calculated sum {calculated_fy18_revenue} != Stated total {total_fy18_revenue}")

        # Checksum for FY18 Revenue Goals
        calculated_fy18_goals = sum(get_numeric_value(line.fy18_revenue_goals) for line in self.revenue_summary_lines)
        total_fy18_goals = get_numeric_value(self.revenue_summary_total.fy18_revenue_goals)
        if not math.isclose(calculated_fy18_goals, total_fy18_goals, rel_tol=1e-5):
            raise ValueError(f"FY18 Revenue Goals checksum failed: Calculated sum {calculated_fy18_goals} != Stated total {total_fy18_goals}")

        # Checksum for FY19 YTD Revenue
        calculated_fy19_ytd = sum(get_numeric_value(line.fy19_ytd_revenue) for line in self.revenue_summary_lines)
        total_fy19_ytd = get_numeric_value(self.revenue_summary_total.fy19_ytd_revenue)
        if not math.isclose(calculated_fy19_ytd, total_fy19_ytd, rel_tol=1e-5):
            raise ValueError(f"FY19 YTD Revenue checksum failed: Calculated sum {calculated_fy19_ytd} != Stated total {total_fy19_ytd}")

        # Checksum for FY19 Goals
        calculated_fy19_goals = sum(get_numeric_value(line.fy19_goals) for line in self.revenue_summary_lines)
        total_fy19_goals = get_numeric_value(self.revenue_summary_total.fy19_goals)
        if not math.isclose(calculated_fy19_goals, total_fy19_goals, rel_tol=1e-5):
            raise ValueError(f"FY19 Goals checksum failed: Calculated sum {calculated_fy19_goals} != Stated total {total_fy19_goals}")

        return self

class PresentationAgendaItem(BaseModel):
    """A single item from the timed agenda in the presentation."""
    model_config = ConfigDict(extra='forbid')
    time: ForensicDataEntity
    topic: ForensicDataEntity
    sub_topics: List[ForensicDataEntity]
    speaker: ForensicDataEntity

class PresentationAttendee(BaseModel):
    """An attendee listed in the presentation, categorized by attendance type."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    los: ForensicDataEntity
    attendance_type: ForensicDataEntity

class APWGoals(BaseModel):
    """Models the 'APW Goals' slide with revenue targets."""
    model_config = ConfigDict(extra='forbid')
    fy18_revenue: ForensicDataEntity
    fy19_goal: ForensicDataEntity

class HorizonAPWPresentation(BaseModel):
    """The full presentation deck for the Horizon APW meeting."""
    model_config = ConfigDict(extra='forbid')
    client: ForensicDataEntity
    event_type: ForensicDataEntity
    date: ForensicDataEntity
    agenda: List[PresentationAgendaItem]
    attendees: List[PresentationAttendee]
    goals: APWGoals
    projects_and_revenue: ProjectsAndRevenue

class DailyRecordOfEvents_2_1(BaseModel):
    """
    The root schema for the 'Daily Record of Events-2-1' document class,
    designed to be resilient to structural drift over time.
    """
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    document_title: ForensicDataEntity
    master_note_type: ForensicDataEntity
    planning_section: Optional[PlanningSection] = None
    meetings: List[Meeting]
    presentation: Optional[HorizonAPWPresentation] = None
```
```json
[
  {
    "test_identifier": "DRE_2_1_COMPLEX_VARIANT_20180723",
    "should_pass": true,
    "taxonomy_lane": "DailyRecordOfEvents_2_1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_date": {
        "extracted_string_or_numeric_value": "2018-07-23",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 150],
          "vertical_y_vertices": [50, 60]
        }
      },
      "document_title": {
        "extracted_string_or_numeric_value": "Daily Record of Events",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [160, 350],
          "vertical_y_vertices": [50, 60]
        }
      },
      "master_note_type": {
        "extracted_string_or_numeric_value": "Planning & Solitude MasterNote",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [360, 600],
          "vertical_y_vertices": [50, 60]
        }
      },
      "planning_section": null,
      "meetings": [],
      "presentation": {
        "client": {
          "extracted_string_or_numeric_value": "Horizon BCBS NJ",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [210, 613],
            "vertical_y_vertices": [209, 238]
          }
        },
        "event_type": {
          "extracted_string_or_numeric_value": "FY19 APW",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [210, 478],
            "vertical_y_vertices": [250, 280]
          }
        },
        "date": {
          "extracted_string_or_numeric_value": "July 23, 2018",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [209, 475],
            "vertical_y_vertices": [300, 329]
          }
        },
        "agenda": [],
        "attendees": [],
        "goals": {
          "fy18_revenue": {
            "extracted_string_or_numeric_value": 2150000.0,
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [93, 218],
              "vertical_y_vertices": [708, 755]
            }
          },
          "fy19_goal": {
            "extracted_string_or_numeric_value": 6400000.0,
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [794, 888],
              "vertical_y_vertices": [545, 592]
            }
          }
        },
        "projects_and_revenue": {
          "title": {
            "extracted_string_or_numeric_value": "Current projects and where we are to date",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [58, 788],
              "vertical_y_vertices": [208, 241]
            }
          },
          "report_date": {
            "extracted_string_or_numeric_value": "7/19/2018",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [58, 318],
              "vertical_y_vertices": [288, 299]
            }
          },
          "revenue_summary_lines": [
            {
              "los": {
                "extracted_string_or_numeric_value": "Advisory",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 110], "vertical_y_vertices": [343, 354] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 1831002.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [269, 331], "vertical_y_vertices": [343, 354] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 2000000.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [415, 477], "vertical_y_vertices": [343, 354] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 115480.0,
                "optical_extraction_confidence_score": 0.96,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [588, 643], "vertical_y_vertices": [343, 354] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 6000000.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [836, 898], "vertical_y_vertices": [343, 354] }
              }
            },
            {
              "los": {
                "extracted_string_or_numeric_value": "Assurance",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 118], "vertical_y_vertices": [365, 376] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 0.0,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [269, 331], "vertical_y_vertices": [365, 376] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 150000.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [415, 477], "vertical_y_vertices": [365, 376] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 0.0,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [588, 643], "vertical_y_vertices": [365, 376] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 100000.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [836, 898], "vertical_y_vertices": [365, 376] }
              }
            },
            {
              "los": {
                "extracted_string_or_numeric_value": "Tax",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 83], "vertical_y_vertices": [387, 398] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 316241.0,
                "optical_extraction_confidence_score": 0.96,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [269, 331], "vertical_y_vertices": [387, 398] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 130000.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [415, 477], "vertical_y_vertices": [387, 398] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 7387.0,
                "optical_extraction_confidence_score": 0.96,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [588, 643], "vertical_y_vertices": [387, 398] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 300000.0,
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [836, 898], "vertical_y_vertices": [387, 398] }
              }
            }
          ],
          "revenue_summary_total": {
            "los": {
              "extracted_string_or_numeric_value": "Total",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 92], "vertical_y_vertices": [418, 429] }
            },
            "fy18_revenue": {
              "extracted_string_or_numeric_value": 2147243.0,
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [269, 331], "vertical_y_vertices": [418, 429] }
            },
            "fy18_revenue_goals": {
              "extracted_string_or_numeric_value": 2280000.0,
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [415, 477], "vertical_y_vertices": [418, 429] }
            },
            "fy19_ytd_revenue": {
              "extracted_string_or_numeric_value": 122867.0,
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [588, 643], "vertical_y_vertices": [418, 429] }
            },
            "fy19_goals": {
              "extracted_string_or_numeric_value": 6400000.0,
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [836, 898], "vertical_y_vertices": [418, 429] }
            }
          },
          "active_projects": [
            {
              "category": {
                "extracted_string_or_numeric_value": "Advisory",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 108], "vertical_y_vertices": [515, 526] }
              },
              "work_effort": {
                "extracted_string_or_numeric_value": "ERP Prog Valu Realize-Select",
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 210], "vertical_y_vertices": [537, 548] }
              },
              "sold_revenue_amount": {
                "extracted_string_or_numeric_value": 225000.0,
                "optical_extraction_confidence_score": 0.94,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [269, 324], "vertical_y_vertices": [537, 548] }
              },
              "opportunity_lead": {
                "extracted_string_or_numeric_value": "Mark Kibby",
                "optical_extraction_confidence_score": 0.93,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [398, 465], "vertical_y_vertices": [537, 548] }
              }
            }
          ]
        }
      }
    }
  }
]
```