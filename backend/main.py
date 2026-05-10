from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routers import auth, items

# Create all tables automatically
Base.metadata.create_all(bind=engine)

app = FastAPI(title="LendNBorrow API", version="1.0.0")

# Allow Flutter app to talk to this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # restrict this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
#app.include_router(items.router, prefix="/items", tags=["Items"])
#app.include_router(agent.router, prefix="/agent", tags=["Agent"]) # later when we introduce the agent

@app.get("/")
def root():
    return {"message": "LendNBorrow API is running!"}