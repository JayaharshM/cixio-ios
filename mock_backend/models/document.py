from datetime import datetime
from pydantic import BaseModel

class DocumentResponse(BaseModel):
    id: str
    name: str
    size: int
    type: str
    uploaded_at: datetime
