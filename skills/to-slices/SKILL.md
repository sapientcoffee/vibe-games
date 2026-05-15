---
name: to-slices
description: Break a plan, spec, or PRD into independently-grabbable issues stored in .plan/issues/ using vertical and parallel slices. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

Break a plan into independently-grabbable issues using vertical and parallel slices. For scratch builds, prioritize parallel execution and isolated components.  Do NOT interview the user — just synthesize what you already know.

## Process

### 1. Delegate to Planner
Invoke `vibe-planner` using `invoke_agent` with the following strict instruction:
"Break the following PRD into atomic, parallel 5-minute implementation slices. **Do NOT generate a PRD or repeat the problem statement.** Output ONLY a numbered list of slices. Each slice title MUST start with `BACKEND -` or `FRONTEND -` (do NOT use brackets)."

- **Tagging**: Mandate that the planner adds `FRONTEND -` or `BACKEND -` to every ticket title.
- **Model**: This leverages Gemini 3.1 Pro for the most efficient task breakdown.

### 2. Gather context
...
### 4. Quiz the user
Present the proposed breakdown from the planner as a numbered list. Ensure the `[FRONTEND]` and `[BACKEND]` tags are visible.

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Store the issues in .plans/issues/

For each approved slice, create a new markdown file in `.plans/issues/` (e.g., `0001-setup-bridge.md`). Use the issue body template below.

<issue-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Verification Procedure

Detailed instructions on how to verify this slice.
- **Logs/Outputs:** Capture and save to `.plan/issues/<issue_id>-verification.md`.
- **UI/Web:** Use `browser_agent` to navigate, verify behavior, and capture screenshots.
- **Evidence:** All logs, screenshots, and terminal outputs must be referenced in the verification document.

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

Do NOT close or modify any parent issue.