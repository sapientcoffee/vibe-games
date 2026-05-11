#!/bin/bash

# Ensure we are inside a tmux session
if [ -z "$TMUX" ]; then
    echo "Error: Not in a tmux session" >&2
    exit 1
fi

# Spawn the pane and capture its ID
PANE_ID=$(tmux split-window -h -P -F "#{pane_id}")

# If a command was provided, send it to the new pane
if [ -n "$1" ]; then
    tmux send-keys -t "$PANE_ID" "$1" C-m
fi

# Output the PANE_ID to stdout for the caller
echo "$PANE_ID"
