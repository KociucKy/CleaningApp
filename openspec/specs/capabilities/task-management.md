# Capability: Task Management

**Status**: Partially Implemented  
**Last Updated**: 2026-04-25

---

## Overview

**Task Management** allows users to create, view, edit, and delete cleaning tasks within rooms. Tasks define what needs to be done, how often, and how long it takes.

Tasks are the core actionable items - they drive the user's daily/weekly cleaning routines.

---

## User Capabilities

### View All Tasks

**Purpose**: See all tasks across all rooms.

**Interactor Method**:
```swift
func fetchAllRoomTasks() throws -> [RoomTask]
```

**Expected Display**:
- List of all tasks (potentially grouped by room)
- Each task shows:
  - Task name (e.g., "Wipe countertops")
  - Room name/icon
  - Frequency (e.g., "Daily", "2x per week")
  - Estimated duration (e.g., "5 min")
  - Status indicators (overdue? upcoming?)

---

### View Tasks for Specific Room

**Purpose**: Filter tasks by room.

**Interactor Method**:
```swift
func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask]
```

**Expected Flow**:
1. User navigates to a room detail
2. Tasks for that room are displayed
3. User can add, edit, delete tasks

---

### Create Task

**Purpose**: Add a new task to a room.

**Interactor Method**:
```swift
func saveRoomTask(_ task: RoomTask) throws
```

**Expected Flow**:
1. User taps "Add Task" button (in room view or general task view)
2. Task creation form appears
3. User enters:
   - Task name (text input)
   - Room (picker - which room this task belongs to)
   - Frequency (picker - how often to perform)
   - Estimated duration (picker - 5/10/15/30/60 min)
4. User confirms
5. Task is saved
6. UI updates

**Validation** (at manager level):
- Validates that parent room exists before saving
- If room doesn't exist, save silently fails (no error thrown)

**Business Rules**:
- Task must have non-empty `name`
- Task must reference valid `roomId`
- Task must have valid `frequency` (one of Frequency enum cases)
- Task must have valid `estimatedDuration` (one of TaskDuration enum)
- `id` auto-generated if not provided
- `createdAt` defaults to current timestamp

---

### Edit Task

**Purpose**: Modify an existing task's properties.

**Current Status**: Uses same `saveRoomTask()` method (upsert by ID).

**Expected Flow**:
1. User taps on task in list
2. Edit form appears (pre-filled with current values)
3. User modifies any property:
   - Name
   - Room (can move to different room)
   - Frequency
   - Estimated duration
4. User confirms
5. Changes saved

**Business Rules**:
- Can change any property including `roomId` (move task to different room)
- Cannot change `id` or `createdAt`

---

### Delete Task

**Purpose**: Remove a task.

**Interactor Method**:
```swift
func deleteRoomTask(_ task: RoomTask) throws
```

**Expected Flow**:
1. User swipes task or taps delete button
2. Confirmation dialog appears (optional)
3. User confirms
4. Task deleted
5. UI updates

**Cascade Behavior**:
- Completion records (`CompletedTask`) are **not deleted** - they remain orphaned
- Skip records (`SkippedTask`) are **not deleted** - they remain orphaned
- Allows historical data retention even after task deletion

**Warning**: Deletion is permanent (no soft-delete).

---

## Task Properties

### Name
- User-provided description
- Examples: "Wipe countertops", "Vacuum bedroom", "Clean toilet"
- No length constraints enforced
- Localized for suggested tasks during onboarding

### Room Association
- Every task belongs to exactly one room
- Stored as `roomId: UUID` foreign key
- Can be changed (task can move between rooms)
- If room is deleted, task is cascade-deleted

### Frequency
- Defines recurrence pattern
- 15+ options: daily, weekly, monthly, custom intervals
- See `domain/frequency.md` for full details
- Displayed as localized string (e.g., "2 times per week")

### Estimated Duration
- Fixed buckets: 5, 10, 15, 30, 60 minutes
- Helps users plan cleaning sessions
- Can be compared against actual `measuredDuration` later

---

## UI Structure (Expected)

### Task List View

```
┌─────────────────────────────────────┐
│         Tasks Tab / Room Detail     │
│  [+ Add Task]                       │
│                                     │
│  Kitchen (5 tasks)                  │
│  ┌───────────────────────────────┐  │
│  │ ☐ Wipe countertops            │  │
│  │   Daily • 5 min               │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ ☐ Clean hob                   │  │
│  │   2x per week • 10 min        │  │
│  └───────────────────────────────┘  │
│                                     │
│  Bedroom (3 tasks)                  │
│  ┌───────────────────────────────┐  │
│  │ ☐ Make bed                    │  │
│  │   Daily • 5 min               │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Task Creation Form

```
┌─────────────────────────────────────┐
│         New Task                    │
│                                     │
│  Task Name                          │
│  ┌───────────────────────────────┐  │
│  │ Wipe kitchen countertops      │  │
│  └───────────────────────────────┘  │
│                                     │
│  Room                               │
│  ┌───────────────────────────────┐  │
│  │ Kitchen            ▼          │  │
│  └───────────────────────────────┘  │
│                                     │
│  Frequency                          │
│  ┌───────────────────────────────┐  │
│  │ Daily              ▼          │  │
│  └───────────────────────────────┘  │
│                                     │
│  Estimated Duration                 │
│  ┌───────────────────────────────┐  │
│  │ 5 minutes          ▼          │  │
│  └───────────────────────────────┘  │
│                                     │
│         [Cancel]   [Save]           │
└─────────────────────────────────────┘
```

---

## Business Rules

### Validation Rules
1. Task must have non-empty `name`
2. Task must reference an existing `roomId`
3. Task must have valid `frequency` (enum case)
4. Task must have valid `estimatedDuration` (5/10/15/30/60)
5. `id` is auto-generated if not provided
6. `createdAt` defaults to current timestamp

### Silent Failure Edge Case
**Issue**: `RoomTaskManager.save()` validates room existence but silently returns if room doesn't exist:

```swift
func save(_ model: RoomTask) throws {
    guard let roomEntity = try roomRepository.fetch(by: model.roomId) else {
        return  // ⚠️ Silent failure - no error thrown
    }
    // ... save task
}
```

**Implication**: 
- Invalid `roomId` doesn't throw error
- Task is not saved, but no feedback to user
- Could lead to confusion if UI doesn't validate

### Orphaned Data After Deletion
- When task is deleted, completion/skip history remains
- Allows analytics on deleted tasks
- Could accumulate orphaned data over time

---

## Current Implementation Status

### Implemented
- ✅ Data model (RoomTask, RoomTaskEntity)
- ✅ Repository (fetch, save, delete)
- ✅ Manager (business logic layer with room validation)
- ✅ Interactor methods (fetchAll, fetchAll(for:), save, delete)
- ✅ Core interactor integration

### Not Implemented / Unknown
- ❓ Task list UI
- ❓ Task creation form UI
- ❓ Task edit form UI
- ❓ Delete confirmation
- ❓ Empty state handling
- ❓ Task detail view
- ❓ Task completion UI (checkboxes?)
- ❓ Scheduling/reminder system

---

## Missing Features

### UI Features
1. **Task List View**: Main screen showing all or filtered tasks
2. **Add Task Flow**: Form to create new task
3. **Edit Task Flow**: Form to modify existing task
4. **Delete Confirmation**: Safety dialog
5. **Empty State**: Message when no tasks exist
6. **Task Detail View**: Expanded view with history
7. **Quick Actions**: Swipe actions for complete/skip/delete
8. **Filters**: By room, by frequency, by duration
9. **Search**: Find tasks by name

### Data Features
1. **Task Templates**: Library of reusable task templates
2. **Subtasks**: Break complex tasks into steps
3. **Task Notes**: Additional context or instructions
4. **Task Photos**: Before/after photos
5. **Task Ordering**: Custom sort within room
6. **Bulk Operations**: Complete/delete multiple tasks

### Scheduling Features
1. **Due Dates**: Calculate next due date based on frequency + last completion
2. **Overdue Status**: Mark tasks as overdue
3. **Reminders**: Push notifications for upcoming tasks
4. **Snooze**: Defer a task to later
5. **Calendar View**: Visualize tasks on calendar

### Analytics
1. **Completion Rate**: % of tasks completed on time
2. **Duration Learning**: Adjust estimate based on actual time
3. **Task History**: View past completions
4. **Streaks**: Track consecutive completions

---

## Integration with Tracking

### Completing a Task
- User marks task complete → creates `CompletedTask` record
- Optionally records actual duration
- See `capability/task-tracking.md` for details

### Skipping a Task
- User marks task skipped → creates `SkippedTask` record
- Records original due date
- See `capability/task-tracking.md` for details

---

## Open Questions

1. **Scheduling**: Should the system calculate "next due date" based on frequency?
2. **Reminders**: Should tasks trigger notifications?
3. **Templates**: Should there be a task template library beyond onboarding suggestions?
4. **Custom Frequencies**: Can users define custom recurrence patterns?
5. **Task Status**: Should tasks have explicit status (pending/overdue/snoozed)?
6. **Validation UI**: Should the UI validate room selection before save?
7. **Error Handling**: Should `save()` throw an error instead of silently failing?
8. **Task Limits**: Maximum tasks per room? Total tasks?
9. **Bulk Import**: Should users be able to import tasks from CSV/template?
10. **Task Sharing**: Can users share task lists with others?

---

## Implementation References

- Domain: `Models/Domain/RoomTask.swift`
- Entity: `Models/Entities/RoomTaskEntity.swift`
- Repository: `Models/Services/RoomTask/RoomTaskRepository.swift`
- Manager: `Models/Services/RoomTask/RoomTaskManager.swift`
- Mapper: `Models/Services/RoomTask/RoomTaskMapper.swift`
- Core methods: `Root/RIB/CoreInteractor.swift` (fetchAllRoomTasks, saveRoomTask, deleteRoomTask)
- Frequency: `Models/Domain/Frequency.swift`
- Duration: `Models/Domain/TaskDuration.swift`
