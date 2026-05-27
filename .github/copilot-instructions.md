# Centurions — Project Guidelines

## Architecture

This is a Unity 6 + URP game project (C#). See `Documentation/DesignRegistry.md` for the single source of truth on all design decisions. Each decision has a `DR-XXX` ID referenced throughout phase documents.

- **Assembly structure**: `Centurions.Core`, `.Data`, `.Battle`, `.Overworld`, `.Centurion`, `.UI`, `.Utils` — see `DR-CORE-005`
- **Singletons**: `GameManager`, `BattleManager`, `InputManager`, `SceneLoader` — see `DR-CORE-001`
- **State machine**: HSM with `Enter()`, `Exit()`, `Update()`, `FixedUpdate()` — see `DR-CORE-002`
- **Events**: Static `System.Action` delegates on `EventBus`. Always unsubscribe in `OnDisable()` — see `DR-CORE-003`

## Documentation System

Design decisions live in `Documentation/DesignRegistry.md` with `[DR-XXX]` IDs. Phase implementation plans (`Phase1_Prototype.md` through `Phase4_Final.md`) reference these IDs inline. `ChangeLog.md` tracks all changes chronologically.

**Critical rule**: When modifying any design value, follow the change propagation process defined in `DesignRegistry.md` — update the registry first, then propagate to all affected phase documents, then log in `ChangeLog.md`.

## Design Registry Sync Protocol

Whenever you modify a documentation file in `Documentation/` or implement code that changes a design decision:

1. **Identify affected DR entries** — check which `[DR-XXX]` tags are referenced by the change
2. **Update `Documentation/DesignRegistry.md` first** — modify the authoritative entry, including any values, formulas, or specs
3. **Propagate to phase documents** — grep for every `[DR-XXX]` ID you changed across `Phase1_Prototype.md`, `Phase2_Alpha.md`, `Phase3_Beta.md`, `Phase4_Final.md`, `ImplementationOverview.md`, and `DevelopmentPlan.md`. Update surrounding text/values to match the registry
4. **Update the "DR entries referenced" list** in each phase document header if new DR entries were added or existing ones now affect new tasks
5. **Update the "Affects" field** in the registry entry if the change touches new task IDs
6. **Add a changelog entry** in `Documentation/ChangeLog.md` with the current date, listing all modified `DR-XXX` IDs and affected task IDs
7. **Bump the version** — increment the revision suffix (e.g., `r2` → `r3`) in the `Version` header of `DesignRegistry.md` and the `Registry synced` header of every updated phase document
8. **Update `Documentation/ProjectDashboard.md`** — update the status row(s) for every system touched by the change:
   - Implementation changed → update **Impl** column
   - Design values changed and playtest validation is needed → set **Feel** or **Bal** to ⚠️
   - Architecture or public API changed → set **Code** to ⚠️
   - DR entry text updated to reflect new values → set **Docs** to ✅ or 🔄 as appropriate
   - New system added → add a new row with initial status populated from the plan
   - Update **Attention Queue** if the change creates or resolves a top-priority issue

When adding new design decisions during implementation, assign the next available DR ID in the appropriate domain (DR-CORE-0XX, DR-UNIT-0XX, DR-COMBAT-0XX, DR-WORLD-0XX, DR-PROG-0XX, DR-ENEMY-0XX, DR-CONTENT-0XX, DR-PERF-0XX, DR-BALANCE-0XX) and add it to the Index table at the bottom of the registry.

## Code Style

- ScriptableObjects for all tunable data (no magic numbers in code)
- `DontDestroyOnLoad` singletons placed in `_Bootstrap` scene
- GPU instancing via `MaterialPropertyBlock` for units
- NavMesh agents at group level only, not per-unit
- Zero GC allocation in hot paths (combat, steering, formation)
- Use `[SerializeField]` with `[Tooltip()]` for inspector fields
- Prefer composition over inheritance
- **Integrity gates for evolving collections**: Any time you design a system that writes to a persistent pool or collection that is expected to improve over time (optimizer seed pools, meta-progression saves, scored config libraries, ranked data stores), ask before implementing: *What prevents regressions from entering the pool? What bounds its size? What quality metadata does each item carry?* Propose the four-gate pattern (quality floor, improvement gate, pool cap + pruning, quality metadata per item) at design time. All gates must be config-driven and default to disabled so existing behaviour is unchanged until the user activates them.

## Cross-System Integration

### Communication Patterns
- **Static `EventBus`** with `System.Action` delegates is the primary cross-system notification mechanism (see DR-CORE-003). Always unsubscribe in `OnDisable()`
- **Singleton.Instance** for direct state queries; events for async notifications (hybrid pattern)
- **Self-registering registries** for lifecycle decoupling (e.g., SaveManager, manager registries)
- **Computed properties over event-cached counters** for aggregate queries across small collections (<50 items) — event caches risk permanent desync if any event is missed (object destroyed, removed before callback fires)
- **Isolate refactors from feature additions** — when adding support for a new consumer, add the new path without touching the existing working path. Consolidation is a separate cleanup task

### Interface Contracts
<!-- No project-wide interfaces implemented yet. Document here when ISaveable/ISelectable are added. -->
<!-- Pattern: Self-register in OnEnable, unregister in OnDisable. SaveManager discovers all automatically. -->

## Prefab Handling
- **NEVER** assume a prefab's hierarchy based on code that references it. Always open and read the actual `.prefab` YAML file to discover the real structure.
- If you cannot locate the prefab file with high confidence, **stop and ask** the user for the exact path before proceeding.
- Only add/modify components on existing GameObjects — do not create or destroy GameObjects in prefab setup scripts unless explicitly asked.

## Customization Structure
System-specific knowledge is in `.github/instructions/` (auto-loaded via `applyTo` globs and `description` keywords). Deep architecture docs are in `.github/skills/*/references/`. See `.github/instructions/CHANGELOG.md` for lesson audit trail.

## Knowledge Maintenance
When you diagnose and fix a bug or implementation issue:
1. **Propose, don't write:** Present the proposed lesson to the user with the target `.github/instructions/` file and section. Wait for explicit approval before writing.
2. **Dedup + conflict check:** Read the existing `## Lessons Learned` and `## Patterns` sections — do not add duplicates, and flag contradictions to the user instead of writing.
3. **Generalize:** Strip project-specific class names, field names, and asset names unless the class itself is the subject of the lesson. Lead with the transferable principle; a concrete example may follow only if it aids clarity. If the lesson documents a proven architectural decision rather than a corrected mistake, place it in `## Patterns` instead of `## Lessons Learned`.
4. **Write:** Append with date: `- **[YYYY-MM-DD]**: [what went wrong] → [what to do instead]`
5. **Log:** Append a one-line entry to `.github/instructions/CHANGELOG.md`. Then count all log entries below the `Last audit:` line — if the count hits the audit threshold (5 initial, then every 3), flag that a regression test is due.
6. **Overflow guard — instruction files**: If a `.github/instructions/*.instructions.md` file exceeds 50 lines after the addition, move the oldest lessons to the corresponding skill's `references/` folder under a `## Historical Lessons` section.
7. **Overflow guard — `copilot-instructions.md`**: This file loads in full every conversation. Keep it to universal cross-cutting rules only. Domain-specific rules belong in `.github/instructions/*.instructions.md` files with `applyTo` globs. If `copilot-instructions.md` exceeds 200 lines, audit it: identify any section scoped to one system or file type and migrate it to the appropriate `.instructions.md` file.

### Key Files Maintenance
When a task reveals that a Key Files entry is outdated (script renamed, moved, or deleted), update it directly. No approval needed for Key Files corrections — they are factual, not behavioral.

### Friction Detection
If a task requires more than one correction prompt after initial implementation (back-and-forth debugging), flag the root cause as a lesson candidate once the fix is confirmed. Propose it with target file and section.

## Copilot Workflow Preferences
- **Compile error check (MANDATORY)**: After every code edit, run `get_errors` with no `filePaths` argument to check the entire project. Fix every error before considering the task done. Repeat the edit → `get_errors` loop until zero errors remain. Never leave compile errors unfixed at the end of a session.
- **Plan mode**: Provide only the written plan, decisions, and questions — no code blocks. The user will switch to agent mode when satisfied with the plan.
- **Agent mode**: Implement the plan directly by creating/editing files.
- **Exact menu paths**: When telling the user to run an Editor script or menu command, always specify the **exact Unity menu path** (e.g., `Centurions → Batch 5 → 5 — Create ScriptableObjects`), not a vague reference like "run Batch5Setup". Grep for `[MenuItem]` attributes to find the precise path.
- **Unity config assets — edit as text/JSON directly**: Prefer editing Unity configuration assets (`*.inputactions`, `*.asmdef`, `*.uss`, UXML, etc.) as JSON/text over instructing the user to use the Unity Editor UI. Read the file first to match the existing format and naming pattern, then insert entries directly. This eliminates manual-entry errors and keeps names exactly in sync with code.
- **Unity Editor steps — always write a setup script**: Any time implementation produces steps the user must do manually in the Unity Editor (Inspector wiring, AddComponent, scene wiring, USS edits, prefab patching), write a `BatchXSetup.cs` Editor script to do them instead. Never leave a list of manual Unity Editor steps for the user. Follow the pattern in `Phase2Setup.cs`: `EditorSceneManager.OpenScene` → `AddComponent` → `SerializedObject.ApplyModifiedPropertiesWithoutUndo()` → `SaveScene`. Only YAML-patch cross-asset (GUID) references that `SerializedObject` fails to persist (see `PatchScenePanelSettingsYAML` in Phase2Setup.cs).

## Planning Mode Directive
When planning or designing features that span multiple systems, proactively read the instruction files for ALL systems that will be touched — `applyTo` globs only fire on file edits, not during planning conversations. Check instruction `description` fields against the task scope and read any that overlap.

## Game Design Pillars

Reference these when evaluating whether a technical decision, mechanic, or UX choice serves the game. Apply before defaulting to generic engineering judgment. When uncertain whether a feature serves these pillars, always surface the question to the user before implementing — never evaluate internally and silently reject.

- **The player is a general, not a soldier.** The core fantasy is commanding a Roman century from a top-down view — reading the battlefield and issuing group orders. All standard soldiers are commanded at group level only. The exception is *hero units*: the Centurion (always present at run start) and up to 2 additional commanders recruited during the run (3 max total, gated by meta progression unlock). The player never begins a run with a multi-commander roster — additional commanders are earned mid-run. Each hero unit is individually controllable in an ARPG style — move, attack, use abilities. Non-Centurion commanders are high-stakes assets: if they die in battle, they die permanently for that run. Features that give per-unit control to non-hero soldiers undermine the fantasy and should be rejected.

- **Tactical depth requires both axes.** Depth comes from terrain/formation reads AND enemy composition reads simultaneously. A mechanic earns its complexity if it creates a decision where context changes the optimal answer. Generalist armies take a *soft disadvantage* against composition-specific threats — they are not cleanly neutralized. Biome-specific mercenary lodges are the designed mechanism for filling composition gaps; players are expected to hire biome mercs to counter local threats. Leaving a biome means those merc types can no longer be replenished — over-investing in one biome's mercs creates a resource trade-off across the run. Never design an encounter that requires a specific counter-composition to win; always leave a terrain/formation adaptation path open.

- **Roguelite stakes — incapacitation, not instant loss.** Units lost in battle accrue attrition across the run; camp recovery keeps the run viable after a bad fight. When the Centurion's HP hits zero mid-battle, they are *incapacitated*: a 1-minute countdown begins. The player must either finish the battle in that window or drag the Centurion to the escape zone at the battle edge. Once in the escape zone, the retreat button activates; triggering it ends the battle and loses 25% of units not yet in the zone. If the timer expires and the Centurion has NOT reached the escape zone, the run ends immediately. Voluntary retreat is always available (no Centurion incapacitation required) and uses the same escape zone mechanic with the same 25% penalty. After catastrophic losses, the overworld POI pool tilts toward recovery options (merc lodges, healing); units can be redistributed between groups at camps.

- **Information design at scale.** At 200+ units on screen, clarity beats detail. Group-level health bars, group-level selection, and group-level feedback are the correct signals. Per-unit indicators create noise that obscures the tactical picture. Exception: individual HP bars and status indicators for each hero unit are appropriate at all scales.

- **Overworld pacing scales with run position.** Runs are mission-scoped: the player chooses between 2–3 biomes (normal or hard variant) at each junction, with harder variants offering greater rewards. Early biomes are readable scouting — players learn terrain and enemy presence with low risk. Final biomes carry real threat: patrol AI is active and directional positioning matters. Approaching a patrol from behind lets the player initiate an ambush (positioning advantage + delayed enemy response at battle start). Being caught from behind triggers an enemy ambush with the same advantages reversed. Early zone features should inform; late zone features should threaten.

- **Both phases of a battle matter.** Pre-battle deployment (target: 1–3 minutes of genuine formation and terrain deliberation) sets the stage. Real-time in-battle decisions — formation swaps, repositioning, hero unit actions, ability activation — are live choices that can change the outcome. Neither phase trivializes the other. Avoid mechanics that collapse deployment into a formality or reduce live battle to executing a predetermined plan.

- **When in doubt, ask.** Does this give the player a new strategic option, or does it make them do more work for the same outcome? When uncertain, always surface the question to the user before implementing.

## Backlog / Deferred Features
<!-- Track features you've discussed with Copilot but deferred. Example format: -->
<!-- - [ ] **{Feature}** — {Brief description of what it does and why it's deferred} -->

- [ ] **Stat Modifier System** — Additive/multiplicative stat layering for unit stats. Deferred until Centurion ability system reveals full requirements.
- [ ] **Overworld Patrol System (DR-WORLD-014)** — `PatrolController` MonoBehaviour; patrol nodes in `ZoneGenerator`; 8 m detection radius, 2.5 m/s; Forest biome. PostPhase2 scope.
- [ ] **Overworld Shortcut Barriers (DR-WORLD-015)** — 15% unconnected room-pair edges as shortcuts; `ShortcutBarrier` prefab with `NavMeshObstacle` carve; E key destroys. Forest biome. PostPhase2 scope.

## Input System Structure
- Asset: `Assets/InputSystem_Actions.inputactions` — `InputSystem_Actions` asset
- **Overworld** action map: Move, Look, Sprint, Interact, Pause
- **Battle** action map: CameraMove, CameraRotate, CameraZoom, Select, Command, AbilitySlot1-4, GroupHotkey1-8, AssignGroup, SelectCenturion, Pause, AttackMove, FormationLine/Wedge/ShieldWall/Loose, Stop
- `InputManager` reads these maps; other systems subscribe via `InputManager.OnXxx` events
- New actions: edit `InputSystem_Actions.inputactions` as JSON directly — match the existing format, then add a corresponding `public event Action<T> OnXxx` in `InputManager.cs`

## UI Theme
- Use **UI Toolkit** (UIDocument + USS + UXML) for all new UI — no uGUI (Canvas/Image/Text) for new panels
- Use `VisualElement.style` properties for programmatic styling; avoid inline `style=` in UXML for anything using `var()` CSS tokens
- USS class rules in `.uss` files; `var()` only inside USS files, never in UXML inline style attributes
- Every `UIDocument` requires a `PanelSettings` asset (ScaleWithScreenSize, 1920×1080, 0.5 match) — silently renders nothing without one
