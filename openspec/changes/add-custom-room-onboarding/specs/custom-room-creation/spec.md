## ADDED Requirements

### Requirement: User can create custom rooms during onboarding

The system SHALL allow users to create custom rooms with user-defined names and icons during the onboarding room selection step.

#### Scenario: User accesses custom room creation
- **WHEN** user taps the "+" button in the toolbar of the room selection screen
- **THEN** system presents a bottom sheet for creating a custom room

#### Scenario: User creates custom room with name and icon
- **WHEN** user enters a room name and selects an icon
- **THEN** system creates a custom room and displays it in the room selection grid

#### Scenario: Custom room appears in selection grid
- **WHEN** user creates a custom room
- **THEN** the custom room appears as a selectable card in the grid alongside predefined rooms

#### Scenario: User selects custom room
- **WHEN** user taps on a custom room card
- **THEN** system toggles the custom room selection (same behavior as predefined rooms)

#### Scenario: Custom room persists through onboarding
- **WHEN** user completes onboarding with selected custom rooms
- **THEN** system persists custom rooms to the database with `isCustom = true` flag

### Requirement: Custom room input validation

The system SHALL validate custom room input and provide appropriate feedback.

#### Scenario: Empty room name rejected
- **WHEN** user attempts to create a custom room without entering a name
- **THEN** system disables the "Next" button and does not advance to icon selection

#### Scenario: Room name length validated
- **WHEN** user enters a room name exceeding 30 characters
- **THEN** system truncates input or displays character count warning

#### Scenario: Icon selection required
- **WHEN** user reaches icon selection step
- **THEN** system displays a curated grid of 15-20 SF Symbols relevant to rooms

#### Scenario: Default icon provided
- **WHEN** user does not select a custom icon
- **THEN** system uses a default icon (e.g., `square.grid.2x2`)

### Requirement: Custom room icon curation

The system SHALL present a curated list of SF Symbols appropriate for room types.

#### Scenario: Icon picker displays curated symbols
- **WHEN** user advances to icon selection
- **THEN** system displays 15-20 curated SF Symbols in a grid (e.g., `house`, `dumbbell`, `book`, `paintpalette`, `leaf`, `door.sliding.left.hand.open`)

#### Scenario: User selects icon
- **WHEN** user taps an icon in the grid
- **THEN** system marks the icon as selected and dismisses the bottom sheet

#### Scenario: Icon persists with custom room
- **WHEN** custom room is displayed in the grid
- **THEN** system shows the user-selected icon on the room card

### Requirement: Custom rooms start with zero tasks

Custom rooms SHALL NOT have suggested tasks pre-populated during onboarding.

#### Scenario: Custom room has no suggested tasks
- **WHEN** user proceeds to task selection for a custom room
- **THEN** system shows empty task list for that custom room

#### Scenario: User can add tasks manually later
- **WHEN** user completes onboarding with custom rooms
- **THEN** system allows user to add tasks to custom rooms in the main app (post-onboarding)

### Requirement: Unlimited custom rooms

The system SHALL allow users to create unlimited custom rooms during onboarding.

#### Scenario: Multiple custom rooms created
- **WHEN** user creates multiple custom rooms (e.g., 5 custom rooms)
- **THEN** system displays all custom rooms in the selection grid

#### Scenario: No artificial limit enforced
- **WHEN** user attempts to create the 11th custom room
- **THEN** system allows creation without displaying a limit error

### Requirement: Custom room UI integration

Custom rooms SHALL integrate seamlessly with the existing room selection grid.

#### Scenario: Custom rooms render after predefined rooms
- **WHEN** custom rooms are created
- **THEN** system appends custom room cards to the grid after the 9 predefined room types

#### Scenario: Custom rooms participate in staggered animation
- **WHEN** room selection screen appears
- **THEN** system animates custom room cards with the same staggered entrance effect as predefined rooms

#### Scenario: Custom room cards match design system
- **WHEN** custom rooms are displayed
- **THEN** system renders custom room cards with the same styling as predefined rooms (FKCardView, borders, selection state)
