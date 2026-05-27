---
description: "Pre-implementation plan review — mechanical verification, architectural analysis, and risk assessment for an implementation plan document"
agent: "agent"
argument-hint: "Path to the plan document to review"
---
# Pre-Implementation Plan Review

Review the provided plan document following the full workflow defined in [plan-review.instructions.md](./../instructions/plan-review.instructions.md).

## Input
The user will provide a path to the plan document. Read it in full before starting.

## Workflow

Execute these phases in order — do NOT skip or reorder:

1. **Step 0 — Load Prior Findings**: Check `/memories/session/review-findings.md` for prior findings on this plan. If this is session 2+ and prior session found <3 new findings, warn the user about the session cap and recommend proceeding to implementation instead.

2. **Mechanical Verification (Steps 1–4)**: Assumption extraction → batch grep verification → internal consistency → removal safety. Complete ALL mechanical checks before any Explore subagent calls.

3. **Completeness Checks**: State enum audit, cross-system patterns, cross-batch modifications list.

4. **Architectural Analysis**: 1–2 targeted Explore subagent calls (≤10-line prompts each) for event lifecycle, initialization flow, or data routing questions.

5. **Final Step — Persist Findings**: Write all findings to `/memories/session/review-findings.md` BEFORE editing the plan.

6. **Apply findings** to the plan document.

## Output Format

```
## Pre-Implementation Review: {PlanName}
**Session**: {1|2} of 2 max | **New findings**: {N} | **Prior findings loaded**: {N}

### Findings
| # | Category | Severity | Summary | Plan Section |
|---|----------|----------|---------|--------------|

### Recommendation
{PROCEED TO IMPLEMENTATION | ONE MORE REVIEW NEEDED (reason) | PLAN NEEDS REWRITE (reason)}
```
