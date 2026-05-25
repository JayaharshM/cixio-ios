import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException

from models.todo import CreateTodoRequest, Todo, UpdateTodoRequest

router = APIRouter(prefix="/todos", tags=["todos"])

# In-memory storage for todos (replace with database in production)
_todos: dict[str, Todo] = {}


@router.get("")
async def get_todos(completed: bool | None = None) -> list[Todo]:
    """Get all todos, optionally filtered by completion status."""
    todos = list(_todos.values())
    if completed is not None:
        todos = [todo for todo in todos if todo.completed == completed]
    return todos


@router.post("")
async def create_todo(request: CreateTodoRequest) -> Todo:
    """Create a new todo."""
    todo_id = str(uuid.uuid4())
    todo = Todo(
        id=todo_id,
        title=request.title,
        description=request.description,
        completed=False,
        due_date=request.due_date,
        created_at=datetime.now(timezone.utc),
    )
    _todos[todo_id] = todo
    return todo


@router.put("/{todo_id}")
async def update_todo(todo_id: str, request: UpdateTodoRequest) -> Todo:
    """Update a todo's title, description, or due date."""
    todo = _todos.get(todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")

    if request.title is not None:
        todo.title = request.title
    if request.description is not None:
        todo.description = request.description
    if request.due_date is not None:
        todo.due_date = request.due_date

    _todos[todo_id] = todo
    return todo


@router.put("/{todo_id}/complete")
async def toggle_todo_complete(todo_id: str) -> Todo:
    """Mark a todo as complete or incomplete."""
    todo = _todos.get(todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")

    todo.completed = not todo.completed
    _todos[todo_id] = todo
    return todo


@router.post("/{todo_id}/toggle_pin")
async def toggle_todo_pin(todo_id: str) -> Todo:
    """Pin or unpin a todo."""
    todo = _todos.get(todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")

    todo.is_pinned = not todo.is_pinned
    _todos[todo_id] = todo
    return todo


@router.delete("/{todo_id}")
async def delete_todo(todo_id: str) -> dict[str, str]:
    """Delete a todo."""
    if todo_id not in _todos:
        raise HTTPException(status_code=404, detail="Todo not found")

    del _todos[todo_id]
    return {"message": "Todo deleted"}
