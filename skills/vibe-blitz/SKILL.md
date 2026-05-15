---
name: vibe-blitz
description: The high-speed orchestrator and bootstrap engine for 40-minute vibe coding sprints. Sets up the React/FastAPI/ADK architecture in the background while prioritizing foreground design.
---

# Vibe Blitz: 40-Minute Sprint Orchestrator

This skill is designed to maximize speed in the first 10 minutes of a vibe coding competition. It uses a "Tracer Bullet" strategy: background infrastructure setup while front-loading design.

## Core Mandates
1. **Parallel Execution**: Bootstrap the environment immediately in a 10-line tmux pane using the `blitz-bootstrap.sh` script.
2. **Foreground Design**: Do NOT wait for the script. Start the PRD and Design immediately.
3. **Local-First Architecture**: Strictly adhere to the architecture in `DESIGN.md`.

## Workflow

### 1. Bootstrap
Run the `blitz-bootstrap.sh` script (located in this skill's directory) in a new 10-line tmux pane at the bottom using the `spawn.sh` script (located in the `tmux-orchestrator` skill's `scripts/` directory):
`!{<tmux-orchestrator-path>/scripts/spawn.sh "<vibe-blitz-path>/blitz-bootstrap.sh"}`

### 2. Interview & Design
Immediately engage the user:
- "I've started bootstrapping the infrastructure in a new tmux pane. What is the core use-case for this project, and what are your initial thoughts?"
- Capture requirements for the `PRD.md`.
- Define the `data.json` schema.

### 3. Implement Slice 0
Once the script logs "Bootstrap completed" in `.blitz.log`, connect the first "Tracer Bullet":
- Update `bridge/main.py` with actual data endpoints.
- Update `ui-user/App.tsx` to display the first piece of data.

## Resources
- **`DESIGN.md`**: The architectural source of truth.
- **`blitz-bootstrap.sh`**: The high-speed setup engine.
