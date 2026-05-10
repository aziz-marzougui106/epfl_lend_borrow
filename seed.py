# seed.py — run this once to populate the database
from backend.database import SessionLocal, engine, Base
from backend.models.user import User
from backend.models.item import Item, ItemType
from backend.utils.auth import hash_password
import uuid

Base.metadata.create_all(bind=engine)

db = SessionLocal()

# guard against duplicate seeding
existing = db.query(User).first()
if existing:
    print("⚠️ Database already seeded, skipping.")
    db.close()
    exit()
db = SessionLocal()

# ── Create mock users ──────────────────────────────────────────
users = [
    User(
        id=uuid.uuid4(),
        email="ahmed.k@epfl.ch",
        name="Ahmed K.",
        hashed_password=hash_password("password123"),
    ),
    User(
        id=uuid.uuid4(),
        email="sara.m@epfl.ch",
        name="Sara M.",
        hashed_password=hash_password("password123"),
    ),
    User(
        id=uuid.uuid4(),
        email="lucas.b@epfl.ch",
        name="Lucas B.",
        hashed_password=hash_password("password123"),
    ),
]

db.add_all(users)
db.commit()

# ── Create mock items ──────────────────────────────────────────
items = [
    Item(
        title='MacBook Pro 16"',
        description="Barely used MacBook Pro 16-inch. M1 Max, 32GB RAM, 1TB SSD. Perfect for coding and design projects. Comes with original charger and box.",
        price=1899.00,
        category="Electronics",
        type=ItemType.sell,
        image_url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8",
        owner_id=users[0].id,
    ),
    Item(
        title="Calculus Early Transcendentals",
        description="Textbook for MATH-101. Some highlighting in chapters 3-5 but overall great condition. Edition 8.",
        price=45.00,
        category="Books",
        type=ItemType.sell,
        owner_id=users[1].id,
    ),
    Item(
        title="Ergonomic Desk Chair",
        description="Herman Miller Aeron chair, size B. Excellent for long study sessions. Available for lending by the semester.",
        price=30.00,
        category="Furniture",
        type=ItemType.lend,
        image_url="https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1",
        owner_id=users[2].id,
    ),
    Item(
        title="Sony WH-1000XM4",
        description="Noise cancelling headphones in perfect condition. Great for studying in the library. Box and all accessories included.",
        price=15.00,
        category="Electronics",
        type=ItemType.lend,
        image_url="https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb",
        owner_id=users[0].id,
    ),
    Item(
        title="EPFL Hoodie",
        description="Size M. Official EPFL merchandise. Very warm and comfortable. Worn only a few times.",
        price=30.00,
        category="Clothing",
        type=ItemType.sell,
        image_url="https://images.unsplash.com/photo-1556821840-3a63f95609a7",
        owner_id=users[1].id,
    ),
    Item(
        title="Scientific Calculator TI-84",
        description="Texas Instruments TI-84 Plus. Required for several EPFL courses. Works perfectly, battery recently replaced.",
        price=5.00,
        category="Electronics",
        type=ItemType.lend,
        owner_id=users[2].id,
    ),
]

db.add_all(items)
db.commit()
db.close()

print("✅ Database seeded successfully!")