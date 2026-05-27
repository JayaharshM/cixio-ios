import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException

from models.todo import CreateTodoRequest, Todo, UpdateTodoRequest, TodoSection, CreateSectionRequest

router = APIRouter(prefix="/todos", tags=["todos"])

_sections: dict[str, TodoSection] = {}
_todos_by_section: dict[str, list[Todo]] = {}

@router.post("/sections")
async def create_section(request: CreateSectionRequest) -> TodoSection:
    section_id = str(uuid.uuid4())
    section = TodoSection(
        id=section_id,
        title=request.title,
        created_at=datetime.now(timezone.utc)
    )
    _sections[section_id] = section
    _todos_by_section[section_id] = []
    return section

@router.get("/sections")
async def get_sections() -> list[TodoSection]:
    return sorted(
        _sections.values(),
        key=lambda s: s.created_at,
        reverse=True
    )

@router.delete("/sections/{section_id}")
async def delete_section(section_id: str) -> dict[str, bool]:
    if section_id not in _sections:
        raise HTTPException(status_code=404, detail="Section not found")
    _sections.pop(section_id, None)
    _todos_by_section.pop(section_id, None)
    return {"deleted": True}

@router.post("/sections/{section_id}/toggle_pin")
async def toggle_pin_section(section_id: str) -> TodoSection:
    if section_id not in _sections:
        raise HTTPException(status_code=404, detail="Section not found")
    section = _sections[section_id]
    section.is_pinned = not section.is_pinned
    return section

@router.get("/sections/{section_id}/todos")
async def get_todos(section_id: str, completed: bool | None = None) -> list[Todo]:
    if section_id not in _sections:
        raise HTTPException(status_code=404, detail="Section not found")
    todos = _todos_by_section.get(section_id, [])
    if completed is not None:
        todos = [todo for todo in todos if todo.completed == completed]
    return todos

@router.post("/sections/{section_id}/todos")
async def create_todo(section_id: str, request: CreateTodoRequest) -> Todo:
    if section_id not in _sections:
        raise HTTPException(status_code=404, detail="Section not found")
    todo_id = str(uuid.uuid4())
    todo = Todo(
        id=todo_id,
        title=request.title,
        description=request.description,
        completed=False,
        due_date=request.due_date,
        created_at=datetime.now(timezone.utc),
    )
    _todos_by_section[section_id].append(todo)
    return todo

def _find_todo(todo_id: str) -> tuple[str, Todo, int] | None:
    for s_id, t_list in _todos_by_section.items():
        for idx, t in enumerate(t_list):
            if t.id == todo_id:
                return (s_id, t, idx)
    return None

@router.put("/{todo_id}")
async def update_todo(todo_id: str, request: UpdateTodoRequest) -> Todo:
    found = _find_todo(todo_id)
    if not found:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    _, todo, _ = found
    if request.title is not None:
        todo.title = request.title
    if request.description is not None:
        todo.description = request.description
    if request.due_date is not None:
        todo.due_date = request.due_date
    return todo

@router.put("/{todo_id}/complete")
async def toggle_todo_complete(todo_id: str) -> Todo:
    found = _find_todo(todo_id)
    if not found:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    _, todo, _ = found
    todo.completed = not todo.completed
    return todo

@router.post("/{todo_id}/toggle_pin")
async def toggle_todo_pin(todo_id: str) -> Todo:
    found = _find_todo(todo_id)
    if not found:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    _, todo, _ = found
    todo.is_pinned = not todo.is_pinned
    return todo

@router.delete("/{todo_id}")
async def delete_todo(todo_id: str) -> dict[str, str]:
    found = _find_todo(todo_id)
    if not found:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    s_id, _, idx = found
    _todos_by_section[s_id].pop(idx)
    return {"message": "Todo deleted"}
