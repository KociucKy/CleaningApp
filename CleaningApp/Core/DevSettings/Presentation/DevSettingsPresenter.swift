import Foundation

// MARK: - DevSettingsPresenter

@Observable
@MainActor
final class DevSettingsPresenter {
	// MARK: - Properties

	private let interactor: any DevSettingsInteractor
	private let router: any DevSettingsRouter

	// MARK: - Init

	init(interactor: any DevSettingsInteractor, router: any DevSettingsRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Actions

	func dismiss() {
		router.dismissScreen()
	}

	func pushReviewKitDebugView() {
		router.presentReviewKitDebugView()
	}

	func pushUserDefaultsDebugView() {
		router.presentUserDefaultsDebugView()
	}

	func pushLocalNotificationDebugView() {
		router.presentLocalNotificationDebugView()
	}

	func pushDeviceDebugView() {
		router.presentDeviceDebugView()
	}
}
