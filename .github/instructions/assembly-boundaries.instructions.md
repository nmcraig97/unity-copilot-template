---
applyTo: "Assets/Scripts/**/*.asmdef"
description: "Use when editing assembly definition files, adding assembly references, moving scripts between assemblies, or designing cross-system APIs (EventBus, singletons)."
---
# Assembly Boundary Rules

## Dependency Hierarchy (no cycles)
```
Centurions.Utils          → (nothing)
Centurions.Core           → Unity.InputSystem only
Centurions.Data           → Centurions.Core
Centurions.Battle         → Core + Data
Centurions.Overworld      → Core + Data
Centurions.Centurion      → Core + Data
Centurions.UI             → Core + Data + Battle + Overworld + Centurion
Centurions.Tests.*        → all of the above
```

## Key Constraints
- **Core cannot reference Data** — `Data.asmdef` already references Core (via `RunData.cs using Centurions.Core`). Adding Core→Data creates a Core→Data→Core cycle.
- **EventBus lives in Core** — its event signatures must not use Data types (`AbilitySO`, `EventCardSO`, etc.) as parameters. Use parameterless `Action` or primitives (`string`, `int`). Subscribers retrieve full objects by querying singletons (e.g. `POIManager.CurrentEventCard`).
- **Classes that need both Core and Data APIs** (e.g. `MetaProgressionManager`) must live in the `Data` assembly, not Core.

## Lessons Learned
- **[2026-04-21]**: Adding `Centurions.Data` to `Centurions.Core.asmdef` references causes a cyclic dependency compile error because `Data` already references `Core`. → Keep EventBus event parameters as `Action` (parameterless) or primitive types. For Data-typed payloads, store the value on the owning singleton (e.g. `POIManager.CurrentEventCard`) and fire a parameterless or string-keyed event; subscribers pull the object from the singleton.
