## Context

CleaningApp persists rooms, recurring `RoomTask` definitions, completion history, and skipped-task history, but has no persistent plan or scheduling service. The current product specification describes a derived `ScheduledTask`, yet users require a stable plan: future assignments must survive re-planning, a skipped item must remain undoable while its replacement is scheduled, and unplaceable work must remain visible as backlog.

The app uses Swift 6, SwiftUI, SwiftData, synchronous `throws` APIs, and a RIB-inspired architecture. Domain models are plain Swift types; persistence follows entity, mapper, repository, and manager layers. Existing managers are `@MainActor`, and business rules belong in services rather than presenters or interactors.

## Goals / Non-Goals

**Goals:**

- Create a deterministic, testable scheduler that produces the remaining current-week plan from task definitions, activity history, existing schedule occurrences, calendar context, and a daily limit.
- Persist occurrence lifecycle and carry-forward lineage so plans remain stable and skipped work can be undone without ambiguity.
- Support all existing `Frequency` cases using canonicalization, rolling intervals, calendar-period quotas, capacity limits, coalescing, and backlog priority.
- Preserve existing RIB and manager/repository boundaries while keeping the allocation engine independent of SwiftData and wall-clock time.
- Add a nullable learned-duration value that can be displayed and used by scheduling before a later feature calculates it.

**Non-Goals:**

- User-selected available/unavailable days, preferred cleaning days, or premium scheduling rules.
- Splitting one task occurrence across multiple days.
- Notifications, Home UI layout, analytics, duration-learning calculation, CloudKit, or multi-household synchronization.
- Asynchronous scheduling or Combine-based state.

## Decisions

### 1. Persist schedule occurrences as an immutable-intent chain

Add the following domain and SwiftData types:

```swift
enum ScheduledTaskStatus: String, Codable, Hashable {
    case planned
    case completed
    case skipped
    case postponed
    case cancelled
}

struct ScheduledTask: Identifiable, Equatable {
    let id: UUID
    let taskId: UUID
    let scheduledDate: Date
    let originalScheduledDate: Date
    var status: ScheduledTaskStatus
    let sourceOccurrenceId: UUID?
    let createdAt: Date
    var updatedAt: Date
}
```

`ScheduledTaskEntity` mirrors these fields. `originalScheduledDate` never changes. A successor created to carry work forward references the original occurrence through `sourceOccurrenceId`; it is therefore possible to show a skipped item while a future replacement is active. `completed`, `skipped`, `postponed`, and `cancelled` occurrences remain historical records.

`CompletedTask` and `SkippedTask` gain an optional `scheduledTaskId` and their entities, mappers, repositories, mocks, and tests are updated accordingly. The optional field permits unscheduled/manual activity while giving scheduled actions an exact audit link.

**Rationale:** Moving a single mutable occurrence loses the day it was skipped and makes Undo ambiguous. An occurrence chain is auditable, supports cancellation of a successor on Undo, and avoids duplicate active work.

**Alternative considered:** Keep all schedule data derived from completions and skips. Rejected because it cannot preserve future assignments during a later re-plan or persist unplaceable backlog.

### 2. Separate pure planning from persistence and feature orchestration

`SchedulingService` is a synchronous `@MainActor` service with no SwiftData dependency and no `Date.now` calls:

```swift
struct SchedulingInput {
    let tasks: [RoomTask]
    let scheduledTasks: [ScheduledTask]
    let completedTasks: [CompletedTask]
    let skippedTasks: [SkippedTask]
    let today: Date
    let dailyLimit: Int
    let calendar: Calendar
}

struct ScheduleMutation {
    let occurrencesToCreate: [ScheduledTask]
    let occurrencesToUpdate: [ScheduledTask]
}
```

`ScheduledTaskManager` supplies persistence access using the established mapper/repository pattern. `CleaningScheduleCoordinator` owns the workflow: it fetches the inputs through `RoomTaskManager`, `ScheduledTaskManager`, `CompletedTaskManager`, and `SkippedTaskManager`; invokes `SchedulingService`; writes its mutation; and implements complete, skip, undo-skip, and refresh actions. Feature interactors call the coordinator through narrow protocols and do not contain scheduling policy.

**Rationale:** Value inputs make recurrence and allocation unit-testable with fixed dates. The coordinator preserves the project’s service-first architecture without coupling the algorithm to SwiftData predicates or UI state.

**Alternative considered:** Put scheduling directly in `CoreInteractor` or a SwiftData repository. Rejected because business policy would become hard to test and would leak into RIB plumbing or persistence code.

### 3. Use normalized local calendar days and explicit planning horizons

The coordinator obtains `today` and a calendar with Monday as the first weekday. `SchedulingService` normalizes every relevant timestamp with `calendar.startOfDay(for:)`. A regular plan horizon begins on `today` and ends on that calendar week’s Sunday; re-planning never revisits prior calendar days.

Future `.planned` occurrences in that horizon are immutable reservations. Completed, skipped, cancelled, and postponed records remain history, while their active successors determine remaining work. An early completion changes the occurrence to `.completed` but does not trigger replacement allocation that day.

**Rationale:** Date normalization prevents time-of-day and time-zone changes from producing duplicate same-day work. Preserving reservations makes plans predictable.

### 4. Generate recurrence candidates with rolling intervals and cumulative quotas

Canonicalize frequency aliases first. Candidate generation follows these rules:

- `daily` and `everyXDays` use a rolling cadence. The latest completion and active planned reservation establish context; `RoomTask.createdAt` is the initial anchor. The interval is a placement preference, not a persisted next-due date.
- `everyXWeeks` and `everyXMonths` use the same rolling-activity principle at week or month scale.
- `timesPerWeek` and `timesPerMonth` use cumulative quota accounting. The first active calendar period is pro-rated from the task creation date. For each later window, calculate the target count due through that window’s end, then subtract completed and preserved active occurrences already counted in the period.
- Candidate generation produces no more than one active occurrence for a task on a calendar day and coalesces a carried occurrence with an otherwise duplicate regular occurrence.
- Past incomplete planned work produces one overdue candidate per task. When capacity cannot accommodate an active candidate, persist it as postponed/backlog rather than dropping it.

**Rationale:** Independent rounding of each week would allow monthly tasks to round to zero indefinitely. Cumulative accounting meets calendar-period targets while first-week pro-rating prevents new users from receiving a full week’s burden late in the week.

**Alternative considered:** Persist a single next-due date per task. Rejected because it makes re-planning rigid and does not represent quotas such as three tasks per week or month.

### 5. Allocate by urgency, feasibility, spacing, and balanced load

Candidates are processed in order: persisted backlog, overdue work, then regular recurrence. Within a tier, less flexible work is processed first: longer effective duration, then fewer eligible days, then a stable ID tie-breaker.

An ordinary candidate may use only an eligible day that does not already contain the same task and would remain at or below `dailyLimit + 2` minutes. A candidate longer than the normal limit may use only an empty day and then exclusively owns it.

For backlog and overdue candidates, the earliest eligible day wins and projected load imbalance breaks ties. For regular candidates, select the day with greatest separation from the task’s nearby occurrences, then lowest projected standard deviation of daily load, lowest resulting day load, and earliest date.

Skipped work becomes inactive immediately, remains visible for Undo, and can be reallocated only from tomorrow onward. Undo cancels the linked successor and returns the original occurrence to `.planned` today, even if this exceeds the normal limit.

**Rationale:** The order recovers late work promptly while best-fit ordering prevents large tasks from being starved by smaller tasks. The regular-task score keeps the weekly plan even without sacrificing recurrence spacing.

### 6. Store a nullable learned duration separately from the user estimate

Add `learnedDuration: Int?` to `RoomTask` and `RoomTaskEntity`. Migrate mappers, repository update paths, mocks, and test fixtures. Scheduling uses `learnedDuration ?? estimatedDuration.rawValue`; the UI may display the effective duration. No part of this change calculates or mutates the learned value from history.

**Rationale:** The user’s selected estimate remains intact and explainable, while a later duration-learning feature can improve prediction without changing scheduler inputs or task schema again.

**Alternative considered:** Overwrite `estimatedDuration` after learning. Rejected because it erases the user’s explicit choice and makes learned behavior opaque.

## Risks / Trade-offs

- **[Risk] Multiple manager saves can leave history and occurrence state temporarily inconsistent if a persistence operation throws.** → The coordinator orders writes defensively, surfaces errors, and tests failure paths. A future SwiftData transaction/store abstraction can make multi-record lifecycle actions atomic if needed.
- **[Risk] Calendar edge cases (time-zone changes, daylight-saving transitions, week-year boundaries) can alter date comparisons.** → Normalize dates with an injected calendar and include boundary-focused tests.
- **[Risk] A greedy allocator is not mathematically globally optimal.** → The deterministic scoring model is explainable and sufficient for MVP-scale data. Inputs/outputs remain isolated so a future optimizer can replace the service implementation.
- **[Trade-off] Immutable occurrence chains increase stored records.** → This buys reliable audit history, Undo, and backlog visibility; expected data volume is small for a personal cleaning app.
- **[Trade-off] A 60-minute task may exceed the user’s target day.** → This is explicit product behavior; allocating it alone avoids hiding or indefinitely postponing it.

## Migration Plan

1. Add the new scheduled-occurrence SwiftData model and include it in the app’s model container.
2. Add optional `learnedDuration` and optional scheduled-occurrence IDs to existing entities; optional fields allow lightweight migration for existing stores.
3. Register production and mock scheduled-task repositories/managers and the coordinator/service through the dependency container.
4. On first refresh after update, generate only future schedule occurrences; existing completion and skip history remain unchanged.
5. If a scheduling error occurs, preserve existing occurrences and display/retry through the calling feature rather than deleting or regenerating the plan.

## Open Questions

- `ScheduleView` is the dedicated operational screen for the schedule pager and task lifecycle actions. Its existing visual structure is retained while mock types and local completion state are replaced with presenter-provided schedule data. `HomeView` is outside this feature’s UI scope.
- The daily time limit needs a Settings persistence design before it becomes user-configurable; this change uses the existing product default of 30 minutes.
- The future learned-duration feature must choose its estimator (for example, median or rolling average) and minimum sample count.
