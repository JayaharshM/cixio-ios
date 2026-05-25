import asyncio
import json
import uuid
from datetime import datetime, timezone

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

    ai_response = _mock_ai_response(content)

    async def event_stream():
        full_response = ""
        for token in _tokens(ai_response):
            full_response += token
            yield f"data: {json.dumps({'token': token})}\n\n"
            await asyncio.sleep(0.05)

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


def _tokens(response: str) -> list[str]:
    parts = response.split(" ")
    return [
        f"{part} " if index < len(parts) - 1 else part
        for index, part in enumerate(parts)
    ]


def _mock_ai_response(prompt: str) -> str:
    prompt_lower = prompt.lower()

    if "react" in prompt_lower or "component" in prompt_lower:
        return (
            "Certainly. Here is a modern React component utilizing hooks for "
            "data fetching, loading, and error states.\n\n"
            "```DataFetcher.tsx\n"
            "import React, { useEffect, useState } from 'react';\n\n"
            "type ApiState<T> = {\n"
            "  data: T | null;\n"
            "  loading: boolean;\n"
            "  error: string | null;\n"
            "};\n\n"
            "export default function DataFetcher() {\n"
            "  const [state, setState] = useState<ApiState<unknown>>({\n"
            "    data: null,\n"
            "    loading: true,\n"
            "    error: null,\n"
            "  });\n\n"
            "  useEffect(() => {\n"
            "    async function loadData() {\n"
            "      try {\n"
            "        const response = await fetch('/api/data');\n"
            "        const data = await response.json();\n"
            "        setState({ data, loading: false, error: null });\n"
            "      } catch (error) {\n"
            "        setState({ data: null, loading: false, error: 'Unable to load data' });\n"
            "      }\n"
            "    }\n\n"
            "    loadData();\n"
            "  }, []);\n\n"
            "  if (state.loading) return <p>Loading...</p>;\n"
            "  if (state.error) return <p>{state.error}</p>;\n"
            "  return <pre>{JSON.stringify(state.data, null, 2)}</pre>;\n"
            "}\n"
            "```\n\n"
            "This keeps request state localized, avoids stale updates, and makes "
            "the loading and error branches explicit for the user."
        )

    if "plan" in prompt_lower or "workspace" in prompt_lower:
        return (
            "A practical next step is to split the workspace into three tracks: "
            "implementation, verification, and polish. Start with the smallest "
            "end-to-end workflow, validate it with one automated check, then "
            "tighten the interaction details that users will touch repeatedly."
        )

    return (
        "I can help with that. I would start by clarifying the intended outcome, "
        "then identify the smallest change that proves the workflow end to end. "
        "From there, we can iterate on edge cases, performance, and interface "
        "polish without losing momentum."
    )
