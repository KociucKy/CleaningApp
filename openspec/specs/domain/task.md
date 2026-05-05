# Domain: Task

**Status**: Implemented  
**Last Updated**: 2026-04-25

---

## Overview

A **RoomTask** represents a cleaning or maintenance activity that needs to be performed in a specific room. Tasks define what needs to be done, how often, and approximately how long it takes.

Tasks are the core actionable items in CleaningApp - they drive the user's daily/weekly cleaning routines.

---

## Domain Model

### Core Entity

```swift
struct RoomTask: Identifiable, Equatable {
    let id: UUID
    var name: String
    var roomId: UUID
    var frequency: Frequency
    var estimatedDuration: TaskDuration
    let createdAt: Date
}
```

**Properties**:
- `id`: Unique identifier, auto-generated
- `name`: Task description (e.g., "Wipe countertops", "Vacuum floor")
- `roomId`: Foreign key to parent room
- `frequency`: How often the task should be performed (see Frequency domain)
- `estimatedDuration`: Expected time to complete (5/10/15/30/60 minutes)
- `createdAt`: Timestamp of creation, immutable

**Equatable**: Two tasks are equal if their `id` matches (identity-based)

---

## Persistence

### Entity Mapping

**SwiftData Entity**:
```swift
@Model
final class RoomTaskEntity {
    var id: UUID
    var name: String
    var room: RoomEntity?              // Relationship to parent room
    var frequencyEncoded: String        // Frequency serialized as string
    var estimatedDuration: Int          // Duration in minutes
    var createdAt: Date
}
```

**Key Differences**:
- Domain uses `roomId: UUID` (value); entity uses `room: RoomEntity?` (relationship)
- Domain uses `frequency: Frequency` enum; entity uses `frequencyEncoded: String`
- Domain uses `estimatedDuration: TaskDuration` enum; entity uses raw `Int`

**Mapping Logic** (`RoomTaskMapper`):
- Requires `FrequencyEncoder` to serialize/deserialize `Frequency` enum
- Maps between value-type `roomId` and relationship-type `room`

---

## Business Rules

### Creation Rules
1. Task must have a non-empty `name`
2. Task must reference a valid `roomId` that exists in the system
3. Task must have a valid `frequency` (see Frequency domain)
4. Task must have a valid `estimatedDuration` (one of 5 fixed buckets)
5. `id` is auto-generated if not provided
6. `createdAt` defaults to current timestamp

### Validation
- `RoomTaskManager.save()` validates that the parent room exists before saving
- If parent room doesn't exist, save operation silently returns (no error thrown)
- **Edge case**: This allows orphaned tasks in theory, though UI prevents it

### Deletion Rules
- Tasks can be deleted independently
- When parent room is deleted, all tasks are cascade-deleted (via SwiftData relationship)
- Deletion is permanent (no soft-delete)

### Task Lifecycle
- Tasks are created during onboarding or manually by users
- Tasks can be **completed** (creates `CompletedTask` record)
- Tasks can be **skipped** (creates `SkippedTask` record)
- Tasks themselves are never marked "done" - they remain scheduled per frequency

---

## Task Frequency

Tasks use a highly flexible `Frequency` enum. See `domain/frequency.md` for full details.

**Common patterns**:
- Daily tasks: `.daily` (e.g., "Make bed")
- Multiple times per week: `.timesPerWeek(3)` (e.g., "Clean sink")
- Weekly tasks: `.timesPerWeek(1)` (e.g., "Vacuum")
- Monthly tasks: `.monthly` (e.g., "Clean oven")
- Irregular: `.everyXDays(4)`, `.everyXWeeks(2)`, `.quarterly`, etc.

**Recurrence logic**: Not yet implemented. Frequency defines the schedule, but there's no scheduling engine yet.

---

## Task Duration

Fixed time buckets for task estimation:

```swift
enum TaskDuration: Int, CaseIterable, Codable {
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case sixtyMinutes = 60
}
```

**Purpose**:
- Helps users plan their cleaning sessions
- Allows filtering tasks by time available
- Can be compared against actual measured duration

**Measured Duration**:
- When a task is completed, users can optionally record actual time taken
- Stored as `measuredDuration: Int?` in `CompletedTask` record
- No automatic adjustment of `estimatedDuration` based on history (yet)

---

## Suggested Tasks

Each `RoomType` provides pre-configured task templates (see `domain/room.md`).

**Example** (Kitchen):
```swift
RoomTask(
    id: UUID(uuidString: "A1000000-0000-0000-0000-000000000001")!,
    name: "Wipe countertops",
    roomId: placeholder,
    frequency: .daily,
    estimatedDuration: .fiveMinutes
)
```

**Characteristics**:
- Stable UUIDs ensure identity across onboarding flows
- Localized names (e.g., `String(localized: "task.wipe_countertops")`)
- Sensible default frequency and duration
- `roomId` is placeholder - replaced when room is created

**Total suggested tasks**: ~40-50 across all room types

---

## Related Models

- **Room**: Parent entity via `roomId` foreign key
- **CompletedTask**: Historical record of task completions
- **SkippedTask**: Historical record of task skips
- **OnboardingFlowState**: Temporarily holds task selections during onboarding

---

## Open Questions

1. **Scheduling**: How should recurring tasks be scheduled? Daily notifications? Calendar integration?
2. **Duration Learning**: Should the system learn from `measuredDuration` and adjust `estimatedDuration`?
3. **Task Templates**: Should there be a library of reusable task templates beyond room suggestions?
4. **Subtasks**: Should complex tasks support subtasks/checklists?
5. **Task Status**: Should tasks have explicit status (pending/overdue/snoozed)?
6. **Custom Frequencies**: Can users create custom frequency patterns? (e.g., "Every Monday and Thursday")
7. **Orphaned Tasks**: Should validation throw an error instead of silently failing when parent room doesn't exist?

---

## Implementation References

- Domain: `Models/Domain/RoomTask.swift`
- Persistence: `Models/Entities/RoomTaskEntity.swift`
- Repository: `Models/Services/RoomTask/RoomTaskRepository.swift`
- Manager: `Models/Services/RoomTask/RoomTaskManager.swift`
- Mapper: `Models/Services/RoomTask/RoomTaskMapper.swift`
- Frequency: `Models/Domain/Frequency.swift`, `Models/Services/Frequency/FrequencyEncoder.swift`
- Duration: `Models/Domain/TaskDuration.swift`
