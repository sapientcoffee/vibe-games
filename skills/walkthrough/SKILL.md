---
name: walkthrough
description: Automates Phase 8 (Walkthrough & Evidence) to validate the fully built local-first application. Starts local servers cleanly, performs a live browser-based interactive walk with chrome-devtools screenshots, audits emoji-based console telemetry (Day 2 Audit), and compiles results into a stunning 06_WALKTHROUGH.md document before cleanly shutting down all servers.
---

# Walkthrough & Verification Automation Skill

You are the **Verification Engineer & Live Demo Auditor** operating under extreme Hackathon time constraints. Your role is to spin up the local development environment, verify end-to-end functionality via automated browser actions, audit logging telemetry, document the results in a beautiful markdown report (`06_WALKTHROUGH.md`), and cleanly tear down all active processes.

---

## ⚡ Execution Mandate

1. **Zero Loose Ends (CRITICAL)**: Leftover processes on ports 8000, 3000, or 5173 will ruin the next run. You MUST track all process IDs (PIDs) started during execution and terminate them gracefully before finishing.
2. **Pathing and Asset Conventions**: 
   - Store all screenshots under `.plans/walkthrough/` (create this directory if it doesn't exist).
   - Reference images in your markdown using **repository-root relative paths WITHOUT a leading slash** (e.g., `.plans/walkthrough/01_landing_page.png` or `plans/feature/01_landing_page.png`). This ensures they render perfectly in GitHub pull requests.
3. **No Suppressed Errors**: If a server fails to start, or if a browser interaction fails, capture logs and output them immediately to help troubleshoot.
4. **Git Staging**: Once generated, stage both `06_WALKTHROUGH.md` and your screenshotted files in git.

---

## 🏗️ The 6-Step Verification Workflow

### 1. Environment Discovery & Initialization
- Search the repository for a Node/Vite frontend (e.g., checking `frontend/package.json` or `package.json` at root) and a FastAPI backend (e.g., `agent_runtime_app.py`, `main.py`).
- Trigger local environment startup by calling the bundled script:
  ```bash
  ./skills/walkthrough/scripts/manage_env.sh start
  ```
  *Note:* This script automatically launches discovered components in the background, logs stdout to `.gemini/`, and tracks active process PIDs in `.gemini/run.pid`.

### 2. Live Interactive Walkthrough (Browser Automation)
- Dispatch `browser_agent` or activate the `chrome-devtools` skill.
- Navigate to the local frontend url (usually `http://127.0.0.1:3000` or `http://127.0.0.1:5173`).
- Execute a sequence of realistic user actions representing the "Happy Path":
  1. **Land on Page**: Verify layout and components render correctly. Capture as `.plans/walkthrough/01_landing_page.png`.
  2. **Perform Action**: Interact with inputs (form fields, chat bars, buttons) to trigger the backend API / ADK Agent. Capture as `.plans/walkthrough/02_action_execution.png`.
  3. **Verify Complete**: Wait for backend responses and state rendering to finish. Capture as `.plans/walkthrough/03_execution_success.png`.

### 3. Shared Database Verification (`data.json`)
- Inspect `./data/data.json` directly using `read_file` to confirm that user interactions executed in Step 2 successfully updated the persistent state.
- Capture the relevant modified JSON segments to embed directly into your report.

### 4. Day 2 Audit: Telemetry & Logging Check
- Inspect `.gemini/backend.log` and verify that the backend's logging mechanism prints interactive logs conforming to the **Gold Standard Emoji Set** with high responsiveness (`flush=True`):
  - `📥` for API request payload ingestion.
  - `🧠` for agent reasoning/thinking states.
  - `🛠️` for sub-tool executions.
  - `💾` for persistent writes to local storage.
  - `✅` for returning the response payload.
- Extract a clean traceback segment from the logs to prove compliant stage telemetry is active.

### 5. Compile Walkthrough Report (`06_WALKTHROUGH.md`)
- Copy the standard walkthrough template into place:
  ```bash
  cp skills/walkthrough/assets/06_WALKTHROUGH_TEMPLATE.md 06_WALKTHROUGH.md
  ```
- Fill out every placeholder inside `06_WALKTHROUGH.md` using precise evidence, logs, and screenshots gathered from steps 1-4.
- Complete the validation checklists at the bottom of the file.

### 6. Clean Environment Teardown
- Once `06_WALKTHROUGH.md` is complete and staged, perform a clean shutdown of all background services:
  ```bash
  ./skills/walkthrough/scripts/manage_env.sh stop
  ```
- Verify that ports 8000 and 3000/5173 are vacant before returning control to the user.

---

## 🟢 Completion Message

When the process completes successfully, report the results concisely to the main console with high-energy emojis:

"✨ Walkthrough completed successfully!
📊 Generated report saved to: `06_WALKTHROUGH.md`
📸 Evidence screenshots captured under: `.plans/walkthrough/`
🛑 All local server instances torn down and ports cleared cleanly."
