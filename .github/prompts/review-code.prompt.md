---
description: "Post-implementation code review — verify code matches plan, check event wiring, migration completeness, null safety, and identify test coverage gaps"
agent: "agent"
argument-hint: "Path to the plan document that was implemented"
---
# Post-Implementation Code Review

Use a **tiered verification approach** — fast tiers first, skip to the next tier only if the previous one surfaces issues or misses coverage.

## Input
The user will provide a path to the plan document. Read it in full to extract the verification checklist before doing anything else.

## Tier 1 — Compile Check (seconds, run first)

Ask the user to confirm the project compiles clean before proceeding. If it does not:
- Read only the files with compile errors
- Fix or flag every error before continuing
- Do NOT proceed to Tier 2 until the project compiles

A clean compile eliminates: missing methods, wrong signatures, removed properties still referenced, type mismatches. This makes the migration completeness grep pass (Tier 2) much cheaper — you only need to verify intent, not catch typos.

## Tier 2 — Test Suite (seconds, run second)

Ask the user to run the edit-mode and play-mode test suites. Record results.

- ✅ All pass → Checks 1 (drift) and 3 (event wiring) are largely satisfied. Proceed to Tier 3 for the remaining gaps tests cannot catch.
- ❌ Failures → Read only the failing test files and the specific methods they exercise. Fix or flag before continuing.

## Tier 3 — Parallel Grep Checklist (cheap, ~10 parallel greps)

From the plan's **cross-batch modifications** and **removal list**, extract every specific identifier that should no longer exist or should now exist. Run all greps in one parallel batch.

For each removed method/property: grep should return **0 results** (all callers migrated).
For each new event subscription (`+=`): grep the same file for the matching `-=`.
For each renamed identifier: grep old name should return 0 results.

Examples (adapt to actual plan content):
- Removed method: `grep "Unit.TakeDamage"` → must be 0
- Renamed event: `grep "FireUnitRemovedFromGroup"` → must be 0
- Removed property: `grep "AggregateCurrentHP"` → must be 0
- Event wiring: `grep "OnGroupHPChanged"` — verify every `+=` file also has `-=`
- New call site: `grep "FinalizeInitialization"` → verify expected callers exist

Each grep costs ~100 tokens. Run all in parallel. Flag any grep that returns unexpected results.

## Tier 4 — Narrow File Reads (AI review, only when needed)

Use targeted file reads only for things greps cannot catch:
- **Initialization ordering** — who calls what and when (race conditions, null refs before Awake)
- **Algorithm correctness** — new logic in pure functions (BSP, overkill carry, spline math)
- **State machine exit paths** — transitions that skip `Exit()` cleanup
- **Edge cases in new data flow** — e.g., sentinel values, division-by-zero guards

Read only the specific methods with these risks — not entire files. If no architectural concerns surface from Tier 3, Tier 4 may be skipped entirely.

## Test Coverage Gaps

After Tier 2, identify implemented behaviors with no corresponding test. For each gap, produce a test plan entry — do NOT generate test code.

## Output Format

```
## Post-Implementation Review: {PlanName}
**Compile**: ✅/❌ | **Tests**: {N passed}/{N total} | **Grep flags**: {N} | **Issues found**: {N}

### Tier 3 Grep Results
| Pattern | Expected | Actual | Status |
|---------|----------|--------|--------|
| `Unit.TakeDamage` | 0 results | 0 | ✅ |

### Tier 4 Findings (if any)
1. **{file}:{line}** — {description} → Recommended fix: {action}

### Test Plan (coverage gaps)
| # | Target Method/Behavior | What to Assert | Edge Cases | Mode |
|---|------------------------|----------------|------------|------|
| 1 | {Class.Method} | {expected outcome} | {edge cases} | edit-mode / play-mode |
```
