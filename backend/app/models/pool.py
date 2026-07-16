from sqlalchemy import Column, String, Numeric, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base
import uuid


class Pool(Base):
    __tablename__ = "pool"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"), unique=True, nullable=False)
    balance = Column(Numeric, nullable=False, default=0)
    sweep_amount = Column(Numeric, nullable=False, default=100)
    min_wallet_threshold = Column(Numeric, nullable=False, default=500)
    contribution_mode = Column(String, nullable=False, default="passive")
    contribution_frequency = Column(String, nullable=True)
    scheduled_contribution_amount = Column(Numeric, nullable=True)
    pending_mode_change = Column(String, nullable=True)
    pending_frequency_change = Column(String, nullable=True)
    pending_amount_change = Column(Numeric, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False)