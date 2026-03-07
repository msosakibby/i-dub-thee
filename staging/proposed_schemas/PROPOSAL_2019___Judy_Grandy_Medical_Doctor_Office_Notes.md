An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided documents and designed a resilient Pydantic V2 schema to accommodate all structural variations. The schema is detailed below, followed by a comprehensive JSON test case representing the most complex document variant identified.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra="forbid")
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]


class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra="forbid")
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon


class PatientDemographics(BaseModel):
    model_config = ConfigDict(extra="forbid")
    patient_id: Optional[ForensicDataEntity] = None
    marital_status: Optional[ForensicDataEntity] = None
    language: Optional[ForensicDataEntity] = None
    race: Optional[ForensicDataEntity] = None
    gender: Optional[ForensicDataEntity] = None


class Problem(BaseModel):
    model_config = ConfigDict(extra="forbid")
    description: ForensicDataEntity
    code: Optional[ForensicDataEntity] = None


class Allergy(BaseModel):
    model_config = ConfigDict(extra="forbid")
    substance: ForensicDataEntity
    reaction: Optional[ForensicDataEntity] = None


class SocialHistory(BaseModel):
    model_config = ConfigDict(extra="forbid")
    tobacco_use: Optional[ForensicDataEntity] = None
    work_status: Optional[ForensicDataEntity] = None
    alcohol_use: Optional[ForensicDataEntity] = None
    exercise_history: Optional[ForensicDataEntity] = None
    caffeine_use: Optional[ForensicDataEntity] = None
    drug_use: Optional[ForensicDataEntity] = None
    health_literacy: Optional[ForensicDataEntity] = None


class Medication(BaseModel):
    model_config = ConfigDict(extra="forbid")
    name: ForensicDataEntity
    dosage_instructions: Optional[ForensicDataEntity] = None
    status: Optional[ForensicDataEntity] = None
    notes: Optional[ForensicDataEntity] = None


class SurgicalHistory(BaseModel):
    model_config = ConfigDict(extra="forbid")
    procedure: ForensicDataEntity
    year: Optional[ForensicDataEntity] = None
    details: Optional[ForensicDataEntity] = None


class DiagnosticStudy(BaseModel):
    model_config = ConfigDict(extra="forbid")
    study_name: ForensicDataEntity
    date: Optional[ForensicDataEntity] = None
    results: Optional[ForensicDataEntity] = None


class FamilyMemberHistory(BaseModel):
    model_config = ConfigDict(extra="forbid")
    relation: ForensicDataEntity
    details: ForensicDataEntity


class SystemReview(BaseModel):
    model_config = ConfigDict(extra="forbid")
    system: ForensicDataEntity
    findings: ForensicDataEntity


class VitalSigns(BaseModel):
    model_config = ConfigDict(extra="forbid")
    date_time: Optional[ForensicDataEntity] = None
    weight: Optional[ForensicDataEntity] = None
    height: Optional[ForensicDataEntity] = None
    bmi: Optional[ForensicDataEntity] = None
    temperature: Optional[ForensicDataEntity] = None
    pulse: Optional[ForensicDataEntity] = None
    respiration: Optional[ForensicDataEntity] = None
    blood_pressure: Optional[ForensicDataEntity] = None
    pain_level: Optional[ForensicDataEntity] = None


class BodySystemExam(BaseModel):
    model_config = ConfigDict(extra="forbid")
    system_name: ForensicDataEntity
    findings: ForensicDataEntity


class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra="forbid")
    diagnosis: ForensicDataEntity
    impression: Optional[ForensicDataEntity] = None
    current_plans: Optional[List[ForensicDataEntity]] = None
    future_plans: Optional[List[ForensicDataEntity]] = None


class Procedure(BaseModel):
    model_config = ConfigDict(extra="forbid")
    name: ForensicDataEntity
    code: Optional[ForensicDataEntity] = None
    status: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None


class LabComponent(BaseModel):
    model_config = ConfigDict(extra="forbid")
    name: ForensicDataEntity
    value: Optional[ForensicDataEntity] = None
    normal_range: Optional[ForensicDataEntity] = None
    note: Optional[ForensicDataEntity] = None


class LabTest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    test_name: ForensicDataEntity
    status: Optional[ForensicDataEntity] = None
    collection_date: Optional[ForensicDataEntity] = None
    diagnosis: Optional[ForensicDataEntity] = None
    components: Optional[List[LabComponent]] = None
    comment: Optional[ForensicDataEntity] = None


class Goal(BaseModel):
    model_config = ConfigDict(extra="forbid")
    description: ForensicDataEntity
    status: ForensicDataEntity
    start_date: ForensicDataEntity
    interventions_plans: List[ForensicDataEntity]


class CarePlan(BaseModel):
    model_config = ConfigDict(extra="forbid")
    health_concern: ForensicDataEntity
    status: ForensicDataEntity
    goals: List[Goal]


class QuestionAnswer(BaseModel):
    model_config = ConfigDict(extra="forbid")
    question: ForensicDataEntity
    answer: ForensicDataEntity


class Questionnaire(BaseModel):
    model_config = ConfigDict(extra="forbid")
    name: ForensicDataEntity
    score: Optional[ForensicDataEntity] = None
    interpretation: Optional[ForensicDataEntity] = None
    questions_and_answers: List[QuestionAnswer]


class Immunization(BaseModel):
    model_config = ConfigDict(extra="forbid")
    name: ForensicDataEntity
    date: ForensicDataEntity
    details: Optional[ForensicDataEntity] = None
    funding: Optional[ForensicDataEntity] = None


class Signature(BaseModel):
    model_config = ConfigDict(extra="forbid")
    signer: ForensicDataEntity
    date_time: ForensicDataEntity


class EncounterSummaryItem(BaseModel):
    model_config = ConfigDict(extra="forbid")
    encounter_number: ForensicDataEntity
    date: ForensicDataEntity
    diagnoses: List[ForensicDataEntity]


class Encounter(BaseModel):
    model_config = ConfigDict(extra="forbid")
    encounter_number: ForensicDataEntity
    encounter_date: ForensicDataEntity
    encounter_type: Optional[ForensicDataEntity] = None
    provider: Optional[ForensicDataEntity] = None
    location: Optional[ForensicDataEntity] = None
    patient_demographics: Optional[PatientDemographics] = None
    history_of_present_illness: Optional[ForensicDataEntity] = None
    problem_list_past_medical: Optional[List[Problem]] = None
    allergies: Optional[List[Allergy]] = None
    social_history: Optional[SocialHistory] = None
    medication_history: Optional[List[Medication]] = None
    past_surgical_history: Optional[List[SurgicalHistory]] = None
    diagnostic_studies_history: Optional[List[DiagnosticStudy]] = None
    health_maintenance_history: Optional[List[DiagnosticStudy]] = None
    family_history: Optional[List[FamilyMemberHistory]] = None
    impairments: Optional[List[ForensicDataEntity]] = None
    review_of_systems: Optional[List[SystemReview]] = None
    vitals: Optional[VitalSigns] = None
    physical_exam: Optional[List[BodySystemExam]] = None
    assessment_and_plan: Optional[List[AssessmentPlanItem]] = None
    procedures: Optional[List[Procedure]] = None
    laboratories: Optional[List[LabTest]] = None
    care_plans: Optional[List[CarePlan]] = None
    questionnaires: Optional[List[Questionnaire]] = None
    immunization_record: Optional[List[Immunization]] = None
    signatures: Optional[List[Signature]] = None


class JudyGrandyMedicalDoctorOfficeNotes(BaseModel):
    model_config = ConfigDict(extra="forbid")
    patient_name: ForensicDataEntity
    dob: ForensicDataEntity
    chart_period: ForensicDataEntity
    encounter_summary: Optional[List[EncounterSummaryItem]] = None
    encounters: List[Encounter]

    @model_validator(mode="after")
    def perform_gaap_checksum(self) -> "JudyGrandyMedicalDoctorOfficeNotes":
        """
        This validator is included to fulfill the directive's requirement for a
        double-entry GAAP mathematical checksum. However, the source documents
        are medical records and do not contain financial data (e.g., invoices,
        ledgers, balance sheets) to which a GAAP checksum (Assets = Liabilities + Equity)
        could be applied. The validator will therefore pass without performing a
        calculation.
        """
        # No financial data present in the document to perform a checksum.
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "complex_wellness_visit_encounter_2_2019",
    "should_pass": true,
    "taxonomy_lane": "JudyGrandyMedicalDoctorOfficeNotes",
    "binary_header_simulation": "25504446",
    "payload": {
      "patient_name": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100.0, 200.0, 200.0, 100.0],
          "vertical_y_vertices": [10.0, 10.0, 20.0, 20.0]
        }
      },
      "dob": {
        "extracted_string_or_numeric_value": "08/18/1947",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100.0, 200.0, 200.0, 100.0],
          "vertical_y_vertices": [21.0, 21.0, 31.0, 31.0]
        }
      },
      "chart_period": {
        "extracted_string_or_numeric_value": "From 01/01/2019 to 12/31/2019",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100.0, 300.0, 300.0, 100.0],
          "vertical_y_vertices": [32.0, 32.0, 42.0, 42.0]
        }
      },
      "encounter_summary": [
        {
          "encounter_number": {
            "extracted_string_or_numeric_value": "Encounter 2",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150.0, 250.0, 250.0, 150.0],
              "vertical_y_vertices": [500.0, 500.0, 510.0, 510.0]
            }
          },
          "date": {
            "extracted_string_or_numeric_value": "05/10/2019",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [251.0, 351.0, 351.0, 251.0],
              "vertical_y_vertices": [500.0, 500.0, 510.0, 510.0]
            }
          },
          "diagnoses": [
            {
              "extracted_string_or_numeric_value": "MEDICARE WELLNESS VISIT",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150.0, 350.0, 350.0, 150.0],
                "vertical_y_vertices": [511.0, 511.0, 521.0, 521.0]
              }
            }
          ]
        }
      ],
      "encounters": [
        {
          "encounter_number": {
            "extracted_string_or_numeric_value": "Encounter #2",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [149.0, 250.0, 250.0, 149.0],
              "vertical_y_vertices": [29.0, 29.0, 39.0, 39.0]
            }
          },
          "encounter_date": {
            "extracted_string_or_numeric_value": "5/10/2019",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [149.0, 250.0, 250.0, 149.0],
              "vertical_y_vertices": [40.0, 40.0, 50.0, 50.0]
            }
          },
          "encounter_type": {
            "extracted_string_or_numeric_value": "Medicare Annual Wellness Visit",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [149.0, 450.0, 450.0, 149.0],
              "vertical_y_vertices": [51.0, 51.0, 61.0, 61.0]
            }
          },
          "provider": {
            "extracted_string_or_numeric_value": "James R. Whelan, MD",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600.0, 750.0, 750.0, 600.0],
              "vertical_y_vertices": [51.0, 51.0, 61.0, 61.0]
            }
          },
          "vitals": {
            "date_time": {
              "extracted_string_or_numeric_value": "5/10/2019 10:26 AM",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150.0, 300.0, 300.0, 150.0],
                "vertical_y_vertices": [30.0, 30.0, 40.0, 40.0]
              }
            },
            "weight": {
              "extracted_string_or_numeric_value": "158.4 lb",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150.0, 250.0, 250.0, 150.0],
                "vertical_y_vertices": [41.0, 41.0, 51.0, 51.0]
              }
            },
            "bmi": {
              "extracted_string_or_numeric_value": "30.94 kg/m²",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [400.0, 500.0, 500.0, 400.0],
                "vertical_y_vertices": [52.0, 52.0, 62.0, 62.0]
              }
            },
            "blood_pressure": {
              "extracted_string_or_numeric_value": "140/80",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150.0, 250.0, 250.0, 150.0],
                "vertical_y_vertices": [73.0, 73.0, 83.0, 83.0]
              }
            }
          },
          "questionnaires": [
            {
              "name": {
                "extracted_string_or_numeric_value": "DEPRESSION QUESTIONNAIRE",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150.0, 350.0, 350.0, 150.0],
                  "vertical_y_vertices": [30.0, 30.0, 40.0, 40.0]
                }
              },
              "score": {
                "extracted_string_or_numeric_value": 4,
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150.0, 200.0, 200.0, 150.0],
                  "vertical_y_vertices": [41.0, 41.0, 51.0, 51.0]
                }
              },
              "questions_and_answers": [
                {
                  "question": {
                    "extracted_string_or_numeric_value": "Little interest or pleasure in doing things",
                    "optical_extraction_confidence_score": 0.97,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [150.0, 450.0, 450.0, 150.0],
                      "vertical_y_vertices": [60.0, 60.0, 70.0, 70.0]
                    }
                  },
                  "answer": {
                    "extracted_string_or_numeric_value": "1 -several days (Gets bored)",
                    "optical_extraction_confidence_score": 0.96,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [451.0, 651.0, 651.0, 451.0],
                      "vertical_y_vertices": [60.0, 60.0, 70.0, 70.0]
                    }
                  }
                }
              ]
            }
          ],
          "care_plans": [
            {
              "health_concern": {
                "extracted_string_or_numeric_value": "MEDICARE WELLNESS VISIT",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150.0, 350.0, 350.0, 150.0],
                  "vertical_y_vertices": [32.0, 32.0, 42.0, 42.0]
                }
              },
              "status": {
                "extracted_string_or_numeric_value": "Active",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [351.0, 401.0, 401.0, 351.0],
                  "vertical_y_vertices": [32.0, 32.0, 42.0, 42.0]
                }
              },
              "goals": [
                {
                  "description": {
                    "extracted_string_or_numeric_value": "Find activity to fill empty time",
                    "optical_extraction_confidence_score": 0.98,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [150.0, 350.0, 350.0, 150.0],
                      "vertical_y_vertices": [50.0, 50.0, 60.0, 60.0]
                    }
                  },
                  "status": {
                    "extracted_string_or_numeric_value": "Started",
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [351.0, 401.0, 401.0, 351.0],
                      "vertical_y_vertices": [50.0, 50.0, 60.0, 60.0]
                    }
                  },
                  "start_date": {
                    "extracted_string_or_numeric_value": "5/10/2019",
                    "optical_extraction_confidence_score": 0.99,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [402.0, 472.0, 472.0, 402.0],
                      "vertical_y_vertices": [50.0, 50.0, 60.0, 60.0]
                    }
                  },
                  "interventions_plans": [
                    {
                      "extracted_string_or_numeric_value": "Contact Council on Aging (Started, Volunteer programs)",
                      "optical_extraction_confidence_score": 0.97,
                      "physical_evidence_coordinates": {
                        "horizontal_x_vertices": [600.0, 800.0, 800.0, 600.0],
                        "vertical_y_vertices": [50.0, 50.0, 70.0, 70.0]
                      }
                    }
                  ]
                }
              ]
            }
          ],
          "signatures": [
            {
              "signer": {
                "extracted_string_or_numeric_value": "James R Whelan, MD",
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150.0, 350.0, 350.0, 150.0],
                  "vertical_y_vertices": [32.0, 32.0, 42.0, 42.0]
                }
              },
              "date_time": {
                "extracted_string_or_numeric_value": "5/10/2019 12:51 PM",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [351.0, 501.0, 501.0, 351.0],
                  "vertical_y_vertices": [32.0, 32.0, 42.0, 42.0]
                }
              }
            }
          ]
        }
      ]
    }
  }
]
```