# SMS registration model - tracks Africa's Talking inbound registration flow state

from sqlalchemy import Column, String, DateTime  # type: ignore
from sqlalchemy.dialects.postgresql import UUID, JSONB  # type: ignore
from app.database import Base
import uuid


class SmsRegistration(Base):
    __tablename__ = "sms_registrations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    phone = Column(String, unique=True, nullable=False)
    stage = Column(String, nullable=False, default="start")
    partial_profile = Column(JSONB, nullable=False, default=dict)
    created_at = Column(DateTime(timezone=True), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False)
