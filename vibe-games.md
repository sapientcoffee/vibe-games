# 🚀 Vibe Games Extension Context (Hacker Vibe Edition)

This extension provides a ruthless, high-speed pipeline of specialized commands, skills, subagents, and tools designed to build and demonstrate a working prototype in under 40 minutes for the Vibe Games Competition.

## ⚡ Core Mandates
1. **The Agents CLI Advantage**: Never write boilerplate. Use `agents-cli create <name> --adk --yes` as the absolute first step for backend scaffolding.
2. **Model Selection Strategy**: Exclusively use `gemini-2.5-flash` or `gemini-3.1-flash-lite` for initial prototyping. To prevent 404 rework, run a 30-second pre-flight check: `uv run --with google-genai python -c "import google.generativeai as genai; genai.configure(api_key='YOUR_KEY'); [print(m.name) for m in genai.list_models()]"`.
3. **Data-First Execution**: The JSON schema generated in the Blueprint is the immutable law. Subagents must map their backend models and frontend UI strictly to `./data/data.json`. 
4. **Local-First Architecture**: ALL infrastructure (UI, APIs) MUST run locally. The ONLY external dependency is the LLM via `GOOGLE_API_KEY`.
5. **Zero-Cloud Persistence**: No Postgres. No Firebase. Use local JSON files for structured data to ensure instantaneous reads/writes during the demo.
6. **Spectator Mode (LIVE VIBES)**: You are on stage. Use emojis (🚀, 🤖, ✨, 🧠), witty status updates, and visual terminal multiplexing (`tmux`). Make the build process look like an automated heist.
7. **CORS-by-Default**: For projects involving a separate UI, the ADK backend MUST pre-emptively include CORS middleware (FastAPI `CORSMiddleware`) to avoid frontend-to-backend connection friction.
8. **Speed is King (NO TESTS)**: Standard developer practices (Unit Tests, exhaustive TDD) are SUSPENDED. Do NOT write tests. If the endpoint returns valid JSON, it ships. Every second spent testing is a second lost. 🏎️💨

---

## 🛠️ The Hacker Vibe Pipeline
The standard software development lifecycle has been compressed into four lightning-fast terminal commands. 

| Command | Role | Output |
| :--- | :--- | :--- |
| **`/vibe-check`** | **Scope Definition** | 3 rapid-fire Yes/No questions to lock in the use case. Initializes the tracker. |
| **`/blueprint`** | **Technical Skeleton** | Generates the ADK prompts, defines Deep Modules, and seeds the initial `data.json` payload. |
| **`/chop-shop`** | **Task Slicing** | Breaks the blueprint into parallel `[FRONTEND]`, `[BACKEND]`, and `[ADK-INIT]` slices. |
| **`/send-it`** | **Swarm Execution** | Ignites the `tmux` swarm, launching subagents in visible parallel panes while updating the Kanban board. |

---

## 🗄️ Data Persistence Protocol (JSON-First)
To avoid setup friction and database migrations, use this strict local storage pattern. Subagents must target `./data/data.json` using absolute path resolution to ensure consistency.

```python
import json
import os
from pathlib import Path

# Explicitly define workspace root for consistent pathing
WORKSPACE_ROOT = Path(os.getcwd())
DATA_FILE = WORKSPACE_ROOT / "data/data.json"
DATA_FILE.parent.mkdir(parents=True, exist_ok=True)

def load_data():
    if not DATA_FILE.exists():
        return {}
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)
```

**API Exposure Pattern**: Since ADK's primary job is LLM orchestration, adding a dedicated "Data API" route in `agent_runtime_app.py` is the most efficient way to bridge the gap to a custom frontend without extra infrastructure. Use this to expose the internal state (from `data.json`) to the React UI.

---

## 🚦 Tmux Orchestration & State Safety
To provide the visual spectacle of parallel agent execution without corrupting files, we use a **State Directory Pattern**.

1. **The Rule:** Subagents (`vibe-ui-artist`, `vibe-adk-hacker`) are FORBIDDEN from writing directly to `.plans/KANBAN.md`. 
2. **The Isolation:** Each `tmux` pane writes its status (`IN_PROGRESS`, `DONE`, `FAILED`) to its own isolated file in `.plans/swarm-state/<issue_id>.state`.
3. **The Watcher:** The orchestrator automatically launches `watch-kanban.sh` in the background. This daemon aggregates the individual state files every 2 seconds and safely reconstructs the Mermaid Kanban board. This prevents read/write collisions while keeping the visual updates live for the audience.

---

## 📺 Spectator Logging (ADK Callbacks)
To satisfy the "Live Log" requirement for the audience, ADK agents MUST use callbacks to broadcast their internal state to the terminal using the **Gold Standard Emoji Set**: (📥 - Input, 🧠 - Reasoning, 🛠️ - Tool Call, 💾 - Save/Persistence, ✅ - Done).

*   **`before_agent_callback`**: Log the incoming user prompt and current tool state using 📥 and 🧠.
*   **`after_agent_callback`**: Log the final response and any modified state objects using ✅.
*   **Tool Execution**: Within tool functions, log execution with 🛠️ and data updates with 💾.
*   **Responsive Tools**: Always use `flush=True` in print statements within agent tools to ensure the "Live Logs" in the UI feel responsive and "alive" during demos.
This ensures that the audience sees the "brain" of the agent working in real-time.

---

## 🏎️ High-Velocity Setup Rules
To ensure a "one-turn" success and avoid common infrastructure bottlenecks:

*   **Dependency Force**: Always use `--index-url https://pypi.org/simple` when installing dependencies via `uv` or `pip` to bypass any internal registry timeouts.
*   **LLM Access**: Exclusively use `GOOGLE_API_KEY` (AI Studio). Do NOT use Vertex AI to avoid IAM/403 friction on stage.
*   **Agents CLI Context**: Subagents should utilize the bundled `/agents-cli-adk-code` skill context if they need to reference the exact ADK syntax.
*   **Line Buffering**: When the orchestrator spawns background services, use `stdbuf -oL -eL` to ensure logs write instantly for live tailing.
*   **Server Lifecycle**: Changes to Agent or Gemini configuration objects require a hard restart of the `uvicorn` (playground) process to re-register models and tools.
*   **Tail the Server Log**: When `agents-cli run` fails without a clear error, the root cause (e.g., gRPC or Model 404s) is always in `.google-agents-cli/run_server.log`. Monitor this log in a separate `tmux` pane for instant debugging.
*   **Pre-Flight Port Checks**: Automate a "clear port" sequence (e.g., `lsof -t -i:8080 | xargs kill`) before starting background services to prevent "Address already in use" failures.
*   **Non-Interactive Frontend**: Always utilize the `npm create vite@latest <name> -- --template <template> -y` pattern to ensure the agent doesn't hang on interactive prompts during scaffolding.