# Vibe Games Gemini CLI Extension

A high-velocity extension for the Gemini CLI, specifically optimized for building and validating agentic prototypes in high-pressure environments like the **Vibe Games Competition**.

## Overview

This extension is designed to eliminate the "friction of thought" during a 30-minute coding blitz. It focuses on:
- **Vertical Slicing:** Building UI -> Bridge -> Agent Tool in one go.
- **Parallel Scaffolding:** Using subagents to build frontend and backend simultaneously.
- **The Bridge Protocol:** Standardized FastAPI connective tissue between React and ADK Agents.
- **Live Orchestration:** Automated tmux session management for dev servers and logs.

## Commands

### `/vibe:scaffold [use-case]`
Instantly bootstraps a monorepo workspace.
- **Frontend:** React (CDN/Tailwind) dashboard.
- **Backend:** ADK Agent + placeholder logic.
- **Bridge:** FastAPI server exposing `/api/chat`.
- **Orchestration:** Spawns tmux panes for all services.

### `/vibe:plan [use-case]`
Initiates a high-velocity planning session.
- **Grill-me:** Interactive interview to refine domain terminology and ADRs.
- **To-PRD:** Automated synthesis into a comprehensive PRD.
- **To-Issues:** Vertical breakdown into "tracer bullet" implementation tickets.

### `/vibe:to-prd`
Synthesizes the current context into a PRD.

### `/vibe:to-issues`
Breaks the current PRD/Plan into vertical "tracer bullet" implementation tickets.

### `/vibe:slice [description]`
Generates presumptive vertical slices (tracer bullets) to begin immediate implementation without manual issue tracking.

## Skills Included

- **`vibe-bridge`**: Generates the FastAPI connective tissue.
- **`tmux-orchestrator`**: Manages terminal panes for a live dev environment.
- **`grill-me`**: Stress-tests your plan against domain language.
- **`to-issues`**: Breaks down plans into vertical implementation tickets.

## Installation

The easiest way to install this extension is directly via the Gemini CLI:

```bash
gemini extensions install https://github.com/sapientcoffee/vibe-games
```

Alternatively, for local development:

1. Clone this repository.
2. Link it:
   ```bash
   gemini extensions link /path/to/vibe-games
   ```

### Best Practices (Blitz Mode)

1. **Start with Scaffold:** Always run `/vibe:scaffold` as your first move.
2. **Centralized Planning:** All artifacts (CONTEXT.md, ADRs, PRD, Issues) are stored in the `.plan/` directory for easy navigation and persistence.
3. **Think Vertically:** Use `/vibe:slice` to identify the fastest path from UI to Tool.
4. **Verify Early:** Use the built-in `agents-cli eval` triggers before wiring to the UI.


## License

Copyright 2026 Google LLC.
Licensed under the Apache License, Version 2.0. See [LICENSE](./LICENSE) for details.
