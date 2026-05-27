---
applyTo: "Assets/Scripts/Overworld/**"
description: "Use when editing overworld zone generation, terrain mesh generation, encounter spawning, fill walls, or player spawn positioning."
---
# Overworld Generation

## Key Files
| File | Purpose |
|------|---------|
| `Scripts/Overworld/ZoneGeneration/ZoneGenerator.cs` | Pure BSP → nodes → MST → spline pipeline; produces immutable `ZoneGraph` |
| `Scripts/Overworld/ZoneGeneration/TerrainMeshGenerator.cs` | Converts `ZoneGraph` to 3D geometry: ground plane, room floors, corridor floors, fill walls, perimeter wall |
| `Scripts/Overworld/ZoneGeneration/SplineHelper.cs` | Catmull-Rom spline sampling utilities |
| `Scripts/Overworld/OverworldRunController.cs` | Zone lifecycle: generate → terrain → environment → navmesh → encounters → POIs → boss gate → position player |
| `Scripts/Overworld/EncounterSpawner.cs` | Spawns/clears `EncounterMarker` objects from graph; `EncounterTrigger` class is co-defined in the same file (sibling class, not nested) |
| `Scripts/Overworld/OverworldInitializer.cs` | Restores player position from `RunData.overworldPosition` on scene load |

## Patterns

- **Fill walls are the sole exterior boundary system**: `GenerateFillWalls` (grid sweep + `IsInRoomOrCorridor` check) covers all exterior walls. `GenerateRoomWalls` (circular arcs) and `GenerateCorridorWalls` (spline quads) must NOT be active at the same time as fill walls — they create enclosed pens around nodes and physical barriers inside corridors.
- **`IsInRoomOrCorridor` must use node-to-node straight-line clearance**: The Catmull-Rom spline output runs from `mid1` (~33%) to `mid2` (~66%) of the room-to-room distance. Checking only spline segments leaves a 10–20m gap on each side of every corridor junction. Always add `SegmentDistanceSq(point, posA, posB)` for each edge in addition to per-segment spline checks.
- **All runtime geometry goes under a `GeneratedContent` child**: `OverworldRunController.GenerateZone` creates a `GeneratedContent` GameObject under `zoneParent` and passes it to `GenerateTerrain` and `DressZone`. On regeneration, only `GeneratedContent` is destroyed — permanent scene siblings (lighting, cameras) are untouched. Never call `Destroy` on all `zoneParent` children.
- **Terrain must be procedurally self-contained**: Generate a full-zone ground plane quad in `GenerateTerrain` so the scene works regardless of pre-placed objects. Relying on a scene-placed ground plane breaks after any `GeneratedContent` destroy cycle.
- **Player position restore sequence**: `ClearOverworldPosition()` must run *after* `PositionPlayerAtEntrance()`, not before. The save contains the post-battle return position; clearing it first forces entrance re-spawn every time.

## Lessons Learned
- **[2026-04-25]**: Catmull-Rom `SampleSpline(from, mid1, mid2, to)` returns points from `mid1` to `mid2` only — `from`/`to` are phantom tangent handles. Fill wall checks against only spline segments left 10–20m blocked gaps at every corridor junction. → Use a straight-line `nodeA.Position → nodeB.Position` clearance check per edge in `IsInRoomOrCorridor`; spline-segment checks are supplemental only.
- **[2026-04-25]**: Running `GenerateRoomWalls` (circular arcs) alongside `GenerateFillWalls` (grid blocks) creates enclosed pens around POI/encounter nodes. Running `GenerateCorridorWalls` alongside fill walls creates redundant physical barriers inside corridors. → Use exactly one wall generation system. When fill walls are active, remove both `GenerateRoomWalls` and `GenerateCorridorWalls` calls from `GenerateTerrain`.
- **[2026-04-25]**: Blanket `Destroy(zoneParent.GetChild(i))` in a loop destroyed the pre-placed ground plane, causing the player camera to fall immediately after overworld spawn. → Use a dedicated `GeneratedContent` container child. Destroy only that container on regeneration — all permanent scene siblings survive.
- **[2026-04-25]**: `_runData.ClearOverworldPosition()` called at the top of `GenerateZone()` wiped the post-battle saved position before `PositionPlayerAtEntrance()` ran, forcing the player back to the entrance after every battle win. → Call `ClearOverworldPosition()` after `PositionPlayerAtEntrance()`, not before.
- **[2026-04-25]**: Pre-placed scene ground plane is deleted when `GeneratedContent` is destroyed on zone regeneration, leaving no walkable surface. → Always generate a full-zone ground plane quad inside `GenerateTerrain` using `WorldBounds` so the system is scene-state-independent.
- **[2026-04-26]**: When a procedural zone system produces wrong object positions (objects in walls, objects at fixed wrong locations regardless of seed), audit the scene YAML before reading any C# scripts. Grep for `PrefabInstance` blocks with `m_TransformParent: {fileID: 0}` (scene-root parent) and hardcoded `m_LocalPosition` overrides. Static scene objects at fixed positions will always conflict with seed-based procedural placement. Code investigation is premature until static scene content is ruled out.
- **[2026-04-26]**: GameObjects placed by one-shot Editor setup scripts (menu items, `[InitializeOnLoad]` bootstrappers, etc.) that are parented to the scene root survive indefinitely — they are never destroyed by runtime zone regeneration, which only destroys its own managed container. Any fixed-position zone content created this way permanently conflicts with procedural spawning. → After running an Editor setup script, delete all zone-content objects it placed from the scene and rely solely on runtime dynamic spawning.
- **[2026-04-26]**: Removing a prefab instance from a Unity scene YAML does not clear serialized field references to its components in other GameObjects. After removal those fields contain stale fileIDs that log missing-reference errors at runtime. → When deleting prefab instances via YAML surgery, grep for every component fileID being removed and zero out (`{fileID: 0}`) or empty any array that references them in other MonoBehaviour blocks.
