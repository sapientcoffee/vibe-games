---
name: build-ui
description: A deterministic pipeline skill that reads an issue file, builds a stunning React frontend using the Tailwind CDN bypass, updates the state file, and exits immediately.
---

# Execution Mandate
1. **Target**: Read the attached `.plans/issue-*.md` and build the requested UI components.
2. **Tech Stack & The Tailwind Bypass (CRITICAL FOR SPEED)**: 
   - Scaffold the app using ONLY non-interactive flags: `npm create vite@latest frontend -- --template react-ts -y`
   - **DO NOT** run `npm install tailwindcss` or create configuration files. 
   - Instead, immediately overwrite `frontend/index.html` to inject the Tailwind CDN directly into the `<head>`: `<script src="https://cdn.tailwindcss.com"></script>`
   - Use Tailwind utility classes for all styling. Do not write custom CSS.
3. **Parallel Tolerance & Data Binding**: 
   - Map all layout values directly to the schema in `../data/data.json`.
   - **CRITICAL**: The backend API is being built in parallel and may not be bound to a port yet. You MUST write your fetch calls to handle network failures gracefully. If the backend is unreachable, simulate the API response with a 1-second delay using local state variables so the UI remains fully interactive on stage.
4. **Spectator Component (LIVE VIBES)**: 
   - You MUST include a "Status" or "Live Log" visual component in the UI. When a user triggers an action, show a sleek loading state (e.g., "🧠 Agent is thinking...") to provide visual feedback while the background processes run.
5. **State Management (No Hangs)**: 
   - Immediately upon starting, run: `echo "IN_PROGRESS" > .plans/swarm-state/<issue_id>.state`
   - When finished writing the code, run: `echo "DONE" > .plans/swarm-state/<issue_id>.state`
6. **No Chatting**: Do not ask follow-up questions. Write the code, update the state file, and terminate.