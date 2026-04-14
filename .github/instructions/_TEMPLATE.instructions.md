---
# applyTo: Glob patterns that auto-load this file when editing matching paths.
# Can be a single string or an array of strings.
# Examples:
#   applyTo: "Assets/Scripts/MySystem/**"
#   applyTo: ["Assets/Scripts/MySystem/**", "Assets/Prefabs/MySystem/**"]
applyTo: "Assets/Scripts/{SystemName}/**"

# description: One-line summary used by Copilot to decide when to load this file
# during planning conversations (applyTo only fires on file edits).
# Include key script names, class names, and domain keywords.
description: "Use when editing {SystemName} scripts, {KeyClass1}, {KeyClass2}, or {domain keywords}"
---
# {System Name}

## Key Files
<!-- List the most important scripts in this system. Keep this table updated
     when files are renamed, moved, or deleted — no approval needed for corrections. -->
| File | Purpose |
|------|---------|
| `Scripts/{SystemName}/{MainScript}.cs` | {Brief description of what this script does} |
| `Scripts/{SystemName}/{SecondScript}.cs` | {Brief description} |

## Patterns
<!-- Document the critical patterns and flows in this system.
     These help Copilot understand HOW things work, not just WHERE they are. -->
- **{Pattern name}**: {Description of the flow or convention}
- **{Another pattern}**: {Description}

## Integration Points
<!-- How does this system connect to other systems? List events consumed/produced,
     singletons queried, and registries used. -->
- `{EventName}` → consumed by {other system}
- See § Cross-System Integration in copilot-instructions.md for interface contracts

## Lessons Learned
<!-- Copilot appends lessons here after diagnosing bugs. Format:
     - **[YYYY-MM-DD]**: {what went wrong} → {what to do instead}
     When this section exceeds 50 lines, overflow oldest entries to
     .github/skills/{system}/references/ under ## Historical Lessons -->
