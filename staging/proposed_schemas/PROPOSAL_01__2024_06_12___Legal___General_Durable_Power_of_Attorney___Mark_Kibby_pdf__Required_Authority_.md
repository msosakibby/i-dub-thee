An analysis of the provided document, `01. 2024-06-12 - Legal - General Durable Power of Attorney - Mark Kibby.pdf`, reveals a composite legal package containing a General Durable Power of Attorney, a Durable Power of Attorney for Health Care, and several related acknowledgment and certification forms. The schema is designed to encapsulate this entire package as a single, cohesive data structure, treating the various sections as components of one overarching document class.

### Key Structural Components Identified:
1.  **General Durable Power of Attorney (Financial):** The primary instrument, appointing an agent for financial matters.
2.  **Durable Power of Attorney for Health Care:** A secondary, but distinct, instrument appointing a patient advocate for medical decisions.
3.  **Principal's Notarization:** A Nevada-based remote online notarization for the principal's signatures on both POA documents.
4.  **Agent's Acceptance/Acknowledgment Forms:** Multiple forms signed by the agent, including a general acceptance of trust and a state-specific acknowledgment form.
5.  **Agent's Certification of Validity:** A form certified by the agent and notarized in Texas, attesting to the ongoing validity of the power of attorney.

The resulting Pydantic V2 schema, `GeneralDurablePowerOfAttorneyPackage`, models these components using nested classes. This approach provides a resilient and comprehensive representation of the entire document set, accommodating the different signers, dates, and notaries involved across the various sub-documents.

***

```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# Base classes provided in the directive
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Custom schema for the Power of Attorney document package
class PowerOfAttorneyParty(BaseModel):
    """Represents a party involved in the power of attorney."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    address: Optional[ForensicDataEntity] = None
    relationship: Optional[ForensicDataEntity] = None

class Notary(BaseModel):
    """Represents a notary public and their acknowledgment."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    signature: ForensicDataEntity
    state: ForensicDataEntity
    county: Optional[ForensicDataEntity] = None
    commission_number: Optional[ForensicDataEntity] = None
    commission_expiry_date: ForensicDataEntity
    notarization_method: Optional[ForensicDataEntity] = None

class AcknowledgementCertificate(BaseModel):
    """Represents the notarial certificate page."""
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    document_date: ForensicDataEntity
    page_count: ForensicDataEntity
    acknowledged_by: ForensicDataEntity
    acknowledgement_date: ForensicDataEntity
    notary: Notary

class HealthCarePOA(BaseModel):
    """Represents the Durable Power of Attorney for Health Care."""
    model_config = ConfigDict(extra='forbid')
    principal: PowerOfAttorneyParty
    agent: PowerOfAttorneyParty
    successor_agent: PowerOfAttorneyParty
    execution_date: ForensicDataEntity
    principal_signature: ForensicDataEntity
    acknowledgement: AcknowledgementCertificate

class AgentForms(BaseModel):
    """Represents the various forms signed by the agent."""
    model_config = ConfigDict(extra='forbid')
    acceptance_of_trust_signature: ForensicDataEntity
    acceptance_of_trust_poa_date: ForensicDataEntity
    acknowledgement_form_signature: ForensicDataEntity
    acknowledgement_form_signature_date: ForensicDataEntity
    acknowledgement_form_notary_state: ForensicDataEntity
    certification_of_validity_signature: ForensicDataEntity
    certification_of_validity_signature_date: ForensicDataEntity
    certification_of_validity_certifier_phone: ForensicDataEntity
    certification_of_validity_notary: Notary

class GeneralDurablePowerOfAttorneyPackage(BaseModel):
    """
    A comprehensive schema for the General Durable Power of Attorney package,
    including the financial POA, health care POA, and related agent forms.
    """
    model_config = ConfigDict(extra='forbid')

    principal: PowerOfAttorneyParty
    agent: PowerOfAttorneyParty
    alternate_agent: PowerOfAttorneyParty
    governing_act: ForensicDataEntity
    execution_date: ForensicDataEntity
    principal_signature: ForensicDataEntity
    acknowledgement: AcknowledgementCertificate
    health_care_poa: HealthCarePOA
    agent_forms: AgentForms

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GeneralDurablePowerOfAttorneyPackage':
        """
        Executes double-entry GAAP mathematical checksums.
        No financial fields are present in this document class for validation.
        This validator is included to meet the directive's requirements.
        """
        # No financial data to validate in this document.
        return self

```
```json
[
  {
    "test_identifier": "01_2024-06-12_general_durable_power_of_attorney_mark_kibby",
    "should_pass": true,
    "taxonomy_lane": "GeneralDurablePowerOfAttorneyPackage",
    "binary_header_simulation": "25504446",
    "payload": {
      "principal": {
        "name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 333],
            "vertical_y_vertices": [121, 133]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [339, 700],
            "vertical_y_vertices": [121, 133]
          }
        }
      },
      "agent": {
        "name": {
          "extracted_string_or_numeric_value": "Mark William Sosa-Kibby",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [493, 685],
            "vertical_y_vertices": [137, 149]
          }
        },
        "address": {
          "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, MI 49665",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 541],
            "vertical_y_vertices": [153, 165]
          }
        },
        "relationship": {
          "extracted_string_or_numeric_value": "my son",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [430, 484],
            "vertical_y_vertices": [137, 149]
          }
        }
      },
      "alternate_agent": {
        "name": {
          "extracted_string_or_numeric_value": "JoAnn S. Weston",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [477, 618],
            "vertical_y_vertices": [285, 297]
          }
        }
      },
      "governing_act": {
        "extracted_string_or_numeric_value": "Michigan Durable Power of Attorney Act (MCL §700.5501)",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [340, 788],
          "vertical_y_vertices": [185, 197]
        }
      },
      "execution_date": {
        "extracted_string_or_numeric_value": "June 12, 2024",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 300],
          "vertical_y_vertices": [483, 495]
        }
      },
      "principal_signature": {
        "extracted_string_or_numeric_value": "Judth A Grandy",
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [188, 342],
          "vertical_y_vertices": [505, 539]
        }
      },
      "acknowledgement": {
        "title": {
          "extracted_string_or_numeric_value": "Certificate of Acknowledgement",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [338, 616],
            "vertical_y_vertices": [121, 131]
          }
        },
        "document_date": {
          "extracted_string_or_numeric_value": "06/12/2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [325, 403],
            "vertical_y_vertices": [152, 162]
          }
        },
        "page_count": {
          "extracted_string_or_numeric_value": 6,
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [499, 508],
            "vertical_y_vertices": [183, 193]
          }
        },
        "acknowledged_by": {
          "extracted_string_or_numeric_value": "Judth A Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [470, 580],
            "vertical_y_vertices": [383, 393]
          }
        },
        "acknowledgement_date": {
          "extracted_string_or_numeric_value": "06/12/2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [321, 400],
            "vertical_y_vertices": [383, 393]
          }
        },
        "notary": {
          "name": {
            "extracted_string_or_numeric_value": "Darlene Morris",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [625, 699],
              "vertical_y_vertices": [425, 433]
            }
          },
          "signature": {
            "extracted_string_or_numeric_value": "Darlene Morris",
            "optical_extraction_confidence_score": 0.94,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [315, 498],
              "vertical_y_vertices": [425, 465]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Nevada",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [315, 358],
              "vertical_y_vertices": [291, 301]
            }
          },
          "county": {
            "extracted_string_or_numeric_value": "Clark",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [315, 380],
              "vertical_y_vertices": [322, 332]
            }
          },
          "commission_number": {
            "extracted_string_or_numeric_value": "19-2267-1",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [625, 695],
              "vertical_y_vertices": [456, 464]
            }
          },
          "commission_expiry_date": {
            "extracted_string_or_numeric_value": "May 29, 2027",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [625, 705],
              "vertical_y_vertices": [466, 474]
            }
          },
          "notarization_method": {
            "extracted_string_or_numeric_value": "Notarized remotely using audio-video communication technology via Proof.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [315, 743],
              "vertical_y_vertices": [497, 507]
            }
          }
        }
      },
      "health_care_poa": {
        "principal": {
          "name": {
            "extracted_string_or_numeric_value": "Judith A. Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [188, 333],
              "vertical_y_vertices": [121, 133]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, MI 49665",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [435, 796],
              "vertical_y_vertices": [121, 133]
            }
          }
        },
        "agent": {
          "name": {
            "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [188, 348],
              "vertical_y_vertices": [137, 149]
            }
          },
          "address": {
            "extracted_string_or_numeric_value": "3291 18 Mile Road, Marion, MI 49665",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [457, 818],
              "vertical_y_vertices": [137, 149]
            }
          }
        },
        "successor_agent": {
          "name": {
            "extracted_string_or_numeric_value": "JoAnn S. Weston",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [520, 661],
              "vertical_y_vertices": [737, 749]
            }
          },
          "relationship": {
            "extracted_string_or_numeric_value": "my sister",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [443, 511],
              "vertical_y_vertices": [737, 749]
            }
          }
        },
        "execution_date": {
          "extracted_string_or_numeric_value": "12th day of June, 2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [259, 438],
            "vertical_y_vertices": [561, 573]
          }
        },
        "principal_signature": {
          "extracted_string_or_numeric_value": "Judth A Grandy",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 350],
            "vertical_y_vertices": [605, 640]
          }
        },
        "acknowledgement": {
          "title": {
            "extracted_string_or_numeric_value": "Certificate of Acknowledgement",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [338, 616],
              "vertical_y_vertices": [121, 131]
            }
          },
          "document_date": {
            "extracted_string_or_numeric_value": "06/12/2024",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [325, 403],
              "vertical_y_vertices": [152, 162]
            }
          },
          "page_count": {
            "extracted_string_or_numeric_value": 4,
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [499, 508],
              "vertical_y_vertices": [183, 193]
            }
          },
          "acknowledged_by": {
            "extracted_string_or_numeric_value": "Judth A Grandy",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [510, 620],
              "vertical_y_vertices": [397, 407]
            }
          },
          "acknowledgement_date": {
            "extracted_string_or_numeric_value": "06/12/2024",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [415, 494],
              "vertical_y_vertices": [397, 407]
            }
          },
          "notary": {
            "name": {
              "extracted_string_or_numeric_value": "Darlene Morris",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [693, 767],
                "vertical_y_vertices": [425, 433]
              }
            },
            "signature": {
              "extracted_string_or_numeric_value": "Dark Mones",
              "optical_extraction_confidence_score": 0.93,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [397, 550],
                "vertical_y_vertices": [440, 478]
              }
            },
            "state": {
              "extracted_string_or_numeric_value": "Nevada",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [397, 440],
                "vertical_y_vertices": [305, 315]
              }
            },
            "county": {
              "extracted_string_or_numeric_value": "Clark",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [397, 462],
                "vertical_y_vertices": [336, 346]
              }
            },
            "commission_number": {
              "extracted_string_or_numeric_value": "19-2267-1",
              "optical_extraction_confidence_score": 0.98,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [693, 763],
                "vertical_y_vertices": [456, 464]
              }
            },
            "commission_expiry_date": {
              "extracted_string_or_numeric_value": "May 29, 2027",
              "optical_extraction_confidence_score": 0.99,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [693, 773],
                "vertical_y_vertices": [466, 474]
              }
            },
            "notarization_method": {
              "extracted_string_or_numeric_value": "Notarized remotely using audio-video communication technology via Proof.",
              "optical_extraction_confidence_score": 0.96,
              "physical_evidence_coordinates": {
                "horizontal_x_vertices": [397, 825],
                "vertical_y_vertices": [511, 521]
              }
            }
          }
        }
      },
      "agent_forms": {
        "acceptance_of_trust_signature": {
          "extracted_string_or_numeric_value": "Mark W. Sosa-Kibby",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [188, 330],
            "vertical_y_vertices": [787, 799]
          }
        },
        "acceptance_of_trust_poa_date": {
          "extracted_string_or_numeric_value": "June 12, 2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [640, 733],
            "vertical_y_vertices": [105, 117]
          }
        },
        "acknowledgement_form_signature": {
          "extracted_string_or_numeric_value": "Mark William Sosan Kibby",
          "optical_extraction_confidence_score": 0.92,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [220, 390],
            "vertical_y_vertices": [830, 850]
          }
        },
        "acknowledgement_form_signature_date": {
          "extracted_string_or_numeric_value": "June 23rd, 2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [430, 520],
            "vertical_y_vertices": [835, 845]
          }
        },
        "acknowledgement_form_notary_state": {
          "extracted_string_or_numeric_value": "Notary Public, State of Texas",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [330, 550],
            "vertical_y_vertices": [910, 920]
          }
        },
        "certification_of_validity_signature": {
          "extracted_string_or_numeric_value": "Mark William SooarKibby",
          "optical_extraction_confidence_score": 0.91,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [200, 480],
            "vertical_y_vertices": [420, 440]
          }
        },
        "certification_of_validity_signature_date": {
          "extracted_string_or_numeric_value": "June 23rd, 2024",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [650, 750],
            "vertical_y_vertices": [425, 435]
          }
        },
        "certification_of_validity_certifier_phone": {
          "extracted_string_or_numeric_value": "+1-773-251-0539",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [370, 500],
            "vertical_y_vertices": [530, 540]
          }
        },
        "certification_of_validity_notary": {
          "name": {
            "extracted_string_or_numeric_value": "Rosa Marie Weido",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [320, 410],
              "vertical_y_vertices": [720, 730]
            }
          },
          "signature": {
            "extracted_string_or_numeric_value": "Rosa Mauve Weido",
            "optical_extraction_confidence_score": 0.92,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [320, 450],
              "vertical_y_vertices": [630, 650]
            }
          },
          "state": {
            "extracted_string_or_numeric_value": "Texas",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [470, 510],
              "vertical_y_vertices": [690, 700]
            }
          },
          "county": {
            "extracted_string_or_numeric_value": "Brazoria",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [470, 530],
              "vertical_y_vertices": [710, 720]
            }
          },
          "commission_number": {
            "extracted_string_or_numeric_value": "13303094-0",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [320, 380],
              "vertical_y_vertices": [760, 770]
            }
          },
          "commission_expiry_date": {
            "extracted_string_or_numeric_value": "04/12/2025",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [650, 720],
              "vertical_y_vertices": [640, 650]
            }
          }
        }
      }
    }
  }
]
```