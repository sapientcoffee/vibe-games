#!/bin/bash

# Ensure a PANE_ID was provided
if [ -z "$1" ]; then
    echo "Error: No PANE_ID provided" >&2
    exit 1
fi

PANE_ID="$1"

# Kill the pane
tmux kill-pane -t "$PANE_ID"
