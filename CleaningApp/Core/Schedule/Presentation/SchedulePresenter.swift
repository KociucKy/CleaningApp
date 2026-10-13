import Foundation

@Observable
@MainActor
final class SchedulePresenter {
	// MARK: - Properties

	private let interactor: any ScheduleInteractor
	private let router: any ScheduleRouter

	// MARK: - Init

	init(
		interactor: any ScheduleInteractor,
		router: any ScheduleRouter
	) {
		self.interactor = interactor
		self.router = router
	}
}
