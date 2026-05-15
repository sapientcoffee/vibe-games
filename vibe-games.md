# Vibe Games Extension Context

This extension provides specialized commands, skills, subagents, and tools for the Vibe Games Competition.

## Core Mandates
1. **Vertical Slice Priority**: Never build horizontal layers. Always build a "Tracer Bullet" that connects UI -> Bridge -> Agent Tool in one turn.
2. **Bridge Protocol**: All communication between the React Frontend and ADK Agent MUST pass through the FastAPI bridge in `bridge/main.py`.
3. **Local-First Architecture**: ALL infrastructure (UI, Bridge API) MUST run locally. The ONLY external network dependency is the LLM for ADK.
4. **Zero-Cloud Persistence**: Use `data.json` for all structured data and a local `storage/` directory for files. No Cloud SQL or Firestore.
5. **Validation (Lite)**: Only validate what is absolutely critical. Prioritize manual UI verification over writing tests.
6. **Spectator Mode (LIVE VIBES)**: Because people are watching, use emojis (🚀, 🤖, ✨, 🧠), witty status updates, and clear "Phase" markers. Make the process feel like a high-speed heist.
7. **Speed is King (NO TESTS)**: Standard developer practices (Unit Tests, exhaustive TDD) are SUSPENDED. Do NOT write tests unless they are the *only* way to prove the feature works. Every second spent on a test is a second lost to the competitors.🏎️💨

## Data Persistence Protocol (JSON-First)
To ensure zero-friction setup with an easy path to Firestore later, use this simple storage pattern in `bridge/main.py` or agent tools:

```python
import json
import os
from pathlib import Path

DATA_FILE = "data.json"
STORAGE_DIR = Path("storage")
STORAGE_DIR.mkdir(exist_ok=True)

def load_data():
    if not os.path.exists(DATA_FILE):
        return {"items": []}
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)

# File Storage Example
def save_local_file(filename: str, content: bytes):
    file_path = STORAGE_DIR / filename
    file_path.write_bytes(content)
    return str(file_path)
```

## High-Velocity Setup Rules (Espresso Blitz)
To ensure a "one-turn" success and avoid common infrastructure bottlenecks:

1. **Dependency Force**: Always use `--index-url https://pypi.org/simple` when installing ADK or bridge dependencies to bypass internal/private registry resolution errors.
2. **LLM Access**: Exclusively use `GOOGLE_API_KEY` (AI Studio) for ADK. Do NOT use Vertex AI to avoid IAM/403 friction.
3. **Explicit Paths**: When spawning background services (Bridge/Playground), use absolute repository paths and explicit virtual environment binaries (e.g., `app/.venv/bin/python3`) to prevent environment mismatch.
4. **Model Selection**: Use `gemini-3.1-pro` for planning (`to-prd`/`to-slices`) and `gemini-3.1-flash-lite` for implementation speed and visual reasoning.

## Winning Plays: Kickoff vs. Blitz

| Command | Strategy | Best For... |
| :--- | :--- | :--- |
| **`/vibe:kickoff`** | **Isolated Workers**: Spawns a separate tmux pane for scaffolding while you stay in your main chat. | Complex projects where you want a "clean" background worker to handle the heavy lifting. |
| **`/vibe:blitz`** | **Parallel Design**: Runs a background shell script in *your current session* while you immediately start designing. | The 40-minute sprint where context switching is too expensive and you need the AI to stay in sync with your design. |

### The Blitz Protocol (Turn 0 Infrastructure)
1. Trigger `/vibe:blitz`.
2. The background script (`blitz-bootstrap.sh`) builds the "Tracer Bullet" skeleton (React, FastAPI, ADK) and installs `npm`/`uv` dependencies.
3. You and the AI immediately define the `PRD.md` and `data.json` schema.
4. By the time the design is done, the infrastructure is warm. Use `/to-code` to push logic into the boilerplate.

## Dependency Installation Helper
* **Force Public Registry**:
  `uv pip install --index-url https://pypi.org/simple google-adk fastapi uvicorn`

## Background Service Orchestration
* **Absolute Paths**: When spawning background processes (Bridge, ADK UI), always use absolute paths for the `PYTHONPATH` and the virtual environment binary.
* **Line Buffering**: Use `stdbuf -oL -eL` to ensure logs are written to files immediately for troubleshooting.
* **Example**:
  `nohup PYTHONPATH=$(pwd) .venv/bin/python3 bridge/main.py > bridge.log 2>&1 &`
