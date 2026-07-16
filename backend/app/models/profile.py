# Health profiles table - stores user medical info and emergency contacts

from sqlalchemy import Column, String, DateTime, ForeignKey  # type: ignore
from sqlalchemy.dialects.postgresql import UUID, ARRAY  # type: ignore
from app.database import Base
import uuid


class HealthProfile(Base):
    __tablename__ = "health_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    blood_type = Column(String, nullable=True)
    allergies = Column(ARRAY(String), nullable=True)
    conditions = Column(ARRAY(String), nullable=True)
    emergency_contact = Column(String, nullable=True)
    emergency_contact_2 = Column(String, nullable=True)
    pool_id = Column(UUID(as_uuid=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False)
