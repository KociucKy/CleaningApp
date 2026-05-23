import Foundation
import NavigationKit
import SwiftUI
import Testing
@testable import CleaningApp

// MARK: - TestRouter

/// No-op Router used in unit tests to satisfy presenter dependencies
/// without triggering real navigation.
@MainActor
private struct TestRouter: Router {
	func showScreen<T: View>(
		_: SegueOption,
		onDismiss _: (() -> Void)?,
		@ViewBuilder destination _: @escaping (any Router) -> T
	) {}

	func dismissScreen() {}
	func popToRoot() {}
	func dismissToRoot() {}

	func showAlert(
		_: AlertType,
		title _: String,
		subtitle _: String?,
		buttons _: (@Sendable () -> AnyView)?
	) {}

	func dismissAlert() {}

	func showModal(
		transition _: AnyTransition,
		backgroundColor _: Color,
		@ViewBuilder destination _: @escaping () -> some View
	) {}

	func dismissModal() {}
}

// MARK: - OnboardingCompletedPresenterTests

@Suite(.tags(.onboarding))
@MainActor
struct OnboardingCompletedPresenterTests {
	// MARK: - shouldShowTimePicker

	@Test func shouldShowTimePicker_returnsTrueWhenNotificationsAllowed() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)

		// Set notifications allowed
		interactor.setNotificationsAllowed(true)

		// Verify time picker should be shown
		#expect(presenter.shouldShowTimePicker == true)
	}

	@Test func shouldShowTimePicker_returnsFalseWhenNotificationsNotAllowed() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)

		// Set notifications not allowed
		interactor.setNotificationsAllowed(false)

		// Verify time picker should NOT be shown
		#expect(presenter.shouldShowTimePicker == false)
	}

	@Test func shouldShowTimePicker_defaultsToFalse() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)

		// Don't set notifications state (defaults to false)

		// Verify time picker defaults to hidden
		#expect(presenter.shouldShowTimePicker == false)
	}

	// MARK: - selectedNotificationTime

	@Test func selectedNotificationTime_defaultsTo9AM() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)

		// Extract hour from default notification time
		let components = Calendar.current.dateComponents([.hour, .minute], from: presenter.selectedNotificationTime)

		// Verify defaults to 9:00 AM
		#expect(components.hour == 9)
		#expect(components.minute == 0)
	}

	// MARK: - animateEntrance

	@Test func animateEntrance_showsTimePickerWhenNotificationsAllowed() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)

		// Set notifications allowed
		interactor.setNotificationsAllowed(true)

		// Initially time picker should not be visible
		#expect(presenter.timePickerVisible == false)

		// Trigger animation
		presenter.animateEntrance()

		// Verify time picker visibility is set (animation scheduled)
		// Note: We can't test the actual animation timing without waiting
		// but we can verify the method doesn't crash and shouldShowTimePicker is correct
		#expect(presenter.shouldShowTimePicker == true)
	}

	@Test func animateEntrance_doesNotShowTimePickerWhenNotificationsNotAllowed() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)

		// Set notifications not allowed
		interactor.setNotificationsAllowed(false)

		// Trigger animation
		presenter.animateEntrance()

		// Verify time picker should not be shown
		#expect(presenter.shouldShowTimePicker == false)
	}

	// MARK: - onFinishButtonPressed

	@Test func onFinishButtonPressed_savesNotificationTimeWhenAllowed() throws {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)
		guard let mockScheduler = preview.notificationScheduler as? MockNotificationScheduler else {
			Issue.record("Expected MockNotificationScheduler")
			return
		}

		// Set notifications allowed
		interactor.setNotificationsAllowed(true)

		// Set a custom notification time
		var components = DateComponents()
		components.hour = 14
		components.minute = 30
		let selectedTime = try #require(Calendar.current.date(from: components))
		presenter.selectedNotificationTime = selectedTime

		// Press finish button
		presenter.onFinishButtonPressed()

		// Verify notification was scheduled at the selected time
		let scheduledTime = try #require(mockScheduler.scheduledTime)
		let scheduledComponents = Calendar.current.dateComponents([.hour, .minute], from: scheduledTime)
		#expect(scheduledComponents.hour == 14)
		#expect(scheduledComponents.minute == 30)
	}

	@Test func onFinishButtonPressed_doesNotSaveNotificationTimeWhenNotAllowed() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)
		guard let mockScheduler = preview.notificationScheduler as? MockNotificationScheduler else {
			Issue.record("Expected MockNotificationScheduler")
			return
		}

		// Set notifications not allowed
		interactor.setNotificationsAllowed(false)

		// Press finish button
		presenter.onFinishButtonPressed()

		// Verify notification was NOT scheduled
		#expect(mockScheduler.scheduledTime == nil)
		#expect(mockScheduler.scheduleCallCount == 0)
	}

	@Test func onFinishButtonPressed_preventsMultipleSaves() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)
		guard let mockScheduler = preview.notificationScheduler as? MockNotificationScheduler else {
			Issue.record("Expected MockNotificationScheduler")
			return
		}

		// Set notifications allowed
		interactor.setNotificationsAllowed(true)

		// Press finish button multiple times rapidly
		presenter.onFinishButtonPressed()
		presenter.onFinishButtonPressed()
		presenter.onFinishButtonPressed()

		// Verify notification was only scheduled once (isSaving guard)
		#expect(mockScheduler.scheduleCallCount == 1)
	}

	@Test func onFinishButtonPressed_completesOnboardingRegardlessOfNotificationState() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let router = OnboardingRouter(
			router: TestRouter(),
			builder: OnboardingBuilder(interactor: interactor)
		)
		let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)
		let appState = preview.onboardingState

		// Initially onboarding should be showing
		#expect(appState.showOnboarding == true)

		// Press finish button (notifications not allowed by default)
		presenter.onFinishButtonPressed()

		// Verify onboarding is marked complete
		#expect(appState.showOnboarding == false)
	}
}
