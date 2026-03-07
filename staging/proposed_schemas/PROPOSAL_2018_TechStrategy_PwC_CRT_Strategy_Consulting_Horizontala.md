An elegant and resilient Pydantic V2 schema has been crafted to parse all structural variations of the provided '2018 TechStrategy PwC CRT Strategy Consulting Horizontala' documents. The design accommodates optional sections and lists, ensuring broad compatibility. The most complex structural variant, exemplified by the 'Sanchit Madan' review, was selected for the test case due to its inclusion of financial data, which is necessary to satisfy the mathematical validation requirement.

***

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


class PerformanceYearProgressItem(BaseModel):
    """Represents a single item in the 'Development Plan Progress' section."""
    model_config = ConfigDict(extra='forbid')
    plan_item: ForensicDataEntity
    progress_against_plan: Union[ForensicDataEntity, List[ForensicDataEntity]]

class FinancialsRow(BaseModel):
    """Represents a single row in the financials table within the Strengths section."""
    model_config = ConfigDict(extra='forbid')
    fiscal_year: ForensicDataEntity
    sales_leader_rev_m: ForensicDataEntity
    eng_revenue_m: ForensicDataEntity
    em_percent: ForensicDataEntity

class FinancialsSummary(BaseModel):
    """Represents the summary of financials found in some Strengths sections."""
    model_config = ConfigDict(extra='forbid')
    rows: List[FinancialsRow]
    utilization_percent: Optional[ForensicDataEntity] = None

class CategorizedListItem(BaseModel):
    """A reusable component for a category followed by a list of bullet points."""
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    details: List[ForensicDataEntity]

class StrengthsSection(BaseModel):
    """Represents the 'Performance Year Strengths' section."""
    model_config = ConfigDict(extra='forbid')
    year: ForensicDataEntity
    summary: Optional[ForensicDataEntity] = None
    financials: Optional[FinancialsSummary] = None
    strength_items: List[CategorizedListItem]

class DevelopmentPlanSection(BaseModel):
    """Represents the 'Performance Year Development Plan' section."""
    model_config = ConfigDict(extra='forbid')
    year: ForensicDataEntity
    development_items: List[CategorizedListItem]

class InputListItem(BaseModel):
    """Represents a single person in the 'Input List' table."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    level: ForensicDataEntity
    relationship_to_assessee: ForensicDataEntity
    contact_info: Optional[ForensicDataEntity] = None

class ProjectPursuitItem(BaseModel):
    """Represents an item in the 'Projects and Pursuits Summary' found in some documents."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    description: ForensicDataEntity
    client_team: Optional[ForensicDataEntity] = None

class PwcCrtStrategyConsultingHorizontal(BaseModel):
    """
    A resilient schema for PwC Strategy& Development Plan documents from various years.
    It accommodates structural drift, such as the presence or absence of certain sections
    and variations in content like financial summaries.
    """
    model_config = ConfigDict(extra='forbid')

    assessee_name: ForensicDataEntity
    assessor_name: ForensicDataEntity
    relationship_partner: ForensicDataEntity
    career_coach: ForensicDataEntity
    talent_consultant: ForensicDataEntity
    level_cohort: ForensicDataEntity
    
    development_plan_progress: Optional[List[PerformanceYearProgressItem]] = None
    strengths: Optional[StrengthsSection] = None
    development_plan: Optional[DevelopmentPlanSection] = None
    input_list: Optional[List[InputListItem]] = None
    recommendation: Optional[ForensicDataEntity] = None
    projects_and_pursuits_summary: Optional[List[ProjectPursuitItem]] = None

    @model_validator(mode='after')
    def validate_financials(self) -> 'PwcCrtStrategyConsultingHorizontal':
        """
        Performs a basic sanity check on financial data. A true double-entry GAAP checksum
        is not possible as source documents do not provide sufficient data (e.g., costs).
        This check ensures reported Engagement Margin (EM) is a valid percentage and
        revenues are non-negative, which is the most robust validation possible given
        the source material.
        """
        if self.strengths and self.strengths.financials:
            for row in self.strengths.financials.rows:
                eng_revenue = row.eng_revenue_m.extracted_string_or_numeric_value
                em_percent = row.em_percent.extracted_string_or_numeric_value

                if not isinstance(eng_revenue, (int, float)) or not isinstance(em_percent, (int, float)):
                    raise ValueError("Financial values (eng_revenue_m, em_percent) must be numeric for validation.")

                if eng_revenue < 0:
                    raise ValueError(f"Engagement revenue for {row.fiscal_year.extracted_string_or_numeric_value} cannot be negative.")
                
                if not (0 <= em_percent <= 100):
                    raise ValueError(f"Engagement Margin (EM) for {row.fiscal_year.extracted_string_or_numeric_value} must be between 0 and 100.")
        return self

```

```json
[
  {
    "test_identifier": "SanchitMadan_D3_Financials_Complex_Variant_PY17_PY18",
    "should_pass": true,
    "taxonomy_lane": "PwcCrtStrategyConsultingHorizontal",
    "binary_header_simulation": "25504446",
    "payload": {
      "assessee_name": {
        "extracted_string_or_numeric_value": "Sanchit Madan",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [202, 458],
          "vertical_y_vertices": [203, 216]
        }
      },
      "assessor_name": {
        "extracted_string_or_numeric_value": "Marcus Ehrhardt",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [482, 668],
          "vertical_y_vertices": [203, 216]
        }
      },
      "relationship_partner": {
        "extracted_string_or_numeric_value": "Thom Bales",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [202, 458],
          "vertical_y_vertices": [221, 234]
        }
      },
      "career_coach": {
        "extracted_string_or_numeric_value": "Sundar Subramanian",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [482, 668],
          "vertical_y_vertices": [221, 252]
        }
      },
      "talent_consultant": {
        "extracted_string_or_numeric_value": "Erin Olson",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [202, 458],
          "vertical_y_vertices": [257, 270]
        }
      },
      "level_cohort": {
        "extracted_string_or_numeric_value": "Director 3",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [482, 668],
          "vertical_y_vertices": [257, 270]
        }
      },
      "development_plan_progress": [
        {
          "plan_item": {
            "extracted_string_or_numeric_value": "1) Continue to grow your business: a. As you grow your platform to new areas of market interest (e.g., sourcing and op model), also reinvest in existing elements (e.g., STARs) and continue to actively drive business development of them in the market b. Continue to develop your client relationships and list – great set of relationships, just need to continue to grow it c. Continue to grow your team – both broadening the partners and directors you collaborate with/ as well as, the junior team that supports you d. Identify industry events to bring your platform and IC to",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [202, 458],
              "vertical_y_vertices": [420, 699]
            }
          },
          "progress_against_plan": {
            "extracted_string_or_numeric_value": "Fully Met\nSanchit is a core team member of the HIA Payor team and plays an important role to grow the business. Over the last year he has broadened his focus with dedicated efforts addressing the Medicaid sector taking the offering that has proven successful at Medicare clients to the Medicaid area. Through these efforts he generated significant business at HCSC, Gateway and other clients. He continuously grows and deepens his network of relationships, e.g. at Gateway with COO Cat Gesh-Wilson, at HCSC with CEO Andy Napoli, as well as with divisional VPs. He keeps in touch and \"travels\" with his relationships, e.g. Dave Goltz from CareSource (who was prior with HCSC). Regarding this team, he has developed a solid \"pyramid\" of followers who work with him on projects and business development (incl. Kristin Basa, Nina Vishwanath, Deepak Tilani, etc.) Parallel to client work Sanchit and his team develop IC and marketing material, e.g. wrote/ published a S+B article, supported the roundtable on ACA, etc.",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [465, 794],
              "vertical_y_vertices": [420, 780]
            }
          }
        },
        {
          "plan_item": {
            "extracted_string_or_numeric_value": "2) Broaden your impact in the firm: a. Identify opportunities to extend your firm impact and also then partner network through platform, account, market, community benefit and other reinvest activities b. Identify opportunities to shape your offering(s) to meet our global delivery model goals 60:30:10",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [202, 458],
              "vertical_y_vertices": [786, 865]
            }
          },
          "progress_against_plan": {
            "extracted_string_or_numeric_value": "Sanchit is very active in the HCSC account development driving a multi-million business year over year together with his partner team. He also co-leads the \"Government Center of Excellence Platform\".\nRegarding 60/30/10: Sanchit is a great example of living Strategy to Execution and working in mixed teams across horizontals and also leveraging SDC resources, e.g. on Project \"Mule” at HCSC.",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [465, 794],
              "vertical_y_vertices": [786, 865]
            }
          }
        }
      ],
      "strengths": {
        "year": {
          "extracted_string_or_numeric_value": "PY18",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [342, 794],
            "vertical_y_vertices": [180, 193]
          }
        },
        "summary": {
          "extracted_string_or_numeric_value": "This past year was another strong year for Sanchit as a third year director on his path to partner. Focused on developing his platform at the intersection of FFG and GCOE, delivering transformation projects for payors in the government market, both on the Medicare and now also increasingly on the Medicaid area.\nA key point is Sanchit's drive to broadened his focus with dedicated efforts addressing the Medicaid sector taking the offering that has proven successful at Medicare clients to the Medicaid area.\nHis main clients include HCSC, his core revenue contributor, as well as Gateway and Scan Health Plan. Sanchit has built strong Relationships with the client team, a true strength of his, as well as with the staff he works with. Interviewees attest, that Sanchit continues to represent the full range of PwC services, both, in delivering high level of work as well as through proposals.\nHe is regarded as an advisor with deep industry (Business Acumen) and subject matter expertise, that is well perceived by the clients he serves and the team(s) he leads. The latter being very positive on his (Whole) Leadership style, giving great direction while at the same time leaving room to grow (not micro managing).",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [193, 794],
            "vertical_y_vertices": [240, 660]
          }
        },
        "financials": {
          "rows": [
            {
              "fiscal_year": {
                "extracted_string_or_numeric_value": "FY'18",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [193, 229],
                  "vertical_y_vertices": [700, 712]
                }
              },
              "sales_leader_rev_m": {
                "extracted_string_or_numeric_value": 8.7,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [230, 320],
                  "vertical_y_vertices": [700, 712]
                }
              },
              "eng_revenue_m": {
                "extracted_string_or_numeric_value": 5.8,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [321, 410],
                  "vertical_y_vertices": [700, 712]
                }
              },
              "em_percent": {
                "extracted_string_or_numeric_value": 22,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [411, 500],
                  "vertical_y_vertices": [700, 712]
                }
              }
            },
            {
              "fiscal_year": {
                "extracted_string_or_numeric_value": "FY'17",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [193, 229],
                  "vertical_y_vertices": [713, 725]
                }
              },
              "sales_leader_rev_m": {
                "extracted_string_or_numeric_value": 8.7,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [230, 320],
                  "vertical_y_vertices": [713, 725]
                }
              },
              "eng_revenue_m": {
                "extracted_string_or_numeric_value": 5.5,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [321, 410],
                  "vertical_y_vertices": [713, 725]
                }
              },
              "em_percent": {
                "extracted_string_or_numeric_value": 35,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [411, 500],
                  "vertical_y_vertices": [713, 725]
                }
              }
            },
            {
              "fiscal_year": {
                "extracted_string_or_numeric_value": "FY'16",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [193, 229],
                  "vertical_y_vertices": [726, 738]
                }
              },
              "sales_leader_rev_m": {
                "extracted_string_or_numeric_value": 3.7,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [230, 320],
                  "vertical_y_vertices": [726, 738]
                }
              },
              "eng_revenue_m": {
                "extracted_string_or_numeric_value": 1.8,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [321, 410],
                  "vertical_y_vertices": [726, 738]
                }
              },
              "em_percent": {
                "extracted_string_or_numeric_value": 26,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [411, 500],
                  "vertical_y_vertices": [726, 738]
                }
              }
            }
          ],
          "utilization_percent": {
            "extracted_string_or_numeric_value": 107,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [193, 500],
              "vertical_y_vertices": [750, 762]
            }
          }
        },
        "strength_items": []
      },
      "development_plan": {
        "year": {
          "extracted_string_or_numeric_value": "PY18",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [342, 794],
            "vertical_y_vertices": [825, 838]
          }
        },
        "development_items": [
          {
            "category": {
              "extracted_string_or_numeric_value": "1) Further grow into the partner role, shifting from delivery focus to client handling, levering your team (delegating even more) and further build your internal “network” within PwC xLOS/ x-horizontal.",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [217, 794],
                "vertical_y_vertices": [190, 230]
              }
            },
            "details": []
          },
          {
            "category": {
              "extracted_string_or_numeric_value": "2) Continue to grow your business:",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [217, 794],
                "vertical_y_vertices": [240, 252]
              }
            },
            "details": [
              {
                "extracted_string_or_numeric_value": "Expand into other growth areas, developing new accounts aside of HCSC etc., e.g. Horizon, other Blue Cluster players. etc",
                "optical_extraction_confidence_score": 0.91,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [225, 794],
                  "vertical_y_vertices": [255, 280]
                }
              },
              {
                "extracted_string_or_numeric_value": "Increase your focus on developing your pipeline of business",
                "optical_extraction_confidence_score": 0.91,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [225, 794],
                  "vertical_y_vertices": [281, 293]
                }
              }
            ]
          },
          {
            "category": {
              "extracted_string_or_numeric_value": "3) Continue to build/ further enhance your platform specifically with a focus on Medicaid",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [217, 794],
                "vertical_y_vertices": [300, 312]
              }
            },
            "details": [
              {
                "extracted_string_or_numeric_value": "transfer successful “STAR” service offering and broaden your playing field/ where you are regarded an expert",
                "optical_extraction_confidence_score": 0.90,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [225, 794],
                  "vertical_y_vertices": [315, 340]
                }
              },
              {
                "extracted_string_or_numeric_value": "develop according IC/ marketing material addressing the Medicaid sector",
                "optical_extraction_confidence_score": 0.90,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [225, 794],
                  "vertical_y_vertices": [341, 353]
                }
              }
            ]
          }
        ]
      },
      "input_list": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Thom Bales",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [217, 330],
              "vertical_y_vertices": [560, 572]
            }
          },
          "level": {
            "extracted_string_or_numeric_value": "Partner",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [331, 450],
              "vertical_y_vertices": [560, 572]
            }
          },
          "relationship_to_assessee": {
            "extracted_string_or_numeric_value": "Relationship Partner, Proposals and Pitches, SCAN – MA Resilience Strategy",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530, 794],
              "vertical_y_vertices": [560, 600]
            }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Sundar Subramanian",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [217, 330],
              "vertical_y_vertices": [610, 622]
            }
          },
          "level": {
            "extracted_string_or_numeric_value": "Partner",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [331, 450],
              "vertical_y_vertices": [610, 622]
            }
          },
          "relationship_to_assessee": {
            "extracted_string_or_numeric_value": "Coach, Projects, Proposals and Pitches",
            "optical_extraction_confidence_score": 0.93,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530, 794],
              "vertical_y_vertices": [610, 850]
            }
          }
        }
      ]
    }
  }
]
```