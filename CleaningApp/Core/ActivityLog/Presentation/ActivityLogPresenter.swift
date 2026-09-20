import Foundation

@Observable
@MainActor
final class ActivityLogPresenter {
	// MARK: - Properties

	private let interactor: any ActivityLogInteractor
	private let router: any ActivityLogRouter

	// MARK: - Init

	init(
		interactor: any ActivityLogInteractor,
		router: any ActivityLogRouter
	) {
		self.interactor = interactor
		self.router = router
	}
}
