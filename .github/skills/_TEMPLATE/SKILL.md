---
# name: Machine-readable skill identifier (lowercase, hyphenated)
name: "{system-name}"

# description: One-line summary used by Copilot to decide when to load this skill.
# Include class names, domain keywords, and specific scenarios.
description: "Use when working on {domain description}. Covers {KeyClass1}, {KeyClass2}, {KeyClass3}."
---
# {System Name}

## When to Use
<!-- List the specific scenarios where this skill should be loaded.
     These should be more specific than the instruction file's scope. -->
- Adding a new {entity type} or modifying existing ones
- Working with {subsystem A} or {subsystem B}
- Debugging {specific category of issues}

## Approach
<!-- 3-4 step workflow for working in this domain.
     The layering is: instruction file (auto-loaded) → skill (loaded on demand) → references (deep docs) -->
1. Read the instruction file first (auto-loaded via `applyTo`)
2. If deeper architectural context needed, read [references/{system-name}-architecture.md](./references/{system-name}-architecture.md)
3. **Always verify against actual codebase** — read the relevant scripts before making changes

## Critical Patterns
<!-- Domain-specific patterns that go beyond what's in the instruction file.
     These are the patterns that prevent the most common bugs in this system. -->
- **{Pattern 1}**: {Detailed description with specifics}
- **{Pattern 2}**: {Detailed description with specifics}
- **{Pattern 3}**: {Detailed description with specifics}
