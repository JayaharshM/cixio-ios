from datetime import datetime
from pydantic import BaseModel


class Todo(BaseModel):
    id: str
    title: str
    description: str | None = None
    completed: bool
    due_date: datetime | None = None
    created_at: datetime


class CreateTodoRequest(BaseModel):
    title: str
    description: str | None = None
    due_date: datetime | None = None


class UpdateTodoRequest(BaseModel):
    title: str | None = None
    description: str | None = None
    due_date: datetime | None = None
