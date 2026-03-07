An expert forensic data architect, I have analyzed the provided document, '2016-04-22 Kibby Company LLC Affidavit Regarding Real Estate', to design a resilient Pydantic V2 schema. This schema is structured to capture all data points with forensic precision, adhering to a Zero-Trust mandate by wrapping each entity in a structure that includes its value, confidence score, and physical location on the source document.

### BLOCK 1: Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
from math import isclose

# MANDATORY: Forensic Data Entity and Spatial Coordinate Wrapper Classes
class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon by its vertices to locate evidence on a physical document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """Wraps each extracted data point with metadata for forensic traceability."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema Definition for the Document
class RecordingHeader(BaseModel):
    """Captures the filing and recording information from the county register of deeds."""
    model_config = ConfigDict(extra='forbid')
    received_date_time: ForensicDataEntity
    recorded_date_time: ForensicDataEntity
    liber: ForensicDataEntity
    page_start: ForensicDataEntity
    page_count: ForensicDataEntity
    document_id: ForensicDataEntity
    fees: ForensicDataEntity
    register_of_deeds_name: ForensicDataEntity
    county: ForensicDataEntity

class Jurisdiction(BaseModel):
    """Defines the legal jurisdiction (state and county) of the document."""
    model_config = ConfigDict(extra='forbid')
    state: ForensicDataEntity
    county: ForensicDataEntity

class Address(BaseModel):
    """A reusable model for physical addresses."""
    model_config = ConfigDict(extra='forbid')
    street: ForensicDataEntity
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: ForensicDataEntity

class AffiantInfo(BaseModel):
    """Details about the affiant making the sworn statement."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    title: ForensicDataEntity
    address: Address

class CompanyInfo(BaseModel):
    """Details about the company mentioned in the affidavit."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    company_type: ForensicDataEntity
    status: ForensicDataEntity
    regulating_department: ForensicDataEntity

class PropertyDetails(BaseModel):
    """Contains the legal description of the real estate parcel."""
    model_config = ConfigDict(extra='forbid')
    parcel_id: ForensicDataEntity
    legal_description: ForensicDataEntity

class SurveyCertificate(BaseModel):
    """Recording details for a related Certificate of Survey."""
    model_config = ConfigDict(extra='forbid')
    liber: ForensicDataEntity
    page: ForensicDataEntity

class QuitClaimDeed(BaseModel):
    """Details of a prior Quit Claim Deed transaction."""
    model_config = ConfigDict(extra='forbid')
    deed_date: ForensicDataEntity
    recorded_date: ForensicDataEntity
    liber: ForensicDataEntity
    page: ForensicDataEntity
    grantors: List[ForensicDataEntity]
    grantee: ForensicDataEntity

class ChainOfTitle(BaseModel):
    """A collection of documents related to the property's history."""
    model_config = ConfigDict(extra='forbid')
    survey_certificate: SurveyCertificate
    quit_claim_deed: QuitClaimDeed

class RelatedMortgage(BaseModel):
    """Details of a mortgage that purportedly encumbers the property."""
    model_config = ConfigDict(extra='forbid')
    mortgage_date: ForensicDataEntity
    recorded_date: ForensicDataEntity
    liber: ForensicDataEntity
    page: ForensicDataEntity
    mortgagors: List[ForensicDataEntity]
    issue_description: ForensicDataEntity

class ExecutionDetails(BaseModel):
    """Information about the signing of the affidavit."""
    model_config = ConfigDict(extra='forbid')
    affidavit_date: ForensicDataEntity
    affiant_signature_present: ForensicDataEntity

class NotaryInfo(BaseModel):
    """Information about the notary public who witnessed the signature."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    county: ForensicDataEntity
    state: ForensicDataEntity
    commission_expires: ForensicDataEntity
    acting_county: ForensicDataEntity

class Acknowledgement(BaseModel):
    """The notary's acknowledgement block."""
    model_config = ConfigDict(extra='forbid')
    date: ForensicDataEntity
    acknowledged_by: ForensicDataEntity
    notary: NotaryInfo

class DrafterInfo(BaseModel):
    """Information about the person or firm that drafted the document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    title: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: Address

class AffidavitRegardingRealEstateV1(BaseModel):
    """
    Schema for an Affidavit Regarding Real Estate filed in Osceola County, MI, in 2016.
    This document clarifies ownership and disputes a mortgage encumbrance on a specific parcel.
    """
    model_config = ConfigDict(extra='forbid')
    
    recording_header: RecordingHeader
    document_title: ForensicDataEntity
    jurisdiction: Jurisdiction
    affiant: AffiantInfo
    company: CompanyInfo
    property_details: PropertyDetails
    chain_of_title: ChainOfTitle
    related_mortgage: RelatedMortgage
    affidavit_purpose: ForensicDataEntity
    execution_details: ExecutionDetails
    acknowledgement: Acknowledgement
    drafter: DrafterInfo

    @model_validator(mode='after')
    def validate_financials(self) -> 'AffidavitRegardingRealEstateV1':
        """
        Executes double-entry GAAP mathematical checksums if financial numbers exist.
        In this document, only a single 'fees' value is present, so no balancing check can be performed.
        The validator confirms the fee is non-negative, serving as a placeholder for more complex
        financial validation in other document versions.
        """
        fees_value = self.recording_header.fees.extracted_string_or_numeric_value
        
        if fees_value is not None and isinstance(fees_value, (int, float)):
            if fees_value < 0:
                raise ValueError(f"Recording fees cannot be negative. Found: {fees_value}")
        
        # As no other financial figures exist for a double-entry check, the validation is complete.
        # If other fields like 'taxes_paid' or 'transfer_amount' were present, they would be
        # cross-validated here.
        
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "20160427_osceola_mi_affidavit_955_474",
    "should_pass": true,
    "taxonomy_lane": "AffidavitRegardingRealEstateV1",
    "binary_header_simulation": "25504446",
    "payload": {
      "recording_header": {
        "received_date_time": {
          "extracted_string_or_numeric_value": "04/27/2016 02:20:18 PM",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [118, 308], "vertical_y_vertices": [186, 200] }
        },
        "recorded_date_time": {
          "extracted_string_or_numeric_value": "04/27/2016 02:21 PM",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [507, 648], "vertical_y_vertices": [25, 37] }
        },
        "liber": {
          "extracted_string_or_numeric_value": 955,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [688, 720], "vertical_y_vertices": [25, 37] }
        },
        "page_start": {
          "extracted_string_or_numeric_value": 474,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [770, 800], "vertical_y_vertices": [25, 37] }
        },
        "page_count": {
          "extracted_string_or_numeric_value": 2,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 650], "vertical_y_vertices": [39, 50] }
        },
        "document_id": {
          "extracted_string_or_numeric_value": "5080475",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [507, 560], "vertical_y_vertices": [39, 50] }
        },
        "fees": {
          "extracted_string_or_numeric_value": 17.00,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 800], "vertical_y_vertices": [39, 50] }
        },
        "register_of_deeds_name": {
          "extracted_string_or_numeric_value": "Nancy S Crawford",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [507, 650], "vertical_y_vertices": [52, 62] }
        },
        "county": {
          "extracted_string_or_numeric_value": "Osceola County, MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [655, 800], "vertical_y_vertices": [52, 62] }
        }
      },
      "document_title": {
        "extracted_string_or_numeric_value": "AFFIDAVIT REGARDING REAL ESTATE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 589], "vertical_y_vertices": [193, 220] }
      },
      "jurisdiction": {
        "state": {
          "extracted_string_or_numeric_value": "STATE OF MICHIGAN",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 382], "vertical_y_vertices": [259, 270] }
        },
        "county": {
          "extracted_string_or_numeric_value": "COUNTY OF OSCEOLA",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 382], "vertical_y_vertices": [275, 286] }
        }
      },
      "affiant": {
        "name": {
          "extracted_string_or_numeric_value": "Judith Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 420], "vertical_y_vertices": [330, 342] }
        },
        "title": {
          "extracted_string_or_numeric_value": "sole operational member of Kibby Company, LLC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [425, 750], "vertical_y_vertices": [330, 342] }
        },
        "address": {
          "street": {
            "extracted_string_or_numeric_value": "3291 18 Mile Road",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 450], "vertical_y_vertices": [420, 432] }
          },
          "city": {
            "extracted_string_or_numeric_value": "Marion",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [455, 510], "vertical_y_vertices": [420, 432] }
          },
          "state": {
            "extracted_string_or_numeric_value": "Mi",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [515, 535], "vertical_y_vertices": [420, 432] }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "49665",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 585], "vertical_y_vertices": [420, 432] }
          }
        }
      },
      "company": {
        "name": {
          "extracted_string_or_numeric_value": "Kibby Company, LLC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [245, 385], "vertical_y_vertices": [385, 398] }
        },
        "company_type": {
          "extracted_string_or_numeric_value": "Michigan limited liability company",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [415, 660], "vertical_y_vertices": [385, 398] }
        },
        "status": {
          "extracted_string_or_numeric_value": "in good standing",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [665, 775], "vertical_y_vertices": [385, 398] }
        },
        "regulating_department": {
          "extracted_string_or_numeric_value": "Michigan Department of Licensing and Regulation",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 680], "vertical_y_vertices": [402, 415] }
        }
      },
      "property_details": {
        "parcel_id": {
          "extracted_string_or_numeric_value": "Parcel 5",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 330], "vertical_y_vertices": [505, 518] }
        },
        "legal_description": {
          "extracted_string_or_numeric_value": "Part of the Southwest One-quarter of the Northwest One-quarter of Section 27, Township 20 North, Range 7 West, being more particularly described as: commencing at the Northwest Corner of said Section; thence S00*00;00\"W along the West Section line, 1362.79 feet to the Point of Beginning; thence continuing S00*00′00″W along said line, 303.22 feet; thence S89*28'58\"E, 355.95 feet; thence N00*00'00″E parallel with said West Section line, 191.19 feet; thence N89*30′10″W parallel with the North One-eighth line, 169.85 feet; thence N28*30'43\"W, 21.72 feet, thence N00*00'00\"E parallel with said West Section line, 93.00 feet; thence N89*30'10\"W parallel with said One-eight line, 176.00 feet to the point of beginning. (Together with two (2) easements)",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 820], "vertical_y_vertices": [520, 695] }
        }
      },
      "chain_of_title": {
        "survey_certificate": {
          "liber": {
            "extracted_string_or_numeric_value": 856,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 520], "vertical_y_vertices": [720, 732] }
          },
          "page": {
            "extracted_string_or_numeric_value": 228,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [575, 605], "vertical_y_vertices": [720, 732] }
          }
        },
        "quit_claim_deed": {
          "deed_date": {
            "extracted_string_or_numeric_value": "April 29, 2008",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 600], "vertical_y_vertices": [750, 762] }
          },
          "recorded_date": {
            "extracted_string_or_numeric_value": "May 1, 2008",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 780], "vertical_y_vertices": [750, 762] }
          },
          "liber": {
            "extracted_string_or_numeric_value": 861,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 350], "vertical_y_vertices": [765, 777] }
          },
          "page": {
            "extracted_string_or_numeric_value": 6,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [405, 415], "vertical_y_vertices": [765, 777] }
          },
          "grantors": [
            {
              "extracted_string_or_numeric_value": "Allen L. Johnson and Terri L. Johnson, Husband and Wife",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 790], "vertical_y_vertices": [780, 792] }
            },
            {
              "extracted_string_or_numeric_value": "Joseph D. Minterfering and Lori Minterfering, Husband and Wife",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 790], "vertical_y_vertices": [795, 807] }
            }
          ],
          "grantee": {
            "extracted_string_or_numeric_value": "Kibby Company, LLC",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 650], "vertical_y_vertices": [810, 822] }
          }
        }
      },
      "related_mortgage": {
        "mortgage_date": {
          "extracted_string_or_numeric_value": "October 28, 2011",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [340, 480], "vertical_y_vertices": [835, 847] }
        },
        "recorded_date": {
          "extracted_string_or_numeric_value": "November 9, 2011",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 730], "vertical_y_vertices": [835, 847] }
        },
        "liber": {
          "extracted_string_or_numeric_value": 903,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 350], "vertical_y_vertices": [850, 862] }
        },
        "page": {
          "extracted_string_or_numeric_value": 148,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [405, 435], "vertical_y_vertices": [850, 862] }
        },
        "mortgagors": [
          {
            "extracted_string_or_numeric_value": "Joseph D. Mintefering and Lori Minterfering, Husband and Wife",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 790], "vertical_y_vertices": [865, 877] }
          }
        ],
        "issue_description": {
          "extracted_string_or_numeric_value": "purports to include a portion of the above described \"Parcel 5\".",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 790], "vertical_y_vertices": [880, 892] }
        }
      },
      "affidavit_purpose": {
        "extracted_string_or_numeric_value": "This Affidavit is made of purposes of giving record notice that said mortgage purports to encumber a southerly portion of the previously described \"Parcel 5\". Kibby Company, LLC is not and was not a party to said mortgage, said mortgage does not encumber any part of said \"Parcel 5\" and Kibby Company, LLC does not intend to abandon or cede any portion of said Parcel 5 to anyone.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 820], "vertical_y_vertices": [240, 350] }
      },
      "execution_details": {
        "affidavit_date": {
          "extracted_string_or_numeric_value": "April 22, 2016",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 530], "vertical_y_vertices": [360, 372] }
        },
        "affiant_signature_present": {
          "extracted_string_or_numeric_value": "Present",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 790], "vertical_y_vertices": [400, 440] }
        }
      },
      "acknowledgement": {
        "date": {
          "extracted_string_or_numeric_value": "22 day of April, 2016",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 590], "vertical_y_vertices": [470, 482] }
        },
        "acknowledged_by": {
          "extracted_string_or_numeric_value": "Judith Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [620, 720], "vertical_y_vertices": [470, 482] }
        },
        "notary": {
          "name": {
            "extracted_string_or_numeric_value": "GREGORY C MERRIFIELD",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690], "vertical_y_vertices": [550, 562] }
          },
          "county": {
            "extracted_string_or_numeric_value": "Osceola County",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690], "vertical_y_vertices": [575, 587] }
          },
          "state": {
            "extracted_string_or_numeric_value": "Michigan",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690], "vertical_y_vertices": [562, 575] }
          },
          "commission_expires": {
            "extracted_string_or_numeric_value": "May 3, 2020",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 690], "vertical_y_vertices": [587, 600] }
          },
          "acting_county": {
            "extracted_string_or_numeric_value": "Osceola",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 720], "vertical_y_vertices": [600, 612] }
          }
        }
      },
      "drafter": {
        "name": {
          "extracted_string_or_numeric_value": "Gregory C. Merrifield",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 370], "vertical_y_vertices": [530, 542] }
        },
        "title": {
          "extracted_string_or_numeric_value": "Attorney at Law",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 330], "vertical_y_vertices": [545, 557] }
        },
        "bar_number": {
          "extracted_string_or_numeric_value": "P27300",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [335, 390], "vertical_y_vertices": [545, 557] }
        },
        "address": {
          "street": {
            "extracted_string_or_numeric_value": "221 E. Main/Box 172",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 370], "vertical_y_vertices": [560, 572] }
          },
          "city": {
            "extracted_string_or_numeric_value": "Marion",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 270], "vertical_y_vertices": [575, 587] }
          },
          "state": {
            "extracted_string_or_numeric_value": "Mi",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [275, 295], "vertical_y_vertices": [575, 587] }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "49665",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 345], "vertical_y_vertices": [575, 587] }
          }
        }
      }
    }
  }
]
```