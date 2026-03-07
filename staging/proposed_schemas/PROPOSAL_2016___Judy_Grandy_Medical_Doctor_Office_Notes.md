An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided medical records for Judith A. Grandy. The documents, while representing a single class, exhibit structural variations typical of evolving electronic health record systems. For instance, the `Diagnostic Studies History` section is present in the March encounter but absent in the October one, and the level of detail in the `Physical Exam` varies between visits.

To create a resilient schema, I have identified a superset of all possible fields across the provided documents. Fields not present in every document, such as `impairments` or `diagnostic_studies_history`, are typed as `Optional`. The schema is designed to be robust, accommodating these structural drifts by nesting data into logical Pydantic models, ensuring that all data points are captured without sacrificing type safety or structural integrity. The resulting schema can reliably parse both encounters and is prepared for future variations.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional, Dict
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Diagnosis(BaseModel):
    model_config = ConfigDict(extra='forbid')
    condition: ForensicDataEntity
    code: Optional[ForensicDataEntity] = None

class EncounterSummaryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_date: ForensicDataEntity
    diagnoses: List[Diagnosis]

class PatientDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    location: ForensicDataEntity
    patient_id: ForensicDataEntity
    marital_status: ForensicDataEntity
    language: ForensicDataEntity
    race: ForensicDataEntity
    gender: ForensicDataEntity

class ChartReviewNote(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider: ForensicDataEntity
    timestamp: ForensicDataEntity
    note: ForensicDataEntity

class Allergy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    substance: ForensicDataEntity
    reaction: Optional[ForensicDataEntity] = None
    date_recorded: Optional[ForensicDataEntity] = None

class SocialHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    health_literacy_assessed: Optional[ForensicDataEntity] = None
    second_hand_smoke_exposure: ForensicDataEntity
    work_status: ForensicDataEntity
    tobacco_use: ForensicDataEntity
    drug_use: ForensicDataEntity
    caffeine_use: ForensicDataEntity
    alcohol_use: ForensicDataEntity
    marital_status: ForensicDataEntity

class Medication(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    dosage: ForensicDataEntity
    instructions: ForensicDataEntity
    start_date: Optional[ForensicDataEntity] = None
    status: ForensicDataEntity

class SurgicalHistoryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    procedure_name: ForensicDataEntity
    location_or_side: Optional[ForensicDataEntity] = None
    year: Optional[ForensicDataEntity] = None

class DiagnosticStudy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    study_name: ForensicDataEntity
    date: ForensicDataEntity
    result: ForensicDataEntity

class HealthMaintenanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    item_name: ForensicDataEntity
    date: ForensicDataEntity
    result_or_notes: ForensicDataEntity

class FamilyMemberHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    relation: ForensicDataEntity
    status: ForensicDataEntity
    age_at_death: Optional[ForensicDataEntity] = None
    conditions: Optional[List[ForensicDataEntity]] = None

class Impairment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    type: ForensicDataEntity
    date: ForensicDataEntity
    details: ForensicDataEntity

class SystemReview(BaseModel):
    model_config = ConfigDict(extra='forbid')
    system: ForensicDataEntity
    present_symptoms: Optional[List[ForensicDataEntity]] = None
    absent_symptoms: Optional[List[ForensicDataEntity]] = None
    notes: Optional[ForensicDataEntity] = None

class Vitals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    timestamp: ForensicDataEntity
    weight: ForensicDataEntity
    height: ForensicDataEntity
    body_surface_area: Optional[ForensicDataEntity] = None
    body_mass_index: ForensicDataEntity
    pulse: ForensicDataEntity
    respiration: ForensicDataEntity
    blood_pressure: ForensicDataEntity

class PhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    general: Optional[ForensicDataEntity] = None
    integumentary: Optional[ForensicDataEntity] = None
    head_and_neck: Optional[ForensicDataEntity] = None
    eye: Optional[ForensicDataEntity] = None
    enmt: Optional[ForensicDataEntity] = None
    chest_and_lung: Optional[ForensicDataEntity] = None
    breast: Optional[ForensicDataEntity] = None
    cardiovascular: Optional[ForensicDataEntity] = None
    abdomen: Optional[ForensicDataEntity] = None
    female_genitourinary: Optional[ForensicDataEntity] = None
    rectal: Optional[ForensicDataEntity] = None
    peripheral_vascular: Optional[ForensicDataEntity] = None
    neurologic: Optional[ForensicDataEntity] = None
    neuropsychiatric: Optional[ForensicDataEntity] = None
    musculoskeletal: Optional[ForensicDataEntity] = None
    lymphatic: Optional[ForensicDataEntity] = None

class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis: ForensicDataEntity
    impression: Optional[ForensicDataEntity] = None
    current_plans: Optional[List[ForensicDataEntity]] = None
    future_plans: Optional[List[ForensicDataEntity]] = None

class Procedure(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    code: Optional[ForensicDataEntity] = None
    date_performed: ForensicDataEntity
    status: ForensicDataEntity

class Signature(BaseModel):
    model_config = ConfigDict(extra='forbid')
    signer_name: ForensicDataEntity
    signer_title: ForensicDataEntity
    timestamp: ForensicDataEntity

class DetailedEncounter(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_number: Optional[ForensicDataEntity] = None
    report_type: ForensicDataEntity
    visit_date: ForensicDataEntity
    visit_type: ForensicDataEntity
    visit_diagnoses: List[Diagnosis]
    provider: ForensicDataEntity
    patient_details: PatientDetails
    history_of_present_illness: Optional[ForensicDataEntity] = None
    chart_review_notes: Optional[List[ChartReviewNote]] = None
    problem_list: Optional[List[Diagnosis]] = None
    allergies: Optional[List[Allergy]] = None
    social_history: Optional[SocialHistory] = None
    medication_history: Optional[List[Medication]] = None
    past_surgical_history: Optional[List[SurgicalHistoryItem]] = None
    diagnostic_studies_history: Optional[List[DiagnosticStudy]] = None
    health_maintenance_history: Optional[List[HealthMaintenanceItem]] = None
    family_history: Optional[List[FamilyMemberHistory]] = None
    impairments: Optional[List[Impairment]] = None
    review_of_systems: Optional[List[SystemReview]] = None
    vitals: Optional[Vitals] = None
    physical_exam: Optional[PhysicalExam] = None
    assessment_and_plan: Optional[List[AssessmentPlanItem]] = None
    procedures: Optional[List[Procedure]] = None
    signatures: Optional[List[Signature]] = None

class MedicalDoctorOfficeNotes(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    chart_date_range: ForensicDataEntity
    encounters_summary: Optional[List[EncounterSummaryItem]] = None
    detailed_encounters: List[DetailedEncounter]

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'MedicalDoctorOfficeNotes':
        """
        Performs double-entry GAAP-style mathematical checksums.
        This document class does not contain financial data (e.g., charges, payments, adjustments).
        Therefore, no checksums are applicable or performed.
        """
        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "complex_encounter_with_optional_fields",
    "should_pass": true,
    "taxonomy_lane": "MedicalDoctorOfficeNotes",
    "binary_header_simulation": "25504446",
    "payload": {
      "patient_name": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [434, 564, 564, 434], "vertical_y_vertices": [145, 145, 156, 156] }
      },
      "date_of_birth": {
        "extracted_string_or_numeric_value": "08/18/1947",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [465, 534, 534, 465], "vertical_y_vertices": [160, 160, 170, 170] }
      },
      "chart_date_range": {
        "extracted_string_or_numeric_value": "From 01/01/2016 to 12/31/2016",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [421, 578, 578, 421], "vertical_y_vertices": [185, 185, 195, 195] }
      },
      "encounters_summary": [
        {
          "encounter_date": {
            "extracted_string_or_numeric_value": "10/04/2016",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [225, 285, 285, 225], "vertical_y_vertices": [90, 90, 100, 100] }
          },
          "diagnoses": [
            {
              "condition": { "extracted_string_or_numeric_value": "BILATERAL PLANTAR FASCIITIS", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [105, 115] } },
              "code": { "extracted_string_or_numeric_value": "M72.2", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [355, 395], "vertical_y_vertices": [105, 115] } }
            }
          ]
        }
      ],
      "detailed_encounters": [
        {
          "encounter_number": {
            "extracted_string_or_numeric_value": "2",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [50, 60] }
          },
          "report_type": {
            "extracted_string_or_numeric_value": "History & Physical Report",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [65, 75] }
          },
          "visit_date": {
            "extracted_string_or_numeric_value": "10/4/2016",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [80, 90] }
          },
          "visit_type": {
            "extracted_string_or_numeric_value": "Office Visit",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [95, 105] }
          },
          "visit_diagnoses": [
            {
              "condition": { "extracted_string_or_numeric_value": "OSTEOPENIA", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [110, 120] } },
              "code": { "extracted_string_or_numeric_value": "M85.80", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [255, 305], "vertical_y_vertices": [110, 120] } }
            }
          ],
          "provider": {
            "extracted_string_or_numeric_value": "RYAN A. STRAIGHT, PA-C",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [125, 135] }
          },
          "patient_details": {
            "location": { "extracted_string_or_numeric_value": "Cadillac Family Physicians", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [140, 150] } },
            "patient_id": { "extracted_string_or_numeric_value": "28641", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [155, 165] } },
            "marital_status": { "extracted_string_or_numeric_value": "Married", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [170, 180] } },
            "language": { "extracted_string_or_numeric_value": "English", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [205, 255], "vertical_y_vertices": [170, 180] } },
            "race": { "extracted_string_or_numeric_value": "White", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [260, 300], "vertical_y_vertices": [170, 180] } },
            "gender": { "extracted_string_or_numeric_value": "Female", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [185, 195] } }
          },
          "history_of_present_illness": {
            "extracted_string_or_numeric_value": "The patient is a 69 year old female who presents with a complaint of Chronic condition(s)..",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [200, 250] }
          },
          "chart_review_notes": [
            {
              "provider": { "extracted_string_or_numeric_value": "LEBARON, TANIA M MD", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [255, 265] } },
              "timestamp": { "extracted_string_or_numeric_value": "10/4/2016 2:03 PM", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [355, 505], "vertical_y_vertices": [255, 265] } },
              "note": { "extracted_string_or_numeric_value": "I have reviewed the history of present illness and findings.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [270, 280] } }
            }
          ],
          "problem_list": [
            {
              "condition": { "extracted_string_or_numeric_value": "BREAST CANCER", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [285, 295] } },
              "code": { "extracted_string_or_numeric_value": "C50.919", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [255, 305], "vertical_y_vertices": [285, 295] } }
            }
          ],
          "allergies": [
            {
              "substance": { "extracted_string_or_numeric_value": "Latex", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [300, 310] } },
              "reaction": { "extracted_string_or_numeric_value": "SENSITIVE", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [205, 285], "vertical_y_vertices": [300, 310] } }
            }
          ],
          "social_history": {
            "tobacco_use": { "extracted_string_or_numeric_value": "Never smoker.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [315, 325] } },
            "work_status": { "extracted_string_or_numeric_value": "Retired from Business", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [330, 340] } },
            "second_hand_smoke_exposure": { "extracted_string_or_numeric_value": "None", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [345, 355] } },
            "drug_use": { "extracted_string_or_numeric_value": "No Drug Use", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [360, 370] } },
            "caffeine_use": { "extracted_string_or_numeric_value": "1-2 cup of coffee and 1 cup of tea qd", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 450], "vertical_y_vertices": [375, 385] } },
            "alcohol_use": { "extracted_string_or_numeric_value": "Occasional alcohol use. 1 glass of wine couple times weekly", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 600], "vertical_y_vertices": [390, 400] } },
            "marital_status": { "extracted_string_or_numeric_value": "Married.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 220], "vertical_y_vertices": [405, 415] } }
          },
          "medication_history": [
            {
              "name": { "extracted_string_or_numeric_value": "Atorvastatin Calcium", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [420, 430] } },
              "dosage": { "extracted_string_or_numeric_value": "10MG Tablet", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [305, 405], "vertical_y_vertices": [420, 430] } },
              "instructions": { "extracted_string_or_numeric_value": "1 (one) Oral daily", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 550], "vertical_y_vertices": [420, 430] } },
              "start_date": { "extracted_string_or_numeric_value": "Taken starting 03/29/2016", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [555, 755], "vertical_y_vertices": [420, 430] } },
              "status": { "extracted_string_or_numeric_value": "Active", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [760, 810], "vertical_y_vertices": [420, 430] } }
            }
          ],
          "past_surgical_history": [
            {
              "procedure_name": { "extracted_string_or_numeric_value": "SIMPLE MASTECTOMY", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [435, 445] } },
              "location_or_side": { "extracted_string_or_numeric_value": "RIGHT", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [305, 355], "vertical_y_vertices": [435, 445] } },
              "year": { "extracted_string_or_numeric_value": "1989", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 400], "vertical_y_vertices": [435, 445] } }
            }
          ],
          "diagnostic_studies_history": [
            {
              "study_name": { "extracted_string_or_numeric_value": "Left Mammogram", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 280], "vertical_y_vertices": [450, 460] } },
              "date": { "extracted_string_or_numeric_value": "10/24/2014", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [285, 365], "vertical_y_vertices": [450, 460] } },
              "result": { "extracted_string_or_numeric_value": "Negative.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [370, 450], "vertical_y_vertices": [450, 460] } }
            }
          ],
          "health_maintenance_history": [
            {
              "item_name": { "extracted_string_or_numeric_value": "Bone Density Study", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [465, 475] } },
              "date": { "extracted_string_or_numeric_value": "07/10/2007", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [305, 385], "vertical_y_vertices": [465, 475] } },
              "result_or_notes": { "extracted_string_or_numeric_value": "Osteopenia", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 480], "vertical_y_vertices": [465, 475] } }
            }
          ],
          "family_history": [
            {
              "relation": { "extracted_string_or_numeric_value": "Mother", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [480, 490] } },
              "status": { "extracted_string_or_numeric_value": "Deceased", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [205, 285], "vertical_y_vertices": [480, 490] } },
              "age_at_death": { "extracted_string_or_numeric_value": "at age 65", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 360], "vertical_y_vertices": [480, 490] } },
              "conditions": [
                { "extracted_string_or_numeric_value": "Breast Cancer", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [365, 485], "vertical_y_vertices": [480, 490] } }
              ]
            }
          ],
          "impairments": [
            {
              "type": { "extracted_string_or_numeric_value": "VISION", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 200], "vertical_y_vertices": [495, 505] } },
              "date": { "extracted_string_or_numeric_value": "10/04/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [205, 285], "vertical_y_vertices": [495, 505] } },
              "details": { "extracted_string_or_numeric_value": "Glasses. Reading", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 420], "vertical_y_vertices": [495, 505] } }
            }
          ],
          "vitals": {
            "timestamp": { "extracted_string_or_numeric_value": "10/4/2016 12:58 PM", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300], "vertical_y_vertices": [510, 520] } },
            "weight": { "extracted_string_or_numeric_value": "154.6 lb", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 220], "vertical_y_vertices": [525, 535] } },
            "height": { "extracted_string_or_numeric_value": "60.5 in", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [225, 295], "vertical_y_vertices": [525, 535] } },
            "body_mass_index": { "extracted_string_or_numeric_value": "29.7 kg/m²", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [540, 550] } },
            "pulse": { "extracted_string_or_numeric_value": "64 (Regular)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 250], "vertical_y_vertices": [555, 565] } },
            "respiration": { "extracted_string_or_numeric_value": "16 (Unlabored)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [255, 385], "vertical_y_vertices": [555, 565] } },
            "blood_pressure": { "extracted_string_or_numeric_value": "128/84(Sitting, Left Arm, Large)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 400], "vertical_y_vertices": [570, 580] } }
          },
          "assessment_and_plan": [
            {
              "diagnosis": { "extracted_string_or_numeric_value": "SUBCLINICAL HYPOTHYROIDISM (E03.9)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 450], "vertical_y_vertices": [585, 595] } },
              "impression": { "extracted_string_or_numeric_value": "TSH elevated. Patient declines treatment at this time. Will monitor for new symptoms and monitor labs.", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [600, 610] } },
              "future_plans": [
                { "extracted_string_or_numeric_value": "1/4/2017: *TSH (THYROID STIMULATING HORMONE) (84443) - one time", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [615, 625] } }
              ]
            }
          ],
          "procedures": [
            {
              "name": { "extracted_string_or_numeric_value": "ADMINISTRATION OF INFLUENZA VIRUS VACCINE", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 550], "vertical_y_vertices": [630, 640] } },
              "code": { "extracted_string_or_numeric_value": "G0008", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [555, 605], "vertical_y_vertices": [630, 640] } },
              "date_performed": { "extracted_string_or_numeric_value": "10/04/2016", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 690], "vertical_y_vertices": [630, 640] } },
              "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [695, 805], "vertical_y_vertices": [630, 640] } }
            }
          ],
          "signatures": [
            {
              "signer_name": { "extracted_string_or_numeric_value": "TANIA M LEBARON", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 350], "vertical_y_vertices": [645, 655] } },
              "signer_title": { "extracted_string_or_numeric_value": "MD", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [355, 385], "vertical_y_vertices": [645, 655] } },
              "timestamp": { "extracted_string_or_numeric_value": "10/4/2016 2:04 PM", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [390, 540], "vertical_y_vertices": [645, 655] } }
            }
          ]
        }
      ]
    }
  }
]
```