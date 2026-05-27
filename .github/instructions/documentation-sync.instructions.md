---
description: "Use when editing Documentation/ files, modifying design decisions, changing game stats/formulas/values, implementing features that affect DR-XXX registry entries, or updating phase plan documents. Ensures design registry tags stay synchronized."
applyTo: "Documentation/**"
---
# Documentation Sync Rules

When editing any file in `Documentation/`:

## On Every Change

1. Check if the change affects a value, formula, or spec tracked by a `[DR-XXX]` entry in `DesignRegistry.md`
2. If yes: update the registry entry first, then propagate to all files that reference that `[DR-XXX]` ID
3. Grep across all docs for the affected `[DR-XXX]` IDs to find every reference that needs updating
4. Verify numerical consistency — if a stat appears in both the registry and a phase doc, they must match

## On Adding New Content

- New design decisions get a `[DR-XXX]` ID in the registry and an entry in the Index table
- New phase tasks that depend on existing decisions get tagged with `[DR-XXX]` inline
- The phase document header's "DR entries referenced" list must include any newly referenced IDs

## On Removing or Changing Scope

- Mark removed decisions with ~~strikethrough~~ in the registry, don't delete them
- Update the "Affects" field to remove task IDs that no longer apply
- Log the removal in `ChangeLog.md`

## Version Protocol

- Increment revision suffix in `DesignRegistry.md` `Version` header (e.g., `r2` → `r3`)
- Update `Registry synced` in every modified phase document to match
- Add a dated entry to `ChangeLog.md` listing all changed DR IDs and affected task IDs

## Cross-Reference Checklist

| If you change... | Also update... |
|-------------------|----------------|
| A stat in the registry | Every phase doc referencing that `[DR-XXX]` |
| A formula in the registry | Phase docs + `ImplementationOverview.md` if the formula is summarized there |
| A task in a phase doc | The "Affects" field of any `[DR-XXX]` entry it references |
| Content scaling numbers | `DR-CONTENT-001` table in the registry |
| Performance targets | `DR-PERF-001` / `DR-PERF-002` in the registry |

## ProjectDashboard.md Sync Rules

`Documentation/ProjectDashboard.md` is updated as part of Step 8 of the Design Registry Sync Protocol. Apply these column rules:

| Change type | Column(s) to update |
|-------------|---------------------|
| Implementation task completed or partially done | **Impl**: ❌ → 🔄 or 🔄 → ✅ |
| Design values changed; playtest re-validation needed | **Feel** and/or **Bal**: set to ⚠️ |
| Architecture or public API changed | **Code**: set to ⚠️ |
| DR entry updated to match current implementation | **Docs**: set to 🔄 or ✅ |
| Visual/audio/UX work completed | **Polish**: update accordingly |
| Playtest confirms feel is acceptable | **Feel**: ⚠️ → ✅ (only after explicit playtest confirmation) |
| Balance figures validated by simulation or playtest | **Bal**: ⚠️ → ✅ (only after explicit confirmation) |
| New system added to codebase | Add new row with Impl 🔄 and all review columns ⚠️ or — |
| System explicitly deferred | Set **Impl** to ⏸; clear review columns to — |

Always update the `Registry synced` version tag in the ProjectDashboard.md header to match the current `DesignRegistry.md` version when making any change.

Update the **Attention Queue** section when:
- A new ⚠️ is added that blocks downstream work
- An item on the queue is resolved
- After each work session, re-sort the queue so the current highest-priority item is #1

## Lessons Learned
- **[2026-04-21]**: Instruction files with `applyTo` globs only auto-load when matching files are edited. Code changes that affect documented design decisions (e.g. adding events, changing a public API) will not trigger a doc-sync instruction file. → When any code change affects a documented design decision, manually apply the doc-sync protocol in the same task — do not wait for a `Documentation/**` edit to trigger it.
