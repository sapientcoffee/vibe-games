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

# 0. Sync state file with reality
if [ -f "$SCRIPTS_DIR/sync.sh" ]; then
    "$SCRIPTS_DIR/sync.sh"
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "No active panes tracked in $STATE_FILE"
    exit 0
fi

# Get the Main Orchestrator pane ID for THIS WINDOW
MAIN_PANE=$(tmux show-option -wv @main-pane-id 2>/dev/null)

# Iterate through the state file and kill idle panes
PANES_TO_TIDY=()

while IFS=' | ' read -r timestamp pane_id type command; do
    clean_pane_id=$(echo "$pane_id" | xargs)
    
    # Never tidy the main pane
    if [ "$clean_pane_id" == "$MAIN_PANE" ]; then
        continue
    fi

    # Check the current command in the pane
    CURRENT_CMD=$(tmux display-message -p -t "$clean_pane_id" "#{pane_current_command}" 2>/dev/null)
    
    # If the current command is just a shell, it's considered idle/finished
    if [[ "$CURRENT_CMD" =~ ^(bash|zsh|sh|fish|tcsh|csh)$ ]]; then
        PANES_TO_TIDY+=("$clean_pane_id")
    fi
done < "$STATE_FILE"

if [ ${#PANES_TO_TIDY[@]} -eq 0 ]; then
    echo "No idle panes found to tidy."
else
    echo "Tidying ${#PANES_TO_TIDY[@]} idle panes..."
    for pid in "${PANES_TO_TIDY[@]}"; do
        "$SCRIPTS_DIR/kill.sh" "$pid"
    done
    echo "✅ Tidy complete."
fi
