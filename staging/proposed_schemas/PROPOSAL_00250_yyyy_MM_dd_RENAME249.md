An expert forensic data architect, I have meticulously analyzed the provided document variants for class '00250 yyyy-MM-dd_RENAME249'. Adhering to a Zero-Trust protocol, I've designed a resilient Pydantic V2 schema to ensure data integrity and accommodate all structural variations. The schema includes a GAAP-compliant mathematical validator.

Below are the mandatory deliverables: the Pydantic V2 schema and a comprehensive JSON test case for the most complex document structure identified.

### BLOCK 1: Python Pydantic V2 Schema
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator, ValidationError
import math

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class TransactionItem(BaseModel):
    """Represents a single transaction line item."""
    model_config = ConfigDict(extra='forbid')
    transaction_date: ForensicDataEntity
    post_date: ForensicDataEntity
    reference_number: ForensicDataEntity
    description: ForensicDataEntity
    amount: ForensicDataEntity

class YearToDateSummary(BaseModel):
    """Represents the year-to-date summary table."""
    model_config = ConfigDict(extra='forbid')
    summary_year: ForensicDataEntity
    total_fees_charged_ytd: ForensicDataEntity
    total_interest_charged_ytd: ForensicDataEntity
    total_interest_paid_ytd: ForensicDataEntity

class Document00250YYYYMMDDRENAME249(BaseModel):
    """
    A resilient schema for extracting data from a financial transaction summary document.
    It captures purchase transactions, payments, and various fee/interest summaries.
    """
    model_config = ConfigDict(extra='forbid')

    meijer_transactions: List[TransactionItem]
    other_transactions: List[TransactionItem]
    total_fees_for_this_period: ForensicDataEntity
    interest_charge_on_purchases: ForensicDataEntity
    interest_charge_on_cash_advances: ForensicDataEntity
    total_interest_for_this_period: ForensicDataEntity
    year_to_date_summary: YearToDateSummary

    @model_validator(mode='after')
    def validate_gaap_checksums(self) -> 'Document00250YYYYMMDDRENAME249':
        """
        Performs double-entry GAAP mathematical checksums on financial fields.
        - Verifies that the total interest for the period equals the sum of its components.
        """
        try:
            purchases_interest = float(self.interest_charge_on_purchases.extracted_string_or_numeric_value)
            cash_advances_interest = float(self.interest_charge_on_cash_advances.extracted_string_or_numeric_value)
            total_interest = float(self.total_interest_for_this_period.extracted_string_or_numeric_value)
        except (ValueError, TypeError) as e:
            raise ValueError(f"Could not convert interest values to float for validation: {e}")

        calculated_total_interest = purchases_interest + cash_advances_interest

        if not math.isclose(calculated_total_interest, total_interest, rel_tol=1e-9, abs_tol=0.01):
            raise ValueError(
                f"Interest checksum failed: "
                f"Interest on Purchases ({purchases_interest}) + "
                f"Interest on Cash Advances ({cash_advances_interest}) = {calculated_total_interest}, "
                f"but Total Interest for Period is {total_interest}."
            )

        return self

```

### BLOCK 2: JSON Test Registry
```json
[
  {
    "test_identifier": "00250_2014-05-18_statement_full_detail",
    "should_pass": true,
    "taxonomy_lane": "Document00250YYYYMMDDRENAME249",
    "binary_header_simulation": "25504446",
    "payload": {
      "meijer_transactions": [
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [89.0, 89.0, 100.0, 100.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/20", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [89.0, 89.0, 100.0, 100.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G000XTMJG1", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [89.0, 89.0, 100.0, 100.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [89.0, 89.0, 120.0, 120.0] } },
          "amount": { "extracted_string_or_numeric_value": 66.74, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [89.0, 89.0, 100.0, 100.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [129.0, 129.0, 140.0, 140.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/22", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [129.0, 129.0, 140.0, 140.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G200XTMJG9", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [129.0, 129.0, 140.0, 140.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [129.0, 129.0, 160.0, 160.0] } },
          "amount": { "extracted_string_or_numeric_value": 31.21, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [129.0, 129.0, 140.0, 140.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [169.0, 169.0, 180.0, 180.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/25", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [169.0, 169.0, 180.0, 180.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G500XTMJG6", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [169.0, 169.0, 180.0, 180.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [169.0, 169.0, 200.0, 200.0] } },
          "amount": { "extracted_string_or_numeric_value": 72.46, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [169.0, 169.0, 180.0, 180.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [209.0, 209.0, 220.0, 220.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/28", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [209.0, 209.0, 220.0, 220.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G700XTMJG4", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [209.0, 209.0, 220.0, 220.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER ROCKFORD MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 598.0, 598.0, 435.0], "vertical_y_vertices": [209.0, 209.0, 240.0, 240.0] } },
          "amount": { "extracted_string_or_numeric_value": 44.16, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [209.0, 209.0, 220.0, 220.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [249.0, 249.0, 260.0, 260.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [249.0, 249.0, 260.0, 260.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G900XTMJG0", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [249.0, 249.0, 260.0, 260.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI Boat\nGAS STATION", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 670.0, 670.0, 435.0], "vertical_y_vertices": [249.0, 249.0, 280.0, 280.0] } },
          "amount": { "extracted_string_or_numeric_value": 36.22, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [249.0, 249.0, 260.0, 260.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [289.0, 289.0, 300.0, 300.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/30", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [289.0, 289.0, 300.0, 300.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G900XTMJGO", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [289.0, 289.0, 300.0, 300.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [289.0, 289.0, 320.0, 320.0] } },
          "amount": { "extracted_string_or_numeric_value": 56.52, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [289.0, 289.0, 300.0, 300.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "05/05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [329.0, 329.0, 340.0, 340.0] } },
          "post_date": { "extracted_string_or_numeric_value": "05/05", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [329.0, 329.0, 340.0, 340.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865GE00XTMJG5", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [329.0, 329.0, 340.0, 340.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [329.0, 329.0, 360.0, 360.0] } },
          "amount": { "extracted_string_or_numeric_value": 58.48, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [329.0, 329.0, 340.0, 340.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "05/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [369.0, 369.0, 380.0, 380.0] } },
          "post_date": { "extracted_string_or_numeric_value": "05/08", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [369.0, 369.0, 380.0, 380.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865GH00XTMJG2", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [369.0, 369.0, 380.0, 380.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER BENTON HARBOR MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 640.0, 640.0, 435.0], "vertical_y_vertices": [369.0, 369.0, 400.0, 400.0] } },
          "amount": { "extracted_string_or_numeric_value": 65.85, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [369.0, 369.0, 380.0, 380.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "05/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [409.0, 409.0, 420.0, 420.0] } },
          "post_date": { "extracted_string_or_numeric_value": "05/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [409.0, 409.0, 420.0, 420.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865GS00XTMJG1", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [409.0, 409.0, 420.0, 420.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nGAS STATION", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [409.0, 409.0, 440.0, 440.0] } },
          "amount": { "extracted_string_or_numeric_value": 63.21, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [409.0, 409.0, 420.0, 420.0] } }
        },
        {
          "transaction_date": { "extracted_string_or_numeric_value": "05/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [449.0, 449.0, 460.0, 460.0] } },
          "post_date": { "extracted_string_or_numeric_value": "05/16", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [449.0, 449.0, 460.0, 460.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865GS00XTMJG1", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [449.0, 449.0, 460.0, 460.0] } },
          "description": { "extracted_string_or_numeric_value": "MEIJER CADILLAC MI\nSUPERMARKET\nHARDWARE", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 588.0, 588.0, 435.0], "vertical_y_vertices": [449.0, 449.0, 495.0, 495.0] } },
          "amount": { "extracted_string_or_numeric_value": 34.22, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [915.0, 963.0, 963.0, 915.0], "vertical_y_vertices": [449.0, 449.0, 460.0, 460.0] } }
        }
      ],
      "other_transactions": [
        {
          "transaction_date": { "extracted_string_or_numeric_value": "04/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [107.0, 143.0, 143.0, 107.0], "vertical_y_vertices": [530.0, 530.0, 541.0, 541.0] } },
          "post_date": { "extracted_string_or_numeric_value": "04/27", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [170.0, 206.0, 206.0, 170.0], "vertical_y_vertices": [530.0, 530.0, 541.0, 541.0] } },
          "reference_number": { "extracted_string_or_numeric_value": "8514865G60187BPTP", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250.0, 405.0, 405.0, 250.0], "vertical_y_vertices": [530.0, 530.0, 541.0, 541.0] } },
          "description": { "extracted_string_or_numeric_value": "PAYMENT - THANK YOU", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [435.0, 600.0, 600.0, 435.0], "vertical_y_vertices": [530.0, 530.0, 541.0, 541.0] } },
          "amount": { "extracted_string_or_numeric_value": -332.14, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [900.0, 963.0, 963.0, 900.0], "vertical_y_vertices": [530.0, 530.0, 541.0, 541.0] } }
        }
      ],
      "total_fees_for_this_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [925.0, 963.0, 963.0, 925.0], "vertical_y_vertices": [580.0, 580.0, 591.0, 591.0] } },
      "interest_charge_on_purchases": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [925.0, 963.0, 963.0, 925.0], "vertical_y_vertices": [620.0, 620.0, 631.0, 631.0] } },
      "interest_charge_on_cash_advances": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [925.0, 963.0, 963.0, 925.0], "vertical_y_vertices": [640.0, 640.0, 651.0, 651.0] } },
      "total_interest_for_this_period": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [925.0, 963.0, 963.0, 925.0], "vertical_y_vertices": [660.0, 660.0, 671.0, 671.0] } },
      "year_to_date_summary": {
        "summary_year": { "extracted_string_or_numeric_value": "2014", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [291.0, 325.0, 325.0, 291.0], "vertical_y_vertices": [700.0, 700.0, 711.0, 711.0] } },
        "total_fees_charged_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0, 738.0, 738.0, 700.0], "vertical_y_vertices": [725.0, 725.0, 736.0, 736.0] } },
        "total_interest_charged_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0, 738.0, 738.0, 700.0], "vertical_y_vertices": [745.0, 745.0, 756.0, 756.0] } },
        "total_interest_paid_ytd": { "extracted_string_or_numeric_value": 0.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [700.0, 738.0, 738.0, 700.0], "vertical_y_vertices": [765.0, 765.0, 776.0, 776.0] } }
      }
    }
  }
]
```