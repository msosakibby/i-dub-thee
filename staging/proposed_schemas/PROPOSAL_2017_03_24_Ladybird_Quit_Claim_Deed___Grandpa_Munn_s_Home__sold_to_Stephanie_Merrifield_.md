An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document and designed a resilient Pydantic V2 schema to accommodate its structural realities.

### BLOCK 1 (Python Pydantic V2):
The following schema is designed for durability and precision, adhering to all specified directives. It includes nested models for logical data grouping, optional fields for structural flexibility, and the mandated, albeit contextually adapted, financial checksum validator.

```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

# MANDATORY BASE CLASSES (Do Not Modify)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# SCHEMA FOR '2017-03-24 Ladybird Quit Claim Deed'
class RecordingHeader(BaseModel):
    model_config = ConfigDict(extra='forbid')
    recording_date: ForensicDataEntity
    recording_time: ForensicDataEntity
    liber_number: ForensicDataEntity
    page_number: ForensicDataEntity
    document_number: ForensicDataEntity
    recording_fees: ForensicDataEntity
    register_of_deeds_name: ForensicDataEntity
    county: ForensicDataEntity

class Party(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity
    marital_status: ForensicDataEntity
    relationship_to_grantor: Optional[ForensicDataEntity] = None

class Purchaser(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    marital_status: ForensicDataEntity

class LandContractDetails(BaseModel):
    model_config = ConfigDict(extra='forbid')
    land_contract_date: ForensicDataEntity
    seller_name: ForensicDataEntity
    purchasers: List[Purchaser]
    purchaser_tenancy_type: ForensicDataEntity

class NotaryBlock(BaseModel):
    model_config = ConfigDict(extra='forbid')
    state: ForensicDataEntity
    county: ForensicDataEntity
    acknowledgement_date: ForensicDataEntity
    acknowledged_by_name: ForensicDataEntity
    notary_name: ForensicDataEntity
    commission_county: ForensicDataEntity
    commission_expiration_date: ForensicDataEntity
    acting_in_county: ForensicDataEntity

class PreparerInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    title: Optional[ForensicDataEntity] = None
    address: ForensicDataEntity

class LadybirdQuitClaimDeedV1(BaseModel):
    """
    A Pydantic V2 schema for a Ladybird Quit Claim Deed document,
    specifically modeled after the Osceola County, MI example from 2017.
    """
    model_config = ConfigDict(extra='forbid')

    recording_header: RecordingHeader
    document_title: ForensicDataEntity
    grantor: Party
    grantees: List[Party]
    property_legal_description: ForensicDataEntity
    tax_id_number: ForensicDataEntity
    property_location_municipality: ForensicDataEntity
    property_location_county: ForensicDataEntity
    property_location_state: ForensicDataEntity
    life_estate_reservation_clause: ForensicDataEntity
    consideration_amount: ForensicDataEntity
    transfer_tax_exemption_statutes: ForensicDataEntity
    land_contract_subject_to: Optional[LandContractDetails] = None
    farmland_operation_notice: Optional[ForensicDataEntity] = None
    land_division_rights_grant: Optional[ForensicDataEntity] = None
    execution_date: ForensicDataEntity
    grantor_printed_name: ForensicDataEntity
    notary_block: NotaryBlock
    preparer_info: PreparerInfo
    return_to: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'LadybirdQuitClaimDeedV1':
        """
        Executes a financial checksum as required by the directive.
        NOTE: This document class (Quit Claim Deed) does not contain fields
        that adhere to double-entry GAAP principles (debits and credits).
        The financial values present, 'recording_fees' and 'consideration_amount',
        are independent and do not balance against each other.
        This validator confirms the presence and numeric nature of these financial
        fields as a basic sanity check.
        """
        fees = self.recording_header.recording_fees.extracted_string_or_numeric_value
        consideration = self.consideration_amount.extracted_string_or_numeric_value

        if not isinstance(fees, (int, float)):
            raise ValueError(f"Recording fees must be a numeric value, but got {type(fees)}")
        if not isinstance(consideration, (int, float)):
            raise ValueError(f"Consideration amount must be a numeric value, but got {type(consideration)}")

        # No debit/credit relationship exists to perform a true checksum.
        # This check ensures financial values are non-negative.
        if fees < 0 or consideration < 0:
            raise ValueError("Financial values (fees, consideration) cannot be negative.")

        return self
```

### BLOCK 2 (JSON Test Registry):
This JSON object represents the single, most complex structural variant provided. It is designed to validate against the `LadybirdQuitClaimDeedV1` schema, including passing the required mathematical checks.

```json
[
  {
    "test_identifier": "20170324_osceola_mi_ladybird_deed_5085469",
    "should_pass": true,
    "taxonomy_lane": "LadybirdQuitClaimDeedV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "recording_header": {
        "recording_date": {
          "extracted_string_or_numeric_value": "03/24/2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [158, 228], "vertical_y_vertices": [40, 49] }
        },
        "recording_time": {
          "extracted_string_or_numeric_value": "10:18 AM",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [235, 295], "vertical_y_vertices": [40, 49] }
        },
        "liber_number": {
          "extracted_string_or_numeric_value": "966",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [680, 705], "vertical_y_vertices": [40, 49] }
        },
        "page_number": {
          "extracted_string_or_numeric_value": "445",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 775], "vertical_y_vertices": [40, 49] }
        },
        "document_number": {
          "extracted_string_or_numeric_value": "5085469",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 535], "vertical_y_vertices": [55, 64] }
        },
        "recording_fees": {
          "extracted_string_or_numeric_value": 30.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [55, 64] }
        },
        "register_of_deeds_name": {
          "extracted_string_or_numeric_value": "Nancy S Crawford",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 650], "vertical_y_vertices": [70, 79] }
        },
        "county": {
          "extracted_string_or_numeric_value": "Osceola County, MI",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [655, 770], "vertical_y_vertices": [70, 79] }
        }
      },
      "document_title": {
        "extracted_string_or_numeric_value": "LADYBIRD QUIT CLAIM DEED",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [387, 612], "vertical_y_vertices": [220, 232] }
      },
      "grantor": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. (Kibby) Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [198, 410], "vertical_y_vertices": [260, 272] }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, Mi 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 510], "vertical_y_vertices": [275, 305] }
        },
        "marital_status": {
          "extracted_string_or_numeric_value": "a woman",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [415, 480], "vertical_y_vertices": [260, 272] }
        }
      },
      "grantees": [
        {
          "name": {
            "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 480], "vertical_y_vertices": [305, 317] }
          },
          "address": {
            "extracted_string_or_numeric_value": "15204 74th St., Kenosha, Wisc. 53142",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 510], "vertical_y_vertices": [305, 332] }
          },
          "marital_status": {
            "extracted_string_or_numeric_value": "a married man",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [485, 585], "vertical_y_vertices": [305, 317] }
          },
          "relationship_to_grantor": {
            "extracted_string_or_numeric_value": "(her sons)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 410], "vertical_y_vertices": [350, 362] }
          }
        },
        {
          "name": {
            "extracted_string_or_numeric_value": "Michael J. Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 470], "vertical_y_vertices": [320, 332] }
          },
          "address": {
            "extracted_string_or_numeric_value": "210 Pearl St., Apt. B, Cadillac, Mi 49601",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 560], "vertical_y_vertices": [335, 347] }
          },
          "marital_status": {
            "extracted_string_or_numeric_value": "a single man",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [475, 565], "vertical_y_vertices": [320, 332] }
          },
          "relationship_to_grantor": {
            "extracted_string_or_numeric_value": "(her sons)",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 410], "vertical_y_vertices": [350, 362] }
          }
        }
      ],
      "property_legal_description": {
        "extracted_string_or_numeric_value": "Lot 15 of Block 3 of Clark's Addition to the Village of Marion, Osceola County, Michigan, according to the recorded Plat thereof.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 848], "vertical_y_vertices": [420, 465] }
      },
      "tax_id_number": {
        "extracted_string_or_numeric_value": "67-41-120-024-00",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 325], "vertical_y_vertices": [485, 497] }
      },
      "property_location_municipality": {
        "extracted_string_or_numeric_value": "Village of Marion",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 620], "vertical_y_vertices": [365, 377] }
      },
      "property_location_county": {
        "extracted_string_or_numeric_value": "Osceola County",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 740], "vertical_y_vertices": [365, 377] }
      },
      "property_location_state": {
        "extracted_string_or_numeric_value": "State of Michigan",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 860], "vertical_y_vertices": [365, 377] }
      },
      "life_estate_reservation_clause": {
        "extracted_string_or_numeric_value": "The Grantor, RESERVES and EXCEPTS to the grantor, for and during the life of the grantor, a LIFE ESTATE in and to the above described real estate, coupled with an absolute power in the grantors' sole and absolute discretion to convey by sale or by gift or otherwise, either to the grantor or to other persons, the fee or any lesser estate of the whole or any part of the real estate by inter vivos conveyance, and coupled with an absolute power in the grantors' sole and absolute discretion, with or without consideration, to mortgage the fee or any lesser estate of mortgage, and coupled with an absolute power in the grantor's sole and absolute discretion with or without consideration to lease the whole or any part of the real estate by inter vivos instrument of lease, even though the term of any lease might extend beyond the time of the grantor's death, all without any obligation to deliver or pay to any person the proceeds, in any, received therefrom, pursuant to Land Title Standard 9.3.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 848], "vertical_y_vertices": [575, 760] }
      },
      "consideration_amount": {
        "extracted_string_or_numeric_value": 1.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 290], "vertical_y_vertices": [775, 787] }
      },
      "transfer_tax_exemption_statutes": {
        "extracted_string_or_numeric_value": "MSA 7.456(5)(a) and MSA 7.456(26)(6)(a/j).",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 680], "vertical_y_vertices": [775, 787] }
      },
      "land_contract_subject_to": {
        "land_contract_date": {
          "extracted_string_or_numeric_value": "May 9, 2012",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 560], "vertical_y_vertices": [790, 802] }
        },
        "seller_name": {
          "extracted_string_or_numeric_value": "the Grantor as Seller",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 800], "vertical_y_vertices": [790, 802] }
        },
        "purchasers": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Nicholas Maddox",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 760], "vertical_y_vertices": [790, 817] }
            },
            "marital_status": {
              "extracted_string_or_numeric_value": "a single man",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 850], "vertical_y_vertices": [790, 817] }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Monique Ashby",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 250], "vertical_y_vertices": [805, 817] }
            },
            "marital_status": {
              "extracted_string_or_numeric_value": "a woman",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [255, 315], "vertical_y_vertices": [805, 817] }
            }
          }
        ],
        "purchaser_tenancy_type": {
          "extracted_string_or_numeric_value": "as joint tenants with full rights of survivorship, as the Purchasers.",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 800], "vertical_y_vertices": [805, 832] }
        }
      },
      "farmland_operation_notice": {
        "extracted_string_or_numeric_value": "This property may be located within the vicinity of farmland or a farm operation. Generally accepted agricultural and management practices which may generate noise, dust, odors, and other associated conditions may be used and are protected by the Michigan right to farm act.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 848], "vertical_y_vertices": [840, 890] }
      },
      "land_division_rights_grant": {
        "extracted_string_or_numeric_value": "The grantors grants to the grantees the right to make all available divisions of the subject property under Section 108 of the land division act, Act No. 288 of the Public Acts of 1967.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 848], "vertical_y_vertices": [900, 912] }
      },
      "execution_date": {
        "extracted_string_or_numeric_value": "21 day of March, 2017",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 380], "vertical_y_vertices": [150, 162] }
      },
      "grantor_printed_name": {
        "extracted_string_or_numeric_value": "Judith A. (Kibby) Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 350], "vertical_y_vertices": [220, 232] }
      },
      "notary_block": {
        "state": {
          "extracted_string_or_numeric_value": "STATE OF MICHIGAN",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 300], "vertical_y_vertices": [280, 292] }
        },
        "county": {
          "extracted_string_or_numeric_value": "Osceola",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 280], "vertical_y_vertices": [295, 307] }
        },
        "acknowledgement_date": {
          "extracted_string_or_numeric_value": "21 day of March, 2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 680], "vertical_y_vertices": [320, 332] }
        },
        "acknowledged_by_name": {
          "extracted_string_or_numeric_value": "Judith A. (Kibby) Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 350], "vertical_y_vertices": [335, 347] }
        },
        "notary_name": {
          "extracted_string_or_numeric_value": "GREGORY C MERRIFIELD",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [530, 680], "vertical_y_vertices": [420, 432] }
        },
        "commission_county": {
          "extracted_string_or_numeric_value": "Osceola County",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [530, 680], "vertical_y_vertices": [445, 457] }
        },
        "commission_expiration_date": {
          "extracted_string_or_numeric_value": "May 3, 2020",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [530, 720], "vertical_y_vertices": [458, 470] }
        },
        "acting_in_county": {
          "extracted_string_or_numeric_value": "OSCEOLA",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [530, 750], "vertical_y_vertices": [470, 482] }
        }
      },
      "preparer_info": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 300], "vertical_y_vertices": [530, 542] }
        },
        "title": {
          "extracted_string_or_numeric_value": "Attorney at Law",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 260], "vertical_y_vertices": [545, 557] }
        },
        "address": {
          "extracted_string_or_numeric_value": "221 E. Main/Box 172 Marion, MI 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 350], "vertical_y_vertices": [560, 587] }
        }
      },
      "return_to": {
        "extracted_string_or_numeric_value": "Grantee",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [152, 210], "vertical_y_vertices": [610, 622] }
      }
    }
  }
]
```