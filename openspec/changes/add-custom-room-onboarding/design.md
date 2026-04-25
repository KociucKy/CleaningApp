## Context

Currently, the onboarding room selection presents 10 predefined `RoomType` enum cases, including `.custom` which has no suggested tasks. Users with unique rooms (gym, conservatory, pantry, etc.) cannot effectively use the app during onboarding. The domain model uses an enum-based room type system which doesn't support user-created types.

**Current Architecture**:
- `RoomType` enum with 10 fixed cases (including `.custom`)
- `Room` domain model stores `kind: RoomType`
- `OnboardingFlowState` tracks `selectedRooms: [RoomType]`
- Suggested tasks keyed by `RoomType` via computed property
- Room persistence uses `RoomType.rawValue` as the room name default

**Key Constraints**:
- Must follow RIB architecture (Router-Interactor-Builder + Presenter + View)
- SwiftUI for UI, @Observable for state management
- No async/await - synchronous service calls with `throws`
- One type per file naming convention
- 4-space indentation, SwiftLint/SwiftFormat compliance

## Goals / Non-Goals

**Goals:**
- Enable custom room creation during onboarding with user-defined name and icon
- Replace unusable `.custom` enum case with a real predefined room type (Dining Room)
- Maintain existing onboarding flow - custom rooms are additive, not a replacement
- Support unlimited custom rooms per user
- Persist custom rooms alongside predefined rooms seamlessly

**Non-Goals:**
- Custom room creation outside of onboarding (post-onboarding is future work)
- Editing custom room icons/names after creation
- Custom task suggestions for custom rooms (they start with 0 tasks, user adds manually)
- AI-generated task suggestions based on room name
- Photo-based room icons

## Decisions

### Decision 1: Room Type Model Evolution

**Chosen**: Add `isCustom: Bool` flag and optional `customName/customIcon` fields to `Room` domain model. Keep `RoomType` enum for predefined types only.

**Rationale**:
- Enum can't represent unlimited user-created types
- Adding fields to `Room` avoids breaking the enum pattern used throughout the app
- Backward compatible - existing rooms have `isCustom = false` by default
- `kind: RoomType` still valid for predefined rooms
- Custom rooms use a sentinel `RoomType` value (we'll add `.customRoom` case)

**Alternatives Considered**:
- **Protocol-based room types**: Too complex, requires major refactoring of suggested tasks system
- **String-based room types**: Loses type safety and SF Symbol associations

**Data Model**:
```swift
struct Room {
    let id: UUID
    var name: String                // Predefined: uses RoomType.rawValue; Custom: user input
    var kind: RoomType              // Predefined rooms; .customRoom for custom
    var isCustom: Bool              // NEW: distinguishes custom from predefined
    var customIcon: String?         // NEW: SF Symbol name for custom rooms
    let createdAt: Date
}
```

### Decision 2: RoomType Enum Changes

**Chosen**: Replace `.custom` with `.diningRoom`, add new `.customRoom` sentinel case for user-created rooms.

**Rationale**:
- `.custom` currently unusable (no suggested tasks)
- Dining Room is a common real-world need
- `.customRoom` acts as a type marker for custom rooms (doesn't appear in selection grid)
- Minimal migration - only affects onboarding suggestions

**New enum**:
```swift
enum RoomType {
    case kitchen, livingRoom, bedroom, bathroom, hallway,
         office, garage, laundry, toilet
    case diningRoom  // NEW - replaces custom
    case customRoom  // NEW - sentinel for user-created rooms (not shown in grid)
}
```

**Dining Room suggested tasks** (4-5 tasks):
- Set table (daily, 5min)
- Clear table (daily, 5min)
- Wipe table (times per week: 2, 10min)
- Vacuum/sweep floor (times per week: 2, 15min)
- Dust shelves/cabinets (weekly, 10min)

### Decision 3: OnboardingFlowState Evolution

**Chosen**: Add `customRooms: [CustomRoomSelection]` array to track user-created rooms separately.

**Rationale**:
- Predefined rooms selected via `toggleRoom(_ room: RoomType)` - keyed by enum
- Custom rooms need UUID identity (multiple "Gym" rooms possible)
- Separate tracking makes persistence logic clear

**New model**:
```swift
struct CustomRoomSelection: Identifiable {
    let id: UUID  
    var name: String
    var icon: String  // SF Symbol name
}

@Observable
final class OnboardingFlowState {
    private(set) var selectedRooms: [RoomType]                        // Predefined
    private(set) var customRooms: [CustomRoomSelection]                // NEW: Custom
    private(set) var selectedTasks: [RoomType: [RoomTask]]           // Tasks for predefined
    // Custom rooms start with 0 tasks
}
```

### Decision 4: Custom Room Creation UI

**Chosen**: Bottom sheet with two-step form: (1) Name input (2) Icon picker grid.

**Rationale**:
- Bottom sheet is iOS native pattern for quick creation
- Two-step form keeps UI simple and focused
- Icon picker shows curated list of relevant SF Symbols
- Follows existing app design language (FulhamKit components)

**UI Flow**:
1. User taps "+" button in toolbar
2. Sheet presents with text field focused (name input)
3. User enters name, taps "Next" or return key
4. Icon picker grid appears (30-40 curated SF Symbols)
5. User selects icon, sheet dismisses, custom room appears in grid

**Icon Curation** (15-20 symbols):
- Generic: `house`, `square.grid.2x2`, `building`, `archway.closed`
- Specific: `dumbbell`, `book`, `paintpalette`, `music.note`, `leaf`, `pawprint`
- Utility: `lamp.desk`, `cabinet`, `door.sliding.left.hand.open`, `stairs`

### Decision 5: Custom Room Persistence

**Chosen**: Save custom rooms as `Room` entities with `isCustom = true`, `kind = .customRoom`.

**Rationale**:
- Reuse existing persistence layer (`RoomManager`, `RoomRepository`)
- Custom rooms are first-class citizens, no separate storage
- `RoomEntity` already has `icon: String` field (stores `customIcon`)
- `RoomType.customRoom` maps to `"customRoom"` string in entity

**Save logic** (in `OnboardingInteractor`):
```swift
// 1. Save predefined rooms
for roomType in flowState.selectedRooms {
    let room = Room(name: roomType.rawValue, kind: roomType, isCustom: false)
    try roomManager.save(room)
}

// 2. Save custom rooms
for customRoom in flowState.customRooms {
    let room = Room(
        id: customRoom.id,
        name: customRoom.name,
        kind: .customRoom,
        isCustom: true,
        customIcon: customRoom.icon
    )
    try roomManager.save(room)
}
```

## Risks / Trade-offs

### Risk 1: RoomEntity Migration
**Risk**: Existing `RoomEntity` records lack `isCustom` and `customIcon` fields.  
**Mitigation**: Add fields as optional with default values. SwiftData handles schema migration automatically. Existing rooms default to `isCustom = false`, `customIcon = nil`.

### Risk 2: Custom Room Icon Storage
**Risk**: SF Symbol names may change across iOS versions, breaking custom icons.  
**Mitigation**: Store symbol names as strings (current approach). If symbol disappears, fall back to default icon (`square.grid.2x2`). Validate symbol exists before displaying.

### Risk 3: Suggested Tasks for Custom Rooms
**Risk**: Users expect suggested tasks for custom rooms (e.g., "Gym" → exercise equipment tasks).  
**Mitigation**: Clearly communicate that custom rooms start empty. Add help text: "Add tasks manually after onboarding." Future work: AI-suggested tasks based on room name.

### Risk 4: UI Complexity in Room Selection Grid
**Risk**: Adding custom rooms to grid while maintaining staggered animation increases complexity.  
**Mitigation**: Render custom rooms after predefined rooms in grid order. Animation index accounts for total count (predefined + custom).

### Trade-off 1: Icon Curation vs. Full SF Symbols Library
**Trade-off**: Limited icon picker (15-20 symbols) vs. searchable full library (5000+ symbols).  
**Decision**: Start with curated list for simplicity. Add search/browse in future iteration if users request more options.

### Trade-off 2: Custom Room Editing
**Trade-off**: Allow editing custom room name/icon during onboarding vs. lock after creation.  
**Decision**: No editing during onboarding (keeps flow simple). Post-onboarding editing is future work in Room Management capability.

### Trade-off 3: RoomType Sentinel Case
**Trade-off**: `.customRoom` sentinel case vs. making `kind` optional for custom rooms.  
**Decision**: Sentinel case maintains non-optional enum (safer, less refactoring). `.customRoom` never shown in UI, purely internal marker.

## Open Questions

1. **Dining Room Icon**: Which SF Symbol? Options: `fork.knife.circle`, `table.furniture`, `wineglass`
2. **Custom Room Limit**: Should there be a max (e.g., 10 custom rooms)? Or unlimited?
3. **Icon Validation**: Should we validate SF Symbol availability at save time or render time?
4. **Custom Room Naming**: Min/max character length for name? Regex validation?
5. **Accessibility**: What VoiceOver labels for custom room icons?
