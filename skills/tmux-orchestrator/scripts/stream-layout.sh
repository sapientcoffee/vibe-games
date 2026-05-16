#!/bin/bash
# stream-layout.sh - Sets up the Vibe Games command center

SESSION_NAME="vibe-games-stream"

# Start a new tmux session in detached mode
tmux new-session -d -s $SESSION_NAME

# Rename the first window
tmux rename-window -t $SESSION_NAME:0 'Control Room'

# Split the window horizontally (Left pane for AI, Right pane for code/preview)
tmux split-window -h -p 50 -t $SESSION_NAME:0

# Split the left pane vertically (Top for Kanban, Bottom for AI Agent Logs)
tmux select-pane -t 0
tmux split-window -v -p 30 -t $SESSION_NAME:0

# Pane 0 (Top Left): Kanban Board
tmux send-keys -t $SESSION_NAME:0.0 './skills/tmux-orchestrator/scripts/watch-kanban.sh' C-m

# Pane 1 (Bottom Left): Send-it Agent Output
tmux send-keys -t $SESSION_NAME:0.1 'echo "🤖 Waiting for Agent Initialization..."' C-m

# Pane 2 (Right): Code Editor or Live Preview
tmux send-keys -t $SESSION_NAME:0.2 'npm run dev' C-m

# Attach to the session
tmux attach-session -t $SESSION_NAME