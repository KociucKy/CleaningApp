import Foundation

// MARK: - SettingsPresenter

@Observable
@MainActor
final class SettingsPresenter {
	// MARK: - Properties

	private let interactor: any SettingsInteractor
	private let router: any SettingsRouter
	private(set) var dailyScheduleLimit = 30

	// MARK: - Init

	init(interactor: any SettingsInteractor, router: any SettingsRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Methods

	func fetchSettings() {
		dailyScheduleLimit = interactor.dailyScheduleLimit()
	}

	func updateDailyScheduleLimit(_ dailyLimit: Int) {
		do {
			try interactor.updateDailyScheduleLimit(dailyLimit)
			self.dailyScheduleLimit = interactor.dailyScheduleLimit()
		} catch {}
	}
}
