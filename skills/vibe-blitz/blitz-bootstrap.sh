#!/bin/bash

# Vibe Games Blitz Bootstrap Script
# This script is designed for maximum speed. It scaffolds the core structure
# immediately and kicks off heavy installations and services in the background.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE=".blitz.log"
BASE_DIR=$(pwd)

# Vibe styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

vibe_log() {
    echo -e "${CYAN}[VIBE]${NC} $1" | tee -a "$LOG_FILE"
}

coffee_log() {
    echo -e "${YELLOW}☕ $1${NC}" | tee -a "$LOG_FILE"
}

success_log() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

info_log() {
    echo -e "${BLUE}ℹ️ $1${NC}" | tee -a "$LOG_FILE"
}

echo -e "${BOLD}${BLUE}--- 🏎️ VIBE GAMES ESPRESSO BLITZ INITIATED 🏎️ ---${NC}" | tee -a "$LOG_FILE"
echo "[$(date)] Blitz Bootstrap Initiated" >> "$LOG_FILE"

# 1. Immediate Infrastructure
coffee_log "Grinding the beans... (Directories and DESIGN.md)"
mkdir -p data/uploads bridge
cp "$SCRIPT_DIR/DESIGN.md" ./DESIGN.md
if [ ! -f data/data.json ]; then
    echo '{"items": []}' > data/data.json
fi
success_log "Grounds are ready."

# Setup virtual environment
vibe_log "Setting up virtual environment with uv..."
uv venv --clear | tee -a "$LOG_FILE"
success_log "Virtual environment ready."

# 2. Scaffolding Bridge (FastAPI)
coffee_log "Warming the espresso machine... (Bridge boilerplate)"
cat <<EOF > bridge/main.py
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
EOF
success_log "Bridge is pressurized."

# Install bridge dependencies
vibe_log "Installing bridge dependencies (fastapi, uvicorn)..."
uv pip install --index-url https://pypi.org/simple fastapi uvicorn python-multipart | tee -a "$LOG_FILE"
success_log "Bridge dependencies installed."

# Start Bridge in background
nohup ./.venv/bin/python3 bridge/main.py > .bridge.log 2>&1 &
echo $! > .bridge.pid
info_log "Bridge running at http://localhost:8000"

# 3. Parallel Background Scaffolding & Launching
coffee_log "Pulling triple shots in parallel! 🔥"

# ADK Agent
    vibe_log "Starting ADK Agent 🤖..."
    uvx google-agents-cli scaffold create agent "core-agent" --deployment-target agent_runtime | tee -a "$LOG_FILE"
    success_log "ADK Agent scaffolded. 🤖"
    
    vibe_log "Launching ADK Playground... 🎨"
    cd core-agent
    # Run playground in background
    nohup agents-cli playground >> ../.agent.log 2>&1 &
    echo $! > ../.agent.pid
    success_log "ADK UI is live! Check below for URL."

# User UI
    vibe_log "Starting User UI ⚛️..."
    npm create vite@latest ui-user -- --template react-ts --yes | tee -a "$LOG_FILE"
    cd ui-user
    npm install | tee -a "$LOG_FILE"
    # Overwrite src/App.tsx with user-specific content
    cat <<EOF > src/App.tsx
import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from './assets/vite.svg'
import './App.css'

function App() {
  const [count, setCount] = useState(0)
  const [agentMessage, setAgentMessage] = useState('');
  const [agentResponse, setAgentResponse] = useState('');

  const handleSendMessage = async () => {
    const response = await fetch('http://localhost:8000/api/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message: agentMessage }),
    });
    const data = await response.json();
    setAgentResponse(data.response);
  };

  return (
    <>
      <div>
        <a href="https://vitejs.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vibe Games User UI</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>

      <h2>Agent Interaction</h2>
      <input
        type="text"
        value={agentMessage}
        onChange={(e) => setAgentMessage(e.target.value)}
        placeholder="Type your message to the agent"
      />
      <button onClick={handleSendMessage}>Send to Agent</button>
      {agentResponse && <p>Agent Says: {agentResponse}</p>}
    </>
  )
}

export default App
EOF
    # Update vite config to use port 3000
    sed -i 's/plugins: \[react()\],/plugins: [react()], server: { port: 3000 },/' vite.config.ts
    vibe_log "Launching User UI... 🚀"
    nohup npm run dev -- --port 3000 >> ../.ui-user.log 2>&1 &
    echo $! > ../.ui-user.pid
    success_log "User UI is steaming hot! ⚛️"

# Admin UI
    vibe_log "Starting Admin UI 🛠️..."
    npm create vite@latest ui-admin -- --template react-ts --yes | tee -a "$LOG_FILE"
    cd ui-admin
    npm install | tee -a "$LOG_FILE"
    # Update vite config to use port 3001
    sed -i 's/plugins: \[react()\],/plugins: [react()], server: { port: 3001 },/' vite.config.ts
    vibe_log "Launching Admin UI... ⚡"
    nohup npm run dev -- --port 3001 >> ../.ui-admin.log 2>&1 &
    echo $! > ../.ui-admin.pid
    success_log "Admin UI has been frothed! 🛠️"

# Final Vibe & URLs
echo -e "
${BOLD}${GREEN}🚀 BOOTSTRAP COMPLETED 🚀${NC}" | tee -a "$LOG_FILE"
echo -e "${MAGENTA}${BOLD}--- TRACER BULLET URLS ---${NC}" | tee -a "$LOG_FILE"
echo -e "${CYAN}BRIDGE API:  ${NC} http://localhost:8000"
echo -e "${CYAN}USER UI:     ${NC} http://localhost:3000"
echo -e "${CYAN}ADMIN UI:    ${NC} http://localhost:3001"
echo -e "${CYAN}ADK UI:      ${NC} http://localhost:8080 (Standard ADK port)"
echo -e "${MAGENTA}--------------------------${NC}"

echo -e "
${YELLOW}Logs are being frothed in .log files. LFG!${NC}
"