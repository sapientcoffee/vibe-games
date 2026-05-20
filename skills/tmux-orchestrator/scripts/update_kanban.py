import os
import re
import sys

def main():
    issue_dir = ".plans"
    state_dir = os.path.join(issue_dir, "swarm-state")
    kanban_file = os.path.join(issue_dir, "KANBAN.md")

    if not os.path.isdir(issue_dir):
        print(f"Error: {issue_dir} is not a directory.", file=sys.stderr)
        return

    os.makedirs(state_dir, exist_ok=True)

    # Dictionary to hold parsed issue details
    issues = {}
    
    # Read all issue files matching issue-*.md
    pattern = re.compile(r"^issue-(\d+)\.md$")
    issue_files = []
    for f in os.listdir(issue_dir):
        match = pattern.match(f)
        if match:
            issue_files.append((int(match.group(1)), f))
    
    # Sort files numerically
    issue_files.sort()

    for idx, f in issue_files:
        issue_id = f"issue-{idx}"
        file_path = os.path.join(issue_dir, f)
        
        # Read the file content
        with open(file_path, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Parse Frontmatter
        frontmatter = {}
        fm_match = re.search(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
        if fm_match:
            fm_text = fm_match.group(1)
            for line in fm_text.splitlines():
                if ":" in line:
                    key, val = line.split(":", 1)
                    key = key.strip()
                    val = val.strip()
                    if val.startswith("[") and val.endswith("]"):
                        # Parse array like [issue-1, issue-2]
                        items = [x.strip() for x in val[1:-1].split(",") if x.strip()]
                        frontmatter[key] = items
                    else:
                        # Strip optional quotes
                        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                            val = val[1:-1]
                        frontmatter[key] = val

        # Get status from .state file, fallback to frontmatter status, fallback to TODO
        state_file_path = os.path.join(state_dir, f"{issue_id}.state")
        if os.path.exists(state_file_path):
            with open(state_file_path, "r", encoding="utf-8") as sf:
                status = sf.read().strip().upper()
        else:
            status = frontmatter.get("status", "TODO").strip().upper()

        # Update frontmatter status in the md file if out of sync
        current_status_in_file = frontmatter.get("status", "TODO").strip().upper()
        if current_status_in_file != status:
            # Replace status: ... in the file
            new_content = re.sub(r"^status:\s*.*", f"status: {status}", content, flags=re.MULTILINE)
            with open(file_path, "w", encoding="utf-8") as file:
                file.write(new_content)
        
        # Extract Phase (default to 1)
        phase_str = frontmatter.get("phase", "1")
        try:
            phase = int(phase_str)
        except ValueError:
            phase = 1

        # Extract Depends On
        depends_on = frontmatter.get("depends_on", [])
        
        # Extract title from h1 or Title header
        title_match = re.search(r"^(# Title:|#\s+)(.*)$", content, re.MULTILINE)
        raw_title = ""
        if title_match:
            raw_title = title_match.group(2).strip()
        else:
            raw_title = frontmatter.get("title", f"Issue {idx}")

        # Extract Tag and Clean Title
        tag_match = re.match(r"^\[(.*?)\]\s*(.*)$", raw_title)
        if tag_match:
            tag = tag_match.group(1).strip()
            clean_title = tag_match.group(2).strip()
        else:
            tag = "TASK"
            clean_title = raw_title

        # Clean title for Mermaid (remove quotes, brackets, parentheses, colons)
        mermaid_title = f"{tag} - {clean_title}"
        mermaid_title = re.sub(r'[:[\]"()\'\\]', ' ', mermaid_title)
        mermaid_title = " ".join(mermaid_title.split()) # normalize spaces

        issues[issue_id] = {
            "id": issue_id,
            "title": raw_title,
            "tag": tag,
            "mermaid_title": mermaid_title,
            "status": status,
            "phase": phase,
            "depends_on": depends_on
        }

    # Group nodes into lanes
    phase1_nodes = []
    phase2_nodes = []
    phase3_nodes = []
    phase4_nodes = []
    inprogress_nodes = []
    done_nodes = []

    # Helper function to format the node
    def format_node(issue):
        return f"    {issue['id']}({issue['mermaid_title']})"

    for issue_id, issue in issues.items():
        status = issue["status"]
        if status == "DONE":
            done_nodes.append(format_node(issue))
        elif status == "IN_PROGRESS" or status == "INPROGRESS":
            inprogress_nodes.append(format_node(issue))
        else: # TODO or anything else
            phase = issue["phase"]
            if phase == 1:
                phase1_nodes.append(format_node(issue))
            elif phase == 2:
                phase2_nodes.append(format_node(issue))
            elif phase == 3:
                phase3_nodes.append(format_node(issue))
            else:
                phase4_nodes.append(format_node(issue))

    # Compile the Mermaid content
    lines = []
    lines.append("# 🚀 Live Build Tracker")
    lines.append("")
    lines.append("```mermaid")
    lines.append("flowchart TD")

    # Phase 1 Subgraph
    lines.append('  subgraph Phase1 ["Phase 1: Setup & Bootstrap (Parallel / Blocking)"]')
    lines.append("    direction TB")
    if phase1_nodes:
        lines.extend(phase1_nodes)
    else:
        lines.append("    None1(None)")
    lines.append("  end")
    lines.append("")

    # Phase 2 Subgraph
    lines.append('  subgraph Phase2 ["Phase 2: Backend Tools & Agent (Parallel / Priority)"]')
    lines.append("    direction TB")
    if phase2_nodes:
        lines.extend(phase2_nodes)
    else:
        lines.append("    None2(None)")
    lines.append("  end")
    lines.append("")

    # Phase 3 Subgraph
    lines.append('  subgraph Phase3 ["Phase 3: Frontend UI (Parallel)"]')
    lines.append("    direction TB")
    if phase3_nodes:
        lines.extend(phase3_nodes)
    else:
        lines.append("    None3(None)")
    lines.append("  end")
    lines.append("")

    # Phase 4 Subgraph
    lines.append('  subgraph Phase4 ["Phase 4: Integration (Blocking)"]')
    lines.append("    direction TB")
    if phase4_nodes:
        lines.extend(phase4_nodes)
    else:
        lines.append("    None4(None)")
    lines.append("  end")
    lines.append("")

    # In Progress Subgraph
    lines.append('  subgraph InProgress ["In Progress"]')
    lines.append("    direction TB")
    if inprogress_nodes:
        lines.extend(inprogress_nodes)
    else:
        lines.append("    NoneInProgress(None)")
    lines.append("  end")
    lines.append("")

    # Done Subgraph
    lines.append('  subgraph Done ["Done"]')
    lines.append("    direction TB")
    # Always include VibeCheck and Blueprint in Done, as they were the pre-requisite completed tasks
    lines.append("    VibeCheck(Vibe Check - Completed)")
    lines.append("    Blueprint(Blueprint - Completed)")
    if done_nodes:
        lines.extend(done_nodes)
    lines.append("  end")
    lines.append("")

    # Dependency Connections
    lines.append("  %% Dependency Connections")
    for issue_id, issue in issues.items():
        for dep in issue["depends_on"]:
            if dep in issues:
                lines.append(f"  {dep} --> {issue_id}")

    lines.append("```")

    # Write KANBAN.md
    with open(kanban_file, "w", encoding="utf-8") as kf:
        kf.write("\n".join(lines) + "\n")

    # Now print terminal display
    print("\033[1;36m============================================================\033[0m")
    print("\033[1;35m             🔥 SWARM LIVE KANBAN TRACKER 🔥                \033[0m")
    print("\033[1;36m============================================================\033[0m\n")

    print("\033[1;34m📋 [ TO DO (PHASED) ]\033[0m")
    for phase_num, nodes in [(1, phase1_nodes), (2, phase2_nodes), (3, phase3_nodes), (4, phase4_nodes)]:
        if nodes:
            print(f"  \033[1;30mPhase {phase_num}:\033[0m")
            for node in nodes:
                m = re.match(r"^\s*(issue-\d+)\((.*)\)$", node)
                if m:
                    print(f"    • {m.group(1)}: {m.group(2)}")
    print("")

    print("\033[1;33m⚡ [ IN PROGRESS ]\033[0m")
    if inprogress_nodes:
        for node in inprogress_nodes:
            m = re.match(r"^\s*(issue-\d+)\((.*)\)$", node)
            if m:
                print(f"    ⚡ \033[1;33m{m.group(1)}: {m.group(2)} 🚀\033[0m")
    else:
        print("    (None)")
    print("")

    print("\033[1;32m✅ [ DONE ]\033[0m")
    print("    ✓ Vibe Check - Completed")
    print("    ✓ Blueprint - Completed")
    if done_nodes:
        for node in done_nodes:
            m = re.match(r"^\s*(issue-\d+)\((.*)\)$", node)
            if m:
                print(f"    ✓ \033[1;32m{m.group(1)}: {m.group(2)}\033[0m")
    print("")
    print("\033[1;36m============================================================\033[0m")
    print("\033[1;30mUpdating live every 2 seconds... Press C-c to stop.\033[0m")

if __name__ == "__main__":
    main()