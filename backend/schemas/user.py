from pydantic import BaseModel, EmailStr
from uuid import UUID
from datetime import datetime

# What we receive when user REGISTERS
class UserCreate(BaseModel):
    email: EmailStr        # validates it's a real email format
    name: str
    password: str          # plain text — we hash it before storing

# What we send BACK to Flutter (never include password!)
class UserResponse(BaseModel):
    id: UUID
    email: str
    name: str
    created_at: datetime

    class Config:
        from_attributes = True  # allows SQLAlchemy model → Pydantic schema

# What we receive when user LOGS IN
class UserLogin(BaseModel):
    email: EmailStr
    password: str

# What we send back after successful login
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"