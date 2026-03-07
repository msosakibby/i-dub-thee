An analysis of the provided documents reveals significant structural drift. The 2018-02-06 document is a simple list of meetings. The 2018-05-02 document introduces structured planning sections, reflections with embedded images, and a detailed CRT agenda table. The 2018-07-23 document is the most complex, containing a full embedded PwC presentation with multiple slide types, including a crucial financial summary table with totals that require a GAAP-style checksum validation.

The following Pydantic V2 schema is designed to be highly resilient, accommodating all observed structures. It uses `Optional` for fields not present in all variants and a union of types for heterogeneous content like embedded images. The most complex structure, the presentation's financial slide, is modeled with a `model_validator` to perform the required double-entry checksums, ensuring data integrity under a Zero-Trust mandate.

### BLOCK 1: Python Pydantic V2 Schema

```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

# MANDATORY BASE CLASSES (Do not modify)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# --- Schema for Daily Record of Events ---

class AttendeeStats(BaseModel):
    model_config = ConfigDict(extra='forbid')
    invited: ForensicDataEntity
    accepted: ForensicDataEntity
    declined: ForensicDataEntity
    unknown: ForensicDataEntity

class Attendee(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    status: Optional[ForensicDataEntity] = None
    mobile: Optional[ForensicDataEntity] = None
    response_timestamp: Optional[ForensicDataEntity] = None

class Meeting(BaseModel):
    model_config = ConfigDict(extra='forbid')
    meeting_title: ForensicDataEntity
    meeting_datetime: Optional[ForensicDataEntity] = None
    meeting_date: Optional[ForensicDataEntity] = None
    meeting_time: Optional[ForensicDataEntity] = None
    meeting_id: Optional[ForensicDataEntity] = None
    wbs: Optional[ForensicDataEntity] = None
    project: Optional[ForensicDataEntity] = None
    location_or_dial_in: Optional[ForensicDataEntity] = None
    webex: Optional[ForensicDataEntity] = None
    attendee_stats: Optional[AttendeeStats] = None
    attendees: List[Attendee]
    agenda: Optional[ForensicDataEntity] = None
    key_points_follow_ups_action_items: Optional[ForensicDataEntity] = None
    meeting_invite_content: Optional[ForensicDataEntity] = None

class RevenueSummaryRow(BaseModel):
    model_config = ConfigDict(extra='forbid')
    los: ForensicDataEntity
    fy18_revenue: ForensicDataEntity
    fy18_revenue_goals: ForensicDataEntity
    fy19_ytd_revenue: ForensicDataEntity
    fy19_goals: ForensicDataEntity

class ActiveProjectRow(BaseModel):
    model_config = ConfigDict(extra='forbid')
    los_work_effort: ForensicDataEntity
    sold_revenue_amount: ForensicDataEntity
    opportunity_lead: ForensicDataEntity
    assumptions_observations: Optional[ForensicDataEntity] = None

class PresentationCurrentProjectsSlide(BaseModel):
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    dashboard_link: ForensicDataEntity
    revenue_summary: List[RevenueSummaryRow]
    active_projects: List[ActiveProjectRow]
    handwritten_annotations: Optional[List[ForensicDataEntity]] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'PresentationCurrentProjectsSlide':
        """Performs double-entry GAAP checksums on financial tables."""
        # --- 1. Validate Revenue Summary Table ---
        total_row = None
        data_rows = []
        for row in self.revenue_summary:
            if str(row.los.extracted_string_or_numeric_value).strip() == 'Total':
                total_row = row
            else:
                data_rows.append(row)

        if total_row and data_rows:
            # Check FY18 Revenue
            calc_sum_fy18 = sum(r.fy18_revenue.extracted_string_or_numeric_value for r in data_rows)
            total_fy18 = total_row.fy18_revenue.extracted_string_or_numeric_value
            if not math.isclose(calc_sum_fy18, total_fy18, rel_tol=1e-5):
                raise ValueError(f"Revenue Summary 'fy18_revenue' checksum failed: Calculated {calc_sum_fy18}, Expected {total_fy18}")

            # Check FY18 Revenue Goals
            calc_sum_fy18_goals = sum(r.fy18_revenue_goals.extracted_string_or_numeric_value for r in data_rows)
            total_fy18_goals = total_row.fy18_revenue_goals.extracted_string_or_numeric_value
            if not math.isclose(calc_sum_fy18_goals, total_fy18_goals, rel_tol=1e-5):
                raise ValueError(f"Revenue Summary 'fy18_revenue_goals' checksum failed: Calculated {calc_sum_fy18_goals}, Expected {total_fy18_goals}")

            # Check FY19 YTD Revenue
            calc_sum_fy19_ytd = sum(r.fy19_ytd_revenue.extracted_string_or_numeric_value for r in data_rows)
            total_fy19_ytd = total_row.fy19_ytd_revenue.extracted_string_or_numeric_value
            if not math.isclose(calc_sum_fy19_ytd, total_fy19_ytd, rel_tol=1e-5):
                raise ValueError(f"Revenue Summary 'fy19_ytd_revenue' checksum failed: Calculated {calc_sum_fy19_ytd}, Expected {total_fy19_ytd}")

            # Check FY19 Goals
            calc_sum_fy19_goals = sum(r.fy19_goals.extracted_string_or_numeric_value for r in data_rows)
            total_fy19_goals = total_row.fy19_goals.extracted_string_or_numeric_value
            if not math.isclose(calc_sum_fy19_goals, total_fy19_goals, rel_tol=1e-5):
                raise ValueError(f"Revenue Summary 'fy19_goals' checksum failed: Calculated {calc_sum_fy19_goals}, Expected {total_fy19_goals}")

        return self

class Presentation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    current_projects_slide: PresentationCurrentProjectsSlide

class DailyRecordOfEventsV1(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_date: ForensicDataEntity
    document_title: ForensicDataEntity
    document_subtitle: Optional[ForensicDataEntity] = None
    evernote_link: Optional[ForensicDataEntity] = None
    omnifocus_task: Optional[ForensicDataEntity] = None
    meetings: Optional[List[Meeting]] = None
    presentation: Optional[Presentation] = None
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "test_case_003_complex_pwc_presentation",
    "should_pass": true,
    "taxonomy_lane": "DailyRecordOfEventsV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_date": {
        "extracted_string_or_numeric_value": "2018-07-23",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [148, 215, 215, 148],
          "vertical_y_vertices": [108, 108, 118, 118]
        }
      },
      "document_title": {
        "extracted_string_or_numeric_value": "Daily Record of Events",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [225, 380, 380, 225],
          "vertical_y_vertices": [108, 108, 118, 118]
        }
      },
      "document_subtitle": {
        "extracted_string_or_numeric_value": "Planning & Solitude MasterNote",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [390, 600, 600, 390],
          "vertical_y_vertices": [108, 108, 118, 118]
        }
      },
      "presentation": {
        "current_projects_slide": {
          "title": {
            "extracted_string_or_numeric_value": "Current projects and where we are to date",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [58, 789, 789, 58],
              "vertical_y_vertices": [208, 208, 234, 234]
            }
          },
          "dashboard_link": {
            "extracted_string_or_numeric_value": "Horizon Dashboard (link)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [58, 395, 395, 58],
              "vertical_y_vertices": [255, 255, 281, 281]
            }
          },
          "revenue_summary": [
            {
              "los": {
                "extracted_string_or_numeric_value": "Advisory",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 1831002.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 2000000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 115480.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 6000000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              }
            },
            {
              "los": {
                "extracted_string_or_numeric_value": "Assurance",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 0.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 150000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 0.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 100000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              }
            },
            {
              "los": {
                "extracted_string_or_numeric_value": "Tax",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 316241.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 130000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 7387.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 300000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              }
            },
            {
              "los": {
                "extracted_string_or_numeric_value": "Total",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue": {
                "extracted_string_or_numeric_value": 2147243.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy18_revenue_goals": {
                "extracted_string_or_numeric_value": 2280000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_ytd_revenue": {
                "extracted_string_or_numeric_value": 122867.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              },
              "fy19_goals": {
                "extracted_string_or_numeric_value": 6400000.0,
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [], "vertical_y_vertices": [] }
              }
            }
          ],
          "active_projects": []
        }
      }
    }
  }
]
```