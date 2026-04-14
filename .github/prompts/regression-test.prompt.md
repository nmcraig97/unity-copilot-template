---
description: "Regression test — verify instruction and skill accuracy across project systems (run after first 5, then every 3 new lessons)"
agent: "agent"
---
# Regression Test

Verify that instruction files and skills are accurate against the current codebase state.

## Workflow

### 1. Discover Systems
Read all `.github/instructions/*.instructions.md` files (skip `_TEMPLATE`). Build a list of documented systems.

### 2. Generate Verification Questions
For each instruction file, generate 1-2 targeted questions that test:
- **Key Files accuracy**: Do the listed files still exist at the documented paths? Have any been renamed or moved?
- **Pattern accuracy**: Does the documented pattern still match the actual code implementation?
- **Lesson relevance**: Are documented lessons still applicable, or has the code been refactored to eliminate the issue?

### 3. Execute Checks
For each verification question:
1. Read the relevant source files from the codebase
2. Compare against the documented patterns/files/lessons
3. Flag any discrepancies

### 4. Report
Output a summary:

```
## Regression Test Results

**Date**: {current date}
**Systems checked**: {N}
**Issues found**: {N}

### Passed
- {System}: All {N} checks passed

### Issues
- {System}: {Description of discrepancy} → Recommended fix: {action}
```

### 5. Auto-Fix Key Files
If any Key Files entries are wrong (file moved/renamed/deleted), fix them directly — no approval needed per project conventions.
