# Vibe Games Extension Context

This extension provides specialized commands, skills, subagents, and tools for the Vibe Games Competition.

## Core Mandates
1. **Vertical Slice Priority**: Never build horizontal layers. Always build a "Tracer Bullet" that connects UI -> Bridge -> Agent Tool in one turn.
2. **Bridge Protocol**: All communication between the React Frontend and ADK Agent MUST pass through the FastAPI bridge in `bridge/main.py`.
3. **Validation**: Every Agent tool change must be verified with `agents-cli eval` or a direct test script before being wired to the UI.
