# Transaction model - all fund movements

from sqlalchemy import Column, String, Numeric, DateTime, ForeignKey  # type: ignore
from sqlalchemy.dialects.postgresql import UUID  # type: ignore
from app.database import Base
import uuid


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pool_id = Column(UUID(as_uuid=True), ForeignKey("pool.id"), nullable=True)
    emergency_id = Column(UUID(as_uuid=True), nullable=True)
    type = Column(String, nullable=False)
    amount = Column(Numeric, nullable=False)
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    recipient_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    destination = Column(String, nullable=False, default="pool")
    note = Column(String, nullable=False, default="")
    opay_reference = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False)
