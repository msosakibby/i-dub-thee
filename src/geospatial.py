import math
from typing import List, Dict, Optional
from pydantic import BaseModel, ConfigDict

class BoundingPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    x_vertices: List[float]
    y_vertices: List[float]
    
    def centroid(self) -> dict:
        return {"x": sum(self.x_vertices)/len(self.x_vertices), "y": sum(self.y_vertices)/len(self.y_vertices)}

class OpticalEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    text: str
    confidence: float
    coordinates: BoundingPolygon
    is_handwritten: bool

class GeospatialAnchorEngine:
    def __init__(self, vertical_threshold: float = 0.05, horizontal_threshold: float = 0.40):
        self.v_thresh = vertical_threshold
        self.h_thresh = horizontal_threshold

    def bind_marginalia(self, printed_items: List[OpticalEntity], handwritten_notes: List[OpticalEntity]) -> List[Dict]:
        anchored_ledger = []
        for printed in printed_items:
            p_center = printed.coordinates.centroid()
            closest_note, shortest_dist = None, float('inf')
            
            for note in handwritten_notes:
                n_center = note.coordinates.centroid()
                if abs(p_center["y"] - n_center["y"]) <= self.v_thresh:
                    dist = math.sqrt((p_center["x"] - n_center["x"])**2 + (p_center["y"] - n_center["y"])**2)
                    if dist < shortest_dist and dist <= self.h_thresh:
                        shortest_dist, closest_note = dist, note
                        
            anchored_ledger.append({
                "printed_transaction": printed.model_dump(),
                "handwritten_modifier": closest_note.model_dump() if closest_note else None
            })
            if closest_note in handwritten_notes:
                handwritten_notes.remove(closest_note)
        return anchored_ledger
