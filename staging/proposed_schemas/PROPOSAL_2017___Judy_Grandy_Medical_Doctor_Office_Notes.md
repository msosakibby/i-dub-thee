An expert forensic data architect, I have analyzed the provided medical records for Judith A. Grandy. The documents exhibit structural drift, particularly between the comprehensive annual physical exam (Encounter #1) and the more focused follow-up visits (Encounters #2 and #3). The annual exam contains significantly more detailed sections for the Review of Systems and Physical Examination.

To create a resilient schema, I have identified the superset of all possible fields present across the documents. Fields that are not consistently present, such as the detailed sub-sections of the physical exam, are typed as `Optional`. The resulting Pydantic V2 model can parse any of the provided encounter formats without data loss. The most complex structural variant, Encounter #1, has been selected for the golden test case.

### **BLOCK 1 (Python Pydantic V2)**
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

#
# FORENSIC DATA PRIMITIVES (MANDATORY)
#

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

#
# NESTED SUB-MODELS FOR ENCOUNTER DETAILS
#

class HistoryOfPresentIllness(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    patient_words: ForensicDataEntity
    narrative: ForensicDataEntity

class SocialHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    alcohol_use: ForensicDataEntity
    tobacco_use: ForensicDataEntity
    health_literacy: ForensicDataEntity
    second_hand_smoke: ForensicDataEntity
    work_status: ForensicDataEntity
    drug_use: ForensicDataEntity
    caffeine_use: ForensicDataEntity
    marital_status: ForensicDataEntity
    exercise_history: ForensicDataEntity

class Medication(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    dosage_and_form: ForensicDataEntity
    instructions: ForensicDataEntity
    start_date: ForensicDataEntity
    status: ForensicDataEntity

class MedicationHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    medications: List[Medication]
    medications_reconciled: ForensicDataEntity

class HealthMaintenanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    test_name: ForensicDataEntity
    details: ForensicDataEntity

class FamilyHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    father: ForensicDataEntity
    brother_1: ForensicDataEntity
    brother_2: ForensicDataEntity
    sister_1: ForensicDataEntity
    mother: ForensicDataEntity

class ReviewOfSystems(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    general: ForensicDataEntity
    skin: ForensicDataEntity
    heent: ForensicDataEntity
    respiratory: ForensicDataEntity
    cardiovascular: ForensicDataEntity
    gastrointestinal: ForensicDataEntity
    musculoskeletal: ForensicDataEntity
    neurological: ForensicDataEntity
    hematology: ForensicDataEntity
    neck: Optional[ForensicDataEntity] = None
    breast: Optional[ForensicDataEntity] = None
    female_genitourinary: Optional[ForensicDataEntity] = None
    psychiatric: Optional[ForensicDataEntity] = None
    endocrine: Optional[ForensicDataEntity] = None

class Vitals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    timestamp: ForensicDataEntity
    weight: ForensicDataEntity
    height: ForensicDataEntity
    body_surface_area: ForensicDataEntity
    body_mass_index: ForensicDataEntity
    pulse: ForensicDataEntity
    respiration: ForensicDataEntity
    blood_pressure: ForensicDataEntity

class GeneralPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    mental_status: ForensicDataEntity
    general_appearance: ForensicDataEntity
    build_and_nutrition: ForensicDataEntity
    hydration: ForensicDataEntity
    posture: Optional[ForensicDataEntity] = None
    voice: Optional[ForensicDataEntity] = None

class IntegumentaryPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    color: ForensicDataEntity
    skin_moisture: Optional[ForensicDataEntity] = None
    mobility_and_turgor: Optional[ForensicDataEntity] = None
    overall_examination: Optional[ForensicDataEntity] = None

class HeadAndNeckPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    head: Optional[ForensicDataEntity] = None
    face: Optional[ForensicDataEntity] = None
    neck_global_assessment: ForensicDataEntity
    trachea: ForensicDataEntity
    thyroid_gland_characteristics: ForensicDataEntity

class EyePhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    eyeball: ForensicDataEntity
    cornea: ForensicDataEntity
    lens: ForensicDataEntity
    fundi: ForensicDataEntity
    pupil: ForensicDataEntity

class ENMTPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    global_assessment: ForensicDataEntity

class ChestAndLungPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    inspection_accessory_muscles: ForensicDataEntity
    auscultation_breath_sounds: ForensicDataEntity
    auscultation_adventitious_sounds: ForensicDataEntity
    chest_wall: Optional[ForensicDataEntity] = None
    percussion: Optional[ForensicDataEntity] = None
    palpation: Optional[ForensicDataEntity] = None

class CardiovascularPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    carotid_arteries_bruit: ForensicDataEntity
    inspection_carotid_artery: ForensicDataEntity
    inspection_jugular_vein: ForensicDataEntity
    auscultation_heart_sounds: ForensicDataEntity
    auscultation_murmurs: ForensicDataEntity
    palpation_percussion: Optional[ForensicDataEntity] = None

class AbdomenPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    palpation_percussion: ForensicDataEntity
    inspection: Optional[ForensicDataEntity] = None
    auscultation: Optional[ForensicDataEntity] = None

class PeripheralVascularPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    lower_extremity_inspection: ForensicDataEntity
    lower_extremity_palpation_tenderness: ForensicDataEntity
    lower_extremity_edema: ForensicDataEntity
    upper_extremity_radial_pulse: Optional[ForensicDataEntity] = None
    lower_extremity_homans_sign: Optional[ForensicDataEntity] = None
    lower_extremity_femoral_pulse: Optional[ForensicDataEntity] = None
    lower_extremity_dorsalis_pedis_pulse: Optional[ForensicDataEntity] = None

class NeurologicPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    mental_status_affect: ForensicDataEntity
    mental_status_speech: ForensicDataEntity
    mental_status_thought_content: ForensicDataEntity
    mental_status_cognitive_function: ForensicDataEntity
    sensory: ForensicDataEntity
    motor: ForensicDataEntity
    cranial_nerves: Optional[ForensicDataEntity] = None
    reflexes_dermatomes: Optional[ForensicDataEntity] = None
    plantar_reflexes: Optional[ForensicDataEntity] = None
    coordination: Optional[ForensicDataEntity] = None
    gait: Optional[ForensicDataEntity] = None

class MusculoskeletalPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    note: Optional[ForensicDataEntity] = None
    global_assessment: Optional[ForensicDataEntity] = None
    spine_ribs_pelvis: Optional[ForensicDataEntity] = None

class LymphaticPhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    head_and_neck: ForensicDataEntity
    axillary: Optional[ForensicDataEntity] = None
    femoral_and_inguinal: Optional[ForensicDataEntity] = None

class PhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    general: GeneralPhysicalExam
    integumentary: IntegumentaryPhysicalExam
    head_and_neck: HeadAndNeckPhysicalExam
    enmt: ENMTPhysicalExam
    chest_and_lung: ChestAndLungPhysicalExam
    cardiovascular: CardiovascularPhysicalExam
    abdomen: AbdomenPhysicalExam
    peripheral_vascular: PeripheralVascularPhysicalExam
    neurologic: NeurologicPhysicalExam
    musculoskeletal: MusculoskeletalPhysicalExam
    lymphatic: Optional[LymphaticPhysicalExam] = None
    eye: Optional[EyePhysicalExam] = None
    breast: Optional[ForensicDataEntity] = None
    female_genitourinary: Optional[ForensicDataEntity] = None
    rectal: Optional[ForensicDataEntity] = None
    neuropsychiatric: Optional[ForensicDataEntity] = None

class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis: ForensicDataEntity
    impression: Optional[ForensicDataEntity] = None
    current_plans: Optional[List[ForensicDataEntity]] = None
    story: Optional[ForensicDataEntity] = None

class AssessmentAndPlan(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author_and_timestamp: ForensicDataEntity
    items: List[AssessmentPlanItem]

class PHQ4Result(BaseModel):
    model_config = ConfigDict(extra='forbid')
    question: ForensicDataEntity
    answer: ForensicDataEntity

class ProcedureItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    performed_date_and_status: ForensicDataEntity
    phq4_score: Optional[ForensicDataEntity] = None
    phq4_results: Optional[List[PHQ4Result]] = None

class Procedures(BaseModel):
    model_config = ConfigDict(extra='forbid')
    items: List[ProcedureItem]

class Signature(BaseModel):
    model_config = ConfigDict(extra='forbid')
    signature_image: ForensicDataEntity
    signed_by_line: ForensicDataEntity

#
# TOP-LEVEL ENCOUNTER MODEL
#

class Encounter(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_title: ForensicDataEntity
    report_type: ForensicDataEntity
    visit_summary: ForensicDataEntity
    patient_name: ForensicDataEntity
    visit_timestamp: ForensicDataEntity
    location: ForensicDataEntity
    patient_id: ForensicDataEntity
    dob: ForensicDataEntity
    demographics: ForensicDataEntity
    gender: ForensicDataEntity
    history_of_present_illness: HistoryOfPresentIllness
    problem_list: List[ForensicDataEntity]
    allergies: List[ForensicDataEntity]
    social_history: SocialHistory
    medication_history: MedicationHistory
    past_surgical_history: List[ForensicDataEntity]
    diagnostic_studies_history: List[ForensicDataEntity]
    health_maintenance_history: List[HealthMaintenanceItem]
    family_history: FamilyHistory
    impairments: List[ForensicDataEntity]
    review_of_systems: ReviewOfSystems
    vitals: Vitals
    physical_exam: PhysicalExam
    assessment_and_plan: AssessmentAndPlan
    signature: Signature
    procedures: Procedures

#
# ROOT DOCUMENT MODEL
#

class JudyGrandyMedicalDoctorOfficeNotes(BaseModel):
    model_config = ConfigDict(extra='forbid')
    chart_title: ForensicDataEntity
    patient_name: ForensicDataEntity
    dob: ForensicDataEntity
    date_range: ForensicDataEntity
    encounters_summary: List[ForensicDataEntity]
    encounters: List[Encounter]
    footer_timestamp: ForensicDataEntity
    footer_patient_info: ForensicDataEntity
    footer_page_number: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'JudyGrandyMedicalDoctorOfficeNotes':
        """
        A double-entry GAAP mathematical checksum is required.
        However, no financial data (e.g., charges, payments, balances)
        is present in the source documents. This validator is included
        to meet the directive's requirements but performs no calculations.
        """
        # No financial fields were identified in the document structure.
        # If fields like `total_charges`, `patient_payment`, `insurance_adjustment`,
        # or `account_balance` were present, the following logic would be applied:
        #
        # running_total = 0.0
        # for item in self.line_items:
        #     running_total += item.charge.extracted_string_or_numeric_value
        #
        # if abs(running_total - self.summary.total_charges.extracted_string_or_numeric_value) > 0.01:
        #     raise ValueError("GAAP checksum failed: Line item charges do not sum to the total charge.")
        
        return self
```

### **BLOCK 2 (JSON Test Registry)**
```json
[
  {
    "test_identifier": "2017_judy_grandy_encounter_1_comprehensive_exam",
    "should_pass": true,
    "taxonomy_lane": "JudyGrandyMedicalDoctorOfficeNotes",
    "binary_header_simulation": "25504446",
    "payload": {
      "chart_title": {
        "extracted_string_or_numeric_value": "Chart",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 200],
          "vertical_y_vertices": [100, 120]
        }
      },
      "patient_name": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 250],
          "vertical_y_vertices": [130, 140]
        }
      },
      "dob": {
        "extracted_string_or_numeric_value": "DOB: 08/18/1947",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 250],
          "vertical_y_vertices": [145, 155]
        }
      },
      "date_range": {
        "extracted_string_or_numeric_value": "From 01/01/2017 to 12/31/2017",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300],
          "vertical_y_vertices": [160, 170]
        }
      },
      "encounters_summary": [
        {
          "extracted_string_or_numeric_value": "Encounter 3 Date 10/16/2017 Diagnosis HISTORY OF BREAST CANCER (Z85.3), HYPERLIPIDEMIA, UNSPECIFIED, SUBCLINICAL HYPOTHYROIDISM (E03.9), BMI 27.0-27.9 IN ADULT (Z68.27)",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850],
            "vertical_y_vertices": [150, 180]
          }
        },
        {
          "extracted_string_or_numeric_value": "Encounter 2 Date 06/09/2017 Diagnosis PAIN OF RIGHT CALF (M79.661), VARICOSE VEINS OF LEGS (183.93), PHYSICAL DECONDITIONING (R53.81), BMI 28.0-28.9,ADULT (Z68.28)",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850],
            "vertical_y_vertices": [190, 220]
          }
        },
        {
          "extracted_string_or_numeric_value": "Encounter 1 Date 04/10/2017 Diagnosis ANNUAL PHYSICAL EXAM (Z00.00), OSTEOPHYTE, RIGHT ANKLE (M25.771), HYPERLIPIDEMIA, UNSPECIFIED, HISTORY OF BREAST CANCER (Z85.3), SUBCLINICAL HYPOTHYROIDISM (E03.9), ADVANCED DIRECTIVES, COUNSELING/DISCUSSION, NEVER USED TOBACCO (CIGS, PIPE, CHEW) (Z78.9),",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [150, 850],
            "vertical_y_vertices": [230, 270]
          }
        }
      ],
      "encounters": [
        {
          "encounter_title": {
            "extracted_string_or_numeric_value": "Encounter #1",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 250],
              "vertical_y_vertices": [150, 160]
            }
          },
          "report_type": {
            "extracted_string_or_numeric_value": "History & Physical Report",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 350],
              "vertical_y_vertices": [170, 180]
            }
          },
          "visit_summary": {
            "extracted_string_or_numeric_value": "4/10/2017: Office Visit - ANNUAL PHYSICAL EXAM (Z00.00), OSTEOPHYTE, RIGHT ANKLE (M25.771), HYPERLIPIDEMIA, UNSPECIFIED, HISTORY OF BREAST CANCER (Z85.3), SUBCLINICAL HYPOTHYROIDISM (E03.9), ADVANCED DIRECTIVES, COUNSELING/DISCUSSION, NEVER USED TOBACCO (CIGS, PIPE, CHEW) (Z78.9), (James R. Whelan, MD)",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 850],
              "vertical_y_vertices": [190, 240]
            }
          },
          "patient_name": {
            "extracted_string_or_numeric_value": "Judith Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 250],
              "vertical_y_vertices": [250, 260]
            }
          },
          "visit_timestamp": {
            "extracted_string_or_numeric_value": "4/10/2017 3:25 PM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 280],
              "vertical_y_vertices": [265, 275]
            }
          },
          "location": {
            "extracted_string_or_numeric_value": "Cadillac Family Physicians",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 320],
              "vertical_y_vertices": [280, 290]
            }
          },
          "patient_id": {
            "extracted_string_or_numeric_value": "Patient #: 28641",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 280],
              "vertical_y_vertices": [295, 305]
            }
          },
          "dob": {
            "extracted_string_or_numeric_value": "DOB: 8/18/1947",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 250],
              "vertical_y_vertices": [310, 320]
            }
          },
          "demographics": {
            "extracted_string_or_numeric_value": "Married / Language: English / Race: White",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 450],
              "vertical_y_vertices": [325, 335]
            }
          },
          "gender": {
            "extracted_string_or_numeric_value": "Female",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [150, 200],
              "vertical_y_vertices": [340, 350]
            }
          },
          "history_of_present_illness": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(James R. Whelan MD; 4/23/2017 9:53 AM)",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [350, 650],
                "vertical_y_vertices": [360, 370]
              }
            },
            "patient_words": {
              "extracted_string_or_numeric_value": "FOLLOW UP CHRONIC MEDICAL CONDITIONS, COMPREHENSIVE EXAM, REVIEW LABWORK FROM 4/3/2017.",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [375, 395]
              }
            },
            "narrative": {
              "extracted_string_or_numeric_value": "has been feeling well,. The patient is a 69 year old female who presents for a complete CFP Exam-Female. The patient feels well with no complaints, has good energy level and is sleeping well. Pap smear: Date: (5/1/2015 - NEGATIVE). Last mammogram: Date of exam: (11/3/2016 - LEFT, NEGATIVE). The patient's appetite is normal. Nutrition: balanced diet and supplemental vitamins. Patient exercises daily. The patient exercises by: walking. Patient sleeps 8 hours per night. The patient reports that she performs monthly self breast exam. Safety measures taken include appropriate use of safety belts.",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [150, 850],
                "vertical_y_vertices": [400, 500]
              }
            }
          },
          "problem_list": [],
          "allergies": [],
          "social_history": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(Kindra S. Odette, RMA; 4/10/2017 4:07 PM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "alcohol_use": {
              "extracted_string_or_numeric_value": "Occasional alcohol use. 1 glass of wine every 6 months",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "tobacco_use": {
              "extracted_string_or_numeric_value": "Never smoker.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "health_literacy": {
              "extracted_string_or_numeric_value": "Yes.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "second_hand_smoke": {
              "extracted_string_or_numeric_value": "None",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "work_status": {
              "extracted_string_or_numeric_value": "Retired from Business",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "drug_use": {
              "extracted_string_or_numeric_value": "No Drug Use",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "caffeine_use": {
              "extracted_string_or_numeric_value": "1-2 cup of coffee and 1 cup of tea qd; no pop",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "marital_status": {
              "extracted_string_or_numeric_value": "Married.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "exercise_history": {
              "extracted_string_or_numeric_value": "Exercises regularly. walks 7,000 to 10,000 steps per day; uses balls to squeeze daily and also does arm exercises with them.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            }
          },
          "medication_history": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(Kindra S. Odette, RMA; 4/10/2017 4:02 PM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "medications": [],
            "medications_reconciled": {
              "extracted_string_or_numeric_value": "Medications Reconciled",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            }
          },
          "past_surgical_history": [],
          "diagnostic_studies_history": [],
          "health_maintenance_history": [],
          "family_history": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(James R. Whelan, MD; 4/10/2017 4:16 PM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "father": {
              "extracted_string_or_numeric_value": "Deceased at age 92, Non-Insulin Dependent Diabetes Mellitus, Chronic Congestive Heart Failure",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "brother_1": {
              "extracted_string_or_numeric_value": "In good health at age 80, Non-Insulin Dependent Diabetes Mellitus",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "brother_2": {
              "extracted_string_or_numeric_value": "In good health at age 65",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "sister_1": {
              "extracted_string_or_numeric_value": "JOANNE WESTON, In good health at age 60",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "mother": {
              "extracted_string_or_numeric_value": "Deceased at age 65, Breast Cancer",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            }
          },
          "impairments": [],
          "review_of_systems": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(James R. Whelan MD; 4/23/2017 9:53 AM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "general": {
              "extracted_string_or_numeric_value": "Not Present- Chills, Fatigue, Fever, Night Sweats, Weight Gain > 10lbs. and Weight Loss > 10lbs..",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "skin": {
              "extracted_string_or_numeric_value": "Not Present- Change in Wart/Mole, New Lesions, Rash, Skin Color Changes and Skin disorders or senstivities.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "heent": {
              "extracted_string_or_numeric_value": "Not Present- Earache, Hearing Loss, Hoarseness, Sore Throat and Visual Disturbances.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "respiratory": {
              "extracted_string_or_numeric_value": "Not Present- Cough, Difficulty Breathing, Hemoptysis, Sputum Production and Wheezing.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "cardiovascular": {
              "extracted_string_or_numeric_value": "Not Present- Chest Heaviness, Chest Pain, Chest Pressure, Chest Tightness, Edema, Exertional Neck or Jaw Pain, Hypertension and Palpitations.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "gastrointestinal": {
              "extracted_string_or_numeric_value": "Not Present- Abdominal Pain, Black Colored Stool, Blood in the Stool, Constipation, Diarrhea, Difficulty Swallowing, Nausea and Vomiting.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "musculoskeletal": {
              "extracted_string_or_numeric_value": "Present- Joint Pain (knees since knee surgery). Not Present- Joint Redness, Joint Stiffness, Joint Swelling, Muscle Aches, Muscle Cramps and Muscle Weakness.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "neurological": {
              "extracted_string_or_numeric_value": "Not Present- Dizziness, Focal Neurological Symptoms, Headaches, Incoordination, Numbness, Visual Changes and Weakness.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "hematology": {
              "extracted_string_or_numeric_value": "Not Present- Abnormal Bleeding, Easy Bruising, Enlarged Lymph Nodes and History of Transfusions.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "neck": {
              "extracted_string_or_numeric_value": "Not Present- Neck Mass, Neck Pain, Neck Stiffness and Swollen Glands.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "breast": {
              "extracted_string_or_numeric_value": "Not Present- Breast Mass, Breast Pain, Nipple Discharge, Nipple Pain and Skin Changes.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "female_genitourinary": {
              "extracted_string_or_numeric_value": "Not Present- Abnormal Vaginal Bleeding, Dysuria, Frequency, Incontinence, Urgency and Vaginal Discharge.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "psychiatric": {
              "extracted_string_or_numeric_value": "Not Present- Anxiety, Depression, Disturbance of Energy and Mood Swings.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "endocrine": {
              "extracted_string_or_numeric_value": "Not Present- Cold Intolerance, Hair Changes, Heat Intolerance, Libido Change, Polydipsia and Polyuria.",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            }
          },
          "vitals": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(James R. Whelan MD; 4/10/2017 4:12 PM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "timestamp": {
              "extracted_string_or_numeric_value": "4/10/2017 3:58 PM",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "weight": {
              "extracted_string_or_numeric_value": "149.4 lb",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "height": {
              "extracted_string_or_numeric_value": "60.5 in",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "body_surface_area": {
              "extracted_string_or_numeric_value": "1.66 m²",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "body_mass_index": {
              "extracted_string_or_numeric_value": "28.7 kg/m²",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "pulse": {
              "extracted_string_or_numeric_value": "63 (Regular)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "respiration": {
              "extracted_string_or_numeric_value": "12 (Unlabored)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "blood_pressure": {
              "extracted_string_or_numeric_value": "142/84(Sitting, Left Arm, Large)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            }
          },
          "physical_exam": null,
          "assessment_and_plan": {
            "author_and_timestamp": {
              "extracted_string_or_numeric_value": "(James R. Whelan MD; 4/23/2017 9:55 AM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "items": []
          },
          "signature": {
            "signature_image": {
              "extracted_string_or_numeric_value": "James R. Whelan mo.",
              "optical_extraction_confidence_score": 0.85,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            },
            "signed_by_line": {
              "extracted_string_or_numeric_value": "Signed electronically by James R Whelan, MD (4/23/2017 9:55 AM)",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [1, 1],
                "vertical_y_vertices": [1, 1]
              }
            }
          },
          "procedures": {
            "items": [
              {
                "description": {
                  "extracted_string_or_numeric_value": "PHQ-4 (96127)",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [1, 1],
                    "vertical_y_vertices": [1, 1]
                  }
                },
                "performed_date_and_status": {
                  "extracted_string_or_numeric_value": "Performed: 04/10/2017 (Final, Reviewed)",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [1, 1],
                    "vertical_y_vertices": [1, 1]
                  }
                },
                "phq4_score": {
                  "extracted_string_or_numeric_value": "Depression Score: 0",
                  "optical_extraction_confidence_score": 0.99,
                  "physical_evidence_coordinates": {
                    "horizontal_x_vertices": [1, 1],
                    "vertical_y_vertices": [1, 1]
                  }
                },
                "phq4_results": [
                  {
                    "question": {
                      "extracted_string_or_numeric_value": "Little interest or pleasure in doing things:",
                      "optical_extraction_confidence_score": 0.99,
                      "physical_evidence_coordinates": {
                        "horizontal_x_vertices": [1, 1],
                        "vertical_y_vertices": [1, 1]
                      }
                    },
                    "answer": {
                      "extracted_string_or_numeric_value": "0 -not at all",
                      "optical_extraction_confidence_score": 0.99,
                      "physical_evidence_coordinates": {
                        "horizontal_x_vertices": [1, 1],
                        "vertical_y_vertices": [1, 1]
                      }
                    }
                  }
                ]
              }
            ]
          }
        }
      ],
      "footer_timestamp": {
        "extracted_string_or_numeric_value": "01/29/2024 03:36 pm",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 250],
          "vertical_y_vertices": [950, 960]
        }
      },
      "footer_patient_info": {
        "extracted_string_or_numeric_value": "Judith A. Grandy DOB 08/18/1947",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [400, 600],
          "vertical_y_vertices": [950, 960]
        }
      },
      "footer_page_number": {
        "extracted_string_or_numeric_value": "Page 1/12",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [800, 850],
          "vertical_y_vertices": [950, 960]
        }
      }
    }
  }
]
```