#!/bin/bash
# Copyright 2026 Google LLC.
# SPDX-License-Identifier: Apache-2.0

# manage_env.sh - Automated local development environment lifecycle management

PID_FILE=".gemini/run.pid"
mkdir -p .gemini

log() {
    echo -e "\033[1;34m[Walkthrough Env]\033[0m $1"
}

success() {
    echo -e "\033[1;32m[Walkthrough Env] $1\033[0m"
}

error() {
    echo -e "\033[1;31m[Walkthrough Env] Error: $1\033[0m" >&2
}

discover_backend() {
    if [ -f "agent_runtime_app.py" ]; then
        echo "uvicorn agent_runtime_app:app --host 127.0.0.1 --port 8000"
    elif [ -f "main.py" ]; then
        # Search for FastAPI in main.py
        if grep -q "FastAPI" main.py; then
            echo "uvicorn main:app --host 127.0.0.1 --port 8000"
        fi
    elif [ -f "bridge.py" ]; then
        if grep -q "FastAPI" bridge.py; then
            echo "uvicorn bridge:app --host 127.0.0.1 --port 8000"
        fi
    else
        # Find any python file with FastAPI import
        find_fastapi=$(grep -rl "FastAPI" . --exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=.git 2>/dev/null | head -n 1)
        if [ -not -z "$find_fastapi" ]; then
            file_base=$(basename "$find_fastapi" .py)
            echo "uvicorn $file_base:app --host 127.0.0.1 --port 8000"
        fi
    fi
}

discover_frontend() {
    if [ -f "frontend/package.json" ]; then
        echo "frontend"
    elif [ -f "package.json" ]; then
        echo "."
    fi
}

start_env() {
    if [ -f "$PID_FILE" ]; then
        log "Warning: $PID_FILE exists. Attempting stop first to ensure clean state."
        stop_env
    fi

    log "Discovering local development components..."
    
    BACKEND_CMD=$(discover_backend)
    FRONTEND_DIR=$(discover_frontend)

    # 1. Start Backend
    if [ -n "$BACKEND_CMD" ]; then
        log "Found Backend. Starting: $BACKEND_CMD"
        # Check if port 8000 is occupied
        if lsof -pi :8000 -sTCP:LISTEN -t >/dev/null; then
            log "Port 8000 is already in use. Checking if it's our backend..."
        else
            # Try with 'uv run' if uv is installed, otherwise standard python/uvicorn
            if command -v uv >/dev/null 2>&1; then
                uv run $BACKEND_CMD > .gemini/backend.log 2>&1 &
            else
                $BACKEND_CMD > .gemini/backend.log 2>&1 &
            fi
            BACKEND_PID=$!
            echo "$BACKEND_PID" >> "$PID_FILE"
            log "Backend started with PID $BACKEND_PID"
        fi
    else
        log "No standard FastAPI backend discovered."
    fi

    # 2. Start Frontend
    if [ -n "$FRONTEND_DIR" ]; then
        log "Found Frontend in directory: $FRONTEND_DIR"
        # Check if typical frontend port is in use
        if lsof -pi :3000 -sTCP:LISTEN -t >/dev/null || lsof -pi :5173 -sTCP:LISTEN -t >/dev/null; then
            log "Frontend port is already in use. Skipping start."
        else
            cd "$FRONTEND_DIR" || exit
            npm run dev > ../.gemini/frontend.log 2>&1 &
            FRONTEND_PID=$!
            cd - >/dev/null || exit
            echo "$FRONTEND_PID" >> "$PID_FILE"
            log "Frontend started with PID $FRONTEND_PID"
        fi
    else
        log "No standard Vite/npm frontend discovered."
    fi

    # 3. Wait/poll for services to be active
    log "Waiting for services to spin up and bind to ports..."
    RETRIES=15
    BACKEND_UP=false
    FRONTEND_UP=false

    for ((i=1; i<=RETRIES; i++)); do
        if [ -n "$BACKEND_CMD" ] && [ "$BACKEND_UP" = false ]; then
            if curl -s http://127.0.0.1:8000/docs >/dev/null; then
                success "Backend is UP on http://127.0.0.1:8000"
                BACKEND_UP=true
            fi
        else
            BACKEND_UP=true
        fi

        if [ -n "$FRONTEND_DIR" ] && [ "$FRONTEND_UP" = false ]; then
            # Check port 3000 or 5173 (standard Vite) or check logs for port
            if curl -s http://127.0.0.1:3000 >/dev/null || curl -s http://127.0.0.1:5173 >/dev/null; then
                success "Frontend is UP"
                FRONTEND_UP=true
            fi
        else
            FRONTEND_UP=true
        fi

        if [ "$BACKEND_UP" = true ] && [ "$FRONTEND_UP" = true ]; then
            break
        fi

        sleep 1
    done

    if [ "$BACKEND_UP" = false ] || [ "$FRONTEND_UP" = false ]; then
        error "One or more services failed to start or bind within timeout."
        log "Checking backend logs (.gemini/backend.log):"
        tail -n 10 .gemini/backend.log 2>/dev/null
        log "Checking frontend logs (.gemini/frontend.log):"
        tail -n 10 .gemini/frontend.log 2>/dev/null
        exit 1
    fi

    success "Environment started cleanly."
}

stop_env() {
    if [ ! -f "$PID_FILE" ]; then
        log "No active walkthrough process file found ($PID_FILE)."
        
        # Fallback: find uvicorn and vite processes and kill them if requested
        log "Checking for loose uvicorn/vite processes on standard ports..."
        BACKEND_PIDS=$(lsof -t -i :8000 2>/dev/null)
        FRONTEND_PIDS=$(lsof -t -i :3000 -i :5173 2>/dev/null)
        
        if [ -n "$BACKEND_PIDS" ]; then
            log "Cleaning up dangling backend process(es): $BACKEND_PIDS"
            kill -9 $BACKEND_PIDS 2>/dev/null
        fi
        if [ -n "$FRONTEND_PIDS" ]; then
            log "Cleaning up dangling frontend process(es): $FRONTEND_PIDS"
            kill -9 $FRONTEND_PIDS 2>/dev/null
        fi
        return 0
    fi

    log "Stopping tracked walkthrough processes..."
    while IFS= read -r pid; do
        if ps -p "$pid" > /dev/null; then
            log "Stopping process $pid..."
            kill "$pid" 2>/dev/null
            sleep 0.5
            # Force kill if still running
            if ps -p "$pid" > /dev/null; then
                log "Force-killing process $pid..."
                kill -9 "$pid" 2>/dev/null
            fi
        fi
    done < "$PID_FILE"

    rm -f "$PID_FILE"
    success "Environment stopped cleanly."
}

case "$1" in
    start|up)
        start_env
        ;;
    stop|down)
        stop_env
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
