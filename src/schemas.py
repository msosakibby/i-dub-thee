import json
import hashlib
import uuid
from pydantic import BaseModel, Field, model_validator, ValidationError
from typing import Optional
from datetime import datetime, timezone

class FlatForensicPayload(BaseModel):
    dossier_id: str = Field(..., description="Binding to the original WORM PDF.")
    extraction_timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    ingestion_event_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    cryptographic_sha256_hash: str = Field(default="")
    
    activity_line_01_description_value: Optional[str] = None
    activity_line_01_description_confidence: Optional[float] = Field(None, ge=0.0, le=1.0)
    activity_line_01_amount_value: Optional[float] = None
    activity_line_01_amount_confidence: Optional[float] = Field(None, ge=0.0, le=1.0)
    
    aicpa_compliant: bool = True

    @model_validator(mode='after')
    def author_hash_and_compliance(self) -> 'FlatForensicPayload':
        for field_name, value in self.__dict__.items():
            if field_name.endswith('_confidence') and value is not None and value < 0.90:
                self.aicpa_compliant = False
        payload_dict = self.model_dump(exclude={'cryptographic_sha256_hash'})
        self.cryptographic_sha256_hash = hashlib.sha256(json.dumps(payload_dict, sort_keys=True, default=str).encode('utf-8')).hexdigest()
        return self

    model_config = {"extra": "forbid"}
