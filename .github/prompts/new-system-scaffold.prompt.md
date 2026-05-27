---
description: "Scaffold a new system with MonoBehaviour, optional interface implementation, and detail panel wiring"
agent: "agent"
---
# New System Scaffold

Scaffold a new system end-to-end following project conventions.

## Gather Requirements
Ask the user for:
1. **System name** (e.g., "Inventory", "Dialogue", "Weather")
2. **Pattern type** — Singleton manager, per-entity component, self-registering registry, or hybrid
3. **Key interfaces** — Does it need to implement any project interfaces? (None exist yet; document here when added)
4. **Dependencies** — Which existing systems does it interact with? (events to subscribe to, singletons to query)
5. **UI panel** — Does it need a detail/info panel? If so, what data does it display?

## Implementation Steps

### 1. Create Instruction File
- Create `.github/instructions/{system-name}.instructions.md` from `_TEMPLATE`
- Set `applyTo` glob for the new script folder
- Set `description` with system keywords and key class names

### 2. Create Core Script(s)
- Create script folder: `Assets/Scripts/{SystemName}/`
- Create main MonoBehaviour with:
  - `[SerializeField] [Tooltip()]` for inspector fields
  - Singleton pattern (if applicable): `public static {ClassName} Instance { get; private set; }` in Awake
  - Event declarations: `public event Action<T> On{EventName};`
  - Interface implementations (if applicable)

### 3. Create ScriptableObject Data (if needed)
- Create SO class in the scripts folder
- Create SO asset in `Assets/ScriptableObjects/{SystemName}/`

### 4. Wire Events & Integration
- Subscribe to dependency events in OnEnable, unsubscribe in OnDisable
- Fire own events for consumers
- Register with any applicable registries (self-registering pattern)

### 5. Create UI Panel (if applicable)
- Create panel script implementing the project's detail panel interface
- Implement Bind/Unbind/Refresh pattern:
  - Bind: subscribe to data events, populate UI references
  - Refresh: update dynamic content
  - Unbind: unsubscribe all events, clean up dynamic content

### 6. Add ISaveable (if stateful)
*(Not yet implemented in the project — skip until SaveSystem wiring is designed)*
- Create `[Serializable]` save data struct
- Implement ISaveable: SaveID, CaptureState, RestoreState
- Self-register in OnEnable, unregister in OnDisable
- Handle SO-name serialization via project registry (if applicable, once SaveSystem is implemented)

### 7. Update Instruction File
- Fill in Key Files table with the created scripts
- Document the patterns implemented
- List integration points with other systems
