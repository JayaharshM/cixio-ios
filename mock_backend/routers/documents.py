import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, UploadFile, File

from models.document import DocumentResponse

router = APIRouter(prefix="/documents", tags=["documents"])

# In-memory storage for documents
_documents: dict[str, DocumentResponse] = {}

@router.get("")
async def get_documents() -> list[DocumentResponse]:
    """List user's documents."""
    return list(_documents.values())

@router.post("/upload")
async def upload_document(file: UploadFile = File(...)) -> DocumentResponse:
    """Upload file (multipart)."""
    doc_id = str(uuid.uuid4())
    
    # Optional: Read file to get accurate size if needed
    file.file.seek(0, 2)
    file_size = file.file.tell()
    file.file.seek(0)
    
    doc = DocumentResponse(
        id=doc_id,
        name=file.filename or "unknown",
        size=file_size,
        type=file.content_type or "application/octet-stream",
        uploaded_at=datetime.now(timezone.utc)
    )
    _documents[doc_id] = doc
    return doc

@router.delete("/{doc_id}")
async def delete_document(doc_id: str) -> dict[str, str]:
    """Delete file + vectors."""
    if doc_id not in _documents:
        raise HTTPException(status_code=404, detail="Document not found")
        
    del _documents[doc_id]
    return {"message": "Document deleted successfully"}
