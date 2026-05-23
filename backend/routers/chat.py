from fastapi import APIRouter, HTTPException, status
from uuid import UUID
from dependencies import user_dependency,db_dependency
from schemas.chat import ChatResponse,PostMessageRequest
import anthropic
import os


router=APIRouter()
conversation_store: dict[UUID, list] = {}

SYSTEM_PROMPT = """
You are a helpful assistant for LendNBorrow, an EPFL student marketplace.
Your job is to help students post items they want to sell or lend.

When the user first describes their item, extract what you can and ask follow-up questions for what's missing. You need:
- Title
- Brand
- Category (electronics/books/sports/clothing/tools/furniture/kitchen/other)
- Condition (new/like_new/good/fair/poor)
- Type (sell or lend)
- Price in CHF (per day if lend)
- A rich description with all relevant details

Ask ONE question at a time. Be friendly and casual.

When you have ALL the information, output exactly SUMMARY_READY on its own line, then:
---
Title: ...
Brand: ...
Category: ...
Condition: ...
Type: ...
Price: ...
Description: ...
---
"""

client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
def _build_system_prompt(req: PostMessageRequest) -> str:
    return f"""
        You are a helpful assistant for LendNBorrow, an EPFL student marketplace app for EPFL students.

        The user is posting the following item with these fixed details already provided:
        - Category: {req.category.value}
        - Brand: {req.brand.value}
        - Condition: {req.condition.value}
        - Type: {req.type.value} ({"per day" if req.type.value == "lend" else "one-time sale"})
        - Price: CHF {req.price}

        Your ONLY job is to build a rich, detailed description of this item through conversation.
        The first message from the user is their initial description — extract what you can from it.
        Then ask follow-up questions ONE AT A TIME to fill in missing details relevant to this category.

        For example:
        - Electronics: model, year, specs, accessories included, any defects
        - Books: title, author, edition, which EPFL course, highlighting or notes inside
        - Clothing: size, how many times worn, any defects
        - Sports: size, age, any damage
        - Furniture: dimensions, material, any damage

        When you have enough detail to write a compelling listing, output exactly SUMMARY_READY on its own line followed by the description only — no other fields, just a rich natural paragraph.

        Keep responses SHORT and friendly. Never ask more than one question at a time.
        Speak casually — you're talking to a student.
        """
def _analyze(history: list, is_first_message: bool,postMessageRequest:PostMessageRequest) -> tuple[bool, str]:
    response = client.messages.create(
        model="claude-sonnet-4-5",
        max_tokens=1024,
        system=_build_system_prompt(postMessageRequest),
        messages=history  # ← the full conversation history
    )
    
    reply = response.content[0].text
    done = done = 'SUMMARY_READY' in reply
    reply = reply.replace('SUMMARY_READY','').strip()
    return (done, reply)



@router.post(path="/post",response_model=ChatResponse)
def get_message(current_user:user_dependency,postMessage:PostMessageRequest):
    history=conversation_store.get(current_user.id,[])
    history.append({"role": "user", "content": postMessage.message})
    conversation_store[current_user.id]=history
    status_code,toReturn=_analyze(history,postMessage.is_first_message,postMessage)#it must later be the return of a function where the agent process the description
    if(status_code==202 ):
        conversation_store.pop(current_user.id)
    else:
        history.append({"role": "assistant", "content": toReturn})
        conversation_store[current_user.id] = history  
    return ChatResponse(reply=toReturn,done=status_code==202)
    
    
    
