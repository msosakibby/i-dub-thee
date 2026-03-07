An expert forensic data architect operating under a Zero-Trust mandate, I have analyzed the provided document specimen for the class 'Daily Record of Events _ 08_00 SH Tech OPS Weekly Partner Call'. Based on the structural evidence, I have engineered the following resilient Pydantic V2 schema and a corresponding golden test case. The schema is designed to parse and validate the key data entities, including a checksum for attendee counts, ensuring data integrity.

***

### **BLOCK 1: Python Pydantic V2 Schema**
```python
from typing import List, Union, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class SpatialCoordinatesPolygon(BaseModel):
    """Defines the bounding box of an extracted data entity."""
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    """A wrapper for a single piece of extracted data, including metadata."""
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Attendee(BaseModel):
    """Represents a single person on the invite list."""
    model_config = ConfigDict(extra='forbid')
    name: ForensicDataEntity
    email: ForensicDataEntity
    mobile_number: Optional[ForensicDataEntity] = None
    status: ForensicDataEntity

class ShTechOpsWeeklyPartnerCall(BaseModel):
    """
    Schema for the 'Daily Record of Events _ 08_00 SH Tech OPS Weekly Partner Call'
    document class.
    """
    model_config = ConfigDict(extra='forbid')

    meeting_date: ForensicDataEntity
    meeting_description: ForensicDataEntity
    meeting_id: ForensicDataEntity
    project: ForensicDataEntity
    notebook: ForensicDataEntity
    location: ForensicDataEntity
    url: ForensicDataEntity
    secondary_tel: ForensicDataEntity
    my_planned_attendance: ForensicDataEntity
    
    people_invited: ForensicDataEntity
    people_accepted: ForensicDataEntity
    people_declined: ForensicDataEntity
    people_unknown: ForensicDataEntity
    
    legend: ForensicDataEntity
    attendees: List[Attendee]
    key_topics_header: ForensicDataEntity

    @model_validator(mode='after')
    def validate_attendance_counts(self) -> 'ShTechOpsWeeklyPartnerCall':
        """
        Performs a double-entry checksum on attendance figures.
        The number of invited people must equal the sum of accepted, declined,
        and unknown responses.
        """
        invited = self.people_invited.extracted_string_or_numeric_value
        accepted = self.people_accepted.extracted_string_or_numeric_value
        declined = self.people_declined.extracted_string_or_numeric_value
        unknown = self.people_unknown.extracted_string_or_numeric_value

        if not all(isinstance(val, (int, float)) for val in [invited, accepted, declined, unknown]):
            raise ValueError("Attendance counts must be numeric for validation.")

        if invited != (accepted + declined + unknown):
            raise ValueError(
                f"Attendance count mismatch: Invited ({invited}) does not equal "
                f"Accepted ({accepted}) + Declined ({declined}) + Unknown ({unknown}). "
                f"Sum is {accepted + declined + unknown}."
            )
        
        return self

```

### **BLOCK 2: JSON Test Registry**
```json
[
  {
    "test_identifier": "20180202_SH_Tech_OPS_Call_80098900001",
    "should_pass": true,
    "taxonomy_lane": "ShTechOpsWeeklyPartnerCall",
    "binary_header_simulation": "25504446",
    "payload": {
      "meeting_date": {
        "extracted_string_or_numeric_value": "2018-02-02",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 235],
          "vertical_y_vertices": [35, 48]
        }
      },
      "meeting_description": {
        "extracted_string_or_numeric_value": "Daily Record of Events | 08:00 SH Tech OPS Weekly Partner Call",
        "optical_extraction_confidence_score": 0.98,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [238, 750],
          "vertical_y_vertices": [35, 48]
        }
      },
      "meeting_id": {
        "extracted_string_or_numeric_value": "80098900001",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [755, 860],
          "vertical_y_vertices": [35, 48]
        }
      },
      "project": {
        "extracted_string_or_numeric_value": "[BTRN] Excellus - Horizon ERP Strategic Advisor",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 580],
          "vertical_y_vertices": [55, 68]
        }
      },
      "notebook": {
        "extracted_string_or_numeric_value": "Business Transformation",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 360],
          "vertical_y_vertices": [75, 88]
        }
      },
      "location": {
        "extracted_string_or_numeric_value": "18883319770,3691597# Host: 1267 (Thom)",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 500],
          "vertical_y_vertices": [95, 108]
        }
      },
      "url": {
        "extracted_string_or_numeric_value": "tel:18883319770,3691597%23",
        "optical_extraction_confidence_score": 0.96,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [505, 750],
          "vertical_y_vertices": [95, 108]
        }
      },
      "secondary_tel": {
        "extracted_string_or_numeric_value": "tel:13127771467,3691597%23",
        "optical_extraction_confidence_score": 0.97,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 360],
          "vertical_y_vertices": [115, 128]
        }
      },
      "my_planned_attendance": {
        "extracted_string_or_numeric_value": "Must Be Attended",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 300],
          "vertical_y_vertices": [135, 148]
        }
      },
      "people_invited": {
        "extracted_string_or_numeric_value": 12,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [320, 335],
          "vertical_y_vertices": [185, 198]
        }
      },
      "people_accepted": {
        "extracted_string_or_numeric_value": 10,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [415, 435],
          "vertical_y_vertices": [185, 198]
        }
      },
      "people_declined": {
        "extracted_string_or_numeric_value": 1,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [515, 525],
          "vertical_y_vertices": [185, 198]
        }
      },
      "people_unknown": {
        "extracted_string_or_numeric_value": 0,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [615, 625],
          "vertical_y_vertices": [185, 198]
        }
      },
      "legend": {
        "extracted_string_or_numeric_value": "(Legend): M=Mobile Number",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 350],
          "vertical_y_vertices": [265, 278]
        }
      },
      "attendees": [
        {
          "name": { "extracted_string_or_numeric_value": "Dirk Klemm", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 230], "vertical_y_vertices": [285, 298] } },
          "email": { "extracted_string_or_numeric_value": "dirk.klemm@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [240, 380], "vertical_y_vertices": [285, 298] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(847) 729-5634", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 520], "vertical_y_vertices": [285, 298] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [530, 600], "vertical_y_vertices": [285, 298] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Akshay Jindal", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 250], "vertical_y_vertices": [305, 318] } },
          "email": { "extracted_string_or_numeric_value": "a.jindal@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [260, 390], "vertical_y_vertices": [305, 318] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(773) 501-3358", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [410, 530], "vertical_y_vertices": [305, 318] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 610], "vertical_y_vertices": [305, 318] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Mark Kibby", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 235], "vertical_y_vertices": [325, 338] } },
          "email": { "extracted_string_or_numeric_value": "mark.kibby@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [245, 400], "vertical_y_vertices": [325, 338] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(773) 251-0539", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [420, 540], "vertical_y_vertices": [325, 338] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [550, 620], "vertical_y_vertices": [325, 338] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Scott Behrens", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 260], "vertical_y_vertices": [345, 358] } },
          "email": { "extracted_string_or_numeric_value": "scott.behrens@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 450], "vertical_y_vertices": [345, 358] } },
          "mobile_number": null,
          "status": { "extracted_string_or_numeric_value": "Declined", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [480, 550], "vertical_y_vertices": [345, 358] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Sundar Subramanian", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 310], "vertical_y_vertices": [365, 378] } },
          "email": { "extracted_string_or_numeric_value": "sundar.subramanian@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [320, 540], "vertical_y_vertices": [365, 378] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(212) 551-6651", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 680], "vertical_y_vertices": [365, 378] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [690, 760], "vertical_y_vertices": [365, 378] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Thom Bales", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 240], "vertical_y_vertices": [385, 398] } },
          "email": { "extracted_string_or_numeric_value": "thom.bales@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [250, 410], "vertical_y_vertices": [385, 398] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(415) 627-3371", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [430, 550], "vertical_y_vertices": [385, 398] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [560, 630], "vertical_y_vertices": [385, 398] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Michael James Farley", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 315], "vertical_y_vertices": [405, 418] } },
          "email": { "extracted_string_or_numeric_value": "michael.farley@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [325, 500], "vertical_y_vertices": [405, 418] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(773) 348-0108", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [520, 640], "vertical_y_vertices": [405, 418] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [650, 720], "vertical_y_vertices": [405, 418] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Pier Paolo Paolo Noventa", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 340], "vertical_y_vertices": [425, 438] } },
          "email": { "extracted_string_or_numeric_value": "pier.noventa@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [350, 520], "vertical_y_vertices": [425, 438] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(312) 320-3741", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [540, 660], "vertical_y_vertices": [425, 438] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [670, 740], "vertical_y_vertices": [425, 438] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Jaime Estupinan", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 280], "vertical_y_vertices": [445, 458] } },
          "email": { "extracted_string_or_numeric_value": "jaime.estupinan@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [290, 480], "vertical_y_vertices": [445, 458] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(212) 551-6518", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [500, 620], "vertical_y_vertices": [445, 458] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [630, 700], "vertical_y_vertices": [445, 458] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Deepak Goyal", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 260], "vertical_y_vertices": [465, 478] } },
          "email": { "extracted_string_or_numeric_value": "deepak.goyal@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [270, 450], "vertical_y_vertices": [465, 478] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(415) 653-3482", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [470, 590], "vertical_y_vertices": [465, 478] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [600, 670], "vertical_y_vertices": [465, 478] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Gil Irwin", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 220], "vertical_y_vertices": [485, 498] } },
          "email": { "extracted_string_or_numeric_value": "gil.irwin@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [230, 380], "vertical_y_vertices": [485, 498] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(201) 805-5351", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [400, 520], "vertical_y_vertices": [485, 498] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [530, 600], "vertical_y_vertices": [485, 498] } }
        },
        {
          "name": { "extracted_string_or_numeric_value": "Keith Fengler", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [148, 255], "vertical_y_vertices": [505, 518] } },
          "email": { "extracted_string_or_numeric_value": "keith.fengler@pwc.com", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [265, 440], "vertical_y_vertices": [505, 518] } },
          "mobile_number": { "extracted_string_or_numeric_value": "(617) 521-8803", "optical_extraction_confidence_score": 0.98, "physical_evidence_coordinates": { "horizontal_x_vertices": [460, 580], "vertical_y_vertices": [505, 518] } },
          "status": { "extracted_string_or_numeric_value": "Accepted", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": { "horizontal_x_vertices": [590, 660], "vertical_y_vertices": [505, 518] } }
        }
      ],
      "key_topics_header": {
        "extracted_string_or_numeric_value": "Key Topics, Action Items, Owners and Due Dates:",
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {
          "horizontal_x_vertices": [145, 550],
          "vertical_y_vertices": [550, 563]
        }
      }
    }
  }
]
```