## Context

The onboarding flow currently requests notification permissions but doesn't capture when users want to be notified. The completion screen (`OnboardingCompletedView`) shows summary statistics but needs to conditionally add a time selector for users who granted notification access.

**Current state:**
- `OnbNotificationPresenter` requests notification permission via `LocalNotificationKit`
- No state tracking whether permission was granted or denied
- `OnboardingCompletedPresenter` saves onboarding data but doesn't handle notification scheduling
- UserDefaults uses `UserDefaultsKit` wrapper with typed keys

**Constraints:**
- Must follow RIB architecture (no business logic in Presenter/View)
- Must use `@Observable` for state management (not `@Published`)
- Must use `UserDefaultsKit` pattern for persistence
- Must maintain onboarding flow animation patterns
- Editing time in Settings is out of scope

## Goals / Non-Goals

**Goals:**
- Conditionally show time picker in `OnboardingCompletedView` only if user allowed notifications
- Save selected time to UserDefaults using `UserDefaultsKit`
- Schedule initial daily notification via `LocalNotificationKit` at selected time
- Maintain existing entrance animations with new UI element
- Provide sensible default time (e.g., 9:00 AM)

**Non-Goals:**
- Editing notification time in Settings (future work)
- Multiple notification times
- Smart notification time suggestions
- Notification content/copy (placeholder is acceptable)
- Handling notification authorization status changes after onboarding

## Decisions

### 1. Track Notification Permission in OnboardingFlowState

**Decision:** Add `notificationsAllowed: Bool` property to `OnboardingFlowState` (the shared state object passed through onboarding steps).

**Rationale:**
- `OnboardingFlowState` already tracks room/task selections across steps
- Avoids re-checking system notification status (async operation)
- Simpler than querying `UNUserNotificationCenter` authorization status on completion screen
- Follows existing pattern of tracking user choices during flow

**Alternative considered:** Query `LocalNotificationManager` for authorization status in `OnboardingCompletedPresenter`. Rejected because it introduces async complexity and doesn't align with existing state management pattern.

### 2. Use Date for Time Storage, DateComponents for Scheduling

**Decision:** Store selected time as `Date` in UserDefaults, extract hour/minute as `DateComponents` when scheduling notifications.

**Rationale:**
- `Date` is `Codable` and works directly with `UserDefaultsKit`
- SwiftUI's `DatePicker` with `.hourAndMinute` style produces `Date`
- `LocalNotificationKit` uses `DateComponents` for recurring notifications
- Conversion is straightforward: `Calendar.current.dateComponents([.hour, .minute], from: date)`

**Alternative considered:** Store hour/minute as separate integers. Rejected because it requires custom encoding/decoding and doesn't leverage SwiftUI's built-in time picker.

### 3. Schedule Notification in Interactor, Not Presenter

**Decision:** Add `scheduleInitialNotification(at: Date)` method to `OnboardingInteractor` protocol and implement in `CoreInteractor`.

**Rationale:**
- Follows RIB architecture: business logic (scheduling) belongs in Interactor
- Interactor already handles `saveAndCompleteOnboarding()`
- Presenter remains a thin bridge between View and business logic
- Testable: can mock the interactor's notification scheduling

**Alternative considered:** Handle notification scheduling directly in presenter. Rejected because it violates architecture guidelines ("Business logic lives in Services/, not in Interactors or Presenters").

### 4. Create NotificationScheduler Service

**Decision:** Create `NotificationScheduler` service that wraps `LocalNotificationKit` for scheduling logic. Inject into `CoreInteractor`.

**Rationale:**
- Architecture doc states: "Business logic lives in Services/"
- Keeps notification scheduling logic reusable for future Settings editing
- Testable via mock implementation
- `CoreInteractor` delegates to the service, maintaining separation of concerns

**Interface:**
```swift
@MainActor
protocol NotificationScheduling {
    func scheduleDailyReminder(at time: Date) throws
    func cancelDailyReminder()
}
```

### 5. Conditionally Render Time Picker Between Stats and Button

**Decision:** Insert time picker section between `statsSection` and `finishButton` in `OnboardingCompletedView`, controlled by `presenter.shouldShowTimePicker`.

**Rationale:**
- Maintains visual hierarchy: stats → optional time picker → finish button
- `safeAreaInset` already positions button at bottom; time picker stays in main VStack
- Follows entrance animation pattern: time picker animates after stats, before button
- Presenter exposes boolean computed property based on `OnboardingFlowState.notificationsAllowed`

**Alternative considered:** Show time picker on a separate screen after completion. Rejected because user requested it on the completion screen, and adding another screen hurts flow.

## Risks / Trade-offs

**[Risk]** User changes system notification permissions after onboarding, but our flag remains stale.  
→ **Mitigation:** Out of scope for this change. Settings implementation will re-check status when user edits time.

**[Risk]** Notification scheduling fails silently (permissions revoked between steps).  
→ **Mitigation:** `scheduleInitialNotification` throws error; catch and log in interactor. Don't block onboarding completion. User can fix in Settings later.

**[Risk]** Time picker adds visual complexity to completion screen.  
→ **Mitigation:** Only shown when relevant (notifications allowed). Uses consistent FulhamKit styling. Tested via snapshot tests.

**[Trade-off]** Storing `Date` for time-only data is imprecise (includes full date components).  
→ **Accepted:** SwiftUI's time picker and `Codable` conformance make this trade-off worthwhile. Only hour/minute are extracted for scheduling.

**[Trade-off]** No validation that selected time is in the future (could be earlier today).  
→ **Accepted:** Daily recurring notification will trigger at next occurrence. Complex validation isn't needed for MVP.
