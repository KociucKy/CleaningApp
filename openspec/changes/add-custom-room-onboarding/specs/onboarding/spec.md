## ADDED Requirements

### Requirement: Toolbar provides custom room creation access

The system SHALL display a "+" button in the toolbar during room selection that initiates custom room creation.

#### Scenario: Plus button visible in toolbar
- **WHEN** user views the room selection screen
- **THEN** system displays a "+" button in the trailing position of the navigation toolbar

#### Scenario: Plus button triggers bottom sheet
- **WHEN** user taps the "+" button
- **THEN** system presents a bottom sheet containing the custom room creation form

### Requirement: Custom room creation is non-blocking

Creating custom rooms SHALL NOT interfere with selecting predefined rooms or proceeding through onboarding.

#### Scenario: User can select predefined rooms while custom room sheet is open
- **WHEN** bottom sheet is presented
- **THEN** system maintains the selected state of any previously selected predefined or custom rooms

#### Scenario: User can dismiss custom room creation
- **WHEN** user swipes down or taps outside the bottom sheet
- **THEN** system dismisses the sheet without creating a custom room

### Requirement: Custom and predefined rooms coexist

The system SHALL allow users to select both predefined and custom rooms together in any combination.

#### Scenario: Mixed selection of predefined and custom rooms
- **WHEN** user selects 2 predefined rooms (e.g., Kitchen, Bedroom) and creates 1 custom room (e.g., "Gym")
- **THEN** system displays all 3 rooms as selected in the grid

#### Scenario: Custom rooms saved alongside predefined rooms
- **WHEN** user completes onboarding with both predefined and custom rooms selected
- **THEN** system persists both types to the database

### Requirement: Custom room persistence in flow state

The system SHALL track custom rooms separately from predefined rooms in `OnboardingFlowState`.

#### Scenario: Custom rooms stored in separate collection
- **WHEN** user creates a custom room
- **THEN** system adds the custom room to `OnboardingFlowState.customRooms` array

#### Scenario: Custom rooms have unique identifiers
- **WHEN** multiple custom rooms are created with the same name
- **THEN** system assigns each a unique UUID to distinguish them

### Requirement: Save logic handles custom rooms

The system SHALL persist custom rooms during the onboarding completion save operation.

#### Scenario: Custom rooms saved with isCustom flag
- **WHEN** `saveAndCompleteOnboarding()` is called
- **THEN** system saves custom rooms as `Room` entities with `isCustom = true` and `kind = .customRoom`

#### Scenario: Custom room icons persisted
- **WHEN** custom rooms with user-selected icons are saved
- **THEN** system stores the SF Symbol name in the `customIcon` field

#### Scenario: Custom rooms have zero tasks initially
- **WHEN** custom rooms are saved
- **THEN** system does not create any `RoomTask` entities for custom rooms (unlike predefined rooms with suggested tasks)
