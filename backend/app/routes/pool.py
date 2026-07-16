# Pool routes - GET /pool/:id, POST /pool/create
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.pool import Pool
from app.models.group import Group
from app.models.member import GroupMember
from app.models.transaction import Transaction
from app.models.user import User
from app.schemas.pool import (
    PoolResponse,
    ContributeRequest,
    ContributionResponse,
    ContributionHistoryItem,
    ContributionHistoryResponse,
)
from app.utils.auth import get_current_user
from app.utils.opay_mock import generate_opay_response
from datetime import datetime
import uuid

router = APIRouter()


@router.get("/{pool_id}", response_model=PoolResponse)
def get_pool(
    pool_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    pool_uuid = uuid.UUID(pool_id)
    user_id = uuid.UUID(current_user["user_id"])

    pool = db.query(Pool).filter(Pool.id == pool_uuid).first()
    if not pool:
        raise HTTPException(status_code=404, detail="Pool not found")

    # Must be a group member to view pool
    membership = db.query(GroupMember).filter(
        GroupMember.group_id == pool.group_id,
        GroupMember.user_id == user_id,
    ).first()
    if not membership:
        raise HTTPException(status_code=403, detail="You are not a member of this pool's group")

    return PoolResponse(
        id=str(pool.id),
        group_id=str(pool.group_id),
        balance=float(pool.balance),
        sweep_amount=float(pool.sweep_amount),
        min_wallet_threshold=float(pool.min_wallet_threshold),
        contribution_mode=pool.contribution_mode,
        contribution_frequency=pool.contribution_frequency,
        scheduled_contribution_amount=float(pool.scheduled_contribution_amount) if pool.scheduled_contribution_amount else None,
        created_at=pool.created_at,
        updated_at=pool.updated_at,
    )


@router.post("/{pool_id}/contribute", response_model=ContributionResponse)
def contribute(
    pool_id: str,
    req: ContributeRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    pool_uuid = uuid.UUID(pool_id)
    user_id = uuid.UUID(current_user["user_id"])
    now = datetime.utcnow()

    pool = db.query(Pool).filter(Pool.id == pool_uuid).first()
    if not pool:
        raise HTTPException(status_code=404, detail="Pool not found")

    # Must be a group member to contribute
    membership = db.query(GroupMember).filter(
        GroupMember.group_id == pool.group_id,
        GroupMember.user_id == user_id,
    ).first()
    if not membership:
        raise HTTPException(status_code=403, detail="You are not a member of this pool's group")

    # Validate amount
    if req.amount <= 0:
        raise HTTPException(status_code=400, detail="Contribution amount must be greater than zero")

    # Validate scheduled contribution amount matches pool config
    if pool.contribution_mode == "scheduled":
        if pool.scheduled_contribution_amount and req.amount != float(pool.scheduled_contribution_amount):
            raise HTTPException(
                status_code=400,
                detail=f"Scheduled contribution amount must be N{pool.scheduled_contribution_amount}"
            )

    # Validate passive sweep amount matches pool config
    if pool.contribution_mode == "passive":
        if not req.transaction_amount:
          raise HTTPException(
            status_code=400,
            detail="Passive sweep requires transaction_amount"
        )
        if req.transaction_amount < 500:
            return ContributionResponse(
            message="Transaction below sweep threshold — no contribution made",
            pool_id=str(pool.id),
            amount_swept=0,
            new_balance=float(pool.balance),
            opay_reference="N/A",
            opay_phone=req.opay_phone,
            transaction_amount=req.transaction_amount,
            contributed_by="",
            timestamp=datetime.utcnow(),
        )

    # Generate mock OPay response
    opay = generate_opay_response(
        amount=req.amount,
        opay_phone=req.opay_phone,
        transaction_amount=req.transaction_amount,
        destination="pool",
    )

    # Update pool balance
    pool.balance = float(pool.balance) + req.amount
    pool.updated_at = now

    # Determine note
    if req.transaction_amount:
        note = "Passive sweep contribution"
    else:
        note = f"Scheduled {pool.contribution_frequency} contribution"

    # Record transaction
    transaction = Transaction(
        id=uuid.uuid4(),
        pool_id=pool_uuid,
        type="contribution",
        amount=req.amount,
        sender_id=user_id,
        destination="pool",
        opay_reference=opay["reference"],
        note=note,
        created_at=now,
    )
    db.add(transaction)
    db.commit()

    # Get user name for response
    user = db.query(User).filter(User.id == user_id).first()

    return ContributionResponse(
        message="Contribution successful",
        pool_id=str(pool.id),
        amount_swept=req.amount,
        new_balance=float(pool.balance),
        opay_reference=opay["reference"],
        opay_phone=req.opay_phone,
        transaction_amount=req.transaction_amount,
        contributed_by=user.full_name,
        timestamp=now,
    )


@router.get("/{pool_id}/contributions", response_model=ContributionHistoryResponse)
def get_contributions(
    pool_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    pool_uuid = uuid.UUID(pool_id)
    user_id = uuid.UUID(current_user["user_id"])

    pool = db.query(Pool).filter(Pool.id == pool_uuid).first()
    if not pool:
        raise HTTPException(status_code=404, detail="Pool not found")

    # Must be a group member to view contributions
    membership = db.query(GroupMember).filter(
        GroupMember.group_id == pool.group_id,
        GroupMember.user_id == user_id,
    ).first()
    if not membership:
        raise HTTPException(status_code=403, detail="You are not a member of this pool's group")

    # Fetch all contributions for this pool
    contributions = (
        db.query(Transaction, User)
        .join(User, Transaction.sender_id == User.id)
        .filter(
            Transaction.pool_id == pool_uuid,
            Transaction.type == "contribution",
        )
        .order_by(Transaction.created_at.desc())
        .all()
    )

    history = [
        ContributionHistoryItem(
            id=str(c.Transaction.id),
            amount=float(c.Transaction.amount),
            opay_reference=c.Transaction.opay_reference or "N/A",  # ← change this
            contributed_by_name=c.User.full_name,
            note=c.Transaction.note,
            created_at=c.Transaction.created_at,
        )
        for c in contributions
    ]

    return ContributionHistoryResponse(
        pool_id=str(pool.id),
        total_contributions=len(history),
        contributions=history,
    )
