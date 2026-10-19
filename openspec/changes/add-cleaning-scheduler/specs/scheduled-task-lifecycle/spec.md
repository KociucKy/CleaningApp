## ADDED Requirements

### Requirement: Persist schedule occurrence lineage
The system SHALL persist every scheduled occurrence with its task ID, scheduled date, immutable original scheduled date, lifecycle status, timestamps, and optional source occurrence ID. A carried successor SHALL reference the occurrence from which it originated.

#### Scenario: Reallocated work retains its origin
- **WHEN** an occurrence is carried to a later day
- **THEN** the replacement occurrence references the original occurrence and the original scheduled date remains available for history

### Requirement: Record completion against an occurrence
The system SHALL mark a completed scheduled occurrence as completed and SHALL save a completion-history record linked to that occurrence. It SHALL allow a completion record without an occurrence link for manual or legacy activity.

#### Scenario: Completing a planned task
- **WHEN** the user completes a planned occurrence
- **THEN** the occurrence becomes completed and a linked completion-history record is persisted

### Requirement: Skip and reallocate an occurrence
The system SHALL mark an occurrence skipped, save a linked skip-history record, keep the skipped occurrence available for Undo, and allocate any successor no earlier than tomorrow.

#### Scenario: Skipping today's task
- **WHEN** the user skips a planned task today
- **THEN** the task leaves today’s active list, remains visible as skipped, and any active replacement is scheduled no earlier than tomorrow

### Requirement: Undo a skipped occurrence
The system SHALL cancel the active successor linked to an undone skip and restore the original occurrence to planned status on the current day, even when doing so exceeds the normal daily limit.

#### Scenario: Undoing a skip restores today’s task
- **WHEN** the user undoes a skipped occurrence after a successor has been allocated
- **THEN** the successor is cancelled and the original occurrence is returned to today’s planned list

### Requirement: Carry forward incomplete planned work
The system SHALL mark a planned occurrence as postponed after its scheduled day has ended without completion or skip. It SHALL create or retain a linked active successor/backlog representation while ensuring no more than one overdue candidate per task is active.

#### Scenario: Day-end incomplete task becomes overdue
- **WHEN** a planned occurrence remains incomplete after its calendar day ends
- **THEN** the system marks it postponed and considers one carried candidate for a later day

