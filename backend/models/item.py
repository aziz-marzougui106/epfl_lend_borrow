from sqlalchemy import Column, String, Float, DateTime, Enum, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base
import uuid
import enum
from datetime import datetime,timezone

class ItemType(str, enum.Enum):
    sell = "sell"
    lend = "lend"

class Item(Base):
    __tablename__ = "items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String, nullable=False)
    brand= Column(String,nullable=False)
    description = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    category = Column(String, nullable=False)
    type = Column(Enum(ItemType), nullable=False)
    image_url = Column(String, nullable=True)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.now(timezone.utc))

    # Relationship — lets you do item.owner to get the user
    owner = relationship("User", backref="items") # user.items  → go from user to their items (added by backref)