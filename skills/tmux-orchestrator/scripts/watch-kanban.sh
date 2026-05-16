#!/bin/bash
# Watches TODO.md and visually formats it for the stream

KANBAN_FILE="TODO.md"

while true; do
  clear
  echo -e "\033[1;36m========================================\033[0m"
  echo -e "\033[1;37m        VIBE GAMES KANBAN BOARD         \033[0m"
  echo -e "\033[1;36m========================================\033[0m"
  echo ""
  
  if [ -f "$KANBAN_FILE" ]; then
    # Highlight [x] as green, [ ] as yellow, [-] as cyan
    cat "$KANBAN_FILE" | \
      sed 's/\[x\]/\\033[1;32m[x]\\033[0m/g' | \
      sed 's/\[ \]/\\033[1;33m[ ]\\033[0m/g' | \
      sed 's/\[-\]/\\033[1;36m[-]\\033[0m/g'
  else
    echo -e "\033[1;31mKanban file not found. Waiting for blueprint...\033[0m"
  fi
  
  sleep 2
done