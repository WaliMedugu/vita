# Emergency schemas
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class TriggerEmergencyRequest(BaseModel):
    user_id: str       # patient's user_id from NFC card
    lat: float
    lng: float


class ReleaseRequest(BaseModel):
    amount: float
    note: Optional[str] = ""


class EmergencyResponse(BaseModel):
    id: str
    pool_id: str
    patient_id: str
    patient_name: str
    status: str
    lat: float
    lng: float
    total_spent: float
    created_at: datetime
    closed_at: Optional[datetime] = None


class EmergencyContactView(BaseModel):
    emergency_id: str
    patient_name: str
    patient_blood_type: Optional[str] = None
    patient_allergies: Optional[List[str]] = []
    patient_conditions: Optional[List[str]] = []
    status: str
    lat: float
    lng: float
    total_spent: float
    pools: List[dict]
    triggered_at: datetime


class ReleaseResponse(BaseModel):
    message: str
    emergency_id: str
    amount_released: float
    destination: str
    new_pool_balance: float
    new_total_spent: float
    opay_reference: str
    timestamp: datetime


class ReceiptItem(BaseModel):
    amount: float
    destination: str
    opay_reference: str
    note: str
    timestamp: datetime


class EmergencyReceipt(BaseModel):
    emergency_id: str
    patient_name: str
    status: str
    triggered_at: datetime
    closed_at: Optional[datetime] = None
    total_spent: float
    remaining_balance: float
    reserve_floor: float
    payments: List[ReceiptItem]