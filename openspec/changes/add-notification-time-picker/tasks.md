## 1. Data Layer - UserDefaults and State Management

- [ ] 1.1 Add `notificationTime` UserDefaultsKey extension in `UserDefaultsKeys.swift` for storing Date
- [ ] 1.2 Add `notificationsAllowed` property to `OnboardingFlowState` to track permission status
- [ ] 1.3 Update `OnbNotificationPresenter.onAllowNotificationsPressed()` to set `notificationsAllowed = true` on flow state after permission grant
- [ ] 1.4 Update `OnbNotificationPresenter.onSkipPressed()` to set `notificationsAllowed = false` on flow state

## 2. Notification Scheduling Service

- [ ] 2.1 Create `NotificationScheduling` protocol in `Models/Services/Notification/NotificationScheduler.swift`
- [ ] 2.2 Implement `NotificationScheduler` production class with `scheduleDailyReminder(at:)` using LocalNotificationKit
- [ ] 2.3 Implement `MockNotificationScheduler` for testing and MOCK builds
- [ ] 2.4 Add `NotificationScheduler` to `DependencyContainer` with conditional registration (Mock vs Production)

## 3. Interactor Extension for Notification Scheduling

- [ ] 3.1 Add `scheduleInitialNotification(at: Date)` method to `OnboardingInteractor` protocol in `Onboarding/RIB/OnboardingInteractor.swift`
- [ ] 3.2 Implement `scheduleInitialNotification(at:)` in `CoreInteractor` extension with try-catch error handling
- [ ] 3.3 Update `CoreInteractor.saveAndCompleteOnboarding()` to call notification scheduling if notifications allowed

## 4. Presenter Logic for Time Selection

- [ ] 4.1 Add `selectedNotificationTime` property to `OnboardingCompletedPresenter` with default 9:00 AM
- [ ] 4.2 Add `shouldShowTimePicker` computed property based on `OnboardingFlowState.notificationsAllowed`
- [ ] 4.3 Add `timePickerVisible` animation state property to `OnboardingCompletedPresenter`
- [ ] 4.4 Update `animateEntrance()` to animate time picker between stats and button (if visible)
- [ ] 4.5 Update `onFinishButtonPressed()` to pass selected time to interactor's scheduling method

## 5. UI - Time Picker Component

- [ ] 5.1 Add `timePickerSection` computed property to `OnboardingCompletedView` with DatePicker using `.hourAndMinute` style
- [ ] 5.2 Apply FulhamKit spacing and styling to time picker section
- [ ] 5.3 Add descriptive label/header above time picker (e.g., "Daily Reminder Time")
- [ ] 5.4 Conditionally render time picker in body based on `presenter.shouldShowTimePicker`
- [ ] 5.5 Position time picker between `statsSection` and `Spacer()` in VStack
- [ ] 5.6 Add entrance animation with opacity and offset tied to `presenter.timePickerVisible`

## 6. Localization

- [ ] 6.1 Add localized string key for time picker header (e.g., `"onb_completed.time_picker.title"`)
- [ ] 6.2 Add localized string key for time picker description (e.g., `"onb_completed.time_picker.description"`)

## 7. Testing

- [ ] 7.1 Add unit tests for `NotificationScheduler` scheduling logic
- [ ] 7.2 Add unit tests for `OnboardingCompletedPresenter` conditional time picker visibility
- [ ] 7.3 Add unit tests for `CoreInteractor.scheduleInitialNotification` error handling
- [ ] 7.4 Add snapshot tests for `OnboardingCompletedView` with time picker visible
- [ ] 7.5 Add snapshot tests for `OnboardingCompletedView` with time picker hidden
- [ ] 7.6 Test `OnboardingFlowState.notificationsAllowed` tracking through notification screen flows

## 8. Integration and Verification

- [ ] 8.1 Test full onboarding flow with notifications allowed - verify time picker appears
- [ ] 8.2 Test full onboarding flow with notifications skipped - verify time picker hidden
- [ ] 8.3 Verify selected time persists to UserDefaults correctly
- [ ] 8.4 Verify notification is scheduled at selected time using LocalNotificationKit debugging
- [ ] 8.5 Verify error handling when notification scheduling fails (doesn't block onboarding)
- [ ] 8.6 Run SwiftLint and SwiftFormat
