## ADDED Requirements

### Requirement: Display room list in grid layout

The system SHALL display all user rooms in a two-column grid layout using FulhamKit design system components.

#### Scenario: Rooms displayed in grid
- **WHEN** user navigates to Rooms tab
- **THEN** system displays all rooms in a LazyVGrid with 2 columns
- **THEN** each room card shows the room icon and room name
- **THEN** grid uses FulhamKit spacing (FKSpacing.medium between cards)

#### Scenario: Grid adapts to screen size
- **WHEN** device orientation changes
- **THEN** grid columns maintain equal width
- **THEN** cards remain properly spaced using FulhamKit layout constants

### Requirement: Display room icon and name

Each room card SHALL display the room's SF Symbol icon and name using FulhamKit typography.

#### Scenario: Room card content
- **WHEN** room is displayed in the list
- **THEN** system shows room type icon as SF Symbol (32pt size)
- **THEN** system shows room name below icon
- **THEN** name uses FKTypography.secondaryLabel style

#### Scenario: Custom room icon
- **WHEN** room has a custom icon defined
- **THEN** system displays the custom SF Symbol instead of default room type icon

### Requirement: Handle empty state

The system SHALL display an empty state message when no rooms exist.

#### Scenario: No rooms exist
- **WHEN** user has zero rooms in their account
- **THEN** system displays centered empty state UI
- **THEN** empty state shows an SF Symbol icon
- **THEN** empty state shows "No rooms yet" title using FKTypography
- **THEN** empty state shows descriptive text

#### Scenario: Rooms exist
- **WHEN** user has one or more rooms
- **THEN** system does not display empty state
- **THEN** system displays room grid instead

### Requirement: Provide tactile feedback

The system SHALL provide haptic feedback when user interacts with room cards.

#### Scenario: Room card tapped
- **WHEN** user taps on a room card
- **THEN** system triggers FKHaptics.selection() feedback
- **THEN** card applies .fkPressable visual effect

### Requirement: Support dark mode

The system SHALL automatically adapt to device dark mode using FulhamKit semantic colors.

#### Scenario: Dark mode enabled
- **WHEN** device is in dark mode
- **THEN** room cards use FKColor.Background.canvas
- **THEN** text uses FKColor.Label.primary and secondary
- **THEN** borders use FKColor.Separator.default

#### Scenario: Light mode enabled
- **WHEN** device is in light mode
- **THEN** system applies corresponding light mode FulhamKit colors

### Requirement: Fetch rooms from SwiftData

The system SHALL fetch all rooms from SwiftData on view initialization via the RIB architecture.

#### Scenario: Successful room fetch
- **WHEN** RoomsPresenter is initialized
- **THEN** presenter calls interactor.fetchRooms()
- **THEN** interactor returns array of Room domain models
- **THEN** presenter stores rooms for view display

#### Scenario: Room fetch fails
- **WHEN** room fetch throws an error
- **THEN** presenter catches the error
- **THEN** presenter sets error message property
- **THEN** view displays error message to user

### Requirement: Sort rooms by creation date

The system SHALL display rooms sorted by creation date with newest rooms first.

#### Scenario: Multiple rooms exist
- **WHEN** user has multiple rooms
- **THEN** system displays rooms in descending order by createdAt
- **THEN** most recently created room appears first in grid
