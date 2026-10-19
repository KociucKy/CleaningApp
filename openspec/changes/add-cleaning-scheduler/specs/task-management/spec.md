## ADDED Requirements

### Requirement: Structural task changes refresh eligible scheduling
The system SHALL refresh eligible future schedule occurrences when a task is created, edited, or deleted. It SHALL preserve completed, skipped, postponed, and historical occurrences for audit purposes, subject to the task’s existing history-retention behavior.

#### Scenario: Creating a task schedules the remaining week
- **WHEN** the user creates a task during an active calendar week
- **THEN** the system makes the task eligible for pro-rated scheduling in the remaining days of that week

#### Scenario: Editing a task preserves completed history
- **WHEN** the user changes a task’s frequency or estimated duration
- **THEN** the system re-plans eligible future occurrences without deleting its completion history

