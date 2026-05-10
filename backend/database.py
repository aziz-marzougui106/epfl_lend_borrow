#Instead of that long path Homebrew gave you, you can still use brew services to turn it on and off manually. 
# When you sit down to study, run: 
# brew services start postgresql@18 
# brew services stop postgresql@18

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency — used in every router
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()