#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# Ensure we are inside a tmux session
if [ -z "$TMUX" ]; then
    echo "Error: Not in a tmux session" >&2
    exit 1
fi

STATE_FILE=".tmux_panes"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine the command to run
if [[ -f "$1" && "$2" =~ ^vibe- ]]; then
    # Special pattern: <issue_file> <agent_type>
    ISSUE_FILE="$1"
    AGENT_NAME="$2"
    TEMPLATE_PATH="$SCRIPTS_DIR/../../send-it/references/subagent-prompt.md"
    
    if [ -f "$TEMPLATE_PATH" ]; then
        # Read template, replace path, and escape single quotes for the command line
        PROMPT=$(cat "$TEMPLATE_PATH" | sed "s|<PATH_TO_ISSUE>|$ISSUE_FILE|g")
        PROMPT_ESCAPED="${PROMPT//\'/\'\\\'\'}"
        COMMAND="gemini invoke_agent $AGENT_NAME --prompt '$PROMPT_ESCAPED'"
    else
        COMMAND="gemini invoke_agent $AGENT_NAME --prompt \"Implement $ISSUE_FILE\""
    fi
else
    # Default: capture all arguments as the command
    COMMAND="$*"
fi

# 0. Sync state file with reality
if [ -f "$SCRIPTS_DIR/sync.sh" ]; then
    "$SCRIPTS_DIR/sync.sh"
fi

# 1. Robustly identify the Main Orchestrator pane
# We look for a pane with the specific title in the current window
MAIN_PANE=$(tmux list-panes -F "#{pane_id} #{pane_title}" | grep "🔥 Orchestrator" | head -n 1 | awk '{print $1}')

if [ -z "$MAIN_PANE" ]; then
    # Fallback to the tracked window option
    MAIN_PANE=$(tmux show-option -wv @main-pane-id 2>/dev/null)
fi

if [ -z "$MAIN_PANE" ] || ! tmux display-message -p -t "$MAIN_PANE" "#{pane_id}" >/dev/null 2>&1; then
    # If still not found, the current pane becomes the orchestrator
    MAIN_PANE="$TMUX_PANE"
    tmux set-option -w @main-pane-id "$MAIN_PANE"
    tmux select-pane -t "$MAIN_PANE" -T "🔥 Orchestrator"
fi

# Ensure high-visibility styling is active
tmux set-option -w pane-border-status top
tmux set-option -w pane-border-format "#{?pane_active,#[fg=black,bg=cyan,bold],#[fg=white,bg=black]} #{pane_title} #[default]"
tmux set-option -w pane-active-border-style "fg=cyan"
tmux set-option -w pane-border-style "fg=white"

# 2. Logic for Gemini Sessions (Right Column, Stacked)
shopt -s nocasematch
TYPE="other"
TITLE="Task"
if [[ "$COMMAND" =~ gemini ]]; then
    TYPE="gemini"
    
    # Inject YOLO mode for gemini sessions
    if [[ ! "$COMMAND" =~ --yolo ]]; then
        if [[ "$COMMAND" =~ ^gemini ]]; then
            COMMAND=$(echo "$COMMAND" | sed -E 's/^gemini/gemini --yolo/I')
        else
            COMMAND="$COMMAND --yolo"
        fi
    fi

    CLEAN_CMD=$(echo "$COMMAND" | sed -E 's/^gemini\s*//I' | sed -E 's/--yolo\s*//I' | sed -E 's/^["'\'']|["'\'']$//g' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
    TITLE="🤖 ${CLEAN_CMD:-session}"
    
    LAST_GEMINI=$(tmux show-option -wv @last-gemini-pane-id 2>/dev/null)
    if [ -n "$LAST_GEMINI" ] && ! tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^$LAST_GEMINI$"; then
        LAST_GEMINI=""
    fi

    if [ -z "$LAST_GEMINI" ]; then
        # First gemini session: split vertically (right) from main pane
        PANE_ID=$(tmux split-window -d -h -P -F "#{pane_id}" -t "$MAIN_PANE")
    else
        # Subsequent sessions: split horizontally (down) from the last gemini pane
        PANE_ID=$(tmux split-window -d -v -P -F "#{pane_id}" -t "$LAST_GEMINI")
    fi
    tmux set-option -w @last-gemini-pane-id "$PANE_ID"

# 3. Logic for Servers (Bottom, full-width, small height)
elif [[ "$COMMAND" =~ (server|dev|start|watch|bridge|uvicorn|fastapi|flask|node|npm|python|localhost|blitz|bootstrap) ]]; then
    TYPE="server"
    CLEAN_SRV=$(echo "$COMMAND" | sed -E 's/^(npm run|python -m|node|\.\/skills\/vibe-blitz\/)\s*//I')
    TITLE="📡 $CLEAN_SRV"
    # -d prevents focus shift
    # -f -v ensures it spans the full window at the bottom
    # Default to 10 lines for servers
    PANE_ID=$(tmux split-window -d -v -f -l 10 -P -F "#{pane_id}" -t "$MAIN_PANE")

# 4. Default fallback
else
    PANE_ID=$(tmux split-window -d -h -P -F "#{pane_id}" -t "$MAIN_PANE")
    TITLE="⚙️ $COMMAND"
fi
shopt -u nocasematch

# 5. Set the title for the new pane
tmux select-pane -t "$PANE_ID" -T "$TITLE"

# 6. Record state
echo "$(date +'%Y-%m-%dT%H:%M:%S') | $PANE_ID | $TYPE | $COMMAND" >> "$STATE_FILE"

# Send the command if provided
if [ -n "$COMMAND" ]; then
    tmux send-keys -t "$PANE_ID" "$COMMAND" C-m
fi

# Output the PANE_ID to stdout
echo "$PANE_ID"
