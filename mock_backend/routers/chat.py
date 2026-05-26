import asyncio
import json
import uuid
from datetime import datetime, timezone

import httpx
from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse

from models.chat import ChatMessage, ChatSession, SendMessageRequest

router = APIRouter(prefix="/chat", tags=["chat"])

sessions: dict[str, ChatSession] = {}
messages_by_session: dict[str, list[ChatMessage]] = {}


@router.post("/sessions")
async def create_session() -> ChatSession:
    session_id = str(uuid.uuid4())
    session = ChatSession(
        id=session_id,
        title="SmartHub workspace",
        created_at=datetime.now(timezone.utc),
    )
    welcome_message = ChatMessage(
        id=str(uuid.uuid4()),
        role="assistant",
        content=(
            "Welcome back to your workspace. The environment is initialized. "
            "How can we advance your current project today?"
        ),
        timestamp=datetime.now(timezone.utc),
    )

    sessions[session_id] = session
    messages_by_session[session_id] = [welcome_message]
    return session


@router.get("/sessions")
async def get_sessions() -> list[ChatSession]:
    return sorted(
        sessions.values(),
        key=lambda session: session.created_at,
        reverse=True,
    )


@router.delete("/sessions/{session_id}")
async def delete_session(session_id: str) -> dict[str, bool]:
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")

    sessions.pop(session_id, None)
    messages_by_session.pop(session_id, None)
    return {"deleted": True}


@router.post("/sessions/{session_id}/toggle_pin")
async def toggle_pin_session(session_id: str) -> ChatSession:
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = sessions[session_id]
    session.is_pinned = not session.is_pinned
    return session


@router.post("/sessions/{session_id}/messages")
async def send_message(
    session_id: str,
    request: SendMessageRequest,
) -> StreamingResponse:
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")

    content = request.content.strip()
    if not content:
        raise HTTPException(status_code=400, detail="Message content is required")

    user_message = ChatMessage(
        id=str(uuid.uuid4()),
        role="user",
        content=content,
        timestamp=datetime.now(timezone.utc),
    )
    messages_by_session[session_id].append(user_message)
    sessions[session_id].title = _title_from_message(content)

    async def event_stream():
        full_response = ""
        
        # We build a simple history string for the prompt
        # Alternatively, Ollama's /api/chat endpoint is better for history, 
        # but we use /api/generate as requested.
        history_prompt = ""
        for msg in messages_by_session[session_id][:-1]: # exclude the one we just added
            history_prompt += f"{msg.role.capitalize()}: {msg.content}\n"
        history_prompt += f"User: {content}\nAssistant: "

        payload = {
            "model": "qwen2.5:3b",
            "prompt": history_prompt,
            "stream": True
        }

        try:
            async with httpx.AsyncClient() as client:
                async with client.stream(
                    "POST", 
                    "http://192.168.1.40:11434/api/generate", 
                    json=payload, 
                    timeout=60.0
                ) as response:
                    async for line in response.aiter_lines():
                        if not line:
                            continue
                        try:
                            data = json.loads(line)
                            token = data.get("response", "")
                            full_response += token
                            yield f"data: {json.dumps({'token': token})}\n\n"
                            
                            if data.get("done"):
                                break
                        except json.JSONDecodeError:
                            pass
        except Exception as e:
            error_msg = f"\n[Error connecting to AI: {str(e)}]"
            full_response += error_msg
            yield f"data: {json.dumps({'token': error_msg})}\n\n"

        assistant_message = ChatMessage(
            id=str(uuid.uuid4()),
            role="assistant",
            content=full_response,
            timestamp=datetime.now(timezone.utc),
        )
        messages_by_session[session_id].append(assistant_message)
        yield f"data: {json.dumps({'done': True})}\n\n"

    return StreamingResponse(event_stream(), media_type="text/event-stream")


@router.get("/sessions/{session_id}/messages")
async def get_messages(session_id: str) -> list[ChatMessage]:
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")

    return messages_by_session.get(session_id, [])


def _title_from_message(content: str) -> str:
    words = content.split()
    title = " ".join(words[:5]).strip()
    return title if title else "SmartHub workspace"
