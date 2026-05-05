# Capability: Room Management

**Status**: Partially Implemented  
**Last Updated**: 2026-04-25

---

## Overview

**Room Management** allows users to create, view, edit, and delete rooms in their home. Rooms are the primary organizational unit - they contain tasks and provide context for cleaning activities.

This capability is accessible from the **Rooms** tab in the main app.

---

## User Capabilities

### View All Rooms

**Purpose**: See all rooms user has created.

**Current Implementation**: Unknown UI details (Rooms presenter/view not fully examined).

**Data Source**:
```swift
func fetchAllRooms() throws -> [Room]
```

**Expected Behavior**:
- List of all rooms, sorted by creation date
- Each room shows:
  - Room name
  - Room type icon
  - Task count (?)
- Empty state if no rooms exist

---

### Create Room

**Purpose**: Add a new room to the system.

**Interactor Method**:
```swift
func saveRoom(_ room: Room) throws
```

**Expected Flow**:
1. User taps "Add Room" button
2. Modal/sheet appears with room creation form
3. User selects:
   - Room type (Kitchen, Bedroom, etc.)
   - Room name (optional customization? currently uses type name)
4. User confirms
5. Room is saved to SwiftData
6. UI updates to show new room

**Business Rules**:
- Room must have valid `kind` (one of RoomType enum)
- Room must have non-empty `name`
- `id` auto-generated
- `createdAt` defaults to current time

**Edge Cases**:
- Duplicate names allowed (no uniqueness constraint)
- Can create multiple rooms of same type (e.g., two "Bedroom" rooms)

---

### Edit Room

**Purpose**: Modify an existing room's name or type.

**Current Status**: **Not explicitly implemented** (no dedicated edit method visible).

**Expected Implementation**:
```swift
// Editing uses same save() method - SwiftData upserts based on ID
func saveRoom(_ room: Room) throws
```

**Expected Flow**:
1. User taps on room in list
2. Edit sheet appears
3. User modifies name or type
4. User confirms
5. Changes saved

**Open Question**: Can room type be changed? Or only name?

---

### Delete Room

**Purpose**: Remove a room and all its tasks.

**Interactor Method**:
```swift
func deleteRoom(_ room: Room) throws
```

**Expected Flow**:
1. User swipes room in list (or taps delete button)
2. Confirmation dialog appears
3. User confirms deletion
4. Room and **all associated tasks** are deleted (cascade)
5. UI updates to remove room

**Cascade Behavior**:
- All `RoomTask` entities linked to this room are automatically deleted
- Enforced by SwiftData relationship: `@Relationship(deleteRule: .cascade)`

**Warning**: Deletion is **permanent** - no undo, no soft-delete.

**Open Question**: Are completion/skip records also deleted? Or do they remain orphaned?

---

## UI Structure (Expected)

```
┌─────────────────────────────────────┐
│         Rooms Tab                   │
│  [+ Add Room]                       │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🍴 Kitchen                   │  │
│  │  5 tasks                      │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🛏️ Master Bedroom           │  │
│  │  3 tasks                      │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🚿 Bathroom                  │  │
│  │  6 tasks                      │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

---

## Integration with Task Management

### Viewing Room Tasks

**Purpose**: Navigate from room to its tasks.

**Expected Flow**:
1. User taps on a room
2. Navigate to task list filtered by that room
3. OR: Show room detail with tasks inline

**Interactor Method**:
```swift
func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask]
```

### Creating Tasks for Room

- When user creates a room, they can immediately add tasks
- OR: Navigate to Task Management with room pre-selected

---

## Business Rules

### Validation
1. Room must have a valid `kind` (RoomType enum)
2. Room must have non-empty `name` (edge case: currently not enforced)
3. No uniqueness constraint on names

### Defaults
1. If name not provided, defaults to `RoomType.rawValue` (e.g., "Kitchen")
2. `id` auto-generated if not provided
3. `createdAt` defaults to current timestamp

### Deletion Cascade
1. Deleting a room deletes all associated tasks
2. Cascade enforced at database level
3. No warning about task count before deletion

---

## Current Implementation Status

### Implemented
- ✅ Data model (Room, RoomEntity)
- ✅ Repository (fetch, save, delete)
- ✅ Manager (business logic layer)
- ✅ Interactor protocol (RoomsInteractor)
- ✅ Core interactor methods (fetchAll, save, delete)
- ✅ Presenter skeleton (RoomsPresenter exists)

### Not Implemented / Unknown
- ❓ Room list UI
- ❓ Add room UI
- ❓ Edit room UI
- ❓ Delete confirmation dialog
- ❓ Empty state handling
- ❓ Room detail view
- ❓ Navigation to tasks for a room

**Evidence**: `RoomsInteractor` protocol is empty with "TODO" comment.

---

## Missing Features

### UI Features
1. **Room List View**: Main screen showing all rooms
2. **Add Room Flow**: Modal/sheet to create new room
3. **Edit Room Flow**: Modify existing room
4. **Delete Confirmation**: Safety dialog before deletion
5. **Empty State**: Message when no rooms exist
6. **Room Detail View**: Detailed view of single room with tasks

### Data Features
1. **Room Ordering**: Custom sort order (currently creation date only)
2. **Room Archival**: Soft-delete instead of hard-delete
3. **Room Templates**: Quick-create from templates
4. **Duplicate Room**: Clone a room with all its tasks
5. **Room Statistics**: Task completion rate, last cleaned, etc.

### Validation
1. **Name Length Limits**: Min/max constraints
2. **Duplicate Prevention**: Warn or prevent duplicate names
3. **Delete Warning**: Show task count before deleting

---

## Open Questions

1. **Editing**: Can users change room type after creation? Or only name?
2. **Naming**: During manual creation, can users customize the name? Or always use default?
3. **Ordering**: Should users be able to reorder rooms?
4. **Filtering**: Should there be filters (by type, by task count, etc.)?
5. **Search**: Should there be room search functionality?
6. **Bulk Operations**: Should users be able to delete multiple rooms at once?
7. **Room Limits**: Is there a maximum number of rooms?
8. **Orphaned Data**: When a room is deleted, what happens to completion/skip history?

---

## Implementation References

- Domain: `Models/Domain/Room.swift`
- Entity: `Models/Entities/RoomEntity.swift`
- Repository: `Models/Services/Room/RoomRepository.swift`
- Manager: `Models/Services/Room/RoomManager.swift`
- Interactor: `Core/Rooms/RIB/RoomsInteractor.swift` (empty, TODO)
- Presenter: `Core/Rooms/Presentation/RoomsPresenter.swift`
- Core methods: `Root/RIB/CoreInteractor.swift` (fetchAllRooms, saveRoom, deleteRoom)
