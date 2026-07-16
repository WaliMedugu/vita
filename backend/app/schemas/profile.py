# Profile schemas - VitaProfile, FirstAidRequest

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class CreateProfileRequest(BaseModel):
    blood_type: Optional[str] = None
    allergies: Optional[List[str]] = []
    conditions: Optional[List[str]] = []
    emergency_contact: Optional[str] = None
    emergency_contact_2: Optional[str] = None
    pool_id: Optional[str] = None  # which pool to link to NFC card


class UpdateProfileRequest(BaseModel):
    blood_type: Optional[str] = None
    allergies: Optional[List[str]] = None
    conditions: Optional[List[str]] = None
    emergency_contact: Optional[str] = None
    emergency_contact_2: Optional[str] = None
    pool_id: Optional[str] = None


class ProfileResponse(BaseModel):
    id: str
    user_id: str
    blood_type: Optional[str] = None
    allergies: Optional[List[str]] = []
    conditions: Optional[List[str]] = []
    emergency_contact: Optional[str] = None
    emergency_contact_2: Optional[str] = None
    pool_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NFCProfileResponse(BaseModel):
    """
    Exact shape written to and read from the NFC card.
    Matches VitaProfile model in Wali's Flutter app.
    """
    name: str
    blood_type: Optional[str] = None
    allergies: Optional[List[str]] = []
    conditions: Optional[List[str]] = []
    emergency_contact: Optional[str] = None
    emergency_contact_2: Optional[str] = None
    pool_id: Optional[str] = None