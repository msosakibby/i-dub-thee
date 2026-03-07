An expert forensic data architect operating under a Zero-Trust mandate, I have meticulously analyzed the provided document. The following Pydantic V2 schema and corresponding JSON test case are designed for maximum structural resilience and data integrity, adhering strictly to the specified directives.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Union, Optional
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
    patient_number: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    age: ForensicDataEntity

class HistoryOfPresentIllness(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    patient_words: ForensicDataEntity
    narrative: ForensicDataEntity

class Allergies(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    medication_allergies: ForensicDataEntity
    other_allergies: ForensicDataEntity

class SocialHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    tobacco_use: ForensicDataEntity

class Medication(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    details: ForensicDataEntity
    status: ForensicDataEntity
    notes: Optional[ForensicDataEntity] = None

class HealthMaintenance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    fall_risk_screening: ForensicDataEntity

class ReviewOfSystems(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    skin: ForensicDataEntity
    psychiatric: ForensicDataEntity

class Vitals(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    vitals_timestamp: ForensicDataEntity
    weight: ForensicDataEntity
    height: ForensicDataEntity
    body_surface_area: ForensicDataEntity
    body_mass_index: ForensicDataEntity
    pulse: ForensicDataEntity
    respiration: ForensicDataEntity
    blood_pressure: ForensicDataEntity

class GeneralExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    mental_status: ForensicDataEntity
    general_appearance: ForensicDataEntity
    build_and_nutrition: ForensicDataEntity
    hydration: ForensicDataEntity

class NeurologicExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    affect: ForensicDataEntity
    speech: ForensicDataEntity
    thought_content_perception: ForensicDataEntity
    cognitive_function: ForensicDataEntity
    sensory: ForensicDataEntity
    motor: ForensicDataEntity

class PhysicalExam(BaseModel):
    model_config = ConfigDict(extra='forbid')
    author: ForensicDataEntity
    timestamp: ForensicDataEntity
    general: GeneralExam
    neurologic: NeurologicExam

class AssessmentPlanItem(BaseModel):
    model_config = ConfigDict(extra='forbid')
    diagnosis_name_and_code: ForensicDataEntity
    problem_story: Optional[ForensicDataEntity] = None
    todays_impression: Optional[ForensicDataEntity] = None
    current_plans: List[ForensicDataEntity]

class Immunization(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date: ForensicDataEntity

class Footer(BaseModel):
    model_config = ConfigDict(extra='forbid')
    patient_name: ForensicDataEntity
    patient_number: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    print_timestamp: ForensicDataEntity
    template_name: ForensicDataEntity
    printed_by: ForensicDataEntity
    page_info: ForensicDataEntity

class OfficeNote142024(BaseModel):
    model_config = ConfigDict(extra='forbid')
    practice_name: ForensicDataEntity
    practice_address: ForensicDataEntity
    practice_phone: ForensicDataEntity
    practice_fax: ForensicDataEntity
    practice_email: Optional[ForensicDataEntity] = None
    contact_phone: ForensicDataEntity
    patient_info: PatientInfo
    encounter_date: ForensicDataEntity
    history_of_present_illness: HistoryOfPresentIllness
    allergies: Allergies
    social_history: SocialHistory
    medication_history: List[Medication]
    health_maintenance: HealthMaintenance
    review_of_systems: ReviewOfSystems
    vitals: Vitals
    physical_exam: PhysicalExam
    assessment_and_plan_author: ForensicDataEntity
    assessment_and_plan_timestamp: ForensicDataEntity
    assessment_and_plan_items: List[AssessmentPlanItem]
    immunizations: List[Immunization]
    signer_name: ForensicDataEntity
    footers: List[Footer]

    @model_validator(mode='after')
    def perform_double_entry_gaap_checksums(self) -> 'OfficeNote142024':
        """
        This medical document does not contain financial data suitable for
        double-entry GAAP checksums (e.g., invoices, debits, credits, totals).
        The validator is included to meet the structural requirements of the directive.
        If financial fields were present, the logic would be implemented here.
        Example:
        if self.invoice_total and self.line_items:
            calculated_total = sum(item.price * item.quantity for item in self.line_items)
            if self.invoice_total.extracted_string_or_numeric_value != calculated_total:
                raise ValueError("Invoice total does not match the sum of line items.")
        """
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "20240104_28641_cadillac_family_physicians",
    "should_pass": true,
    "taxonomy_lane": "OfficeNote142024",
    "binary_header_simulation": "25504446",
    "payload": {
      "practice_name": {
        "extracted_string_or_numeric_value": "Cadillac Family Physicians",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [583, 843],
          "vertical_y_vertices": [37, 54]
        }
      },
      "practice_address": {
        "extracted_string_or_numeric_value": "8950 Professional Drive\nCadillac, MI 49601",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [733, 843],
          "vertical_y_vertices": [93, 119]
        }
      },
      "practice_phone": {
        "extracted_string_or_numeric_value": "(231) 775-2493",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [733, 843],
          "vertical_y_vertices": [123, 131]
        }
      },
      "practice_fax": {
        "extracted_string_or_numeric_value": "(231) 779-7701",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [733, 843],
          "vertical_y_vertices": [135, 143]
        }
      },
      "practice_email": {
        "extracted_string_or_numeric_value": "info@cadillacfamilyphysicians.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [653, 843],
          "vertical_y_vertices": [159, 167]
        }
      },
      "contact_phone": {
        "extracted_string_or_numeric_value": "(231) 775-2493",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [710, 843],
          "vertical_y_vertices": [171, 179]
        }
      },
      "patient_info": {
        "patient_name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 253],
            "vertical_y_vertices": [183, 210]
          }
        },
        "patient_number": {
          "extracted_string_or_numeric_value": "28641",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 569],
            "vertical_y_vertices": [373, 383]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "08/18/1947",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [720, 790],
            "vertical_y_vertices": [373, 383]
          }
        },
        "age": {
          "extracted_string_or_numeric_value": "76 years",
          "optical_extraction_confidence_score": 1.0,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [792, 843],
            "vertical_y_vertices": [373, 383]
          }
        }
      },
      "encounter_date": {
        "extracted_string_or_numeric_value": "01/04/2024 01:45 PM",
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [194, 343],
          "vertical_y_vertices": [399, 409]
        }
      },
      "history_of_present_illness": {
        "author": {
          "extracted_string_or_numeric_value": "ANNEL. BROAD, MD",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [360, 510],
            "vertical_y_vertices": [446, 454]
          }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:57 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [513, 623],
            "vertical_y_vertices": [446, 454]
          }
        },
        "patient_words": {
          "extracted_string_or_numeric_value": "Spot noticed on cheek a few days ago, has been feeling anxious and forgetful lately.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 843],
            "vertical_y_vertices": [462, 472]
          }
        },
        "narrative": {
          "extracted_string_or_numeric_value": "The patient is a 76 year old female who presents with a complaint of Chronic condition(s).. The chronic problem is characterized as neurologic disorders (alzheimers) and as noted (anxiety). The chronic condition(s). has been occurring for years. The patient rates the problem as severe. The patient worsening. Current medication use: experiencing side effects (thinks she stopped aricept beccause she though anxiety was worse on it). Note for \"Chronic condition(s).\": has been on edge, nervous, lots of stress going on in life. more forgetful, also has a skin lesion on L cheek, has been dry a long time but now opened up",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 843],
            "vertical_y_vertices": [484, 562]
          }
        }
      },
      "allergies": {
        "author": {
          "extracted_string_or_numeric_value": "Katrina Smaltz, RMA",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [265, 400],
            "vertical_y_vertices": [590, 598]
          }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:35 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [403, 513],
            "vertical_y_vertices": [590, 598]
          }
        },
        "medication_allergies": {
          "extracted_string_or_numeric_value": "NO KNOWN MEDICATION ALLERGIES 09/30/2022",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 513],
            "vertical_y_vertices": [606, 616]
          }
        },
        "other_allergies": {
          "extracted_string_or_numeric_value": "Latex 09/30/2022; SENSITIVE",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 420],
            "vertical_y_vertices": [622, 632]
          }
        }
      },
      "social_history": {
        "author": {
          "extracted_string_or_numeric_value": "Katrina Smaltz, RMA",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [295, 430],
            "vertical_y_vertices": [659, 667]
          }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:35 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [433, 543],
            "vertical_y_vertices": [659, 667]
          }
        },
        "tobacco_use": {
          "extracted_string_or_numeric_value": "Never smoker",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 370],
            "vertical_y_vertices": [675, 685]
          }
        }
      },
      "medication_history": [
        {
          "name": {
            "extracted_string_or_numeric_value": "atorvastatin",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 268], "vertical_y_vertices": [162, 172] }
          },
          "details": {
            "extracted_string_or_numeric_value": "10mg tablet 1 (one) oral daily, Taken starting 07/05/2023",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [271, 660], "vertical_y_vertices": [162, 172] }
          },
          "status": {
            "extracted_string_or_numeric_value": "Active - Hx Entry.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [663, 770], "vertical_y_vertices": [162, 172] }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Loratadine",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 260], "vertical_y_vertices": [184, 194] }
          },
          "details": {
            "extracted_string_or_numeric_value": "10MG tablet 1 Oral daily, Taken starting 06/30/2022",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [263, 610], "vertical_y_vertices": [184, 194] }
          },
          "status": {
            "extracted_string_or_numeric_value": "Active - Hx Entry.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [613, 720], "vertical_y_vertices": [184, 194] }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "levothyroxine",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 278], "vertical_y_vertices": [206, 216] }
          },
          "details": {
            "extracted_string_or_numeric_value": "75mcg tablet 1 (one) oral 5 days per week, Taken starting 05/26/2023",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [281, 700], "vertical_y_vertices": [206, 216] }
          },
          "status": {
            "extracted_string_or_numeric_value": "Active - Hx Entry.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [703, 810], "vertical_y_vertices": [206, 216] }
          },
          "notes": {
            "extracted_string_or_numeric_value": "(Tue-Sat)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 275], "vertical_y_vertices": [218, 228] }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Tylenol Extra Strength",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 340], "vertical_y_vertices": [340, 350] }
          },
          "details": {
            "extracted_string_or_numeric_value": "500MG tablet 2 Oral every six hours, as needed, Taken starting 10/23/2019",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [343, 780], "vertical_y_vertices": [340, 350] }
          },
          "status": {
            "extracted_string_or_numeric_value": "Active - Hx Entry.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [783, 843], "vertical_y_vertices": [340, 350] }
          },
          "notes": {
            "extracted_string_or_numeric_value": "(not to exceed 4000mg daily - DO NOT take with percocet. R. Miller RN, Care Manager)",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 780], "vertical_y_vertices": [352, 362] }
          }
        }
      ],
      "health_maintenance": {
        "author": {
          "extracted_string_or_numeric_value": "Katrina Smaltz, RMA",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 465], "vertical_y_vertices": [500, 508] }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:35 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [468, 578], "vertical_y_vertices": [500, 508] }
        },
        "fall_risk_screening": {
          "extracted_string_or_numeric_value": "No falls during reporting year",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 430], "vertical_y_vertices": [516, 526] }
        }
      },
      "review_of_systems": {
        "author": {
          "extracted_string_or_numeric_value": "ANNEL. BROAD, MD",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 490], "vertical_y_vertices": [553, 561] }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:57 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [493, 603], "vertical_y_vertices": [553, 561] }
        },
        "skin": {
          "extracted_string_or_numeric_value": "Present- Ulcer. Not Present- Pruritus and Rash.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 580], "vertical_y_vertices": [569, 579] }
        },
        "psychiatric": {
          "extracted_string_or_numeric_value": "Present- Anxiety, Disturbance of Energy, Impaired Cognitive Function and Inability to Concentrate. Not Present- Depression.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 843], "vertical_y_vertices": [581, 603] }
        }
      },
      "vitals": {
        "author": {
          "extracted_string_or_numeric_value": "Katrina Smaltz, RMA",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 375], "vertical_y_vertices": [630, 638] }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:36 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [378, 488], "vertical_y_vertices": [630, 638] }
        },
        "vitals_timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:35 PM",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 343], "vertical_y_vertices": [646, 656] }
        },
        "weight": {
          "extracted_string_or_numeric_value": "138 lb, 9.6 oz",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 290], "vertical_y_vertices": [662, 672] }
        },
        "height": {
          "extracted_string_or_numeric_value": "60 in",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 380], "vertical_y_vertices": [662, 672] }
        },
        "body_surface_area": {
          "extracted_string_or_numeric_value": "1.6 m²",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 290], "vertical_y_vertices": [684, 694] }
        },
        "body_mass_index": {
          "extracted_string_or_numeric_value": "27.07 kg/m²",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 450], "vertical_y_vertices": [684, 694] }
        },
        "pulse": {
          "extracted_string_or_numeric_value": "66 (Regular)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 280], "vertical_y_vertices": [706, 716] }
        },
        "respiration": {
          "extracted_string_or_numeric_value": "16 (Unlabored)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 420], "vertical_y_vertices": [706, 716] }
        },
        "blood_pressure": {
          "extracted_string_or_numeric_value": "120/72 Manual (Sitting, Left Arm, Large)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 490], "vertical_y_vertices": [728, 738] }
        }
      },
      "physical_exam": {
        "author": {
          "extracted_string_or_numeric_value": "ANNEL. BROAD, MD",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 460], "vertical_y_vertices": [745, 753] }
        },
        "timestamp": {
          "extracted_string_or_numeric_value": "01/04/2024 01:58 PM",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [463, 573], "vertical_y_vertices": [745, 753] }
        },
        "general": {
          "mental_status": {
            "extracted_string_or_numeric_value": "Alert.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 310], "vertical_y_vertices": [803, 813] }
          },
          "general_appearance": {
            "extracted_string_or_numeric_value": "Cooperative, Well groomed, Not in acute distress.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 580], "vertical_y_vertices": [815, 825] }
          },
          "build_and_nutrition": {
            "extracted_string_or_numeric_value": "Well nourished and Well developed.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 460], "vertical_y_vertices": [827, 837] }
          },
          "hydration": {
            "extracted_string_or_numeric_value": "Well hydrated.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 310], "vertical_y_vertices": [839, 849] }
          }
        },
        "neurologic": {
          "affect": {
            "extracted_string_or_numeric_value": "normal and appropriate.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 420], "vertical_y_vertices": [303, 313] }
          },
          "speech": {
            "extracted_string_or_numeric_value": "Normal.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [425, 500], "vertical_y_vertices": [303, 313] }
          },
          "thought_content_perception": {
            "extracted_string_or_numeric_value": "Normal.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [505, 750], "vertical_y_vertices": [303, 313] }
          },
          "cognitive_function": {
            "extracted_string_or_numeric_value": "Short term memory impaired.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 480], "vertical_y_vertices": [315, 325] }
          },
          "sensory": {
            "extracted_string_or_numeric_value": "Normal.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 320], "vertical_y_vertices": [339, 349] }
          },
          "motor": {
            "extracted_string_or_numeric_value": "Normal.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 310], "vertical_y_vertices": [351, 361] }
          }
        }
      },
      "assessment_and_plan_author": {
        "extracted_string_or_numeric_value": "ANNE L. BROAD, MD",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 500], "vertical_y_vertices": [380, 388] }
      },
      "assessment_and_plan_timestamp": {
        "extracted_string_or_numeric_value": "01/04/202401:56 PM",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [503, 623], "vertical_y_vertices": [380, 388] }
      },
      "assessment_and_plan_items": [
        {
          "diagnosis_name_and_code": {
            "extracted_string_or_numeric_value": "ALZHEIMER DISEASE (G30.9)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 410], "vertical_y_vertices": [396, 406] }
          },
          "problem_story": {
            "extracted_string_or_numeric_value": "Underwent lab workup and MRI\nMRI showed a meningioma but asymptomatic, normal labs",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 600], "vertical_y_vertices": [412, 436] }
          },
          "todays_impression": {
            "extracted_string_or_numeric_value": "Pt says she thinks she stopped aricept due to SEs, plans to check at home",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 780], "vertical_y_vertices": [442, 452] }
          },
          "current_plans": [
            {
              "extracted_string_or_numeric_value": "If so, could consider trial of memantine",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 500], "vertical_y_vertices": [458, 468] }
            }
          ]
        },
        {
          "diagnosis_name_and_code": {
            "extracted_string_or_numeric_value": "ANXIETY, GENERALIZED (F41.1)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 420], "vertical_y_vertices": [658, 668] }
          },
          "todays_impression": {
            "extracted_string_or_numeric_value": "Chronic condition, worsening\ntrial lexapro",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 450], "vertical_y_vertices": [674, 698] }
          },
          "current_plans": [
            {
              "extracted_string_or_numeric_value": "Started Lexapro 5 mg tablet, 1 (one) tablet daily, #90, 01/04/2024, No Refill.",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 750], "vertical_y_vertices": [740, 750] }
            }
          ]
        },
        {
          "diagnosis_name_and_code": {
            "extracted_string_or_numeric_value": "BODY MASS INDEX (BMI) OF 27.0-27.9 IN ADULT (Z68.27)",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 580], "vertical_y_vertices": [162, 172] }
          },
          "current_plans": [
            {
              "extracted_string_or_numeric_value": "DOCUMENTATION OF CURRENT MEDICATIONS (G8539) Routine ()",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 650], "vertical_y_vertices": [184, 194] }
            }
          ]
        }
      ],
      "immunizations": [
        {
          "name": {
            "extracted_string_or_numeric_value": "COVID-19, mRNA, LNP-S, bivalent booster, PF, 30 mcg/0.3 mL dose #2 / PFIZER BIVALENT (91312)",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 500], "vertical_y_vertices": [260, 284] }
          },
          "date": {
            "extracted_string_or_numeric_value": "09/28/2022 10:00 AM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 680], "vertical_y_vertices": [260, 284] }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Zoster (shingles) #2 / SHINGRIX (90750)",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 450], "vertical_y_vertices": [880, 890] }
          },
          "date": {
            "extracted_string_or_numeric_value": "10/18/2018 09:45 AM",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 680], "vertical_y_vertices": [880, 890] }
          }
        }
      ],
      "signer_name": {
        "extracted_string_or_numeric_value": "ANNE L. BROAD MD",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [194, 320],
          "vertical_y_vertices": [200, 210]
        }
      },
      "footers": [
        {
          "patient_name": {
            "extracted_string_or_numeric_value": "Judith A. Grandy",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 270], "vertical_y_vertices": [915, 925] }
          },
          "patient_number": {
            "extracted_string_or_numeric_value": "28641",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 540], "vertical_y_vertices": [915, 925] }
          },
          "date_of_birth": {
            "extracted_string_or_numeric_value": "08/18/1947 (76 years)",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [710, 843], "vertical_y_vertices": [915, 925] }
          },
          "print_timestamp": {
            "extracted_string_or_numeric_value": "01/29/2024 03:47:37 PM",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [194, 310], "vertical_y_vertices": [940, 950] }
          },
          "template_name": {
            "extracted_string_or_numeric_value": "CFP History & Physical Note with Caregiver Signoff and Results (16.0)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 700], "vertical_y_vertices": [927, 950] }
          },
          "printed_by": {
            "extracted_string_or_numeric_value": "Jamie E. Michell",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 580], "vertical_y_vertices": [952, 962] }
          },
          "page_info": {
            "extracted_string_or_numeric_value": "Page 1/5",
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [800, 843], "vertical_y_vertices": [952, 962] }
          }
        }
      ]
    }
  }
]
```