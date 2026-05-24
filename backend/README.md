# Mock Backend

Run the local API:

```bash
node backend/mock_server.js
```

The Flutter app defaults to:

```text
http://localhost:3000
```

Seed account:

```text
demo@cixio.test
password123
```

Endpoints:

- `GET /health`
- `POST /auth/register`
- `POST /auth/login`

Registration body:

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "password123"
}
```

Login body:

```json
{
  "email": "jane@example.com",
  "password": "password123"
}
```

The login endpoint returns fake JWT-shaped `accessToken` and `refreshToken`
values for frontend development.
