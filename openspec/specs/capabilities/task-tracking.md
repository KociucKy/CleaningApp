# Capability: Task Tracking

**Status**: Backend Implemented, UI Unknown  
**Last Updated**: 2026-04-25

---

## Overview

**Task Tracking** allows users to record when they complete or skip cleaning tasks. This creates a historical record of cleaning activity and enables analytics, progress tracking, and scheduling.

Two types of tracking:
1. **Completion**: Task was done
2. **Skip**: Task was deliberately not done

---

## User Capabilities

### Mark Task Complete

**Purpose**: Record that a task was completed.

**Interactor Method**:
```swift
func saveCompletedTask(_ task: CompletedTask) throws
```

**Expected Flow**:
1. User sees task in their list
2. User taps checkbox/complete button
3. (Optional) User records actual duration taken
4. `CompletedTask` record created:
   - `taskId`: Links to the task
   - `completedAt`: Current timestamp
   - `measuredDuration`: Optional actual time (in minutes)
5. UI updates to show completion (checkmark, strikethrough, etc.)

**Business Rules**:
- Same task can be completed multiple times (new record each time)
- `completedAt` defaults to current timestamp
- `measuredDuration` is optional
- No validation that `taskId` exists (allows orphaned records)

---

### Mark Task Skipped

**Purpose**: Record that a task was deliberately skipped/postponed.

**Interactor Method**:
```swift
func saveSkippedTask(_ task: SkippedTask) throws
```

**Expected Flow**:
1. User sees task in their list
2. User taps "Skip" button
3. `SkippedTask` record created:
   - `taskId`: Links to the task
   - `originalDate`: When task was supposed to be done
   - `skippedAt`: Current timestamp
4. UI updates to show skip status

**Business Rules**:
- Same task can be skipped multiple times
- `originalDate` vs `skippedAt` tracks delay/postponement
- No validation that `taskId` exists

---

### View Task History

**Purpose**: See all past completions for a specific task.

**Interactor Method**:
```swift
func fetchAllCompletedTasks(for taskId: UUID) throws -> [CompletedTask]
```

**Expected Display**:
- List of all completions for this task
- Each record shows:
  - Date/time completed
  - Actual duration (if recorded)
- Sorted by date (newest first)

**Use Cases**:
- "When did I last clean the bathroom?"
- "How long does vacuuming usually take?"
- "Have I been doing this task regularly?"

---

### View All Completions

**Purpose**: See all completed tasks across all rooms.

**Interactor Method**:
```swift
func fetchAllCompletedTasks() throws -> [CompletedTask]
```

**Expected Display**:
- Timeline of recent activity
- Grouped by date (Today, Yesterday, This Week, etc.)
- Shows task name, room, time completed

**Use Cases**:
- "What have I accomplished this week?"
- Weekly/monthly summaries
- Progress dashboards

---

### Undo Completion/Skip

**Purpose**: Reverse accidental marking.

**Interactor Method**:
```swift
func deleteCompletedTask(_ task: CompletedTask) throws
func deleteSkippedTask(_ task: SkippedTask) throws
```

**Expected Flow**:
1. User accidentally marks task complete
2. User taps "Undo" or swipes to delete from history
3. Record is deleted
4. UI reverts to incomplete state

**Note**: Currently no UI for this - method exists but may be unused.

---

## Tracking Details

### CompletedTask Record

```swift
struct CompletedTask {
    let id: UUID
    let taskId: UUID
    let completedAt: Date
    var measuredDuration: Int?    // minutes
}
```

**Fields**:
- `id`: Unique identifier for this specific completion
- `taskId`: Which task was completed (foreign key)
- `completedAt`: When it was marked done
- `measuredDuration`: How long it actually took (optional)

**Purpose of measuredDuration**:
- Compare actual vs. estimated time
- Learn typical duration over time
- Adjust future estimates
- Calculate total time spent cleaning

---

### SkippedTask Record

```swift
struct SkippedTask {
    let id: UUID
    let taskId: UUID
    let originalDate: Date
    let skippedAt: Date
}
```

**Fields**:
- `id`: Unique identifier for this skip instance
- `taskId`: Which task was skipped
- `originalDate`: When task was supposed to be done
- `skippedAt`: When user marked it skipped

**Why track originalDate?**
- Distinguish "skipped today's task" from "skipped yesterday's overdue task"
- Track how long tasks remain undone
- Analyze skip patterns

---

## UI Patterns (Expected)

### Quick Complete (No Duration)

```
┌─────────────────────────────────────┐
│  ☐ Wipe countertops                │
│    Daily • 5 min                   │
└─────────────────────────────────────┘
           ↓ (tap checkbox)
┌─────────────────────────────────────┐
│  ☑ Wipe countertops                │
│    Daily • 5 min                   │
│    ✅ Completed just now           │
└─────────────────────────────────────┘
```

### Complete with Duration Tracking

```
┌─────────────────────────────────────┐
│  Complete Task                      │
│                                     │
│  Wipe countertops                  │
│                                     │
│  How long did it take?             │
│  ┌───┬───┬───┬───┬───┐            │
│  │ 5 │10 │15 │30 │60 │            │
│  └───┴───┴───┴───┴───┘            │
│        minutes                      │
│                                     │
│  [Skip]          [Done]            │
└─────────────────────────────────────┘
```

### Task History View

```
┌─────────────────────────────────────┐
│  Wipe Countertops - History        │
│                                     │
│  ✅ Today at 10:30 AM              │
│     Took 6 minutes                 │
│                                     │
│  ✅ Yesterday at 11:15 AM          │
│     Took 5 minutes                 │
│                                     │
│  ⏭️ Apr 23 (skipped)               │
│                                     │
│  ✅ Apr 22 at 9:45 AM              │
│     Took 7 minutes                 │
│                                     │
└─────────────────────────────────────┘
```

---

## Business Rules

### Completion Rules
1. Task can be completed multiple times (creates new record each time)
2. `completedAt` defaults to current timestamp if not specified
3. `measuredDuration` is optional - quick complete is valid
4. No validation that `taskId` exists - allows orphaned records
5. No uniqueness constraint - same task can be completed twice at same timestamp (edge case)

### Skip Rules
1. Task can be skipped multiple times
2. `originalDate` should represent when task was due
3. `skippedAt` defaults to current timestamp
4. No validation that `originalDate` <= `skippedAt` (could backdate)
5. No validation that `taskId` exists

### Data Retention
- Completion/skip records are **never automatically deleted**
- If task is deleted, records remain orphaned (intentional - preserves history)
- No cleanup/archival strategy
- Could accumulate large amount of data over time

---

## Current Implementation Status

### Implemented
- ✅ Data models (CompletedTask, SkippedTask)
- ✅ Entities (CompletedTaskEntity, SkippedTaskEntity)
- ✅ Repositories (fetch, save, delete)
- ✅ Managers (business logic layer)
- ✅ Interactor methods (all CRUD operations)
- ✅ Core interactor integration

### Not Implemented / Unknown
- ❓ Complete task UI (checkbox? button?)
- ❓ Skip task UI
- ❓ Duration entry UI
- ❓ History view UI
- ❓ Undo completion UI
- ❓ Activity timeline
- ❓ Progress indicators
- ❓ Analytics/statistics

**Evidence**: `HomeInteractor` only has `fetchAllRooms()` and `fetchAllRoomTasks()` - no completion methods exposed.

---

## Missing Features

### UI Features
1. **Quick Complete**: Tap to mark done (no duration)
2. **Timed Complete**: Record actual duration
3. **Skip Button**: Mark task as skipped
4. **Task History**: View past completions/skips
5. **Activity Feed**: Recent completions across all tasks
6. **Undo**: Reverse accidental marking
7. **Animations**: Visual feedback on completion

### Scheduling Integration
1. **Next Due Date**: Calculate based on frequency + last completion
2. **Overdue Status**: Show tasks past due date
3. **Upcoming Tasks**: Show tasks due soon
4. **Reminders**: Notifications for upcoming tasks
5. **Streak Tracking**: "5 days in a row"
6. **Schedule View**: Calendar showing past/future

### Analytics
1. **Completion Rate**: % of tasks completed on time
2. **Total Time**: Sum of `measuredDuration`
3. **Average Duration**: Compare to `estimatedDuration`
4. **Duration Learning**: Auto-adjust estimates
5. **Most/Least Completed**: Which tasks done most often
6. **Skip Analysis**: Why tasks are skipped
7. **Trends**: Completion over time (charts)
8. **Leaderboards**: Gamification

### Advanced Features
1. **Bulk Complete**: "Mark all as done"
2. **Templates**: "Complete morning routine" (multiple tasks)
3. **Photos**: Before/after task completion
4. **Notes**: Add context to completion
5. **Ratings**: How well was task done? (quality tracking)
6. **Export**: CSV/PDF of completion history

---

## Integration Points

### With Task Management
- Completion doesn't modify the `RoomTask` itself
- Task remains in system, ready to be completed again
- Historical data links to task via `taskId`

### With Scheduling (Future)
- Last completion date → calculate next due date
- Frequency → determine recurrence
- Example: Daily task completed today → due again tomorrow

### With Notifications (Future)
- Overdue tasks → send reminder
- Streak about to break → motivational notification
- Weekly summary → progress report

---

## Open Questions

1. **Automatic Completion**: Should recurring tasks auto-generate instances? Or complete against the template?
2. **Backfilling**: Can users mark tasks complete in the past?
3. **Editing History**: Can users edit `completedAt` or `measuredDuration`?
4. **Bulk Operations**: Complete all today's tasks at once?
5. **Quality Tracking**: Should users rate completion quality?
6. **Photo Evidence**: Should completions support before/after photos?
7. **Scheduling Logic**: How is "next due" calculated? Store or compute?
8. **Orphaned Data**: Should completion/skip records be deleted when task is deleted?
9. **Data Limits**: Maximum history length? Archive old records?
10. **Sharing**: Can users share completion stats with family/roommates?

---

## Implementation References

### CompletedTask
- Domain: `Models/Domain/CompletedTask.swift`
- Entity: `Models/Entities/CompletedTaskEntity.swift`
- Repository: `Models/Services/CompletedTask/CompletedTaskRepository.swift`
- Manager: `Models/Services/CompletedTask/CompletedTaskManager.swift`
- Mapper: `Models/Services/CompletedTask/CompletedTaskMapper.swift`

### SkippedTask
- Domain: `Models/Domain/SkippedTask.swift`
- Entity: `Models/Entities/SkippedTaskEntity.swift`
- Repository: `Models/Services/SkippedTask/SkippedTaskRepository.swift`
- Manager: `Models/Services/SkippedTask/SkippedTaskManager.swift`
- Mapper: `Models/Services/SkippedTask/SkippedTaskMapper.swift`

### Integration
- Core methods: `Root/RIB/CoreInteractor.swift` (all completion/skip CRUD methods)
