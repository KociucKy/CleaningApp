## 1. Data Layer - UserDefaults and State Management

- [x] 1.1 Add `notificationTime` UserDefaultsKey extension in `UserDefaultsKeys.swift` for storing Date
- [x] 1.2 Add `notificationsAllowed` property to `OnboardingFlowState` to track permission status
- [x] 1.3 Update `OnbNotificationPresenter.onAllowNotificationsPressed()` to set `notificationsAllowed = true` on flow state after permission grant
- [x] 1.4 Update `OnbNotificationPresenter.onSkipPressed()` to set `notificationsAllowed = false` on flow state

## 2. Notification Scheduling Service

- [x] 2.1 Create `NotificationScheduling` protocol in `Models/Services/Notification/NotificationScheduler.swift`
- [x] 2.2 Implement `NotificationScheduler` production class with `scheduleDailyReminder(at:)` using LocalNotificationKit
- [x] 2.3 Implement `MockNotificationScheduler` for testing and MOCK builds
- [x] 2.4 Add `NotificationScheduler` to `DependencyContainer` with conditional registration (Mock vs Production)

## 3. Interactor Extension for Notification Scheduling

- [x] 3.1 Add `scheduleInitialNotification(at: Date)` method to `OnboardingInteractor` protocol in `Onboarding/RIB/OnboardingInteractor.swift`
- [x] 3.2 Implement `scheduleInitialNotification(at:)` in `CoreInteractor` extension with try-catch error handling
- [x] 3.3 Update `CoreInteractor.saveAndCompleteOnboarding()` to call notification scheduling if notifications allowed

## 4. Presenter Logic for Time Selection

- [x] 4.1 Add `selectedNotificationTime` property to `OnboardingCompletedPresenter` with default 9:00 AM
- [x] 4.2 Add `shouldShowTimePicker` computed property based on `OnboardingFlowState.notificationsAllowed`
- [x] 4.3 Add `timePickerVisible` animation state property to `OnboardingCompletedPresenter`
- [x] 4.4 Update `animateEntrance()` to animate time picker between stats and button (if visible)
- [x] 4.5 Update `onFinishButtonPressed()` to pass selected time to interactor's scheduling method

## 5. UI - Time Picker Component

- [x] 5.1 Add `timePickerSection` computed property to `OnboardingCompletedView` with DatePicker using `.hourAndMinute` style
- [x] 5.2 Apply FulhamKit spacing and styling to time picker section
- [x] 5.3 Add descriptive label/header above time picker (e.g., "Daily Reminder Time")
- [x] 5.4 Conditionally render time picker in body based on `presenter.shouldShowTimePicker`
- [x] 5.5 Position time picker between `statsSection` and `Spacer()` in VStack
- [x] 5.6 Add entrance animation with opacity and offset tied to `presenter.timePickerVisible`

## 6. Localization

- [x] 6.1 Add localized string key for time picker header (e.g., `"onb_completed.time_picker.title"`)
- [x] 6.2 Add localized string key for time picker description (e.g., `"onb_completed.time_picker.description"`)

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
- [x] 8.6 Run SwiftLint and SwiftFormat
