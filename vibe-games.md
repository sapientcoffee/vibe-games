# Vibe Games Extension Context

This extension provides specialized commands, skills, subagents, and tools for the Vibe Games Competition.

## Core Mandates
1. **Vertical Slice Priority**: Never build horizontal layers. Always build a "Tracer Bullet" that connects UI -> Bridge -> Agent Tool in one turn.
2. **Bridge Protocol**: All communication between the React Frontend and ADK Agent MUST pass through the FastAPI bridge in `bridge/main.py`.
3. **Validation**: Every Agent tool change must be verified with `agents-cli eval` or a direct test script before being wired to the UI.

## High-Velocity Setup Rules (Espresso Blitz)
To ensure a "one-turn" success and avoid common infrastructure bottlenecks:

1. **Dependency Force**: Always use `--index-url https://pypi.org/simple` when installing ADK or bridge dependencies to bypass internal/private registry resolution errors.
2. **Hybrid Auth Strategy**: Start projects using `GOOGLE_API_KEY` (Gemini API / AI Studio) for the first 30 minutes to prove Slice 0. Transition to Vertex AI ADC only after UI/Bridge connectivity is verified.
3. **Explicit Paths**: When spawning background services (Bridge/Playground), use absolute repository paths and explicit virtual environment binaries (e.g., `app/.venv/bin/python3`) to prevent "ModuleNotFound" or environment mismatch errors.
4. **Gemini 3 Priority**: Prefer `gemini-3-flash-preview` for development velocity.

## Vertex AI Optimized Setup
Once permissions have propagated and Slice 0 is verified via Gemini API, adhere to this configuration for production alignment:

### 1. Pre-Flight Checklist
* **Enable API**: `gcloud services enable aiplatform.googleapis.com`
* **IAM Permissions**: Ensure `roles/aiplatform.user` is active.
* **Quota Project**: Set `GOOGLE_CLOUD_QUOTA_PROJECT` to match your Project ID.

### 2. Environment Variables
```bash
export GOOGLE_GENAI_USE_VERTEXAI="True"
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_CLOUD_QUOTA_PROJECT="your-project-id"
export GOOGLE_CLOUD_LOCATION="us-central1"
```

### 3. The Vertex Runner Pattern
Always use `google.adk.runners.Runner` with an explicit `app_name` for session and trace tracking.
