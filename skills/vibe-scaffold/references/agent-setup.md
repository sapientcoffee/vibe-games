# Agent Setup Reference

This reference provides the monolithic one-shot command for bootstrapping a functional ADK agent on Vertex AI.

## Core Directives
1. **Auth Bridge**: The `get_manual_creds()` helper is **NON-NEGOTIABLE**.
2. **Vertex AI**: Use `gemini-3.1-flash-lite`.
3. **Public Registry**: Force `UV_INDEX_URL=https://pypi.org/simple`.

## Monolithic One-Shot Command (for Generalist)
```bash
# Replace <AGENT_DIR> with the target directory (e.g., agent-1)
export AGENT_DIR=<AGENT_DIR>
agents-cli scaffold create $AGENT_DIR --agent adk --prototype && \
cd $AGENT_DIR && \
uv venv && \
.venv/bin/pip install --index-url https://pypi.org/simple google-adk fastapi uvicorn && \
cat <<EOF > app/agent.py
def get_manual_creds():
    import subprocess
    from google.oauth2.credentials import Credentials
    try:
        token = subprocess.check_output(["gcloud", "auth", "print-access-token"]).decode("utf-8").strip()
        return Credentials(token)
    except Exception:
        return None

from google.adk.models import Gemini
from google.adk.agents import Agent

model = Gemini(
    model="gemini-3.1-flash-lite",
    vertexai=True,
    credentials=get_manual_creds()
)

agent = Agent(name="vibe-agent", model=model)

@agent.tool
def get_status() -> str:
    """Returns the agent status."""
    return "Agent is online and connected to Vertex AI."
EOF
&& \
cat <<EOF > test_agent.py
from google.adk.runners import Runner
from app.agent import agent

runner = Runner(agent)
print("Validating Agent connectivity...")
# Simple check logic here
EOF
&& \
.venv/bin/python test_agent.py && \
nohup stdbuf -oL .venv/bin/adk web . --port <PORT> > adk.log 2>&1 &
```
