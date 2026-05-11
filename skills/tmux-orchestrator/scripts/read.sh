#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# Ensure a PANE_ID was provided
if [ -z "$1" ]; then
    echo "Error: No PANE_ID provided" >&2
    exit 1
fi

PANE_ID="$1"

# Capture the pane buffer and print to stdout
tmux capture-pane -p -t "$PANE_ID"
