# Domain: Room

**Status**: Implemented  
**Last Updated**: 2026-04-25

---

## Overview

A **Room** represents a physical space in a user's home that requires cleaning and maintenance. Rooms are the primary organizational unit in CleaningApp - they contain tasks and provide context for cleaning activities.

---

## Domain Model

### Core Entity

```swift
struct Room: Identifiable, Equatable {
    let id: UUID
    var name: String
    var kind: RoomType
    let createdAt: Date
}
```

**Properties**:
- `id`: Unique identifier, auto-generated
- `name`: User-provided name (e.g., "Master Bedroom", "Kitchen")
- `kind`: Room type from predefined enum (see below)
- `createdAt`: Timestamp of creation, immutable

### Room Types

```swift
enum RoomType: String, CaseIterable, Codable {
    case kitchen
    case livingRoom
    case bedroom
    case bathroom
    case hallway
    case office
    case garage
    case laundry
    case toilet
    case custom
}
```

**Predefined Types** (9 total):
| Type | Symbol | Example Tasks |
|------|--------|---------------|
| Kitchen | `fork.knife` | Wipe countertops, clean hob, empty bin |
| Living Room | `sofa` | Vacuum, dust surfaces, tidy cushions |
| Bedroom | `bed.double` | Make bed, vacuum, change linen |
| Bathroom | `shower` | Clean toilet, wipe sink, clean shower |
| Hallway | `door.left.hand.open` | Vacuum, wipe door handles |
| Office | `desktopcomputer` | Wipe desk, dust monitor |
| Garage | `car` | Sweep floor, organize tools |
| Laundry | `washer` | Clean lint filter, descale machine |
| Toilet | `toilet` | Clean bowl, wipe seat, mop floor |
| Custom | `square.grid.2x2` | No suggested tasks |

Each type (except `custom`) has **localized display names** and **suggested tasks** pre-configured.

---

## Persistence

### Entity Mapping

**SwiftData Entity**:
```swift
@Model
final class RoomEntity {
    var id: UUID
    var name: String
    var icon: String              // Stores RoomType.rawValue
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \RoomTaskEntity.room)
    var tasks: [RoomTaskEntity]
}
```

**Key Differences**:
- Domain model uses `kind: RoomType` enum
- Entity uses `icon: String` for persistence
- Entity has `tasks` relationship; domain model does not

**Mapping Logic** (`RoomMapper`):
- `toDomain(_: RoomEntity) -> Room`
  - Converts `icon` string back to `RoomType` enum
- `toEntity(_: Room) -> RoomEntity`
  - Stores `kind.rawValue` as `icon` string

---

## Business Rules

### Creation Rules
1. Room must have a non-empty `name`
2. Room must have a valid `kind` (one of the enum cases)
3. `id` is auto-generated if not provided
4. `createdAt` defaults to current timestamp

### Uniqueness
- No uniqueness constraint on `name` - users can have multiple "Bedroom" rooms
- Each room has a unique `id`

### Deletion Rules
- When a room is deleted, **all associated tasks are cascade-deleted**
- Cascade is enforced at the SwiftData relationship level
- No soft-delete; deletion is permanent

### Naming Constraints
- No explicit validation on name length in current implementation
- Empty names are technically possible (edge case not handled)

---

## Suggested Tasks

Each `RoomType` (except `custom`) provides a list of pre-populated tasks via:

```swift
extension RoomType {
    var suggestedTasks: [RoomTask] { ... }
}
```

**Characteristics**:
- Tasks have **stable, hardcoded UUIDs** (e.g., `A1000000-0000-0000-0000-000000000001`)
- UUIDs ensure identity is preserved across multiple calls
- `roomId` is a placeholder UUID - must be replaced before persisting
- Number of suggested tasks varies by room type (4-7 tasks typically)

**Usage**: 
- During onboarding, users select rooms and get suggested tasks
- First 3 tasks are auto-selected by default
- Suggested tasks are starting templates, not enforced

---

## Related Models

- **RoomTask**: Tasks belong to a room via `roomId` foreign key
- **OnboardingFlowState**: Temporarily holds room selections during setup

---

## Open Questions

1. **Name Validation**: Should we enforce minimum/maximum length for room names?
2. **Uniqueness**: Should we prevent duplicate room names? Or allow multiples?
3. **Custom Room Type**: Can users customize the icon for custom rooms?
4. **Archival**: Should rooms be soft-deleted instead of hard-deleted for data retention?
5. **Ordering**: Is there a concept of room ordering/priority?

---

## Implementation References

- Domain: `Models/Domain/Room.swift`
- Domain extensions: `Models/Domain/RoomType.swift`, `Models/Domain/RoomType+SuggestedTasks.swift`
- Persistence: `Models/Entities/RoomEntity.swift`
- Repository: `Models/Services/Room/RoomRepository.swift`
- Manager: `Models/Services/Room/RoomManager.swift`
- Mapper: `Models/Services/Room/RoomMapper.swift`
