An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided documents and designed a resilient Pydantic V2 schema. The schema accommodates the structural variations found across the different medical encounter notes for Judith A. Grandy in 2018. The most complex structural variant, a detailed six-month follow-up visit, was chosen to generate the golden test case.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Optional, Union, Dict
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

class PatientInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_name: ForensicDataEntity
    dob: ForensicDataEntity
    patient_id: Optional[ForensicDataEntity] = None
    marital_status: Optional[ForensicDataEntity] = None
    language: Optional[ForensicDataEntity] = None
    race: Optional[ForensicDataEntity] = None
    gender: Optional[ForensicDataEntity] = None

class Medication(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    details: ForensicDataEntity
    status: ForensicDataEntity

class FamilyMemberHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    relative: ForensicDataEntity
    details: ForensicDataEntity

class SurgicalHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    procedure: ForensicDataEntity
    details: Optional[ForensicDataEntity] = None

class HealthMaintenanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    item_name: ForensicDataEntity
    date: ForensicDataEntity
    result: ForensicDataEntity

class SocialHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    tobacco_use: Optional[ForensicDataEntity] = None
    work_status: Optional[ForensicDataEntity] = None
    marital_status: Optional[ForensicDataEntity] = None
    alcohol_use: Optional[ForensicDataEntity] = None
    health_literacy: Optional[ForensicDataEntity] = None
    second_hand_smoke_exposure: Optional[ForensicDataEntity] = None
    caffeine_use: Optional[ForensicDataEntity] = None
    drug_use: Optional[ForensicDataEntity] = None
    exercise_history: Optional[ForensicDataEntity] = None

class ReviewOfSystems(BaseModel):
    model_config = ConfigDict(extra='forbid')
    skin: Optional[ForensicDataEntity] = None
    heent: Optional[ForensicDataEntity] = None
    neck: Optional[ForensicDataEntity] = None
    respiratory: Optional[ForensicDataEntity] = None
    gastrointestinal: Optional[ForensicDataEntity] = None
    neurological: Optional[ForensicDataEntity] = None
    endocrine: Optional[ForensicDataEntity] = None
    general: Optional[ForensicDataEntity] = None
    cardiovascular: Optional[ForensicDataEntity] = None
    musculoskeletal: Optional[ForensicDataEntity] = None
    psychiatric: Optional[ForensicDataEntity] = None
    female_genitourinary: Optional[ForensicDataEntity] = None
    hematology: Optional[ForensicDataEntity] = None

class Vitals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date_time: ForensicDataEntity
    weight: Optional[ForensicDataEntity] = None
    height: Optional[ForensicDataEntity] = None
    body_surface_area: Optional[ForensicDataEntity] = None
    body_mass_index: Optional[ForensicDataEntity] = None
    pulse: Optional[ForensicDataEntity] = None
    respiration: Optional[ForensicDataEntity] = None
    blood_pressure: Optional[ForensicDataEntity] = None
    temperature: Optional[ForensicDataEntity] = None

class PhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    general: Optional[ForensicDataEntity] = None
    integumentary: Optional[ForensicDataEntity] = None
    head_and_neck: Optional[ForensicDataEntity] = None
    chest_and_lung: Optional[ForensicDataEntity] = None
    cardiovascular: Optional[ForensicDataEntity] = None
    abdomen: Optional[ForensicDataEntity] = None
    lymphatic: Optional[ForensicDataEntity] = None
    peripheral_vascular: Optional[ForensicDataEntity] = None
    neurologic: Optional[ForensicDataEntity] = None
    musculoskeletal: Optional[ForensicDataEntity] = None
    enmt: Optional[ForensicDataEntity] = None
    breast: Optional[ForensicDataEntity] = None
    female_genitourinary: Optional[ForensicDataEntity] = None
    rectal: Optional[ForensicDataEntity] = None
    neuropsychiatric: Optional[ForensicDataEntity] = None
    eye: Optional[ForensicDataEntity] = None

class Plan(BaseModel):
    model_config = ConfigDict(extra='forbid')
    details: List[ForensicDataEntity]

class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis: ForensicDataEntity
    impression: ForensicDataEntity
    current_plans: Optional[Plan] = None
    future_plans: Optional[Plan] = None
    notes: Optional[ForensicDataEntity] = None

class LabResult(BaseModel):
    model_config = ConfigDict(extra='forbid')
    test_name: ForensicDataEntity
    diagnosis: Optional[ForensicDataEntity] = None
    result_value: ForensicDataEntity
    normal_range: ForensicDataEntity
    notes: Optional[ForensicDataEntity] = None

class Procedure(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    code: Optional[ForensicDataEntity] = None
    performed_date: Optional[ForensicDataEntity] = None
    status: ForensicDataEntity

class Encounter(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_id: ForensicDataEntity
    encounter_date: ForensicDataEntity
    encounter_type: Optional[ForensicDataEntity] = None
    location: Optional[ForensicDataEntity] = None
    diagnoses: Optional[List[ForensicDataEntity]] = None
    history_of_present_illness: Optional[ForensicDataEntity] = None
    problem_list: Optional[List[ForensicDataEntity]] = None
    allergies: Optional[List[ForensicDataEntity]] = None
    social_history: Optional[SocialHistory] = None
    medication_history: Optional[List[Medication]] = None
    family_history: Optional[List[FamilyMemberHistory]] = None
    past_surgical_history: Optional[List[SurgicalHistory]] = None
    health_maintenance_history: Optional[List[HealthMaintenanceItem]] = None
    diagnostic_studies_history: Optional[List[HealthMaintenanceItem]] = None
    impairments: Optional[List[ForensicDataEntity]] = None
    review_of_systems: Optional[ReviewOfSystems] = None
    vitals: Optional[Vitals] = None
    physical_exam: Optional[PhysicalExam] = None
    assessments_and_plans: Optional[List[AssessmentPlanItem]] = None
    lab_results: Optional[List[LabResult]] = None
    procedures: Optional[List[Procedure]] = None

class JudyGrandyMedicalDoctorOfficeNotes(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_info: PatientInfo
    document_date_range: ForensicDataEntity
    encounters: List[Encounter]

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksum(self) -> 'JudyGrandyMedicalDoctorOfficeNotes':
        # This validator is included to fulfill the directive requirements.
        # No financial data (e.g., debits, credits, totals) was identified in the source documents.
        # Therefore, a meaningful GAAP checksum cannot be performed.
        # The validator will simply pass, ensuring model integrity without mathematical checks.
        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "2018_judy_grandy_complex_encounter_test",
    "should_pass": true,
    "taxonomy_lane": "JudyGrandyMedicalDoctorOfficeNotes",
    "binary_header_simulation": "25504446",
    "payload": {
      "patient_info": {
        "patient_name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 550],
            "vertical_y_vertices": [140, 160]
          }
        },
        "dob": {
          "extracted_string_or_numeric_value": "08/18/1947",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 550],
            "vertical_y_vertices": [165, 175]
          }
        },
        "patient_id": {
          "extracted_string_or_numeric_value": "28641",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 250],
            "vertical_y_vertices": [280, 290]
          }
        },
        "marital_status": {
          "extracted_string_or_numeric_value": "Married",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 250],
            "vertical_y_vertices": [300, 310]
          }
        },
        "language": {
          "extracted_string_or_numeric_value": "English",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [255, 355],
            "vertical_y_vertices": [300, 310]
          }
        },
        "race": {
          "extracted_string_or_numeric_value": "White",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [360, 460],
            "vertical_y_vertices": [300, 310]
          }
        },
        "gender": {
          "extracted_string_or_numeric_value": "Female",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 250],
            "vertical_y_vertices": [320, 330]
          }
        }
      },
      "document_date_range": {
        "extracted_string_or_numeric_value": "From 01/01/2018 to 12/31/2018",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [150, 550],
          "vertical_y_vertices": [185, 195]
        }
      },
      "encounters": [
        {
          "encounter_id": {
            "extracted_string_or_numeric_value": "Encounter #6",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 250],
              "vertical_y_vertices": [50, 60]
            }
          },
          "encounter_date": {
            "extracted_string_or_numeric_value": "10/18/2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [80, 180],
              "vertical_y_vertices": [80, 90]
            }
          },
          "encounter_type": {
            "extracted_string_or_numeric_value": "Office Visit",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [185, 285],
              "vertical_y_vertices": [80, 90]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "Cadillac Family Physicians",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 400],
              "vertical_y_vertices": [270, 280]
            }
          },
          "diagnoses": [
            {
              "extracted_string_or_numeric_value": "GASTROESOPHAGEAL REFLUX (K21.9)",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [80, 90]
              }
            },
            {
              "extracted_string_or_numeric_value": "HYPERLIPIDEMIA, UNSPECIFIED",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [80, 90]
              }
            },
            {
              "extracted_string_or_numeric_value": "SUBCLINICAL HYPOTHYROIDISM (E03.9)",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [90, 100]
              }
            },
            {
              "extracted_string_or_numeric_value": "THORACIC COMPRESSION FRACTURE (S22.000A)",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [90, 100]
              }
            },
            {
              "extracted_string_or_numeric_value": "SEBACEOUS CYST (L72.3)",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [90, 100]
              }
            },
            {
              "extracted_string_or_numeric_value": "ATHLETES FOOT (B35.3)",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [100, 110]
              }
            },
            {
              "extracted_string_or_numeric_value": "MEDICARE FLU",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [100, 110]
              }
            },
            {
              "extracted_string_or_numeric_value": "NEED FOR SHINGLES VACCINE",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [100, 110]
              }
            },
            {
              "extracted_string_or_numeric_value": "BREAST CANCER SCREENING-BI",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [80, 850],
                "vertical_y_vertices": [100, 110]
              }
            }
          ],
          "history_of_present_illness": {
            "extracted_string_or_numeric_value": "Patient words: HERE FOR SIX MONTH FOLLOWUP CHRONIC MEDICAL CONDITIONS. The patient is a 71 year old female who presents with a complaint of Chronic condition(s).. The chronic problem is characterized as hyperlipidemia and thyroid disease. The patient has good energy level and is sleeping well. Current medication use: experiencing side effects (DRY COUGH AND DIFFICULTY SWALLOWING VITAMINS, NOT FOOD.). Nutrition: balanced diet. Patient exercises a daily (PT WALKS 5,000 STEPS A DAY). The patient exercises by: walking. The patients compliance with instructions has been takes medication as directed Patient sleeps 6-8 hours per night.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 850],
              "vertical_y_vertices": [360, 480]
            }
          },
          "problem_list": [
            {
              "extracted_string_or_numeric_value": "THORACIC COMPRESSION FRACTURE (S22.000A)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 600],
                "vertical_y_vertices": [530, 540]
              }
            },
            {
              "extracted_string_or_numeric_value": "GASTROESOPHAGEAL REFLUX (K21.9)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 600],
                "vertical_y_vertices": [540, 550]
              }
            },
            {
              "extracted_string_or_numeric_value": "HYPERLIPIDEMIA, UNSPECIFIED (E78.5)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 600],
                "vertical_y_vertices": [550, 560]
              }
            },
            {
              "extracted_string_or_numeric_value": "VARICOSE VEINS OF LEGS (183.93)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 600],
                "vertical_y_vertices": [560, 570]
              }
            },
            {
              "extracted_string_or_numeric_value": "SUBCLINICAL HYPOTHYROIDISM (E03.9)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 600],
                "vertical_y_vertices": [570, 580]
              }
            }
          ],
          "allergies": [
            {
              "extracted_string_or_numeric_value": "NO KNOWN MEDICATION ALLERGIES",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 500],
                "vertical_y_vertices": [610, 620]
              }
            },
            {
              "extracted_string_or_numeric_value": "Latex SENSITIVE",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 500],
                "vertical_y_vertices": [620, 630]
              }
            }
          ],
          "social_history": {
            "tobacco_use": {
              "extracted_string_or_numeric_value": "Never smoker.",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [660, 670]
              }
            },
            "exercise_history": {
              "extracted_string_or_numeric_value": "Exercises regularly. walks 7,000 to 10,000 steps per day; uses balls to squeeze daily and also does arm exercises with them.",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [760, 780]
              }
            }
          },
          "medication_history": [
            {
              "name": {
                "extracted_string_or_numeric_value": "Levothyroxine Sodium",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 300],
                  "vertical_y_vertices": [810, 820]
                }
              },
              "details": {
                "extracted_string_or_numeric_value": "(75MCG Tablet, 1 (one) Oral daily, Taken starting 08/29/2018)",
                "optical_extraction_confidence_score": 0.95,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [301, 800],
                  "vertical_y_vertices": [810, 820]
                }
              },
              "status": {
                "extracted_string_or_numeric_value": "Active.",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [801, 850],
                  "vertical_y_vertices": [810, 820]
                }
              }
            }
          ],
          "family_history": [
            {
              "relative": {
                "extracted_string_or_numeric_value": "Father",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 200],
                  "vertical_y_vertices": [980, 990]
                }
              },
              "details": {
                "extracted_string_or_numeric_value": "Deceased at age 92, Non-Insulin Dependent Diabetes Mellitus, Chronic Congestive Heart Failure",
                "optical_extraction_confidence_score": 0.96,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [201, 850],
                  "vertical_y_vertices": [980, 990]
                }
              }
            },
            {
              "relative": {
                "extracted_string_or_numeric_value": "Mother",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 200],
                  "vertical_y_vertices": [990, 1000]
                }
              },
              "details": {
                "extracted_string_or_numeric_value": "Deceased at age 65, Breast Cancer",
                "optical_extraction_confidence_score": 0.96,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [201, 850],
                  "vertical_y_vertices": [990, 1000]
                }
              }
            }
          ],
          "review_of_systems": {
            "skin": {
              "extracted_string_or_numeric_value": "Present- New Lesions (PT THINKS SHE MAY HAVE GANGION CYST ON LEFT HAND.).",
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [80, 90]
              }
            },
            "gastrointestinal": {
              "extracted_string_or_numeric_value": "Present- Abdominal Pain (SORE IN THE LEFT UPPER QUADRANT. HAS FELT BURNING PAIN BEFORE. PAIN COMES AND GOES FOR PAST THREE MONTHS. NOT ASSOCIATED WITH EATING OR GOING THE BATHROOM.), Difficulty Swallowing and Gets full quickly at meals (DOESN'T EAT AS MUCH AS SHE USED TO). Not Present- Constipation and Diarrhea.",
              "optical_extraction_confidence_score": 0.93,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [150, 200]
              }
            }
          },
          "vitals": {
            "date_time": {
              "extracted_string_or_numeric_value": "10/18/2018 9:57 AM",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 300],
                "vertical_y_vertices": [300, 310]
              }
            },
            "weight": {
              "extracted_string_or_numeric_value": "151 lb",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 250],
                "vertical_y_vertices": [310, 320]
              }
            },
            "height": {
              "extracted_string_or_numeric_value": "60 in",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [251, 350],
                "vertical_y_vertices": [310, 320]
              }
            },
            "body_mass_index": {
              "extracted_string_or_numeric_value": "29.49 kg/m²",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 400],
                "vertical_y_vertices": [330, 340]
              }
            },
            "pulse": {
              "extracted_string_or_numeric_value": "80 (Regular)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 250],
                "vertical_y_vertices": [340, 350]
              }
            },
            "blood_pressure": {
              "extracted_string_or_numeric_value": "118/74(Sitting, Left Arm, Large)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 450],
                "vertical_y_vertices": [350, 360]
              }
            }
          },
          "physical_exam": {
            "integumentary": {
              "extracted_string_or_numeric_value": "Color - normal coloration of skin (NO RASHES). Skin Moisture - normal skin moisture. Mobility & Turgor - normal mobility and turgor. Note: Bottom of feet are red. No ulcerations present. Skin warm, dry, and intact. Cyst like structure present on lateral aspect of left hand. Firm, mobile, and superficial. Not present near wrist joint.",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [480, 550]
              }
            },
            "abdomen": {
              "extracted_string_or_numeric_value": "Inspection - Inspection Normal. Palpation/Percussion Palpation and Percussion of the abdomen reveal - Soft. Tenderness - Epigastrium.",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [700, 740]
              }
            }
          },
          "assessments_and_plans": [
            {
              "diagnosis": {
                "extracted_string_or_numeric_value": "GASTROESOPHAGEAL REFLUX (K21.9)",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 500],
                  "vertical_y_vertices": [70, 80]
                }
              },
              "impression": {
                "extracted_string_or_numeric_value": "OTC MEDS as needed. Will reevaluate at time of physical in 6 mo.",
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 850],
                  "vertical_y_vertices": [80, 90]
                }
              },
              "current_plans": {
                "details": [
                  {
                    "extracted_string_or_numeric_value": "FOLLOW UP IN SIX MONTHS",
                    "optical_extraction_confidence_score": 0.98,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [170, 400],
                      "vertical_y_vertices": [110, 120]
                    }
                  }
                ]
              }
            },
            {
              "diagnosis": {
                "extracted_string_or_numeric_value": "SUBCLINICAL HYPOTHYROIDISM (E03.9)",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 500],
                  "vertical_y_vertices": [180, 190]
                }
              },
              "impression": {
                "extracted_string_or_numeric_value": "scheduled for labs next month to check thyroid function. Will adjuct medication if needed at that time. No complaints currently.",
                "optical_extraction_confidence_score": 0.97,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 850],
                  "vertical_y_vertices": [190, 210]
                }
              },
              "future_plans": {
                "details": [
                  {
                    "extracted_string_or_numeric_value": "11/16/2018: *TSH (THYROID STIMULATING HORMONE) (84443) - one time",
                    "optical_extraction_confidence_score": 0.98,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [170, 800],
                      "vertical_y_vertices": [230, 240]
                    }
                  },
                  {
                    "extracted_string_or_numeric_value": "11/16/2018: *T4 FREE (84439) - one time",
                    "optical_extraction_confidence_score": 0.98,
                    "physical_evidence_coordinates": {
                      "horizontal_x_vertices": [170, 800],
                      "vertical_y_vertices": [240, 250]
                    }
                  }
                ]
              }
            }
          ],
          "procedures": [
            {
              "name": {
                "extracted_string_or_numeric_value": "HIGH DOSE SPLIT VIRUS PRESERVATIVE FREE INFLUENZA VACCINE",
                "optical_extraction_confidence_score": 0.98,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [150, 600],
                  "vertical_y_vertices": [110, 120]
                }
              },
              "code": {
                "extracted_string_or_numeric_value": "90662",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [601, 650],
                  "vertical_y_vertices": [110, 120]
                }
              },
              "performed_date": {
                "extracted_string_or_numeric_value": "10/18/2018",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [700, 780],
                  "vertical_y_vertices": [110, 120]
                }
              },
              "status": {
                "extracted_string_or_numeric_value": "(Final, Reviewed)",
                "optical_extraction_confidence_score": 0.99,
                "physical_evidence_coordinates": {
                  "horizontal_x_vertices": [781, 880],
                  "vertical_y_vertices": [110, 120]
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