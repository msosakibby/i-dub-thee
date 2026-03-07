BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """
    A polygon representing the spatial coordinates of an extracted entity on the document page.
    """
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """
    A wrapper for a single piece of extracted data, including its value, confidence, and location.
    """
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class ClientDetails(BaseModel):
    """
    Details of the client for whom the survey was conducted.
    """
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: ForensicDataEntity

class ParcelDescription(BaseModel):
    """
    A detailed description of a single parcel of land, including its legal description and any associated easements.
    """
    model_config = ConfigDict(extra='forbid')
    parcel_identifier: ForensicDataEntity = Field(description="The identifier for the parcel, e.g., 'Parcel One', 'Parcel Two'.")
    legal_description: ForensicDataEntity = Field(description="The full legal description of the parcel.")
    area: Optional[ForensicDataEntity] = Field(default=None, description="The area of the parcel, e.g., '2.9 acres'.")
    easements: Optional[List[ForensicDataEntity]] = Field(default=None, description="Text descriptions of any easements associated with the parcel.")

class RobertLWetherellLandSurveyor_CertificateOfSurvey(BaseModel):
    """
    A schema for a Certificate of Survey issued by Robert L. Wetherell, Land Surveyor.
    This model captures metadata, client information, certification details, and detailed descriptions of surveyed parcels.
    """
    model_config = ConfigDict(extra='forbid')

    liber: ForensicDataEntity = Field(description="The Liber (book) number where the survey is recorded.")
    page_start: ForensicDataEntity = Field(description="The starting page number where the survey is recorded.")
    total_sheets: ForensicDataEntity = Field(description="The total number of sheets in the survey document.")
    
    surveyor_name: ForensicDataEntity = Field(description="The name of the licensed surveyor.")
    surveyor_license_number: ForensicDataEntity = Field(description="The license number of the surveyor.")
    surveyor_company: Optional[ForensicDataEntity] = Field(default=None, description="The surveying company name.")
    surveyor_address: Optional[ForensicDataEntity] = Field(default=None, description="The address of the surveyor or their company.")
    
    client: ClientDetails = Field(description="Details of the client for whom the survey was performed.")
    
    file_number: Optional[ForensicDataEntity] = Field(default=None, description="The internal file number for the survey.")
    survey_date: ForensicDataEntity = Field(description="The date the survey was conducted and mapped.")
    
    certification_text: ForensicDataEntity = Field(description="The official certification statement by the surveyor.")
    
    parcels: List[ParcelDescription] = Field(description="A list of all parcels described in the survey.")
    
    map_notes: Optional[ForensicDataEntity] = Field(default=None, description="General notes included on the survey map.")
    annotations: Optional[List[ForensicDataEntity]] = Field(default=None, description="Any handwritten or other annotations on the document.")

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'RobertLWetherellLandSurveyor_CertificateOfSurvey':
        """
        This model validator is included to satisfy the directive.
        No financial numbers suitable for a double-entry GAAP checksum were found in the document.
        The closest numerical data are parcel areas, but no total area is provided for a sum check.
        Therefore, this validator confirms the absence of applicable data and performs no calculations.
        """
        # In a real-world scenario with financial data, one would implement a check like:
        # total_debits = sum(entry.amount for entry in self.entries if entry.type == 'debit')
        # total_credits = sum(entry.amount for entry in self.entries if entry.type == 'credit')
        # if not math.isclose(total_debits, total_credits):
        #     raise ValueError("GAAP checksum failed: Debits do not equal credits.")
        return self
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "wetherell_survey_978B_complex_variant",
    "should_pass": true,
    "taxonomy_lane": "RobertLWetherellLandSurveyor_CertificateOfSurvey",
    "binary_header_simulation": "25504446",
    "payload": {
      "liber": {
        "extracted_string_or_numeric_value": "664",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [498, 550, 550, 498],
          "vertical_y_vertices": [99, 99, 115, 115]
        }
      },
      "page_start": {
        "extracted_string_or_numeric_value": "566",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [560, 612, 612, 560],
          "vertical_y_vertices": [99, 99, 115, 115]
        }
      },
      "total_sheets": {
        "extracted_string_or_numeric_value": "3",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700, 710, 710, 700],
          "vertical_y_vertices": [65, 65, 78, 78]
        }
      },
      "surveyor_name": {
        "extracted_string_or_numeric_value": "Robert L. Wetherell",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [510, 680, 680, 510],
          "vertical_y_vertices": [875, 875, 888, 888]
        }
      },
      "surveyor_license_number": {
        "extracted_string_or_numeric_value": "24624",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [870, 925, 925, 870],
          "vertical_y_vertices": [850, 850, 865, 865]
        }
      },
      "surveyor_company": {
        "extracted_string_or_numeric_value": "% of McClung Land Surveying",
        "optical_extraction_confidence_score": 0.92,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [510, 680, 680, 510],
          "vertical_y_vertices": [889, 889, 902, 902]
        }
      },
      "surveyor_address": {
        "extracted_string_or_numeric_value": "19420 50th Ave. Marion, Michigan",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [510, 680, 680, 510],
          "vertical_y_vertices": [903, 903, 928, 928]
        }
      },
      "client": {
        "name": {
          "extracted_string_or_numeric_value": "Max Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 380, 380, 300],
            "vertical_y_vertices": [890, 890, 902, 902]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "301 S. Mill St. Marion, Michigan 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300, 480, 480, 300],
            "vertical_y_vertices": [903, 903, 928, 928]
          }
        }
      },
      "file_number": {
        "extracted_string_or_numeric_value": "978-B",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [260, 320, 320, 260],
          "vertical_y_vertices": [950, 950, 962, 962]
        }
      },
      "survey_date": {
        "extracted_string_or_numeric_value": "3 June 1999",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 730, 730, 650],
          "vertical_y_vertices": [800, 800, 812, 812]
        }
      },
      "certification_text": {
        "extracted_string_or_numeric_value": "I hereby certify that I have surveyed and mapped the land above described on, 3 June 1999, and that the ratio of closure of the unadjusted field observations of such survey was better then 1/5000 feet and that all of the requirements of P.A. 132, 1970 have been complied with.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [260, 960, 960, 260],
          "vertical_y_vertices": [800, 800, 850, 850]
        }
      },
      "parcels": [
        {
          "parcel_identifier": {
            "extracted_string_or_numeric_value": "Parcel One",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [80, 80, 95, 95]
            }
          },
          "legal_description": {
            "extracted_string_or_numeric_value": "A parcel of land located in the Northwest One Quarter of Section 27, T20N-R7W, Twp of Marion, Osceola County, Michigan described as. Commencing at the Northwest Corner of said section; thence South, along the West Line of said section, a distance of 901.04 feet; thence South 89 degrees 30 minutes 10 seconds East, a distance of 640.13 feet ta the POINT OF BEGINNING, thence North 89 degrees 30 minutes 10 seconds West, a distance of 640. 13 feet, to the West Line of said section, thence South, along the West Line of said section, a distance of 136.76 feet, thence South 89 degrees 30 minutes 10 seconds East, a distance of 746 52 feet, to the West right-of-way of the Ann Arbor Railroad, thence Northwesterly along the West right-of-way of the Ann Arbor Railroad to the point of beginning This parcel is subject to any easements or restrictions of record.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [96, 96, 220, 220]
            }
          }
        },
        {
          "parcel_identifier": {
            "extracted_string_or_numeric_value": "Parcel Two",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [250, 250, 265, 265]
            }
          },
          "legal_description": {
            "extracted_string_or_numeric_value": "A parcel of land located in the Northwest One Quarter of Section 27, T20N-R7W, Twp. of Marion, Osceola County, Michigan described as: Commencing at the Northwest Comer of said section, thence South, along the West Line of said section, distance of 1037.80 feet, to the POINT OF BEGINNING, thence South 89 degrees 30 minutes 10 seconds East, a distance of 275.96 feet; thence South 40 degrees 44 minutes 13 seconds West, a distance of 183.46 feet, thence North 89 degrees 30 minutes 10 seconds West, a distance of 156.23 feet, to the West Line of said section; thence North along the West Line of said section, a distance of 140.10 feet to the POINT OF BEGINNING, said tract contains 0.7 acres, more or less.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [266, 266, 360, 360]
            }
          },
          "area": {
            "extracted_string_or_numeric_value": "0.7 acres",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [300, 300, 310, 310]
            }
          },
          "easements": [
            {
              "extracted_string_or_numeric_value": "Together with an ingress and egress easement described as commencing at the Southwest Comer of said described parcel, said point being the POINT OF BEGINNING; thence South along the West Line of said section, a distance of 40.00 feet; thence South 89 degrees 30 minutes 10 seconds East, a distance of 156.23 feet; thence North 40 00 feet; thence North 89 degrees 30 minutes 10 seconds West, a distance of 156.23 feet to the POINT OF BEGINNING. This parcel is subject to any other easements or restrictions of record",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [240, 960, 960, 240],
                "vertical_y_vertices": [361, 361, 440, 440]
              }
            }
          ]
        },
        {
          "parcel_identifier": {
            "extracted_string_or_numeric_value": "Parcel Three",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [450, 450, 465, 465]
            }
          },
          "legal_description": {
            "extracted_string_or_numeric_value": "A parcel of land located in the Northwest One Quarter of Section 27, T20N-R7W, Twp. of Marion, Osceola County, Michigan described as: Commencing at the Northwest Corner of said section, thence South, along the West Line of said section, a distance of 1177.90 feet to the POINT OF BEGINNING, thence South 89 degrees 30 minutes 10 seconds East, a distance of 156.23 feet; thence North 40 degrees 44 minutes 13 seconds East, a distance of 183.46 feet, thence South 89 degrees 30 minutes 10 seconds East, a distance of 212.52 feet; thence South, a distance of 324.93 feet; thence North 89 degrees 30 minutes 10 seconds West, a distance of 488 48 feet, to the West Line of said section; thence North, along the West Line of said section, a distance of 184.89 feet to the POINT OF BEGINNING; said described tract containing 2.9 acres, more or less.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [466, 466, 580, 580]
            }
          },
          "area": {
            "extracted_string_or_numeric_value": "2.9 acres",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [570, 570, 580, 580]
            }
          },
          "easements": [
            {
              "extracted_string_or_numeric_value": "Subject to two ingress and egress casements the first being described as: Commencing at the Northwest Comer of said described parcel, said point being the POINT OF BEGINNING; thence South along the West Line of said section, a distance of 40.00 feet, thence South 89 degrees 30 minutes 10 seconds East, a distance of 156.23 feet; thence North 40.00 feet; thence North 89 degrees 30 minutes 10 seconds West, a distance of 156 23 feet to the POINT OF BEGINNING.",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [240, 960, 960, 240],
                "vertical_y_vertices": [581, 581, 660, 660]
              }
            },
            {
              "extracted_string_or_numeric_value": "The second being described as Commencing at the Southwest Corner of said described parcel, said point being the POINT OF BEGINNING; thence North along the West Line of said section, 40.00 feet, thence South 89 degrees 30 minutes 10 seconds East, a distance of 240.00 feet, thence South, 20.00 feet; thence South 89 degrees 30 minutes 10 seconds East, a distance of 110.00 feet; thence South 20.00 feet; thence North 89 degrees 30 minutes 10 seconds West, a distance of 350.00 feet, to the POINT OF BEGINNING.",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [240, 960, 960, 240],
                "vertical_y_vertices": [661, 661, 740, 740]
              }
            }
          ]
        },
        {
          "parcel_identifier": {
            "extracted_string_or_numeric_value": "Parcel Four",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [80, 80, 95, 95]
            }
          },
          "legal_description": {
            "extracted_string_or_numeric_value": "A parcel of land located in the Northwest One Quarter of Section 27, T20N-R7W. Twp. of Marion, Osceola County, Michigan described as Commencing at the Northwest Comer of said soction, thence South, along the West Line of said section, a distance of 1362.79 feet to the POINT OF BEGINNING, thence South 89 degrees 30 minutes 10 seconds East, a distance of 488 48 feet, thence North, a distance of 324.93 feet, thence South 89 degrees 30 minutes 10 seconds East, a distance of 258 04 feet, to the West right-of-way of the Ann Arbor Railroad. thance South 37 degrees 41 minutes 30 seconds East, along the West right-of-way of the Ann Arbor Railroad, a distance of 1074.72 feet, thence North 89 degrees 30 minutes 10 seconds West, a distance of 1174.73 feet, thence North 0 degrees 00 minutes 38 seconds East, a distance of 216.45 feet, thance North 89 degrees 28 minutes 58 seconds West, a distance of 228.95 feet, 10 the West Line of said section; thence North, along the West Line of said section, a distance of 303.22 feet to the POINT OF BEGINNING, said described tract contuning 16.1 acres, more ar less.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [240, 960, 960, 240],
              "vertical_y_vertices": [96, 96, 280, 280]
            }
          },
          "area": {
            "extracted_string_or_numeric_value": "16.1 acres",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [300, 350, 350, 300],
              "vertical_y_vertices": [270, 270, 280, 280]
            }
          },
          "easements": [
            {
              "extracted_string_or_numeric_value": "Together with an ingress and egress easement described as: commencing at the Northwest Comer of said described parcel, said point being the POINT OF BEGINNING, thence North along the West Line of said section, 40.00 feet; thence South 89 degrees 30 minutes 10 seconds East, a distance of 240.00 feet; thence South, 20.00 feet; thence South 89 degrees 30 minutes 10 seconds East, a distance of 110.00 feet, thence South 20.00 feet; thence North 89 degrees 30 minutes 10 seconds West, a distance of 350.00 feet, to the POINT OF BEGINNING. This parcel is subject to any other easements or restrictions of record.",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [240, 960, 960, 240],
                "vertical_y_vertices": [281, 281, 380, 380]
              }
            }
          ]
        }
      ],
      "map_notes": {
        "extracted_string_or_numeric_value": "Notes: Basis of bearings is determined from Liber 302, Page 77, Osceola County Register of Deeds. fd. survey iron. fd. government corner. O set iron & cap #13037.",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 850, 850, 450],
          "vertical_y_vertices": [660, 660, 730, 730]
        }
      },
      "annotations": [
        {
          "extracted_string_or_numeric_value": "67-41-027-028-01",
          "optical_extraction_confidence_score": 0.85,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580, 800, 800, 580],
            "vertical_y_vertices": [480, 480, 580, 580]
          }
        },
        {
          "extracted_string_or_numeric_value": "to LEO",
          "optical_extraction_confidence_score": 0.80,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [350, 400, 400, 350],
            "vertical_y_vertices": [550, 550, 580, 580]
          }
        }
      ]
    }
  }
]
```