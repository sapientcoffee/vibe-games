# Vibe Games Extension Context

This extension provides specialized commands, skills, subagents, and tools for the Vibe Games Competition.

## Core Mandates
1. **Vertical Slice Priority**: Never build horizontal layers. Always build a "Tracer Bullet" that connects UI -> Bridge -> Agent Tool in one turn.
2. **Bridge Protocol**: All communication between the React Frontend and ADK Agent MUST pass through the FastAPI bridge in `bridge/main.py`.
3. **Validation**: Every Agent tool change must be verified with `agents-cli eval` or a direct test script before being wired to the UI.

## Vertex AI Optimized Setup
To ensure a zero-friction, Vertex AI-only setup, adhere to this strict configuration. This removes all alternatives and focuses strictly on the requirements for the Gemini Enterprise Agent Platform.

### 1. Pre-Flight Checklist (Infrastructure)
Before initializing the agent, these steps must be completed in the GCP console or via CLI:
* **Enable API**: `gcloud services enable aiplatform.googleapis.com`
* **IAM Permissions**: Ensure the active identity has `roles/aiplatform.user` on the project.
* **Quota Project**: If using User Credentials (ADC), you must set the quota project to match your project ID to avoid 403 errors.

### 2. Mandatory Environment Variables
The application must have these variables set to function correctly with Vertex AI:
```bash
export GOOGLE_GENAI_USE_VERTEXAI="True"
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_CLOUD_QUOTA_PROJECT="your-project-id"
export GOOGLE_CLOUD_LOCATION="us-central1" # Vertex features are most stable in us-central1
```

### 3. High-Velocity Installation
Use `uv` with an explicit index to bypass registry resolution timeouts and force the Google-specific dependencies:
```bash
uv pip install --index-url https://pypi.org/simple \
    google-adk \
    fastapi \
    uvicorn \
    pydantic \
    --break-system-packages
```

### 4. The Vertex Runner Pattern
Always use the `google.adk.runners.Runner` with an explicit `app_name`. This is required for Vertex AI to correctly track sessions and trace events:
```python
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService # Or VertexAiSessionService for persistence

# app_name MUST match the agent directory name (e.g., 'app')
runner = Runner(
    agent=agent,
    app_name="app",
    session_service=InMemorySessionService()
)

# Execution must be async to handle Vertex streaming events
async for event in runner.run_async(
    user_id=user_id,
    session_id=session_id,
    new_message=types.Content(role="user", parts=[types.Part.from_text(text=msg)]),
):
    if event.is_final_response():
        return event.content.parts[0].text
```

### 5. Why this works:
* **Quota Fix**: `GOOGLE_CLOUD_QUOTA_PROJECT` resolves "Permission Denied" errors that occur when the API cannot find a billing account for the request.
* **Location Fix**: Setting `us-central1` instead of `global` ensures access to the latest model versions and prevents 404/403 errors in newer project environments.
* **Registry Fix**: Forcing the `pypi.org` index prevents `litellm` and other sub-dependencies from attempting to resolve against internal/locked artifact registries.
