from datetime import datetime
from pydantic import BaseModel


class ChatSession(BaseModel):
    id: str
    title: str
    created_at: datetime


class ChatMessage(BaseModel):
    id: str
    role: str
    content: str
    timestamp: datetime


class SendMessageRequest(BaseModel):
    content: str


class AuthRequest(BaseModel):
    email: str
    password: str


class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
