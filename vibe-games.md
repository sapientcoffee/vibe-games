# Vibe Games Extension Context

This extension provides specialized commands, skills, subagents, and tools for the Vibe Games Competition.

## Core Mandates
1. **Vertical Slice Priority**: Never build horizontal layers. Always build a "Tracer Bullet" that connects UI -> Bridge -> Agent Tool in one turn.
2. **Bridge Protocol**: All communication between the React Frontend and ADK Agent MUST pass through the FastAPI bridge in `bridge/main.py`.
3. **Validation**: Every Agent tool change must be verified with `agents-cli eval` or a direct test script before being wired to the UI.

## Environment Overrides (Agent Platform / Restricted Vertex)
If working in the 'Agent Platform' environment (e.g., `coffee-and-codey` project), follow these strict protocols to ensure Vertex connectivity:

### 1. Model Configuration
* **Use Direct IDs**: Do NOT use model aliases (like `gemini-flash-latest`) or full publisher paths. Use the direct IDs found in the Agent Platform Studio (e.g., `gemini-3.1-flash-lite`).
* **Standard ADK Setup**:
```python
model=Gemini(
    model="gemini-3.1-flash-lite", # Direct ID required
    vertexai=True,
    # Manual credential bridge to sync gcloud session
    credentials=get_manual_creds()
)
```

### 2. The Credential Bridge
Always include this helper in `agent.py` to prevent 403 errors where Python's ADC differs from the terminal's `gcloud` session:
```python
def get_manual_creds():
    import subprocess
    from google.oauth2.credentials import Credentials
    try:
        token = subprocess.check_output(["gcloud", "auth", "print-access-token"]).decode("utf-8").strip()
        return Credentials(token)
    except Exception:
        return None
```

### 3. Dependency Installation
* **Force Public Registry**: Always use `--index-url https://pypi.org/simple` when installing packages to bypass 403 errors from internal Google registries.
* **Example**: `uv pip install --index-url https://pypi.org/simple google-adk fastapi uvicorn`

### 4. Background Service Orchestration
* **Absolute Paths**: When spawning background processes (Bridge, ADK UI), always use absolute paths for the `PYTHONPATH` and the virtual environment binary.
* **Line Buffering**: Use `stdbuf -oL -eL` to ensure logs are written to files immediately for troubleshooting.
* **Example**:
  `nohup PYTHONPATH=$(pwd) .venv/bin/python3 bridge/main.py > bridge.log 2>&1 &`

### 5. Infrastructure Troubleshooting
* If 403s persist after granting `aiplatform.admin`, ensure the **AI Platform Service Agent** has the consumer role:
  `gcloud projects add-iam-policy-binding [PROJECT_ID] --member="serviceAccount:service-[PROJECT_NUMBER]@gcp-sa-aiplatform.iam.gserviceaccount.com" --role="roles/serviceusage.serviceUsageConsumer"`

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
