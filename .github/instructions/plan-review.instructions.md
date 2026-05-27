---
description: "Use when reviewing implementation plans, refining plans, planning features, drafting multi-step implementation proposals, or performing post-implementation code reviews. Covers plan completeness, risk review, trade-off resolution, and code-vs-plan drift analysis."
---
# Plan Review

## Review Session Cap

Pre-implementation plan review has diminishing returns. Follow these limits:
- **Maximum 2 pre-implementation review sessions** per plan document
- If the second session finds **fewer than 3 new findings**, stop reviewing — further sessions will not meaningfully reduce risk
- Remaining risk is better caught by post-implementation code review and testing (see § Post-Implementation Code Review below)
- If a review triggers significant plan rewrites, that counts as a new plan — the cap resets

## Self-Check Rule
Before emitting any finding, argue the counter-position. If the counter-argument survives (the plan's approach is justified given stated goals), do NOT emit the finding. Only report issues where the plan should actually change.

## Step 0 — Load Prior Findings (BLOCKING)

**Do this BEFORE any other work. Do not proceed to Step 1 until complete.**

1. Run `memory view /memories/session/` to list session files
2. If `review-findings.md` exists, run `memory view /memories/session/review-findings.md` and read it
3. If prior findings exist for this plan, treat them as already-discovered — only search for NEW findings not already listed
4. If no prior findings exist, proceed normally

## Mechanical Verification (do FIRST, before any codebase exploration)

Complete ALL mechanical checks before launching any Explore subagent or heavy file reads. These are high-hit-rate, low-token-cost checks.

### Step 1 — Assumption Extraction (text-only, no tools)
Read the plan and build a checklist of every verifiable assumption:
- **Methods called**: every method the plan calls on existing classes (e.g., `poiManager.RegisterDynamicPOI()`)
- **Fields/properties accessed**: every field the plan reads/writes, noting assumed access modifiers
- **Events fired/subscribed**: every EventBus event referenced
- **File paths**: every source file path mentioned — flag nested classes referenced as standalone files
- **Properties removed**: every removal — needs caller verification
- **Enum values used**: every enum value referenced — verify it exists in the enum definition

### Step 2 — Batch grep verification (parallel grep_search, NOT Explore subagents)
Run parallel `grep_search` calls for each assumption from Step 1:
- Method exists? `grep "RegisterDynamicPOI"` 
- Field access modifier? `grep "bossGate"` in the owning class
- Callers of removed property? `grep "AggregateCurrentHP"`
- Event subscribers? `grep "OnUnitDamaged"`
- Nested vs standalone? `grep "class EncounterTrigger"`

Each grep costs ~100 tokens vs ~3000-5000 for an Explore subagent reading full files. Use grep for existence/caller checks; reserve Explore for multi-file reasoning.

### Step 3 — Internal consistency (text-only, no tools)
Check the plan against itself:
- Docstrings/comments match the code direction they describe
- Section A's assumptions match section B's behavior
- Config lookup patterns handle ALL node/entity types (no special cases missed)
- Cross-references between sections agree on signatures, parameters, and field names
- Sentinel values and edge cases are documented (e.g., what happens when saved value is 0?)

### Step 4 — Removal safety (grep_search)
For every property/method/event being removed, grep for ALL callers across the codebase. Confirm the plan explicitly migrates each one. List the file:line for each caller alongside the plan section that handles it. Flag any unaddressed callers.

## Domain Prioritization

Identify which domains the plan touches and weight your review accordingly:

| Domain | Emphasis |
|--------|----------|
| AI, combat, state machines | Robustness — state machine gaps and race conditions are highest-risk |
| Save/load, persistence | Robustness — data loss and desync are critical; simplicity for maintainability |
| UI, panels, data binding | Balance robustness and simplicity equally |
| Core infrastructure, pooling | Balance robustness and performance — must be correct AND fast |
| Procedural generation | Performance + simplicity — fast algorithms, clear code |
| Multi-system / mixed | Default to robustness; escalate performance for hot-path systems |

## Completeness Checks

Before reviewing for risks, verify the plan is complete:

1. **State enum audit**: Read matched instruction files' Key Files and Patterns sections. If any document existing states/enums/phases, verify the plan accounts for ALL existing states — not just new ones. Flag missing states as integration gaps.
2. **Cross-system patterns**: Check `copilot-instructions.md` § Cross-System Integration. For each pattern the plan touches, verify it's addressed:
   - Does the plan isolate refactors from feature additions (separate new path from existing)?
   - Does the plan use computed properties instead of event-cached counters for small collections?
   - If adding interface implementations, does the plan address all members?
3. **Cross-batch modifications list**: Verify the plan's cross-batch modification list includes ALL files that will be touched. grep for subscribers to modified events and consumers of modified APIs. Flag any file that will need changes but isn't listed.
4. **Integrity gates for evolving collections**: If the plan introduces a system that writes to a persistent pool or collection that improves over time (optimizer seed pools, save slots, upgrade inventories, difficulty parameter stores, scored config libraries), verify all four components are planned:
   - **Quality floor** — reject additions below a minimum threshold
   - **Improvement gate** — reject unless the addition beats the current best by a margin
   - **Pool cap + pruning** — evict the lowest-quality member when the collection is full
   - **Quality metadata on items** — each item carries its own score so gates can operate without external tracking
   All gates should be config-driven and default to disabled (zero/off) so existing behaviour is unchanged until activated. Flag plans that introduce such collections without this analysis.

## Architectural Analysis (use Explore subagents here, AFTER mechanical verification)

Spend exploration budget on questions that require multi-file call-chain reasoning. These find the highest-value bugs (event timing, race conditions, data flow gaps):

- **Event lifecycle tracing**: For each new event wiring, trace: who fires → who subscribes → when does the subscriber first need data → does the fire happen before or after? Flag ordering gaps.
- **Initialization flow**: For each new `Initialize()` / setup method, trace who calls it and when. Verify all dependencies are available at call time.
- **Damage/data routing**: For refactors that reroute data flow, trace ALL paths (not just the obvious ones). Flag any path the plan doesn't address.
- **Scene-access responsibility**: Flag any plan that assigns `GameManager.TransitionTo`, `BattleConfig.Pending` assignment, or `TransitionContext` construction to a plain C# class (non-MonoBehaviour, non-singleton). These require scene access and must live on a MonoBehaviour or singleton. The plan must explicitly name which MonoBehaviour carries the responsibility.

Limit to 1-2 targeted Explore subagent calls. Each Explore prompt must be **≤10 lines** and ask a single specific architectural question (e.g., "Trace who fires OnBattleEnd and whether BattleCleanup subscribes before or after BattleRewards"). Do NOT send broad prompts like "read all files in Battle/ and list issues".

## Final Step — Persist Findings (BLOCKING)

**Do this AFTER all findings are collected but BEFORE editing the plan document.**

Write all findings to session memory so they survive interruptions:
```
memory create /memories/session/review-findings.md
## {PlanName} Review Findings ({date})
1. [MECHANICAL] {one-line summary}
2. [ARCHITECTURAL] {one-line summary}
...
```
If the file already exists, use `memory str_replace` or `memory insert` to append new findings. Do NOT skip this step — if the session is interrupted before plan edits, the next session will reload findings from Step 0 instead of re-discovering them.

## Risk Checklist

Evaluate the plan against these items. Skip items that don't apply — do not force findings.

### Robustness
- State machine transitions: missing exit paths, forced transitions skipping Exit() cleanup, stuck states when targets are destroyed
- Event desync: subscribers destroyed before unsubscribing, events firing during teardown, cached counters that permanently desync on missed events
- Unity lifecycle: Awake/Start/OnEnable ordering dependencies, singleton access before Awake, scene load cleanup of static references
- Null safety: destroyed GameObjects, unassigned SerializeField, failed lookups

### Performance
- Per-frame allocations: new lists, LINQ `.ToList()`, string concat, closure captures in Update
- Cached lookups: `GetComponent<T>()` or `Find` in Update loops instead of caching in Awake/Start
- Batch vs per-frame: work that runs every frame but only changes occasionally (should be event-driven)
- Scalability: O(n²) over entity collections, per-entity ops that should be batched, missing spatial partitioning

### Simplicity
- Interfaces with a single implementation and no planned second consumer
- Scope creep: steps exceeding stated goal, "while we're in there" additions
- Premature generalization: config for values that won't change, generic params always used with one type
- Unnecessary indirection: wrappers with one consumer, manager-of-managers

## Trade-Off Resolution

When a risk finding conflicts with a simplicity concern:
- **Correctness-critical paths** (state machines, save/load, event cleanup) → prefer robustness
- **All other paths** → prefer simplicity
- **Ambiguous** → flag both positions for user decision

## Post-Implementation Code Review

After implementation is complete, review the **actual code** rather than the plan. This catches bug categories that plan review cannot:

### When to Trigger
- After all implementation steps for a batch/feature are complete and compiling
- Before the final test pass

**Compile gate (BLOCKING):** Before starting this review, run `get_errors` on all modified files. Fix every error. Repeat until `get_errors` returns zero errors. Do NOT begin the code review while compile errors exist — they mask real issues and waste review effort.

### What to Check
1. **Plan-vs-code drift**: Diff the plan's described behavior against what the code actually does. Flag any step where implementation diverged from the plan without an explicit decision to change
2. **Migration completeness**: For every removal/refactor in the plan, grep to confirm ALL callers were actually migrated (not just the ones the plan listed)
3. **Event wiring verification**: For each new event subscription, verify the matching unsubscribe exists in `OnDisable()` or equivalent cleanup
4. **Null/destruction safety**: For each new `GetComponent`, `Find`, or cross-object reference, verify null checks or guaranteed lifecycle ordering
5. **Test coverage gaps**: Identify implemented behaviors that have no corresponding test. For each gap, output a test plan entry:
   - Target method/behavior
   - What to assert (expected outcome)
   - Edge cases to cover
   - Whether edit-mode or play-mode test is appropriate

### What NOT to Check
- Style, naming, formatting — these are lint concerns, not review concerns
- "While we're here" improvements to adjacent code — out of scope
- Theoretical edge cases with no concrete trigger path
