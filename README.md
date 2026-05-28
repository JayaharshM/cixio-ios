# cixio

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API Documentation

The frontend uses the `Dio` package to communicate with the backend. Below are all the APIs and their structures called from the Flutter application.

### Authentication API (`/auth`)

- **Register**
  - **Endpoint**: `POST /auth/register`
  - **Body**:
    ```json
    {
      "name": "User Name",
      "email": "user@example.com",
      "password": "password123"
    }
    ```

- **Login**
  - **Endpoint**: `POST /auth/login`
  - **Body**:
    ```json
    {
      "email": "user@example.com",
      "password": "password123"
    }
    ```
  - **Response**: Access token (and optionally a refresh token)

- **Get Current User**
  - **Endpoint**: `GET /auth/me`
  - **Response**: User object (JSON)

### Todo API (`/todos`)

- **Get Sections**
  - **Endpoint**: `GET /todos/sections`
  - **Response**: List of `TodoSection` objects

- **Create Section**
  - **Endpoint**: `POST /todos/sections`
  - **Body**: `{ "title": "Section Title" }`
  - **Response**: Created `TodoSection` object

- **Delete Section**
  - **Endpoint**: `DELETE /todos/sections/:id`

- **Toggle Pin Section**
  - **Endpoint**: `POST /todos/sections/:id/toggle_pin`
  - **Response**: Updated `TodoSection` object

- **Get Todos**
  - **Endpoint**: `GET /todos/sections/:sectionId/todos`
  - **Query Parameters**: `completed` (optional boolean)
  - **Response**: List of `Todo` objects

- **Create Todo**
  - **Endpoint**: `POST /todos/sections/:sectionId/todos`
  - **Body**: 
    ```json
    {
      "title": "Todo Title",
      "description": "Optional description",
      "due_date": "ISO8601 String" 
    }
    ```
  - **Response**: Created `Todo` object

- **Update Todo**
  - **Endpoint**: `PUT /todos/:id`
  - **Body**: `title`, `description`, and/or `due_date`
  - **Response**: Updated `Todo` object

- **Toggle Todo Complete**
  - **Endpoint**: `PUT /todos/:id/complete`
  - **Response**: Updated `Todo` object

- **Delete Todo**
  - **Endpoint**: `DELETE /todos/:id`

- **Toggle Todo Pin**
  - **Endpoint**: `POST /todos/:id/toggle_pin`
  - **Response**: Updated `Todo` object

### Chat API (`/chat`)

- **Create Session**
  - **Endpoint**: `POST /chat/sessions`
  - **Response**: Created `ChatSession` object

- **Get Sessions**
  - **Endpoint**: `GET /chat/sessions`
  - **Response**: List of `ChatSession` objects

- **Delete Session**
  - **Endpoint**: `DELETE /chat/sessions/:id`

- **Toggle Pin Session**
  - **Endpoint**: `POST /chat/sessions/:id/toggle_pin`
  - **Response**: Updated `ChatSession` object

- **Get Messages**
  - **Endpoint**: `GET /chat/sessions/:sessionId/messages`
  - **Response**: List of `Message` objects

- **Send Message**
  - **Endpoint**: `POST /chat/sessions/:sessionId/messages`
  - **Headers**: `Accept: text/event-stream`
  - **Body**: `{ "content": "Message text" }`
  - **Response**: Server-Sent Events (SSE) stream of token chunks

### Document API (`/documents`)

- **Get Documents**
  - **Endpoint**: `GET /documents`
  - **Response**: List of `Document` objects

- **Upload Document**
  - **Endpoint**: `POST /documents/upload`
  - **Body**: `FormData` containing the `file`
  - **Response**: Uploaded `Document` object

- **Delete Document**
  - **Endpoint**: `DELETE /documents/:id`
