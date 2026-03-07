An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document and designed a resilient Pydantic V2 schema. This schema accommodates the structural realities of the 'Home Study Final Notarized 022006' document class, adhering to all specified directives.

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
from math import isclose

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class ProspectiveAdoptiveParent(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    ssn: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    address: ForensicDataEntity
    phone: ForensicDataEntity

class PreparedBy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    credentials: ForensicDataEntity
    phone: Optional[ForensicDataEntity] = None
    email: Optional[ForensicDataEntity] = None

class SummaryOfContacts(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    home_visit_date: ForensicDataEntity
    personal_interview_dates: List[ForensicDataEntity]

class HistoricalBackground(BaseModel):
    model_config = ConfigDict(extra='forbid')
    full_text: ForensicDataEntity
    date_of_birth: ForensicDataEntity
    birth_place: ForensicDataEntity
    mother_name: ForensicDataEntity
    father_name: ForensicDataEntity
    brother_name: ForensicDataEntity

class HomeAndCommunity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    description: ForensicDataEntity
    home_type: ForensicDataEntity
    location: ForensicDataEntity
    neighborhood: ForensicDataEntity
    city_population: ForensicDataEntity
    square_feet: ForensicDataEntity

class Liabilities(BaseModel):
    model_config = ConfigDict(extra='forbid')
    home: ForensicDataEntity
    credit_cards: ForensicDataEntity
    other: ForensicDataEntity
    total_liabilities: Optional[ForensicDataEntity] = None # For checksum validation

class EmploymentAndFinancialInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    employer: ForensicDataEntity
    location: ForensicDataEntity
    title: ForensicDataEntity
    start_date: ForensicDataEntity
    annual_salary: ForensicDataEntity
    potential_bonus_percentage: ForensicDataEntity
    liabilities: Liabilities

    @model_validator(mode='after')
    def perform_financial_checksum(self) -> 'EmploymentAndFinancialInfo':
        """Performs a checksum on the listed liabilities against a total."""
        if self.liabilities and self.liabilities.total_liabilities:
            home_val = self.liabilities.home.extracted_string_or_numeric_value
            cc_val = self.liabilities.credit_cards.extracted_string_or_numeric_value
            other_val = self.liabilities.other.extracted_string_or_numeric_value
            total_val = self.liabilities.total_liabilities.extracted_string_or_numeric_value

            # Ensure all values are floats for calculation
            if not all(isinstance(v, (float, int)) for v in [home_val, cc_val, other_val, total_val]):
                 raise ValueError("All liability values must be numeric for checksum.")

            calculated_sum = home_val + cc_val + other_val

            if not isclose(calculated_sum, total_val):
                raise ValueError(f"Liabilities checksum failed: Calculated sum {calculated_sum} does not match provided total {total_val}.")
        return self

class OtherSupportingInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    cants_clearance_date: ForensicDataEntity
    state_police_clearance_date: ForensicDataEntity
    physician_exam_date: ForensicDataEntity
    declarations: ForensicDataEntity

class ComplaintsContact(BaseModel):
    model_config = ConfigDict(extra='forbid')
    person_name: ForensicDataEntity
    department: ForensicDataEntity
    phone: ForensicDataEntity

class AssessmentAndRecommendations(BaseModel):
    model_config = ConfigDict(extra='forbid')
    recommendation_text: ForensicDataEntity
    recommended_number_of_children: ForensicDataEntity
    recommended_gender: ForensicDataEntity
    recommended_age_range: ForensicDataEntity
    recommended_origin: ForensicDataEntity
    license_permit_number: ForensicDataEntity
    license_expiration_date: ForensicDataEntity
    authorized_personnel: ForensicDataEntity
    complaints_contact: ComplaintsContact

class AgencyDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    phone: ForensicDataEntity

class AuthorizerSignature(BaseModel):
    model_config = ConfigDict(extra='forbid')
    printed_name: ForensicDataEntity
    title: ForensicDataEntity
    date: ForensicDataEntity

class NotarySeal(BaseModel):
    model_config = ConfigDict(extra='forbid')
    notary_name: ForensicDataEntity
    notary_public_state: ForensicDataEntity
    commission_expires_date: ForensicDataEntity

class Notarization(BaseModel):
    model_config = ConfigDict(extra='forbid')
    subscribed_and_sworn_date: ForensicDataEntity
    notary_seal: NotarySeal

class HomeStudyFinalNotarized022006(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    document_date: ForensicDataEntity
    case_name: ForensicDataEntity
    prospective_adoptive_parent: ProspectiveAdoptiveParent
    prepared_by: PreparedBy
    type_of_adoption: ForensicDataEntity
    purpose_of_report: ForensicDataEntity
    summary_of_contacts: SummaryOfContacts
    type_of_child_desired_and_motivation: ForensicDataEntity
    historical_social_and_educational_background: HistoricalBackground
    physical_description: ForensicDataEntity
    quality_of_marriage: ForensicDataEntity
    children_in_family_and_parenting_philosophy: ForensicDataEntity
    child_care_plans: ForensicDataEntity
    home_and_community: HomeAndCommunity
    employment_and_financial_information: EmploymentAndFinancialInfo
    religion: ForensicDataEntity
    other_supporting_information: OtherSupportingInfo
    guardianship: ForensicDataEntity
    female_role_models: ForensicDataEntity
    rights_of_the_child: ForensicDataEntity
    assessment_and_recommendations: AssessmentAndRecommendations
    agency_details: List[AgencyDetails]
    authorizer_signature: AuthorizerSignature
    notarization: Notarization
```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "home_study_022006_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "HomeStudyFinalNotarized022006",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "ADOPTION HOME STUDY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [97, 512],
          "vertical_y_vertices": [97, 110]
        }
      },
      "document_date": {
        "extracted_string_or_numeric_value": "February 20, 2006",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [406, 512],
          "vertical_y_vertices": [122, 133]
        }
      },
      "case_name": {
        "extracted_string_or_numeric_value": "Mark Kibby - Home Study",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [593, 783],
          "vertical_y_vertices": [31, 42]
        }
      },
      "prospective_adoptive_parent": {
        "name": {
          "extracted_string_or_numeric_value": "Mark William Kibby",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [244, 366],
            "vertical_y_vertices": [201, 212]
          }
        },
        "ssn": {
          "extracted_string_or_numeric_value": "366-72-9323",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [244, 323],
            "vertical_y_vertices": [222, 233]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "August 8, 1973",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [244, 345],
            "vertical_y_vertices": [243, 254]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "4618 N. Racine Avenue, Unit 7\nChicago, Illinois 60640",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [336, 512],
            "vertical_y_vertices": [275, 307]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "(773) 251-0539",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [336, 430],
            "vertical_y_vertices": [328, 339]
          }
        }
      },
      "prepared_by": {
        "name": {
          "extracted_string_or_numeric_value": "Jamie J. Janssen Casey",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [336, 500],
            "vertical_y_vertices": [360, 371]
          }
        },
        "credentials": {
          "extracted_string_or_numeric_value": "M.S.W., L.C.S.W., C-AYCFSW",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [503, 699],
            "vertical_y_vertices": [360, 371]
          }
        },
        "phone": {
          "extracted_string_or_numeric_value": "(708) 363-3338",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 296],
            "vertical_y_vertices": [405, 416]
          }
        },
        "email": {
          "extracted_string_or_numeric_value": "djascasey@comcast.net",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 332],
            "vertical_y_vertices": [426, 437]
          }
        }
      },
      "type_of_adoption": {
        "extracted_string_or_numeric_value": "Agency international through Guatemala",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [195, 550],
          "vertical_y_vertices": [392, 403]
        }
      },
      "purpose_of_report": {
        "extracted_string_or_numeric_value": "This is a home study for the purpose of an international adoption. Madison Adoption Associates is involved in the capacity of home study agency. A Guatemalan adoption program will be utilized for the placing agency.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [195, 823],
          "vertical_y_vertices": [447, 499]
        }
      },
      "summary_of_contacts": {
        "description": {
          "extracted_string_or_numeric_value": "Extensive individual in-person and telephone interviews were conducted with the adoptive individual. One home visit was conducted on January 26, 2006 and personal interviews took place on February 18 and 21, 2005. Phone and mail contact has been maintained throughout the process. All contacts have been found to be very favorable.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 823],
            "vertical_y_vertices": [532, 605]
          }
        },
        "home_visit_date": {
          "extracted_string_or_numeric_value": "January 26, 2006",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [518, 630],
            "vertical_y_vertices": [553, 564]
          }
        },
        "personal_interview_dates": [
          {
            "extracted_string_or_numeric_value": "February 18, 2005",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [340, 460],
              "vertical_y_vertices": [574, 585]
            }
          },
          {
            "extracted_string_or_numeric_value": "February 21, 2005",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [465, 585],
              "vertical_y_vertices": [574, 585]
            }
          }
        ]
      },
      "type_of_child_desired_and_motivation": {
        "extracted_string_or_numeric_value": "Mark Kibby is a heterosexual male who very much desire to expand his family through the adoption of a child 0-12 months of age. He has been considering adoption for over two years. Mark will be sensitive to any child or children placed with him that may have been subjected to abuse, neglect, separation from and loss of their biological family. Mark currently has no children. Mark desires to adopt a child and be a parent to raise, care, love and share his experiences with another individual. Mark stated he has a lot of love to give a child and is more than ready to expand his family through adoption. He has a great admiration for the birth parents for the sacrifice they are making in placing their child. He will be open and honest with his first adopted child and very respectful of the child's history and culture. Mark will work to help their child or children retain and celebrate their own cultural and ethnic identity and heritage. Mark has a fondness for the Guatemalan culture and feels that a Guatemalan child would fit into his life and community. Mark is using a Guatemalan adoption program in Antigua, Guatemala for",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [195, 823],
          "vertical_y_vertices": [649, 854]
        }
      },
      "historical_social_and_educational_background": {
        "full_text": {
          "extracted_string_or_numeric_value": "Mark William Kibby was born on August 8, 1973 in Cadillac, Michigan to Judith Ann (Munn) and Max Revoe Kibby. His mother is of English and Irish descent and his father is of German descent. While Mark was growing up, his father and mother owned their own grocery store in their hometown. Mark remembers both of his parents spending several hours each day working at their store. He recalls having to take care of his self when he was eight years old. He was very self-sufficient and capable of helping his parents with the house hold responsibilities such as cleaning and preparing a meal. Mark remembers his father as being a very hard work and being very knowledgeable in manual work such as carpentry and mechanics. He also remembers that his father's ability to earn his pilots license taught him the value of hard worker and determination to accomplish a personal goal. He has fond memories of his mother as being generous and kind. He remembers having love and respect for his parents. He recalls discipline being handled equally by both parents and was never disciplines with any means of physical contact. Mark is the older of two siblings. He describes his relationship with his brother, Michael, as being very close. They are sixteen months apart and spent a significant amount of time playing together. Living in a rural community, they were often each other's only playmates. Their relationship continues to be very strong to this day. He has special memories of his family that include trips to grocery conventions and Detroit Lions football games.",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 823],
            "vertical_y_vertices": [192, 508]
          }
        },
        "date_of_birth": {
          "extracted_string_or_numeric_value": "August 8, 1973",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [468, 569],
            "vertical_y_vertices": [192, 203]
          }
        },
        "birth_place": {
          "extracted_string_or_numeric_value": "Cadillac, Michigan",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [575, 705],
            "vertical_y_vertices": [192, 203]
          }
        },
        "mother_name": {
          "extracted_string_or_numeric_value": "Judith Ann (Munn)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [628, 758],
            "vertical_y_vertices": [192, 224]
          }
        },
        "father_name": {
          "extracted_string_or_numeric_value": "Max Revoe Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 318],
            "vertical_y_vertices": [213, 224]
          }
        },
        "brother_name": {
          "extracted_string_or_numeric_value": "Michael",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 556],
            "vertical_y_vertices": [381, 392]
          }
        }
      },
      "physical_description": {
        "extracted_string_or_numeric_value": "Mark is 32 years old and is of German, Irish, and English descent. He stands 5'8\" tall, weighs 145 pounds and has hazel eyes and brown hair. During the personal interviews, Mark was friendly and polite. He appeared attentive to his home and family's needs, intelligent, and thoughtful. I found him to be a pleasure to work with. He describes himself as being very organized, trustworthy, committed, loving, hardworking and having a strong sense of self with goals and objectives. Mark's hobbies include biking, reading, camping, and hiking. I believe he understands the responsibilities of parenting and will be able to give much love to any child placed with him.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [97, 254]
        }
      },
      "quality_of_marriage": {
        "extracted_string_or_numeric_value": "Mark has never been married. Mark has stated that he is open to marriage in the future should he meet the right person. He also understands that this person would have to be willing to accept both him and his child, placing his child's interests and needs as the priority.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [287, 340]
        }
      },
      "children_in_family_and_parenting_philosophy": {
        "extracted_string_or_numeric_value": "Mark currently has no children. He believes his approach to parenting will be based on respect and trust. He plans to establish an authoritative and respect driven relationship with is child by demonstrating that he respects his child as an individual. He hopes to instill such characteristics such as confidence, self-control and independence. Mark will not use any physical forms of discipline. Disciplines will be completed by items such as time-outs, chores, loss of privileges, and formal apologies to the person(s) impacted. Mark believes he is loving, honest, and structured towards her children. He believes in exposing children to responsibility and goals early in life to help instill self-confidence, a strong sense of purpose, values and independence. He believes in such values as dignity, respect, trust, strong work ethic, and honesty.",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [373, 530]
        }
      },
      "child_care_plans": {
        "extracted_string_or_numeric_value": "After adopting a child, Mark plans on remaining home for three weeks after placement to help the child adjust to his/her new environment. When he returns to his work full-time, Mark plans on utilizing Little Hands, which is a licensed Day Care facility adjacent to his work for childcare.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [552, 615]
        }
      },
      "home_and_community": {
        "description": {
          "extracted_string_or_numeric_value": "Mark lives alone in a Brownstone flat style home, located in a lovely neighborhood. His home is in the city of Chicago, Illinois. His home was built in the 1920's and has approximately 1400 square feet of living space. His home is divided into 7 rooms including two furnished bedrooms, two bathrooms, a kitchen, living room and dining room. His brown stone has a 60x35ft front yard for a child to play in and is located near various parks within his neighborhood. His home located in Chicago's Uptown Neighborhood in a city with a population of 2,852,244. There are medical facilities within a two-mile radius of his home. There are various public and private schools is two mile radius from his home. The neighborhood is comprised of single-family residences. It is comprised of people from many ethnic groups including, Caucasian, African-American, Asian, and Hispanic families.",
          "optical_extraction_confidence_score": 0.94,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 823],
            "vertical_y_vertices": [648, 854]
          }
        },
        "home_type": {
          "extracted_string_or_numeric_value": "Brownstone flat style home",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [340, 550],
            "vertical_y_vertices": [648, 659]
          }
        },
        "location": {
          "extracted_string_or_numeric_value": "Chicago, Illinois",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 512],
            "vertical_y_vertices": [669, 680]
          }
        },
        "neighborhood": {
          "extracted_string_or_numeric_value": "Uptown Neighborhood",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [370, 540],
            "vertical_y_vertices": [754, 765]
          }
        },
        "city_population": {
          "extracted_string_or_numeric_value": 2852244,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [680, 750],
            "vertical_y_vertices": [754, 765]
          }
        },
        "square_feet": {
          "extracted_string_or_numeric_value": 1400,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490, 525],
            "vertical_y_vertices": [690, 701]
          }
        }
      },
      "employment_and_financial_information": {
        "employer": {
          "extracted_string_or_numeric_value": "Allstate Insurance Company",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [320, 520],
            "vertical_y_vertices": [97, 108]
          }
        },
        "location": {
          "extracted_string_or_numeric_value": "Northbrook, Illinois",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [530, 670],
            "vertical_y_vertices": [97, 108]
          }
        },
        "title": {
          "extracted_string_or_numeric_value": "Technology Shared Services Senior Manager",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 580],
            "vertical_y_vertices": [97, 129]
          }
        },
        "start_date": {
          "extracted_string_or_numeric_value": "November 2004",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 610],
            "vertical_y_vertices": [118, 129]
          }
        },
        "annual_salary": {
          "extracted_string_or_numeric_value": 115512.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [340, 400],
            "vertical_y_vertices": [139, 150]
          }
        },
        "potential_bonus_percentage": {
          "extracted_string_or_numeric_value": 30.0,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 605],
            "vertical_y_vertices": [139, 150]
          }
        },
        "liabilities": {
          "home": {
            "extracted_string_or_numeric_value": 226466.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [310, 370],
              "vertical_y_vertices": [243, 254]
            }
          },
          "credit_cards": {
            "extracted_string_or_numeric_value": 12923.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [520, 570],
              "vertical_y_vertices": [243, 254]
            }
          },
          "other": {
            "extracted_string_or_numeric_value": 61000.0,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [630, 680],
              "vertical_y_vertices": [243, 254]
            }
          },
          "total_liabilities": {
            "extracted_string_or_numeric_value": 300389.0,
            "optical_extraction_confidence_score": 1.0,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [0, 0],
              "vertical_y_vertices": [0, 0]
            }
          }
        }
      },
      "religion": {
        "extracted_string_or_numeric_value": "Mark was raised Christian of Methodist denomination. His parents exposed him to several faiths through family and friends within his local community and allowed his to choose which religion met his personal needs. He plans to expose his child to various religions, the same way that his parents exposed him, and will allow his child to chose a religion when the child is mature enough to make such a decision. Mark's concept of religion is that it is a personal choice for each individual. He stated that religion can provide examples of strong moral character in a child's fundamental years to act as a guidepost as they establish their own character.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [328, 462]
        }
      },
      "other_supporting_information": {
        "cants_clearance_date": {
          "extracted_string_or_numeric_value": "January 19, 2006",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [520, 630],
            "vertical_y_vertices": [495, 506]
          }
        },
        "state_police_clearance_date": {
          "extracted_string_or_numeric_value": "January 18, 2006",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 690],
            "vertical_y_vertices": [537, 548]
          }
        },
        "physician_exam_date": {
          "extracted_string_or_numeric_value": "December 29, 2005",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [420, 540],
            "vertical_y_vertices": [731, 742]
          }
        },
        "declarations": {
          "extracted_string_or_numeric_value": "Mark has declared that he has never participated in substance abuse, sexual or child abuse, domestic violence, nor to the best of his knowledge has there been any allegations of such against him. He also stated that he has never been arrested. Mark stated that he has never previously been rejected as prospective adoptive parent nor has he been the subject of an unfavorable home study. All references (six on file) with this office are highly supportive of Mark and his adoption plans.",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 823],
            "vertical_y_vertices": [626, 720]
          }
        }
      },
      "guardianship": {
        "extracted_string_or_numeric_value": "Mark has arranged for his mother, Judith Grandy, to be the guardian of his child/children should anything happen to him. Judith lives in Marion, Michigan and is currently retired. Her husband past away in 1999 and her children currently reside on their own. Judith is very active within her community and is currently running for her local school board.",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [97, 170]
        }
      },
      "female_role_models": {
        "extracted_string_or_numeric_value": "Mark's mother and aunts will be strong influences in the life of his child. They both live in the same area of Michigan and he will continue to visit and spend time with his mother and aunts as described in the prior section. The primary female role model in the life of his child will be his cousin, Julie Weston. Julie will be moving to Chicago, Illinois during the summer of 2006. Once she graduates from college, Mark plans on Julie being an active participant in raising his child. Julie and Mark have a very strong relationship and she often travels to Chicago to spend time with him for weekends or holidays. She has been and will continue to spend time with Mark and his child including weekly activities and family vacations.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [192, 349]
        }
      },
      "rights_of_the_child": {
        "extracted_string_or_numeric_value": "Mark Kibby, does hereby swear and affirm that any child adopted by him will be treated with the same respect, care, love and attention and will have the same rights and privileges as any biological child. Furthermore, please be advised that according to the laws of the United Sates of America, children that qualify as orphans and are legally adopted by an American citizen shall have equal rights as children originally born in the United States of America and his/her civil rights will not be restricted in any way.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [192, 823],
          "vertical_y_vertices": [372, 516]
        }
      },
      "assessment_and_recommendations": {
        "recommendation_text": {
          "extracted_string_or_numeric_value": "Mark has given more than considerable thought to this adoption. Mark stated that he has never participated in a previous adoption process and been rejected as a prospective adoptive parent or have been subject of an unfavorable home study. He is aware of the expenses, processing, procedures, difficulties and possible delays associated with international adoption. These topics were discussed in depth with associates from Madison Adoption Associates. His emotional and intellectual capacity, values and personal experiences all lend themselves to his ability to adopt and parent one to three children from Guatemala. Therefore, I recommend and approve Mark Kibby as an adoptive parent to one to three healthy children, of either gender between the ages of 0-3 years of age from Guatemala. There are no restrictions to the adoption such as nationality, age or gender of the orphan.",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 823],
            "vertical_y_vertices": [549, 720]
          }
        },
        "recommended_number_of_children": {
          "extracted_string_or_numeric_value": "one to three",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [480, 570],
            "vertical_y_vertices": [680, 691]
          }
        },
        "recommended_gender": {
          "extracted_string_or_numeric_value": "either gender",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 740],
            "vertical_y_vertices": [680, 691]
          }
        },
        "recommended_age_range": {
          "extracted_string_or_numeric_value": "0-3 years",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [340, 410],
            "vertical_y_vertices": [700, 711]
          }
        },
        "recommended_origin": {
          "extracted_string_or_numeric_value": "Guatemala",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 570],
            "vertical_y_vertices": [700, 711]
          }
        },
        "license_permit_number": {
          "extracted_string_or_numeric_value": "395194-02",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [500, 570],
            "vertical_y_vertices": [754, 765]
          }
        },
        "license_expiration_date": {
          "extracted_string_or_numeric_value": "April 3, 2008",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [670, 760],
            "vertical_y_vertices": [754, 765]
          }
        },
        "authorized_personnel": {
          "extracted_string_or_numeric_value": "Jamie J. Janssen Casey",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [192, 370],
            "vertical_y_vertices": [765, 786]
          }
        },
        "complaints_contact": {
          "person_name": {
            "extracted_string_or_numeric_value": "Mary Donley, MSW",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [500, 630],
              "vertical_y_vertices": [808, 819]
            }
          },
          "department": {
            "extracted_string_or_numeric_value": "Illinois Department of Child and Family Services",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [290, 680],
              "vertical_y_vertices": [819, 830]
            }
          },
          "phone": {
            "extracted_string_or_numeric_value": "217:785:2692",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [195, 280],
              "vertical_y_vertices": [97, 108]
            }
          }
        }
      },
      "agency_details": [
        {
          "name": {
            "extracted_string_or_numeric_value": "MADISON ADOPTION ASSOCIATES",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [572, 863],
              "vertical_y_vertices": [862, 873]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "1447 E. Norman Drive\nPalatine, IL 60074",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [769, 863],
              "vertical_y_vertices": [891, 923]
            }
          },
          "phone": {
            "extracted_string_or_numeric_value": "847-991-2873",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [798, 863],
              "vertical_y_vertices": [933, 944]
            }
          }
        }
      ],
      "authorizer_signature": {
        "printed_name": {
          "extracted_string_or_numeric_value": "Jamie J. Janssen Casey, M.S.W., L.C.S.W., C-AYCFSW",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [166, 540],
            "vertical_y_vertices": [184, 195]
          }
        },
        "title": {
          "extracted_string_or_numeric_value": "Executive Director – Illinois Branch",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [195, 420],
            "vertical_y_vertices": [205, 216]
          }
        },
        "date": {
          "extracted_string_or_numeric_value": "3-21-06",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [620, 710],
            "vertical_y_vertices": [148, 165]
          }
        }
      },
      "notarization": {
        "subscribed_and_sworn_date": {
          "extracted_string_or_numeric_value": "21 day of March 2006",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [460, 780],
            "vertical_y_vertices": [234, 251]
          }
        },
        "notary_seal": {
          "notary_name": {
            "extracted_string_or_numeric_value": "Marilyn A. Baggetto",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [560, 700],
              "vertical_y_vertices": [310, 321]
            }
          },
          "notary_public_state": {
            "extracted_string_or_numeric_value": "State of Illinois",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [560, 660],
              "vertical_y_vertices": [321, 332]
            }
          },
          "commission_expires_date": {
            "extracted_string_or_numeric_value": "09/08/2006",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [560, 700],
              "vertical_y_vertices": [332, 343]
            }
          }
        }
      }
    }
  }
]
```