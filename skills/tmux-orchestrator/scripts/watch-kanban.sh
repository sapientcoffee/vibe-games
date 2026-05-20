#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# watch-kanban.sh - Aggregates swarm-state and dynamically reconstructs .plans/KANBAN.md using update_kanban.py

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
  clear
  python3 "$SCRIPTS_DIR/update_kanban.py"
  sleep 2
done
