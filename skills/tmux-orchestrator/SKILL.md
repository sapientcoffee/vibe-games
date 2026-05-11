# Skill: TMUX Orchestrator

<description>
This skill allows Gemini CLI to orchestrate TMUX sessions. It can spawn new panes, read their terminal output (to poll for status/keywords), and kill them programmatically.
</description>

## Instructions

### Prerequisites
- **Strict Requirement**: You MUST be running within an active TMUX session to use this skill. Check for the `TMUX` environment variable if unsure.

### Helper Scripts
The skill uses helper scripts located in `./scripts/` (relative to this SKILL.md):
- `spawn.sh [command]`: Spawns a new horizontal pane. If `command` is provided, it is executed. Returns the `PANE_ID`.
- `read.sh <pane_id>`: Returns the text buffer of the specified pane.
- `kill.sh <pane_id>`: Kills the specified pane.

### Workflow
1. **Spawn**: To start a new task in a background-like pane, use `run_shell_command` to execute `spawn.sh`. Capture the returned `PANE_ID` (e.g., `%12`).
2. **Monitor**: Use `read.sh <pane_id>` to periodically capture the output of the pane. Look for specific success/failure strings or progress updates.
3. **Cleanup**: Once the task is finished or no longer needed, use `kill.sh <pane_id>` to close the pane.

### Example Usage
- **Spawn a watcher**: `skills/tmux-orchestrator/scripts/spawn.sh "npm run watch"`
- **Read progress**: `skills/tmux-orchestrator/scripts/read.sh %12`
- **Kill watcher**: `skills/tmux-orchestrator/scripts/kill.sh %12`
