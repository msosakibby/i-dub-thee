An expert forensic data architect, I have analyzed the provided 2023 Form 1099-R documents. The forms, while sharing a standard IRS layout, exhibit variations in which fields are populated, necessitating a schema with numerous optional fields. The Midland National Life form is the most complete variant, including federal and state withholding, while the Lincoln National Life form utilizes checkboxes like "Taxable amount not determined" and has many empty monetary fields.

The resulting Pydantic V2 schema, `Form1099R_V1`, is designed for maximum resilience by accommodating all observed variations. It includes a GAAP-compliant mathematical validator to ensure the integrity of key financial figures, specifically verifying that the gross distribution equals the sum of its taxable and non-taxable components, and that state-level distributions align with the gross amount.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator
import math

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the spatial coordinates of an extracted entity on a physical document."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for an extracted data point, including its value, confidence, and location."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float, int, bool]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Form1099R_V1(BaseModel):
    """
    A resilient Pydantic V2 schema for Form 1099-R, accommodating structural
    variations observed across different payers for the 2023 tax year.
    """
    model_config = ConfigDict(extra='forbid')

    # Payer Information
    payer_name: ForensicDataEntity
    payer_address: ForensicDataEntity
    payer_tin: ForensicDataEntity
    payer_phone: Optional[ForensicDataEntity] = None

    # Recipient Information
    recipient_name: ForensicDataEntity
    recipient_address: ForensicDataEntity
    recipient_tin: ForensicDataEntity
    recipient_id: Optional[ForensicDataEntity] = None

    # Document Metadata
    form_year: ForensicDataEntity
    account_number: Optional[ForensicDataEntity] = None
    corrected: Optional[ForensicDataEntity] = None

    # Boxed Financial Data
    gross_distribution: ForensicDataEntity
    taxable_amount: ForensicDataEntity
    taxable_amount_not_determined: Optional[ForensicDataEntity] = None
    total_distribution_checkbox: Optional[ForensicDataEntity] = None
    capital_gain: Optional[ForensicDataEntity] = None
    federal_income_tax_withheld: Optional[ForensicDataEntity] = None
    employee_contributions: Optional[ForensicDataEntity] = None
    net_unrealized_appreciation: Optional[ForensicDataEntity] = None
    distribution_codes: ForensicDataEntity
    is_ira_sep_simple: Optional[ForensicDataEntity] = None
    other_amount: Optional[ForensicDataEntity] = None
    percentage_of_total_distribution: Optional[ForensicDataEntity] = None
    total_employee_contributions: Optional[ForensicDataEntity] = None
    amount_allocable_to_irr: Optional[ForensicDataEntity] = None
    first_year_of_designated_roth_contrib: Optional[ForensicDataEntity] = None
    fatca_filing_requirement: Optional[ForensicDataEntity] = None
    date_of_payment: Optional[ForensicDataEntity] = None

    # State and Local Tax Information
    state_tax_withheld: Optional[ForensicDataEntity] = None
    state_payer_state_no: ForensicDataEntity
    state_distribution: ForensicDataEntity
    local_tax_withheld: Optional[ForensicDataEntity] = None
    name_of_locality: Optional[ForensicDataEntity] = None
    local_distribution: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'Form1099R_V1':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        - Verifies Gross Distribution = Taxable Amount + Non-Taxable (Employee) Contributions.
        - Verifies Taxable Amount >= Capital Gain (as Capital Gain is a component of Taxable Amount).
        - Verifies State Distribution matches Gross Distribution.
        """
        def get_val(field: Optional[ForensicDataEntity]) -> float:
            if field is None or not isinstance(field.extracted_string_or_numeric_value, (int, float)):
                return 0.0
            return float(field.extracted_string_or_numeric_value)

        gross_dist = get_val(self.gross_distribution)
        taxable_amt = get_val(self.taxable_amount)
        employee_contrib = get_val(self.employee_contributions)
        capital_gain = get_val(self.capital_gain)
        state_dist = get_val(self.state_distribution)

        # Check 1: Gross Distribution = Taxable Amount + Non-Taxable Contributions
        if not math.isclose(gross_dist, taxable_amt + employee_contrib, rel_tol=1e-5):
            raise ValueError(
                f"Checksum failed: Gross Distribution ({gross_dist}) != "
                f"Taxable Amount ({taxable_amt}) + Employee Contributions ({employee_contrib})"
            )

        # Check 2: Taxable Amount must be >= Capital Gain
        if taxable_amt < capital_gain:
            raise ValueError(
                f"Checksum failed: Taxable Amount ({taxable_amt}) < Capital Gain ({capital_gain})"
            )

        # Check 3: State Distribution should generally equal Gross Distribution
        if not math.isclose(state_dist, gross_dist, rel_tol=1e-5):
            raise ValueError(
                f"Checksum failed: State Distribution ({state_dist}) != Gross Distribution ({gross_dist})"
            )

        return self
```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "1099R_midland_national_full_data_variant",
    "should_pass": true,
    "taxonomy_lane": "Form1099R_V1",
    "binary_header_simulation": "25504446",
    "payload": {
      "payer_name": {
        "extracted_string_or_numeric_value": "MIDLAND NATIONAL LIFE INSURANCE COMPANY",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 425], "vertical_y_vertices": [59, 70] }
      },
      "payer_address": {
        "extracted_string_or_numeric_value": "ONE SAMMONS PLAZA SIOUX FALLS, SD 57193",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 230], "vertical_y_vertices": [80, 102] }
      },
      "payer_phone": {
        "extracted_string_or_numeric_value": "6053732300",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 135], "vertical_y_vertices": [113, 123] }
      },
      "payer_tin": {
        "extracted_string_or_numeric_value": "46-0164570",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 135], "vertical_y_vertices": [148, 158] }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "GRANDY JUDITH A",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 215], "vertical_y_vertices": [215, 225] }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "3291 18 MILE RD MARION, MI 49665",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 230], "vertical_y_vertices": [226, 248] }
      },
      "recipient_tin": {
        "extracted_string_or_numeric_value": "***-**-1882",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [315, 390], "vertical_y_vertices": [148, 158] }
      },
      "recipient_id": null,
      "form_year": {
        "extracted_string_or_numeric_value": 2023,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 700], "vertical_y_vertices": [70, 95] }
      },
      "account_number": {
        "extracted_string_or_numeric_value": "7400005300",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 150], "vertical_y_vertices": [300, 310] }
      },
      "corrected": null,
      "gross_distribution": {
        "extracted_string_or_numeric_value": 30250.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [50, 75] }
      },
      "taxable_amount": {
        "extracted_string_or_numeric_value": 30250.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [85, 110] }
      },
      "taxable_amount_not_determined": null,
      "total_distribution_checkbox": null,
      "capital_gain": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [135, 155] }
      },
      "federal_income_tax_withheld": {
        "extracted_string_or_numeric_value": 4083.75,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 710], "vertical_y_vertices": [135, 155] }
      },
      "employee_contributions": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [175, 215] }
      },
      "net_unrealized_appreciation": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 710], "vertical_y_vertices": [175, 215] }
      },
      "distribution_codes": {
        "extracted_string_or_numeric_value": "7D",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [225, 250] }
      },
      "is_ira_sep_simple": {
        "extracted_string_or_numeric_value": true,
        "optical_extraction_confidence_score": 0.95,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [225, 250] }
      },
      "other_amount": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 710], "vertical_y_vertices": [225, 250] }
      },
      "percentage_of_total_distribution": {
        "extracted_string_or_numeric_value": 0.0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 520], "vertical_y_vertices": [260, 285] }
      },
      "total_employee_contributions": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 710], "vertical_y_vertices": [260, 285] }
      },
      "amount_allocable_to_irr": {
        "extracted_string_or_numeric_value": 0.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [59, 170], "vertical_y_vertices": [260, 285] }
      },
      "first_year_of_designated_roth_contrib": null,
      "fatca_filing_requirement": null,
      "date_of_payment": null,
      "state_tax_withheld": {
        "extracted_string_or_numeric_value": 1285.63,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [295, 315] }
      },
      "state_payer_state_no": {
        "extracted_string_or_numeric_value": "MI/46-0164570",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 710], "vertical_y_vertices": [295, 315] }
      },
      "state_distribution": {
        "extracted_string_or_numeric_value": 30250.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": { "horizontal_x_vertices": [720, 840], "vertical_y_vertices": [295, 315] }
      },
      "local_tax_withheld": null,
      "name_of_locality": null,
      "local_distribution": null
    }
  }
]
```