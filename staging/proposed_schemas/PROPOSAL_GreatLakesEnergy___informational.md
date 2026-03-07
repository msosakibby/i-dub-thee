An expert forensic data architect, I have meticulously analyzed the provided document, a 'GreatLakesEnergy - informational' page. My analysis reveals a structured layout containing contact information, service hours, phone directories, and regulatory notices. Based on this, I have designed a resilient Pydantic V2 schema that logically groups this information into nested models for clarity and robustness. The schema accounts for variations in contact details, such as the presence or absence of phone extensions, and captures all textual information blocks.

The corresponding JSON test case represents the single provided document, populating every field defined in the schema. As this document contains no financial figures, the mandatory GAAP checksum validator is included but performs no calculations, adhering to the directive.

***

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box coordinates for an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data entity, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Address(BaseModel):
    """A structured model for physical mailing addresses."""
    model_config = ConfigDict(extra='forbid')
    recipient: ForensicDataEntity
    department: ForensicDataEntity
    po_box_or_street_address: ForensicDataEntity
    city_state_zip: ForensicDataEntity

class PhoneNumber(BaseModel):
    """A structured model for a phone number, with an optional extension."""
    model_config = ConfigDict(extra='forbid')
    number: ForensicDataEntity
    extension: Optional[ForensicDataEntity] = None

class PhoneMenu(BaseModel):
    """A structured model for the detailed phone service menu."""
    model_config = ConfigDict(extra='forbid')
    electric_billing_questions_ext: ForensicDataEntity
    propane_billing_questions_ext: ForensicDataEntity
    automatic_bill_payment_enrollment_ext: ForensicDataEntity
    credit_card_payments_ext: ForensicDataEntity
    disconnect_notice_arrangements_ext: ForensicDataEntity
    last_payment_information_ext: ForensicDataEntity
    moving_service_arrangements_ext: ForensicDataEntity
    controlled_heating_surge_protection_ext: ForensicDataEntity
    report_meter_reading_automated_ext: ForensicDataEntity
    report_meter_reading_rep_ext: ForensicDataEntity
    propane_heating_cooling_service_ext: ForensicDataEntity
    long_distance_phone_service_number: ForensicDataEntity

class GreatLakesEnergyInformational(BaseModel):
    """
    Schema for the informational back page of a Great Lakes Energy utility bill.
    """
    model_config = ConfigDict(extra='forbid')

    payment_address: Address
    correspondence_address: Address
    
    power_outage_contact: PhoneNumber
    after_hours_emergency_contact: PhoneNumber
    
    customer_service_hours: ForensicDataEntity
    
    toll_free_number: ForensicDataEntity
    boyne_city_local_number: ForensicDataEntity
    newaygo_area_local_number: ForensicDataEntity
    
    phone_menu: PhoneMenu
    
    website_url: ForensicDataEntity
    
    coop_by_laws_info: ForensicDataEntity
    disconnect_notice_info: ForensicDataEntity
    availability_charge_info: ForensicDataEntity
    pscr_adjustment_info: ForensicDataEntity
    regulatory_body_info: ForensicDataEntity
    inquiry_registration_info: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatLakesEnergyInformational':
        """
        Performs double-entry GAAP mathematical checksums.
        This document class does not contain financial figures, so no checks are performed.
        """
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "informational_page_full_detail",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyInformational",
    "binary_header_simulation": "25504446",
    "payload": {
      "payment_address": {
        "recipient": {
          "extracted_string_or_numeric_value": "Great Lakes Energy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [277.0, 425.0, 425.0, 277.0],
            "vertical_y_vertices": [69.0, 69.0, 82.0, 82.0]
          }
        },
        "department": {
          "extracted_string_or_numeric_value": "Bill Payment Center",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [277.0, 425.0, 425.0, 277.0],
            "vertical_y_vertices": [86.0, 86.0, 99.0, 99.0]
          }
        },
        "po_box_or_street_address": {
          "extracted_string_or_numeric_value": "PO Box 248",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [300.0, 399.0, 399.0, 300.0],
            "vertical_y_vertices": [103.0, 103.0, 116.0, 116.0]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "Scottville, MI 49454-0248",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [251.0, 454.0, 454.0, 251.0],
            "vertical_y_vertices": [120.0, 120.0, 133.0, 133.0]
          }
        }
      },
      "correspondence_address": {
        "recipient": {
          "extracted_string_or_numeric_value": "Great Lakes Energy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550.0, 725.0, 725.0, 550.0],
            "vertical_y_vertices": [69.0, 69.0, 82.0, 82.0]
          }
        },
        "department": {
          "extracted_string_or_numeric_value": "Customer Support Center",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [532.0, 743.0, 743.0, 532.0],
            "vertical_y_vertices": [86.0, 86.0, 99.0, 99.0]
          }
        },
        "po_box_or_street_address": {
          "extracted_string_or_numeric_value": "1323 Boyne Avenue",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [550.0, 725.0, 725.0, 550.0],
            "vertical_y_vertices": [103.0, 103.0, 116.0, 116.0]
          }
        },
        "city_state_zip": {
          "extracted_string_or_numeric_value": "Boyne City, MI 49712-0070",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [531.0, 744.0, 744.0, 531.0],
            "vertical_y_vertices": [120.0, 120.0, 133.0, 133.0]
          }
        }
      },
      "power_outage_contact": {
        "number": {
          "extracted_string_or_numeric_value": "1-800-678-0411",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [638.0, 820.0, 820.0, 638.0],
            "vertical_y_vertices": [180.0, 180.0, 192.0, 192.0]
          }
        },
        "extension": null
      },
      "after_hours_emergency_contact": {
        "number": {
          "extracted_string_or_numeric_value": "1-888-485-2537",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [638.0, 758.0, 758.0, 638.0],
            "vertical_y_vertices": [198.0, 198.0, 210.0, 210.0]
          }
        },
        "extension": {
          "extracted_string_or_numeric_value": "1478",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [768.0, 820.0, 820.0, 768.0],
            "vertical_y_vertices": [198.0, 198.0, 210.0, 210.0]
          }
        }
      },
      "customer_service_hours": {
        "extracted_string_or_numeric_value": "7:00 a.m. to 5:00 p.m. Monday through Friday, except holidays.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [118.0, 877.0, 877.0, 118.0],
          "vertical_y_vertices": [230.0, 230.0, 245.0, 245.0]
        }
      },
      "toll_free_number": {
        "extracted_string_or_numeric_value": "1-888-485-2537",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608.0, 738.0, 738.0, 608.0],
          "vertical_y_vertices": [270.0, 270.0, 282.0, 282.0]
        }
      },
      "boyne_city_local_number": {
        "extracted_string_or_numeric_value": "582-6521",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608.0, 669.0, 669.0, 608.0],
          "vertical_y_vertices": [288.0, 288.0, 300.0, 300.0]
        }
      },
      "newaygo_area_local_number": {
        "extracted_string_or_numeric_value": "652-1651",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [608.0, 669.0, 669.0, 608.0],
          "vertical_y_vertices": [306.0, 306.0, 318.0, 318.0]
        }
      },
      "phone_menu": {
        "electric_billing_questions_ext": {
          "extracted_string_or_numeric_value": "8924",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [429.0, 478.0, 478.0, 429.0],
            "vertical_y_vertices": [348.0, 348.0, 360.0, 360.0]
          }
        },
        "propane_billing_questions_ext": {
          "extracted_string_or_numeric_value": "8930",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [429.0, 478.0, 478.0, 429.0],
            "vertical_y_vertices": [364.0, 364.0, 376.0, 376.0]
          }
        },
        "automatic_bill_payment_enrollment_ext": {
          "extracted_string_or_numeric_value": "8924",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [429.0, 478.0, 478.0, 429.0],
            "vertical_y_vertices": [380.0, 380.0, 392.0, 392.0]
          }
        },
        "credit_card_payments_ext": {
          "extracted_string_or_numeric_value": "8924",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [429.0, 478.0, 478.0, 429.0],
            "vertical_y_vertices": [396.0, 396.0, 408.0, 408.0]
          }
        },
        "disconnect_notice_arrangements_ext": {
          "extracted_string_or_numeric_value": "8924",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [429.0, 478.0, 478.0, 429.0],
            "vertical_y_vertices": [412.0, 412.0, 424.0, 424.0]
          }
        },
        "last_payment_information_ext": {
          "extracted_string_or_numeric_value": "1765",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [429.0, 478.0, 478.0, 429.0],
            "vertical_y_vertices": [428.0, 428.0, 440.0, 440.0]
          }
        },
        "moving_service_arrangements_ext": {
          "extracted_string_or_numeric_value": "8924",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [902.0, 951.0, 951.0, 902.0],
            "vertical_y_vertices": [348.0, 348.0, 360.0, 360.0]
          }
        },
        "controlled_heating_surge_protection_ext": {
          "extracted_string_or_numeric_value": "8957",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [902.0, 951.0, 951.0, 902.0],
            "vertical_y_vertices": [364.0, 364.0, 376.0, 376.0]
          }
        },
        "report_meter_reading_automated_ext": {
          "extracted_string_or_numeric_value": "1764",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [902.0, 951.0, 951.0, 902.0],
            "vertical_y_vertices": [380.0, 380.0, 392.0, 392.0]
          }
        },
        "report_meter_reading_rep_ext": {
          "extracted_string_or_numeric_value": "8924",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [902.0, 951.0, 951.0, 902.0],
            "vertical_y_vertices": [396.0, 396.0, 408.0, 408.0]
          }
        },
        "propane_heating_cooling_service_ext": {
          "extracted_string_or_numeric_value": "8930",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [902.0, 951.0, 951.0, 902.0],
            "vertical_y_vertices": [412.0, 412.0, 424.0, 424.0]
          }
        },
        "long_distance_phone_service_number": {
          "extracted_string_or_numeric_value": "(877) 981-3000",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [877.0, 960.0, 960.0, 877.0],
            "vertical_y_vertices": [428.0, 428.0, 440.0, 440.0]
          }
        }
      },
      "website_url": {
        "extracted_string_or_numeric_value": "www.gtlakes.com",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [149.0, 300.0, 300.0, 149.0],
          "vertical_y_vertices": [455.0, 455.0, 470.0, 470.0]
        }
      },
      "coop_by_laws_info": {
        "extracted_string_or_numeric_value": "Any Coop member can receive a copy of the coop by-laws upon request.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [225.0, 770.0, 770.0, 225.0],
          "vertical_y_vertices": [485.0, 485.0, 498.0, 498.0]
        }
      },
      "disconnect_notice_info": {
        "extracted_string_or_numeric_value": "If a \"DISCONNECT NOTICE FOR NON-PAYMENT\" message appears on the bottom of your bill for your electric account, please review the following information: You, the customer, have the right to: Enter into a settlement agreement with Great Lakes Energy if the claim is for monies not in dispute and the customer is presently unable to pay in full amount due Great Lakes Energy. File a complaint disputing the claim of the utility before the date of the proposed discontinuation of service. Request a hearing before a utility hearing officer if the complaint cannot be otherwise resolved, providing that you, the customer, pay to the utility that portion of the bill not in dispute within 3 days of the date that the hearing is requested. Represent yourself or to be represented by counsel or other person of your choice in the complaint process. Contact Great Lakes Energy for information about the Winter Protection Plan if the date on or after which shut-off of service may occur between Nov. 15 and March 31. Service will not be discontinued pending the resolution of a complaint filed with Great Lakes Energy in accordance with the Rules of the Michigan Public Service Commission. If you believe you may be eligible for emergency economic assistance, contact a social service office immediately. Discontinuance of service may be postponed if a medical emergency exists in your residence by producing a physician's statement. In accordance with the Rules of the Michigan Public Service Commission a collection fee, reconnect fee and a deposit may be required if you are disconnected for non-payment of a delinquent account.",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [35.0, 960.0, 960.0, 35.0],
          "vertical_y_vertices": [515.0, 515.0, 835.0, 835.0]
        }
      },
      "availability_charge_info": {
        "extracted_string_or_numeric_value": "The availability charge was designed to cover the fixed cost of providing individual service. It does not include any kilowatt hour (KwH) usage.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [48.0, 947.0, 947.0, 48.0],
          "vertical_y_vertices": [840.0, 840.0, 865.0, 865.0]
        }
      },
      "pscr_adjustment_info": {
        "extracted_string_or_numeric_value": "The Power Supply Cost Recovery (PSCR) adjustment is charged us by wholesale power suppliers. The formula for passing on higher or lower costs to retail customers has been approved by the Michigan Public Service Commission.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [48.0, 947.0, 947.0, 48.0],
          "vertical_y_vertices": [870.0, 870.0, 908.0, 908.0]
        }
      },
      "regulatory_body_info": {
        "extracted_string_or_numeric_value": "Great Lakes Energy is regulated by the Michigan Public Service Commission Lansing, Mich.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [190.0, 805.0, 805.0, 190.0],
          "vertical_y_vertices": [920.0, 920.0, 933.0, 933.0]
        }
      },
      "inquiry_registration_info": {
        "extracted_string_or_numeric_value": "Register any inquiry or complaint about your bill prior to the due date.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [258.0, 737.0, 737.0, 258.0],
          "vertical_y_vertices": [938.0, 938.0, 950.0, 950.0]
        }
      }
    }
  }
]
```