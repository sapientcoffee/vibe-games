# 🚀 Vibe Games Extension Context (Hacker Vibe Edition)

This extension provides a ruthless, high-speed pipeline of specialized commands, skills, subagents, and tools designed to build and demonstrate a working prototype in under 40 minutes for the Vibe Games Competition.

## ⚡ Core Mandates
1. **The Agents CLI Advantage**: Never write boilerplate. Use `agents-cli init vibe-agent -y --agent adk` as the absolute first step for backend scaffolding.
2. **Data-First Execution**: The JSON schema generated in the Blueprint is the immutable law. Subagents must map their backend models and frontend UI strictly to `./testing/data/data.json`. 
3. **Local-First Architecture**: ALL infrastructure (UI, APIs) MUST run locally. The ONLY external dependency is the LLM via `GOOGLE_API_KEY`.
4. **Zero-Cloud Persistence**: No Postgres. No Firebase. Use local JSON files for structured data to ensure instantaneous reads/writes during the demo.
5. **Spectator Mode (LIVE VIBES)**: You are on stage. Use emojis (🚀, 🤖, ✨, 🧠), witty status updates, and visual terminal multiplexing (`tmux`). Make the build process look like an automated heist.
6. **Speed is King (NO TESTS)**: Standard developer practices (Unit Tests, exhaustive TDD) are SUSPENDED. Do NOT write tests. If the endpoint returns valid JSON, it ships. Every second spent testing is a second lost. 🏎️💨

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
To avoid setup friction and database migrations, use this strict local storage pattern. Subagents must target `./testing/data/data.json`.

```python
import json
import os
from pathlib import Path

DATA_FILE = Path("testing/data/data.json")
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

---

## 🚦 Tmux Orchestration & State Safety
To provide the visual spectacle of parallel agent execution without corrupting files, we use a **State Directory Pattern**.

1. **The Rule:** Subagents (`vibe-ui-artist`, `vibe-adk-hacker`) are FORBIDDEN from writing directly to `.plans/KANBAN.md`. 
2. **The Isolation:** Each `tmux` pane writes its status (`IN_PROGRESS`, `DONE`, `FAILED`) to its own isolated file in `.plans/swarm-state/<issue_id>.state`.
3. **The Watcher:** The orchestrator automatically launches `watch-kanban.sh` in the background. This daemon aggregates the individual state files every 2 seconds and safely reconstructs the Mermaid Kanban board. This prevents read/write collisions while keeping the visual updates live for the audience.

---

## 🏎️ High-Velocity Setup Rules
To ensure a "one-turn" success and avoid common infrastructure bottlenecks:

*   **Dependency Force**: Always use `--index-url https://pypi.org/simple` when installing dependencies via `uv` or `pip` to bypass any internal registry timeouts.
*   **LLM Access**: Exclusively use `GOOGLE_API_KEY` (AI Studio). Do NOT use Vertex AI to avoid IAM/403 friction on stage.
*   **Agents CLI Context**: Subagents should utilize the bundled `/agents-cli-adk-code` skill context if they need to reference the exact ADK syntax.
*   **Line Buffering**: When the orchestrator spawns background services, use `stdbuf -oL -eL` to ensure logs write instantly for live tailing.