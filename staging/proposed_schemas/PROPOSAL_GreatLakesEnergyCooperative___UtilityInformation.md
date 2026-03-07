An expert forensic data architect, I have analyzed the provided document from Great Lakes Energy Cooperative. This document is a general information and remittance form, not a transactional bill. My Pydantic V2 schema is designed to robustly capture the static informational content, contact directory, and the structure of the user-fillable form sections.

The schema uses nested models to mirror the document's logical layout, such as separate classes for addresses, the call center directory, and form sections. All data points are wrapped in the mandated `ForensicDataEntity` class. Fields corresponding to blank form areas are typed as `Optional` to reflect their potential absence. The required GAAP checksum validator is included, with a note clarifying that no financial calculations are applicable to this document type.

The accompanying JSON test case represents a complete and complex parse of the provided document, populating all available fields and lists to ensure the schema's integrity and coverage.

**BLOCK 1 (Python Pydantic V2):**
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator

# Base classes mandated by the directive
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Nested models for structured data within the document
class Address(BaseModel):
    model_config = ConfigDict(extra='forbid')
    addressee: Optional[ForensicDataEntity] = None
    street_address: Optional[ForensicDataEntity] = None
    po_box: Optional[ForensicDataEntity] = None
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: ForensicDataEntity

class OutageInfo(BaseModel):
    model_config = ConfigDict(extra='forbid')
    phone_number: ForensicDataEntity
    availability: ForensicDataEntity

class DirectoryEntry(BaseModel):
    model_config = ConfigDict(extra='forbid')
    service_name: ForensicDataEntity
    extension: ForensicDataEntity

class LocalNumber(BaseModel):
    model_config = ConfigDict(extra='forbid')
    phone_number: ForensicDataEntity
    location: ForensicDataEntity

class CallCenterDirectory(BaseModel):
    model_config = ConfigDict(extra='forbid')
    availability: ForensicDataEntity
    toll_free_number: ForensicDataEntity
    directory_entries: List[DirectoryEntry]
    local_numbers: List[LocalNumber]
    website: ForensicDataEntity

class AddressChangeForm(BaseModel):
    model_config = ConfigDict(extra='forbid')
    is_permanent_change: Optional[ForensicDataEntity] = None
    is_temporary_change: Optional[ForensicDataEntity] = None
    temporary_from_date: Optional[ForensicDataEntity] = None
    temporary_to_date: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    city: Optional[ForensicDataEntity] = None
    state: Optional[ForensicDataEntity] = None
    zip_code: Optional[ForensicDataEntity] = None
    email_address: Optional[ForensicDataEntity] = None
    phone: Optional[ForensicDataEntity] = None

class PaymentOptions(BaseModel):
    model_config = ConfigDict(extra='forbid')
    automated_checking_account_selected: Optional[ForensicDataEntity] = None
    support_gle_people_fund_selected: Optional[ForensicDataEntity] = None

# Top-level schema for the 'GreatLakesEnergyCooperative - UtilityInformation' document class
class GreatLakesEnergyCooperativeUtilityInformation(BaseModel):
    model_config = ConfigDict(extra='forbid')

    send_payments_to: Address
    send_correspondence_to: Address
    report_power_outage: OutageInfo
    call_center_directory: CallCenterDirectory
    billing_information_text: ForensicDataEntity
    disconnect_notice_information_text: ForensicDataEntity
    shutoff_nonpayment_notice: ForensicDataEntity
    address_change_form: AddressChangeForm
    payment_options: PaymentOptions
    signature: Optional[ForensicDataEntity] = None
    date_signed: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatLakesEnergyCooperativeUtilityInformation':
        """
        Performs double-entry GAAP mathematical checksums.
        This document is a general information sheet and does not contain financial figures
        like line items, totals, or payments. Therefore, no checksums can be performed.
        The validator is included to conform to the required output structure.
        """
        # No financial data to validate on this document type.
        return self
```

**BLOCK 2 (JSON Test Registry):**
```json
[
  {
    "test_identifier": "great_lakes_energy_info_sheet_full_parse",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyCooperativeUtilityInformation",
    "binary_header_simulation": "25504446",
    "payload": {
      "send_payments_to": {
        "addressee": { "extracted_string_or_numeric_value": "Bill Payment Center", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [183, 352, 352, 183], "vertical_y_vertices": [59, 59, 72, 72] } },
        "street_address": { "extracted_string_or_numeric_value": "2183 N. WATER RD.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [183, 352, 352, 183], "vertical_y_vertices": [73, 73, 86, 86] } },
        "city": { "extracted_string_or_numeric_value": "Hart", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [183, 220, 220, 183], "vertical_y_vertices": [87, 87, 100, 100] } },
        "state": { "extracted_string_or_numeric_value": "MI", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [225, 245, 245, 225], "vertical_y_vertices": [87, 87, 100, 100] } },
        "zip_code": { "extracted_string_or_numeric_value": "49420-9007", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 352, 352, 250], "vertical_y_vertices": [87, 87, 100, 100] } }
      },
      "send_correspondence_to": {
        "addressee": { "extracted_string_or_numeric_value": "Great Lakes Energy Cooperative Customer Support Center", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 570, 570, 380], "vertical_y_vertices": [45, 45, 72, 72] } },
        "po_box": { "extracted_string_or_numeric_value": "P.O. Box 70", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 570, 570, 380], "vertical_y_vertices": [73, 73, 86, 86] } },
        "city": { "extracted_string_or_numeric_value": "Boyne City", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 460, 460, 380], "vertical_y_vertices": [87, 87, 100, 100] } },
        "state": { "extracted_string_or_numeric_value": "MI", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [465, 485, 485, 465], "vertical_y_vertices": [87, 87, 100, 100] } },
        "zip_code": { "extracted_string_or_numeric_value": "49712-0070", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 570, 570, 490], "vertical_y_vertices": [87, 87, 100, 100] } }
      },
      "report_power_outage": {
        "phone_number": { "extracted_string_or_numeric_value": "1-800-678-0411", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 780, 780, 650], "vertical_y_vertices": [59, 59, 72, 72] } },
        "availability": { "extracted_string_or_numeric_value": "(24 hours a day)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 780, 780, 650], "vertical_y_vertices": [73, 73, 86, 86] } }
      },
      "call_center_directory": {
        "availability": { "extracted_string_or_numeric_value": "Available Monday - Friday, 8:00 a.m. to 5:00 p.m., (except holidays)", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 550, 550, 150], "vertical_y_vertices": [150, 150, 165, 165] } },
        "toll_free_number": { "extracted_string_or_numeric_value": "1-888-485-2537 (All Areas)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 800, 800, 600], "vertical_y_vertices": [135, 135, 150, 150] } },
        "website": { "extracted_string_or_numeric_value": "www.gtlakes.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 800, 800, 700], "vertical_y_vertices": [270, 270, 285, 285] } },
        "local_numbers": [
          { "phone_number": { "extracted_string_or_numeric_value": "582-6521", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [180, 180, 195, 195] } }, "location": { "extracted_string_or_numeric_value": "(Boyne)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 810, 810, 765], "vertical_y_vertices": [180, 180, 195, 195] } } },
          { "phone_number": { "extracted_string_or_numeric_value": "652-1651", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700, 760, 760, 700], "vertical_y_vertices": [196, 196, 211, 211] } }, "location": { "extracted_string_or_numeric_value": "(Newaygo)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [765, 820, 820, 765], "vertical_y_vertices": [196, 196, 211, 211] } } }
        ],
        "directory_entries": [
          { "service_name": { "extracted_string_or_numeric_value": "Electric billing questions", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300, 300, 150], "vertical_y_vertices": [180, 180, 190, 190] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 360, 360, 330], "vertical_y_vertices": [180, 180, 190, 190] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Moving? Start or stop service", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300, 300, 150], "vertical_y_vertices": [195, 195, 205, 205] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 360, 360, 330], "vertical_y_vertices": [195, 195, 205, 205] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Credit Card Payments", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300, 300, 150], "vertical_y_vertices": [210, 210, 220, 220] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 360, 360, 330], "vertical_y_vertices": [210, 210, 220, 220] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Payment Arrangements", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300, 300, 150], "vertical_y_vertices": [225, 225, 235, 235] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 360, 360, 330], "vertical_y_vertices": [225, 225, 235, 235] } } },
          { "service_name": { "extracted_string_or_numeric_value": "File a complaint", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300, 300, 150], "vertical_y_vertices": [240, 240, 250, 250] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 360, 360, 330], "vertical_y_vertices": [240, 240, 250, 250] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Disconnect Notice arrangements", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 300, 300, 150], "vertical_y_vertices": [255, 255, 265, 265] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [330, 360, 360, 330], "vertical_y_vertices": [255, 255, 265, 265] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Automated Bill Payment Plan Enrollment", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 600, 600, 380], "vertical_y_vertices": [180, 180, 190, 190] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 660, 660, 630], "vertical_y_vertices": [180, 180, 190, 190] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Controlled heating or water heating questions", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 600, 600, 380], "vertical_y_vertices": [195, 195, 205, 205] } }, "extension": { "extracted_string_or_numeric_value": "8957", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 660, 660, 630], "vertical_y_vertices": [195, 195, 205, 205] } } },
          { "service_name": { "extracted_string_or_numeric_value": "Surge Protection program enrollment or questions", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 600, 600, 380], "vertical_y_vertices": [210, 210, 220, 220] } }, "extension": { "extracted_string_or_numeric_value": "8957", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 660, 660, 630], "vertical_y_vertices": [210, 210, 220, 220] } } },
          { "service_name": { "extracted_string_or_numeric_value": "New Construction .. varies by location ...", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [380, 600, 600, 380], "vertical_y_vertices": [225, 225, 235, 235] } }, "extension": { "extracted_string_or_numeric_value": "0", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 660, 660, 630], "vertical_y_vertices": [225, 225, 235, 235] } } }
        ]
      },
      "billing_information_text": { "extracted_string_or_numeric_value": "The rate schedules, the explanation of rate schedules, and the explanation of how to verify the accuracy of the bill will be provided upon request. Make any inquiry or complaint about the bill before the due date. The PCSR (Power Supply Cost Recovery) is the adjustment in the rate that is approved by the Michigan Public Service Commission to recognize the variations in the cost of purchased power and fuel for electric generation. Any cooperative member may receive a copy of the cooperative by-laws, rates, rules and regulations upon request. Visit www.gtlakes.com for more information. Great Lakes Energy Cooperative is regulated by the Michigan Public Service Commission, Lansing, Michigan.", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [140, 480, 480, 140], "vertical_y_vertices": [350, 350, 600, 600] } },
      "disconnect_notice_information_text": { "extracted_string_or_numeric_value": "As a customer you have the following rights: To enter into a settlement agreement with Great Lakes Energy if the claim is for an amount that is not in dispute and you are presently unable to pay in full. To file a complaint disputing the claim of Great Lakes Energy before the date of the proposed date of the shutoff of service. To request a hearing before a utility hearing officer if the complaint cannot be otherwise resolved, providing that you pay that portion of the bill not in dispute within 10 days of the date you request a hearing. To represent yourself or be represented by counsel or other person of your choice in the complaint process. Service will not be shutoff pending the resolution of a complaint filed with Great Lakes Energy in accordance with the rules of the Michigan Public Service Commission. To have the shutoff of service postponed if a medical emergency exists at your residence and you can provide a physician's certificate or notice from a public health or social services official identifying the medical emergency and the period of time during which shutoff will aggravate the emergency. If you believe you may be eligible for emergency economic assistance, contact a social service office immediately. Contact Great Lakes Energy for information about the winter protection plan if the date on or after which shut-off of service may occur is between Nov. 1 and March 31. A site visit may not be required in order to disconnect an account, Please contact Great Lakes Energy at Ext. 8924, if you are unable to pay your bill.", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 840, 840, 490], "vertical_y_vertices": [350, 350, 650, 650] } },
      "shutoff_nonpayment_notice": { "extracted_string_or_numeric_value": "If your service is shutoff for non-payment, a reconnect charge and a deposit will be required to restore service.", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [490, 840, 840, 490], "vertical_y_vertices": [655, 655, 685, 685] } },
      "address_change_form": {
        "is_permanent_change": null,
        "is_temporary_change": null,
        "temporary_from_date": null,
        "temporary_to_date": null,
        "address": null,
        "city": null,
        "state": null,
        "zip_code": null,
        "email_address": null,
        "phone": null
      },
      "payment_options": {
        "automated_checking_account_selected": null,
        "support_gle_people_fund_selected": null
      },
      "signature": null,
      "date_signed": null
    }
  }
]
```