from pydantic import BaseModel #type: ignore
from typing import List, Optional


class FirstAidRequest(BaseModel):
    conditions: List[str]
    allergies: Optional[List[str]] = []


class FirstAidResponse(BaseModel):
    guidance: str
    disclaimer: str
    conditions_addressed: List[str]


class ProfileBuilderRequest(BaseModel):
    raw_text: str
    language: Optional[str] = "english"


class ProfileBuilderResponse(BaseModel):
    blood_type: Optional[str] = None
    allergies: List[str] = []
    conditions: List[str] = []
    emergency_contact: Optional[str] = None
    confidence_note: str