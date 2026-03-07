An expert forensic data architect, operating under a Zero-Trust mandate, has meticulously analyzed the provided document (`2015 Sixth Addendum to Lease`) to produce the following resilient Pydantic V2 schema and a corresponding golden test case.

### BLOCK 1 (Python Pydantic V2)
```python
import math
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for a data entity on a physical document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single piece of extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Party(BaseModel):
    """Represents a party to the lease agreement (Landlord or Tenant)."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    entity_type: ForensicDataEntity
    address: ForensicDataEntity
    dba: Optional[ForensicDataEntity] = None

class Recitals(BaseModel):
    """Contains the background information and context for the amendment."""
    model_config = ConfigDict(extra='forbid')
    original_lease_date: ForensicDataEntity
    original_landlord: ForensicDataEntity
    original_tenant: ForensicDataEntity
    leased_premises_address: ForensicDataEntity
    fifth_amendment_date: ForensicDataEntity
    remaining_options_before_amendment: ForensicDataEntity

class RentPeriod(BaseModel):
    """Defines the rent amounts for a specific period within the lease term."""
    model_config = ConfigDict(extra='forbid')
    start_date: ForensicDataEntity
    end_date: ForensicDataEntity
    annual_base_rent: ForensicDataEntity
    monthly_rent: ForensicDataEntity

class Signature(BaseModel):
    """Represents a signature on the document."""
    model_config = ConfigDict(extra='forbid')
    signer_name: ForensicDataEntity
    signer_title: ForensicDataEntity
    formerly_known_as: Optional[ForensicDataEntity] = None
    signing_for: Optional[ForensicDataEntity] = None

class SixthLeaseAmendment(BaseModel):
    """
    A resilient schema for the 'Sixth Amendment to Lease' document class,
    capturing all structural elements and ensuring financial integrity.
    """
    model_config = ConfigDict(extra='forbid')
    
    document_title: ForensicDataEntity
    location_in_parentheses: ForensicDataEntity
    execution_date: ForensicDataEntity
    landlord: Party
    tenant: Party
    recitals: Recitals
    new_lease_expiration_date: ForensicDataEntity
    rent_schedule: List[RentPeriod]
    landlord_signatures: List[Signature]
    tenant_signature: Signature

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'SixthLeaseAmendment':
        """
        Performs a double-entry GAAP checksum on the rent schedule.
        Verifies that Annual Rent / 12 equals the stated Monthly Rent,
        within a small tolerance for rounding.
        """
        for period in self.rent_schedule:
            annual_rent = period.annual_base_rent.extracted_string_or_numeric_value
            monthly_rent = period.monthly_rent.extracted_string_or_numeric_value

            if not isinstance(annual_rent, (int, float)) or not isinstance(monthly_rent, (int, float)):
                raise ValueError(f"Rent values must be numeric for validation. Found types: {type(annual_rent)}, {type(monthly_rent)}")

            calculated_monthly = annual_rent / 12
            
            # Use a tolerance of $0.01 for floating point and rounding discrepancies
            if not math.isclose(calculated_monthly, monthly_rent, rel_tol=0, abs_tol=0.01):
                raise ValueError(
                    f"Checksum failed for period ending {period.end_date.extracted_string_or_numeric_value}: "
                    f"Annual rent {annual_rent} / 12 = {calculated_monthly:.2f}, "
                    f"but stated monthly rent is {monthly_rent}."
                )
        return self

```

### BLOCK 2 (JSON Test Registry)
```json
[
  {
    "test_identifier": "2015_kibby_family_fare_marion_lease_amendment",
    "should_pass": true,
    "taxonomy_lane": "SixthLeaseAmendment",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "SIXTH AMENDMENT TO LEASE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [123.0, 876.0],
          "vertical_y_vertices": [120.0, 135.0]
        }
      },
      "location_in_parentheses": {
        "extracted_string_or_numeric_value": "Marion",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [123.0, 876.0],
          "vertical_y_vertices": [140.0, 155.0]
        }
      },
      "execution_date": {
        "extracted_string_or_numeric_value": "7/27, 2015",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [700.0, 800.0],
          "vertical_y_vertices": [160.0, 180.0]
        }
      },
      "landlord": {
        "name": {
          "extracted_string_or_numeric_value": "KIBBY COMPANY, L.L.C.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [290.0, 550.0],
            "vertical_y_vertices": [185.0, 200.0]
          }
        },
        "entity_type": {
          "extracted_string_or_numeric_value": "a Michigan limited liability company",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [555.0, 876.0],
            "vertical_y_vertices": [185.0, 200.0]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291-18 Mile Road, Marion, Michigan 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218.0, 680.0],
            "vertical_y_vertices": [200.0, 215.0]
          }
        }
      },
      "tenant": {
        "name": {
          "extracted_string_or_numeric_value": "FAMILY FARE, LLC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580.0, 770.0],
            "vertical_y_vertices": [215.0, 230.0]
          }
        },
        "entity_type": {
          "extracted_string_or_numeric_value": "a Michigan limited liability company",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218.0, 500.0],
            "vertical_y_vertices": [230.0, 245.0]
          }
        },
        "dba": {
          "extracted_string_or_numeric_value": "d/b/a Glen's Markets",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [505.0, 690.0],
            "vertical_y_vertices": [230.0, 245.0]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "850 - 76th Street, S.W., P.O. Box 8700, Grand Rapids, Michigan 49518-8700",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [218.0, 876.0],
            "vertical_y_vertices": [245.0, 275.0]
          }
        }
      },
      "recitals": {
        "original_lease_date": {
          "extracted_string_or_numeric_value": "September 29, 1992",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [620.0, 780.0],
            "vertical_y_vertices": [325.0, 340.0]
          }
        },
        "original_landlord": {
          "extracted_string_or_numeric_value": "Max R. Kibby and Judith A. Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [265.0, 580.0],
            "vertical_y_vertices": [310.0, 325.0]
          }
        },
        "original_tenant": {
          "extracted_string_or_numeric_value": "Ashcraft's Market, Inc.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [610.0, 800.0],
            "vertical_y_vertices": [310.0, 325.0]
          }
        },
        "leased_premises_address": {
          "extracted_string_or_numeric_value": "401 S. Mill Road, Marion, Michigan 49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [580.0, 876.0],
            "vertical_y_vertices": [355.0, 385.0]
          }
        },
        "fifth_amendment_date": {
          "extracted_string_or_numeric_value": "July 14th, 2014",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650.0, 780.0],
            "vertical_y_vertices": [550.0, 565.0]
          }
        },
        "remaining_options_before_amendment": {
          "extracted_string_or_numeric_value": "four (4)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [670.0, 750.0],
            "vertical_y_vertices": [670.0, 685.0]
          }
        }
      },
      "new_lease_expiration_date": {
        "extracted_string_or_numeric_value": "September 26, 2019",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [350.0, 520.0],
          "vertical_y_vertices": [1140.0, 130.0]
        }
      },
      "rent_schedule": [
        {
          "start_date": {
            "extracted_string_or_numeric_value": "Sept 27, 2015",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220.0, 360.0],
              "vertical_y_vertices": [1140.0, 280.0]
            }
          },
          "end_date": {
            "extracted_string_or_numeric_value": "Sept. 26, 2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [365.0, 500.0],
              "vertical_y_vertices": [1140.0, 280.0]
            }
          },
          "annual_base_rent": {
            "extracted_string_or_numeric_value": 84553.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [540.0, 630.0],
              "vertical_y_vertices": [1140.0, 280.0]
            }
          },
          "monthly_rent": {
            "extracted_string_or_numeric_value": 7046.08,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700.0, 780.0],
              "vertical_y_vertices": [1140.0, 280.0]
            }
          }
        },
        {
          "start_date": {
            "extracted_string_or_numeric_value": "Sept. 27, 2018",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [220.0, 360.0],
              "vertical_y_vertices": [1140.0, 340.0]
            }
          },
          "end_date": {
            "extracted_string_or_numeric_value": "Sept. 26, 2019",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [365.0, 500.0],
              "vertical_y_vertices": [1140.0, 340.0]
            }
          },
          "annual_base_rent": {
            "extracted_string_or_numeric_value": 104553.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [540.0, 630.0],
              "vertical_y_vertices": [1140.0, 340.0]
            }
          },
          "monthly_rent": {
            "extracted_string_or_numeric_value": 8712.75,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [700.0, 780.0],
              "vertical_y_vertices": [1140.0, 340.0]
            }
          }
        }
      ],
      "landlord_signatures": [
        {
          "signer_name": {
            "extracted_string_or_numeric_value": "Judith A. Grandy",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 650.0],
              "vertical_y_vertices": [1240.0, 255.0]
            }
          },
          "signer_title": {
            "extracted_string_or_numeric_value": "Member",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 600.0],
              "vertical_y_vertices": [1240.0, 285.0]
            }
          },
          "formerly_known_as": {
            "extracted_string_or_numeric_value": "Judith A. Kibby",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 780.0],
              "vertical_y_vertices": [1240.0, 270.0]
            }
          },
          "signing_for": {
            "extracted_string_or_numeric_value": "KIBBY COMPANY, L.L.C.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [490.0, 690.0],
              "vertical_y_vertices": [1240.0, 200.0]
            }
          }
        },
        {
          "signer_name": {
            "extracted_string_or_numeric_value": "Judith A. Grandy",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 650.0],
              "vertical_y_vertices": [1240.0, 460.0]
            }
          },
          "signer_title": {
            "extracted_string_or_numeric_value": "Trustee",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 600.0],
              "vertical_y_vertices": [1240.0, 490.0]
            }
          },
          "formerly_known_as": {
            "extracted_string_or_numeric_value": "Judith A. Kibby",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 780.0],
              "vertical_y_vertices": [1240.0, 475.0]
            }
          },
          "signing_for": {
            "extracted_string_or_numeric_value": "Max R. Kibby Credit Trust",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [530.0, 750.0],
              "vertical_y_vertices": [1240.0, 330.0]
            }
          }
        }
      ],
      "tenant_signature": {
        "signer_name": {
          "extracted_string_or_numeric_value": "David M. Staples",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [530.0, 660.0],
            "vertical_y_vertices": [1240.0, 650.0]
          }
        },
        "signer_title": {
          "extracted_string_or_numeric_value": "Vice President and Treasurer",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [530.0, 750.0],
            "vertical_y_vertices": [1240.0, 680.0]
          }
        },
        "signing_for": {
          "extracted_string_or_numeric_value": "FAMILY FARE, LLC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [490.0, 650.0],
            "vertical_y_vertices": [1240.0, 600.0]
          }
        }
      }
    }
  }
]
```