## ADDED Requirements

### Requirement: Time picker visibility based on notification permission
The system SHALL display a time picker on the onboarding completion screen only when the user has granted notification permissions during the onboarding flow.

#### Scenario: User granted notification permission
- **WHEN** user granted notification permission in the notification permission step
- **THEN** time picker is displayed on the completion screen between statistics and finish button

#### Scenario: User denied or skipped notification permission
- **WHEN** user denied or skipped notification permission in the notification permission step
- **THEN** time picker is not displayed on the completion screen

### Requirement: Default notification time
The system SHALL populate the time picker with a default time of 9:00 AM when displayed.

#### Scenario: Initial time picker display
- **WHEN** time picker is displayed for the first time
- **THEN** selected time is set to 9:00 AM

### Requirement: Time selection persistence
The system SHALL save the user's selected notification time to UserDefaults when the finish button is pressed.

#### Scenario: User selects custom time and finishes onboarding
- **WHEN** user selects a time (e.g., 2:30 PM) and presses the finish button
- **THEN** selected time is persisted to UserDefaults using the notification time key

#### Scenario: User keeps default time and finishes onboarding
- **WHEN** user does not change the default 9:00 AM time and presses the finish button
- **THEN** default time (9:00 AM) is persisted to UserDefaults

### Requirement: Initial notification scheduling
The system SHALL schedule a daily recurring notification at the selected time when the user completes onboarding with notifications enabled.

#### Scenario: User completes onboarding with custom notification time
- **WHEN** user finishes onboarding with notifications enabled and selected time of 2:30 PM
- **THEN** daily recurring notification is scheduled for 2:30 PM every day

#### Scenario: Notification scheduling failure does not block onboarding
- **WHEN** notification scheduling fails due to permission changes or system error
- **THEN** onboarding completes successfully and error is logged

### Requirement: Time picker UI integration
The system SHALL integrate the time picker with existing onboarding entrance animations and visual styling.

#### Scenario: Time picker entrance animation
- **WHEN** completion screen appears with time picker visible
- **THEN** time picker animates into view after statistics section and before finish button

#### Scenario: Time picker uses consistent styling
- **WHEN** time picker is displayed
- **THEN** time picker follows FulhamKit design system styling and spacing

### Requirement: Notification permission state tracking
The system SHALL track whether the user granted notification permissions in the onboarding flow state.

#### Scenario: User allows notifications
- **WHEN** user taps "Allow" and grants permission in the system dialog
- **THEN** onboarding flow state sets notificationsAllowed to true

#### Scenario: User skips notification permission
- **WHEN** user taps "Skip" on the notification permission screen
- **THEN** onboarding flow state sets notificationsAllowed to false

#### Scenario: User denies notifications in system dialog
- **WHEN** user taps "Allow" but denies in the system dialog
- **THEN** onboarding flow state sets notificationsAllowed to false
