#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

STATE_FILE=".tmux_panes"

if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

# Get all active pane IDs from tmux
ACTIVE_PANES=$(tmux list-panes -a -F "#{pane_id}" 2>/dev/null)

# Create a temporary file
TEMP_FILE="${STATE_FILE}.tmp"
touch "$TEMP_FILE"

# Iterate through the state file and keep only active panes
while IFS=' | ' read -r timestamp pane_id type command; do
    # Cleanup the pane_id (it might have extra spaces from the ' | ' split)
    clean_pane_id=$(echo "$pane_id" | xargs)
    
    if echo "$ACTIVE_PANES" | grep -q "^$clean_pane_id$"; then
        echo "$timestamp | $pane_id | $type | $command" >> "$TEMP_FILE"
    fi
done < "$STATE_FILE"

mv "$TEMP_FILE" "$STATE_FILE"
