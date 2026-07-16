# Emergency routes - POST /emergency/trigger, POST /emergency/:id/pay

from fastapi import APIRouter, Depends, HTTPException, Query #type: ignore
from sqlalchemy.orm import Session #type: ignore
from app.database import get_db, supabase
from app.models.emergency import Emergency
from app.models.pool import Pool
from app.models.group import Group
from app.models.member import GroupMember
from app.models.transaction import Transaction
from app.models.user import User
from app.models.profile import HealthProfile #type: ignore
from app.schemas.emergency import (
    TriggerEmergencyRequest,
    ReleaseRequest,
    EmergencyResponse,
    EmergencyContactView,
    ReleaseResponse,
    EmergencyReceipt,
    ReceiptItem,
)
from app.utils.auth import get_current_user
from app.utils.emergency_token import generate_emergency_token, verify_emergency_token
from app.utils.opay_mock import generate_opay_response
from app.services.sms_service import send_emergency_sms, send_emergency_closed_sms
from app.config import settings
from datetime import datetime
from typing import Optional
import uuid

router = APIRouter()

@router.post("/trigger", response_model=EmergencyResponse)
def trigger_emergency(
    req: TriggerEmergencyRequest,
    db: Session = Depends(get_db),
):
    """
    Public endpoint — no auth required.
    Bystander taps NFC card, this fires with patient user_id + GPS.
    """
    now = datetime.utcnow()
    patient_uuid = uuid.UUID(req.user_id)

    # Get patient
    patient = db.query(User).filter(User.id == patient_uuid).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    # Get patient health profile for emergency contact
    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == patient_uuid
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Health profile not found for this patient")

    # Get all pools patient belongs to — use first pool for emergency
    memberships = db.query(GroupMember).filter(
        GroupMember.user_id == patient_uuid
    ).all()
    if not memberships:
        raise HTTPException(status_code=404, detail="Patient is not a member of any VitaPool group")

    # Use the pool linked to the health profile, or first available
    pool_id = profile.pool_id
    if not pool_id:
        # Fall back to first group membership
        first_membership = memberships[0]
        pool = db.query(Pool).filter(Pool.group_id == first_membership.group_id).first()
        if not pool:
            raise HTTPException(status_code=404, detail="No pool found for patient")
        pool_id = pool.id
    else:
        pool = db.query(Pool).filter(Pool.id == pool_id).first()
        if not pool:
            raise HTTPException(status_code=404, detail="Pool not found")

    # Check no active emergency already exists for this pool
    existing = db.query(Emergency).filter(
        Emergency.pool_id == pool.id,
        Emergency.status == "active"
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail="There is already an active emergency for this pool"
        )

    # Create emergency
    emergency = Emergency(
        id=uuid.uuid4(),
        pool_id=pool.id,
        patient_id=patient_uuid,
        triggered_by=None,  # anonymous bystander
        status="active",
        lat=req.lat,
        lng=req.lng,
        total_spent=0,
        created_at=now,
    )
    db.add(emergency)
    db.commit()
    db.refresh(emergency)

    # Generate emergency-contact token
    emergency_contact = profile.emergency_contact
    if emergency_contact:
        token = generate_emergency_token(str(emergency.id), emergency_contact)
        emergency_link = f"{settings.FRONTEND_URL}/emergency/{emergency.id}?token={token}"

        # Send SMS to emergency contact
        send_emergency_sms(
            phone=emergency_contact,
            patient_name=patient.full_name,
            emergency_link=emergency_link,
            lat=req.lat,
            lng=req.lng,
        )

        # Send to backup contact if exists
        if profile.emergency_contact_2:
            token_2 = generate_emergency_token(str(emergency.id), profile.emergency_contact_2)
            emergency_link_2 = f"{settings.FRONTEND_URL}/emergency/{emergency.id}?token={token_2}"
            send_emergency_sms(
                phone=profile.emergency_contact_2,
                patient_name=patient.full_name,
                emergency_link=emergency_link_2,
                lat=req.lat,
                lng=req.lng,
            )

    # Broadcast emergency to group via Supabase realtime
    try:
        supabase.table("emergencies").update(
            {"status": "active"}
        ).eq("id", str(emergency.id)).execute()
    except Exception as e:
        print(f"[Realtime] Failed to broadcast emergency: {e}")

    return EmergencyResponse(
        id=str(emergency.id),
        pool_id=str(emergency.pool_id),
        patient_id=str(emergency.patient_id),
        patient_name=patient.full_name,
        status=emergency.status,
        lat=float(emergency.lat),
        lng=float(emergency.lng),
        total_spent=float(emergency.total_spent),
        created_at=emergency.created_at,
    )


@router.get("/{emergency_id}", response_model=EmergencyContactView)
def get_emergency(
    emergency_id: str,
    token: str = Query(..., description="One-time emergency access token from SMS link"),
    db: Session = Depends(get_db),
):
    """
    Public endpoint — validated by one-time token from SMS link.
    Sister opens this to see emergency details and pool balance.
    """
    emergency_uuid = uuid.UUID(emergency_id)

    # Get emergency
    emergency = db.query(Emergency).filter(Emergency.id == emergency_uuid).first()
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")

    # Verify token
    try:
        verify_emergency_token(token, emergency_id)
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))

    # Emergency must be active
    if emergency.status == "closed":
        raise HTTPException(status_code=400, detail="This emergency has been closed")

    # Get patient details
    patient = db.query(User).filter(User.id == emergency.patient_id).first()
    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == emergency.patient_id
    ).first()

    # Get all pools patient belongs to with balances
    memberships = db.query(GroupMember).filter(
        GroupMember.user_id == emergency.patient_id
    ).all()

    pools = []
    for membership in memberships:
        pool = db.query(Pool).filter(Pool.group_id == membership.group_id).first()
        if pool:
            pools.append({
                "pool_id": str(pool.id),
                "balance": float(pool.balance),
                "reserve_floor": float(
                    db.query(Group).filter(Group.id == pool.group_id).first().reserve_floor
                    if db.query(Group).filter(Group.id == pool.group_id).first() else 3000
                ),
            })

    return EmergencyContactView(
        emergency_id=str(emergency.id),
        patient_name=patient.full_name if patient else "Unknown",
        patient_blood_type=profile.blood_type if profile else None,
        patient_allergies=profile.allergies if profile else [],
        patient_conditions=profile.conditions if profile else [],
        status=emergency.status,
        lat=float(emergency.lat),
        lng=float(emergency.lng),
        total_spent=float(emergency.total_spent),
        pools=pools,
        triggered_at=emergency.created_at,
    )


# ── 3. RELEASE FUNDS ─────────────────────────────────────────────────────────
@router.post("/{emergency_id}/release", response_model=ReleaseResponse)
def release_funds(
    emergency_id: str,
    req: ReleaseRequest,
    token: str = Query(..., description="One-time emergency access token"),
    db: Session = Depends(get_db),
):
    """
    Public endpoint — validated by one-time token.
    Sister releases funds from the pool for the emergency.
    """
    emergency_uuid = uuid.UUID(emergency_id)
    now = datetime.utcnow()

    # Get emergency
    emergency = db.query(Emergency).filter(Emergency.id == emergency_uuid).first()
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")

    # Verify token
    try:
        verify_emergency_token(token, emergency_id)
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))

    # Emergency must be active
    if emergency.status != "active":
        raise HTTPException(status_code=400, detail="Emergency is not active")

    destination = "bystander"

    # Validate amount
    if req.amount <= 0:
        raise HTTPException(status_code=400, detail="Release amount must be greater than zero")

    # Get pool
    pool = db.query(Pool).filter(Pool.id == emergency.pool_id).first()
    if not pool:
        raise HTTPException(status_code=404, detail="Pool not found")

    # Get group for reserve floor
    from app.models.group import Group
    group = db.query(Group).filter(Group.id == pool.group_id).first()
    reserve_floor = float(group.reserve_floor) if group else 3000

    # Enforce reserve floor
    available = float(pool.balance) - reserve_floor
    if available <= 0:
        raise HTTPException(
            status_code=400,
            detail=f"Pool balance is at or below the reserve floor of N{reserve_floor}. No funds can be released."
        )
    if req.amount > available:
        raise HTTPException(
            status_code=400,
            detail=f"Amount exceeds available balance. Maximum releasable: N{available:.2f} (N{reserve_floor} reserve floor protected)"
        )

    # Generate OPay reference
    opay = generate_opay_response(
        amount=req.amount,
        opay_phone="emergency_release",
        destination=destination,
    )

    # Deduct from pool
    pool.balance = float(pool.balance) - req.amount
    pool.updated_at = now

    # Update emergency total spent
    emergency.total_spent = float(emergency.total_spent) + req.amount

    # Record transaction
    transaction = Transaction(
        id=uuid.uuid4(),
        pool_id=pool.id,
        emergency_id=emergency_uuid,
        type="emergency_release",
        amount=req.amount,
        destination=destination,
        opay_reference=opay["reference"],
        note=req.note or f"Emergency release to {destination}",
        created_at=now,
    )
    db.add(transaction)
    db.commit()

    return ReleaseResponse(
        message=f"N{req.amount:.2f} released to bystander",
        emergency_id=str(emergency.id),
        amount_released=req.amount,
        destination=destination,
        new_pool_balance=float(pool.balance),
        new_total_spent=float(emergency.total_spent),
        opay_reference=opay["reference"],
        timestamp=now,
    )


# ── 4. CLOSE EMERGENCY ────────────────────────────────────────────────────────
@router.post("/{emergency_id}/close")
def close_emergency(
    emergency_id: str,
    token: str = Query(..., description="One-time emergency access token"),
    db: Session = Depends(get_db),
):
    """
    Public endpoint — validated by one-time token.
    Sister closes the emergency when treatment is complete.
    """
    emergency_uuid = uuid.UUID(emergency_id)
    now = datetime.utcnow()

    emergency = db.query(Emergency).filter(Emergency.id == emergency_uuid).first()
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")

    # Verify token
    try:
        verify_emergency_token(token, emergency_id)
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))

    if emergency.status != "active":
        raise HTTPException(status_code=400, detail="Emergency is already closed")

    # Close emergency
    emergency.status = "closed"
    emergency.closed_at = now
    db.commit()

    # Get pool balance for SMS
    pool = db.query(Pool).filter(Pool.id == emergency.pool_id).first()
    patient = db.query(User).filter(User.id == emergency.patient_id).first()
    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == emergency.patient_id
    ).first()

    # Send SMS to emergency contacts
    if profile and profile.emergency_contact:
        send_emergency_closed_sms(
            phone=profile.emergency_contact,
            patient_name=patient.full_name if patient else "Patient",
            total_spent=float(emergency.total_spent),
            remaining_balance=float(pool.balance) if pool else 0,
        )

    return {
        "message": "Emergency closed",
        "emergency_id": str(emergency.id),
        "total_spent": float(emergency.total_spent),
        "closed_at": now.isoformat(),
    }


# ── 5. RECEIPT ────────────────────────────────────────────────────────────────
@router.get("/{emergency_id}/receipt", response_model=EmergencyReceipt)
def get_receipt(
    emergency_id: str,
    token: str = Query(..., description="One-time emergency access token"),
    db: Session = Depends(get_db),
):
    """
    Public endpoint — validated by one-time token.
    Returns full receipt of all payments made during emergency.
    """
    emergency_uuid = uuid.UUID(emergency_id)

    emergency = db.query(Emergency).filter(Emergency.id == emergency_uuid).first()
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")

    # Verify token
    try:
        verify_emergency_token(token, emergency_id)
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))

    # Get patient
    patient = db.query(User).filter(User.id == emergency.patient_id).first()

    # Get pool + group for reserve floor
    pool = db.query(Pool).filter(Pool.id == emergency.pool_id).first()
    from app.models.group import Group
    group = db.query(Group).filter(Group.id == pool.group_id).first() if pool else None
    reserve_floor = float(group.reserve_floor) if group else 3000

    # Get all payments for this emergency
    payments = db.query(Transaction).filter(
        Transaction.emergency_id == emergency_uuid,
        Transaction.type == "emergency_release",
    ).order_by(Transaction.created_at.asc()).all()

    receipt_items = [
        ReceiptItem(
            amount=float(p.amount),
            destination=p.destination,
            opay_reference=p.opay_reference or "N/A",
            note=p.note or "",
            timestamp=p.created_at,
        )
        for p in payments
    ]

    return EmergencyReceipt(
        emergency_id=str(emergency.id),
        patient_name=patient.full_name if patient else "Unknown",
        status=emergency.status,
        triggered_at=emergency.created_at,
        closed_at=emergency.closed_at,
        total_spent=float(emergency.total_spent),
        remaining_balance=float(pool.balance) if pool else 0,
        reserve_floor=reserve_floor,
        payments=receipt_items,
    )
