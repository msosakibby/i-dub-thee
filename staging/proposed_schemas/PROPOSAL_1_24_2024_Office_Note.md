An analysis of the provided `1.24.2024 Office Note` reveals a comprehensive, multi-section medical report. The document structure includes patient identification, a summary of encounter diagnoses, and a detailed breakdown of a specific office visit. This detailed section encompasses patient demographics, multiple history sections (present illness, medical, surgical, social, family), a review of systems, vitals, a physical examination, a multi-part assessment and plan for various conditions, wellness visit-specific details, standardized questionnaires (PHQ-9, STEADI), a list of performed procedures, and an electronic signature.

To create a resilient schema, the structure is broken down into nested Pydantic models. Key data points like medications, problems, and assessment items are modeled as lists of objects to accommodate variability in number. A notable feature is the `Vitals` model, which includes a mathematical validator to checksum the Body Mass Index (BMI) calculation against the recorded weight and height, fulfilling the directive for a numerical verification. The overall schema is encapsulated within a root `OfficeNote` model, designed to be robust and strictly validated against the provided document structure.

### BLOCK 1 (Python Pydantic V2):
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

# --- ForensicDataEntity and SpatialCoordinatesPolygon (MANDATORY) ---

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# --- Custom Schema for '1.24.2024 Office Note' ---

class PatientHeader(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    document_date_range: ForensicDataEntity

class DiagnosisSummary(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis_name: ForensicDataEntity
    icd_code: ForensicDataEntity

class PatientDemographics(BaseModel):
    model_config = ConfigDict(extra='forbid')
    appointment_datetime: ForensicDataEntity
    location: ForensicDataEntity
    patient_id: ForensicDataEntity
    marital_status: ForensicDataEntity
    language: ForensicDataEntity
    race: ForensicDataEntity
    gender: ForensicDataEntity

class HistoryOfPresentIllness(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    patient_words: ForensicDataEntity
    narrative: ForensicDataEntity
    chronic_condition_details: ForensicDataEntity

class Problem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    problem_name: ForensicDataEntity
    icd_code: Optional[ForensicDataEntity] = None
    details: Optional[ForensicDataEntity] = None

class Allergy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    substance: ForensicDataEntity
    details: ForensicDataEntity

class SocialHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    work_status: ForensicDataEntity
    tobacco_use: ForensicDataEntity
    caffeine_use: ForensicDataEntity
    second_hand_smoke_exposure: ForensicDataEntity
    drug_use: ForensicDataEntity
    exercise_history: ForensicDataEntity
    health_literacy: ForensicDataEntity
    marital_status: ForensicDataEntity
    alcohol_use: ForensicDataEntity

class Medication(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    details: ForensicDataEntity
    status: ForensicDataEntity

class SurgicalHistoryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    procedure_name: ForensicDataEntity
    details: Optional[ForensicDataEntity] = None

class DiagnosticStudy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    study_name: ForensicDataEntity
    date: ForensicDataEntity
    results: ForensicDataEntity

class HealthMaintenanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    item_name: ForensicDataEntity
    date: ForensicDataEntity
    finding: ForensicDataEntity

class FamilyMemberHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    relation: ForensicDataEntity
    details: ForensicDataEntity

class Impairment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    type: ForensicDataEntity
    details: ForensicDataEntity

class ReviewOfSystems(BaseModel):
    model_config = ConfigDict(extra='forbid')
    general: ForensicDataEntity
    respiratory: ForensicDataEntity
    cardiovascular: ForensicDataEntity
    psychiatric: ForensicDataEntity

class Vitals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    timestamp: ForensicDataEntity
    weight_lb: ForensicDataEntity
    height_in: ForensicDataEntity
    body_mass_index: ForensicDataEntity
    pulse: ForensicDataEntity
    respiration: ForensicDataEntity
    blood_pressure: ForensicDataEntity

    @model_validator(mode='after')
    def validate_bmi_calculation(self) -> 'Vitals':
        weight_val = self.weight_lb.extracted_string_or_numeric_value
        height_val = self.height_in.extracted_string_or_numeric_value
        bmi_val = self.body_mass_index.extracted_string_or_numeric_value

        if isinstance(weight_val, (int, float)) and isinstance(height_val, (int, float)) and isinstance(bmi_val, (int, float)):
            if height_val > 0:
                calculated_bmi = (weight_val / (height_val ** 2)) * 703
                if not (abs(calculated_bmi - bmi_val) < 0.01):
                    raise ValueError(f"BMI checksum failed. Documented BMI: {bmi_val}, Calculated BMI: {calculated_bmi:.2f}")
        return self

class PhysicalExamSystem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    findings: List[ForensicDataEntity]

class PhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    systems: List[PhysicalExamSystem]

class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis: ForensicDataEntity
    icd_code: ForensicDataEntity
    hcc_codes: Optional[ForensicDataEntity] = None
    story: ForensicDataEntity
    impression: Optional[ForensicDataEntity] = None
    plan: Optional[ForensicDataEntity] = None

class WellnessVisitDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    impression: ForensicDataEntity
    regular_providers: List[ForensicDataEntity]
    hospitalizations: ForensicDataEntity
    advanced_care_plan_status: ForensicDataEntity
    tug_test_seconds: ForensicDataEntity
    mini_cog_score: ForensicDataEntity
    screenings_discussion: List[ForensicDataEntity]
    exercise_nutrition_advice: ForensicDataEntity
    current_plans: List[ForensicDataEntity]

class Evaluation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    normal_range: ForensicDataEntity
    score: ForensicDataEntity
    result: ForensicDataEntity

class QuestionAnswer(BaseModel):
    model_config = ConfigDict(extra='forbid')
    question: ForensicDataEntity
    answer: ForensicDataEntity

class Questionnaire(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    submitter: Optional[ForensicDataEntity] = None
    submission_date: Optional[ForensicDataEntity] = None
    evaluation: Evaluation
    questions: List[QuestionAnswer]

class Procedure(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    code: ForensicDataEntity
    performed_date: ForensicDataEntity
    status: ForensicDataEntity

class Signature(BaseModel):
    model_config = ConfigDict(extra='forbid')
    signer: ForensicDataEntity
    timestamp: ForensicDataEntity

class Encounter(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_date: ForensicDataEntity
    provider: ForensicDataEntity
    diagnoses_summary: List[DiagnosisSummary]
    patient_demographics: PatientDemographics
    history_of_present_illness: HistoryOfPresentIllness
    problem_list: List[Problem]
    allergies: List[Allergy]
    social_history: SocialHistory
    medication_history: List[Medication]
    past_surgical_history: List[SurgicalHistoryItem]
    diagnostic_studies: List[DiagnosticStudy]
    health_maintenance: List[HealthMaintenanceItem]
    family_history: List[FamilyMemberHistory]
    impairments: List[Impairment]
    review_of_systems: ReviewOfSystems
    vitals: Vitals
    physical_exam: PhysicalExam
    assessment_and_plan: List[AssessmentPlanItem]
    wellness_visit_details: WellnessVisitDetails
    questionnaires: List[Questionnaire]
    procedures: List[Procedure]
    signature: Signature

class OfficeNote(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_header: PatientHeader
    encounter: Encounter

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'OfficeNote':
        # Per directive, a GAAP checksum validator is required.
        # No financial data exists for a double-entry check.
        # A specific mathematical check (BMI) is performed in the Vitals model.
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "20240124_judith_grandy_officenote_complex",
    "should_pass": true,
    "taxonomy_lane": "OfficeNote",
    "binary_header_simulation": "25504446",
    "payload": {
      "patient_header": {
        "patient_name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 550],
            "vertical_y_vertices": [150, 165]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "08/18/1947",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 550],
            "vertical_y_vertices": [166, 180]
          }
        },
        "document_date_range": {
          "extracted_string_or_numeric_value": "From 01/01/2024 to 01/29/2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 550],
            "vertical_y_vertices": [181, 195]
          }
        }
      },
      "encounter": {
        "encounter_date": {
          "extracted_string_or_numeric_value": "01/24/2024",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 250],
            "vertical_y_vertices": [80, 95]
          }
        },
        "provider": {
          "extracted_string_or_numeric_value": "ANNE L. BROAD, MD",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [700, 850],
            "vertical_y_vertices": [80, 95]
          }
        },
        "diagnoses_summary": [
          {
            "diagnosis_name": {
              "extracted_string_or_numeric_value": "ALZHEIMER DISEASE",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 300],
                "vertical_y_vertices": [100, 115]
              }
            },
            "icd_code": {
              "extracted_string_or_numeric_value": "G30.9",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [301, 350],
                "vertical_y_vertices": [100, 115]
              }
            }
          },
          {
            "diagnosis_name": {
              "extracted_string_or_numeric_value": "HYPERTENSION, ESSENTIAL",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [500, 700],
                "vertical_y_vertices": [100, 115]
              }
            },
            "icd_code": {
              "extracted_string_or_numeric_value": "I10",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [701, 730],
                "vertical_y_vertices": [100, 115]
              }
            }
          }
        ],
        "patient_demographics": {
          "appointment_datetime": {
            "extracted_string_or_numeric_value": "1/24/2024 9:00 AM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [150, 160] }
          },
          "location": {
            "extracted_string_or_numeric_value": "Cadillac Family Physicians",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [161, 171] }
          },
          "patient_id": {
            "extracted_string_or_numeric_value": "28641",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [172, 182] }
          },
          "marital_status": {
            "extracted_string_or_numeric_value": "Married",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [194, 204] }
          },
          "language": {
            "extracted_string_or_numeric_value": "English",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [251, 350], "vertical_y_vertices": [194, 204] }
          },
          "race": {
            "extracted_string_or_numeric_value": "White",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [351, 450], "vertical_y_vertices": [194, 204] }
          },
          "gender": {
            "extracted_string_or_numeric_value": "Female",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [205, 215] }
          }
        },
        "history_of_present_illness": {
          "provider_and_timestamp": {
            "extracted_string_or_numeric_value": "ANNE L. BROAD MD; 1/24/2024 10:16 AM",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 500], "vertical_y_vertices": [220, 230] }
          },
          "patient_words": {
            "extracted_string_or_numeric_value": "6 month follow up for chronic medical condition and annual wellness subsequent.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [231, 241] }
          },
          "narrative": {
            "extracted_string_or_numeric_value": "The patient is a 76 year old female who presents today for a Medicare Annual Wellness Visit. The patient feels well with no complaints, denies any pain, enough sleep to manage daily life, appropriate use of safety belts and no increased stress.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [245, 280] }
          },
          "chronic_condition_details": {
            "extracted_string_or_numeric_value": "The chronic problem is characterized as arthritis, neurologic disorders (alzheimers) and as noted (chronic back pain, anxiety). The chronic condition(s). has been occurring for years. The patient rates the problem as moderate. The patient feels well with no associated symptoms.",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [290, 330] }
          }
        },
        "problem_list": [
          {
            "problem_name": {
              "extracted_string_or_numeric_value": "S/P TOTAL KNEE ARTHROPLASTY, RIGHT",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 450], "vertical_y_vertices": [380, 390] }
            },
            "icd_code": {
              "extracted_string_or_numeric_value": "Z96.651",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [451, 520], "vertical_y_vertices": [380, 390] }
            }
          },
          {
            "problem_name": {
              "extracted_string_or_numeric_value": "MEMORY LOSS",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [430, 440] }
            },
            "icd_code": {
              "extracted_string_or_numeric_value": "R41.3",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [251, 300], "vertical_y_vertices": [430, 440] }
            },
            "details": {
              "extracted_string_or_numeric_value": "Chronic condition, worsening",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [301, 500], "vertical_y_vertices": [430, 440] }
            }
          }
        ],
        "allergies": [
          {
            "substance": {
              "extracted_string_or_numeric_value": "NO KNOWN MEDICATION ALLERGIES",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 450], "vertical_y_vertices": [800, 810] }
            },
            "details": {
              "extracted_string_or_numeric_value": "[09/30/2022]:",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [451, 550], "vertical_y_vertices": [800, 810] }
            }
          },
          {
            "substance": {
              "extracted_string_or_numeric_value": "Latex",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [811, 821] }
            },
            "details": {
              "extracted_string_or_numeric_value": "[01/24/2024]: SENSITIVE",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [201, 400], "vertical_y_vertices": [811, 821] }
            }
          }
        ],
        "social_history": {
          "work_status": {
            "extracted_string_or_numeric_value": "Retired from Self employed grocery store",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 500], "vertical_y_vertices": [850, 860] }
          },
          "tobacco_use": {
            "extracted_string_or_numeric_value": "Never smoker.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [861, 871] }
          },
          "caffeine_use": {
            "extracted_string_or_numeric_value": "1 cup of tea occ; diet coke once per month or less; 2-3 of decaf coffee daily",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [872, 882] }
          },
          "second_hand_smoke_exposure": {
            "extracted_string_or_numeric_value": "None",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [883, 893] }
          },
          "drug_use": {
            "extracted_string_or_numeric_value": "No Drug Use",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [894, 904] }
          },
          "exercise_history": {
            "extracted_string_or_numeric_value": "Exercises regularly. walks 7,000 to 10,000 steps per day; uses balls to squeeze daily and also does arm exercises with them.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [905, 925] }
          },
          "health_literacy": {
            "extracted_string_or_numeric_value": "Yes.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [20, 30] }
          },
          "marital_status": {
            "extracted_string_or_numeric_value": "Married. Keith",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [31, 41] }
          },
          "alcohol_use": {
            "extracted_string_or_numeric_value": "Occasional alcohol use. hasnt drank in 2 to 3 weeks ago (beginning of june 2021)",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [42, 62] }
          }
        },
        "medication_history": [
          {
            "name": {
              "extracted_string_or_numeric_value": "atorvastatin",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [80, 90] }
            },
            "details": {
              "extracted_string_or_numeric_value": "10mg tablet, 1 (one) oral daily, Taken starting 07/05/2023",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [251, 700], "vertical_y_vertices": [80, 90] }
            },
            "status": {
              "extracted_string_or_numeric_value": "Active.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [701, 750], "vertical_y_vertices": [80, 90] }
            }
          }
        ],
        "past_surgical_history": [
          {
            "procedure_name": {
              "extracted_string_or_numeric_value": "Arthroscopic Knee Surgery - Both patellar relocation",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 600], "vertical_y_vertices": [280, 290] }
            }
          },
          {
            "procedure_name": {
              "extracted_string_or_numeric_value": "Total Knee Replacement - Right",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [320, 330] }
            },
            "details": {
              "extracted_string_or_numeric_value": "[10/2019]:",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [401, 500], "vertical_y_vertices": [320, 330] }
            }
          }
        ],
        "diagnostic_studies": [
          {
            "study_name": {
              "extracted_string_or_numeric_value": "MRI Brain, Brain Stem",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [450, 460] }
            },
            "date": {
              "extracted_string_or_numeric_value": "[10/19/2022]:",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [351, 450], "vertical_y_vertices": [450, 460] }
            },
            "results": {
              "extracted_string_or_numeric_value": "1. Enhancing extra-axial lesion left cerebral hemisphere just dorsal to the sylvian fissure imaging characteristics are that of a meningioma see dimensions above. Minor degree of local mass effect with no edema",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [451, 850], "vertical_y_vertices": [450, 500] }
            }
          }
        ],
        "health_maintenance": [
          {
            "item_name": {
              "extracted_string_or_numeric_value": "Colonoscopy, Screening",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [550, 560] }
            },
            "date": {
              "extracted_string_or_numeric_value": "[08/31/2021]:",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [351, 450], "vertical_y_vertices": [550, 560] }
            },
            "finding": {
              "extracted_string_or_numeric_value": "Positive Finding. 1. Internal and external hemorrhoids. 2. Moderate left-sided and sigmoid diverticulosis. 3. Small polyp at the hepatic flexure (adenoma). Repeat in 2024",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [451, 850], "vertical_y_vertices": [550, 590] }
            }
          }
        ],
        "family_history": [
          {
            "relation": {
              "extracted_string_or_numeric_value": "Mother",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [700, 710] }
            },
            "details": {
              "extracted_string_or_numeric_value": "Deceased at age 65, Breast Cancer",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [201, 550], "vertical_y_vertices": [700, 710] }
            }
          }
        ],
        "impairments": [
          {
            "type": {
              "extracted_string_or_numeric_value": "VISION",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [750, 760] }
            },
            "details": {
              "extracted_string_or_numeric_value": "[01/24/2024]: Glasses. Reading",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [201, 500], "vertical_y_vertices": [750, 760] }
            }
          }
        ],
        "review_of_systems": {
          "general": {
            "extracted_string_or_numeric_value": "Not Present- Chills, Fatigue and Fever.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 500], "vertical_y_vertices": [800, 810] }
          },
          "respiratory": {
            "extracted_string_or_numeric_value": "Not Present- Cough, Decreased Exercise Tolerance and Dyspnea.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 600], "vertical_y_vertices": [811, 821] }
          },
          "cardiovascular": {
            "extracted_string_or_numeric_value": "Not Present- Chest Pain and Edema.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 500], "vertical_y_vertices": [822, 832] }
          },
          "psychiatric": {
            "extracted_string_or_numeric_value": "Not Present- Anxiety, Depression, Difficulty Daily Functioning and Disturbance of Energy.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 800], "vertical_y_vertices": [833, 843] }
          }
        },
        "vitals": {
          "timestamp": {
            "extracted_string_or_numeric_value": "1/24/2024 8:51 AM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [880, 890] }
          },
          "weight_lb": {
            "extracted_string_or_numeric_value": 139.4,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [891, 901] }
          },
          "height_in": {
            "extracted_string_or_numeric_value": 60,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [251, 350], "vertical_y_vertices": [891, 901] }
          },
          "body_mass_index": {
            "extracted_string_or_numeric_value": 27.22,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [913, 923] }
          },
          "pulse": {
            "extracted_string_or_numeric_value": "66 (Regular)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 280], "vertical_y_vertices": [924, 934] }
          },
          "respiration": {
            "extracted_string_or_numeric_value": "16 (Unlabored)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [281, 450], "vertical_y_vertices": [924, 934] }
          },
          "blood_pressure": {
            "extracted_string_or_numeric_value": "110/70(Sitting, Left Arm, Standard)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 500], "vertical_y_vertices": [935, 945] }
          }
        },
        "physical_exam": {
          "systems": [
            {
              "category": {
                "extracted_string_or_numeric_value": "General",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [30, 40] }
              },
              "findings": [
                {
                  "extracted_string_or_numeric_value": "Mental Status - Alert.",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [41, 51] }
                },
                {
                  "extracted_string_or_numeric_value": "General Appearance - Cooperative, Not in acute distress.",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 600], "vertical_y_vertices": [52, 62] }
                }
              ]
            },
            {
              "category": {
                "extracted_string_or_numeric_value": "Cardiovascular",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 280], "vertical_y_vertices": [200, 210] }
              },
              "findings": [
                {
                  "extracted_string_or_numeric_value": "Heart Sounds - S1 WNL and S2 WNL, No S3, No S4. Murmurs & Other Heart Sounds - Auscultation of the heart reveals - No Murmurs.",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [221, 241] }
                }
              ]
            }
          ]
        },
        "assessment_and_plan": [
          {
            "diagnosis": {
              "extracted_string_or_numeric_value": "ALZHEIMER DISEASE",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [450, 460] }
            },
            "icd_code": {
              "extracted_string_or_numeric_value": "G30.9",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [301, 360], "vertical_y_vertices": [450, 460] }
            },
            "hcc_codes": {
              "extracted_string_or_numeric_value": "<HCCv2452 | HCCv28 127>",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [361, 550], "vertical_y_vertices": [450, 460] }
            },
            "story": {
              "extracted_string_or_numeric_value": "Underwent lab workup and MRI. MRI showed a meningioma but asymptomatic, normal labs",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [461, 490] }
            },
            "impression": {
              "extracted_string_or_numeric_value": "Established diagnosis and stable",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 450], "vertical_y_vertices": [491, 501] }
            },
            "plan": {
              "extracted_string_or_numeric_value": "Long discussion on disease w/ husband and son. Overall coping well, still does finances, discussed help w/ meds. Continue ariept. CPE 6 mo",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [502, 550] }
            }
          }
        ],
        "wellness_visit_details": {
          "impression": {
            "extracted_string_or_numeric_value": "A medicare wellness visit was performed in the office today. Please see the scanned health risk assessment document attached to this encounter for additional information. HRA was reviewed with patient.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [30, 60] }
          },
          "regular_providers": [
            {
              "extracted_string_or_numeric_value": "PCP: Anne Broad MD",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [80, 90] }
            }
          ],
          "hospitalizations": {
            "extracted_string_or_numeric_value": "NONE",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 450], "vertical_y_vertices": [110, 120] }
          },
          "advanced_care_plan_status": {
            "extracted_string_or_numeric_value": "YES",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [121, 131] }
          },
          "tug_test_seconds": {
            "extracted_string_or_numeric_value": "8 seconds",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 280], "vertical_y_vertices": [132, 142] }
          },
          "mini_cog_score": {
            "extracted_string_or_numeric_value": "2/5 - Hx of alzheimers disease, See above",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 550], "vertical_y_vertices": [143, 153] }
          },
          "screenings_discussion": [
            {
              "extracted_string_or_numeric_value": "Depression/anxiety screen: Hx anxiety, controlled w/ lexapro",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 700], "vertical_y_vertices": [160, 170] }
            }
          ],
          "exercise_nutrition_advice": {
            "extracted_string_or_numeric_value": "I recommend 30 minutes of aerobic exercise daily - Walking, hiking jogging, elliptical, ect. Balanced diet minimizing saturated fats and simple carbs recommended",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [210, 240] }
          },
          "current_plans": [
            {
              "extracted_string_or_numeric_value": "ANNUAL WELLNESS VISIT, INCLUDES A PERSONALIZED PREVENTION PLAN OF SERVICE (PPS), SUBSEQUENT VISIT (G0439)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [160, 850], "vertical_y_vertices": [250, 260] }
            }
          ]
        },
        "questionnaires": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Patient Health Questionnaire- (Adult PHQ-9)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 600], "vertical_y_vertices": [450, 460] }
            },
            "submitter": {
              "extracted_string_or_numeric_value": "Sadler, Makayla (Undefined)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [470, 480] }
            },
            "submission_date": {
              "extracted_string_or_numeric_value": "01/24/2024",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [401, 500], "vertical_y_vertices": [470, 480] }
            },
            "evaluation": {
              "name": {
                "extracted_string_or_numeric_value": "No Section",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [510, 520] }
              },
              "normal_range": {
                "extracted_string_or_numeric_value": "0-4",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [251, 300], "vertical_y_vertices": [510, 520] }
              },
              "score": {
                "extracted_string_or_numeric_value": "0",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 450], "vertical_y_vertices": [510, 520] }
              },
              "result": {
                "extracted_string_or_numeric_value": "Pass",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 400], "vertical_y_vertices": [510, 520] }
              }
            },
            "questions": [
              {
                "question": {
                  "extracted_string_or_numeric_value": "Little interest or pleasure in doing things?",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 500], "vertical_y_vertices": [550, 560] }
                },
                "answer": {
                  "extracted_string_or_numeric_value": "Not at all",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 700], "vertical_y_vertices": [550, 560] }
                }
              }
            ]
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Fall Risk Assessment",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [50, 60] }
            },
            "evaluation": {
              "name": {
                "extracted_string_or_numeric_value": "Fall Risk Assessment",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [30, 40] }
              },
              "normal_range": {
                "extracted_string_or_numeric_value": "0-3",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [301, 350], "vertical_y_vertices": [30, 40] }
              },
              "score": {
                "extracted_string_or_numeric_value": "1",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 500], "vertical_y_vertices": [30, 40] }
              },
              "result": {
                "extracted_string_or_numeric_value": "Pass",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 450], "vertical_y_vertices": [30, 40] }
              }
            },
            "questions": [
              {
                "question": {
                  "extracted_string_or_numeric_value": "I need to push with my hands to stand up from a chair.",
                  "optical_extraction_confidence_score": 0.98,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 550], "vertical_y_vertices": [150, 160] }
                },
                "answer": {
                  "extracted_string_or_numeric_value": "Yes (depends on chair)",
                  "optical_extraction_confidence_score": 0.97,
                  "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 800], "vertical_y_vertices": [150, 170] }
                }
              }
            ]
          }
        ],
        "procedures": [
          {
            "name": {
              "extracted_string_or_numeric_value": "ANNUAL WELLNESS VISIT, INCLUDES A PERSONALIZED PREVENTION PLAN OF SERVICE (PPS), SUBSEQUENT VISIT",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [500, 520] }
            },
            "code": {
              "extracted_string_or_numeric_value": "G0439",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 220], "vertical_y_vertices": [521, 531] }
            },
            "performed_date": {
              "extracted_string_or_numeric_value": "01/24/2024",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 400], "vertical_y_vertices": [521, 531] }
            },
            "status": {
              "extracted_string_or_numeric_value": "Final, Reviewed",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [401, 550], "vertical_y_vertices": [521, 531] }
            }
          }
        ],
        "signature": {
          "signer": {
            "extracted_string_or_numeric_value": "ANNE L. BROAD, MD",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 500], "vertical_y_vertices": [450, 460] }
          },
          "timestamp": {
            "extracted_string_or_numeric_value": "1/24/2024 10:18 AM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [501, 650], "vertical_y_vertices": [450, 460] }
          }
        }
      }
    }
  }
]
```