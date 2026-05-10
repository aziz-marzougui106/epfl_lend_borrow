# dependencies.py
from typing import Annotated
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from utils.auth import verify_token

# DB dependency
db_dependency = Annotated[Session, Depends(get_db)]

# OAuth2 scheme — tells FastAPI where to find the token
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    payload = verify_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = db.query(User).filter(
        User.id == payload.get("sub")
    ).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

# User dependency
user_dependency = Annotated[User, Depends(get_current_user)]