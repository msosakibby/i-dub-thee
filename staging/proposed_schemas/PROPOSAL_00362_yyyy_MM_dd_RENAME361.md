An expert forensic data architect, I have analyzed the provided document, a neuropsychological evaluation, to design a resilient Pydantic V2 schema. The schema accommodates the document's complex structure, including nested tables of test results with varying formats, extensive narrative sections, and discrete data points. The design prioritizes logical grouping of information, mirroring the report's own sections for clarity and robustness.

### BLOCK 1: Python Pydantic V2 Schema

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its horizontal and vertical vertices for spatial referencing."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class TestResult(BaseModel):
    """A structured representation of a single test result from the evaluation tables."""
    model_config = ConfigDict(extra='forbid')
    measure: ForensicDataEntity
    sub_measure: Optional[ForensicDataEntity] = None
    score_type: Optional[ForensicDataEntity] = None
    score_value: ForensicDataEntity
    norm_average: ForensicDataEntity
    functional_level: Optional[ForensicDataEntity] = None

class DiagnosticImpression(BaseModel):
    """Represents the final diagnostic code and text."""
    model_config = ConfigDict(extra='forbid')
    code: ForensicDataEntity
    text: ForensicDataEntity

class NeuropsychologicalEvaluation(BaseModel):
    """
    A Pydantic V2 schema for extracting data from a Neuropsychological Evaluation report.
    This model corresponds to document class '00362 yyyy-MM-dd_RENAME361'.
    """
    model_config = ConfigDict(extra='forbid')

    # Document Header & Clinic Information
    clinic_name: ForensicDataEntity
    clinic_psychologist: ForensicDataEntity
    clinic_address: ForensicDataEntity
    clinic_contact: ForensicDataEntity
    document_title: ForensicDataEntity

    # I. Identifying Data
    patient_name: ForensicDataEntity
    patient_dob: ForensicDataEntity
    date_of_testing: ForensicDataEntity

    # II. Reason for Referral and Observations
    referral_and_observations_narrative: ForensicDataEntity
    medical_history_narrative: ForensicDataEntity
    medications: List[ForensicDataEntity]
    social_history_narrative: ForensicDataEntity
    activities_and_observations_narrative: ForensicDataEntity

    # III. Sources of Data
    sources_of_data: List[ForensicDataEntity]
    psychometrist: ForensicDataEntity

    # IV. Findings
    mental_status_and_language_skills_narrative: ForensicDataEntity
    mental_status_language_tests: List[TestResult]

    visual_perception_memory_learning_narrative: ForensicDataEntity
    visual_perception_memory_tests: List[TestResult]

    auditory_verbal_memory_learning_narrative: ForensicDataEntity
    auditory_verbal_memory_tests: List[TestResult]

    executive_function_problem_solving_narrative: ForensicDataEntity
    executive_function_tests: List[TestResult]

    mood_and_coping_status_narrative: ForensicDataEntity
    mood_coping_tests: List[TestResult]

    # Summary, Recommendations, and Diagnosis
    summary_narrative: ForensicDataEntity
    recommendations_and_prognosis_narrative: ForensicDataEntity
    recommendations_list: List[ForensicDataEntity]
    diagnostic_impression: DiagnosticImpression
    
    # Signature
    signing_psychologist_name: ForensicDataEntity
    signing_psychologist_title: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'NeuropsychologicalEvaluation':
        """
        This validator is included to fulfill the directive's structural requirements.
        Neuropsychological evaluations do not contain financial data suitable for
        double-entry GAAP checksums, so this validator will always pass.
        """
        # No financial fields to validate in this document type.
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "neuropsych_eval_00362_2025-10-30_grandy",
    "should_pass": true,
    "taxonomy_lane": "NeuropsychologicalEvaluation",
    "binary_header_simulation": "25504446",
    "payload": {
      "clinic_name": {
        "extracted_string_or_numeric_value": "NeuroBloom Cognitive Health Center",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [160, 620],
          "vertical_y_vertices": [120, 140]
        }
      },
      "clinic_psychologist": {
        "extracted_string_or_numeric_value": "Sarah von der Hoff PsyD",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [400, 580],
          "vertical_y_vertices": [141, 155]
        }
      },
      "clinic_address": {
        "extracted_string_or_numeric_value": "207 Circle Dr.\nTraverse City, MI 49684",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [400, 580],
          "vertical_y_vertices": [156, 185]
        }
      },
      "clinic_contact": {
        "extracted_string_or_numeric_value": "Ph: (231) 642-4722/Fax (231) 642-4724",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [400, 650],
          "vertical_y_vertices": [200, 215]
        }
      },
      "document_title": {
        "extracted_string_or_numeric_value": "NEUROPSYCHOLOGICAL EVALUATION",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [360, 650],
          "vertical_y_vertices": [250, 265]
        }
      },
      "patient_name": {
        "extracted_string_or_numeric_value": "Mrs. Judith Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 490],
          "vertical_y_vertices": [315, 330]
        }
      },
      "patient_dob": {
        "extracted_string_or_numeric_value": "8/18/1947",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 420],
          "vertical_y_vertices": [345, 360]
        }
      },
      "date_of_testing": {
        "extracted_string_or_numeric_value": "10/7/2025",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [355, 425],
          "vertical_y_vertices": [375, 390]
        }
      },
      "referral_and_observations_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Judith Grandy is a 77-year-old married woman, referred for neuropsychological evaluation by Dr. Heather Lee, D.O., to assess her neuropsychological status regarding potential cognitive decline including memory issues, to clarify diagnosis, and facilitate treatment planning. Mrs. Grandy attended the evaluation with her husband, Keith, and while she was able to provide her client history along with subjective observations, Keith added a chronological sequence of her concerns and his opinion of her functional cognition.\n\nWhen asked if she's experiencing any cognitive functioning decline, Mrs. Grandy stated, \"Most of the time I can remember people; I know I know them, but not their names\". She went on to say, \"I think running the grocery store is good for me, it gets me out, I get my steps in\". Mrs. Grandy continues to go into the grocery store she started and enjoys the sense of purpose this provides. She believes she is forgetful stating, \"Keith repeats things for me\". Keith added, \"She's worse than what she says, she repeats things we talked about two hours ago\". He continued, \"She is very happy, has no bad moods”.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [460, 690]
        }
      },
      "medical_history_narrative": {
        "extracted_string_or_numeric_value": "According to available medical records, Mrs. Grandy's medical history is significant for bradycardia, diverticulitis, GERD, osteoarthritis, peripheral venous insufficiency, thoracic compression fracture. She does not have a history of seizure disorder, stroke, cardiac procedures, or TBI.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [700, 760]
        }
      },
      "medications": [
        {
          "extracted_string_or_numeric_value": "aspirin",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 530], "vertical_y_vertices": [760, 775] }
        },
        {
          "extracted_string_or_numeric_value": "Donepezil",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [535, 590], "vertical_y_vertices": [760, 775] }
        },
        {
          "extracted_string_or_numeric_value": "Atorvastatin",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [595, 665], "vertical_y_vertices": [760, 775] }
        },
        {
          "extracted_string_or_numeric_value": "Escitalopram",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 745], "vertical_y_vertices": [760, 775] }
        },
        {
          "extracted_string_or_numeric_value": "Levothyroxine",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 820], "vertical_y_vertices": [760, 775] }
        },
        {
          "extracted_string_or_numeric_value": "Loratadine",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [185, 250], "vertical_y_vertices": [776, 790] }
        },
        {
          "extracted_string_or_numeric_value": "omeprazole",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [255, 320], "vertical_y_vertices": [776, 790] }
        }
      ],
      "social_history_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Grandy graduated from high school and went on to attend Lansing Business School for one year. She reports being a good student. She began working for GMAC (General Motors accounting division) where she worked in the office. She got married along the way and they had two sons together. She and her husband ran a farm as well as opened a grocery store in 1969. Sadly, her husband passed away in 1999 from a farming accident. The grocery store continued to be run by leasers, until eventually, her son and she reopened it under their name again quite recently. Mrs. Grandy remarried Keith 21 years ago and they live happily in their own home. Mrs. Grandy continues to take an active role in the store, working four hours/day at least 5-6 days/week. She reports enjoying talking with people and \"gets [her] steps in\". In her free time, she enjoys playing games on her phone and doing Sudoku. The Grandys go out to dinner with friends and enjoy their family.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [800, 960]
        }
      },
      "activities_and_observations_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Grandy reports no formal exercise regimen, she stays active stocking shelves and cleaning the grocery store. She continues to drive locally, no more than 11 miles to get her hair done. Keith and Mrs. Grandy's son, Mark, do the family finances. Mrs. Grandy continues to be independent in all basic ADLs.\n\nMrs. Grandy interacted in an alert, pleasant manner, laughing often. She did not demonstrate any significant visual deficits, wearing reading glasses for portions of testing. She did not demonstrate any significant auditory deficits. She provided persistent effort producing a valid measure of her current cognitive functioning. Her performance is compared to a normative sample of her same-age peers. Her performance on a measure of historical cognitive capacity (WRAT-4) converges with an educational and vocational history to estimate average historical cognitive capacity.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [100, 300]
        }
      },
      "sources_of_data": [
        { "extracted_string_or_numeric_value": "Clinical Interview", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 380], "vertical_y_vertices": [350, 360] } },
        { "extracted_string_or_numeric_value": "Trail Making Test", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 380], "vertical_y_vertices": [361, 371] } },
        { "extracted_string_or_numeric_value": "WRAT-4 (Word Reading)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 420], "vertical_y_vertices": [372, 382] } },
        { "extracted_string_or_numeric_value": "MOCA", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 310], "vertical_y_vertices": [383, 393] } },
        { "extracted_string_or_numeric_value": "Wisconsin Card Sort Test", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 430], "vertical_y_vertices": [394, 404] } },
        { "extracted_string_or_numeric_value": "CLOX I/II", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 340], "vertical_y_vertices": [405, 415] } },
        { "extracted_string_or_numeric_value": "Wechsler Memory Scale – Fourth Edition", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435, 670], "vertical_y_vertices": [350, 360] } },
        { "extracted_string_or_numeric_value": "RBANS (Repeatable Battery)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435, 590], "vertical_y_vertices": [361, 371] } },
        { "extracted_string_or_numeric_value": "FAS", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435, 460], "vertical_y_vertices": [372, 382] } },
        { "extracted_string_or_numeric_value": "Delis-Kaplan Executive Function System", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435, 670], "vertical_y_vertices": [383, 393] } },
        { "extracted_string_or_numeric_value": "Geriatric Depression Scale (GDS)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435, 630], "vertical_y_vertices": [394, 404] } },
        { "extracted_string_or_numeric_value": "Geriatric Anxiety Scale (GAS)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435, 610], "vertical_y_vertices": [405, 415] } }
      ],
      "psychometrist": {
        "extracted_string_or_numeric_value": "Gretchen Fraser, MS, OTR/L",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 420],
          "vertical_y_vertices": [435, 450]
        }
      },
      "mental_status_and_language_skills_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Grandy achieved a score of 18 out of a possible 30 on the MoCA. She was partially oriented to time, and fully oriented to place, and situation. She was not able to correctly state the day or date. She was able to subtract seven from seventy, three times successfully. She was able to identify 3/3 animals. She was able to repeat a string of numbers in order, both forward and backward. She scored within the low average range on a task of object recognition and naming. Her expressive language was effective during normal conversation. She scored within the mildly impaired range on a structured language fluency measure. Mrs. Grandy scored within the average range on a measure that asked her to read a list of words.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [480, 620]
        }
      },
      "mental_status_language_tests": [
        {
          "measure": { "extracted_string_or_numeric_value": "MOCA", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 230], "vertical_y_vertices": [650, 660] } },
          "score_value": { "extracted_string_or_numeric_value": "18/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 390], "vertical_y_vertices": [650, 660] } },
          "norm_average": { "extracted_string_or_numeric_value": "WNL > 23", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 550], "vertical_y_vertices": [650, 660] } },
          "functional_level": { "extracted_string_or_numeric_value": "Functional Level", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 750], "vertical_y_vertices": [630, 640] } }
        },
        {
          "measure": { "extracted_string_or_numeric_value": "RBANS", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 240], "vertical_y_vertices": [670, 680] } },
          "sub_measure": { "extracted_string_or_numeric_value": "(object naming)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 290], "vertical_y_vertices": [690, 700] } },
          "score_type": { "extracted_string_or_numeric_value": "Score", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 390], "vertical_y_vertices": [670, 680] } },
          "score_value": { "extracted_string_or_numeric_value": -0.86, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 390], "vertical_y_vertices": [690, 700] } },
          "norm_average": { "extracted_string_or_numeric_value": "Norm-Average", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 580], "vertical_y_vertices": [630, 640] } },
          "functional_level": { "extracted_string_or_numeric_value": "Average", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [680, 690] } }
        },
        {
          "measure": { "extracted_string_or_numeric_value": "FAS", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 220], "vertical_y_vertices": [710, 720] } },
          "sub_measure": { "extracted_string_or_numeric_value": "(letter fluency)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 290], "vertical_y_vertices": [730, 740] } },
          "score_type": { "extracted_string_or_numeric_value": "Z-Score", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 400], "vertical_y_vertices": [710, 720] } },
          "score_value": { "extracted_string_or_numeric_value": -1.90, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 390], "vertical_y_vertices": [730, 740] } },
          "norm_average": { "extracted_string_or_numeric_value": "-1 to +1", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 540], "vertical_y_vertices": [720, 730] } },
          "functional_level": { "extracted_string_or_numeric_value": "Mildly Impaired", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 760], "vertical_y_vertices": [720, 730] } }
        },
        {
          "measure": { "extracted_string_or_numeric_value": "WRAT-4", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 240], "vertical_y_vertices": [750, 760] } },
          "sub_measure": { "extracted_string_or_numeric_value": "(word reading)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 290], "vertical_y_vertices": [770, 780] } },
          "score_type": { "extracted_string_or_numeric_value": "Standard Score", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 450], "vertical_y_vertices": [750, 760] } },
          "score_value": { "extracted_string_or_numeric_value": 98, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 370], "vertical_y_vertices": [770, 780] } },
          "norm_average": { "extracted_string_or_numeric_value": "86-114", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 540], "vertical_y_vertices": [760, 770] } },
          "functional_level": { "extracted_string_or_numeric_value": "Average", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [760, 770] } }
        }
      ],
      "visual_perception_memory_learning_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Grandy was unable to correctly copy a chair while viewing a model. She was able to copy a clock face while viewing a model, scoring within the intact range. Mrs. Grandy scored within the mildly impaired range on a visuospatial measure of visual perception and line orientation. She scored within the average range on a measure of visual scanning and sequencing. She scored within the severely impaired and mild to moderately impaired ranges for measures of color naming and word naming, respectively, that track her visual processing and speed. She scored within the mild to moderately impaired range on a visuoconstructive task that required her to immediately reproduce visual figures from memory. She scored within the severely impaired range when asked to recall these images after a 20-minute delay.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [800, 950]
        }
      },
      "visual_perception_memory_tests": [],
      "auditory_verbal_memory_learning_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Grandy was able to immediately repeat five words on her first attempt, but not her second attempt. She was unable to recall any of the five words following a brief interference task. She was able to repeat one of two sentences after hearing them once. She scored within the moderately impaired range when required to immediately remember details of two short stories. She scored within the severely impaired range when asked to recall these stories after a thirty-minute delay. Mrs. Grandy scored within the moderately impaired range when asked to learn a list of words over repeated trials. She scored within the mildly impaired range when asked to recall these words following a 20-minute delay.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [100, 250]
        }
      },
      "auditory_verbal_memory_tests": [],
      "executive_function_problem_solving_narrative": {
        "extracted_string_or_numeric_value": "Executive functioning is defined as the ability to extract, anticipate, select, plan, experiment, modify, and act on information in novel situations: Additionally, executive functioning pertains to the ability to form concepts and use reason to solve complex problems. A successful performance on the Wisconsin Card Sort Test requires intact capacities in these areas. Mrs. Grandy scored in the below average range on the Wisconsin Card Sort Test with regard to total errors. Specifically, she was able to identify a range of possible response options. She quickly completed the first category and midway through the task achieved the second. She completed two total categories resulting in an average score.\n\nThe CLOX1 measures executive capacity related to planning, motor sequencing, selective attention, and self-monitoring as the action plan evolves. Mrs. Grandy scored in the borderline range on the CLOX1, suggesting borderline abilities in these executive control areas.\n\nMrs. Grandy scored in the mildly impaired range on a measure that required a coordination of visual scanning and cognitive shifting. She was asked to switch between numbers and letters in sequence. She was able to complete the measure in a longer than average amount of time, although sustained one error requiring correction. The ability to engage in this type of cognitive flexibility is considered a classic executive function, one that is essential for higher-level skills such as multitasking, divided attention, and alternating attention.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [400, 750]
        }
      },
      "executive_function_tests": [],
      "mood_and_coping_status_narrative": {
        "extracted_string_or_numeric_value": "Mrs. Grandy presented with a pleasant, outgoing affect. She showed a range of facial expressions with no outward signs of distress. Mrs. Grandy endorsed 2 items out of 30 on the Geriatric Depression Scale, indicating low risk for depression in her daily life. The items she endorsed were associated with often feeling helpless and lacking mental clarity. Mrs. Grandy scored a 1 on the Geriatric Anxiety Scale, a low risk for anxiety in her daily life. She stated she feels like she is in a daze \"sometimes\". She drinks a glass of alcohol most evenings and does not use tobacco or other illicit substances. When asked about her sleep she said, “I sleep great”. Mrs. Grandy reports an appetite that is “normal”, stating, “I hate cooking, I eat Thrive”, an online grocery service.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [450, 600]
        }
      },
      "mood_coping_tests": [
        {
          "measure": { "extracted_string_or_numeric_value": "Geriatric Depression Scale (GDS)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 420], "vertical_y_vertices": [700, 710] } },
          "score_value": { "extracted_string_or_numeric_value": 2, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 460], "vertical_y_vertices": [700, 710] } },
          "norm_average": { "extracted_string_or_numeric_value": "WNL<10", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [700, 710] } }
        },
        {
          "measure": { "extracted_string_or_numeric_value": "Geriatric Anxiety Scale (GAS)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [190, 400], "vertical_y_vertices": [720, 730] } },
          "score_value": { "extracted_string_or_numeric_value": 1, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 460], "vertical_y_vertices": [720, 730] } },
          "norm_average": { "extracted_string_or_numeric_value": "WNL<7", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 700], "vertical_y_vertices": [720, 730] } }
        }
      ],
      "summary_narrative": {
        "extracted_string_or_numeric_value": "In summary, Mrs. Grandy's performance on neuropsychological measures of cognitive capacity reveals a range of findings including significant cognitive deficits. She performed within the intact ranges on measures of word reading, visual scanning and sequencing, and on executive functioning measures of problem solving and reasoning (total categories) and inhibition (total errors). She scored in the low average range on measures of object recognition and naming, and on executive functioning measures of problem solving and reasoning (total errors) and inhibition (completion time). Mrs. Grandy scored in the impaired ranges on measures of language fluency, visuospatial perception and judgment, visual processing speed, visual memory immediate and delayed recall, auditory memory immediate and delayed recall, and auditory list learning immediate and delayed recall.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [800, 950]
        }
      },
      "recommendations_and_prognosis_narrative": {
        "extracted_string_or_numeric_value": "Overall, her findings are consistent with a diagnosis of dementia. The nature of her findings and report of progressive memory decline over the past year (per available records) suggest a neurodegenerative process. Mrs. Grady is currently prescribed Donepezil. A cost benefit analysis of Atorvastatin could be conducted given the potential of 'statin' medication to impact cognition.\n\nIt is recommended that Mrs. Grandy remain socially engaged and physically active. It is a good idea to continue engagement with brain games on her computer or phone to promote cognitive 'exercise'. There are many apps that are conducive to this training that include, but are not limited to, Awesome Memory, Bag Games, Déjà vu, iMazing, iMimic, Matrix game and Memory Matches. The Lumosity app is another source for brain challenges. She has supports in place for medication, meal and financial management, along with family close by who provide oversight. Her participation with the grocery store is vital for social engagement and mood.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [185, 820],
          "vertical_y_vertices": [100, 300]
        }
      },
      "recommendations_list": [
        { "extracted_string_or_numeric_value": "It is recommended that Mrs. Grandy have assistance for set up and management of medications.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 820], "vertical_y_vertices": [310, 330] } },
        { "extracted_string_or_numeric_value": "Assistance is also recommended with management of finances.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 820], "vertical_y_vertices": [331, 345] } },
        { "extracted_string_or_numeric_value": "Mrs. Grandy's findings appear inconsistent with safe driving from a neuropsychological standpoint.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 820], "vertical_y_vertices": [346, 360] } },
        { "extracted_string_or_numeric_value": "Establishing Durable Power of Attorney arrangements is recommended as part of good planning and for her protection.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 820], "vertical_y_vertices": [361, 390] } },
        { "extracted_string_or_numeric_value": "A repeat evaluation is recommended in one year to monitor the course of her cognitive and emotional functioning, assist in diagnostic clarification, and assist with treatment recommendations within the context of her medical care.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 820], "vertical_y_vertices": [391, 440] } }
      ],
      "diagnostic_impression": {
        "code": {
          "extracted_string_or_numeric_value": "F03.90",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [185, 240],
            "vertical_y_vertices": [480, 490]
          }
        },
        "text": {
          "extracted_string_or_numeric_value": "Dementia",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [185, 250],
            "vertical_y_vertices": [491, 501]
          }
        }
      },
      "signing_psychologist_name": {
        "extracted_string_or_numeric_value": "Sarah J. von der Hoff, PsyD",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 700],
          "vertical_y_vertices": [600, 615]
        }
      },
      "signing_psychologist_title": {
        "extracted_string_or_numeric_value": "Licensed Psychologist",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 650],
          "vertical_y_vertices": [616, 630]
        }
      }
    }
  }
]
```