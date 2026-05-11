#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# Ensure we are inside a tmux session
if [ -z "$TMUX" ]; then
    echo "Error: Not in a tmux session" >&2
    exit 1
fi

COMMAND="$1"
STATE_FILE=".tmux_panes"
SCRIPTS_DIR="/home/robedwards/.gemini/extensions/vibe-games-extension/skills/tmux-orchestrator/scripts"

# 0. Sync state file with reality
if [ -f "$SCRIPTS_DIR/sync.sh" ]; then
    "$SCRIPTS_DIR/sync.sh"
fi

# 1. Initialize or retrieve the Main Orchestrator pane ID for THIS WINDOW (-w)
MAIN_PANE=$(tmux show-option -wv @main-pane-id 2>/dev/null)
if [ -z "$MAIN_PANE" ] || ! tmux display-message -p -t "$MAIN_PANE" "#{pane_id}" >/dev/null 2>&1; then
    MAIN_PANE="$TMUX_PANE"
    tmux set-option -w @main-pane-id "$MAIN_PANE"
    tmux select-pane -t "$MAIN_PANE" -T "Main Orchestrator"
fi
tmux set-option -w pane-border-status top

# 2. Logic for Servers (Bottom, full-width, small height)
shopt -s nocasematch
TYPE="other"
TITLE="Task"
if [[ "$COMMAND" =~ (server|dev|start|watch|bridge|uvicorn|fastapi|flask|node|npm|python|localhost) ]]; then
    TYPE="server"
    TITLE="Server: $COMMAND"
    PANE_ID=$(tmux split-window -v -f -l 4 -P -F "#{pane_id}" -t "$MAIN_PANE")

# 3. Logic for Gemini Sessions (Right Column, Stacked)
elif [[ "$COMMAND" =~ gemini ]]; then
    TYPE="gemini"
    # Clean up title: remove 'gemini' and leading/trailing quotes/spaces
    CLEAN_CMD=$(echo "$COMMAND" | sed -E 's/^gemini\s*//I' | sed -E 's/^["'\'']|["'\'']$//g')
    TITLE="Gemini: ${CLEAN_CMD:-session}"
    
    LAST_GEMINI=$(tmux show-option -wv @last-gemini-pane-id 2>/dev/null)
    if [ -n "$LAST_GEMINI" ] && ! tmux display-message -p -t "$LAST_GEMINI" "#{pane_id}" >/dev/null 2>&1; then
        LAST_GEMINI=""
    fi

    if [ -z "$LAST_GEMINI" ]; then
        PANE_ID=$(tmux split-window -h -P -F "#{pane_id}" -t "$MAIN_PANE")
    else
        PANE_ID=$(tmux split-window -v -P -F "#{pane_id}" -t "$LAST_GEMINI")
    fi
    tmux set-option -w @last-gemini-pane-id "$PANE_ID"

# 4. Default fallback
else
    PANE_ID=$(tmux split-window -h -P -F "#{pane_id}" -t "$MAIN_PANE")
    TITLE="Extra: $COMMAND"
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
