#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# Ensure a PANE_ID was provided
if [ -z "$1" ]; then
    echo "Error: No PANE_ID provided" >&2
    exit 1
fi

PANE_ID="$1"
STATE_FILE=".tmux_panes"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Kill the pane first
tmux kill-pane -t "$PANE_ID" 2>/dev/null

# Sync state file to reflect the change
if [ -f "$SCRIPTS_DIR/sync.sh" ]; then
    "$SCRIPTS_DIR/sync.sh"
fi
