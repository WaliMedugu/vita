from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.group import Group
from app.models.member import GroupMember
from app.models.pool import Pool
from app.models.user import User
from app.schemas.group import (
    CreateGroupRequest,
    InviteMemberRequest,
    GroupResponse,
    InviteResponse,
    UpdateContributionRequest,
    ContributionUpdateResponse,
)
from app.utils.auth import get_current_user
from datetime import datetime
import uuid

router = APIRouter()


@router.post("", response_model=GroupResponse)
def create_group(
    req: CreateGroupRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    admin_id = uuid.UUID(current_user["user_id"])
    now = datetime.utcnow()

    # Validate contribution mode rules
    if req.contribution_mode == "scheduled":
        if not req.contribution_frequency or not req.scheduled_contribution_amount:
            raise HTTPException(
                status_code=400,
                detail="Scheduled mode requires both contribution_frequency and scheduled_contribution_amount"
            )
    if req.contribution_mode == "passive":
        if req.contribution_frequency or req.scheduled_contribution_amount:
            raise HTTPException(
                status_code=400,
                detail="Passive mode does not accept contribution_frequency or scheduled_contribution_amount"
            )

    # Create group
    group = Group(
        id=uuid.uuid4(),
        name=req.name,
        admin_id=admin_id,
        spending_limit=req.spending_limit,
        reserve_floor=req.reserve_floor,
        created_at=now,
    )
    db.add(group)
    db.flush()

    # Auto-create VitaPool for the group
    pool = Pool(
        id=uuid.uuid4(),
        group_id=group.id,
        balance=0,
        sweep_amount=req.sweep_amount,
        min_wallet_threshold=500,
        contribution_mode=req.contribution_mode,
        contribution_frequency=req.contribution_frequency,
        scheduled_contribution_amount=req.scheduled_contribution_amount,
        created_at=now,
        updated_at=now,
    )
    db.add(pool)

    # Add creator as first member
    membership = GroupMember(
        id=uuid.uuid4(),
        group_id=group.id,
        user_id=admin_id,
        joined_at=now,
    )
    db.add(membership)

    db.commit()
    db.refresh(group)

    return GroupResponse(
        id=str(group.id),
        name=group.name,
        admin_id=str(group.admin_id),
        spending_limit=float(group.spending_limit),
        reserve_floor=float(group.reserve_floor),
        sweep_amount=float(pool.sweep_amount),
        created_at=group.created_at,
        member_count=1,
        pool_id=str(pool.id),
        pool_balance=0.0,
        contribution_mode=pool.contribution_mode,
        contribution_frequency=pool.contribution_frequency,
        scheduled_contribution_amount=float(pool.scheduled_contribution_amount) if pool.scheduled_contribution_amount else None,
    )


@router.post("/{group_id}/invite", response_model=InviteResponse)
def invite_member(
    group_id: str,
    req: InviteMemberRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    group_uuid = uuid.UUID(group_id)
    admin_id = uuid.UUID(current_user["user_id"])
    now = datetime.utcnow()

    group = db.query(Group).filter(Group.id == group_uuid).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    if group.admin_id != admin_id:
        raise HTTPException(status_code=403, detail="Only the group admin can invite members")

    invitee = db.query(User).filter(User.email == req.email).first()
    if not invitee:
        raise HTTPException(status_code=404, detail="No VITA account found with that email")

    existing = db.query(GroupMember).filter(
        GroupMember.group_id == group_uuid,
        GroupMember.user_id == invitee.id,
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="User is already a member")

    count = db.query(GroupMember).filter(GroupMember.group_id == group_uuid).count()
    if count >= 50:
        raise HTTPException(status_code=400, detail="Group is full — maximum 50 members")

    membership = GroupMember(
        id=uuid.uuid4(),
        group_id=group_uuid,
        user_id=invitee.id,
        joined_at=now,
    )
    db.add(membership)
    db.commit()

    return InviteResponse(
        message=f"{invitee.full_name} added to {group.name}",
        group_id=str(group.id),
        user_id=str(invitee.id),
        full_name=invitee.full_name,
    )


@router.get("/{group_id}", response_model=GroupResponse)
def get_group(
    group_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    group_uuid = uuid.UUID(group_id)
    user_id = uuid.UUID(current_user["user_id"])

    group = db.query(Group).filter(Group.id == group_uuid).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    membership = db.query(GroupMember).filter(
        GroupMember.group_id == group_uuid,
        GroupMember.user_id == user_id,
    ).first()
    if not membership:
        raise HTTPException(status_code=403, detail="You are not a member of this group")

    member_count = db.query(GroupMember).filter(
        GroupMember.group_id == group_uuid
    ).count()

    pool = db.query(Pool).filter(Pool.group_id == group_uuid).first()

    return GroupResponse(
        id=str(group.id),
        name=group.name,
        admin_id=str(group.admin_id),
        spending_limit=float(group.spending_limit),
        reserve_floor=float(group.reserve_floor),
        sweep_amount=float(pool.sweep_amount) if pool else None,
        created_at=group.created_at,
        member_count=member_count,
        pool_id=str(pool.id) if pool else None,
        pool_balance=float(pool.balance) if pool else 0.0,
        contribution_mode=pool.contribution_mode if pool else None,
        contribution_frequency=pool.contribution_frequency if pool else None,
        scheduled_contribution_amount=float(pool.scheduled_contribution_amount) if pool and pool.scheduled_contribution_amount else None,
    )


@router.get("/{group_id}/members")
def get_members(
    group_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    group_uuid = uuid.UUID(group_id)
    user_id = uuid.UUID(current_user["user_id"])

    membership = db.query(GroupMember).filter(
        GroupMember.group_id == group_uuid,
        GroupMember.user_id == user_id,
    ).first()
    if not membership:
        raise HTTPException(status_code=403, detail="You are not a member of this group")

    members = (
        db.query(GroupMember, User)
        .join(User, GroupMember.user_id == User.id)
        .filter(GroupMember.group_id == group_uuid)
        .all()
    )

    return [
        {
            "user_id": str(m.GroupMember.user_id),
            "full_name": m.User.full_name,
            "email": m.User.email,
            "joined_at": m.GroupMember.joined_at,
        }
        for m in members
    ]


@router.patch("/{group_id}/contribution", response_model=ContributionUpdateResponse)
def request_contribution_change(
    group_id: str,
    req: UpdateContributionRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    group_uuid = uuid.UUID(group_id)
    admin_id = uuid.UUID(current_user["user_id"])

    group = db.query(Group).filter(Group.id == group_uuid).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")
    if group.admin_id != admin_id:
        raise HTTPException(status_code=403, detail="Only the group admin can change contribution settings")

    # Validate contribution mode rules
    if req.contribution_mode == "scheduled":
        if not req.contribution_frequency or not req.scheduled_contribution_amount:
            raise HTTPException(
                status_code=400,
                detail="Scheduled mode requires both contribution_frequency and scheduled_contribution_amount"
            )
    if req.contribution_mode == "passive":
        if req.contribution_frequency or req.scheduled_contribution_amount:
            raise HTTPException(
                status_code=400,
                detail="Passive mode does not accept contribution_frequency or scheduled_contribution_amount"
            )

    pool = db.query(Pool).filter(Pool.group_id == group_uuid).first()
    if not pool:
        raise HTTPException(status_code=404, detail="Pool not found")

    pool.pending_mode_change = req.contribution_mode
    pool.pending_frequency_change = req.contribution_frequency
    pool.pending_amount_change = req.scheduled_contribution_amount
    pool.updated_at = datetime.utcnow()

    db.commit()

    return ContributionUpdateResponse(
        message="Contribution change submitted — group members have 30 minutes to object before it takes effect",
        group_id=str(group.id),
        pending_mode=req.contribution_mode,
        pending_frequency=req.contribution_frequency,
        pending_amount=req.scheduled_contribution_amount,
    )