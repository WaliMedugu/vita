# Group model - vitapool groups table

from sqlalchemy import Column, String, Numeric, DateTime, ForeignKey  # type: ignore
from sqlalchemy.dialects.postgresql import UUID  # type: ignore
from app.database import Base
import uuid


class Group(Base):
    __tablename__ = "groups"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    admin_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    spending_limit = Column(Numeric, nullable=False, default=15000)
    reserve_floor = Column(Numeric, nullable=False, default=3000)
    created_at = Column(DateTime(timezone=True), nullable=False)
