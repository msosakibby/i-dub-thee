BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, model_validator
import decimal

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class SalesBreakdownItem(BaseModel):
    """Represents a single line item in a sales breakdown report."""
    model_config = ConfigDict(extra='forbid')
    department_name: ForensicDataEntity
    department_sales: ForensicDataEntity

class NoticeToSpartanNashRequestingIntentToRenewLease(BaseModel):
    """
    A schema to capture lease-related correspondence, including renewal notices
    and periodic gross sales reports with detailed breakdowns.
    """
    model_config = ConfigDict(extra='forbid')

    # Sender/Recipient Information (can be landlord or tenant)
    sender_name: Optional[ForensicDataEntity] = None
    sender_address: Optional[ForensicDataEntity] = None
    sender_contact_person: Optional[ForensicDataEntity] = None
    sender_contact_phone: Optional[ForensicDataEntity] = None
    
    recipient_name: Optional[ForensicDataEntity] = None
    recipient_address: Optional[ForensicDataEntity] = None
    recipient_attention_person: Optional[ForensicDataEntity] = None
    recipient_attention_title: Optional[ForensicDataEntity] = None

    # Document Metadata
    document_date: Optional[ForensicDataEntity] = None
    property_name: Optional[ForensicDataEntity] = None
    property_address: Optional[ForensicDataEntity] = None
    lease_date: Optional[ForensicDataEntity] = None

    # Lease Renewal Specific Fields
    lease_renewal_reminder_days: Optional[ForensicDataEntity] = None
    lease_renewal_exercise_deadline: Optional[ForensicDataEntity] = None
    lease_renewal_notice_period_days: Optional[ForensicDataEntity] = None

    # Gross Sales Report Specific Fields
    sales_period_start_date: Optional[ForensicDataEntity] = None
    sales_period_end_date: Optional[ForensicDataEntity] = None
    total_gross_sales: Optional[ForensicDataEntity] = None
    percentage_rent_breakpoint: Optional[ForensicDataEntity] = None
    percentage_rent_due_message: Optional[ForensicDataEntity] = None

    # Detailed Sales Breakdown
    sales_breakdown: Optional[List[SalesBreakdownItem]] = None
    sales_breakdown_total: Optional[ForensicDataEntity] = None

    @model_validator(mode='after')
    def perform_gaap_checksum(self) -> 'NoticeToSpartanNashRequestingIntentToRenewLease':
        """
        Performs a double-entry GAAP checksum if sales breakdown data is available.
        1. Verifies that the sum of individual department sales equals the breakdown total.
        2. Verifies that the breakdown total matches the total gross sales from the summary letter.
        """
        if self.sales_breakdown and self.total_gross_sales and self.sales_breakdown_total:
            
            # Use Decimal for financial precision
            ctx = decimal.Context(prec=10)
            calculated_sum = decimal.Decimal('0.00')
            
            for item in self.sales_breakdown:
                if isinstance(item.department_sales.extracted_string_or_numeric_value, (int, float, str)):
                    try:
                        calculated_sum += decimal.Decimal(str(item.department_sales.extracted_string_or_numeric_value))
                    except decimal.InvalidOperation:
                        raise ValueError(f"Invalid numeric value for department sales: {item.department_sales.extracted_string_or_numeric_value}")
                else:
                    raise ValueError("Department sales value must be a number or a string convertible to a number.")

            # Extract and validate reported totals
            reported_total_from_letter_val = self.total_gross_sales.extracted_string_or_numeric_value
            reported_total_from_breakdown_val = self.sales_breakdown_total.extracted_string_or_numeric_value

            if not isinstance(reported_total_from_letter_val, (int, float)) or not isinstance(reported_total_from_breakdown_val, (int, float)):
                raise ValueError("Reported totals for checksum must be numeric.")

            decimal_total_from_letter = decimal.Decimal(str(reported_total_from_letter_val))
            decimal_total_from_breakdown = decimal.Decimal(str(reported_total_from_breakdown_val))

            # Checksum 1: Sum of breakdown items vs. reported breakdown total
            if not ctx.isclose(calculated_sum, decimal_total_from_breakdown):
                raise ValueError(
                    f"GAAP Checksum Failed: Sum of breakdown items ({calculated_sum}) does not match "
                    f"the reported breakdown total ({decimal_total_from_breakdown})."
                )

            # Checksum 2: Breakdown total vs. summary letter total
            if not ctx.isclose(decimal_total_from_breakdown, decimal_total_from_letter):
                raise ValueError(
                    f"GAAP Checksum Failed: Breakdown total ({decimal_total_from_breakdown}) does not match "
                    f"the summary letter total ({decimal_total_from_letter})."
                )

        return self
```

BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "test_sales_report_2018_with_breakdown",
    "should_pass": true,
    "taxonomy_lane": "NoticeToSpartanNashRequestingIntentToRenewLease",
    "binary_header_simulation": "25504446",
    "payload": {
      "sender_name": {
        "extracted_string_or_numeric_value": "SpartanNash",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [225, 375],
          "vertical_y_vertices": [100, 130]
        }
      },
      "sender_address": {
        "extracted_string_or_numeric_value": "850 76th Street SW | PO Box 8700 | Grand Rapids MI 49518-8700",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [150, 850],
          "vertical_y_vertices": [900, 920]
        }
      },
      "sender_contact_person": {
        "extracted_string_or_numeric_value": "Amber Deering",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 350],
          "vertical_y_vertices": [750, 765]
        }
      },
      "recipient_name": {
        "extracted_string_or_numeric_value": "Kibby Company LLC",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 400],
          "vertical_y_vertices": [240, 255]
        }
      },
      "recipient_address": {
        "extracted_string_or_numeric_value": "P.O. Box 297\nMarion, MI 49665",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 400],
          "vertical_y_vertices": [260, 290]
        }
      },
      "recipient_attention_person": {
        "extracted_string_or_numeric_value": "Mrs. Judith A. Grandy",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 400],
          "vertical_y_vertices": [225, 240]
        }
      },
      "document_date": {
        "extracted_string_or_numeric_value": "April 10, 2018",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 320],
          "vertical_y_vertices": [190, 205]
        }
      },
      "property_name": {
        "extracted_string_or_numeric_value": "Valu Land #1529",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [240, 450],
          "vertical_y_vertices": [330, 345]
        }
      },
      "property_address": {
        "extracted_string_or_numeric_value": "401 S. Mill St., Marion, MI",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [455, 680],
          "vertical_y_vertices": [330, 345]
        }
      },
      "lease_date": {
        "extracted_string_or_numeric_value": "September 29, 1992",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 600],
          "vertical_y_vertices": [440, 455]
        }
      },
      "sales_period_start_date": {
        "extracted_string_or_numeric_value": "April 1, 2017",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 600],
          "vertical_y_vertices": [470, 485]
        }
      },
      "sales_period_end_date": {
        "extracted_string_or_numeric_value": "March 31, 2018",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [670, 780],
          "vertical_y_vertices": [470, 485]
        }
      },
      "total_gross_sales": {
        "extracted_string_or_numeric_value": 3767235.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [450, 580],
          "vertical_y_vertices": [530, 545]
        }
      },
      "percentage_rent_breakpoint": {
        "extracted_string_or_numeric_value": 7500000.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 600],
          "vertical_y_vertices": [580, 595]
        }
      },
      "percentage_rent_due_message": {
        "extracted_string_or_numeric_value": "no percentage rent is due for the above lease year",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [220, 700],
          "vertical_y_vertices": [595, 610]
        }
      },
      "sales_breakdown_total": {
        "extracted_string_or_numeric_value": 3767235.00,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [500, 600],
          "vertical_y_vertices": [900, 915]
        }
      },
      "sales_breakdown": [
        {"department_name": {"extracted_string_or_numeric_value": "MISC TRANSACTION", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 30.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "GROCERY", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 1351772.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "GROCERY NON-FOOD", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 205233.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "WINE", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 31451.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "TOBACCO", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 73531.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "BEER", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 207768.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "MEAT", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 582077.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "PRODUCE", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 277228.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "GEN MDSE", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 108443.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "HBC", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 83645.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "COMMISSION SALES", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 1927.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "DAIRY", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 471543.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "BAKERY", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 38137.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "DELI", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 29013.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "FROZEN", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 286161.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "SEAFOOD", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 12297.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}},
        {"department_name": {"extracted_string_or_numeric_value": "FLORAL", "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}, "department_sales": {"extracted_string_or_numeric_value": 6979.00, "optical_extraction_confidence_score": 0.95, "physical_evidence_coordinates": {"horizontal_x_vertices": [1,2], "vertical_y_vertices": [1,2]}}}
      ]
    }
  }
]
```