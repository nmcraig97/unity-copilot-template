# GitHub Copilot Instructions

## Project Overview
<!-- Replace the placeholders below with your project's details -->
This is a Unity project called "{PROJECT_NAME}" using:
- {RENDER_PIPELINE} (e.g., URP, HDRP, Built-in)
- {INPUT_SYSTEM} (e.g., New Input System, Legacy)
- {PATHFINDING} (e.g., NavMesh, A*, custom)

## Backlog / Deferred Features
<!-- Track features you've discussed with Copilot but deferred. Example format: -->

### {System Name}
- [ ] **{Feature}** — {Brief description of what it does and why it's deferred}

## Cross-System Integration

### Communication Patterns
- **C# events** (`event Action<T>`) are the primary cross-system notification mechanism — no UnityEvents, no event bus
- **Singleton.Instance** for direct state queries; events for async notifications (hybrid pattern)
- **Self-registering registries** for lifecycle decoupling (e.g., SaveManager, manager registries)
- **Computed properties over event-cached counters** for aggregate queries across small collections (<50 items) — event caches risk permanent desync if any event is missed (object destroyed, removed before callback fires)
- **Isolate refactors from feature additions** — when adding support for a new consumer, add the new path without touching the existing working path. Consolidation is a separate cleanup task

### Interface Contracts
<!-- Document your project's key interfaces here. Example format: -->
<!-- - **ISaveable**: `SaveID` (unique string), `CaptureState()` → object, `RestoreState(string)`. Self-register in OnEnable, unregister in OnDisable. SaveManager discovers all automatically. -->
<!-- - **ISelectable**: `OnSelect()`, `OnDeselect()`, `IsSelected`, `SelectionCollider`, `Transform`. Narrow interface — prefer composition. -->

### ScriptableObject Name Resolution (Optional)
<!-- If your save system serializes SO references by name, document the resolution pattern here -->
<!-- All ScriptableObject references in save data are serialized by `ScriptableObject.name` and resolved via `GameRegistry.Resolve*()` typed dictionary methods. No generic Resolve<T>. -->

### Stat Modifier System (Optional)
<!-- If your project uses a stat/modifier system, document computation order and init layering here -->
<!-- Example: -->
<!-- - **Computation order**: base → +additive sum → ×multiplicative product → override (last override wins) -->
<!-- - **Init layering**: Awake (base stats) → Start (equipment Override) → Start (trait Additive/Multiplicative) -->

## Customization Structure
System-specific knowledge is in `.github/instructions/` (auto-loaded via `applyTo` globs and `description` keywords). Deep architecture docs are in `.github/skills/*/references/`. See `.github/instructions/CHANGELOG.md` for lesson audit trail.

**Planning mode**: When planning or designing features that span multiple systems, proactively read the instruction files for ALL systems that will be touched — `applyTo` globs only fire on file edits, not during planning conversations. Check instruction `description` fields against the task scope and read any that overlap.

## Knowledge Maintenance
When you diagnose and fix a bug or implementation issue:
1. **Propose, don't write:** Present the proposed lesson to the user with the target `.github/instructions/` file and section. Wait for explicit approval before writing.
2. **Dedup + conflict check:** Read the existing `## Lessons Learned` and `## Patterns` sections — do not add duplicates, and flag contradictions to the user instead of writing.
3. **Write:** Append with date: `- **[YYYY-MM-DD]**: [what went wrong] → [what to do instead]`
4. **Log:** Append a one-line entry to `.github/instructions/CHANGELOG.md`. Then count all log entries below the `Last audit:` line — if the count hits the audit threshold (5 initial, then every 3), flag that a regression test is due.
5. **Overflow guard:** If the instruction file exceeds 50 lines after the addition, move the oldest lessons to the corresponding skill's `references/` folder under a `## Historical Lessons` section.

### Key Files Maintenance
When a task reveals that a Key Files entry is outdated (script renamed, moved, or deleted), update it directly. No approval needed for Key Files corrections — they are factual, not behavioral.

### Friction Detection
If a task requires more than one correction prompt after initial implementation (back-and-forth debugging), flag the root cause as a lesson candidate once the fix is confirmed. Propose it with target file and section.

## Code Conventions
- Use `[SerializeField]` with `[Tooltip()]` for inspector fields
- Use `#region` blocks to organize code sections
- Use XML documentation comments for public APIs
- Prefer composition over inheritance
- Use `ReadOnlyAttribute` for debug fields in inspector

## UI Theme
<!-- Replace with your project's UI package -->
<!-- - Use **{UI_PACKAGE}** for all new UI -->
<!-- - Use `{STYLING_UTILITY}` for programmatic styling -->

## Input System Structure
<!-- Document your project's input action maps -->
<!-- Example: -->
<!-- - **Selection** action map: Select, MultiSelect, SelectPosition, Command -->
<!-- - **Camera** action map: Pan, Rotate, Zoom, PitchDrag, MouseDelta -->

## GitHub Repository
<!-- Replace with your project's repo details -->
- **Repo**: `{REPO_OWNER}/{REPO_NAME}` (private)
- **Default branch**: `{DEFAULT_BRANCH}`
- **Connection method**: Use the PAT from `.vscode/mcp.json` (`servers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN`) with `Invoke-RestMethod` and an `Authorization: token <PAT>` header against the GitHub REST API (`https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/...`). Do not rely on the MCP server being connected.

## Prefab Handling
- **NEVER** assume a prefab's hierarchy based on code that references it. Always open and read the actual `.prefab` YAML file to discover the real structure.
- If you cannot locate the prefab file with high confidence, **stop and ask** the user for the exact path before proceeding.
- Only add/modify components on existing GameObjects — do not create or destroy GameObjects in prefab setup scripts unless explicitly asked.

## Copilot Workflow Preferences
- **Plan mode**: Provide only the written plan, decisions, and questions — no code blocks. The user will switch to agent mode when satisfied with the plan.
- **Agent mode**: Implement the plan directly by creating/editing files.
