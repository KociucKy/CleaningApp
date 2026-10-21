## ADDED Requirements

### Requirement: Plan the remaining calendar week
The system SHALL generate schedule occurrences only for the local calendar days from the planning date through the following Sunday. It SHALL preserve future planned occurrences already in that horizon and SHALL not modify a prior calendar day during ordinary re-planning.

#### Scenario: Re-planning preserves a future assignment
- **WHEN** a task is already planned for Friday and the system refreshes the plan on Wednesday
- **THEN** the Friday occurrence remains assigned to Friday

#### Scenario: Planning starts in the middle of a week
- **WHEN** the system creates a plan on Wednesday
- **THEN** it considers only Wednesday through Sunday as new regular scheduling days

### Requirement: Generate recurrence candidates from frequency and activity
The system SHALL canonicalize frequency aliases and generate candidates using rolling activity intervals for interval frequencies and cumulative calendar-period quotas for count frequencies. It SHALL use the task creation date as the initial activity anchor when the task has no completion or active scheduled occurrence.

#### Scenario: First partial weekly quota is pro-rated
- **WHEN** a task with frequency three times per week is created and first planned on Wednesday
- **THEN** the system generates two regular occurrences for Wednesday through Sunday

#### Scenario: Monthly quota is not lost through weekly rounding
- **WHEN** a task requires one occurrence per month and the system re-plans in each week of that month
- **THEN** cumulative quota accounting schedules the required monthly occurrence by the appropriate point in the active month rather than rounding every weekly share to zero

#### Scenario: Rolling interval uses recent activity as context
- **WHEN** an every-three-days task has a recent completion or future active reservation
- **THEN** the system uses that activity to prefer approximately three-day spacing without persisting a standalone next-due date

### Requirement: Allocate candidates within daily capacity
The system SHALL limit ordinary task assignments to the user’s daily limit plus two minutes. It SHALL assign a task longer than the normal daily limit only to an empty day and SHALL not add another task to that day.

#### Scenario: Ordinary task respects the effective daily limit
- **WHEN** adding a ten-minute task would raise a day from 25 to 35 minutes with a 30-minute daily limit
- **THEN** the system does not assign that task to the day

#### Scenario: Long task owns an empty day
- **WHEN** a 60-minute task is eligible with a 30-minute daily limit
- **THEN** the system assigns it only to an empty eligible day and schedules no other task on that day

### Requirement: Optimize placement predictably
The system SHALL process persisted backlog before overdue work and regular recurrence work. Within a priority tier, it SHALL place less flexible tasks first. It SHALL place backlog and overdue work on the earliest eligible day, and it SHALL place regular work by greatest same-task separation followed by the lowest projected daily-load imbalance.

#### Scenario: Backlog takes precedence over regular work
- **WHEN** backlog and regular candidates compete for the same limited capacity
- **THEN** the system allocates the backlog candidate before the regular candidate

#### Scenario: Repeated regular work is distributed
- **WHEN** a task has multiple regular occurrences in a planning horizon
- **THEN** the system selects eligible days that maximize separation from its other occurrences before using daily-load tie-breakers

### Requirement: Coalesce missed and regular work
The system SHALL represent at most one active occurrence for a task on any calendar day. It SHALL coalesce a carried occurrence with an otherwise duplicate regular recurrence occurrence rather than requiring two executions of the task.

#### Scenario: Skipped daily task does not create duplicate tomorrow work
- **WHEN** a daily task is skipped today and a regular occurrence is due tomorrow
- **THEN** the system creates at most one active occurrence for that task tomorrow

### Requirement: Persist unplaceable work as backlog
The system SHALL persist a candidate that cannot be assigned within the planning horizon as postponed backlog. It SHALL include backlog candidates before regular candidates on the next planning run.

#### Scenario: Full week creates visible backlog
- **WHEN** no eligible day has capacity for a candidate
- **THEN** the system persists the candidate as postponed backlog instead of discarding it

### Requirement: Present the operational plan in ScheduleView
The system SHALL present planned, postponed/backlog, and skipped schedule occurrences in the separate `ScheduleView` feature. `ScheduleView` SHALL retain its Monday–Sunday pager, render occurrences only from the current planning date through Sunday, and leave earlier weekday pages intentionally empty. `ScheduleView` SHALL obtain display data and lifecycle actions through its interactor and presenter, and SHALL NOT own mock schedule data or local completion state. `HomeView` SHALL remain outside the operational schedule UI scope.

#### Scenario: ScheduleView renders persisted occurrences
- **WHEN** the user opens ScheduleView after occurrences have been persisted
- **THEN** the view displays those occurrences from presenter-provided data rather than static mock tasks

#### Scenario: Earlier weekday page is intentionally empty
- **WHEN** the user opens ScheduleView on Wednesday
- **THEN** the Monday and Tuesday pages contain no operational schedule tasks
