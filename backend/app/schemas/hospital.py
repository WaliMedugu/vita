# Hospital schemas - HospitalResponse
from pydantic import BaseModel #type: ignore
from typing import List, Optional


class Hospital(BaseModel):
    name: str
    address: str
    distance_km: float
    open_now: Optional[bool] = None
    lat: float
    lng: float
    maps_link: str


class HospitalResponse(BaseModel):
    hospitals: List[Hospital]
    bystander_lat: float
    bystander_lng: float