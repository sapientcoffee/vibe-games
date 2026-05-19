#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# watch-kanban.sh - Aggregates swarm-state and dynamically reconstructs .plans/KANBAN.md

STATE_DIR=".plans/swarm-state"
KANBAN_FILE=".plans/KANBAN.md"
ISSUE_DIR=".plans"

mkdir -p "$STATE_DIR"

while true; do
  clear
  echo -e "\033[1;36m============================================================\033[0m"
  echo -e "\033[1;35m             🔥 SWARM LIVE KANBAN TRACKER 🔥                \033[0m"
  echo -e "\033[1;36m============================================================\033[0m"
  echo ""

  # Initialize temporary lists for Mermaid and Terminal Display
  todo_nodes=""
  inprogress_nodes=""
  done_nodes=""

  todo_display=""
  inprogress_display=""
  done_display=""

  # Scan for all issue files in .plans/
  if [ -d "$ISSUE_DIR" ]; then
    # Sort issues by filename numerically
    for issue_file in $(ls "$ISSUE_DIR"/issue-*.md 2>/dev/null | sort -V); do
      issue_id=$(basename "$issue_file" .md)
      
      # Determine state from state file, defaulting to TODO if none exists
      state_file="$STATE_DIR/$issue_id.state"
      if [ -f "$state_file" ]; then
        status=$(cat "$state_file" | tr -d '[:space:]' | tr 'a-z' 'A-Z')
      else
        status="TODO"
      fi

      # Update the Status line in the issue file itself if out of sync
      if [ -f "$issue_file" ]; then
        # Check current status in the file
        current_in_file=$(grep -E "^(Status:|\*\*Status:\*\*)" "$issue_file" | head -n 1 | sed -E 's/^(Status:|\*\*Status:\*\*)[[:space:]]*//' | tr -d '[:space:]')
        if [ "$current_in_file" != "$status" ]; then
          # Update the status line in place
          sed -i -E "s/^(Status:|\*\*Status:\*\*)[[:space:]]*.*/\1 $status/" "$issue_file"
        fi
      fi

      # Extract the title from the issue file
      title=$(grep -E "^(# Title:|# )" "$issue_file" | head -n 1 | sed -E 's/^(# Title:[[:space:]]*|# [[:space:]]*)//' | sed -E 's/\[[^]]+\]//g' | tr -d '"'"'"')
      # Extract raw tag (e.g. BACKEND, FRONTEND, ADK)
      tag=$(grep -E "^(# Title:|# )" "$issue_file" | head -n 1 | grep -o -E "\[[^]]+\]" | tr -d '[]' | head -n 1)
      if [ -z "$tag" ]; then
        tag="TASK"
      fi

      # Format clean name for Mermaid (no brackets, quotes, or colons)
      clean_title="$tag - $title"
      clean_title=$(echo "$clean_title" | sed 's/[:[\]"()]/ /g' | xargs)

      # Group by state
      if [ "$status" = "DONE" ]; then
        done_nodes="$done_nodes\n    $issue_id($clean_title)"
        done_display="$done_display\n  \033[1;32m✓ $issue_id: [$tag] $title\033[0m"
      elif [ "$status" = "IN_PROGRESS" ]; then
        inprogress_nodes="$inprogress_nodes\n    $issue_id($clean_title)"
        inprogress_display="$inprogress_display\n  \033[1;33m⚡ $issue_id: [$tag] $title 🚀\033[0m"
      else
        todo_nodes="$todo_nodes\n    $issue_id($clean_title)"
        todo_display="$todo_display\n  \033[1;37m• $issue_id: [$tag] $title\033[0m"
      fi
    done
  fi

  # Fallback for empty columns
  [ -z "$todo_nodes" ] && todo_nodes="\n    None" && todo_display="\n  \033[1;30m(None)\033[0m"
  [ -z "$inprogress_nodes" ] && inprogress_nodes="\n    None" && inprogress_display="\n  \033[1;30m(None)\033[0m"
  [ -z "$done_nodes" ] && done_nodes="\n    None" && done_display="\n  \033[1;30m(None)\033[0m"

  # 1. Compile the Mermaid KANBAN.md file
  {
    echo "\`\`\`mermaid"
    echo "flowchart TD"
    echo "  subgraph Todo [\"To Do\"]"
    echo "    direction TB"
    echo -e "$todo_nodes"
    echo "  end"
    echo "  subgraph InProgress [\"In Progress\"]"
    echo "    direction TB"
    echo -e "$inprogress_nodes"
    echo "  end"
    echo "  subgraph Done [\"Done\"]"
    echo "    direction TB"
    echo -e "$done_nodes"
    echo "  end"
    echo "\`\`\`"
  } > "$KANBAN_FILE"

  # 2. Print high-energy color-coded board to terminal stdout
  echo -e "\033[1;34m📋 [ TO DO ]\033[0m"
  echo -e "$todo_display"
  echo ""
  echo -e "\033[1;33m⚡ [ IN PROGRESS ]\033[0m"
  echo -e "$inprogress_display"
  echo ""
  echo -e "\033[1;32m✅ [ DONE ]\033[0m"
  echo -e "$done_display"
  echo ""
  echo -e "\033[1;36m============================================================\033[0m"
  echo -e "\033[1;30mUpdating live every 2 seconds... Press C-c to stop.\033[0m"

  sleep 2
done
