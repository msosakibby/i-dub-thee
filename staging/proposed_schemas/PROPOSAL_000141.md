An expert forensic data architect, I have analyzed the provided document '000141' and engineered a resilient Pydantic V2 schema. This schema accommodates the observed data structure and anticipates potential variations, ensuring robust data extraction and validation under a Zero-Trust framework. The included mathematical validator enforces logical consistency between summary and periodic data, mirroring double-entry accounting principles to guarantee data integrity.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

# DO NOT MODIFY THIS CLASS
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

# DO NOT MODIFY THIS CLASS
class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class QuizDetail(BaseModel):
    """Represents the details of a single quiz taken by the student."""
    model_config = ConfigDict(extra='forbid')
    book_title: ForensicDataEntity
    book_author: ForensicDataEntity
    score_correct: ForensicDataEntity
    score_total: ForensicDataEntity
    percent_correct: ForensicDataEntity
    teacher_remark: Optional[ForensicDataEntity] = None
    atos_bl: ForensicDataEntity
    quiz_number: ForensicDataEntity
    language: ForensicDataEntity
    format: ForensicDataEntity
    quiz_date: ForensicDataEntity
    word_count: ForensicDataEntity
    interest_level: ForensicDataEntity
    twi: Optional[ForensicDataEntity] = None
    points_earned: ForensicDataEntity
    points_possible: ForensicDataEntity

class QuarterlyProgress(BaseModel):
    """Represents the summary of progress for a specific marking period."""
    model_config = ConfigDict(extra='forbid')
    header: ForensicDataEntity
    date_range: ForensicDataEntity
    percent_complete: ForensicDataEntity
    average_percent_correct: ForensicDataEntity
    average_percent_correct_goal: ForensicDataEntity
    points_earned: ForensicDataEntity
    points_goal: ForensicDataEntity
    average_atos_bl: ForensicDataEntity
    atos_bl_goal: ForensicDataEntity
    quizzes_passed: ForensicDataEntity
    quizzes_taken: ForensicDataEntity
    words_read: ForensicDataEntity

class SchoolYearSummary(BaseModel):
    """Represents the cumulative summary for the entire school year."""
    model_config = ConfigDict(extra='forbid')
    header: ForensicDataEntity
    date_range: ForensicDataEntity
    percent_complete: ForensicDataEntity
    average_percent_correct: ForensicDataEntity
    points_earned: ForensicDataEntity
    average_atos_bl: ForensicDataEntity
    quizzes_passed: ForensicDataEntity
    quizzes_taken: ForensicDataEntity
    total_words_read: ForensicDataEntity
    last_certification: Optional[ForensicDataEntity] = None
    date_achieved: Optional[ForensicDataEntity] = None
    certification_goal: Optional[ForensicDataEntity] = None

class TeacherFeedback(BaseModel):
    """Represents handwritten feedback and signatures from staff."""
    model_config = ConfigDict(extra='forbid')
    monitor_signature: Optional[ForensicDataEntity] = None
    teacher_signature: Optional[ForensicDataEntity] = None
    comments: Optional[ForensicDataEntity] = None

class AcceleratedReaderTopsReport(BaseModel):
    """
    A resilient schema for Accelerated Reader TOPS reports (Taxonomy 000141).
    """
    model_config = ConfigDict(extra='forbid')

    document_title: ForensicDataEntity
    student_name: ForensicDataEntity
    printed_date: ForensicDataEntity
    school_name: ForensicDataEntity
    class_name: ForensicDataEntity
    grade: ForensicDataEntity
    teacher_name: ForensicDataEntity
    quiz_details: List[QuizDetail]
    quarterly_progress: QuarterlyProgress
    school_year_summary: SchoolYearSummary
    teacher_feedback: TeacherFeedback

    @model_validator(mode='after')
    def validate_summary_totals(self) -> 'AcceleratedReaderTopsReport':
        """
        Performs a double-entry GAAP-style checksum by verifying that cumulative
        year-to-date totals are greater than or equal to the totals from the
        most recent marking period. This ensures logical and mathematical consistency.
        """
        year_summary = self.school_year_summary
        quarter_progress = self.quarterly_progress

        # Extract numeric values for validation
        year_points = float(year_summary.points_earned.extracted_string_or_numeric_value)
        quarter_points = float(quarter_progress.points_earned.extracted_string_or_numeric_value)

        year_quizzes_passed = float(year_summary.quizzes_passed.extracted_string_or_numeric_value)
        quarter_quizzes_passed = float(quarter_progress.quizzes_passed.extracted_string_or_numeric_value)

        year_quizzes_taken = float(year_summary.quizzes_taken.extracted_string_or_numeric_value)
        quarter_quizzes_taken = float(quarter_progress.quizzes_taken.extracted_string_or_numeric_value)

        year_words_read = float(year_summary.total_words_read.extracted_string_or_numeric_value)
        quarter_words_read = float(quarter_progress.words_read.extracted_string_or_numeric_value)

        # Assert that cumulative totals are not less than periodic totals
        if year_points < quarter_points:
            raise ValueError(f"School Year points ({year_points}) cannot be less than Quarter points ({quarter_points}).")

        if year_quizzes_passed < quarter_quizzes_passed:
            raise ValueError(f"School Year quizzes passed ({year_quizzes_passed}) cannot be less than Quarter quizzes passed ({quarter_quizzes_passed}).")

        if year_quizzes_taken < quarter_quizzes_taken:
            raise ValueError(f"School Year quizzes taken ({year_quizzes_taken}) cannot be less than Quarter quizzes taken ({quarter_quizzes_taken}).")

        if year_words_read < quarter_words_read:
            raise ValueError(f"School Year words read ({year_words_read}) cannot be less than Quarter words read ({quarter_words_read}).")

        return self
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "doc_000141_variant_2012_11_28",
    "should_pass": true,
    "taxonomy_lane": "AcceleratedReaderTopsReport",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "Reading Practice TOPS Report",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 643, 643, 355],
          "vertical_y_vertices": [63, 63, 80, 80]
        }
      },
      "student_name": {
        "extracted_string_or_numeric_value": "COLE M. SOSA KIBBY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [395, 643, 643, 395],
          "vertical_y_vertices": [85, 85, 102, 102]
        }
      },
      "printed_date": {
        "extracted_string_or_numeric_value": "Wednesday, November 28, 2012 11:17:42 AM",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [370, 643, 643, 370],
          "vertical_y_vertices": [106, 106, 117, 117]
        }
      },
      "school_name": {
        "extracted_string_or_numeric_value": "Bristol Elementary School",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [195, 345, 345, 195],
          "vertical_y_vertices": [124, 124, 134, 134]
        }
      },
      "class_name": {
        "extracted_string_or_numeric_value": "Olsen",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [195, 228, 228, 195],
          "vertical_y_vertices": [138, 138, 148, 148]
        }
      },
      "grade": {
        "extracted_string_or_numeric_value": "1",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [788, 794, 794, 788],
          "vertical_y_vertices": [124, 124, 134, 134]
        }
      },
      "teacher_name": {
        "extracted_string_or_numeric_value": "Mrs. C. Olsen",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [688, 794, 794, 688],
          "vertical_y_vertices": [138, 138, 148, 148]
        }
      },
      "quiz_details": [
        {
          "book_title": {
            "extracted_string_or_numeric_value": "Green Eggs and Ham",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 330, 330, 207],
              "vertical_y_vertices": [210, 210, 220, 220]
            }
          },
          "book_author": {
            "extracted_string_or_numeric_value": "Seuss, Dr.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 275, 275, 207],
              "vertical_y_vertices": [224, 224, 234, 234]
            }
          },
          "score_correct": {
            "extracted_string_or_numeric_value": 5.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [550, 558, 558, 550],
              "vertical_y_vertices": [210, 210, 220, 220]
            }
          },
          "score_total": {
            "extracted_string_or_numeric_value": 5.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [578, 586, 586, 578],
              "vertical_y_vertices": [210, 210, 220, 220]
            }
          },
          "percent_correct": {
            "extracted_string_or_numeric_value": 100.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [738, 775, 775, 738],
              "vertical_y_vertices": [210, 210, 220, 220]
            }
          },
          "teacher_remark": {
            "extracted_string_or_numeric_value": "Remarkable, COLE!",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [510, 620, 620, 510],
              "vertical_y_vertices": [240, 240, 250, 250]
            }
          },
          "atos_bl": {
            "extracted_string_or_numeric_value": 1.5,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 270, 270, 207],
              "vertical_y_vertices": [278, 278, 288, 288]
            }
          },
          "quiz_number": {
            "extracted_string_or_numeric_value": 9021.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 300, 300, 207],
              "vertical_y_vertices": [292, 292, 302, 302]
            }
          },
          "language": {
            "extracted_string_or_numeric_value": "EN",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [304, 322, 322, 304],
              "vertical_y_vertices": [292, 292, 302, 302]
            }
          },
          "format": {
            "extracted_string_or_numeric_value": "Fiction",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [330, 410, 410, 330],
              "vertical_y_vertices": [292, 292, 302, 302]
            }
          },
          "quiz_date": {
            "extracted_string_or_numeric_value": "11/28/2012 11:15 AM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 360, 360, 207],
              "vertical_y_vertices": [306, 306, 316, 316]
            }
          },
          "word_count": {
            "extracted_string_or_numeric_value": 769.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [364, 440, 440, 364],
              "vertical_y_vertices": [306, 306, 316, 316]
            }
          },
          "interest_level": {
            "extracted_string_or_numeric_value": "Lower Grades (LG)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 350, 350, 207],
              "vertical_y_vertices": [320, 320, 330, 330]
            }
          },
          "twi": {
            "extracted_string_or_numeric_value": "Read With",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [207, 280, 280, 207],
              "vertical_y_vertices": [334, 334, 344, 344]
            }
          },
          "points_earned": {
            "extracted_string_or_numeric_value": 0.5,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [510, 600, 600, 510],
              "vertical_y_vertices": [306, 306, 316, 316]
            }
          },
          "points_possible": {
            "extracted_string_or_numeric_value": 0.5,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [610, 630, 630, 610],
              "vertical_y_vertices": [306, 306, 316, 316]
            }
          }
        }
      ],
      "quarterly_progress": {
        "header": {
          "extracted_string_or_numeric_value": "My Progress in 2nd Quarter",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [420, 600, 600, 420],
            "vertical_y_vertices": [380, 380, 390, 390]
          }
        },
        "date_range": {
          "extracted_string_or_numeric_value": "11/5/2012 - 11/28/2012",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [420, 560, 560, 420],
            "vertical_y_vertices": [395, 395, 405, 405]
          }
        },
        "percent_complete": {
          "extracted_string_or_numeric_value": 36.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [565, 600, 600, 565],
            "vertical_y_vertices": [395, 395, 405, 405]
          }
        },
        "average_percent_correct": {
          "extracted_string_or_numeric_value": 93.3,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [207, 370, 370, 207],
            "vertical_y_vertices": [420, 420, 430, 430]
          }
        },
        "average_percent_correct_goal": {
          "extracted_string_or_numeric_value": 85.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 320, 320, 300],
            "vertical_y_vertices": [435, 435, 445, 445]
          }
        },
        "points_earned": {
          "extracted_string_or_numeric_value": 1.4,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 700, 700, 600],
            "vertical_y_vertices": [420, 420, 430, 430]
          }
        },
        "points_goal": {
          "extracted_string_or_numeric_value": "No Goal Set",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 660, 660, 600],
            "vertical_y_vertices": [435, 435, 445, 445]
          }
        },
        "average_atos_bl": {
          "extracted_string_or_numeric_value": 1.4,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [207, 350, 350, 207],
            "vertical_y_vertices": [540, 540, 550, 550]
          }
        },
        "atos_bl_goal": {
          "extracted_string_or_numeric_value": "No Goal Set",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [207, 270, 270, 207],
            "vertical_y_vertices": [555, 555, 565, 565]
          }
        },
        "quizzes_passed": {
          "extracted_string_or_numeric_value": 3.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 688, 688, 680],
            "vertical_y_vertices": [540, 540, 550, 550]
          }
        },
        "quizzes_taken": {
          "extracted_string_or_numeric_value": 3.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 688, 688, 680],
            "vertical_y_vertices": [555, 555, 565, 565]
          }
        },
        "words_read": {
          "extracted_string_or_numeric_value": 1373.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 715, 715, 680],
            "vertical_y_vertices": [570, 570, 580, 580]
          }
        }
      },
      "school_year_summary": {
        "header": {
          "extracted_string_or_numeric_value": "My School Year Summary",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [420, 580, 580, 420],
            "vertical_y_vertices": [650, 650, 660, 660]
          }
        },
        "date_range": {
          "extracted_string_or_numeric_value": "9/4/2012 - 11/28/2012",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [420, 550, 550, 420],
            "vertical_y_vertices": [665, 665, 675, 675]
          }
        },
        "percent_complete": {
          "extracted_string_or_numeric_value": 32.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [555, 590, 590, 555],
            "vertical_y_vertices": [665, 665, 675, 675]
          }
        },
        "average_percent_correct": {
          "extracted_string_or_numeric_value": 95.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 350, 350, 320],
            "vertical_y_vertices": [700, 700, 710, 710]
          }
        },
        "points_earned": {
          "extracted_string_or_numeric_value": 1.9,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 350, 350, 320],
            "vertical_y_vertices": [715, 715, 725, 725]
          }
        },
        "average_atos_bl": {
          "extracted_string_or_numeric_value": 1.8,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 350, 350, 320],
            "vertical_y_vertices": [730, 730, 740, 740]
          }
        },
        "quizzes_passed": {
          "extracted_string_or_numeric_value": 4.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 510, 510, 500],
            "vertical_y_vertices": [700, 700, 710, 710]
          }
        },
        "quizzes_taken": {
          "extracted_string_or_numeric_value": 4.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 510, 510, 500],
            "vertical_y_vertices": [715, 715, 725, 725]
          }
        },
        "total_words_read": {
          "extracted_string_or_numeric_value": 1950.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 535, 535, 500],
            "vertical_y_vertices": [730, 730, 740, 740]
          }
        },
        "last_certification": null,
        "date_achieved": null,
        "certification_goal": null
      },
      "teacher_feedback": {
        "monitor_signature": {
          "extracted_string_or_numeric_value": "Les Berg...",
          "optical_extraction_confidence_score": 0.85,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 350, 350, 200],
            "vertical_y_vertices": [750, 750, 780, 780]
          }
        },
        "teacher_signature": null,
        "comments": {
          "extracted_string_or_numeric_value": "ü Great job!",
          "optical_extraction_confidence_score": 0.90,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [280, 550, 550, 280],
            "vertical_y_vertices": [820, 820, 880, 880]
          }
        }
      }
    }
  }
]
```