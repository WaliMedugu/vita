# Member model - group membership table

from sqlalchemy import Column, DateTime, ForeignKey, UniqueConstraint  # type: ignore
from sqlalchemy.dialects.postgresql import UUID  # type: ignore
from app.database import Base
import uuid


class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    joined_at = Column(DateTime(timezone=True), nullable=False)

    __table_args__ = (
        UniqueConstraint("group_id", "user_id", name="uq_group_members_group_user"),
    )
