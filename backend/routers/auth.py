from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from schemas.user import UserCreate, UserResponse, UserLogin, Token
from utils.auth import hash_password, verify_password, create_access_token

router = APIRouter()

@router.post("/register", response_model=UserResponse, status_code=201)
def register(user: UserCreate, db: Session = Depends(get_db)):
    # Check if email already exists
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Hash password and create user
    new_user = User(
        email=user.email,
        name=user.name,
        hashed_password=hash_password(user.password)
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=Token)
def login(user: UserLogin, db: Session = Depends(get_db)):
    # Find user by email
    db_user = db.query(User).filter(User.email == user.email).first()

    # Check user exists and password is correct
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )

    # Create and return JWT token
    token = create_access_token(data={"sub": str(db_user.id)})
    return {"access_token": token, "token_type": "bearer"}