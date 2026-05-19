---
name: tmux-orchestrator
description: Allows Gemini CLI to orchestrate TMUX sessions. It can spawn new panes, read their terminal output, and kill them programmatically.
---

# Skill: TMUX Orchestrator

## Instructions

### Prerequisites
- **Strict Requirement**: You MUST be running within an active TMUX session to use this skill. Check for the `TMUX` environment variable if unsure.

### Helper Scripts
The skill uses helper scripts located in `./scripts/` (relative to this SKILL.md):
- `spawn.sh [command]`: Spawns a new horizontal pane. If `command` is provided, it is executed. Returns the `PANE_ID`.
- `read.sh <pane_id>`: Returns the text buffer of the specified pane.
- `kill.sh <pane_id>`: Kills the specified pane.
- `manage-servers.sh [list|restart|logs|kill] <pane_id>`: Easily manages active background servers running inside tmux panes. Supports listing active server panes (`list`), restarting them with Ctrl+C and repeating their startup command (`restart <pane_id>`), viewing their latest log history (`logs <pane_id>`), or terminating them gracefully (`kill <pane_id>`).

### Workflow
1. **Spawn**: To start a new task in a background-like pane, use `run_shell_command` to execute `spawn.sh`. Capture the returned `PANE_ID` (e.g., `%12`).
2. **Monitor**: Use `read.sh <pane_id>` to periodically capture the output of the pane. Look for specific success/failure strings or progress updates.
3. **Manual Closure**: The user will manually close panes (e.g., using `exit` or tmux shortcuts). Do NOT automatically call `kill.sh` unless explicitly requested by the user.

### Example Usage
- **Spawn a watcher**: `skills/tmux-orchestrator/scripts/spawn.sh "npm run watch"`
- **Read progress**: `skills/tmux-orchestrator/scripts/read.sh %12`
- **Manual exit**: The user interacts with the pane directly.
