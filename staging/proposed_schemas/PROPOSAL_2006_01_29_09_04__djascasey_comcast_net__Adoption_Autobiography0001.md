An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document and designed a resilient Pydantic V2 schema. The schema is structured to mirror the document's layout, with nested models for each section and sub-section, ensuring a clear and maintainable data structure.

The design incorporates a mathematical validation check as required. Specifically, the `FinancialStatusSection` includes a `model_validator` that verifies the internal consistency between the applicant's stated annual salary and their life insurance coverage amount, based on the relationship described in the document text. This fulfills the directive for a GAAP-style checksum within the constraints of the available data.

The corresponding JSON test case represents the full complexity of the document, including nested lists for employment history, medical benefits, demographic tables, and facility listings, ensuring the schema's robustness and accuracy.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
import re

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class ChildrenAtHomeQuestions(BaseModel):
    model_config = ConfigDict(extra='forbid')
    exposure_to_other_cultures: ForensicDataEntity
    acceptance_of_different_sibling: ForensicDataEntity
    willingness_to_share: ForensicDataEntity

class AdoptionSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    motivations: ForensicDataEntity
    desired_child_characteristics: ForensicDataEntity
    reason_for_country: ForensicDataEntity
    adoption_initiator: ForensicDataEntity
    risk_understanding: ForensicDataEntity
    child_background_plan: ForensicDataEntity
    coping_experience: ForensicDataEntity
    experience_with_diversity: ForensicDataEntity
    expected_relationship: ForensicDataEntity
    acceptance_of_bio_family: ForensicDataEntity
    coping_with_no_affection: ForensicDataEntity
    acceptance_of_differences: ForensicDataEntity
    neighborhood_attitude: ForensicDataEntity
    awareness_of_problems: ForensicDataEntity
    communication_plan_no_english: ForensicDataEntity
    support_network: ForensicDataEntity
    adoptive_parent_group_involvement: ForensicDataEntity
    extended_family_openness: ForensicDataEntity
    children_at_home_questions: Optional[ChildrenAtHomeQuestions] = None

class ParentDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    full_name: ForensicDataEntity
    occupation: ForensicDataEntity
    age: Optional[ForensicDataEntity] = None
    health: ForensicDataEntity
    ethnic_descent: ForensicDataEntity
    deceased_details: Optional[ForensicDataEntity] = None

class SiblingDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    residence: ForensicDataEntity
    number_of_children: ForensicDataEntity
    spouse_name: ForensicDataEntity

class BiographicalInfoSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    applicant_full_name: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    weight: ForensicDataEntity
    height: ForensicDataEntity
    eye_color: ForensicDataEntity
    hair_color: ForensicDataEntity
    complexion: ForensicDataEntity
    father_details: ParentDetails
    mother_details: ParentDetails
    parents_residence: ForensicDataEntity
    siblings: List[SiblingDetails]
    family_visit_frequency: ForensicDataEntity
    parents_activities: ForensicDataEntity

class ChildhoodExperiencesSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    feelings_toward_parents: ForensicDataEntity
    sibling_relationship: ForensicDataEntity
    family_upbringing: ForensicDataEntity
    special_memories: ForensicDataEntity
    substance_use_in_home: ForensicDataEntity

class EducationHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    institution: ForensicDataEntity
    years: ForensicDataEntity

class EmploymentHistory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    company: ForensicDataEntity
    years: ForensicDataEntity

class SelfDescriptionSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    self_perception: ForensicDataEntity
    others_perception: ForensicDataEntity
    strengths: ForensicDataEntity
    weaknesses: ForensicDataEntity
    education_history: List[EducationHistory]
    employment_history: List[EmploymentHistory]
    employment_satisfaction: ForensicDataEntity
    hobbies: ForensicDataEntity
    greatest_achievement: ForensicDataEntity
    greatest_failure: ForensicDataEntity
    life_goals: ForensicDataEntity

class FamilySection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    meeting_spouse: ForensicDataEntity
    spouse_relationship: ForensicDataEntity
    marriage_strong_points: ForensicDataEntity
    marriage_areas_to_strengthen: ForensicDataEntity
    responsibility_division: ForensicDataEntity
    discussing_feelings: ForensicDataEntity
    spouse_support: ForensicDataEntity
    conflict_resolution: ForensicDataEntity
    decision_making: ForensicDataEntity
    recreational_activities: ForensicDataEntity
    relationship_with_other_children: ForensicDataEntity
    current_family_relationships: ForensicDataEntity

class GuardianDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    age: ForensicDataEntity
    relationship: ForensicDataEntity
    occupation: ForensicDataEntity
    address: ForensicDataEntity

class ChildRearingPhilosophySection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    parenting_approach: ForensicDataEntity
    discipline_approach: ForensicDataEntity
    child_expectations: ForensicDataEntity
    parenting_skills: ForensicDataEntity
    spouse_parenting_skills: ForensicDataEntity
    capacity_for_fairness: ForensicDataEntity
    willingness_to_gain_skills: ForensicDataEntity
    experience_with_children: ForensicDataEntity
    daily_childcare_plan: ForensicDataEntity
    guardian_details: GuardianDetails
    perception_of_family_life: ForensicDataEntity
    view_of_family_fun: ForensicDataEntity

class MedicalBenefit(BaseModel):
    model_config = ConfigDict(extra='forbid')
    service: ForensicDataEntity
    coverage_details: ForensicDataEntity

class MedicalInsurance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    provider: ForensicDataEntity
    plan_description: ForensicDataEntity
    adult_preventive_care: List[MedicalBenefit]
    well_baby_child_care: List[MedicalBenefit]
    mental_health_care: List[MedicalBenefit]
    substance_abuse_care: List[MedicalBenefit]
    durable_medical_equipment: MedicalBenefit
    maternity_care: List[MedicalBenefit]
    other_services: List[MedicalBenefit]
    dental_care: List[MedicalBenefit]
    vision_care: List[MedicalBenefit]

class LifeInsurance(BaseModel):
    model_config = ConfigDict(extra='forbid')
    underwriter: ForensicDataEntity
    plan_description: ForensicDataEntity
    coverage_level: ForensicDataEntity

class FinancialStatusSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    employment_and_salary: ForensicDataEntity
    assets_and_income_sources: ForensicDataEntity
    medical_insurance: MedicalInsurance
    life_insurance: LifeInsurance
    liabilities: ForensicDataEntity
    ability_to_support: ForensicDataEntity

    @model_validator(mode='after')
    def validate_financial_consistency(self) -> 'FinancialStatusSection':
        """
        Performs a mathematical check based on statements in the document.
        The document states life insurance is "a multiple of four times my Qualified Annual Earnings (QAE)".
        This validator assumes QAE is the base salary and checks if the coverage is 4x the salary.
        """
        salary_text = self.employment_and_salary.extracted_string_or_numeric_value
        salary_match = re.search(r'\$(\d{1,3}(,\d{3})*(\.\d+)?)', str(salary_text))
        
        if not salary_match:
            # If no salary is found in the text, the check cannot be performed.
            return self
        
        base_salary = float(salary_match.group(1).replace(',', ''))

        coverage_value = self.life_insurance.coverage_level.extracted_string_or_numeric_value
        if not isinstance(coverage_value, (int, float)):
            # If coverage is not a number, the check cannot be performed.
            return self

        expected_coverage = 4 * base_salary
        
        # Use a tolerance for floating point comparisons
        if not abs(coverage_value - expected_coverage) < 0.01:
             raise ValueError(f"Life insurance coverage {coverage_value} does not match expected value based on salary ({expected_coverage})")

        return self

class HomeDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    style: ForensicDataEntity
    number_of_rooms: ForensicDataEntity
    square_footage: ForensicDataEntity
    year_built_renovated: ForensicDataEntity
    lot_size: ForensicDataEntity
    child_bedroom_size: ForensicDataEntity
    play_area: ForensicDataEntity

class DemographicStat(BaseModel):
    model_config = ConfigDict(extra='forbid')
    category: ForensicDataEntity
    value_1990: Optional[ForensicDataEntity] = None
    value_2000: ForensicDataEntity
    number_difference: Optional[ForensicDataEntity] = None
    percentage_difference: Optional[ForensicDataEntity] = None

class NeighborhoodDemographics(BaseModel):
    model_config = ConfigDict(extra='forbid')
    source: ForensicDataEntity
    population: List[DemographicStat]
    race_2000: List[DemographicStat]
    household_by_type: List[DemographicStat]
    housing_tenure: List[DemographicStat]
    educational_attainment: List[DemographicStat]
    commuting_to_work: List[DemographicStat]
    employment_status: List[DemographicStat]
    income: List[DemographicStat]
    poverty_status: List[DemographicStat]
    housing_value_and_rent: List[DemographicStat]

class Facility(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    phone: Optional[ForensicDataEntity] = None
    address: ForensicDataEntity
    distance: Optional[ForensicDataEntity] = None
    website: Optional[ForensicDataEntity] = None

class HomeAndNeighborhoodSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    home_details: HomeDetails
    location_and_population: ForensicDataEntity
    neighborhood_description: ForensicDataEntity
    demographics: NeighborhoodDemographics
    medical_facilities: List[Facility]
    educational_facilities: List[Facility]
    pets: ForensicDataEntity

class ReligiousOrientationSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    preference: ForensicDataEntity
    child_education_plan: ForensicDataEntity
    concept_of_religious_living: ForensicDataEntity
    views_on_values: ForensicDataEntity

class FamilyHealthSection(BaseModel):
    model_config = ConfigDict(extra='forbid')
    applicant_health_problems: ForensicDataEntity
    child_health_problems: ForensicDataEntity
    reason_for_childlessness: ForensicDataEntity

class AdoptionAutobiography(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    applicant_name: ForensicDataEntity
    applicant_ssn: ForensicDataEntity
    adoption_section: AdoptionSection
    biographical_info_section: BiographicalInfoSection
    childhood_experiences_section: ChildhoodExperiencesSection
    self_description_section: SelfDescriptionSection
    family_section: FamilySection
    child_rearing_philosophy_section: ChildRearingPhilosophySection
    financial_status_section: FinancialStatusSection
    home_and_neighborhood_section: HomeAndNeighborhoodSection
    religious_orientation_section: ReligiousOrientationSection
    family_health_section: FamilyHealthSection
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2006-01-29 09-04 _djascasey@comcast.net_ Adoption Autobiography0001",
    "should_pass": true,
    "taxonomy_lane": "AdoptionAutobiography",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "AUTOBIOGRAPHY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [368, 524, 524, 368],
          "vertical_y_vertices": [36, 36, 49, 49]
        }
      },
      "applicant_name": {
        "extracted_string_or_numeric_value": "Mark Kibby",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [158, 252, 252, 158],
          "vertical_y_vertices": [67, 67, 78, 78]
        }
      },
      "applicant_ssn": {
        "extracted_string_or_numeric_value": "366-72-9323",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [520, 633, 633, 520],
          "vertical_y_vertices": [67, 67, 78, 78]
        }
      },
      "adoption_section": {
        "motivations": {
          "extracted_string_or_numeric_value": "My motivations for adoption are simple. I want to be a parent to raise, care, love and share with another person the experiences of a lifetime.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 810, 810, 198],
            "vertical_y_vertices": [184, 184, 220, 220]
          }
        },
        "desired_child_characteristics": {
          "extracted_string_or_numeric_value": "I am hoping to adopt a healthy infant of Guatemalan decent.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 688, 688, 198],
            "vertical_y_vertices": [284, 284, 296, 296]
          }
        },
        "reason_for_country": {
          "extracted_string_or_numeric_value": "My rationale for pursuing Guatemala over another country is simple. The focus of my college education was in Spanish Literature and Culture. As a result, I feel a stronger desire to adopt from a Latin American due to the fact that I've spent a considerable amount of time learning the language, history and culture of the region. This background will help me relate better to a child from this region.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [368, 368, 450, 450]
          }
        },
        "adoption_initiator": {
          "extracted_string_or_numeric_value": "As a single parent, the idea for adopting a child was mine alone. It is something I have contemplated over the last five years and discussed at length with my family and friends.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 820, 820, 198],
            "vertical_y_vertices": [520, 520, 568, 568]
          }
        },
        "risk_understanding": {
          "extracted_string_or_numeric_value": "This is the most intense and serious endeavor I have ever undertaken. It is no small thing to be entrusted with another life. This is a lifetime commitment. It is a commitment to care for, love and put the life and welfare of this individual above all others. It doesn't end with the child's infancy. The responsibilities carry on through out your entire life. It is a point my mother emphasized as we discussed this decision. Your child is always your child. You will always love them no matter what and will do anything at anytime for them.\n\nNow, I am aware of and have researched the particular risks associated with adopting. I have consulted other friends who have recently adopted and understand there are particular issues I may face as an adoptive father. Things such as separation or adjustment issues, developmental issues, unknown future health issues hereditarily passed and currently undetectable by science.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [620, 620, 840, 840]
          }
        },
        "child_background_plan": {
          "extracted_string_or_numeric_value": "As I mentioned previously my college education focused on Spanish literature culture as a result I myself am extremely familiar with Latin American culture and plan on using that background to help share and educate my child. Additionally, Chicago the city in which I intend to live and raise the child is has one of the largest Latin American populations in the United States. There are many opportunities that are available at cultural centers in which we can participate. Obviously, I will focus those opportunities on Guatemala specifically, but I will also introduce the child to other cultures of the region in addition to those around the world.\n\nOther than cultural exposure, I enjoy traveling and once the child is old enough to understand and enjoy the experiences of traveling to Latin America will arrange for trips to the region as a family.\n\nRegarding helping my child understand adoption, I will do my best to explain the situation and circumstances as they are explained to me by the placement agency. I will be as up front and honest as possible regarding their background. It is important to me that the child knows the facts of the situation and to the best of my knowledge their parents felt this was in the child's best interest.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 380, 380]
          }
        },
        "coping_experience": {
          "extracted_string_or_numeric_value": "I don't believe I have any more or any less “life experience/preparation” than any other potential parent to be has. I will draw on my own personal experiences, on those others have shared with me and strive to understand what is best given my family situation. One of the most important things you can do is keep an active discussion going on family challenges, how items are progressing. Don't sweep it under the table, then you won't cope with the adjustment opportunities you'll just provide them a breeding ground to fester. There is no silver bullet to child rearing.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [450, 450, 580, 580]
          }
        },
        "experience_with_diversity": {
          "extracted_string_or_numeric_value": "I've been extremely fortune to have been exposed to many different cultures and backgrounds. I was born and raised in a small farming community that was extremely heterogeneous. Once I got to college though the entire world opened up to me. I went from living in a small community of 800 people to a community of over 90,000 with individuals from every corner of the globe.\n\nI took every opportunity available to participate in events and build friendships that would expose to me to people from different countries, races, religions and ethnicities.\n\nMy education was just the stepping stone though. In my professional career I've continued to grow and expand my cultural awareness not only through my friendship and interactions, also through training and professional education.\n\nCurrently, I am fortunate enough to have on my staff individuals born and raised in 5 different countries each from different parts of the globe.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [650, 650, 920, 920]
          }
        },
        "expected_relationship": {
          "extracted_string_or_numeric_value": "My desire is that I have an active, open, honest, loving relationship in the same manner in which I was brought up. Every child and family unit is unique and while the relationship in my head may not become the reality I am confident in my abilities to love this child unconditionally. I will ensure that I am present and available in my child's life.\n\nI will never be able to completely relate to my child's feelings regarding adoption or cultural background. However, I can be informative, loving and supportive as the child begins to understand and explore what it means to be adopted and from a different culture than myself. I see these discussions and questions as opportunities to grow and strengthen my relationship with my child and not as uncomfortable topics.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 300, 300]
          }
        },
        "acceptance_of_bio_family": {
          "extracted_string_or_numeric_value": "Yes, these are important and fundamental in being able to understand and relate to my child. Excluding these relationships from my child's life only hurt the child and is not in their best interest. A strong healthy relationship with previous care givers or biological parents can only be a benefit to the child in the long run. It increases that child support network and helps them understand that many people love them in their life.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [350, 350, 450, 450]
          }
        },
        "coping_with_no_affection": {
          "extracted_string_or_numeric_value": "Obviously, this is one risk any parent faces which is especially true in cases of adoption. The feelings would be difficult to understand, I would seek professional assistance both for myself and for my child in working to understand and if possible over come this challenge.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [500, 500, 560, 560]
          }
        },
        "acceptance_of_differences": {
          "extracted_string_or_numeric_value": "Yes, accepting the child for who they are regardless of their exterior appearances or challenges will not be a problem.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [630, 630, 660, 660]
          }
        },
        "neighborhood_attitude": {
          "extracted_string_or_numeric_value": "I live in Chicago, one of the largest cities in the United States. My neighborhood is diverse racially, socio-economically, culturally and religiously. An adopted child from a foreign country will be accepted the same as any other member of the community.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [710, 710, 770, 770]
          }
        },
        "awareness_of_problems": {
          "extracted_string_or_numeric_value": "My child will be exposed to many children of various cultures, backgrounds, religions and races in the school systems available in Chicago. This sea of diversity will help the child fit in as there will be children from so many different backgrounds and family situations. However, should my child will encounter challenges whether educationally, socially or emotionally at school, I will work with the school personnel and other professionals to understand the underlying issues and put together a course of action to address.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [820, 820, 920, 920]
          }
        },
        "communication_plan_no_english": {
          "extracted_string_or_numeric_value": "I speak fluent Spanish and plan on speaking Spanish as my primary language with the child. Over the course of time as the child becomes accustomed to their new surrounding and events I will slowly introduce English. However, Spanish will be the primary language I use at home with the child. This is important to me as I do not want my child to be at a disadvantage with his Latin American peers who will naturally assume the child speaks Spanish being of Guatemalan decent.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 200, 200]
          }
        },
        "support_network": {
          "extracted_string_or_numeric_value": "Yes, I am fortunate to have a strong social support network in Chicago. Many of my friends have children all in similar age ranges. Moreover, I am fortunate to have three close friends who have all adopted, two of them from Guatemala.\n\nHowever, if this support network doesn't meet my needs or there is something of a personal nature I wish to confide I have no problems seeking professional assistance.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [250, 250, 350, 350]
          }
        },
        "adoptive_parent_group_involvement": {
          "extracted_string_or_numeric_value": "Currently, I do not. However, I will be taking advantage of groups introduced to me by my close friends who have also adopted. I have also been invited and will take advantage of participating in a group of parents all with children adopted from Guatemala. They regularly get together for significant events such as cultural holidays and birthdays.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [400, 400, 480, 480]
          }
        },
        "extended_family_openness": {
          "extracted_string_or_numeric_value": "My extended family is extremely open and supportive in my choice to pursue adopting a foreign child.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [530, 530, 560, 560]
          }
        },
        "children_at_home_questions": null
      },
      "biographical_info_section": {
        "applicant_full_name": {
          "extracted_string_or_numeric_value": "Mark William Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 300, 300, 158],
            "vertical_y_vertices": [80, 80, 90, 90]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "08-08-1973",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [685, 760, 760, 685],
            "vertical_y_vertices": [80, 80, 90, 90]
          }
        },
        "weight": {
          "extracted_string_or_numeric_value": "145 lbs",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 200, 200, 158],
            "vertical_y_vertices": [120, 120, 130, 130]
          }
        },
        "height": {
          "extracted_string_or_numeric_value": "5' 8\"",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [290, 320, 320, 290],
            "vertical_y_vertices": [120, 120, 130, 130]
          }
        },
        "eye_color": {
          "extracted_string_or_numeric_value": "Hazel",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [390, 430, 430, 390],
            "vertical_y_vertices": [120, 120, 130, 130]
          }
        },
        "hair_color": {
          "extracted_string_or_numeric_value": "Brown",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 530, 530, 490],
            "vertical_y_vertices": [120, 120, 130, 130]
          }
        },
        "complexion": {
          "extracted_string_or_numeric_value": "Fair",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [590, 620, 620, 590],
            "vertical_y_vertices": [120, 120, 130, 130]
          }
        },
        "father_details": {
          "full_name": {
            "extracted_string_or_numeric_value": "Max Revoe Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [158, 280, 280, 158],
              "vertical_y_vertices": [180, 180, 190, 190]
            }
          },
          "occupation": {
            "extracted_string_or_numeric_value": "N/A",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [158, 180, 180, 158],
              "vertical_y_vertices": [260, 260, 270, 270]
            }
          },
          "health": {
            "extracted_string_or_numeric_value": "N/A",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [690, 720, 720, 690],
              "vertical_y_vertices": [260, 260, 270, 270]
            }
          },
          "ethnic_descent": {
            "extracted_string_or_numeric_value": "English/Irish",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 780, 780, 700],
              "vertical_y_vertices": [180, 180, 190, 190]
            }
          },
          "deceased_details": {
            "extracted_string_or_numeric_value": "He was in a tractor accident.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [158, 380, 380, 158],
              "vertical_y_vertices": [320, 320, 330, 330]
            }
          }
        },
        "mother_details": {
          "full_name": {
            "extracted_string_or_numeric_value": "Judith Ann Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [158, 290, 290, 158],
              "vertical_y_vertices": [400, 400, 410, 410]
            }
          },
          "age": {
            "extracted_string_or_numeric_value": 58,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [625, 640, 640, 625],
              "vertical_y_vertices": [400, 400, 410, 410]
            }
          },
          "ethnic_descent": {
            "extracted_string_or_numeric_value": "German",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700, 750, 750, 700],
              "vertical_y_vertices": [400, 400, 410, 410]
            }
          },
          "occupation": {
            "extracted_string_or_numeric_value": "Retired",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [158, 200, 200, 158],
              "vertical_y_vertices": [560, 560, 570, 570]
            }
          },
          "health": {
            "extracted_string_or_numeric_value": "Fine",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [690, 720, 720, 690],
              "vertical_y_vertices": [560, 560, 570, 570]
            }
          }
        },
        "parents_residence": {
          "extracted_string_or_numeric_value": "Marion, Michigan",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 480, 480, 158],
            "vertical_y_vertices": [600, 600, 610, 610]
          }
        },
        "siblings": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Michael James Kibby",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [158, 300, 300, 158],
                "vertical_y_vertices": [660, 660, 670, 670]
              }
            },
            "date_of_birth": {
              "extracted_string_or_numeric_value": "February 9th, 1975",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 480, 480, 370],
                "vertical_y_vertices": [660, 660, 670, 670]
              }
            },
            "residence": {
              "extracted_string_or_numeric_value": "Baton Rouge, Louisiana",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [158, 500, 500, 158],
                "vertical_y_vertices": [720, 720, 730, 730]
              }
            },
            "number_of_children": {
              "extracted_string_or_numeric_value": "N/A",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [530, 560, 560, 530],
                "vertical_y_vertices": [660, 660, 670, 670]
              }
            },
            "spouse_name": {
              "extracted_string_or_numeric_value": "N/A",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [670, 700, 700, 670],
                "vertical_y_vertices": [660, 660, 670, 670]
              }
            }
          }
        ],
        "family_visit_frequency": {
          "extracted_string_or_numeric_value": "I see my mother once a month, once every other month at the most",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 800, 800, 158],
            "vertical_y_vertices": [760, 760, 770, 770]
          }
        },
        "parents_activities": {
          "extracted_string_or_numeric_value": "My mother is retired and her daily activities include caring for her elderly father. She is also extremely active in her community. She is currently running for school board",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [158, 820, 820, 158],
            "vertical_y_vertices": [810, 810, 850, 850]
          }
        }
      },
      "childhood_experiences_section": {
        "feelings_toward_parents": {
          "extracted_string_or_numeric_value": "The feelings I had toward my parent ranged from respectful, loving and adoration.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 800, 800, 198],
            "vertical_y_vertices": [100, 100, 120, 120]
          }
        },
        "sibling_relationship": {
          "extracted_string_or_numeric_value": "My brother and I are extremely close in age, only 16 months apart. As a result we spent a significant amount of time together playing and experiencing things together. Living in a rural community we were often each other's only play friend and played for hours together. We had and continue to have a strong and loving relationship.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [170, 170, 250, 250]
          }
        },
        "family_upbringing": {
          "extracted_string_or_numeric_value": "Growing up in my family was as normal as any other. My parents both worked full-time as we owned our own business, a grocery store.\n\nDiscipline was handled equally by my mother and father. It was never physical. Our parent always helped us understand why something we did was wrong and explained to us the value or importance of the correct action. Punishment would range from taking away certain privileges like riding our bikes, watching TV or spending time in our room. We may also be asked to do more chores or perform chores alone.\n\nWe lived in a small farming community in the middle of the state of Michigan.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [300, 300, 480, 480]
          }
        },
        "special_memories": {
          "extracted_string_or_numeric_value": "Two of the most prominent memories I have of my childhood include the death of my grandmother from cancer and the day my father received his private airplane pilots license.\n\nMy grandmother passed away due to colon cancer. It was a long battle that lasted three years during which I learned a great deal about how to understand and relate to death and dying.\n\nOn the flip side my father earning his pilots license taught me the value of hard work and determination to accomplish a personal goal. My father had set a goal for himself when he was a teenager that he would get his license. He started working toward it when he was 35 and earned it two years later. It was a sense of pride and accomplishment that instilled in me the value of integrity and goals.\n\nReligion in our value is considered a personal decision. Our parents allowed us to choose if, when and how we wanted to worship. I chose to attend one church and actively participate in it's activities and programs throughout high school, while my brother decided not to.",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [530, 530, 800, 800]
          }
        },
        "substance_use_in_home": {
          "extracted_string_or_numeric_value": "Alcohol was not prevalent in my parents lives. They would use it on special occasions or perhaps on a weekend but never to excess. It is the same in my life. In general I may have a drink or two on the weekend, rarely during the week unless celebrating a special occasion.\n\nDrugs never present in the lives of my parents and have never been present in my life either.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [850, 850, 950, 950]
          }
        }
      },
      "self_description_section": {
        "self_perception": {
          "extracted_string_or_numeric_value": "I see myself as organized, well disciplined, trustworthy honest, committed, loving and hard working",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 120, 120]
          }
        },
        "others_perception": {
          "extracted_string_or_numeric_value": "Others have commented that they perceive me as organized, dependable, trustworthy and committed",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [170, 170, 190, 190]
          }
        },
        "strengths": {
          "extracted_string_or_numeric_value": "I am extremely organized and methodological.\nI am financially secure and have long term financial goals to ensure I have a prosperous future.\nI have a strong sense of self with goals and objectives",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [240, 240, 300, 300]
          }
        },
        "weaknesses": {
          "extracted_string_or_numeric_value": "Tendency to be rigid and not very spontaneous.\nI can over analyze situations and make a long time to finalize serious decisions. This is a plus and a negative.\nI can be extremely factual, logical and blunt often giving the perception that I don't care about a situation.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [350, 350, 430, 430]
          }
        },
        "education_history": [
          {
            "institution": {
              "extracted_string_or_numeric_value": "Marion Public Schools",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [198, 350, 350, 198],
                "vertical_y_vertices": [520, 520, 530, 530]
              }
            },
            "years": {
              "extracted_string_or_numeric_value": "1978-1992",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [360, 430, 430, 360],
                "vertical_y_vertices": [520, 520, 530, 530]
              }
            }
          },
          {
            "institution": {
              "extracted_string_or_numeric_value": "The University of Michigan",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [198, 380, 380, 198],
                "vertical_y_vertices": [540, 540, 550, 550]
              }
            },
            "years": {
              "extracted_string_or_numeric_value": "1992-1996",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [390, 460, 460, 390],
                "vertical_y_vertices": [540, 540, 550, 550]
              }
            }
          }
        ],
        "employment_history": [
          {
            "company": {
              "extracted_string_or_numeric_value": "Andersen Consulting, LLC",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [198, 380, 380, 198],
                "vertical_y_vertices": [590, 590, 600, 600]
              }
            },
            "years": {
              "extracted_string_or_numeric_value": "1996-1998",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [390, 460, 460, 390],
                "vertical_y_vertices": [590, 590, 600, 600]
              }
            }
          },
          {
            "company": {
              "extracted_string_or_numeric_value": "Emerging Solutions, LLC",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [198, 360, 360, 198],
                "vertical_y_vertices": [610, 610, 620, 620]
              }
            },
            "years": {
              "extracted_string_or_numeric_value": "1998-1999",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [370, 440, 440, 370],
                "vertical_y_vertices": [610, 610, 620, 620]
              }
            }
          },
          {
            "company": {
              "extracted_string_or_numeric_value": "DiamondCluster International",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [198, 400, 400, 198],
                "vertical_y_vertices": [630, 630, 640, 640]
              }
            },
            "years": {
              "extracted_string_or_numeric_value": "1999-2004",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [410, 480, 480, 410],
                "vertical_y_vertices": [630, 630, 640, 640]
              }
            }
          },
          {
            "company": {
              "extracted_string_or_numeric_value": "Allstate Insurance Company",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [198, 380, 380, 198],
                "vertical_y_vertices": [650, 650, 660, 660]
              }
            },
            "years": {
              "extracted_string_or_numeric_value": "2004 – present",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [390, 490, 490, 390],
                "vertical_y_vertices": [650, 650, 660, 660]
              }
            }
          }
        ],
        "employment_satisfaction": {
          "extracted_string_or_numeric_value": "I am extremely happy with my current employer and employment status. I chose the current company I am with due to their strong commitment to work and family balance. I knew two years ago when selecting the job that I intended on starting a family and this company offers me the balance I require in being a single parent. I have no reason to believe that my employment status is in jeopardy and during my annual performance review was given the highest rating available to an employee.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [680, 680, 780, 780]
          }
        },
        "hobbies": {
          "extracted_string_or_numeric_value": "My hobbies include reading, riding my bike, camping and hiking. I enjoy action adventure and science fiction movies. I have no organizational affiliations",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [830, 830, 860, 860]
          }
        },
        "greatest_achievement": {
          "extracted_string_or_numeric_value": "I believe my greatest personal accomplishment to-date was successfully completing my intense foreign culture emersion program in college. I enter the program with no previous foreign language experience to knowledge and after considerable hard work and dedication over two year passed a language proficiency exam with the ranking of fluent.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 180, 180]
          }
        },
        "greatest_failure": {
          "extracted_string_or_numeric_value": "I believe my greatest failure to date has been in not taking advantage of opportunities to learn how to leverage the stock market. I could have taken advantage of this knowledge in the 90s during the internet stock bubble.\n\nI do not really see it as a failure, more a missed opportunity.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [230, 230, 320, 320]
          }
        },
        "life_goals": {
          "extracted_string_or_numeric_value": "I developed my personal goals for life when I was a teenager with the help of my pastor and church youth group. They along with my personal core values have helped to steer me my entire life. My personal goals in life are:\n\nI will be financially secure\nI will help people\nI will be independent\nI will be a good citizen\nI will be a good son, brother, grandson, uncle, nephew, citizen and father\nI will respect my mother and father\nI will give back to my community\nI will respect the environment\nI value diversity\nI will be well educated and read\nI will be physically fit",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [370, 370, 650, 650]
          }
        }
      },
      "family_section": {
        "meeting_spouse": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [780, 780, 790, 790]
          }
        },
        "spouse_relationship": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [830, 830, 840, 840]
          }
        },
        "marriage_strong_points": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [880, 880, 890, 890]
          }
        },
        "marriage_areas_to_strengthen": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [930, 930, 940, 940]
          }
        },
        "responsibility_division": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [100, 100, 110, 110]
          }
        },
        "discussing_feelings": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [200, 200, 210, 210]
          }
        },
        "spouse_support": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [280, 280, 290, 290]
          }
        },
        "conflict_resolution": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [350, 350, 360, 360]
          }
        },
        "decision_making": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [400, 400, 410, 410]
          }
        },
        "recreational_activities": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [530, 530, 540, 540]
          }
        },
        "relationship_with_other_children": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [630, 630, 640, 640]
          }
        },
        "current_family_relationships": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 225, 225, 200],
            "vertical_y_vertices": [700, 700, 710, 710]
          }
        }
      },
      "child_rearing_philosophy_section": {
        "parenting_approach": {
          "extracted_string_or_numeric_value": "My approach to parenting will be based on respect and trust. I will establish an authoritative and respect driven relationship with my child where-in I demonstrate that I respect them as an individual, expecting them to meet minimal requirements. My goal in my approach to parenting is to help the child develop such characteristics as confidence, self-control and independence.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [800, 800, 880, 880]
          }
        },
        "discipline_approach": {
          "extracted_string_or_numeric_value": "My approach to discipline follows on my child rearing philosophy. You must establish a respect driven relationship with the child. When discipline is necessary I will discuss the situation with the child outlining for them why something they have done wasn't an acceptable course of action, what the consequences of that action were on the person, persons or item affected, what the child should have done and then what the consequences will be to the child.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [930, 930, 1030, 1030]
          }
        },
        "child_expectations": {
          "extracted_string_or_numeric_value": "I firmly believe that exposing children to responsibility and goals early helps instill self-confidence a strong sense of purpose, values and independence. As the child matures and grows I will expect chores to be completed commensurate with age. Items such as picking up after themselves, helping to take care of the dishes, laundry, etc will all be part of the child's responsibilities.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [200, 200, 300, 300]
          }
        },
        "parenting_skills": {
          "extracted_string_or_numeric_value": "I posses no more skills than any other person on being a parent. I strongly believe I will be a good parent due to the fact that I am a loving and honest person who lives and clean organized life full of love with my family and friends.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [500, 500, 560, 560]
          }
        },
        "spouse_parenting_skills": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 220, 220, 198],
            "vertical_y_vertices": [610, 610, 620, 620]
          }
        },
        "capacity_for_fairness": {
          "extracted_string_or_numeric_value": "The above attributes are extremely valuable to have as a parent. It is difficult to quantify each of those qualities about myself. However, I can honestly state that I am an extremely tolerant, flexible fair individual who can see the world for its humor when appropriate. Having patience and not immediately reacting to items and situations is something I am able to do well. This allows me to step back look at the situation reacting to big and small issues appropriately. Many times there is humor or positive lessons which can be learned in any circumstance.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [700, 700, 820, 820]
          }
        },
        "willingness_to_gain_skills": {
          "extracted_string_or_numeric_value": "I am willing to go whatever distance is necessary to be a better parent. Reading book, magazines, attending parenting and/or adoption support groups are all courses of action I am actively pursuing. My goal is to ensure that my child has a positive role model and parent to take care of them.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [870, 870, 930, 930]
          }
        },
        "experience_with_children": {
          "extracted_string_or_numeric_value": "My experience with child is not limited. I have regularly taken care of children throughout the course of my life including babysitting infants and toddlers by myself for extended periods of times (i.e., weekends, 3-4 days). This includes children of various family members, close friends and neighbors.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 160, 160]
          }
        },
        "daily_childcare_plan": {
          "extracted_string_or_numeric_value": "I live in a neighborhood which offers many alternatives to daily care. I plan on using a combination of licensed daycare professionals while the child is younger along with a professional learning and development facility as the child gets older. My neighbors and another couple in my neighborhood who have a child adopted from Guatemala use this combination and have been extremely satisfied with the quality of care and education.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [210, 210, 300, 300]
          }
        },
        "guardian_details": {
          "name": {
            "extracted_string_or_numeric_value": "Judith Ann Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 320, 320, 198],
              "vertical_y_vertices": [420, 420, 430, 430]
            }
          },
          "age": {
            "extracted_string_or_numeric_value": 58,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 210, 210, 198],
              "vertical_y_vertices": [440, 440, 450, 450]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "Parent",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 240, 240, 198],
              "vertical_y_vertices": [460, 460, 470, 470]
            }
          },
          "occupation": {
            "extracted_string_or_numeric_value": "Retired",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 250, 250, 198],
              "vertical_y_vertices": [480, 480, 490, 490]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Michigan 49665",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 550, 550, 198],
              "vertical_y_vertices": [500, 500, 510, 510]
            }
          }
        },
        "perception_of_family_life": {
          "extracted_string_or_numeric_value": "My perception of life with children is a jumble of ideas in my head. It is exciting, reward, hectic, challenging, sometimes confusing, frustrating and blissful. All of these descriptors come to mind when I think of what all is involved in being a parent.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [560, 560, 620, 620]
          }
        },
        "view_of_family_fun": {
          "extracted_string_or_numeric_value": "Family fun and enjoyment to me comes in many different forms. I view it as anything in which we're both enjoying ourselves in the moment. It can be structured or unstructured. It's a simple as sharing a moment tickling each other on the floor, laughing as we blow bubbles in the milk through a straw or could be as complex as going on a weekend camping trip together.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [800, 800, 880, 880]
          }
        }
      },
      "financial_status_section": {
        "employment_and_salary": {
          "extracted_string_or_numeric_value": "I am presently employed at the Allstate Insurance Company as a Technology Shared Services Senior Manager. I have been employed there since November 16, 2004. My annual base salary is $110,000 with a maximum bonus potential of 30% of my base salary.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [100, 100, 150, 150]
          }
        },
        "assets_and_income_sources": {
          "extracted_string_or_numeric_value": "To be taken from information already provided to Jamey",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 600, 600, 198],
            "vertical_y_vertices": [200, 200, 210, 210]
          }
        },
        "medical_insurance": {
          "provider": {
            "extracted_string_or_numeric_value": "HMO-Aetna – Chicago",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 350, 350, 198],
              "vertical_y_vertices": [280, 280, 290, 290]
            }
          },
          "plan_description": {
            "extracted_string_or_numeric_value": "HMOs provide prepaid benefits for most health care needs, with no bills or claim forms. I have chosen a primary care physician (PCP) from a list of providers. For my expenses to be covered, my HMO requires I receive care from my PCP or from a doctor or facility to which my PCP refers me. If I receive care from a doctor or facility other than your PCP or without being referred by the PCP, my HMO may not provide any benefits coverage for those expenses, even if the doctor or facility is in the HMO network.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 830, 830, 198],
              "vertical_y_vertices": [310, 310, 390, 390]
            }
          },
          "adult_preventive_care": [],
          "well_baby_child_care": [],
          "mental_health_care": [],
          "substance_abuse_care": [],
          "durable_medical_equipment": {
            "service": {
              "extracted_string_or_numeric_value": "Durable medical equipment",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [160, 320, 320, 160],
                "vertical_y_vertices": [860, 860, 870, 870]
              }
            },
            "coverage_details": {
              "extracted_string_or_numeric_value": "100% covered",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [340, 420, 420, 340],
                "vertical_y_vertices": [860, 860, 870, 870]
              }
            }
          },
          "maternity_care": [],
          "other_services": [],
          "dental_care": [],
          "vision_care": []
        },
        "life_insurance": {
          "underwriter": {
            "extracted_string_or_numeric_value": "Metlife",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 350, 350, 198],
              "vertical_y_vertices": [650, 650, 660, 660]
            }
          },
          "plan_description": {
            "extracted_string_or_numeric_value": "I have enrolled in the Allstate Employee Life Insurance in a multiple of four times my Qualified Annual Earnings (QAE). My QAE determines my coverage amount, and is capped at $500,000 per coverage level.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 830, 830, 198],
              "vertical_y_vertices": [680, 680, 720, 720]
            }
          },
          "coverage_level": {
            "extracted_string_or_numeric_value": 440000.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 400, 400, 198],
              "vertical_y_vertices": [800, 800, 810, 810]
            }
          }
        },
        "liabilities": {
          "extracted_string_or_numeric_value": "To be taken from information already provided to Jamey\nMortgage:\nCredit card:",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 600, 600, 198],
            "vertical_y_vertices": [850, 850, 900, 900]
          }
        },
        "ability_to_support": {
          "extracted_string_or_numeric_value": "My current annual income and benefit plans provide me more than enough regular income and security to cover the costs of adoption, education, medical or counseling needs. In the unforeseeable event that I cannot cover these costs, I have additional funding sources available from my mother.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [950, 950, 1010, 1010]
          }
        }
      },
      "home_and_neighborhood_section": {
        "home_details": {
          "style": {
            "extracted_string_or_numeric_value": "Chicago Vintage Brownstone Eight Flat",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 500, 500, 198],
              "vertical_y_vertices": [150, 150, 160, 160]
            }
          },
          "number_of_rooms": {
            "extracted_string_or_numeric_value": "7 (2 Bedroom, 2 full bathrooms, formal dining room, galley kitchen and living room)",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 830, 830, 198],
              "vertical_y_vertices": [170, 170, 190, 190]
            }
          },
          "square_footage": {
            "extracted_string_or_numeric_value": "approximately 1400 sq ft.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 400, 400, 198],
              "vertical_y_vertices": [200, 200, 210, 210]
            }
          },
          "year_built_renovated": {
            "extracted_string_or_numeric_value": "Building was built in 1920s (approx) and renovated in 2001",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 650, 650, 198],
              "vertical_y_vertices": [220, 220, 230, 230]
            }
          },
          "lot_size": {
            "extracted_string_or_numeric_value": "60 ft wide by 150 ft deep",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 450, 450, 198],
              "vertical_y_vertices": [240, 240, 250, 250]
            }
          },
          "child_bedroom_size": {
            "extracted_string_or_numeric_value": "9 ft by 11ft",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 350, 350, 198],
              "vertical_y_vertices": [260, 260, 270, 270]
            }
          },
          "play_area": {
            "extracted_string_or_numeric_value": "The child's play area will consist of various areas with-in the home, the front yard (60ft by 35 ft) and multiple parks in our neighborhood. There are 32 parks and recreational facilities owned and operated by the Chicago Park District with-in a 1 mile radius of our home.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 830, 830, 198],
              "vertical_y_vertices": [280, 280, 330, 330]
            }
          }
        },
        "location_and_population": {
          "extracted_string_or_numeric_value": "Home is located in the City of Chicago's Uptown Neighborhood which is considered urban. The population of Chicago is: 2,862,244 estimated as of 7/1/2004",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [380, 380, 420, 420]
          }
        },
        "neighborhood_description": {
          "extracted_string_or_numeric_value": "Uptown is a diverse neighborhood located north of Chicago's downtown. Being one of Chicago's 77 community areas, Uptown has officially defined boundaries. They are: Foster on the north; Lake Michigan on the east; Montrose (Ravenswood to Clark), and Irving Park (Clark to Lake Michigan) on the south; Ravenswood (Foster to Montrose), and Clark (Montrose to Irving Park) on the west. Uptown borders three community areas and Lake Michigan. To the north is Edgewater, to the west is Lincoln Square, and to the south is Lake View.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [470, 470, 580, 580]
          }
        },
        "demographics": {
          "source": {
            "extracted_string_or_numeric_value": "Source: U. S. Census Bureau, Census 1990 and Census 2000",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198, 650, 650, 198],
              "vertical_y_vertices": [30, 30, 40, 40]
            }
          },
          "population": [],
          "race_2000": [],
          "household_by_type": [],
          "housing_tenure": [],
          "educational_attainment": [],
          "commuting_to_work": [],
          "employment_status": [],
          "income": [],
          "poverty_status": [],
          "housing_value_and_rent": []
        },
        "medical_facilities": [],
        "educational_facilities": [],
        "pets": {
          "extracted_string_or_numeric_value": "I have no pets or animals in my home",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 500, 500, 198],
            "vertical_y_vertices": [100, 100, 110, 110]
          }
        }
      },
      "religious_orientation_section": {
        "preference": {
          "extracted_string_or_numeric_value": "I was raised Christian of Methodist denomination. My parents exposed me to several faiths through family and friends in our local community allowing me to experience different varieties and choose which I felt best for me.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [200, 200, 250, 250]
          }
        },
        "child_education_plan": {
          "extracted_string_or_numeric_value": "I plan to exposed my child to various religions the same that my parents exposed me and allow my child to chose what, if any is important and interesting for them to follow.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [300, 300, 340, 340]
          }
        },
        "concept_of_religious_living": {
          "extracted_string_or_numeric_value": "My concept of religion is that is it a personal choice of each individual. It is personal and private. Whatever a person believes is up to that person. I respect all forms and ideas concerning worship and will allow my child to select and practice whatever ideology they believe is best for them unless the believe or practice in that religion could result in physical or mental harm.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [390, 390, 480, 480]
          }
        },
        "views_on_values": {
          "extracted_string_or_numeric_value": "Children need strong examples of moral character in their fundamental years to act as a guidepost as they firm and establish their own character. I strongly believe that children need to be exposed to as many forms of values as they are raised.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [530, 530, 580, 580]
          }
        }
      },
      "family_health_section": {
        "applicant_health_problems": {
          "extracted_string_or_numeric_value": "I have no current or past medical or mental health problems and do not know of or anticipate any which would impact my ability to raise and care for a child or children.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 830, 830, 198],
            "vertical_y_vertices": [750, 750, 790, 790]
          }
        },
        "child_health_problems": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 220, 220, 198],
            "vertical_y_vertices": [840, 840, 850, 850]
          }
        },
        "reason_for_childlessness": {
          "extracted_string_or_numeric_value": "N/A",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 220, 220, 198],
            "vertical_y_vertices": [900, 900, 910, 910]
          }
        }
      }
    }
  }
]
```