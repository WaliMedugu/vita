# Profile routes - POST /profile, GET /profile/:id

from fastapi import APIRouter, Depends, HTTPException #type: ignore
from sqlalchemy.orm import Session #type: ignore
from app.database import get_db
from app.models.profile import HealthProfile
from app.models.user import User
from app.models.pool import Pool
from app.models.member import GroupMember
from app.schemas.profile import (
    CreateProfileRequest,
    UpdateProfileRequest,
    ProfileResponse,
    NFCProfileResponse,
)
from app.utils.auth import get_current_user
from datetime import datetime
import uuid

router = APIRouter()


@router.post("", response_model=ProfileResponse)
def create_profile(
    req: CreateProfileRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """
    Creates health profile for the logged-in user.
    One profile per user — returns 400 if profile already exists.
    """
    user_id = uuid.UUID(current_user["user_id"])
    now = datetime.utcnow()

    # Check profile doesn't already exist
    existing = db.query(HealthProfile).filter(
        HealthProfile.user_id == user_id
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail="Profile already exists. Use PATCH /profile to update."
        )

    # Validate pool_id if provided
    pool_uuid = None
    if req.pool_id:
        pool_uuid = uuid.UUID(req.pool_id)
        pool = db.query(Pool).filter(Pool.id == pool_uuid).first()
        if not pool:
            raise HTTPException(status_code=404, detail="Pool not found")

        # Must be a member of the pool's group
        membership = db.query(GroupMember).filter(
            GroupMember.group_id == pool.group_id,
            GroupMember.user_id == user_id,
        ).first()
        if not membership:
            raise HTTPException(
                status_code=403,
                detail="You are not a member of this pool's group"
            )

    profile = HealthProfile(
        id=uuid.uuid4(),
        user_id=user_id,
        blood_type=req.blood_type,
        allergies=req.allergies or [],
        conditions=req.conditions or [],
        emergency_contact=req.emergency_contact,
        emergency_contact_2=req.emergency_contact_2,
        pool_id=pool_uuid,
        created_at=now,
        updated_at=now,
    )
    db.add(profile)
    db.commit()
    db.refresh(profile)

    return ProfileResponse(
        id=str(profile.id),
        user_id=str(profile.user_id),
        blood_type=profile.blood_type,
        allergies=profile.allergies or [],
        conditions=profile.conditions or [],
        emergency_contact=profile.emergency_contact,
        emergency_contact_2=profile.emergency_contact_2,
        pool_id=str(profile.pool_id) if profile.pool_id else None,
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


@router.patch("", response_model=ProfileResponse)
def update_profile(
    req: UpdateProfileRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """
    Updates existing health profile for the logged-in user.
    Only provided fields are updated — null fields are ignored.
    """
    user_id = uuid.UUID(current_user["user_id"])
    now = datetime.utcnow()

    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == user_id
    ).first()
    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Profile not found. Use POST /profile to create one."
        )

    # Update only provided fields
    if req.blood_type is not None:
        profile.blood_type = req.blood_type
    if req.allergies is not None:
        profile.allergies = req.allergies
    if req.conditions is not None:
        profile.conditions = req.conditions
    if req.emergency_contact is not None:
        profile.emergency_contact = req.emergency_contact
    if req.emergency_contact_2 is not None:
        profile.emergency_contact_2 = req.emergency_contact_2

    # Validate and update pool_id if provided
    if req.pool_id is not None:
        pool_uuid = uuid.UUID(req.pool_id)
        pool = db.query(Pool).filter(Pool.id == pool_uuid).first()
        if not pool:
            raise HTTPException(status_code=404, detail="Pool not found")

        membership = db.query(GroupMember).filter(
            GroupMember.group_id == pool.group_id,
            GroupMember.user_id == user_id,
        ).first()
        if not membership:
            raise HTTPException(
                status_code=403,
                detail="You are not a member of this pool's group"
            )
        profile.pool_id = pool_uuid

    profile.updated_at = now
    db.commit()
    db.refresh(profile)

    return ProfileResponse(
        id=str(profile.id),
        user_id=str(profile.user_id),
        blood_type=profile.blood_type,
        allergies=profile.allergies or [],
        conditions=profile.conditions or [],
        emergency_contact=profile.emergency_contact,
        emergency_contact_2=profile.emergency_contact_2,
        pool_id=str(profile.pool_id) if profile.pool_id else None,
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


@router.get("/me", response_model=ProfileResponse)
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """
    Returns the logged-in user's health profile.
    Used by health_profile.dart to display and edit profile.
    """
    user_id = uuid.UUID(current_user["user_id"])

    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == user_id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    return ProfileResponse(
        id=str(profile.id),
        user_id=str(profile.user_id),
        blood_type=profile.blood_type,
        allergies=profile.allergies or [],
        conditions=profile.conditions or [],
        emergency_contact=profile.emergency_contact,
        emergency_contact_2=profile.emergency_contact_2,
        pool_id=str(profile.pool_id) if profile.pool_id else None,
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


@router.get("/nfc/{user_id}", response_model=NFCProfileResponse)
def get_nfc_profile(
    user_id: str,
    db: Session = Depends(get_db),
):
    """
    Public endpoint — no auth required.
    Returns profile in NFC card format.
    Called by bystander's phone after tapping card.
    Also used by nfc_write.dart to get data to write to card.
    """
    user_uuid = uuid.UUID(user_id)

    user = db.query(User).filter(User.id == user_uuid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == user_uuid
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Health profile not found")

    return NFCProfileResponse(
        name=user.full_name,
        blood_type=profile.blood_type,
        allergies=profile.allergies or [],
        conditions=profile.conditions or [],
        emergency_contact=profile.emergency_contact,
        emergency_contact_2=profile.emergency_contact_2,
        pool_id=str(profile.pool_id) if profile.pool_id else None,
    )
