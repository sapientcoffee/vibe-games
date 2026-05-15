import json
import os
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pathlib import Path

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_FILE = Path("data/data.json")
UPLOAD_DIR = Path("data/uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

class ChatRequest(BaseModel):
    message: str

@app.get("/api/data")
async def get_data():
    if not DATA_FILE.exists():
        return {"items": []}
    return json.loads(DATA_FILE.read_text())

@app.post("/api/data")
async def update_data(data: dict):
    DATA_FILE.write_text(json.dumps(data, indent=2))
    return {"status": "success"}

@app.post("/api/chat")
async def chat(request: ChatRequest):
    return {"response": f"Tracer Bullet Received: {request.message}. Setup is live!"}

@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    file_path = UPLOAD_DIR / file.filename
    with file_path.open("wb") as buffer:
        buffer.write(await file.read())
    return {"filename": file.filename, "path": str(file_path)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
