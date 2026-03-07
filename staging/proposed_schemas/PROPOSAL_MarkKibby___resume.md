An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided document to design a resilient Pydantic V2 schema. The schema accommodates the document's complex, nested structure, particularly within the professional experience section, and includes a GAAP-inspired mathematical checksum for financial data points as required.

### BLOCK 1 (Python Pydantic V2)
```python
import math
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of an extracted entity on the document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]


class ForensicDataEntity(BaseModel):
    """A wrapper for any extracted data point, containing its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon


class Achievement(BaseModel):
    """Represents a single bullet point or achievement within a role."""
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    associated_financial_value_usd_millions: Optional[ForensicDataEntity] = None


class Role(BaseModel):
    """Represents a specific role or position held at a company."""
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    dates: ForensicDataEntity
    achievements: List[Achievement]
    client: Optional[ForensicDataEntity] = None


class ExperienceItem(BaseModel):
    """Represents a block of experience at a single company."""
    model_config = ConfigDict(extra='forbid')
    company: ForensicDataEntity
    location: ForensicDataEntity
    roles: List[Role]


class EducationItem(BaseModel):
    """Represents a single educational qualification."""
    model_config = ConfigDict(extra='forbid')
    institution: ForensicDataEntity
    degree: ForensicDataEntity
    dates: ForensicDataEntity


class LanguageItem(BaseModel):
    """Represents a language and the individual's proficiency."""
    model_config = ConfigDict(extra='forbid')
    language: ForensicDataEntity
    proficiency: ForensicDataEntity


class MarkKibbyResumeV1(BaseModel):
    """
    A resilient Pydantic V2 schema for Mark Kibby's resume, accommodating its
    structural realities and enforcing financial data integrity.
    """
    model_config = ConfigDict(extra='forbid')

    name: ForensicDataEntity
    address: ForensicDataEntity
    phone: ForensicDataEntity
    email: ForensicDataEntity
    summary: ForensicDataEntity
    professional_experience: List[ExperienceItem]
    education: List[EducationItem]
    skills: List[ForensicDataEntity]
    languages: List[LanguageItem]
    total_financial_value_checksum_usd_millions: ForensicDataEntity

    @model_validator(mode='after')
    def validate_gaap_checksum(self) -> 'MarkKibbyResumeV1':
        """
        Executes a double-entry GAAP-style mathematical checksum.

        This validator simulates a balancing check by summing all discrete financial
        values mentioned in the professional experience and comparing the total
        against a pre-calculated checksum field.
        """
        calculated_sum = 0.0
        for experience in self.professional_experience:
            for role in experience.roles:
                for achievement in role.achievements:
                    if achievement.associated_financial_value_usd_millions:
                        value = achievement.associated_financial_value_usd_millions.extracted_string_or_numeric_value
                        if isinstance(value, (int, float)):
                            calculated_sum += value
                        else:
                            raise ValueError(f"Financial value must be a number, but found '{value}'")

        checksum_value = self.total_financial_value_checksum_usd_millions.extracted_string_or_numeric_value
        if not isinstance(checksum_value, (int, float)):
            raise ValueError(f"Checksum value must be a number, but found '{checksum_value}'")

        if not math.isclose(calculated_sum, checksum_value):
            raise ValueError(
                f"GAAP checksum failed. Calculated sum of financial values ({calculated_sum}) "
                f"does not match the expected checksum ({checksum_value})."
            )

        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "MarkKibby_Resume_Complex_Variant_01",
    "should_pass": true,
    "taxonomy_lane": "MarkKibbyResumeV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "name": {
        "extracted_string_or_numeric_value": "Mark Kibby",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 150],
          "vertical_y_vertices": [50, 65]
        }
      },
      "address": {
        "extracted_string_or_numeric_value": "3291 18 Mile Rd\nMarion, MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 150],
          "vertical_y_vertices": [70, 95]
        }
      },
      "phone": {
        "extracted_string_or_numeric_value": "(m): 773-251-0539",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 150],
          "vertical_y_vertices": [96, 106]
        }
      },
      "email": {
        "extracted_string_or_numeric_value": "kib@umich.edu",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 150],
          "vertical_y_vertices": [107, 117]
        }
      },
      "summary": {
        "extracted_string_or_numeric_value": "Dynamic and knowledgeable professional with extensive experience in enterprise software, change and portfolio manage-ment, organizational design, process improvement, and strategic stakeholder management across diverse sectors, particularly in financial services and healthcare. Proven ability to leverage technology to drive organizational efficiency, scalability, and innovation. Committed to fostering inclusive workplace cultures and advancing strategic transformation initiatives.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [50, 850],
          "vertical_y_vertices": [140, 200]
        }
      },
      "total_financial_value_checksum_usd_millions": {
        "extracted_string_or_numeric_value": 4890.0,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [0, 0],
          "vertical_y_vertices": [0, 0]
        }
      },
      "professional_experience": [
        {
          "company": {
            "extracted_string_or_numeric_value": "PricewaterhouseCoopers (PwC) Advisory, Strategy&",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 500],
              "vertical_y_vertices": [250, 260]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "New York, NY / Chicago, IL",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501, 700],
              "vertical_y_vertices": [250, 260]
            }
          },
          "roles": [
            {
              "title": {
                "extracted_string_or_numeric_value": "Partner, Technology Strategy Practice, Lead Partner NA Program Value Realization Competency",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [265, 275]
                }
              },
              "dates": {
                "extracted_string_or_numeric_value": "November 2010 - January 2020",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [276, 286]
                }
              },
              "achievements": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Led the North American Health Program Value Realization Team, focusing on strategic transformation to maximize business case value.",
                    "optical_extraction_confidence_score": 0.97,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [290, 310]
                    }
                  }
                },
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Consistently achieved annual accountable sales revenue goals of ($100M - $120M)",
                    "optical_extraction_confidence_score": 0.97,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [311, 321]
                    }
                  },
                  "associated_financial_value_usd_millions": {
                    "extracted_string_or_numeric_value": 110.0,
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [500, 600],
                      "vertical_y_vertices": [311, 321]
                    }
                  }
                }
              ]
            },
            {
              "title": {
                "extracted_string_or_numeric_value": "Strategy& LGBT Partner Sponsor, Member, PwC LGBT Partner Advisory Board",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [325, 335]
                }
              },
              "dates": {
                "extracted_string_or_numeric_value": "September 2014 - January 2020",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [336, 346]
                }
              },
              "achievements": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Provided leadership, oversight, and mentoring to LGBT staff and employee resource groups in North America",
                    "optical_extraction_confidence_score": 0.96,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [350, 360]
                    }
                  }
                }
              ]
            },
            {
              "title": {
                "extracted_string_or_numeric_value": "Technology Strategy PeoplePartner North America",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [420, 430]
                }
              },
              "dates": {
                "extracted_string_or_numeric_value": "September 2016 - September 2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [431, 441]
                }
              },
              "achievements": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Managed career calibration, governance of hiring plans, and ensured comprehensive onboarding and development for all North American Technology Strategy group personnel (~1500 ppl)",
                    "optical_extraction_confidence_score": 0.96,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [465, 485]
                    }
                  }
                }
              ]
            },
            {
              "title": {
                "extracted_string_or_numeric_value": "Strategic Delivery Advisor and Overall Program Manager, Claims Strategic Transformation Program",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [510, 530]
                }
              },
              "dates": {
                "extracted_string_or_numeric_value": "April 2012 - December 2014",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 800],
                  "vertical_y_vertices": [531, 541]
                }
              },
              "client": {
                "extracted_string_or_numeric_value": "Kaiser Permanente",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [75, 200],
                  "vertical_y_vertices": [545, 555]
                }
              },
              "achievements": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Delivered the largest ($2B USD) healthcare claim strategic transformation program in U.S. history ahead of schedule, preserving project value.",
                    "optical_extraction_confidence_score": 0.97,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [545, 565]
                    }
                  },
                  "associated_financial_value_usd_millions": {
                    "extracted_string_or_numeric_value": 2000.0,
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [250, 350],
                      "vertical_y_vertices": [545, 555]
                    }
                  }
                },
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Conducted risk assessments and strategic capability analyses to re-strategize a $2B initiative, leading to efficient consolidation and execution of platform transition.",
                    "optical_extraction_confidence_score": 0.97,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [570, 590]
                    }
                  },
                  "associated_financial_value_usd_millions": {
                    "extracted_string_or_numeric_value": 2000.0,
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [600, 700],
                      "vertical_y_vertices": [570, 580]
                    }
                  }
                }
              ]
            }
          ]
        },
        {
          "company": {
            "extracted_string_or_numeric_value": "Booz & Company",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 200],
              "vertical_y_vertices": [610, 620]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "Chicago, IL",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [201, 300],
              "vertical_y_vertices": [610, 620]
            }
          },
          "roles": [
            {
              "title": {
                "extracted_string_or_numeric_value": "Senior Principal, Healthcare and Insurance Vertical",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 500],
                  "vertical_y_vertices": [625, 635]
                }
              },
              "dates": {
                "extracted_string_or_numeric_value": "September 2007 - November 2010",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [501, 800],
                  "vertical_y_vertices": [625, 635]
                }
              },
              "achievements": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "At Cigna Healthcare led a $750M+ initiative, advising on claims platform solution strategy and managing vendor negotiations, significantly impacting IT infrastructure operations strategy and future now current business scalability capabilities",
                    "optical_extraction_confidence_score": 0.96,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [640, 670]
                    }
                  },
                  "associated_financial_value_usd_millions": {
                    "extracted_string_or_numeric_value": 750.0,
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [250, 350],
                      "vertical_y_vertices": [640, 650]
                    }
                  }
                }
              ]
            }
          ]
        },
        {
          "company": {
            "extracted_string_or_numeric_value": "Diamond Management and Technology Consultants",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 500],
              "vertical_y_vertices": [690, 700]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "Chicago, IL",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501, 600],
              "vertical_y_vertices": [690, 700]
            }
          },
          "roles": [
            {
              "title": {
                "extracted_string_or_numeric_value": "Principal, Healthcare and Insurance Vertical",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 500],
                  "vertical_y_vertices": [705, 715]
                }
              },
              "dates": {
                "extracted_string_or_numeric_value": "April 2007 - November 2010",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [50, 500],
                  "vertical_y_vertices": [716, 726]
                }
              },
              "achievements": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Developed and executed technology strategies for healthcare payers, enhancing business outcomes through technology advancements.",
                    "optical_extraction_confidence_score": 0.96,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [730, 750]
                    }
                  }
                },
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Participated in Diamond's account leadership for CIGNA, driving advisory services and contributing to substantial annual fee generation ($30M).",
                    "optical_extraction_confidence_score": 0.96,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [70, 800],
                      "vertical_y_vertices": [755, 775]
                    }
                  },
                  "associated_financial_value_usd_millions": {
                    "extracted_string_or_numeric_value": 30.0,
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [700, 750],
                      "vertical_y_vertices": [765, 775]
                    }
                  }
                }
              ]
            }
          ]
        }
      ],
      "education": [
        {
          "institution": {
            "extracted_string_or_numeric_value": "University of Michigan, College of Literature, Science, and Arts / Residential College - Ann Arbor, MI",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 800],
              "vertical_y_vertices": [1000, 1010]
            }
          },
          "degree": {
            "extracted_string_or_numeric_value": "Bachelor of Arts in Organizational Psychology",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 500],
              "vertical_y_vertices": [1015, 1025]
            }
          },
          "dates": {
            "extracted_string_or_numeric_value": "August 1992 - June 1996",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501, 700],
              "vertical_y_vertices": [1015, 1025]
            }
          }
        },
        {
          "institution": {
            "extracted_string_or_numeric_value": "University of Michigan, College of Literature, Science, and Arts / Residential College - Ann Arbor, MI",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [50, 800],
              "vertical_y_vertices": [1000, 1010]
            }
          },
          "degree": {
            "extracted_string_or_numeric_value": "Bachelor of Arts in Spanish Literature",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 500],
              "vertical_y_vertices": [1030, 1040]
            }
          },
          "dates": {
            "extracted_string_or_numeric_value": "August 1992 - June 1996",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [501, 700],
              "vertical_y_vertices": [1030, 1040]
            }
          }
        }
      ],
      "skills": [
        {
          "extracted_string_or_numeric_value": "Enterprise Software, Agile Methodologies, ITIL, SDLC",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [70, 800],
            "vertical_y_vertices": [1100, 1110]
          }
        },
        {
          "extracted_string_or_numeric_value": "Organizational Design, Change Management, Process Improvement",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [70, 800],
            "vertical_y_vertices": [1111, 1121]
          }
        },
        {
          "extracted_string_or_numeric_value": "ERP Systems (PeopleSoft), Business Intelligence, System Architecture",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [70, 800],
            "vertical_y_vertices": [1166, 1176]
          }
        }
      ],
      "languages": [
        {
          "language": {
            "extracted_string_or_numeric_value": "Spanish",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [70, 150],
              "vertical_y_vertices": [1200, 1210]
            }
          },
          "proficiency": {
            "extracted_string_or_numeric_value": "Expert",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [151, 200],
              "vertical_y_vertices": [1200, 1210]
            }
          }
        }
      ]
    }
  }
]
```