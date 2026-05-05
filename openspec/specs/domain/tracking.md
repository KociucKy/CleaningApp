# Domain: Tracking

**Status**: Implemented  
**Last Updated**: 2026-04-25

---

## Overview

**Tracking** captures historical data about task completion and skipping. This domain includes two models:
- **CompletedTask**: Records when a task was completed
- **SkippedTask**: Records when a task was deliberately skipped

These models enable:
- Tracking cleaning history
- Analyzing completion patterns
- Measuring actual vs. estimated time
- Understanding user behavior

---

## CompletedTask Model

```swift
struct CompletedTask: Identifiable {
    let id: UUID
    let taskId: UUID
    let completedAt: Date
    var measuredDuration: Int?    // Duration in minutes
}
```

**Properties**:
- `id`: Unique identifier for this completion record
- `taskId`: Foreign key to the `RoomTask` that was completed
- `completedAt`: Timestamp when task was marked complete
- `measuredDuration`: Optional actual time taken (in minutes)

**Purpose**:
- One completion record = one instance of a task being done
- Tasks can be completed multiple times (new record each time)
- Supports both "quick complete" (no duration) and "tracked complete" (with duration)

---

## SkippedTask Model

```swift
struct SkippedTask: Identifiable {
    let id: UUID
    let taskId: UUID
    let originalDate: Date
    let skippedAt: Date
}
```

**Properties**:
- `id`: Unique identifier for this skip record
- `taskId`: Foreign key to the `RoomTask` that was skipped
- `originalDate`: When the task was originally scheduled/due
- `skippedAt`: Timestamp when user marked it skipped

**Purpose**:
- Records intentional skips (not just "not done yet")
- Distinguishes between "forgot" and "chose not to do"
- `originalDate` vs `skippedAt` allows tracking delays

---

## Persistence

### CompletedTask Entity

```swift
@Model
final class CompletedTaskEntity {
    var id: UUID
    var taskId: UUID
    var completedAt: Date
    var measuredDuration: Int?
}
```

**No relationship to RoomTaskEntity** - uses simple UUID foreign key.

**Rationale**: Allows completion history to persist even if task is deleted.

### SkippedTask Entity

```swift
@Model
final class SkippedTaskEntity {
    var id: UUID
    var taskId: UUID
    var originalDate: Date
    var skippedAt: Date
}
```

**No relationship to RoomTaskEntity** - same pattern as CompletedTask.

---

## Business Rules

### Completion Rules
1. A task can be completed multiple times (creates new record each time)
2. `completedAt` defaults to current timestamp if not provided
3. `measuredDuration` is optional - users can quick-complete without tracking time
4. No validation that `taskId` references an existing task (allows orphaned records)
5. No uniqueness constraint - same task can be completed twice at same timestamp (edge case)

### Skip Rules
1. A task can be skipped multiple times (creates new record each time)
2. `originalDate` represents when the task was supposed to be done
3. `skippedAt` defaults to current timestamp
4. No validation that `originalDate` <= `skippedAt` (user could backdate)
5. No validation that `taskId` references an existing task

### Data Retention
- Completion and skip records are **never automatically deleted**
- If a task is deleted, historical records remain (orphaned)
- No cleanup/archival strategy currently implemented

---

## Repository Operations

### CompletedTask Repository

```swift
protocol CompletedTaskRepository {
    func fetchAll() throws -> [CompletedTaskEntity]
    func fetchAllForTaskId(_ taskId: UUID) throws -> [CompletedTaskEntity]
    func save(_ item: CompletedTaskEntity) throws
    func delete(_ item: CompletedTaskEntity) throws
}
```

**Key operations**:
- `fetchAll()`: All completion records across all tasks
- `fetchAllForTaskId()`: Completion history for a specific task
- No date range queries (e.g., "completions last 30 days")

### SkippedTask Repository

```swift
protocol SkippedTaskRepository {
    func fetchAll() throws -> [SkippedTaskEntity]
    func save(_ item: SkippedTaskEntity) throws
    func delete(_ item: SkippedTaskEntity) throws
}
```

**Limitation**: No `fetchAllForTaskId()` - can't query skips for a specific task.

---

## Usage Patterns

### Recording a Completion

```swift
let completion = CompletedTask(
    taskId: task.id,
    completedAt: Date(),
    measuredDuration: 12  // User took 12 minutes
)
try completedTaskManager.save(completion)
```

### Recording a Skip

```swift
let skip = SkippedTask(
    taskId: task.id,
    originalDate: expectedDueDate,
    skippedAt: Date()
)
try skippedTaskManager.save(skip)
```

### Viewing Task History

```swift
let completions = try completedTaskManager.fetchAll(for: task.id)
// Returns all times this task was completed, sorted by date
```

---

## Missing Features

### No Analytics Layer
- No aggregation queries (e.g., "tasks completed this week")
- No completion rate calculations
- No streak tracking ("cleaned kitchen 7 days in a row")
- No trend analysis (getting faster? slowing down?)

### No Scheduling Integration
- Completions don't affect next due date
- No concept of "overdue" vs "upcoming"
- No reminders based on frequency + last completion

### No Duration Learning
- `measuredDuration` is captured but not used
- System doesn't learn and adjust `estimatedDuration`
- No average/median calculations

### No Bulk Operations
- Can't "complete all tasks in a room"
- Can't "mark today's tasks done"
- Can't undo completion/skip

---

## Open Questions

1. **Task Deletion Impact**: Should completion/skip records be cascade-deleted when a task is deleted? Or preserved for analytics?
2. **Scheduling**: How should completions affect the next due date for recurring tasks?
3. **Validation**: Should we validate that `taskId` exists? Or allow orphaned records?
4. **Time Travel**: Should users be able to backdate completions/skips?
5. **Duration Learning**: Should the system auto-adjust `estimatedDuration` based on `measuredDuration` history?
6. **Bulk Actions**: Should there be a "complete multiple tasks" operation?
7. **Undo**: Should completion/skip be reversible? (Delete the record?)
8. **Streaks**: Should we track consecutive completions? Longest streak?
9. **Reminders**: Should the app notify users about overdue tasks based on frequency + last completion?
10. **Data Export**: Should users be able to export their completion history (CSV, etc.)?

---

## Implementation References

### CompletedTask
- Domain: `Models/Domain/CompletedTask.swift`
- Persistence: `Models/Entities/CompletedTaskEntity.swift`
- Repository: `Models/Services/CompletedTask/CompletedTaskRepository.swift`
- Manager: `Models/Services/CompletedTask/CompletedTaskManager.swift`
- Mapper: `Models/Services/CompletedTask/CompletedTaskMapper.swift`

### SkippedTask
- Domain: `Models/Domain/SkippedTask.swift`
- Persistence: `Models/Entities/SkippedTaskEntity.swift`
- Repository: `Models/Services/SkippedTask/SkippedTaskRepository.swift`
- Manager: `Models/Services/SkippedTask/SkippedTaskManager.swift`
- Mapper: `Models/Services/SkippedTask/SkippedTaskMapper.swift`
