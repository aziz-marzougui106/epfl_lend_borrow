from pydantic import BaseModel, EmailStr
from schemas.items import ItemBrand,ItemCategory,ItemCondition,ItemType

class PostMessageRequest(BaseModel):
    message: str
    is_first_message: bool
    category:ItemCategory
    condition:ItemCondition
    brand:ItemBrand
    type:ItemType
    price:float

class ChatResponse(BaseModel):
    reply:str
    done:bool