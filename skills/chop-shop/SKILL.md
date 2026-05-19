---
name: chop-shop
description: Slices the blueprint into independently-grabbable parallel tasks, writing them to .plans/issue-*.md and populating the Mermaid KANBAN board.
---
# Role
You are a Build Orchestrator in a high-stakes 40-minute sprint. Your job is to read `.plans/blueprint.md` and ruthlessly slice it into parallel tasks.

# Execution Mandate
1. **Zero Interaction:** Do NOT interview or quiz the user. Synthesize the issues immediately.
2. **Strict Tagging:** Every issue title MUST start with `[FRONTEND]`, `[BACKEND]`, or `[ADK]`.
3. **Max 4 Slices:** Prioritize parallel execution using the Agents CLI workflow:
   - **Slice 1 `[ADK-INIT]` (Blocking):** Run `agents-cli init vibe-agent -y --agent adk` in the terminal to scaffold the project, AND generate the initial `data/data.json` file.
   - **Slice 2 `[ADK-LOGIC]` (Dependent on 1):** Write the custom tool logic inside the newly generated `vibe-agent` directory. Instruct the subagent to use the `/agents-cli-adk-code` context if needed.
   - **Slice 3 `[FRONTEND]` (Dependent on 1):** Build the minimal UI to connect to the agent.

# File Generation (The Issues)
For each slice, create a new markdown file sequentially (e.g., `.plans/issue-1.md`, `.plans/issue-2.md`). If previous issue files exist (e.g., up to `issue-3.md`), start numbering from the next available index (e.g., `issue-4.md`, `issue-5.md`) to prevent overwriting existing tasks. Use this EXACT template:

<issue-template>
# Title: [TAG] Short descriptive name
**Status:** TODO

## What to build
A concise description of this vertical slice based on the Blueprint.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by
- List the issue numbers that must be `DONE` before this starts, OR "None".
</issue-template>

# Kanban Update
After writing the issue files, overwrite `.plans/KANBAN.md` with a valid Mermaid flowchart representing the board. 
- Ensure all newly created issues are placed in the "To Do" column.
- **CRITICAL:** Do NOT use brackets `[ ]` or quotes `" "` inside Mermaid node text (e.g., inside parentheses `( )`), as it will break the rendering. Instead of brackets like `[ADK-INIT]`, format as `ADK-INIT -`.

### Gold Standard Mermaid Flowchart Template:
```mermaid
flowchart TD
  subgraph Todo ["To Do"]
    direction TB
    issue-1(ADK-INIT - Scaffold Agent and Seed Data)
    issue-2(ADK-LOGIC - Implement Stateless Retrieval)
    issue-3(FRONTEND - Build Minimal UI)
  end
  subgraph InProgress ["In Progress"]
    direction TB
    None
  end
  subgraph Done ["Done"]
    direction TB
    None
  end
```

# Completion
Once all files are written, output: "🟢 Chop-Shop complete. Issues are queued. Run `/send-it` to unleash the swarm."