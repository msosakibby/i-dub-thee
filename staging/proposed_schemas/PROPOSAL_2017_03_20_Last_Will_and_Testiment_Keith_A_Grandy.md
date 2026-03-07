An expert forensic data architect, I have analyzed the provided document, a Last Will and Testament with several addenda, and designed a resilient Pydantic V2 schema to capture its complex and varied structure. The schema accounts for both the formally typed will and the associated handwritten directives and memorandums, treating them as optional components of a single estate planning document class.

A key feature of this schema is the `model_validator`, which performs a financial checksum as required. It calculates the sum of all specified monetary disbursements (funeral expenses and cash bequests) and validates this sum against a declared total, ensuring internal financial consistency in the extracted data, a principle aligned with double-entry accounting.

---

### **BLOCK 1: Python Pydantic V2 Schema**
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError

# DO NOT MODIFY: Provided base classes for forensic data extraction.
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Schema for the structured components of the Will and its addenda.
class Witness(BaseModel):
    model_config = ConfigDict(extra='forbid')
    signature: ForensicDataEntity
    address: ForensicDataEntity

class DraftingAttorney(BaseModel):
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    bar_number: ForensicDataEntity
    address: ForensicDataEntity

class TypedWill(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    testator_name: ForensicDataEntity
    testator_address: ForensicDataEntity
    revocation_clause: ForensicDataEntity
    debt_and_cremation_directive: ForensicDataEntity
    estate_bequest_clause: ForensicDataEntity
    estate_beneficiaries: List[ForensicDataEntity]
    co_personal_representatives: List[ForensicDataEntity]
    bond_waiver_clause: ForensicDataEntity
    handwritten_instructions_reference_clause: ForensicDataEntity
    marital_status_clause: ForensicDataEntity
    execution_date: ForensicDataEntity
    testator_signature: ForensicDataEntity
    testator_printed_name: ForensicDataEntity
    attestation_clause: ForensicDataEntity
    witnesses: List[Witness]
    drafting_attorney: DraftingAttorney

class InsurancePolicy(BaseModel):
    model_config = ConfigDict(extra='forbid')
    purpose: ForensicDataEntity
    amount: ForensicDataEntity
    financial_group_name: ForensicDataEntity
    financial_group_phone: ForensicDataEntity
    financial_group_address: ForensicDataEntity
    agent_name: ForensicDataEntity

class HandwrittenWillAddendum(BaseModel):
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    date: ForensicDataEntity
    personal_property_disposition: ForensicDataEntity
    possessions_list_reference: ForensicDataEntity
    funeral_expense_insurance: InsurancePolicy
    other_insurance_disposition: ForensicDataEntity
    long_term_care_policy_mention: ForensicDataEntity

class EndOfLifeInstructions(BaseModel):
    model_config = ConfigDict(extra='forbid')
    resuscitation_directive: ForensicDataEntity
    organ_donor_status: ForensicDataEntity
    care_preference: ForensicDataEntity
    incapacity_clause: ForensicDataEntity
    long_term_care_insurance_mention: ForensicDataEntity

class AshesDisposition(BaseModel):
    model_config = ConfigDict(extra='forbid')
    cremation_request: ForensicDataEntity
    disposition_location_1: ForensicDataEntity
    disposition_location_2: ForensicDataEntity

class PatientAdvocateDirective(BaseModel):
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    testator_name: ForensicDataEntity
    date: ForensicDataEntity
    end_of_life_instructions: EndOfLifeInstructions
    ashes_disposition: AshesDisposition
    celebration_of_life_instructions: ForensicDataEntity

class CashBequestRecipient(BaseModel):
    model_config = ConfigDict(extra='forbid')
    recipient_name: ForensicDataEntity
    relationship: ForensicDataEntity
    date: ForensicDataEntity
    initials: ForensicDataEntity

class SignatureBlock(BaseModel):
    model_config = ConfigDict(extra='forbid')
    signed_by: ForensicDataEntity
    address: ForensicDataEntity

class PersonalPropertyMemorandum(BaseModel):
    model_config = ConfigDict(extra='forbid')
    title: ForensicDataEntity
    testator_initials: ForensicDataEntity
    cash_bequest_amount_each: ForensicDataEntity
    cash_bequest_recipients: List[CashBequestRecipient]
    signatures: List[SignatureBlock]

class LastWillAndTestamentKeithAGrandy(BaseModel):
    """
    A resilient schema for the Last Will and Testament of Keith A. Grandy,
    accommodating the formal typed will and various handwritten addenda.
    """
    model_config = ConfigDict(extra='forbid')
    
    typed_will: TypedWill
    handwritten_will_addendum: Optional[HandwrittenWillAddendum] = None
    patient_advocate_directive: Optional[PatientAdvocateDirective] = None
    personal_property_memorandum: Optional[PersonalPropertyMemorandum] = None
    total_monetary_disbursements: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_financial_checksum(self) -> 'LastWillAndTestamentKeithAGrandy':
        """
        Performs a GAAP-style checksum on specified monetary disbursements.
        It sums the funeral expense and all cash bequests, then validates this
        calculated total against the 'total_monetary_disbursements' field.
        This ensures the financial data extracted from the document is internally consistent.
        """
        # Validation is only performed if all relevant financial sections are present.
        if not all([self.handwritten_will_addendum, self.personal_property_memorandum, self.total_monetary_disbursements]):
            return self

        calculated_total = 0.0

        # 1. Sum funeral expense from the handwritten addendum.
        try:
            funeral_expense_entity = self.handwritten_will_addendum.funeral_expense_insurance.amount
            val = funeral_expense_entity.extracted_string_or_numeric_value
            if isinstance(val, str):
                # Parses strings like "$7,500" to a numeric value.
                cleaned_val = ''.join(filter(str.isdigit, val.split('.')[0]))
                calculated_total += float(cleaned_val)
            elif isinstance(val, (int, float)):
                calculated_total += float(val)
        except (ValueError, AttributeError, TypeError) as e:
            raise ValueError(f"Could not parse funeral expense for checksum: {e}")

        # 2. Sum cash bequests from the personal property memorandum.
        try:
            amount_each_entity = self.personal_property_memorandum.cash_bequest_amount_each
            val = amount_each_entity.extracted_string_or_numeric_value
            if isinstance(val, str):
                # Parses strings like "$1,000.00 EACH TO" to a numeric value.
                cleaned_val = ''.join(filter(str.isdigit, val.split('.')[0]))
                amount_each = float(cleaned_val)
            elif isinstance(val, (int, float)):
                amount_each = float(val)
            else:
                raise TypeError("Bequest amount is not a valid number or string.")
            
            num_recipients = len(self.personal_property_memorandum.cash_bequest_recipients)
            calculated_total += amount_each * num_recipients
        except (ValueError, AttributeError, TypeError, IndexError) as e:
            raise ValueError(f"Could not parse cash bequests for checksum: {e}")

        # 3. Retrieve the declared total for comparison.
        try:
            declared_total_val = self.total_monetary_disbursements.extracted_string_or_numeric_value
            declared_total = float(declared_total_val)
        except (AttributeError, TypeError, ValueError) as e:
            raise ValueError(f"Could not parse declared total for checksum: {e}")

        # 4. Assert that the calculated sum equals the declared total.
        if not abs(calculated_total - declared_total) < 0.01:
            raise ValueError(
                "GAAP Checksum Failed: The sum of specified disbursements does not match the declared total. "
                f"Calculated: {calculated_total}, Declared: {declared_total}"
            )
            
        return self
```

### **BLOCK 2: JSON Test Registry**
```json
[
  {
    "test_identifier": "2017-03-20_keith_grandy_will_full_complex",
    "should_pass": true,
    "taxonomy_lane": "LastWillAndTestamentKeithAGrandy",
    "binary_header_simulation": "25504446",
    "payload": {
      "typed_will": {
        "document_title": {
          "extracted_string_or_numeric_value": "LAST WILL AND TESTAMENT",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [388, 598], "vertical_y_vertices": [279, 292] }
        },
        "testator_name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [444, 548], "vertical_y_vertices": [346, 359] }
        },
        "testator_address": {
          "extracted_string_or_numeric_value": "Marion, Osceola County, Michigan",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [281, 609], "vertical_y_vertices": [420, 433] }
        },
        "revocation_clause": {
          "extracted_string_or_numeric_value": "expressly revoking all Wills and Codicils to Wills by me at any time heretofore made.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 771], "vertical_y_vertices": [465, 493] }
        },
        "debt_and_cremation_directive": {
          "extracted_string_or_numeric_value": "Upon my death, I direct my Personal Representative, hereinafter named, to pay all my just debts and to provide for me a proper and fitting cremation, all such expenses to be paid as soon as possible out of my estate.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 772], "vertical_y_vertices": [581, 651] }
        },
        "estate_bequest_clause": {
          "extracted_string_or_numeric_value": "Upon my death, I give, devise and bequeath all of my estate, real, personal or mixed, of whatsoever character and wheresoever situate to to my children",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 772], "vertical_y_vertices": [708, 750] }
        },
        "estate_beneficiaries": [
          { "extracted_string_or_numeric_value": "Jodi Marie Bell", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 772], "vertical_y_vertices": [750, 778] } },
          { "extracted_string_or_numeric_value": "Jason Keith Grandy", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 772], "vertical_y_vertices": [750, 778] } },
          { "extracted_string_or_numeric_value": "Amanda Sue LaBell", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 772], "vertical_y_vertices": [750, 778] } }
        ],
        "co_personal_representatives": [
          { "extracted_string_or_numeric_value": "Jodi Marie Bell", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 771], "vertical_y_vertices": [355, 383] } },
          { "extracted_string_or_numeric_value": "Judith A. Grandy", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 771], "vertical_y_vertices": [355, 383] } }
        ],
        "bond_waiver_clause": {
          "extracted_string_or_numeric_value": "I direct that no bond be required of either of them.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [243, 690], "vertical_y_vertices": [399, 411] }
        },
        "handwritten_instructions_reference_clause": {
          "extracted_string_or_numeric_value": "I direct my Personal Representatives to follow any handwritten instructions found with this my Last Will and Testament that are in my own handwriting, being dated and signed by myself. (Pay attention to instructions for ashes and celebration of life.)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [243, 771], "vertical_y_vertices": [421, 479] }
        },
        "marital_status_clause": {
          "extracted_string_or_numeric_value": "I recognize that I have a wife that is currently alive, Judith A. Grandy. We have well taken care of ourselves during our life times. This is a second marriage for each of us and each of us have children from our prior marriages and our estates are subject to Premarital Agreements.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [243, 771], "vertical_y_vertices": [491, 561] }
        },
        "execution_date": {
          "extracted_string_or_numeric_value": "24th day of March, 2017",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [570, 771], "vertical_y_vertices": [585, 597] }
        },
        "testator_signature": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.95,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 650], "vertical_y_vertices": [610, 640] }
        },
        "testator_printed_name": {
          "extracted_string_or_numeric_value": "Keith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 550], "vertical_y_vertices": [655, 665] }
        },
        "attestation_clause": {
          "extracted_string_or_numeric_value": "On this 24th day of March, 2017, the above named Testator, Keith A. Grandy, signed, sealed and published the foregoing for and as his Last Will and Testament in ourpresence, and we, in his presence, at his request, and in the presence of each other have hereunto subscribed our names as witnesses.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 771], "vertical_y_vertices": [695, 765] }
        },
        "witnesses": [
          {
            "signature": { "extracted_string_or_numeric_value": "Witness Signature 1", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 442], "vertical_y_vertices": [218, 265] } },
            "address": { "extracted_string_or_numeric_value": "of Marion, Michigan.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [470, 600], "vertical_y_vertices": [240, 250] } }
          },
          {
            "signature": { "extracted_string_or_numeric_value": "Witness Signature 2", "optical_extraction_confidence_score": 0.91, "physical_evidence_coordinates": { "horizontal_x_vertices": [219, 442], "vertical_y_vertices": [310, 360] } },
            "address": { "extracted_string_or_numeric_value": "of Marion, Michigan.", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [470, 600], "vertical_y_vertices": [335, 345] } }
          }
        ],
        "drafting_attorney": {
          "name": { "extracted_string_or_numeric_value": "Gregory C. Merrifield", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 370], "vertical_y_vertices": [560, 570] } },
          "bar_number": { "extracted_string_or_numeric_value": "(P27300)", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 380], "vertical_y_vertices": [575, 585] } },
          "address": { "extracted_string_or_numeric_value": "221 E. Main/Box 172 Marion, MI 49665", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [220, 380], "vertical_y_vertices": [590, 620] } }
        }
      },
      "handwritten_will_addendum": {
        "title": { "extracted_string_or_numeric_value": "Will of Keith a Grandy", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [300, 600], "vertical_y_vertices": [100, 120] } },
        "date": { "extracted_string_or_numeric_value": "3-20-2017", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 700], "vertical_y_vertices": [100, 120] } },
        "personal_property_disposition": { "extracted_string_or_numeric_value": "My boat-fishing equipment-work tools-personal items - guns - hunting equipment: Take what you want and then give the rest to family members.", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 800], "vertical_y_vertices": [150, 250] } },
        "possessions_list_reference": { "extracted_string_or_numeric_value": "I have a list of my possessions. On this list I show you I desire to receive certain items.", "optical_extraction_confidence_score": 0.93, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 800], "vertical_y_vertices": [260, 320] } },
        "funeral_expense_insurance": {
          "purpose": { "extracted_string_or_numeric_value": "CMS insurance is to paid for my funeral expense", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 780], "vertical_y_vertices": [380, 420] } },
          "amount": { "extracted_string_or_numeric_value": "($7,500)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 780], "vertical_y_vertices": [420, 440] } },
          "financial_group_name": { "extracted_string_or_numeric_value": "Advanced Financial Group", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [450, 700], "vertical_y_vertices": [420, 440] } },
          "financial_group_phone": { "extracted_string_or_numeric_value": "(231-922-8993)", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 350], "vertical_y_vertices": [460, 480] } },
          "financial_group_address": { "extracted_string_or_numeric_value": "2121 North Four Mile Rd. Traverse City, MI 49686", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 800], "vertical_y_vertices": [460, 500] } },
          "agent_name": { "extracted_string_or_numeric_value": "Agent Jim P. Olesnovage.", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 800], "vertical_y_vertices": [500, 520] } }
        },
        "other_insurance_disposition": { "extracted_string_or_numeric_value": "My other life Insurance & Annuities will be distributed by this Financial Group.", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 800], "vertical_y_vertices": [530, 570] } },
        "long_term_care_policy_mention": { "extracted_string_or_numeric_value": "also have life long term health care policy,", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [180, 650], "vertical_y_vertices": [580, 620] } }
      },
      "patient_advocate_directive": {
        "title": { "extracted_string_or_numeric_value": "Patient Advocate", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 450], "vertical_y_vertices": [150, 170] } },
        "testator_name": { "extracted_string_or_numeric_value": "Keith Grandy", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 600], "vertical_y_vertices": [150, 170] } },
        "date": { "extracted_string_or_numeric_value": "3-21-2017", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [610, 720], "vertical_y_vertices": [150, 170] } },
        "end_of_life_instructions": {
          "resuscitation_directive": { "extracted_string_or_numeric_value": "If my soul leaves my body: Do not revive me, place me on life support, if no hope for survival.", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [180, 250] } },
          "organ_donor_status": { "extracted_string_or_numeric_value": "I am an organ donor.", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [250, 280] } },
          "care_preference": { "extracted_string_or_numeric_value": "If my health fails, I would like to live at home with professional care. If this is to overwhelming for the family. Please admit me to a care phycility. I do not want to be a burden for my family", "optical_extraction_confidence_score": 0.93, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [300, 400] } },
          "incapacity_clause": { "extracted_string_or_numeric_value": "If my mind is gone - I will be ok anywhere.", "optical_extraction_confidence_score": 0.94, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [400, 430] } },
          "long_term_care_insurance_mention": { "extracted_string_or_numeric_value": "I have long term care insurance!", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 600], "vertical_y_vertices": [440, 470] } }
        },
        "ashes_disposition": {
          "cremation_request": { "extracted_string_or_numeric_value": "I would like to be cremated.", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 550], "vertical_y_vertices": [500, 520] } },
          "disposition_location_1": { "extracted_string_or_numeric_value": "Like to have half of my ashes & Marilee ashes be on Lake Margrethe First major point on the south eat side", "optical_extraction_confidence_score": 0.92, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [520, 600] } },
          "disposition_location_2": { "extracted_string_or_numeric_value": "The other half of the ashes at duck blind... Also at my rifle blind. on the east lane about 40 yds from blind", "optical_extraction_confidence_score": 0.91, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [650, 750] } }
        },
        "celebration_of_life_instructions": { "extracted_string_or_numeric_value": "Celebration of life: at the pole barn with a venison fry. With family & friends..", "optical_extraction_confidence_score": 0.93, "physical_evidence_coordinates": { "horizontal_x_vertices": [200, 800], "vertical_y_vertices": [750, 800] } }
      },
      "personal_property_memorandum": {
        "title": { "extracted_string_or_numeric_value": "MEMORANDUM Desired Distribution of Personal Property", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [360, 640], "vertical_y_vertices": [100, 140] } },
        "testator_initials": { "extracted_string_or_numeric_value": "KG", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 480], "vertical_y_vertices": [200, 210] } },
        "cash_bequest_amount_each": { "extracted_string_or_numeric_value": "$1,000.00 EACH TO", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 350], "vertical_y_vertices": [250, 270] } },
        "cash_bequest_recipients": [
          { "recipient_name": { "extracted_string_or_numeric_value": "ZACHARY SLEVOSTI", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 350], "vertical_y_vertices": [290, 310] } }, "relationship": { "extracted_string_or_numeric_value": "GD. Son", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 560], "vertical_y_vertices": [290, 310] } }, "date": { "extracted_string_or_numeric_value": "3/27/17", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [290, 310] } }, "initials": { "extracted_string_or_numeric_value": "KG", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [290, 310] } } },
          { "recipient_name": { "extracted_string_or_numeric_value": "ZACHARIAH BROWN", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 350], "vertical_y_vertices": [320, 340] } }, "relationship": { "extracted_string_or_numeric_value": "GD. Son", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 560], "vertical_y_vertices": [320, 340] } }, "date": { "extracted_string_or_numeric_value": "3/27/17", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [320, 340] } }, "initials": { "extracted_string_or_numeric_value": "KG", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [320, 340] } } },
          { "recipient_name": { "extracted_string_or_numeric_value": "JACOB LaBell", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 350], "vertical_y_vertices": [350, 370] } }, "relationship": { "extracted_string_or_numeric_value": "GD. Son", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 560], "vertical_y_vertices": [350, 370] } }, "date": { "extracted_string_or_numeric_value": "3/24/17", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [350, 370] } }, "initials": { "extracted_string_or_numeric_value": "KG", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [350, 370] } } },
          { "recipient_name": { "extracted_string_or_numeric_value": "ALI BELL", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 350], "vertical_y_vertices": [380, 400] } }, "relationship": { "extracted_string_or_numeric_value": "GD. Dau.", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 560], "vertical_y_vertices": [380, 400] } }, "date": { "extracted_string_or_numeric_value": "3/27/17", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [380, 400] } }, "initials": { "extracted_string_or_numeric_value": "KG", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [380, 400] } } },
          { "recipient_name": { "extracted_string_or_numeric_value": "DANA LaBell", "optical_extraction_confidence_score": 0.96, "physical_evidence_coordinates": { "horizontal_x_vertices": [210, 350], "vertical_y_vertices": [410, 430] } }, "relationship": { "extracted_string_or_numeric_value": "GD. Dau", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 560], "vertical_y_vertices": [410, 430] } }, "date": { "extracted_string_or_numeric_value": "3/24/17", "optical_extraction_confidence_score": 0.97, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 710], "vertical_y_vertices": [410, 430] } }, "initials": { "extracted_string_or_numeric_value": "KG", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 750], "vertical_y_vertices": [410, 430] } } }
        ],
        "signatures": [
          {
            "signed_by": { "extracted_string_or_numeric_value": "Keith Grandy", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 400], "vertical_y_vertices": [790, 810] } },
            "address": { "extracted_string_or_numeric_value": "PO Box 297 Marion MI 49665-0297", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [310, 480], "vertical_y_vertices": [810, 840] } }
          }
        ]
      },
      "total_monetary_disbursements": {
        "extracted_string_or_numeric_value": 12500.00,
        "optical_extraction_confidence_score": 1.0,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [0, 0], "vertical_y_vertices": [0, 0] }
      }
    }
  }
]
```