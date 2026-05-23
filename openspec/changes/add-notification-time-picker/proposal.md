## Why

Users who enable notifications during onboarding need to specify when they want to receive daily cleaning reminders. Without a time preference, we cannot schedule meaningful notifications that fit their routines. This completes the notification setup flow before the feature is built.

## What Changes

- Add a time picker UI to the OnboardingCompletedView that appears only for users who allowed notifications
- Store the selected notification time in UserDefaults for later use in Settings
- Integrate LocalNotificationKit to schedule the initial daily notification at the selected time
- Conditionally show/hide the time selector based on notification permission status from the previous onboarding step

## Capabilities

### New Capabilities
- `notification-time-selection`: User can select their preferred notification time during onboarding, which is persisted and used to schedule daily reminders

### Modified Capabilities
<!-- No existing specs are being modified -->

## Impact

- **Files**: 
  - `CleaningApp/Onboarding/Completed/OnboardingCompletedView.swift` (add time picker UI)
  - `CleaningApp/Onboarding/Completed/OnboardingCompletedPresenter.swift` (handle time selection state)
  - `CleaningApp/Models/UserDefaults/` (new key for notification time)
- **Dependencies**: LocalNotificationKit (already in project)
- **User Experience**: Adds one optional step to onboarding flow (only for users who allowed notifications)
