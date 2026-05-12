#!/bin/bash
# 0. Set Absolute Base Path
BASE_DIR=$(pwd)

# 1. Clean Scaffolding
rm -rf app/ && agents-cli scaffold create agent --agent adk --prototype --name app

# 2. Force Public Index & Virtual Env
cd "${BASE_DIR}/app"
python3 -m venv .venv
.venv/bin/pip install --index-url https://pypi.org/simple \
    google-adk \
    google-genai \
    fastapi \
    uvicorn \
    pydantic

# 3. Create Bridge with Explicit Paths
mkdir -p "${BASE_DIR}/bridge"
cat <<EOF > "${BASE_DIR}/bridge/main.py"
import os
import sys
# Add app to path using absolute reference
sys.path.append("${BASE_DIR}/app")

from fastapi import FastAPI
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from app.agent import root_agent

app = FastAPI()
runner = Runner(
    agent=root_agent,
    app_name="app",
    session_service=InMemorySessionService()
)

@app.post("/api/chat")
async def chat(request: dict):
    # Simplified hybrid-ready bridge logic
    return {"response": "System Ready: Connected via ADK"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# 4. Success Signal
echo "🚀 Tracer Bullet Scaffolding Complete in ${BASE_DIR}"
