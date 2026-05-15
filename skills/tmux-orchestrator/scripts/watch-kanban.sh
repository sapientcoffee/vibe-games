#!/bin/bash
# Rebuilds the Mermaid Kanban board safely every 2 seconds

STATE_DIR=".plans/swarm-state"
KANBAN_FILE=".plans/KANBAN.md"

while true; do
  echo "\`\`\`mermaid" > $KANBAN_FILE
  echo "kanban" >> $KANBAN_FILE
  
  # Default columns
  TODO=""
  IN_PROGRESS=""
  DONE=""

  # Read all issues and check their state
  for issue in .plans/issue-*.md; do
    [ -f "$issue" ] || continue
    issue_name=$(basename "$issue" .md)
    title=$(grep "^# Title:" "$issue" | sed 's/# Title: //')
    
    state_file="$STATE_DIR/$issue_name.state"
    
    if [ -f "$state_file" ]; then
      status=$(cat "$state_file")
      if [ "$status" == "IN_PROGRESS" ]; then
        IN_PROGRESS="$IN_PROGRESS\n  $issue_name($title)"
      elif [ "$status" == "DONE" ]; then
        DONE="$DONE\n  $issue_name($title)"
      else
        TODO="$TODO\n  $issue_name($title)"
      fi
    else
      TODO="$TODO\n  $issue_name($title)"
    fi
  done

  # Build the Mermaid structure
  echo "  Todo" >> $KANBAN_FILE
  echo -e "$TODO" >> $KANBAN_FILE
  echo "  In Progress" >> $KANBAN_FILE
  echo -e "$IN_PROGRESS" >> $KANBAN_FILE
  echo "  Done" >> $KANBAN_FILE
  echo -e "$DONE" >> $KANBAN_FILE
  echo "\`\`\`" >> $KANBAN_FILE

  sleep 2
done