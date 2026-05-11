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
from agents.app.agent import agent # Assuming standard ADK path

app = FastAPI()

class ChatRequest(BaseModel):
    message: str

@app.post("/api/chat")
async def chat(request: ChatRequest):
    try:
        # Standard ADK invocation
        response = agent.run(request.message)
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Usage
Use this skill when `/vibe:scaffold` or the user needs to establish the "Slice 0" connection between the UI and the Backend logic.
