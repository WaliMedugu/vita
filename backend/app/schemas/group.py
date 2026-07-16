from pydantic import BaseModel
from typing import Optional, Literal
from datetime import datetime


class CreateGroupRequest(BaseModel):
    name: str
    spending_limit: Optional[float] = 15000
    reserve_floor: Optional[float] = 3000 #minimum balance to maintain in the pool(pool can't go below this amount)
    sweep_amount: Optional[float] = 100 #minimum amount to sweep from members' per transacriion, only available if contribution_mode is "passive"
    contribution_mode: Literal["passive", "scheduled"] = "passive"
    contribution_frequency: Optional[Literal["daily", "weekly", "monthly", "yearly"]] = None
    scheduled_contribution_amount: Optional[float] = None


class InviteMemberRequest(BaseModel):
    email: str


class UpdateContributionRequest(BaseModel):
    contribution_mode: Literal["passive", "scheduled"]
    contribution_frequency: Optional[Literal["daily", "weekly", "monthly", "yearly"]] = None
    scheduled_contribution_amount: Optional[float] = None


class GroupResponse(BaseModel):
    id: str
    name: str
    admin_id: str
    spending_limit: float
    reserve_floor: float
    sweep_amount: Optional[float] = None
    created_at: datetime
    member_count: int
    pool_id: Optional[str] = None
    pool_balance: float = 0.0
    contribution_mode: Optional[str] = None
    contribution_frequency: Optional[str] = None
    scheduled_contribution_amount: Optional[float] = None

    class Config:
        from_attributes = True


class InviteResponse(BaseModel):
    message: str
    group_id: str
    user_id: str
    full_name: str


class ContributionUpdateResponse(BaseModel):
    message: str
    group_id: str
    pending_mode: str
    pending_frequency: Optional[str] = None
    pending_amount: Optional[float] = None