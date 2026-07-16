# Pool schemas - PoolResponse, SweepConfig
from pydantic import BaseModel #type: ignore
from typing import Optional
from datetime import datetime


class ContributeRequest(BaseModel):
    amount: float
    opay_phone: str
    transaction_amount: Optional[float] = None  # null if scheduled contribution


class PoolResponse(BaseModel):
    id: str
    group_id: str
    balance: float
    sweep_amount: float
    min_wallet_threshold: float
    contribution_mode: str
    contribution_frequency: Optional[str] = None
    scheduled_contribution_amount: Optional[float] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ContributionResponse(BaseModel):
    message: str
    pool_id: str
    amount_swept: float
    new_balance: float
    opay_reference: str
    opay_phone: str
    transaction_amount: Optional[float] = None
    contributed_by: str
    timestamp: datetime


class ContributionHistoryItem(BaseModel):
    id: str
    amount: float
    opay_reference: str
    contributed_by_name: str
    note: str
    created_at: datetime


class ContributionHistoryResponse(BaseModel):
    pool_id: str
    total_contributions: int
    contributions: list[ContributionHistoryItem]