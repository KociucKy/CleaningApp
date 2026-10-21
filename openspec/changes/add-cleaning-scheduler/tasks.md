## 1. Schedule Domain and Persistence

- [ ] 1.1 Add `ScheduledTaskStatus` and `ScheduledTask` domain models with occurrence-lineage fields.
- [ ] 1.2 Add `ScheduledTaskEntity` and register it in every SwiftData model container configuration.
- [ ] 1.3 Add optional `scheduledTaskId` to completed and skipped domain models, entities, mappers, mocks, and repository update paths.
- [ ] 1.4 Add optional `learnedDuration` to `RoomTask`, `RoomTaskEntity`, mappers, mocks, and repository update paths.
- [ ] 1.5 Implement `ScheduledTaskMapper` and `ScheduledTaskRepository` with mock and SwiftData implementations.
- [ ] 1.6 Implement `ScheduledTaskManager` queries for schedule horizon, task ID, active occurrence, and lineage, plus save/update/delete operations.

## 2. Pure Scheduling Engine

- [ ] 2.1 Define `SchedulingInput`, `ScheduleMutation`, candidate, and daily-load value types without persistence dependencies.
- [ ] 2.2 Implement date normalization and Monday–Sunday planning-horizon helpers using an injected calendar.
- [ ] 2.3 Implement frequency canonicalization and rolling-activity candidate generation for daily and every-X-day frequencies.
- [ ] 2.4 Implement rolling-activity candidate generation for every-X-week and every-X-month frequencies.
- [ ] 2.5 Implement cumulative quota accounting and first-period pro-rating for times-per-week and times-per-month frequencies.
- [ ] 2.6 Implement active-occurrence deduplication, coalescing, overdue detection, and backlog candidate generation.
- [ ] 2.7 Implement capacity eligibility, long-task exclusive-day handling, and least-flexible-first candidate ordering.
- [ ] 2.8 Implement deterministic day scoring for backlog/overdue and regular candidates.
- [ ] 2.9 Implement conversion of unplaceable candidates to postponed/backlog mutations.

## 3. Scheduling Coordination and Lifecycle

- [ ] 3.1 Create `CleaningScheduleCoordinator` protocol and implementation that gathers manager data, invokes `SchedulingService`, and persists mutations.
- [ ] 3.2 Implement schedule refresh operations for first launch, new day, manual refresh, and structural task changes.
- [ ] 3.3 Implement completion flow that updates the occurrence and creates a linked `CompletedTask` record.
- [ ] 3.4 Implement skip flow that updates the occurrence, creates a linked `SkippedTask` record, and allocates a successor no earlier than tomorrow.
- [ ] 3.5 Implement undo-skip flow that cancels the successor, removes or reverses the linked skip record, and restores the original occurrence to today.
- [ ] 3.6 Implement day-end carry-forward flow that marks incomplete occurrences postponed and preserves one active overdue representation per task.
- [ ] 3.7 Register repositories, managers, scheduling service, and coordinator in `DependencyContainer` for production and MOCK builds.

## 4. Schedule Feature Integration

- [ ] 4.1 Extend `ScheduleInteractor` and `CoreInteractor` with schedule query, refresh, completion, skip, and undo operations.
- [ ] 4.2 Refactor the existing mock-backed `ScheduleView` and `SchedulePresenter` to render scheduled, backlog, and skipped occurrences without moving scheduling rules into presentation.
- [ ] 4.3 Replace `ScheduleView`'s local completion state with coordinator-backed complete, skip, and undo actions.
- [ ] 4.4 Trigger scheduling refresh after task creation, editing, deletion, room-structure changes, and the agreed app/day refresh events.
- [ ] 4.5 Display effective duration using learned duration when present and the user estimate otherwise.

## 5. Tests and Verification

- [ ] 5.1 Add mapper, repository, and manager tests for scheduled occurrences and optional persisted fields.
- [ ] 5.2 Add deterministic `SchedulingService` tests for every frequency family, aliases, partial-period pro-rating, and cumulative quota accounting.
- [ ] 5.3 Add allocation tests for daily limits, two-minute tolerance, long-task exclusive days, spacing, stable ties, and least-flexible-first ordering.
- [ ] 5.4 Add lifecycle tests for completion, skip, undo skip, coalescing, overdue carry-forward, backlog persistence, and Monday backlog priority.
- [ ] 5.5 Add calendar boundary tests for Monday starts, month/year boundaries, daylight-saving transitions, and time-zone-normalized dates.
- [ ] 5.6 Add coordinator and interactor tests using mock repositories and fixed calendar/date inputs.
- [ ] 5.7 Run SwiftFormat, SwiftLint, the `CleaningApp - Mock` test suite, and a `CleaningApp - Dev` build.
