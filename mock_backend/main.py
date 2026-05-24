import base64
import json
import uuid
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from models.chat import AuthRequest, RegisterRequest
from routers.chat import router as chat_router

app = FastAPI(title="SmartHub Mock Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/auth/register")
async def register(request: RegisterRequest) -> dict[str, object]:
    return {
        "message": "Account created.",
        "user": {
            "id": str(uuid.uuid4()),
            "name": request.name,
            "email": request.email,
        },
    }


@app.post("/auth/login")
async def login(request: AuthRequest) -> dict[str, object]:
    return {
        "accessToken": _fake_jwt(request.email, "access"),
        "refreshToken": _fake_jwt(request.email, "refresh"),
        "user": {
            "id": str(uuid.uuid4()),
            "email": request.email,
        },
    }


def _fake_jwt(email: str, token_type: str) -> str:
    header = _base64_url({"alg": "HS256", "typ": "JWT"})
    payload = _base64_url(
        {
            "sub": str(uuid.uuid4()),
            "email": email,
            "type": token_type,
            "iat": int(datetime.now(timezone.utc).timestamp()),
        }
    )
    signature = base64.urlsafe_b64encode(uuid.uuid4().bytes).decode().rstrip("=")
    return f"{header}.{payload}.{signature}"


def _base64_url(data: dict[str, object]) -> str:
    raw = json.dumps(data, separators=(",", ":")).encode()
    return base64.urlsafe_b64encode(raw).decode().rstrip("=")
