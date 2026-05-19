#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# manage-servers.sh - Manage background server processes in tmux panes

STATE_FILE=".tmux_panes"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure we are inside tmux
if [ -z "$TMUX" ]; then
    echo -e "\033[1;31mError: Not in a active tmux session\033[0m" >&2
    exit 1
fi

list_servers() {
    echo -e "\033[1;34m============================================================\033[0m"
    echo -e "\033[1;35m               📡 ACTIVE SERVER PROCESSES 📡                \033[0m"
    echo -e "\033[1;34m============================================================\033[0m"
    echo -e "\033[1;30mPane ID  | Title                       | Command\033[0m"
    echo -e "\033[1;30m---------+-----------------------------+--------------------\033[0m"

    # Find panes with title 📡
    tmux list-panes -F "#{pane_id} #{pane_title}" | while read -r line; do
        pane_id=$(echo "$line" | awk '{print $1}')
        pane_title=$(echo "$line" | cut -d' ' -f2-)
        
        if [[ "$pane_title" =~ "📡" ]]; then
            # Look up the actual command in .tmux_panes
            cmd="Unknown"
            if [ -f "$STATE_FILE" ]; then
                cmd=$(grep " | $pane_id | " "$STATE_FILE" | tail -n 1 | cut -d'|' -f4- | xargs)
            fi
            printf "\033[1;32m%-8s\033[0m | \033[1;37m%-27s\033[0m | \033[1;36m%s\033[0m\n" "$pane_id" "$pane_title" "${cmd:-$pane_title}"
        fi
    done
    echo -e "\033[1;34m============================================================\033[0m"
}

restart_server() {
    pane_id="$1"
    if [ -z "$pane_id" ]; then
        echo "Usage: $0 restart <pane_id>"
        exit 1
    fi

    # Verify pane exists
    if ! tmux has-session -t "$pane_id" 2>/dev/null; then
        echo -e "\033[1;31mError: Pane $pane_id not found.\033[0m"
        exit 1
    fi

    # Look up command
    cmd=""
    if [ -f "$STATE_FILE" ]; then
        cmd=$(grep " | $pane_id | " "$STATE_FILE" | tail -n 1 | cut -d'|' -f4- | xargs)
    fi

    if [ -z "$cmd" ]; then
        # Fallback to extracting title if command not logged
        cmd=$(tmux display-message -p -t "$pane_id" "#{pane_title}" | sed 's/📡[[:space:]]*//')
    fi

    echo -e "\033[1;33mRestarting server in pane $pane_id...\033[0m"
    echo -e "\033[1;30mStopping running process (C-c)...\033[0m"
    tmux send-keys -t "$pane_id" C-c
    sleep 0.5
    
    echo -e "\033[1;32mSending startup command: $cmd\033[0m"
    tmux send-keys -t "$pane_id" "$cmd" C-m
    echo -e "\033[1;32mServer restarted successfully!\033[0m"
}

view_logs() {
    pane_id="$1"
    if [ -z "$pane_id" ]; then
        echo "Usage: $0 logs <pane_id>"
        exit 1
    fi

    # Verify pane exists
    if ! tmux has-session -t "$pane_id" 2>/dev/null; then
        echo -e "\033[1;31mError: Pane $pane_id not found.\033[0m"
        exit 1
    fi

    echo -e "\033[1;36mShowing last 30 lines of logs for server pane $pane_id:\033[0m"
    echo -e "\033[1;30m------------------------------------------------------------\033[0m"
    tmux capture-pane -p -t "$pane_id" | tail -n 30
    echo -e "\033[1;30m------------------------------------------------------------\033[0m"
}

kill_server() {
    pane_id="$1"
    if [ -z "$pane_id" ]; then
        echo "Usage: $0 kill <pane_id>"
        exit 1
    fi

    # Verify pane exists
    if ! tmux has-session -t "$pane_id" 2>/dev/null; then
        echo -e "\033[1;31mError: Pane $pane_id not found.\033[0m"
        exit 1
    fi

    echo -e "\033[1;31mTerminating process in server pane $pane_id...\033[0m"
    tmux send-keys -t "$pane_id" C-c
    sleep 0.3
    tmux kill-pane -t "$pane_id"
    echo -e "\033[1;32mPane $pane_id killed cleanly.\033[0m"
}

# Main routing logic
case "$1" in
    list|ls)
        list_servers
        ;;
    restart|r)
        restart_server "$2"
        ;;
    logs|l)
        view_logs "$2"
        ;;
    kill|k)
        kill_server "$2"
        ;;
    *)
        echo "Usage: $0 {list|restart|logs|kill} [pane_id]"
        exit 1
        ;;
esac
