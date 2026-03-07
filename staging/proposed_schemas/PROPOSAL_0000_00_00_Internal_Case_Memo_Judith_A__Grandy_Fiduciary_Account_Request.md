An expert forensic data architect, operating under a Zero-Trust mandate, has meticulously analyzed the provided document's structural attributes. The following Pydantic V2 schema and corresponding JSON test case have been generated to ensure resilient, long-term data integrity for the `Internal Case Memo Judith A. Grandy Fiduciary Account Request` document class.

### BLOCK 1 (Python Pydantic V2):
```python
from typing import List, Union, Optional
from pydantic import BaseModel, Field, ConfigDict, model_validator
import math

# Base forensic data classes (MANDATORY)
class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

# Nested sub-schemas for document structure
class ClientOverview(BaseModel):
    model_config = ConfigDict(extra='forbid')
    client_name: ForensicDataEntity
    client_profile: ForensicDataEntity
    legal_authority: ForensicDataEntity
    probate_posture: ForensicDataEntity

class ActiveProceeding(BaseModel):
    model_config = ConfigDict(extra='forbid')
    proceeding_type: ForensicDataEntity
    proceeding_details: ForensicDataEntity
    expected_timeline: ForensicDataEntity

class KeyDocument(BaseModel):
    model_config = ConfigDict(extra='forbid')
    document_title: ForensicDataEntity
    summary_points: List[ForensicDataEntity]

class ClientDpoaRequest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    request_points: List[ForensicDataEntity]

class StatedObjectives(BaseModel):
    model_config = ConfigDict(extra='forbid')
    objective_points: List[ForensicDataEntity]

class RiskContext(BaseModel):
    model_config = ConfigDict(extra='forbid')
    risk_points: List[ForensicDataEntity]

class ProposedControls(BaseModel):
    model_config = ConfigDict(extra='forbid')
    control_points: List[ForensicDataEntity]

class InternalGuidanceRequested(BaseModel):
    model_config = ConfigDict(extra='forbid')
    guidance_points: List[ForensicDataEntity]

# Main schema for the document class
class InternalCaseMemoJudithAGrandyFiduciaryAccountRequest(BaseModel):
    """
    Schema for Internal Case Memo regarding Judith A. Grandy's DPOA and Fiduciary Account Request.
    """
    model_config = ConfigDict(extra='forbid')

    document_title: ForensicDataEntity
    prepared_for: ForensicDataEntity
    client_overview: ClientOverview
    active_proceeding: ActiveProceeding
    key_document: KeyDocument
    client_dpoa_request: ClientDpoaRequest
    objectives: StatedObjectives
    risk_context: RiskContext
    proposed_controls: ProposedControls
    internal_guidance_requested: InternalGuidanceRequested
    primary_advisor: ForensicDataEntity
    prepared_by: ForensicDataEntity

    @model_validator(mode='after')
    def perform_gaap_checksums(self) -> 'InternalCaseMemoJudithAGrandyFiduciaryAccountRequest':
        """
        Performs double-entry GAAP mathematical checksums.
        This document class does not contain financial figures, so this validator
        serves as a structural placeholder for compliance. If financial fields
        were introduced, their validation logic would be implemented here.
        """
        # Example of how a check would be structured if data were present:
        # if hasattr(self, 'financials'):
        #     assets = self.financials.total_assets.extracted_string_or_numeric_value
        #     liabilities = self.financials.total_liabilities.extracted_string_or_numeric_value
        #     equity = self.financials.total_equity.extracted_string_or_numeric_value
        #     if not math.isclose(assets, liabilities + equity):
        #         raise ValueError("GAAP Checksum Failed: Assets must equal Liabilities + Equity")
        return self

```

### BLOCK 2 (JSON Test Registry):
```json
[
  {
    "test_identifier": "20240515-MEMO-001-COMPLEX",
    "should_pass": true,
    "taxonomy_lane": "InternalCaseMemoJudithAGrandyFiduciaryAccountRequest",
    "binary_header_simulation": "25504446",
    "payload": {
      "document_title": {
        "extracted_string_or_numeric_value": "Internal Case Memo – Judith A. Grandy (DPOA / Fiduciary Account Request)",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [88.0, 787.0, 787.0, 88.0],
          "vertical_y_vertices": [88.0, 88.0, 118.0, 118.0]
        }
      },
      "prepared_for": {
        "extracted_string_or_numeric_value": "Prepared for internal circulation (Compliance / Fiduciary / Operations).",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [137.0, 594.0, 594.0, 137.0],
          "vertical_y_vertices": [137.0, 137.0, 149.0, 149.0]
        }
      },
      "client_overview": {
        "client_name": {
          "extracted_string_or_numeric_value": "Judith A. Grandy",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198.0, 347.0, 347.0, 198.0],
            "vertical_y_vertices": [198.0, 198.0, 209.0, 209.0]
          }
        },
        "client_profile": {
          "extracted_string_or_numeric_value": "Elderly; progressive cognitive impairment (family reports and supporting documentation available upon request).",
          "optical_extraction_confidence_score": 0.97,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
            "vertical_y_vertices": [220.0, 220.0, 243.0, 243.0]
          }
        },
        "legal_authority": {
          "extracted_string_or_numeric_value": "Durable Power of Attorney held by son, Mark W. Sosa Kibby.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198.0, 661.0, 661.0, 198.0],
            "vertical_y_vertices": [254.0, 254.0, 265.0, 265.0]
          }
        },
        "probate_posture": {
          "extracted_string_or_numeric_value": "Recent Probate Court ruling affirmed DPOA validity and denied guardianship petition (order available for file).",
          "optical_extraction_confidence_score": 0.96,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
            "vertical_y_vertices": [276.0, 276.0, 300.0, 300.0]
          }
        }
      },
      "active_proceeding": {
        "proceeding_type": {
          "extracted_string_or_numeric_value": "Divorce",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198.0, 250.0, 250.0, 198.0],
            "vertical_y_vertices": [343.0, 343.0, 354.0, 354.0]
          }
        },
        "proceeding_details": {
          "extracted_string_or_numeric_value": "Divorce proceeding underway between Judith A. Grandy and Keith A. Grandy.",
          "optical_extraction_confidence_score": 0.98,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [253.0, 791.0, 791.0, 253.0],
            "vertical_y_vertices": [343.0, 343.0, 354.0, 354.0]
          }
        },
        "expected_timeline": {
          "extracted_string_or_numeric_value": "DPOA expects completion by 1/31.",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [198.0, 460.0, 460.0, 198.0],
            "vertical_y_vertices": [376.0, 376.0, 387.0, 387.0]
          }
        }
      },
      "key_document": {
        "document_title": {
          "extracted_string_or_numeric_value": "Key Document – Antenuptial Agreement (2005)",
          "optical_extraction_confidence_score": 0.99,
          "physical_evidence_coordinates": {
            "horizontal_x_vertices": [170.0, 555.0, 555.0, 170.0],
            "vertical_y_vertices": [409.0, 409.0, 420.0, 420.0]
          }
        },
        "summary_points": [
          {
            "extracted_string_or_numeric_value": "Agreement executed prior to marriage; includes premarital asset/debt disclosures and a defined separate property framework for premarital assets (including real estate and premarital business interests).",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [431.0, 431.0, 466.0, 466.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Includes provisions addressing responsibility for debts and contemplates handling of property issues in the event of separation/divorce.",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [477.0, 477.0, 501.0, 501.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Counsel is responsible for legal interpretation and court strategy; this memo references the agreement only as relevant context for fiduciary risk management and documentation.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [512.0, 512.0, 547.0, 547.0]
            }
          }
        ]
      },
      "client_dpoa_request": {
        "request_points": [
          {
            "extracted_string_or_numeric_value": "Open a fiduciary managed investment and cash management account at Merrill Lynch under valid DPOA authority.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [580.0, 580.0, 604.0, 604.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Position Merrill as the professional steward of assets, liquidity, and controls; reduce concentration of discretion in the DPOA individually.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [615.0, 615.0, 638.0, 638.0]
            }
          }
        ]
      },
      "objectives": {
        "objective_points": [
          {
            "extracted_string_or_numeric_value": "Implement institutional oversight, documentation, and auditability.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 680.0, 680.0, 198.0],
              "vertical_y_vertices": [682.0, 682.0, 693.0, 693.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Ensure disbursements are policy driven and aligned with documented care needs and estate objectives.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [704.0, 704.0, 715.0, 715.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Increase transparency and defensibility amid family conflict and elevated litigation sensitivity.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [726.0, 726.0, 737.0, 737.0]
            }
          }
        ]
      },
      "risk_context": {
        "risk_points": [
          {
            "extracted_string_or_numeric_value": "Vulnerable adult considerations due to cognitive impairment.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 670.0, 670.0, 198.0],
              "vertical_y_vertices": [781.0, 781.0, 792.0, 792.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Active family conflict; heightened optics and challenge risk.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 670.0, 670.0, 198.0],
              "vertical_y_vertices": [803.0, 803.0, 814.0, 814.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Divorce timing creates near term sensitivity around liquidity and disbursements.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [825.0, 825.0, 836.0, 836.0]
            }
          }
        ]
      },
      "proposed_controls": {
        "control_points": [
          {
            "extracted_string_or_numeric_value": "Account opened with standard DPOA validation and any required supporting documentation.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 791.0, 791.0, 198.0],
              "vertical_y_vertices": [880.0, 880.0, 903.0, 903.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Merrill to manage investment policy, liquidity posture, and disbursement controls; maintain a clear audit trail.",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 810.0, 810.0, 198.0],
              "vertical_y_vertices": [100.0, 100.0, 111.0, 111.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Disbursement categories tied to documented care plan / household needs / professional fees (as permitted).",
            "optical_extraction_confidence_score": 0.96,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 810.0, 810.0, 198.0],
              "vertical_y_vertices": [122.0, 122.0, 133.0, 133.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Transparency via reporting cadence (e.g., periodic statements shared with designated oversight stakeholders) without granting additional trading authority.",
            "optical_extraction_confidence_score": 0.95,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 810.0, 810.0, 198.0],
              "vertical_y_vertices": [144.0, 144.0, 167.0, 167.0]
            }
          }
        ]
      },
      "internal_guidance_requested": {
        "guidance_points": [
          {
            "extracted_string_or_numeric_value": "Confirm recommended account structure and supervisory requirements.",
            "optical_extraction_confidence_score": 0.99,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 680.0, 680.0, 198.0],
              "vertical_y_vertices": [200.0, 200.0, 211.0, 211.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Confirm documentation checklist for a DPOA led relationship with elevated family conflict and active divorce.",
            "optical_extraction_confidence_score": 0.98,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 810.0, 810.0, 198.0],
              "vertical_y_vertices": [222.0, 222.0, 245.0, 245.0]
            }
          },
          {
            "extracted_string_or_numeric_value": "Recommend any additional safeguards (e.g., disbursement policy memo, dual review thresholds, restricted disbursement instructions).",
            "optical_extraction_confidence_score": 0.97,
            "physical_evidence_coordinates": {
              "horizontal_x_vertices": [198.0, 810.0, 810.0, 198.0],
              "vertical_y_vertices": [256.0, 256.0, 291.0, 291.0]
            }
          }
        ]
      },
      "primary_advisor": {
        "extracted_string_or_numeric_value": "Julie A. Wilsey (Merrill Lynch)",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [198.0, 460.0, 460.0, 198.0],
          "vertical_y_vertices": [324.0, 324.0, 335.0, 335.0]
        }
      },
      "prepared_by": {
        "extracted_string_or_numeric_value": "Mark W. Sosa Kibby (DPOA for Judith A. Grandy) – for advisor use",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [198.0, 680.0, 680.0, 198.0],
          "vertical_y_vertices": [346.0, 346.0, 357.0, 357.0]
        }
      }
    }
  }
]
```
