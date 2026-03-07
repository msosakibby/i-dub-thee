An expert forensic data architect, I have meticulously analyzed the provided documents and designed a resilient Pydantic V2 schema to accommodate the observed structural drift. The schema is built to handle the core lease amendment, as well as related correspondence like notices and third-party forms, by leveraging optional fields.

The most complex structural variant is the `Third Amendment to Lease`, which contains nested details about renewal options and rental rate adjustments. The test case below is based on this document, augmented with data from the related notice letters and the Michigan Lottery form to ensure the schema's flexibility and completeness.

***

### BLOCK 1: Python Pydantic V2 Schema

```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon for the spatial coordinates of an extracted entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for extracted data, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Address(BaseModel):
    """Represents a physical or mailing address."""
    model_config = ConfigDict(extra='forbid')
    street_address: Optional[ForensicDataEntity] = None
    po_box: Optional[ForensicDataEntity] = None
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: ForensicDataEntity

class Signatory(BaseModel):
    """Represents a person signing a document."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    title: ForensicDataEntity
    representing_entity: Optional[ForensicDataEntity] = None
    date: Optional[ForensicDataEntity] = None

class PartyDetails(BaseModel):
    """Represents a party to the lease, such as Landlord or Tenant."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: Address
    doing_business_as: Optional[ForensicDataEntity] = None
    attention: Optional[ForensicDataEntity] = None
    signatories: Optional[List[Signatory]] = None

class RentalRate(BaseModel):
    """Details the rental rate and adjustment clauses."""
    model_config = ConfigDict(extra='forbid')
    initial_renewal_rate_per_sq_ft: Optional[ForensicDataEntity] = None
    rate_floor_per_sq_ft: Optional[ForensicDataEntity] = None
    rate_cap_per_sq_ft: Optional[ForensicDataEntity] = None
    adjustment_frequency_years: Optional[ForensicDataEntity] = None
    adjustment_index: Optional[ForensicDataEntity] = None

class RenewalOption(BaseModel):
    """Details the terms for lease renewal options."""
    model_config = ConfigDict(extra='forbid')
    option_description: ForensicDataEntity
    tenant_notice_period_days: ForensicDataEntity
    landlord_reminder_period_days: ForensicDataEntity

class LeaseTermDetails(BaseModel):
    """Contains specific terms of the lease agreement."""
    model_config = ConfigDict(extra='forbid')
    original_lease_date: ForensicDataEntity
    current_term_expiration_date: ForensicDataEntity
    renewal_options: List[RenewalOption]
    rental_rate: RentalRate

class FirstAmendmentToSpartanNashLease(BaseModel):
    """
    A schema representing a lease amendment and related correspondence between
    a landlord (Kibby Company) and a tenant (Family Fare / SpartanNash).
    """
    model_config = ConfigDict(extra='forbid')
    
    document_type: ForensicDataEntity
    document_date: ForensicDataEntity
    landlord: PartyDetails
    tenant: PartyDetails
    property_address: Address
    lease_details: Optional[LeaseTermDetails] = None
    
    # Optional fields from related correspondence
    exercised_renewal_start_date: Optional[ForensicDataEntity] = None
    exercised_renewal_end_date: Optional[ForensicDataEntity] = None
    lottery_retailer_id: Optional[ForensicDataEntity] = None
    acknowledgement_signature: Optional[Signatory] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'FirstAmendmentToSpartanNashLease':
        """
        Executes double-entry GAAP mathematical checksums.
        
        Note: The provided documents (lease amendments, notices) do not contain
        transactional financial data like invoices or ledgers with debit/credit
        entries. They specify rental rates and formulas for future adjustments.
        Therefore, a traditional double-entry checksum is not applicable.
        This validator is included to meet the structural requirement of the prompt.
        """
        # No financial transactions to validate in this document class.
        return self

```

### BLOCK 2: JSON Test Registry

```json
[
  {
    "test_identifier": "lease-amendment-composite-001",
    "should_pass": true,
    "taxonomy_lane": "FirstAmendmentToSpartanNashLease",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_type": {
        "extracted_string_or_numeric_value": "THIRD AMENDMENT TO LEASE",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 900],
          "vertical_y_vertices": [100, 150]
        }
      },
      "document_date": {
        "extracted_string_or_numeric_value": "2008-05-27",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [650, 750],
          "vertical_y_vertices": [200, 220]
        }
      },
      "landlord": {
        "name": {
          "extracted_string_or_numeric_value": "KIBBY COMPANY, L.L.C.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 600],
            "vertical_y_vertices": [250, 270]
          }
        },
        "address": {
          "street_address": {
            "extracted_string_or_numeric_value": "3291 - 18 Mile Road",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 600],
              "vertical_y_vertices": [275, 295]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Marion",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 300],
              "vertical_y_vertices": [300, 320]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Michigan",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [310, 410],
              "vertical_y_vertices": [300, 320]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "49665",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [420, 500],
              "vertical_y_vertices": [300, 320]
            }
          }
        },
        "signatories": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Judith A. Kibby",
              "optical_extraction_confidence_score": 0.95,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 800],
                "vertical_y_vertices": [150, 170]
              }
            },
            "title": {
              "extracted_string_or_numeric_value": "Member",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 650],
                "vertical_y_vertices": [175, 195]
              }
            },
            "representing_entity": {
              "extracted_string_or_numeric_value": "KIBBY COMPANY, L.L.C.",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [520, 720],
                "vertical_y_vertices": [125, 145]
              }
            }
          },
          {
            "name": {
              "extracted_string_or_numeric_value": "Judith A. Kibby",
              "optical_extraction_confidence_score": 0.94,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 800],
                "vertical_y_vertices": [350, 370]
              }
            },
            "title": {
              "extracted_string_or_numeric_value": "Trustee",
              "optical_extraction_confidence_score": 0.97,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 650],
                "vertical_y_vertices": [375, 395]
              }
            },
            "representing_entity": {
              "extracted_string_or_numeric_value": "Max R. Kibby Credit Trust",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [520, 820],
                "vertical_y_vertices": [250, 270]
              }
            }
          }
        ]
      },
      "tenant": {
        "name": {
          "extracted_string_or_numeric_value": "FAMILY FARE, LLC",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 600],
            "vertical_y_vertices": [350, 370]
          }
        },
        "address": {
          "street_address": {
            "extracted_string_or_numeric_value": "850-76th Street, S.W.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 600],
              "vertical_y_vertices": [375, 395]
            }
          },
          "po_box": {
            "extracted_string_or_numeric_value": "8700",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 300],
              "vertical_y_vertices": [400, 420]
            }
          },
          "city": {
            "extracted_string_or_numeric_value": "Grand Rapids",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [310, 450],
              "vertical_y_vertices": [400, 420]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "MI",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [460, 500],
              "vertical_y_vertices": [400, 420]
            }
          },
          "zip_code": {
            "extracted_string_or_numeric_value": "49518-8700",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [510, 650],
              "vertical_y_vertices": [400, 420]
            }
          }
        },
        "doing_business_as": {
          "extracted_string_or_numeric_value": "Glen's Markets",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 400],
            "vertical_y_vertices": [375, 395]
          }
        },
        "signatories": [
          {
            "name": {
              "extracted_string_or_numeric_value": "Illegible Signature",
              "optical_extraction_confidence_score": 0.90,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 800],
                "vertical_y_vertices": [650, 670]
              }
            },
            "title": {
              "extracted_string_or_numeric_value": "VP Real Estate",
              "optical_extraction_confidence_score": 0.92,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [550, 700],
                "vertical_y_vertices": [675, 695]
              }
            },
            "representing_entity": {
              "extracted_string_or_numeric_value": "Seaway Food Town, Inc., a Michigan corporation",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [520, 920],
                "vertical_y_vertices": [550, 570]
              }
            }
          }
        ]
      },
      "property_address": {
        "street_address": {
          "extracted_string_or_numeric_value": "401 S. Mill Road",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 500],
            "vertical_y_vertices": [500, 520]
          }
        },
        "city": {
          "extracted_string_or_numeric_value": "Marion",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [510, 600],
            "vertical_y_vertices": [500, 520]
          }
        },
        "state": {
          "extracted_string_or_numeric_value": "Michigan",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [610, 710],
            "vertical_y_vertices": [500, 520]
          }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "49665",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [720, 800],
            "vertical_y_vertices": [500, 520]
          }
        }
      },
      "lease_details": {
        "original_lease_date": {
          "extracted_string_or_numeric_value": "1992-09-29",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 400],
            "vertical_y_vertices": [600, 620]
          }
        },
        "current_term_expiration_date": {
          "extracted_string_or_numeric_value": "2008-09-26",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 400],
            "vertical_y_vertices": [700, 720]
          }
        },
        "renewal_options": [
          {
            "option_description": {
              "extracted_string_or_numeric_value": "up to five (5) additional separate and consecutive terms of one (1) year each, followed by one (1) additional consecutive term of five (5) years",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 900],
                "vertical_y_vertices": [750, 800]
              }
            },
            "tenant_notice_period_days": {
              "extracted_string_or_numeric_value": 90,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 300],
                "vertical_y_vertices": [850, 870]
              }
            },
            "landlord_reminder_period_days": {
              "extracted_string_or_numeric_value": 120,
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [200, 300],
                "vertical_y_vertices": [900, 920]
              }
            }
          }
        ],
        "rental_rate": {
          "initial_renewal_rate_per_sq_ft": {
            "extracted_string_or_numeric_value": 5.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 300],
              "vertical_y_vertices": [1000, 1020]
            }
          },
          "rate_floor_per_sq_ft": {
            "extracted_string_or_numeric_value": 5.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 300],
              "vertical_y_vertices": [1100, 1120]
            }
          },
          "rate_cap_per_sq_ft": {
            "extracted_string_or_numeric_value": 8.00,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 300],
              "vertical_y_vertices": [1050, 1070]
            }
          },
          "adjustment_frequency_years": {
            "extracted_string_or_numeric_value": 3,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 300],
              "vertical_y_vertices": [1150, 1170]
            }
          },
          "adjustment_index": {
            "extracted_string_or_numeric_value": "Consumer Price Index for all Urban Consumers",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [200, 900],
              "vertical_y_vertices": [1200, 1250]
            }
          }
        }
      },
      "exercised_renewal_start_date": {
        "extracted_string_or_numeric_value": "2008-09-27",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300],
          "vertical_y_vertices": [1300, 1320]
        }
      },
      "exercised_renewal_end_date": {
        "extracted_string_or_numeric_value": "2009-09-26",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 300],
          "vertical_y_vertices": [1350, 1370]
        }
      },
      "lottery_retailer_id": {
        "extracted_string_or_numeric_value": "43083",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [100, 200],
          "vertical_y_vertices": [1400, 1420]
        }
      },
      "acknowledgement_signature": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 300],
            "vertical_y_vertices": [1500, 1520]
          }
        },
        "title": {
          "extracted_string_or_numeric_value": "Member",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 200],
            "vertical_y_vertices": [1525, 1545]
          }
        },
        "representing_entity": {
          "extracted_string_or_numeric_value": "Kibby Company, LLC",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [100, 300],
            "vertical_y_vertices": [1475, 1495]
          }
        },
        "date": {
          "extracted_string_or_numeric_value": "2008-06-27",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [400, 600],
            "vertical_y_vertices": [1500, 1520]
          }
        }
      }
    }
  }
]
```