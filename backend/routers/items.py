from fastapi import APIRouter, HTTPException, status
from typing import List
from uuid import UUID

from database import db_dependency
from dependencies import user_dependency
from models.item import Item
from backend.schemas.items import ItemCreate, ItemUpdate, ItemResponse

router = APIRouter(prefix="/items", tags=["items"])


def _to_response(item: Item) -> ItemResponse:
    """Convert an Item ORM object to ItemResponse using the owner relationship."""
    return ItemResponse(
        id=item.id,
        title=item.title,
        description=item.description,
        price=item.price,
        category=item.category,
        type=item.type,
        image_url=item.image_url,
        owner_id=item.owner_id,
        owner_name=item.owner.name,  # resolved via relationship
    )


@router.get("/", response_model=List[ItemResponse])
def get_items(db: db_dependency):
    """Get all items — public, no auth required."""
    items = db.query(Item).all()
    return [_to_response(item) for item in items]

# Why is GET /items/my declared before GET /items/{item_id}?
# Because FastAPI reads routes top to bottom. If /{item_id} came first, a request to /items/my would be matched by it — FastAPI would try to parse "my" as a UUID, fail, and return a 422 error. By putting /my first, FastAPI matches it correctly before even looking at /{item_id}.
@router.get("/my", response_model=List[ItemResponse])
def get_my_items(db: db_dependency, current_user: user_dependency):
    """Get all items posted by the authenticated user."""
    items = db.query(Item).filter(Item.owner_id == current_user.id).all()
    return [_to_response(item) for item in items]


@router.get("/{item_id}", response_model=ItemResponse)
def get_item(item_id: UUID, db: db_dependency):
    """Get a single item by ID — public, no auth required."""
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return _to_response(item)


@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
def create_item(item_data: ItemCreate, db: db_dependency, current_user: user_dependency):
    """Create a new item. Requires authentication."""
    new_item = Item(
        title=item_data.title,
        description=item_data.description,
        price=item_data.price,
        category=item_data.category,
        type=item_data.type,
        image_url=item_data.image_url,
        owner_id=current_user.id,
    )
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return _to_response(new_item)


@router.patch("/{item_id}", response_model=ItemResponse)
def update_item(item_id: UUID, item_data: ItemUpdate, db: db_dependency, current_user: user_dependency):
    """Update an item. Only the owner can update."""
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    if item.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your item")

    for field, value in item_data.model_dump(exclude_unset=True).items():
        setattr(item, field, value)

    db.commit()
    db.refresh(item)
    return _to_response(item)


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: UUID, db: db_dependency, current_user: user_dependency):
    """Delete an item. Only the owner can delete."""
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    if item.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your item")

    db.delete(item)
    db.commit()