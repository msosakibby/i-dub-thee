An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided document and designed a resilient Pydantic V2 schema to accommodate its structural realities.

### BLOCK 1: Pydantic V2 Schema

```python
from typing import List, Optional, Union
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

# MANDATORY BASE CLASSES (DO NOT MODIFY)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# SCHEMA FOR DOCUMENT '02-19-19 ERP Transformation SteerCo-vFINAL v1'

class AgendaItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    item_description: ForensicDataEntity
    sub_items: Optional[List[ForensicDataEntity]] = None

class AgendaSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    section_number: ForensicDataEntity
    section_title: ForensicDataEntity
    items: List[AgendaItem]

class ExecutiveSummaryDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    timeline_summary: ForensicDataEntity
    guidance_summary: ForensicDataEntity
    key_accomplishments: List[ForensicDataEntity]
    program_risks: List[ForensicDataEntity]
    resources: List[ForensicDataEntity]
    program_timeline_notes: List[ForensicDataEntity]

class WorkstreamDetail(BaseModel):
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    description: ForensicDataEntity

class WorkstreamStatusOverview(BaseModel):
    model_config = ConfigDict(extra='forbid')
    red_status_workstreams: List[WorkstreamDetail]
    yellow_status_workstreams: List[WorkstreamDetail]
    green_status_summary: ForensicDataEntity

class GoLiveRecommendation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    guidance: ForensicDataEntity
    considerations: List[ForensicDataEntity]
    collaboration_notes: List[ForensicDataEntity]
    next_steps: List[ForensicDataEntity]

class Obstacle(BaseModel):
    model_config = ConfigDict(extra='forbid')
    concern_area: ForensicDataEntity
    description: ForensicDataEntity
    plan_to_address: ForensicDataEntity
    date: ForensicDataEntity
    priority: ForensicDataEntity
    owner: ForensicDataEntity

class MilestoneActivity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    stage: ForensicDataEntity
    activity: ForensicDataEntity
    start_date: ForensicDataEntity
    end_date: ForensicDataEntity

class MilestoneStageNote(BaseModel):
    model_config = ConfigDict(extra='forbid')
    stage: ForensicDataEntity
    note: ForensicDataEntity

class ActionItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    item_number: ForensicDataEntity
    item_description: ForensicDataEntity
    status: ForensicDataEntity
    owner_and_date: ForensicDataEntity
    comments_and_updates: ForensicDataEntity

class UnitTestMetric(BaseModel):
    model_config = ConfigDict(extra='forbid')
    functionality: ForensicDataEntity
    total_scenarios_for_functionality: Optional[ForensicDataEntity] = None
    scenario_assignment: ForensicDataEntity
    open_scenarios: ForensicDataEntity
    to_be_tested: ForensicDataEntity
    executed: ForensicDataEntity
    passed: ForensicDataEntity
    failed: ForensicDataEntity
    pending_retest: ForensicDataEntity
    total_scenarios_check: ForensicDataEntity
    pass_percentage: ForensicDataEntity
    avg_est_time: ForensicDataEntity
    est_to_complete_minutes: ForensicDataEntity
    est_to_complete_hours: ForensicDataEntity

    @model_validator(mode='after')
    def validate_gaap_checksum(self) -> 'UnitTestMetric':
        """Double-entry validation: EXECUTED = PASSED + FAILED + PENDING/RETEST"""
        executed_val = self.executed.extracted_string_or_numeric_value
        passed_val = self.passed.extracted_string_or_numeric_value
        failed_val = self.failed.extracted_string_or_numeric_value
        pending_val = self.pending_retest.extracted_string_or_numeric_value

        if isinstance(executed_val, float) and isinstance(passed_val, float) and \
           isinstance(failed_val, float) and isinstance(pending_val, float):
            if round(passed_val + failed_val + pending_val, 2) != round(executed_val, 2):
                raise ValueError(
                    f"Checksum failed for {self.functionality.extracted_string_or_numeric_value} ({self.scenario_assignment.extracted_string_or_numeric_value}): "
                    f"Executed ({executed_val}) != Passed ({passed_val}) + Failed ({failed_val}) + Pending/Retest ({pending_val})"
                )
        return self

class IntegrationDesignGroupStatus(BaseModel):
    model_config = ConfigDict(extra='forbid')
    group: ForensicDataEntity
    not_started: ForensicDataEntity
    in_progress: ForensicDataEntity
    ready_for_review: ForensicDataEntity
    approved: ForensicDataEntity
    total: ForensicDataEntity

    @model_validator(mode='after')
    def validate_gaap_checksum(self) -> 'IntegrationDesignGroupStatus':
        """Double-entry validation: TOTAL = Not Started + In Progress + Ready for Review + Approved"""
        total_val = self.total.extracted_string_or_numeric_value
        not_started_val = self.not_started.extracted_string_or_numeric_value
        in_progress_val = self.in_progress.extracted_string_or_numeric_value
        ready_val = self.ready_for_review.extracted_string_or_numeric_value
        approved_val = self.approved.extracted_string_or_numeric_value

        if isinstance(total_val, float) and isinstance(not_started_val, float) and \
           isinstance(in_progress_val, float) and isinstance(ready_val, float) and \
           isinstance(approved_val, float):
            if round(not_started_val + in_progress_val + ready_val + approved_val, 2) != round(total_val, 2):
                raise ValueError(
                    f"Checksum failed for {self.group.extracted_string_or_numeric_value}: "
                    f"Total ({total_val}) != Sum of statuses ({not_started_val + in_progress_val + ready_val + approved_val})"
                )
        return self

class IntegrationDesignStatus(BaseModel):
    model_config = ConfigDict(extra='forbid')
    statuses: List[IntegrationDesignGroupStatus]
    footnotes: List[ForensicDataEntity]

class DeploymentPhase(BaseModel):
    model_config = ConfigDict(extra='forbid')
    phase_name: ForensicDataEntity
    deliverables: List[ForensicDataEntity]

class DeploymentMethodology(BaseModel):
    model_config = ConfigDict(extra='forbid')
    phases: List[DeploymentPhase]
    progress_tracking_items: List[ForensicDataEntity]

class Appendix(BaseModel):
    model_config = ConfigDict(extra='forbid')
    unit_test_metrics: Optional[List[UnitTestMetric]] = None
    integration_design_status: Optional[IntegrationDesignStatus] = None
    gantt_chart_titles: Optional[List[ForensicDataEntity]] = None
    deployment_methodology: Optional[DeploymentMethodology] = None

class ErpProgramHealthReport(BaseModel):
    model_config = ConfigDict(extra='forbid')
    report_title: ForensicDataEntity
    deck_type: ForensicDataEntity
    report_date: ForensicDataEntity
    client_name: ForensicDataEntity
    client_slogan: ForensicDataEntity
    meeting_agenda: List[AgendaSection]
    executive_summary: ExecutiveSummaryDetails
    workstream_status_overview: WorkstreamStatusOverview
    go_live_recommendation: GoLiveRecommendation
    remaining_obstacles: List[Obstacle]
    revised_milestone_dates: List[MilestoneActivity]
    milestone_stage_notes: List[MilestoneStageNote]
    action_items: List[ActionItem]
    appendix: Appendix
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "02-19-19_ERP_SteerCo_vFINAL_v1_full_extraction",
    "should_pass": true,
    "taxonomy_lane": "ErpProgramHealthReport",
    "binary_header_simulation": "25504446",
    "payload": {
      "report_title": {
        "extracted_string_or_numeric_value": "Horizon ERP Program Health Report",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 600],
          "vertical_y_vertices": [680, 720]
        }
      },
      "deck_type": {
        "extracted_string_or_numeric_value": "Steering Committee Deck",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 400],
          "vertical_y_vertices": [730, 760]
        }
      },
      "report_date": {
        "extracted_string_or_numeric_value": "Wednesday, Feb. 19, 2019",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 350],
          "vertical_y_vertices": [780, 810]
        }
      },
      "client_name": {
        "extracted_string_or_numeric_value": "Horizon Blue Cross Blue Shield of New Jersey",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [655, 880],
          "vertical_y_vertices": [755, 770]
        }
      },
      "client_slogan": {
        "extracted_string_or_numeric_value": "Making Healthcare Work.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [655, 850],
          "vertical_y_vertices": [780, 795]
        }
      },
      "meeting_agenda": [
        {
          "section_number": {
            "extracted_string_or_numeric_value": "1.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 85],
              "vertical_y_vertices": [330, 345]
            }
          },
          "section_title": {
            "extracted_string_or_numeric_value": "Executive Summary",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [90, 270],
              "vertical_y_vertices": [330, 345]
            }
          },
          "items": [
            {
              "item_description": {
                "extracted_string_or_numeric_value": "Status Update",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [515, 650],
                  "vertical_y_vertices": [310, 325]
                }
              },
              "sub_items": [
                {
                  "extracted_string_or_numeric_value": "Executive Summary",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [540, 700],
                    "vertical_y_vertices": [340, 355]
                  }
                },
                {
                  "extracted_string_or_numeric_value": "Workstream Status",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [540, 700],
                    "vertical_y_vertices": [370, 385]
                  }
                }
              ]
            }
          ]
        },
        {
          "section_number": {
            "extracted_string_or_numeric_value": "2.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 85],
              "vertical_y_vertices": [480, 495]
            }
          },
          "section_title": {
            "extracted_string_or_numeric_value": "Special Topics",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [90, 220],
              "vertical_y_vertices": [480, 495]
            }
          },
          "items": [
            {
              "item_description": {
                "extracted_string_or_numeric_value": "Review Revised Go-live Date",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [515, 750],
                  "vertical_y_vertices": [480, 495]
                }
              },
              "sub_items": [
                {
                  "extracted_string_or_numeric_value": "Approach",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [540, 620],
                    "vertical_y_vertices": [510, 525]
                  }
                },
                {
                  "extracted_string_or_numeric_value": "Remaining obstacles",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [540, 700],
                    "vertical_y_vertices": [540, 555]
                  }
                },
                {
                  "extracted_string_or_numeric_value": "High level milestones",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [540, 700],
                    "vertical_y_vertices": [570, 585]
                  }
                }
              ]
            }
          ]
        },
        {
          "section_number": {
            "extracted_string_or_numeric_value": "3.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 85],
              "vertical_y_vertices": [680, 695]
            }
          },
          "section_title": {
            "extracted_string_or_numeric_value": "Steer Co Review of Action Items",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [90, 370],
              "vertical_y_vertices": [680, 695]
            }
          },
          "items": [
            {
              "item_description": {
                "extracted_string_or_numeric_value": "Review action items",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [515, 680],
                  "vertical_y_vertices": [680, 695]
                }
              },
              "sub_items": null
            }
          ]
        }
      ],
      "executive_summary": {
        "timeline_summary": {
          "extracted_string_or_numeric_value": "Project schedule is red due to delays in the Architect Stage which led to delays in the Configure and Prototype Stage. The project team has been finalizing scope and creating a project plan to support a revised go-live date. The objective of the Steering Committee meeting today is to provide guidance on a revised go-live date.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [70, 940],
            "vertical_y_vertices": [250, 320]
          }
        },
        "guidance_summary": {
          "extracted_string_or_numeric_value": "Target go-live date is Oct. 2019. Detailed plan has been created and this needs to be vetted further before finalizing a decision.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [70, 940],
            "vertical_y_vertices": [325, 355]
          }
        },
        "key_accomplishments": [
          {
            "extracted_string_or_numeric_value": "Unit Testing - ~85% complete. Contingent Worker, Budgeting and Financial Reporting continue to show delays. Payroll unit testing is close to 84%.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 940],
              "vertical_y_vertices": [375, 415]
            }
          },
          {
            "extracted_string_or_numeric_value": "IBM Integration Design Progress – 21 out of 130 approved, 21 out of 130 ready for review (+ 11 from previous week).",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 940],
              "vertical_y_vertices": [420, 440]
            }
          },
          {
            "extracted_string_or_numeric_value": "OCM – Identified change network team, created draft training strategy document, and created draft speaking points for leadership. HCM impact assessment workshop scheduled for 2/25.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 940],
              "vertical_y_vertices": [445, 485]
            }
          }
        ],
        "program_risks": [
          {
            "extracted_string_or_numeric_value": "Compressed timeline due to delays in the architect stage. Re-plan is in process to mitigate risks.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [90, 340],
              "vertical_y_vertices": [530, 570]
            }
          },
          {
            "extracted_string_or_numeric_value": "Delays with integration designs, unit testing results, and delays in data extraction will delay End to End Testing. Re-plan is in process to mitigate risks.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [90, 340],
              "vertical_y_vertices": [580, 630]
            }
          }
        ],
        "resources": [
          {
            "extracted_string_or_numeric_value": "Additional team members have been added by IBM, Horizon, and PWC to strengthen the team and address deficiencies.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [380, 630],
              "vertical_y_vertices": [530, 580]
            }
          },
          {
            "extracted_string_or_numeric_value": "Looking to bring in IBM domain health care industry experts to assess HCM and Financial business processes.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [380, 630],
              "vertical_y_vertices": [590, 640]
            }
          }
        ],
        "program_timeline_notes": [
          {
            "extracted_string_or_numeric_value": "Evaluate and agree on revised Go-live date based on the following:",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [670, 920],
              "vertical_y_vertices": [530, 560]
            }
          },
          {
            "extracted_string_or_numeric_value": "Detailed project plan developed in collaboration with IBM/Horizon/PWC.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [680, 920],
              "vertical_y_vertices": [570, 610]
            }
          }
        ]
      },
      "workstream_status_overview": {
        "red_status_workstreams": [
          {
            "title": {
              "extracted_string_or_numeric_value": "Integrations",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [180, 280],
                "vertical_y_vertices": [280, 295]
              }
            },
            "description": {
              "extracted_string_or_numeric_value": "Integration designs are delayed and scope is still not finalized. This will compress the design review and development timeline further. Additional IBM developers added to supplement the team. Development has now begun and will continue for the integrations that have been signed off. The get to green plan is agree to new completion dates which are included in the re-plan.",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [180, 940],
                "vertical_y_vertices": [280, 370]
              }
            }
          },
          {
            "title": {
              "extracted_string_or_numeric_value": "Contingent Worker",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [180, 320],
                "vertical_y_vertices": [380, 395]
              }
            },
            "description": {
              "extracted_string_or_numeric_value": "IBM has designed the contingent worker business processes. The get to green plan is to review and finalize by 3/8. Schedule customer confirmation session. Any barriers will be escalated to the Steering Committee (Bud).",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [180, 940],
                "vertical_y_vertices": [380, 440]
              }
            }
          }
        ],
        "yellow_status_workstreams": [
          {
            "title": {
              "extracted_string_or_numeric_value": "HCM Core, HCM Data, Benefits, Budgets, Procurement, Financial Accounting, Financial Conversion, FDM",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [180, 940],
                "vertical_y_vertices": [520, 535]
              }
            },
            "description": {
              "extracted_string_or_numeric_value": "Business processes and configurations still being refined; Additional time needed to unit test and resolve issues. Additional time required for data extraction. The get to green plan is to resolve open design items and complete unit testing by 3/8 – based on re-plan.",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [180, 940],
                "vertical_y_vertices": [535, 610]
              }
            }
          }
        ],
        "green_status_summary": {
          "extracted_string_or_numeric_value": "The remaining 17 out of 27 workstreams are in Green status",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [180, 940],
            "vertical_y_vertices": [690, 705]
          }
        }
      },
      "go_live_recommendation": {
        "guidance": {
          "extracted_string_or_numeric_value": "Move production date from 6/10 to 9/16 (employee go live 9/21).",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [65, 940],
            "vertical_y_vertices": [280, 310]
          }
        },
        "considerations": [
          {
            "extracted_string_or_numeric_value": "Leveraged assumptions from the latest version of the scope document (pending final review).",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [65, 940],
              "vertical_y_vertices": [330, 350]
            }
          }
        ],
        "collaboration_notes": [
          {
            "extracted_string_or_numeric_value": "Collaboration with IBM, PWC, Horizon PMO Team, Horizon Core Team (Ongoing)",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [65, 940],
              "vertical_y_vertices": [580, 595]
            }
          }
        ],
        "next_steps": [
          {
            "extracted_string_or_numeric_value": "Steering Committee support guidance on Oct. 2019 go-live date.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [65, 940],
              "vertical_y_vertices": [680, 695]
            }
          }
        ]
      },
      "remaining_obstacles": [
        {
          "concern_area": {
            "extracted_string_or_numeric_value": "Security",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [45, 185],
              "vertical_y_vertices": [290, 400]
            }
          },
          "description": {
            "extracted_string_or_numeric_value": "Need to understand security requirements for the platform (Workday, Enterprise, Mobile, SSO, Splunk, Pen Testing, ETC.)",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [190, 410],
              "vertical_y_vertices": [290, 400]
            }
          },
          "plan_to_address": {
            "extracted_string_or_numeric_value": "Joe Marsigliano to set up meeting with Horizon Security team to understand the security requirements.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [415, 680],
              "vertical_y_vertices": [290, 400]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "TBD",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [685, 745],
              "vertical_y_vertices": [290, 400]
            }
          },
          "priority": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [750, 810],
              "vertical_y_vertices": [290, 400]
            }
          },
          "owner": {
            "extracted_string_or_numeric_value": "Herb Ronde",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [815, 950],
              "vertical_y_vertices": [290, 400]
            }
          }
        }
      ],
      "revised_milestone_dates": [
        {
          "stage": {
            "extracted_string_or_numeric_value": "ARCHITECT STAGE",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 480],
              "vertical_y_vertices": [340, 355]
            }
          },
          "activity": {
            "extracted_string_or_numeric_value": "Integration design and sign-off",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [100, 480],
              "vertical_y_vertices": [360, 375]
            }
          },
          "start_date": {
            "extracted_string_or_numeric_value": "10/1/2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [490, 590],
              "vertical_y_vertices": [360, 375]
            }
          },
          "end_date": {
            "extracted_string_or_numeric_value": "4/12/2019",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 680],
              "vertical_y_vertices": [360, 375]
            }
          }
        }
      ],
      "milestone_stage_notes": [
        {
          "stage": {
            "extracted_string_or_numeric_value": "Architect Stage",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [690, 940],
              "vertical_y_vertices": [340, 355]
            }
          },
          "note": {
            "extracted_string_or_numeric_value": "+ 6 weeks",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [690, 940],
              "vertical_y_vertices": [340, 355]
            }
          }
        }
      ],
      "action_items": [
        {
          "item_number": {
            "extracted_string_or_numeric_value": 1,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [45, 80],
              "vertical_y_vertices": [300, 380]
            }
          },
          "item_description": {
            "extracted_string_or_numeric_value": "Governance process and documentation be put in place for when any \"New Fields” are requested; capturing: Requestor, Field Name, purpose, approval, etc.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [85, 490],
              "vertical_y_vertices": [300, 380]
            }
          },
          "status": {
            "extracted_string_or_numeric_value": "In Progress",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [495, 580],
              "vertical_y_vertices": [300, 380]
            }
          },
          "owner_and_date": {
            "extracted_string_or_numeric_value": "Keith Campbell (2/22)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [585, 680],
              "vertical_y_vertices": [300, 380]
            }
          },
          "comments_and_updates": {
            "extracted_string_or_numeric_value": "IBM documenting the process and will share with team next week. We have a proposed process. Keith will review with Herb and communicate to the team.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [685, 950],
              "vertical_y_vertices": [300, 380]
            }
          }
        }
      ],
      "appendix": {
        "unit_test_metrics": [
          {
            "functionality": {
              "extracted_string_or_numeric_value": "Payroll",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [10, 100],
                "vertical_y_vertices": [500, 510]
              }
            },
            "total_scenarios_for_functionality": {
              "extracted_string_or_numeric_value": 208,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [105, 150],
                "vertical_y_vertices": [500, 510]
              }
            },
            "scenario_assignment": {
              "extracted_string_or_numeric_value": "IBM",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [155, 210],
                "vertical_y_vertices": [500, 510]
              }
            },
            "open_scenarios": {
              "extracted_string_or_numeric_value": 34,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [215, 250],
                "vertical_y_vertices": [500, 510]
              }
            },
            "to_be_tested": {
              "extracted_string_or_numeric_value": 7,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [255, 300],
                "vertical_y_vertices": [500, 510]
              }
            },
            "executed": {
              "extracted_string_or_numeric_value": 201,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [305, 350],
                "vertical_y_vertices": [500, 510]
              }
            },
            "passed": {
              "extracted_string_or_numeric_value": 174,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [355, 400],
                "vertical_y_vertices": [500, 510]
              }
            },
            "failed": {
              "extracted_string_or_numeric_value": 27,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [405, 450],
                "vertical_y_vertices": [500, 510]
              }
            },
            "pending_retest": {
              "extracted_string_or_numeric_value": 0,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [455, 500],
                "vertical_y_vertices": [500, 510]
              }
            },
            "total_scenarios_check": {
              "extracted_string_or_numeric_value": 208,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [505, 550],
                "vertical_y_vertices": [500, 510]
              }
            },
            "pass_percentage": {
              "extracted_string_or_numeric_value": "83.65%",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [555, 600],
                "vertical_y_vertices": [500, 510]
              }
            },
            "avg_est_time": {
              "extracted_string_or_numeric_value": 15,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [605, 650],
                "vertical_y_vertices": [500, 510]
              }
            },
            "est_to_complete_minutes": {
              "extracted_string_or_numeric_value": 510,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [655, 700],
                "vertical_y_vertices": [500, 510]
              }
            },
            "est_to_complete_hours": {
              "extracted_string_or_numeric_value": 8.50,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [705, 750],
                "vertical_y_vertices": [500, 510]
              }
            }
          }
        ],
        "integration_design_status": {
          "statuses": [
            {
              "group": {
                "extracted_string_or_numeric_value": "Group 1",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [125, 200],
                  "vertical_y_vertices": [410, 440]
                }
              },
              "not_started": {
                "extracted_string_or_numeric_value": 0,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [220, 320],
                  "vertical_y_vertices": [410, 440]
                }
              },
              "in_progress": {
                "extracted_string_or_numeric_value": 1,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [340, 440],
                  "vertical_y_vertices": [410, 440]
                }
              },
              "ready_for_review": {
                "extracted_string_or_numeric_value": 8,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [460, 560],
                  "vertical_y_vertices": [410, 440]
                }
              },
              "approved": {
                "extracted_string_or_numeric_value": 6,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [580, 680],
                  "vertical_y_vertices": [410, 440]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 15,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [690, 750],
                  "vertical_y_vertices": [410, 440]
                }
              }
            },
            {
              "group": {
                "extracted_string_or_numeric_value": "Total",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [125, 200],
                  "vertical_y_vertices": [560, 590]
                }
              },
              "not_started": {
                "extracted_string_or_numeric_value": 68,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [220, 320],
                  "vertical_y_vertices": [560, 590]
                }
              },
              "in_progress": {
                "extracted_string_or_numeric_value": 20,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [340, 440],
                  "vertical_y_vertices": [560, 590]
                }
              },
              "ready_for_review": {
                "extracted_string_or_numeric_value": 21,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [460, 560],
                  "vertical_y_vertices": [560, 590]
                }
              },
              "approved": {
                "extracted_string_or_numeric_value": 21,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [580, 680],
                  "vertical_y_vertices": [560, 590]
                }
              },
              "total": {
                "extracted_string_or_numeric_value": 130,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [690, 750],
                  "vertical_y_vertices": [560, 590]
                }
              }
            }
          ],
          "footnotes": [
            {
              "extracted_string_or_numeric_value": "*IBM-owned integrations only. Horizon-owned integrations to be added ** Include IICS (15) integrations which are pending Horizon decision on ownership. Decision due 2/22",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [125, 650],
                "vertical_y_vertices": [620, 680]
              }
            }
          ]
        },
        "gantt_chart_titles": [
          {
            "extracted_string_or_numeric_value": "Revised Milestone Dates (Architect and Configure & Prototype)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 500],
              "vertical_y_vertices": [170, 220]
            }
          },
          {
            "extracted_string_or_numeric_value": "Revised Milestone Dates (Testing)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 500],
              "vertical_y_vertices": [170, 220]
            }
          },
          {
            "extracted_string_or_numeric_value": "Revised Milestone Dates (Deploy)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 500],
              "vertical_y_vertices": [170, 220]
            }
          }
        ],
        "deployment_methodology": {
          "phases": [
            {
              "phase_name": {
                "extracted_string_or_numeric_value": "PLAN",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [45, 180],
                  "vertical_y_vertices": [320, 350]
                }
              },
              "deliverables": [
                {
                  "extracted_string_or_numeric_value": "Project Startup",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [50, 180],
                    "vertical_y_vertices": [380, 395]
                  }
                },
                {
                  "extracted_string_or_numeric_value": "Customer Training",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [50, 180],
                    "vertical_y_vertices": [400, 415]
                  }
                }
              ]
            }
          ],
          "progress_tracking_items": [
            {
              "extracted_string_or_numeric_value": "DELIVERY ASSURANCE",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [90, 350],
                "vertical_y_vertices": [650, 665]
              }
            },
            {
              "extracted_string_or_numeric_value": "PROJECT MANAGEMENT & ADMINISTRATION",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [90, 350],
                "vertical_y_vertices": [690, 705]
              }
            },
            {
              "extracted_string_or_numeric_value": "PRODUCTION PREPAREDNESS",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [90, 350],
                "vertical_y_vertices": [730, 745]
              }
            }
          ]
        }
      }
    }
  }
]
```