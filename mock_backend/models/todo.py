from datetime import datetime
from pydantic import BaseModel


class Todo(BaseModel):
    id: str
    title: str
    description: str | None = None
    completed: bool
    due_date: datetime | None = None
    created_at: datetime
    is_pinned: bool = False


class CreateTodoRequest(BaseModel):
    title: str
    description: str | None = None
    due_date: datetime | None = None


class TodoSection(BaseModel):
    id: str
    title: str
    created_at: datetime
    is_pinned: bool = False

class CreateSectionRequest(BaseModel):
    title: str

class UpdateTodoRequest(BaseModel):
    title: str | None = None
    description: str | None = None
    due_date: datetime | None = None
