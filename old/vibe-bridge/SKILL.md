---
name: vibe-bridge
description: Skill for creating the connective tissue between a React frontend and an ADK agent using FastAPI.
---

## The Bridge Protocol

In a competition blitz, we use FastAPI to bridge the frontend and the Agent. 

### Implementation Template

Write this to `bridge/main.py`:

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from agents.app.agent import agent
import json
import os

app = FastAPI()
DATA_FILE = "data.json"

def get_db():
    if not os.path.exists(DATA_FILE):
        return {"messages": []}
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save_db(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)

class ChatRequest(BaseModel):
    message: str

@app.post("/api/chat")
async def chat(request: ChatRequest):
    try:
        # 1. Log to JSON DB
        db = get_db()
        db["messages"].append({"role": "user", "content": request.message})
        
        # 2. Run Agent
        response = agent.run(request.message)
        
        # 3. Save Response
        db["messages"].append({"role": "assistant", "content": response})
        save_db(db)
        
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### Usage
Use this skill when `/vibe:scaffold` or the user needs to establish the "Slice 0" connection between the UI and the Backend logic.
