An expert forensic data architect, I have meticulously analyzed the provided 2006 adoption home study document. Adhering to a Zero-Trust mandate, I've designed a resilient Pydantic V2 schema that captures the document's complex structure, including its financial data points, for which a GAAP-style checksum validator has been implemented.

### BLOCK 1 (Python Pydantic V2)
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator, ValidationError

# BASE CLASSES (Do not modify)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# SCHEMA DEFINITION
class ProspectiveParent(BaseModel):
    model_config = ConfigDict(extra='forbid')
    full_name: ForensicDataEntity
    ssn: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: ForensicDataEntity

class Preparer(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    credentials: ForensicDataEntity
    title: ForensicDataEntity
    phone_number: ForensicDataEntity
    email: ForensicDataEntity

class AdoptionDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    type_of_adoption: ForensicDataEntity
    purpose_of_report: ForensicDataEntity
    desired_child_description: ForensicDataEntity

class ParentBackground(BaseModel):
    model_config = ConfigDict(extra='forbid')
    ethnic_descent: ForensicDataEntity
    physical_description: ForensicDataEntity
    hobbies: ForensicDataEntity
    education_summary: ForensicDataEntity
    employment_history: ForensicDataEntity
    family_and_childhood_summary: ForensicDataEntity

class HomeAndCommunity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    home_description: ForensicDataEntity
    home_size_sqft: ForensicDataEntity
    neighborhood: ForensicDataEntity
    city_population: ForensicDataEntity
    community_composition: ForensicDataEntity

class Liabilities(BaseModel):
    model_config = ConfigDict(extra='forbid')
    home_loan: ForensicDataEntity
    credit_cards: ForensicDataEntity
    other_liabilities: ForensicDataEntity
    total_liabilities: ForensicDataEntity

    @model_validator(mode='after')
    def validate_liabilities_checksum(self) -> 'Liabilities':
        home_loan = self.home_loan.extracted_string_or_numeric_value
        credit_cards = self.credit_cards.extracted_string_or_numeric_value
        other = self.other_liabilities.extracted_string_or_numeric_value
        total = self.total_liabilities.extracted_string_or_numeric_value

        if not all(isinstance(val, (int, float)) for val in [home_loan, credit_cards, other, total]):
            raise ValueError("All liability values must be numeric for checksum validation.")

        calculated_sum = round(home_loan + credit_cards + other, 2)
        if calculated_sum != round(total, 2):
            raise ValueError(f"Liabilities checksum failed: {calculated_sum} != {total}")
        return self

class FinancialInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    employer: ForensicDataEntity
    position: ForensicDataEntity
    employment_since: ForensicDataEntity
    annual_salary: ForensicDataEntity
    potential_bonus: ForensicDataEntity
    liabilities: Liabilities

class SupportingInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    dcfs_clearance_date: ForensicDataEntity
    state_police_clearance_date: ForensicDataEntity
    physician_exam_date: ForensicDataEntity
    physician_summary: ForensicDataEntity
    background_check_summary: ForensicDataEntity

class Guardianship(BaseModel):
    model_config = ConfigDict(extra='forbid')
    guardian_name: ForensicDataEntity
    guardian_relationship: ForensicDataEntity

class Assessment(BaseModel):
    model_config = ConfigDict(extra='forbid')
    recommendation: ForensicDataEntity
    restrictions: ForensicDataEntity
    complaint_contact_name: ForensicDataEntity
    complaint_contact_department: ForensicDataEntity
    complaint_contact_phone: ForensicDataEntity

class Notarization(BaseModel):
    model_config = ConfigDict(extra='forbid')
    date_subscribed: ForensicDataEntity
    notary_name: ForensicDataEntity
    commission_expiry_date: ForensicDataEntity

class AgencyDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone_number: ForensicDataEntity
    license_permit_number: ForensicDataEntity
    license_expiration_date: ForensicDataEntity

class HomeStudy2006(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    report_date: ForensicDataEntity
    prospective_parent: ProspectiveParent
    preparer: Preparer
    adoption_details: AdoptionDetails
    summary_of_contacts: ForensicDataEntity
    parent_background: ParentBackground
    marriage_quality: ForensicDataEntity
    parenting_philosophy: ForensicDataEntity
    child_care_plans: ForensicDataEntity
    home_and_community: HomeAndCommunity
    financials: FinancialInformation
    religion: ForensicDataEntity
    supporting_info: SupportingInformation
    guardianship: Guardianship
    female_role_models: ForensicDataEntity
    rights_of_child: ForensicDataEntity
    assessment_and_recommendations: Assessment
    notarization: Notarization
    agency_details: AgencyDetails
```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2006-02-20_Home_Study_Mark_Kibby",
    "should_pass": true,
    "taxonomy_lane": "HomeStudy2006",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "ADOPTION HOME STUDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [409, 590],
          "vertical_y_vertices": [109, 120]
        }
      },
      "report_date": {
        "extracted_string_or_numeric_value": "2006-02-20",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [420, 579],
          "vertical_y_vertices": [125, 135]
        }
      },
      "prospective_parent": {
        "full_name": {
          "extracted_string_or_numeric_value": "Mark William Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [244, 400],
            "vertical_y_vertices": [200, 210]
          }
        },
        "ssn": {
          "extracted_string_or_numeric_value": "366-72-9323",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [244, 340],
            "vertical_y_vertices": [216, 226]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "1973-08-08",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [244, 375],
            "vertical_y_vertices": [232, 242]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "4618 N. Racine Avenue, Unit 7 Chicago, Illinois 60640",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [336, 570],
            "vertical_y_vertices": [264, 292]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "(773) 251-0539",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [336, 445],
            "vertical_y_vertices": [316, 326]
          }
        }
      },
      "preparer": {
        "name": {
          "extracted_string_or_numeric_value": "Jamie J. Janssen Casey",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [336, 530],
            "vertical_y_vertices": [356, 366]
          }
        },
        "credentials": {
          "extracted_string_or_numeric_value": "M.S.W., L.C.S.W., C-AYCFSW",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [535, 700],
            "vertical_y_vertices": [356, 366]
          }
        },
        "title": {
          "extracted_string_or_numeric_value": "Executive Director – Illinois Branch",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 425],
            "vertical_y_vertices": [208, 220]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "(708) 363-3338",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 290],
            "vertical_y_vertices": [400, 410]
          }
        },
        "email": {
          "extracted_string_or_numeric_value": "djascasey@comcast.net",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [194, 340],
            "vertical_y_vertices": [416, 426]
          }
        }
      },
      "adoption_details": {
        "type_of_adoption": {
          "extracted_string_or_numeric_value": "Agency international through Guatemala",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [196, 550],
            "vertical_y_vertices": [396, 406]
          }
        },
        "purpose_of_report": {
          "extracted_string_or_numeric_value": "This is a home study for the purpose of an international adoption. Madison Adoption Associates is involved in the capacity of home study agency. A Guatemalan adoption program will be utilized for the placing agency.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [196, 810],
            "vertical_y_vertices": [444, 495]
          }
        },
        "desired_child_description": {
          "extracted_string_or_numeric_value": "Mark Kibby is a heterosexual male who very much desire to expand his family through the adoption of a child 0-12 months of age. He has been considering adoption for over two years. Mark will be sensitive to any child or children placed with him that may have been subjected to abuse, neglect, separation from and loss of their biological family.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [196, 810],
            "vertical_y_vertices": [640, 735]
          }
        }
      },
      "summary_of_contacts": {
        "extracted_string_or_numeric_value": "Extensive individual in-person and telephone interviews were conducted with the adoptive individual. One home visit was conducted on January 26, 2006 and personal interviews took place on February 18 and 21, 2005. Phone and mail contact has been maintained throughout the process. All contacts have been found to be very favorable.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [196, 810],
          "vertical_y_vertices": [524, 600]
        }
      },
      "parent_background": {
        "ethnic_descent": {
          "extracted_string_or_numeric_value": "German, Irish, and English",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 500],
            "vertical_y_vertices": [140, 150]
          }
        },
        "physical_description": {
          "extracted_string_or_numeric_value": "Mark is 32 years old and is of German, Irish, and English descent. He stands 5'8\" tall, weighs 145 pounds and has hazel eyes and brown hair.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [140, 180]
          }
        },
        "hobbies": {
          "extracted_string_or_numeric_value": "biking, reading, camping, and hiking",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 600],
            "vertical_y_vertices": [260, 270]
          }
        },
        "education_summary": {
          "extracted_string_or_numeric_value": "Mark attended his local grade school and high school. He remembers his school experiences as being exciting and very busy. He participated in student council, marching band, football, and was class president four years running. He graduated high school in 1992 and attended The University of Michigan from 1992-1996. He received a degree in Spanish Culture and Literature.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [520, 620]
          }
        },
        "employment_history": {
          "extracted_string_or_numeric_value": "After graduating college, he began his career with Andersen Consulting as a Business Analyst and worked there until 1998. He followed that employment by working with Emerging Solutions, LLC for one year and then began working with Diamond Cluster International in 1999 until 2004. Mark made the decision to seek new employment to lessen his work hours as a result of anticipating adopting a child. He began working with Allstate Insurance Company in 2004 and continues employment with this agency to date.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [625, 750]
          }
        },
        "family_and_childhood_summary": {
          "extracted_string_or_numeric_value": "Mark William Kibby was born on August 8, 1973 in Cadillac, Michigan to Judith Ann (Munn) and Max Revoe Kibby. His mother is of English and Irish descent and his father is of German descent. While Mark was growing up, his father and mother owned their own grocery store in their hometown. He is the older of two siblings. He describes his relationship with his brother, Michael, as being very close. Mark's father past away in 1999 as a result of a tractor accident on the family's farm.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [200, 850]
          }
        }
      },
      "marriage_quality": {
        "extracted_string_or_numeric_value": "Mark has never been married. Mark has stated that he is open to marriage in the future should he meet the right person. He also understands that this person would have to be willing to accept both him and his child, placing his child's interests and needs as the priority.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 810],
          "vertical_y_vertices": [290, 350]
        }
      },
      "parenting_philosophy": {
        "extracted_string_or_numeric_value": "Mark currently has no children. He believes his approach to parenting will be based on respect and trust. He plans to establish an authoritative and respect driven relationship with is child by demonstrating that he respects his child as an individual. He hopes to instill such characteristics such as confidence, self-control and independence. Mark will not use any physical forms of discipline.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 810],
          "vertical_y_vertices": [380, 480]
        }
      },
      "child_care_plans": {
        "extracted_string_or_numeric_value": "After adopting a child, Mark plans on remaining home for three weeks after placement to help the child adjust to his/her new environment. When he returns to his work full-time, Mark plans on utilizing Little Hands, which is a licensed Day Care facility adjacent to his work for childcare.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 810],
          "vertical_y_vertices": [560, 630]
        }
      },
      "home_and_community": {
        "home_description": {
          "extracted_string_or_numeric_value": "Mark lives alone in a Brownstone flat style home, located in a lovely neighborhood. His home is in the city of Chicago, Illinois. His home was built in the 1920's and has approximately 1400 square feet of living space. His home is divided into 7 rooms including two furnished bedrooms, two bathrooms, a kitchen, living room and dining room.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [660, 750]
          }
        },
        "home_size_sqft": {
          "extracted_string_or_numeric_value": 1400,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 620],
            "vertical_y_vertices": [690, 700]
          }
        },
        "neighborhood": {
          "extracted_string_or_numeric_value": "Uptown Neighborhood",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 550],
            "vertical_y_vertices": [760, 770]
          }
        },
        "city_population": {
          "extracted_string_or_numeric_value": 2852244,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 750],
            "vertical_y_vertices": [760, 770]
          }
        },
        "community_composition": {
          "extracted_string_or_numeric_value": "It is comprised of people from many ethnic groups including, Caucasian, African-American, Asian, and Hispanic families.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [820, 850]
          }
        }
      },
      "financials": {
        "employer": {
          "extracted_string_or_numeric_value": "Allstate Insurance Company",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 550],
            "vertical_y_vertices": [140, 150]
          }
        },
        "position": {
          "extracted_string_or_numeric_value": "Technology Shared Services Senior Manager",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 600],
            "vertical_y_vertices": [155, 165]
          }
        },
        "employment_since": {
          "extracted_string_or_numeric_value": "November 2004",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 520],
            "vertical_y_vertices": [170, 180]
          }
        },
        "annual_salary": {
          "extracted_string_or_numeric_value": 115512,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 370],
            "vertical_y_vertices": [185, 195]
          }
        },
        "potential_bonus": {
          "extracted_string_or_numeric_value": "30% of his base salary",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550, 750],
            "vertical_y_vertices": [185, 195]
          }
        },
        "liabilities": {
          "home_loan": {
            "extracted_string_or_numeric_value": 226466,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [320, 380],
              "vertical_y_vertices": [280, 290]
            }
          },
          "credit_cards": {
            "extracted_string_or_numeric_value": 12923,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 550],
              "vertical_y_vertices": [280, 290]
            }
          },
          "other_liabilities": {
            "extracted_string_or_numeric_value": 61000,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [600, 650],
              "vertical_y_vertices": [295, 305]
            }
          },
          "total_liabilities": {
            "extracted_string_or_numeric_value": 300389,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 0],
              "vertical_y_vertices": [0, 0]
            }
          }
        }
      },
      "religion": {
        "extracted_string_or_numeric_value": "Mark was raised Christian of Methodist denomination. His parents exposed him to several faiths through family and friends within his local community and allowed his to choose which religion met his personal needs. He plans to expose his child to various religions, the same way that his parents exposed him, and will allow his child to chose a religion when the child is mature enough to make such a decision.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 810],
          "vertical_y_vertices": [360, 460]
        }
      },
      "supporting_info": {
        "dcfs_clearance_date": {
          "extracted_string_or_numeric_value": "2006-01-19",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 600],
            "vertical_y_vertices": [500, 510]
          }
        },
        "state_police_clearance_date": {
          "extracted_string_or_numeric_value": "2006-01-18",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550, 650],
            "vertical_y_vertices": [550, 560]
          }
        },
        "physician_exam_date": {
          "extracted_string_or_numeric_value": "2005-12-29",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 500],
            "vertical_y_vertices": [750, 760]
          }
        },
        "physician_summary": {
          "extracted_string_or_numeric_value": "He was found to be in excellent health both physically and emotionally and having a normal life expectancy as best as can be determined. There is no evidence of communicable diseases, alcohol or drug addiction.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [765, 810]
          }
        },
        "background_check_summary": {
          "extracted_string_or_numeric_value": "Madison Adoption Associates received a clearance date of January 19, 2006 from the Illinois Department of Children and Family Services on their Child Abuse and Neglect Screening (CANTS) for Mark Kibby. He is in good standing with all law enforcement departments (letters on file from the Illinois State Police Department dated January 18, 2006) and has no prior record of child abuse or neglect. Mark declared that neither have any history of arrests or criminal history.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [500, 600]
          }
        }
      },
      "guardianship": {
        "guardian_name": {
          "extracted_string_or_numeric_value": "Judith Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 500],
            "vertical_y_vertices": [140, 150]
          }
        },
        "guardian_relationship": {
          "extracted_string_or_numeric_value": "mother",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 350],
            "vertical_y_vertices": [140, 150]
          }
        }
      },
      "female_role_models": {
        "extracted_string_or_numeric_value": "Mark's mother and aunts will be strong influences in the life of his child. The primary female role model in the life of his child will be his cousin, Julie Weston. Julie will be moving to Chicago, Illinois during the summer of 2006.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 810],
          "vertical_y_vertices": [240, 300]
        }
      },
      "rights_of_child": {
        "extracted_string_or_numeric_value": "Mark Kibby, does hereby swear and affirm that any child adopted by him will be treated with the same respect, care, love and attention and will have the same rights and privileges as any biological child. Furthermore, please be advised that according to the laws of the United Sates of America, children that qualify as orphans and are legally adopted by an American citizen shall have equal rights as children originally born in the United States of America and his/her civil rights will not be restricted in any way.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 810],
          "vertical_y_vertices": [420, 550]
        }
      },
      "assessment_and_recommendations": {
        "recommendation": {
          "extracted_string_or_numeric_value": "Therefore, I recommend and approve Mark Kibby as an adoptive parent to one to three healthy children, of either gender between the ages of 0-3 years of age from Guatemala.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [680, 730]
          }
        },
        "restrictions": {
          "extracted_string_or_numeric_value": "There are no restrictions to the adoption such as nationality, age or gender of the orphan.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 810],
            "vertical_y_vertices": [735, 750]
          }
        },
        "complaint_contact_name": {
          "extracted_string_or_numeric_value": "Mary Donley, MSW",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 650],
            "vertical_y_vertices": [830, 840]
          }
        },
        "complaint_contact_department": {
          "extracted_string_or_numeric_value": "the Illinois Department of Child and Family Services",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 750],
            "vertical_y_vertices": [845, 855]
          }
        },
        "complaint_contact_phone": {
          "extracted_string_or_numeric_value": "217:785:2692",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198, 280],
            "vertical_y_vertices": [140, 150]
          }
        }
      },
      "notarization": {
        "date_subscribed": {
          "extracted_string_or_numeric_value": "2006-03-21",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [470, 780],
            "vertical_y_vertices": [230, 250]
          }
        },
        "notary_name": {
          "extracted_string_or_numeric_value": "Marilyn A. Baggetto",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [560, 690],
            "vertical_y_vertices": [310, 320]
          }
        },
        "commission_expiry_date": {
          "extracted_string_or_numeric_value": "2006-09-08",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [560, 710],
            "vertical_y_vertices": [340, 350]
          }
        }
      },
      "agency_details": {
        "name": {
          "extracted_string_or_numeric_value": "MADISON ADOPTION ASSOCIATES",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [570, 860],
            "vertical_y_vertices": [860, 870]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "1447 E. Norman Drive Palatine, IL 60074",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [770, 860],
            "vertical_y_vertices": [880, 900]
          }
        },
        "phone_number": {
          "extracted_string_or_numeric_value": "847-991-2873",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [790, 860],
            "vertical_y_vertices": [910, 920]
          }
        },
        "license_permit_number": {
          "extracted_string_or_numeric_value": "395194-02",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [450, 520],
            "vertical_y_vertices": [780, 790]
          }
        },
        "license_expiration_date": {
          "extracted_string_or_numeric_value": "2008-04-03",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [600, 700],
            "vertical_y_vertices": [780, 790]
          }
        }
      }
    }
  }
]
```