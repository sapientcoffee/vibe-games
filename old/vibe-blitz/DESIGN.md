# DESIGN.md - Vibe Games Tracer Bullet Architecture

## System Context
This project is a high-velocity prototype for the Vibe Games. It uses a **Local-First, Zero-Cloud** architecture to maximize speed and minimize infrastructure friction.

### Component Map
- **User UI (Port 3000):** React (Vite) + Tailwind. Main interactive surface.
- **Admin UI (Port 3001):** React (Vite) + Tailwind. Management dashboard for `data.json`.
- **Bridge API (Port 8000):** FastAPI. The central hub for all logic and data persistence.
- **Agent:** Google ADK Agent. Orchestrated via `agents-cli`.

## Data Model
- **Persistence:** All structured data is stored in `data/data.json`.
- **File Storage:** All uploads (images, PDFs) are stored in `data/uploads/`.
- **Protocol:** The UIs must NEVER talk to the Agent directly. All flows must be:
  `UI -> Bridge (FastAPI) -> Agent/Data`.

## Architecture Principles
1. **Vertical Slices:** Implement end-to-end features (UI to Data) before polishing individual layers.
2. **Zero-npm-install Policy:** Avoid adding new dependencies during the 40-minute sprint unless critical.
3. **LLM as First Class Citizen:** All code should be highly readable and well-documented to assist the AI in subsequent turns.

## Endpoints (Standard)
- `GET /api/data`: Returns the full `data.json`.
- `POST /api/data`: Updates `data.json`.
- `POST /api/chat`: Invokes the ADK Agent and returns a response.
- `POST /api/upload`: Handles local file storage.
