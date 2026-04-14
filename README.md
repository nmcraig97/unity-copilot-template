# Unity Copilot Architecture Template

A reusable GitHub Copilot customization framework for Unity projects. Provides structured instruction files, domain skills, plan-review agents, prompt templates, and VS Code configuration.

## What's Included

### Agents (`.github/agents/`)
| Agent | Purpose |
|-------|---------|
| **plan-refine** | Orchestrates multi-dimension plan review. Launches 3 specialized reviewers, consolidates findings, resolves conflicts, and produces a revised plan. |
| **robust-reviewer** | Evaluates plans for edge cases, race conditions, event desync, state machine gaps, and Unity lifecycle pitfalls. |
| **perf-reviewer** | Evaluates plans for algorithmic complexity, allocation patterns, scalability bottlenecks, and Unity-specific performance pitfalls. |
| **simple-reviewer** | Evaluates plans for over-engineering, unnecessary abstractions, scope creep, and clarity issues. |
| **plan-benchmark** | Tests the plan-refine system against known ground-truth defects. Scores recall, precision, actionability, coverage, and consolidation quality. |

### Instructions (`.github/instructions/`)
System-specific knowledge files that auto-load via `applyTo` glob patterns when editing matching files. Each instruction file documents:
- **Key Files** — important scripts and their purposes
- **Patterns** — critical flows and conventions
- **Integration Points** — cross-system connections
- **Lessons Learned** — bug fixes and hard-won knowledge (auto-maintained by Copilot)

### Skills (`.github/skills/`)
Deep architecture documentation loaded on demand. Each skill folder contains:
- `SKILL.md` — when to use, approach, critical patterns
- `references/` — detailed architecture docs (overflow destination for lessons)

### Prompts (`.github/prompts/`)
| Prompt | Purpose |
|--------|---------|
| **regression-test** | Auto-verify instruction/skill accuracy against codebase (run after lessons accumulate) |
| **new-system-scaffold** | Guided workflow to scaffold a new system end-to-end |

### Hooks (`.github/hooks/`)
Pre-tool-use guard that requires approval before modifying `.github/` files — prevents accidental edits to the customization framework.

### VS Code Config (`.vscode/`)
Unity-optimized settings: YAML file associations for Unity files, Library/Temp/obj exclusions, meta file nesting, debug attach config, and extension recommendations.

---

## Setup

### 1. Copy into your Unity project

Copy the `.github/` and `.vscode/` folders into your Unity project root.

### 2. Find and replace placeholders

Search for `{` across all files and replace each placeholder:

| Placeholder | Where | What to fill in |
|-------------|-------|-----------------|
| `{PROJECT_NAME}` | `copilot-instructions.md`, `settings.json` | Your project's name |
| `{RENDER_PIPELINE}` | `copilot-instructions.md` | URP, HDRP, or Built-in |
| `{INPUT_SYSTEM}` | `copilot-instructions.md` | New Input System or Legacy |
| `{PATHFINDING}` | `copilot-instructions.md` | NavMesh, A*, or custom |
| `{REPO_OWNER}/{REPO_NAME}` | `copilot-instructions.md` | Your GitHub repo path |
| `{DEFAULT_BRANCH}` | `copilot-instructions.md` | `main`, `master`, etc. |
| `{YOUR_GITHUB_PAT}` | `mcp.json` | Your GitHub Personal Access Token |
| `{DATE}` | `CHANGELOG.md` | Today's date (YYYY-MM-DD) |

### 3. Uncomment optional sections

In `copilot-instructions.md`, uncomment and fill in sections that apply to your project:
- **Interface Contracts** — document your key interfaces
- **UI Theme** — your UI package and styling utility
- **Input System Structure** — your action maps
- **Stat Modifier System** — if your project uses stat/modifier systems
- **SO-Name Resolution** — if your save system uses ScriptableObject name resolution

### 4. Create your first instruction file

Copy `.github/instructions/_TEMPLATE.instructions.md` to a new file named after your first system (e.g., `player-controller.instructions.md`). Fill in:
- `applyTo` glob pattern matching your script folder
- `description` with key class names and domain keywords
- Key Files table with your main scripts
- Patterns section with critical flows

### 5. Create your first skill (optional)

Copy `.github/skills/_TEMPLATE/` to a new folder named after a system that needs deep documentation. Fill in the `SKILL.md` and add architecture docs to `references/`.

### 6. Test the plan-refine system

1. Write a short implementation plan in a markdown file (e.g., `Documentation/plans/my-feature.md`)
2. In VS Code Copilot chat, invoke: `@plan-refine Documentation/plans/my-feature.md`
3. Verify it reads your instruction files, launches all 3 reviewers, and produces consolidated output

### 7. Set up benchmarking (optional)

To benchmark the plan-refine system:
1. Create `Documentation/benchmarks/scoring-matrix.md` with the rubric (or use the defaults in `plan-benchmark.agent.md`)
2. Write a plan with known defects
3. Document the defects in a ground-truth file
4. Run: `@plan-benchmark path/to/plan.md path/to/ground-truth.md`

---

## How It Works

### Knowledge Maintenance Cycle

```
Bug diagnosed → Lesson proposed → User approves → Written to instruction file
→ Logged to CHANGELOG.md → Audit threshold check → Regression test if due
→ Overflow guard moves old lessons to skill references/
```

This cycle is fully automated by Copilot — you just approve or reject proposed lessons.

### Plan Review Flow

```
User writes plan → @plan-refine reads plan
→ Detects relevant domains from instruction files
→ Launches robust-reviewer → perf-reviewer → simple-reviewer
→ Consolidates findings (dedup, conflict resolution, severity ranking)
→ Presents structured report with findings, conflicts, and design questions
→ User responds → Plan revised → Selective re-review if needed
```

### Instruction Layering

```
copilot-instructions.md          (always loaded — project-wide conventions)
  └── instructions/*.instructions.md  (auto-loaded via applyTo globs)
        └── skills/*/SKILL.md          (loaded on demand for deep context)
              └── skills/*/references/  (architecture docs + historical lessons)
```

---

## File Structure

```
.github/
├── copilot-instructions.md
├── agents/
│   ├── plan-refine.agent.md
│   ├── robust-reviewer.agent.md
│   ├── perf-reviewer.agent.md
│   ├── simple-reviewer.agent.md
│   └── plan-benchmark.agent.md
├── hooks/
│   ├── instruction-guard.json
│   └── instruction-guard.ps1
├── instructions/
│   ├── CHANGELOG.md
│   └── _TEMPLATE.instructions.md
├── prompts/
│   ├── regression-test.prompt.md
│   └── new-system-scaffold.prompt.md
└── skills/
    └── _TEMPLATE/
        ├── SKILL.md
        └── references/
            └── .gitkeep
.vscode/
├── settings.json
├── launch.json
├── extensions.json
└── mcp.json
```

## Requirements

- VS Code with GitHub Copilot extension
- Unity project (any version, any render pipeline)
- Windows (hooks use PowerShell 5.1)
- Node.js (for GitHub MCP server, optional)
