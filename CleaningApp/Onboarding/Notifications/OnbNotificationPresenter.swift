import LocalNotificationKit
import SwiftUI

// MARK: - OnbNotificationPresenter

@Observable
@MainActor
final class OnbNotificationPresenter {
	// MARK: - Properties

	var iconVisible = false
	var titleVisible = false
	var benefitsVisible = false
	var buttonVisible = false
	var isRequestingPermission = false

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter
	private let notificationManager: any LocalNotificationManaging

	// MARK: - Init

	init(
		interactor: OnboardingInteractor,
		router: OnboardingRouter,
		notificationManager: any LocalNotificationManaging = LocalNotificationManager.shared
	) {
		self.interactor = interactor
		self.router = router
		self.notificationManager = notificationManager
	}

	// MARK: - Actions

	func animateEntrance() {
		withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
			iconVisible = true
		}
		withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
			titleVisible = true
		}
		withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
			benefitsVisible = true
		}
		withAnimation(.easeOut(duration: 0.35).delay(0.75)) {
			buttonVisible = true
		}
	}

	func onAllowNotificationsPressed() {
		isRequestingPermission = true
		Task { @MainActor in
			let granted = await (try? notificationManager.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
			interactor.setNotificationsAllowed(granted)
			isRequestingPermission = false
			router.showOnboardingPaywallView()
		}
	}

	func onSkipPressed() {
		interactor.setNotificationsAllowed(false)
		router.showOnboardingPaywallView()
	}
}
