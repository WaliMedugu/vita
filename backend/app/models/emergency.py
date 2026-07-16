# Emergency model - emergency events table

from sqlalchemy import Column, String, Numeric, DateTime, ForeignKey  # type: ignore
from sqlalchemy.dialects.postgresql import UUID  # type: ignore
from app.database import Base
import uuid


class Emergency(Base):
    __tablename__ = "emergencies"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pool_id = Column(UUID(as_uuid=True), ForeignKey("pool.id"), nullable=True)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    triggered_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    status = Column(String, nullable=False, default="active")
    lat = Column(Numeric, nullable=True)
    lng = Column(Numeric, nullable=True)
    total_spent = Column(Numeric, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), nullable=False)
    closed_at = Column(DateTime(timezone=True), nullable=True)
