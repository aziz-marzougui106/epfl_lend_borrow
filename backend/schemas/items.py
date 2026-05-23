from pydantic import BaseModel, UUID4
from typing import Optional
from enum import Enum


class ItemType(str, Enum):
    lend = "lend"
    sell = "sell"

class ItemBrand(str,Enum):#Spot on. If you omit the str inheritance, Python treats the enum members as objects, not strings.
    sony="sony"
    apple="apple"
    microsoft="microsoft"
    google="google"
class ItemCategory(str, Enum):
    electronics = "electronics"
    books = "books"
    sports = "sports"
    clothing = "clothing"
    tools = "tools"
    furniture = "furniture"
    kitchen = "kitchen"
    other = "other"

class ItemCondition(str,Enum):
    new="new"
    like_new="like_new"
    good="good"
    fair="fair"
    poor="poor"

class ItemCreate(BaseModel):
    title: str
    brand: str
    description: str
    condition:ItemCondition
    price: float
    category: ItemCategory
    type: ItemType
    image_url: Optional[str] = None


class ItemUpdate(BaseModel):
    title: Optional[str] = None
    brand: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    category: Optional[ItemCategory] = None
    type: Optional[ItemType] = None
    image_url: Optional[str] = None


class ItemResponse(BaseModel):
    id: UUID4
    title: str
    brand: ItemBrand
    description: str
    condition: ItemCondition
    price: float
    category: ItemCategory        # String in the model, not an Enum column
    type: ItemType
    image_url: Optional[str]
    owner_id: UUID4
    owner_name: str      # resolved via item.owner relationship  # joined from User

    class Config:
        from_attributes = True