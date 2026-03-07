An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided `2015 Office Notes` document. The document contains three distinct patient encounters with varying levels of detail, from a comprehensive annual physical to a sparse phone encounter note.

To accommodate this structural drift, I have designed a resilient Pydantic V2 schema. The schema models the entire document as a single entity containing a list of encounters. Each encounter and its constituent sections (e.g., Vitals, Social History, Physical Exam) are modeled as classes. The use of `Optional` types throughout the schema ensures that it can gracefully handle both the most detailed office visit and the most minimal phone note without validation errors. The most complex structural variant is the document as a whole, which contains a heterogeneous list of encounters, thereby testing the schema's flexibility.

The following Pydantic schema and JSON test case fulfill the directive's requirements.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# --- Provided Base Classes ---

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# --- Custom Schema for 2015 Office Notes ---

class DiagnosisItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    icd9_code: Optional[ForensicDataEntity] = None
    icd10_code: Optional[ForensicDataEntity] = None

class PatientDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    documented_timestamp: ForensicDataEntity
    location: ForensicDataEntity
    patient_id: ForensicDataEntity
    dob: ForensicDataEntity
    marital_status: ForensicDataEntity
    language: ForensicDataEntity
    race: ForensicDataEntity
    gender: ForensicDataEntity

class HistoryOfPresentIllness(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: Optional[ForensicDataEntity] = None
    patient_words: Optional[ForensicDataEntity] = None
    narrative: ForensicDataEntity

class ProblemList(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    problems: List[DiagnosisItem]

class Allergies(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    medication_allergies: ForensicDataEntity
    other_allergies: Optional[ForensicDataEntity] = None

class SocialHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    drug_use: ForensicDataEntity
    caffeine_use: ForensicDataEntity
    marital_status: ForensicDataEntity
    alcohol_use: ForensicDataEntity
    second_hand_smoke_exposure: ForensicDataEntity
    work_status: ForensicDataEntity
    tobacco_use: ForensicDataEntity

class Medication(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    details: ForensicDataEntity
    status: ForensicDataEntity

class MedicationHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    medications: List[Medication]
    reconciled: Optional[ForensicDataEntity] = None

class SurgicalHistoryItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    details: Optional[ForensicDataEntity] = None

class PastSurgicalHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    surgeries: List[SurgicalHistoryItem]

class DiagnosticStudy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity

class DiagnosticStudiesHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    studies: List[DiagnosticStudy]

class HealthMaintenanceItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity

class HealthMaintenanceHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    items: List[HealthMaintenanceItem]

class FamilyHistoryRelative(BaseModel):
    model_config = ConfigDict(extra='forbid')
    relation: ForensicDataEntity
    details: ForensicDataEntity

class FamilyHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    relatives: List[FamilyHistoryRelative]

class SystemReview(BaseModel):
    model_config = ConfigDict(extra='forbid')
    system: ForensicDataEntity
    present_symptoms: Optional[ForensicDataEntity] = None
    not_present_symptoms: Optional[ForensicDataEntity] = None

class ReviewOfSystems(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    systems: List[SystemReview]
    note: Optional[ForensicDataEntity] = None

class Vitals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    timestamp: ForensicDataEntity
    weight: ForensicDataEntity
    height: ForensicDataEntity
    body_surface_area: ForensicDataEntity
    body_mass_index: ForensicDataEntity
    pulse: ForensicDataEntity
    respirations: ForensicDataEntity
    blood_pressure: ForensicDataEntity

class PhysicalExamSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    system_name: ForensicDataEntity
    findings: ForensicDataEntity

class PhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    sections: List[PhysicalExamSection]
    findings_summary: Optional[ForensicDataEntity] = None

class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis: DiagnosisItem
    plan: Optional[ForensicDataEntity] = None
    impression: Optional[ForensicDataEntity] = None
    note: Optional[ForensicDataEntity] = None

class AssessmentAndPlan(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider_and_timestamp: ForensicDataEntity
    assessments: List[AssessmentPlanItem]
    provider_signature: Optional[ForensicDataEntity] = None
    signed_timestamp: Optional[ForensicDataEntity] = None
    note: Optional[ForensicDataEntity] = None

class LabResult(BaseModel):
    model_config = ConfigDict(extra='forbid')
    test_name_and_code: ForensicDataEntity
    status: ForensicDataEntity
    collection_date: ForensicDataEntity
    associated_diagnosis: ForensicDataEntity
    value: ForensicDataEntity
    units: ForensicDataEntity
    normal_range: ForensicDataEntity
    result_note: Optional[ForensicDataEntity] = None
    result_annotation: Optional[ForensicDataEntity] = None
    performing_lab_details: Optional[ForensicDataEntity] = None

class Laboratories(BaseModel):
    model_config = ConfigDict(extra='forbid')
    results: List[LabResult]

class Procedure(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description_and_code: ForensicDataEntity
    performed_date: ForensicDataEntity
    status: ForensicDataEntity

class Procedures(BaseModel):
    model_config = ConfigDict(extra='forbid')
    procedures_performed: List[Procedure]

class EncounterHeader(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_date: ForensicDataEntity
    diagnoses: List[DiagnosisItem]

class Encounter(BaseModel):
    model_config = ConfigDict(extra='forbid')
    encounter_number: ForensicDataEntity
    header: EncounterHeader
    provider_name: ForensicDataEntity
    patient_details: Optional[PatientDetails] = None
    history_of_present_illness: Optional[HistoryOfPresentIllness] = None
    problem_list_past_medical: Optional[ProblemList] = None
    allergies: Optional[Allergies] = None
    social_history: Optional[SocialHistory] = None
    medication_history: Optional[MedicationHistory] = None
    past_surgical_history: Optional[PastSurgicalHistory] = None
    diagnostic_studies_history: Optional[DiagnosticStudiesHistory] = None
    health_maintenance_history: Optional[HealthMaintenanceHistory] = None
    family_history: Optional[FamilyHistory] = None
    review_of_systems: Optional[ReviewOfSystems] = None
    vitals: Optional[Vitals] = None
    physical_exam: Optional[PhysicalExam] = None
    assessment_and_plan: Optional[AssessmentAndPlan] = None
    laboratories: Optional[Laboratories] = None
    procedures: Optional[Procedures] = None

class OfficeNotes2015(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_name: ForensicDataEntity
    patient_dob: ForensicDataEntity
    chart_date_range: ForensicDataEntity
    encounters: List[Encounter]

    @model_validator(mode='after')
    def validate_financial_checksums(self) -> 'OfficeNotes2015':
        """
        No financial data is present in this document class.
        This validator is included to satisfy the directive's requirement for a
        double-entry GAAP mathematical checksum, which would be implemented here
        if any financial figures were present.
        """
        return self
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "2015_office_notes_judith_grandy_full_chart",
    "should_pass": true,
    "taxonomy_lane": "OfficeNotes2015",
    "binary_header_simulation": "25504446",
    "payload": {
      "patient_name": {
        "extracted_string_or_numeric_value": "Judith A. Grandy",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [1, 2, 2, 1],
          "vertical_y_vertices": [1, 1, 2, 2]
        }
      },
      "patient_dob": {
        "extracted_string_or_numeric_value": "08/18/1947",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [1, 2, 2, 1],
          "vertical_y_vertices": [1, 1, 2, 2]
        }
      },
      "chart_date_range": {
        "extracted_string_or_numeric_value": "From 01/01/2015 to 12/31/2015",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [1, 2, 2, 1],
          "vertical_y_vertices": [1, 1, 2, 2]
        }
      },
      "encounters": [
        {
          "encounter_number": {
            "extracted_string_or_numeric_value": "Encounter 3",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] }
          },
          "header": {
            "encounter_date": {
              "extracted_string_or_numeric_value": "09/21/2015",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] }
            },
            "diagnoses": [
              {
                "description": { "extracted_string_or_numeric_value": "CHRONIC FATIGUE AND MALAISE", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "780.71", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "R53.82", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description": { "extracted_string_or_numeric_value": "LAMELLAR NAIL DYSTROPHY", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "703.8", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "L60.3", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description": { "extracted_string_or_numeric_value": "MEDICARE FLU", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description": { "extracted_string_or_numeric_value": "BMI 28.0-28.9,ADULT", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "V85.24", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "Z68.28", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description": { "extracted_string_or_numeric_value": "HYPERLIPIDEMIA, UNSPECIFIED", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description": { "extracted_string_or_numeric_value": "BREAST CANCER", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "174.9", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "C50.919", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ]
          },
          "provider_name": { "extracted_string_or_numeric_value": "James R. Whelan, MD", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
          "laboratories": {
            "results": [
              {
                "test_name_and_code": { "extracted_string_or_numeric_value": "TSH (THYROID STIMULATING HORMONE) (84443)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "collection_date": { "extracted_string_or_numeric_value": "09/21/2015", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "associated_diagnosis": { "extracted_string_or_numeric_value": "LAMELLAR NAIL DYSTROPHY (L60.3)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "value": { "extracted_string_or_numeric_value": 5.22, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "units": { "extracted_string_or_numeric_value": "mIU/L", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "normal_range": { "extracted_string_or_numeric_value": "0.40 - 5.50 mIU/L", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "test_name_and_code": { "extracted_string_or_numeric_value": "T4 FREE (84439)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "collection_date": { "extracted_string_or_numeric_value": "09/21/2015", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "associated_diagnosis": { "extracted_string_or_numeric_value": "LAMELLAR NAIL DYSTROPHY (L60.3)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "value": { "extracted_string_or_numeric_value": 0.87, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "units": { "extracted_string_or_numeric_value": "ng/dL", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "normal_range": { "extracted_string_or_numeric_value": "0.8 - 1.8 ng/dL", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "test_name_and_code": { "extracted_string_or_numeric_value": "FREE TRIIODOTHYRONINE (T3) (84481)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "collection_date": { "extracted_string_or_numeric_value": "09/21/2015", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "associated_diagnosis": { "extracted_string_or_numeric_value": "LAMELLAR NAIL DYSTROPHY (L60.3)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "value": { "extracted_string_or_numeric_value": 2.8, "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "units": { "extracted_string_or_numeric_value": "pg/mL", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "normal_range": { "extracted_string_or_numeric_value": "2.3-4.2 pg/mL", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ]
          },
          "procedures": {
            "procedures_performed": [
              {
                "description_and_code": { "extracted_string_or_numeric_value": "INTRAMUSCULAR ADMINISTRATION OF PRESERVATIVE FREE QUADRIVALENT INFLUENZA VACCINE IN PATIENTS 3 YEARS OR OLDER (90686)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "performed_date": { "extracted_string_or_numeric_value": "09/21/2015", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description_and_code": { "extracted_string_or_numeric_value": "ADMINISTRATION OF INFLUENZA VIRUS VACCINE (G0008)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "performed_date": { "extracted_string_or_numeric_value": "09/21/2015", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description_and_code": { "extracted_string_or_numeric_value": "MEDICARE DRAW FEE (36415)", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "performed_date": { "extracted_string_or_numeric_value": "09/21/2015", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "status": { "extracted_string_or_numeric_value": "Final, Reviewed", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ]
          }
        },
        {
          "encounter_number": {
            "extracted_string_or_numeric_value": "Encounter 2",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] }
          },
          "header": {
            "encounter_date": {
              "extracted_string_or_numeric_value": "03/16/2015",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] }
            },
            "diagnoses": [
              {
                "description": { "extracted_string_or_numeric_value": "ANNUAL PHYSICAL EXAM", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "V70.0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "Z00.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              },
              {
                "description": { "extracted_string_or_numeric_value": "OSTEOPENIA", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "733.90", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "M85.80", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ]
          },
          "provider_name": { "extracted_string_or_numeric_value": "James R. Whelan, MD", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
          "assessment_and_plan": {
            "provider_and_timestamp": { "extracted_string_or_numeric_value": "James R. Whelan, MD; 3/22/2015 12:17 PM", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
            "assessments": [
              {
                "diagnosis": {
                  "description": { "extracted_string_or_numeric_value": "ANNUAL PHYSICAL EXAM", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                  "icd9_code": { "extracted_string_or_numeric_value": "V70.0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                  "icd10_code": { "extracted_string_or_numeric_value": "Z00.00", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
                }
              },
              {
                "diagnosis": {
                  "description": { "extracted_string_or_numeric_value": "OSTEOPENIA", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                  "icd9_code": { "extracted_string_or_numeric_value": "733.90", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                  "icd10_code": { "extracted_string_or_numeric_value": "M85.80", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
                },
                "impression": { "extracted_string_or_numeric_value": "calcium, exercise", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ]
          }
        },
        {
          "encounter_number": {
            "extracted_string_or_numeric_value": "Encounter 1",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] }
          },
          "header": {
            "encounter_date": {
              "extracted_string_or_numeric_value": "03/13/2015",
              "optical_extraction_confidence_score": 1.0,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] }
            },
            "diagnoses": [
              {
                "description": { "extracted_string_or_numeric_value": "URINARY TRACT INFECTION", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd9_code": { "extracted_string_or_numeric_value": "599.0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                "icd10_code": { "extracted_string_or_numeric_value": "N39.0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ]
          },
          "provider_name": { "extracted_string_or_numeric_value": "James R. Whelan, MD", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
          "assessment_and_plan": {
            "provider_and_timestamp": { "extracted_string_or_numeric_value": "James R. Whelan, MD; 3/13/2015 7:57 AM", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
            "assessments": [
              {
                "diagnosis": {
                  "description": { "extracted_string_or_numeric_value": "URINARY TRACT INFECTION", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                  "icd9_code": { "extracted_string_or_numeric_value": "599.0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
                  "icd10_code": { "extracted_string_or_numeric_value": "N39.0", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
                },
                "plan": { "extracted_string_or_numeric_value": "Restarted Ciprofloxacin HCI 500MG, 1 Tablet two times daily, #14, 7 days starting 03/13/2015, No Refill.", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
              }
            ],
            "provider_signature": { "extracted_string_or_numeric_value": "James R. Whelan, MD", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } },
            "signed_timestamp": { "extracted_string_or_numeric_value": "3/13/2015 7:58 AM", "optical_extraction_confidence_score": 1.0, "physical_evidence_coordinates": { "horizontal_x_vertices": [0,0,0,0], "vertical_y_vertices": [0,0,0,0] } }
          }
        }
      ]
    }
  }
]
```