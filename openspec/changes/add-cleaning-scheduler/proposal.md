## Why

CleaningApp currently stores rooms, recurring cleaning tasks, completions, and skips, but it does not turn them into a dependable daily cleaning plan. Users still have to decide what to clean and when. The product goal is for the app to own that planning: provide a realistic daily list that respects recurrence, unfinished work, and daily capacity without constantly reshuffling the week.

## What Changes

- Add a scheduling capability that creates and maintains daily cleaning-task occurrences for the remaining days of the current calendar week.
- Persist planned occurrences and their lifecycle so that future assignments remain stable, skipped work is undoable, and deferred work cannot disappear.
- Allocate work using task frequency, completion history, skipped occurrences, backlog, estimated duration, and a configurable daily limit (30 minutes by default, with a two-minute tolerance).
- Prioritize overdue and postponed work, distribute repeated work across eligible days, and keep each task to at most one occurrence per day.
- Preserve future assignments during re-planning; only unplanned, overdue, postponed, or otherwise eligible occurrences are allocated or rebalanced.
- Support completion, skipping, undoing a skip, and deferred/backlog states as inputs to later planning.

## Product Rules Agreed So Far

- The scheduler plans the remaining portion of the current Monday–Sunday week and pro-rates frequency for the days remaining when a plan is first created or re-planned.
- A newly created task without completion history is eligible for the remaining current week.
- Recurrence is resolved during each planning run; it is not solely a fixed next-due date calculated from the most recent completion.
- An early completion removes its planned occurrence and affects future planning, but does not cause the scheduler to fill the newly free capacity immediately.
- A task becomes overdue only after its scheduled calendar day has ended.
- Repeated occurrences of a task are spread apart when possible and never appear more than once on the same calendar day.
- A task whose duration exceeds the daily limit may be scheduled alone on an otherwise empty day; no other task is added to that day.
- Skipping removes the task from today's active list immediately, keeps it visible as an undoable skipped item, and returns it to the general pool for allocation from tomorrow onward.
- Undoing a skip restores the original occurrence to today, even if that exceeds the daily limit.
- Unfinished work after midnight competes as overdue work and may push regular work to later days.
- If capacity runs out, the scheduler persists the occurrence as backlog. Backlog is visible to the user and has priority when Monday's new plan is generated.
- Monthly and longer frequencies target the appropriate calendar period while distributing occurrences across applicable weeks.

## Scheduling Approach Agreed So Far

- Canonicalize aliases (`everyOtherDay`, `monthly`, `quarterly`, and similar) before scheduling, then handle interval, weekly-quota, monthly-quota, and long-interval frequencies consistently.
- Use local calendar days and inject the planning date/calendar into the scheduling service for deterministic behavior and testing.
- For weekly and monthly quota frequencies, use cumulative quota accounting rather than independently rounding each planning window. A task's first partial period is pro-rated from its activation date; later full periods receive their full quota.
- Use rolling activity intervals for `everyXDays`, `everyXWeeks`, and `everyXMonths`. Recent completions and reserved future occurrences provide cadence context; `createdAt` is the initial anchor when no activity exists.
- Process candidates in this priority order: persisted backlog, overdue occurrences, then regular recurrence occurrences. Within each tier, place the least flexible work first (longer tasks, then tasks with fewer eligible days).
- Place backlog and overdue work on the earliest eligible day, using workload balance as the tie-breaker. Place regular work by greatest same-task separation, then the lowest projected daily-load standard deviation, lowest resulting load, and earliest date.
- Persist schedule occurrences as an immutable-intent chain. Each occurrence retains its original scheduled date and lifecycle status; a reallocated successor links to the occurrence it carries forward.
- Keep completion and skip history as the audit trail and add an optional exact link from each history record to its scheduled occurrence. Undoing a skip cancels its linked successor and restores the original occurrence to today.
- Keep recurrence and allocation logic in a pure `SchedulingService` that accepts explicit value inputs and returns a schedule mutation. A `CleaningScheduleCoordinator` loads and persists data through managers and exposes lifecycle operations to feature interactors.
- Add an optional persisted `learnedDuration` to `RoomTask`. Until a future learning feature writes it, the scheduler uses `learnedDuration ?? estimatedDuration.rawValue`.

## Capabilities

### New Capabilities

- `cleaning-scheduling`: Generate, persist, re-plan, and expose an optimized daily cleaning schedule.
- `scheduled-task-lifecycle`: Track a scheduled occurrence through planned, completed, skipped, and postponed/backlog states, including undoing a skip.

### Modified Capabilities

- `task-tracking`: Completing or skipping a task updates its scheduled occurrence as well as the existing completion/skip history.
- `task-management`: Creating, editing, or deleting a task triggers scheduling updates for eligible future occurrences.

## Impact

- **Domain and persistence:** Adds scheduled-occurrence models, SwiftData entities, mapping, repository, manager, and mock implementations. It also prepares a separate persisted learned-duration field for a later duration-learning feature.
- **Services:** Adds a synchronous scheduling service that evaluates recurrence and assigns eligible occurrences to calendar days.
- **Architecture:** Exposes scheduling and schedule-query operations through the Home feature's interactor layer; presenters and views remain free of scheduling logic.
- **UI:** This proposal enables a future Home daily-plan view and backlog/skipped-item presentation. Their detailed visual design is outside this change unless included in the implementation tasks later.
- **Testing:** Requires deterministic calendar/date tests, recurrence tests for every `Frequency` case, lifecycle tests, and capacity/distribution tests using the Mock scheme.

## Non-Goals

- User-selected preferred or unavailable cleaning days; this is a future premium capability.
- Splitting a single task across multiple days or sessions.
- Multiple occurrences of the same task on one calendar day.
- Automatic rebalancing immediately after an early completion.
- Replacing the user-entered estimate with learned duration in this change. The data-model extension will allow a later feature to display and use learned estimates.
- Notifications, gamification, multi-household support, or CloudKit synchronization.
