An expert forensic data architect, operating under a Zero-Trust mandate, I have analyzed the provided document 'GreatLakesEnergyCooperative - InformationSheet'. My findings indicate a single, consistent layout across the provided evidence. To ensure maximum resilience against future structural drift, I have designed a Pydantic V2 schema that models distinct informational sections as nested objects and utilizes `Optional` typing for fields that could vary or be absent in other versions, such as form inputs or specific address components.

The schema includes a placeholder for a GAAP-compliant mathematical validator as mandated. However, as this document class is purely informational and lacks financial transaction data (e.g., subtotals, taxes, totals), no actual checksums can be performed.

The accompanying JSON test case represents the most complex variant available—the single provided document—and includes a complete data payload extracted from it, demonstrating the schema's capability to capture all present information.

### BLOCK 1 (Python Pydantic V2):
```python
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Optional

class SpatialCoordinatesPolygon(BaseModel):
    """Defines a polygon for the physical location of extracted data."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for any extracted data point, containing its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Address(BaseModel):
    """Models a physical or mailing address."""
    model_config = ConfigDict(extra='forbid')
    recipient: ForensicDataEntity
    street_address: Optional[ForensicDataEntity] = None
    po_box: Optional[ForensicDataEntity] = None
    city: ForensicDataEntity
    state: ForensicDataEntity
    zip_code: ForensicDataEntity

class OutageReporting(BaseModel):
    """Models contact information for power outage reporting."""
    model_config = ConfigDict(extra='forbid')
    phone_number: ForensicDataEntity
    availability: ForensicDataEntity

class CallCenterExtension(BaseModel):
    """Models a single service and its corresponding phone extension."""
    model_config = ConfigDict(extra='forbid')
    service_description: ForensicDataEntity
    extension: ForensicDataEntity

class LocalPhoneNumber(BaseModel):
    """Models a local phone number for a specific geographic area."""
    model_config = ConfigDict(extra='forbid')
    location: ForensicDataEntity
    phone_number: ForensicDataEntity

class CallCenterDirectory(BaseModel):
    """Models the entire call center contact information section."""
    model_config = ConfigDict(extra='forbid')
    availability: ForensicDataEntity
    toll_free_number: ForensicDataEntity
    extensions: List[CallCenterExtension]
    local_numbers: List[LocalPhoneNumber]
    website: ForensicDataEntity

class MailingAddressPhoneChange(BaseModel):
    """Models the form for customers to update their contact information."""
    model_config = ConfigDict(extra='forbid')
    is_permanent: Optional[ForensicDataEntity] = None
    is_temporary: Optional[ForensicDataEntity] = None
    temporary_from_date: Optional[ForensicDataEntity] = None
    temporary_to_date: Optional[ForensicDataEntity] = None
    address: Optional[ForensicDataEntity] = None
    city: Optional[ForensicDataEntity] = None
    state: Optional[ForensicDataEntity] = None
    zip_code: Optional[ForensicDataEntity] = None
    phone: Optional[ForensicDataEntity] = None
    email_address: Optional[ForensicDataEntity] = None
    instructions: ForensicDataEntity

class PaymentOptions(BaseModel):
    """Models the text associated with various payment and enrollment options."""
    model_config = ConfigDict(extra='forbid')
    automated_checking_plan_text: ForensicDataEntity
    pay_by_check_credit_card_enroll_text: ForensicDataEntity
    gle_people_fund_text: ForensicDataEntity

class GreatLakesEnergyCooperativeInformationSheet(BaseModel):
    """
    The root schema for the Great Lakes Energy Cooperative information sheet.
    This document provides contact details, billing policies, and customer action forms.
    """
    model_config = ConfigDict(extra='forbid')

    send_payments_to: Address
    send_correspondence_to: Address
    report_power_outage: OutageReporting
    call_center_directory: CallCenterDirectory
    billing_information_points: List[ForensicDataEntity]
    regulatory_statement: ForensicDataEntity
    disconnect_notice_rights: List[ForensicDataEntity]
    shutoff_reconnect_notice: ForensicDataEntity
    mailing_address_phone_change: MailingAddressPhoneChange
    payment_options: PaymentOptions
    signature_required_label: Optional[ForensicDataEntity] = None
    date_required_label: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'GreatLakesEnergyCooperativeInformationSheet':
        """
        Performs double-entry GAAP-style mathematical checksums.
        This document is an informational sheet and does not contain financial figures
        (e.g., subtotals, taxes, totals) that can be cross-validated.
        Therefore, this validator serves as a structural placeholder and performs no actions.
        """
        # No financial calculations to validate on this document type.
        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "great-lakes-energy-info-sheet-blank-form",
    "should_pass": true,
    "taxonomy_lane": "GreatLakesEnergyCooperativeInformationSheet",
    "binary_header_simulation": "25504446",
    "payload": {
      "send_payments_to": {
        "recipient": {
          "extracted_string_or_numeric_value": "Bill Payment Center",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 319], "vertical_y_vertices": [62, 75] }
        },
        "street_address": {
          "extracted_string_or_numeric_value": "2183 N. WATER RD.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 319], "vertical_y_vertices": [78, 90] }
        },
        "city": {
          "extracted_string_or_numeric_value": "Hart",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [189, 220], "vertical_y_vertices": [94, 106] }
        },
        "state": {
          "extracted_string_or_numeric_value": "MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [225, 243], "vertical_y_vertices": [94, 106] }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "49420-9007",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [248, 319], "vertical_y_vertices": [94, 106] }
        }
      },
      "send_correspondence_to": {
        "recipient": {
          "extracted_string_or_numeric_value": "Great Lakes Energy Cooperative Customer Support Center",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [391, 578], "vertical_y_vertices": [62, 87] }
        },
        "po_box": {
          "extracted_string_or_numeric_value": "P.O. Box 70",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [440, 529], "vertical_y_vertices": [90, 102] }
        },
        "city": {
          "extracted_string_or_numeric_value": "Boyne City",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [391, 465], "vertical_y_vertices": [105, 117] }
        },
        "state": {
          "extracted_string_or_numeric_value": "MI",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [470, 488], "vertical_y_vertices": [105, 117] }
        },
        "zip_code": {
          "extracted_string_or_numeric_value": "49712-0070",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [493, 570], "vertical_y_vertices": [105, 117] }
        }
      },
      "report_power_outage": {
        "phone_number": {
          "extracted_string_or_numeric_value": "1-800-678-0411",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 780], "vertical_y_vertices": [62, 75] }
        },
        "availability": {
          "extracted_string_or_numeric_value": "(24 hours a day)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [675, 775], "vertical_y_vertices": [78, 90] }
        }
      },
      "call_center_directory": {
        "availability": {
          "extracted_string_or_numeric_value": "Available Monday - Friday, 8:00 a.m. to 5:00 p.m., (except holidays)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 544], "vertical_y_vertices": [161, 173] }
        },
        "toll_free_number": {
          "extracted_string_or_numeric_value": "1-888-485-2537 (All Areas)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [586, 841], "vertical_y_vertices": [144, 158] }
        },
        "extensions": [
          { "service_description": { "extracted_string_or_numeric_value": "Electric billing questions", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 290], "vertical_y_vertices": [184, 195] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [324, 352], "vertical_y_vertices": [184, 195] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Moving? Start or stop service", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 308], "vertical_y_vertices": [200, 211] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [324, 352], "vertical_y_vertices": [200, 211] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Credit Card Payments", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 265], "vertical_y_vertices": [216, 227] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [324, 352], "vertical_y_vertices": [216, 227] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Payment Arrangements", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 270], "vertical_y_vertices": [232, 243] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [324, 352], "vertical_y_vertices": [232, 243] } } },
          { "service_description": { "extracted_string_or_numeric_value": "File a complaint", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 238], "vertical_y_vertices": [248, 259] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [324, 352], "vertical_y_vertices": [248, 259] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Disconnect Notice arrangements", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 315], "vertical_y_vertices": [264, 275] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [324, 352], "vertical_y_vertices": [264, 275] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Automated Bill Payment Plan Enrollment", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [377, 600], "vertical_y_vertices": [184, 195] } }, "extension": { "extracted_string_or_numeric_value": "8924", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [652, 680], "vertical_y_vertices": [184, 195] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Controlled heating or water heating questions", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [377, 630], "vertical_y_vertices": [200, 211] } }, "extension": { "extracted_string_or_numeric_value": "8957", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [652, 680], "vertical_y_vertices": [200, 211] } } },
          { "service_description": { "extracted_string_or_numeric_value": "Surge Protection program enrollment or questions", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [377, 645], "vertical_y_vertices": [216, 227] } }, "extension": { "extracted_string_or_numeric_value": "8957", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [652, 680], "vertical_y_vertices": [216, 227] } } },
          { "service_description": { "extracted_string_or_numeric_value": "New Construction ... varies by location ...", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [377, 610], "vertical_y_vertices": [232, 243] } }, "extension": { "extracted_string_or_numeric_value": "0", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [652, 660], "vertical_y_vertices": [232, 243] } } }
        ],
        "local_numbers": [
          { "location": { "extracted_string_or_numeric_value": "(Boyne)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 795], "vertical_y_vertices": [184, 195] } }, "phone_number": { "extracted_string_or_numeric_value": "582-6521", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [695, 745], "vertical_y_vertices": [184, 195] } } },
          { "location": { "extracted_string_or_numeric_value": "(Newaygo)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [750, 810], "vertical_y_vertices": [200, 211] } }, "phone_number": { "extracted_string_or_numeric_value": "652-1651", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [695, 745], "vertical_y_vertices": [200, 211] } } }
        ],
        "website": {
          "extracted_string_or_numeric_value": "www.gtlakes.com",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [695, 795], "vertical_y_vertices": [248, 259] }
        }
      },
      "billing_information_points": [
        { "extracted_string_or_numeric_value": "The rate schedules, the explanation of rate schedules, and the explanation of how to verify the accuracy of the bill will be provided upon request.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 485], "vertical_y_vertices": [350, 390] } },
        { "extracted_string_or_numeric_value": "Make any inquiry or complaint about the bill before the due date.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 485], "vertical_y_vertices": [395, 420] } },
        { "extracted_string_or_numeric_value": "The PCSR (Power Supply Cost Recovery) is the adjustment in the rate that is approved by the Michigan Public Service Commission to recognize the variations in the cost of purchased power and fuel for electric generation.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 485], "vertical_y_vertices": [425, 495] } },
        { "extracted_string_or_numeric_value": "Any cooperative member may receive a copy of the cooperative by-laws, rates, rules and regulations upon request.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 485], "vertical_y_vertices": [500, 540] } },
        { "extracted_string_or_numeric_value": "Visit www.gtlakes.com for more information.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 485], "vertical_y_vertices": [545, 555] } }
      ],
      "regulatory_statement": {
        "extracted_string_or_numeric_value": "Great Lakes Energy Cooperative is regulated by the Michigan Public Service Commission, Lansing, Michigan.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [145, 490], "vertical_y_vertices": [600, 640] }
      },
      "disconnect_notice_rights": [
        { "extracted_string_or_numeric_value": "To enter into a settlement agreement with Great Lakes Energy if the claim is for an amount that is not in dispute and you are presently unable to pay in full.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [365, 400] } },
        { "extracted_string_or_numeric_value": "To file a complaint disputing the claim of Great Lakes Energy before the date of the proposed date of the shutoff of service.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [405, 435] } },
        { "extracted_string_or_numeric_value": "To request a hearing before a utility hearing officer if the complaint cannot be otherwise resolved, providing that you pay that portion of the bill not in dispute within 10 days of the date you request a hearing. To represent yourself or be represented by counsel or other person of your choice in the complaint process. Service will not be shutoff pending the resolution of a complaint filed with Great Lakes Energy in accordance with the rules of the Michigan Public Service Commission.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [440, 530] } },
        { "extracted_string_or_numeric_value": "To have the shutoff of service postponed if a medical emergency exists at your residence and you can provide a physician's certificate or notice from a public health or social services official identifying the medical emergency and the period of time during which shutoff will aggravate the emergency.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [535, 590] } },
        { "extracted_string_or_numeric_value": "If you believe you may be eligible for emergency economic assistance, contact a social service office immediately.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [595, 620] } },
        { "extracted_string_or_numeric_value": "Contact Great Lakes Energy for information about the winter protection plan if the date on or after which shut-off of service may occur is between Nov. 1 and March 31.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [625, 660] } },
        { "extracted_string_or_numeric_value": "A site visit may not be required in order to disconnect an account, Please contact Great Lakes Energy at Ext. 8924, if you are unable to pay your bill.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 850], "vertical_y_vertices": [665, 695] } }
      ],
      "shutoff_reconnect_notice": {
        "extracted_string_or_numeric_value": "If your service is shutoff for non-payment, a reconnect charge and a deposit will be required to restore service.",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [495, 855], "vertical_y_vertices": [705, 735] }
      },
      "mailing_address_phone_change": {
        "is_permanent": null,
        "is_temporary": null,
        "temporary_from_date": null,
        "temporary_to_date": null,
        "address": null,
        "city": null,
        "state": null,
        "zip_code": null,
        "phone": null,
        "email_address": null,
        "instructions": {
          "extracted_string_or_numeric_value": "*Please call toll free or send separate correspondence to the Boyne City address above to report name changes, discontinue service, provide new party information, to inquire about your account, send comments, etc. Thank You.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [800, 830] }
        }
      },
      "payment_options": {
        "automated_checking_plan_text": {
          "extracted_string_or_numeric_value": "Automated Checking Account payment plan- Use the check enclosed to obtain my bank account numbers. I understand that I may discontinue the automated payment plan by contacting Great Lakes Energy.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [840, 870] }
        },
        "pay_by_check_credit_card_enroll_text": {
          "extracted_string_or_numeric_value": "To pay by Check, Credit Card or enroll in our Automatic Bill Payment Plan visit www.gtlakes.com or contact our Customer Call Center at 1-888-485-2537 x8924. (When paying your bill by check, you authorize us to either use the information from your check to make a one-time electronic funds transfer from your account or to process the payment as a check transaction. When we use information from your check to make an electronic funds transfer, funds may be withdrawn from your account as soon as the same day we receive your payment and you will not receive your check back from the bank.)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [875, 940] }
        },
        "gle_people_fund_text": {
          "extracted_string_or_numeric_value": "Yes, I support the GLE People Fund. I authorize GLE to permanently Round Up my bills to the next highest dollar amount.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [150, 850], "vertical_y_vertices": [945, 970] }
        }
      },
      "signature_required_label": {
        "extracted_string_or_numeric_value": "Signature (Required)",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 350], "vertical_y_vertices": [975, 985] }
      },
      "date_required_label": {
        "extracted_string_or_numeric_value": "Date (Required)",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 680], "vertical_y_vertices": [975, 985] }
      }
    }
  }
]
```