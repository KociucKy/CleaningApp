## ADDED Requirements

### Requirement: Scheduled actions retain exact history links
The system SHALL link completion and skip records created from a scheduled occurrence to that occurrence. It SHALL preserve the existing ability to record history without a scheduled occurrence.

#### Scenario: Manual completion remains supported
- **WHEN** a completion is recorded without a schedule occurrence
- **THEN** the system saves the completion with no occurrence link

#### Scenario: Scheduled skip is traceable
- **WHEN** a user skips a task from the daily schedule
- **THEN** the saved skip record references the skipped occurrence

