# User model - users table
from sqlalchemy import Column, String, DateTime #type: ignore
from sqlalchemy.dialects.postgresql import UUID  #type: ignore
from sqlalchemy.sql import func #type: ignore
import uuid
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id            = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email         = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name     = Column(String, nullable=False)
    phone         = Column(String, nullable=False)
    created_at    = Column(DateTime(timezone=True), server_default=func.now())