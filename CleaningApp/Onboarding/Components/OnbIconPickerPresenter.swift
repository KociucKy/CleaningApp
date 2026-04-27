import SwiftUI

// MARK: - OnbIconPickerPresenter

@Observable
@MainActor
final class OnbIconPickerPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter
	private let roomName: String

	let icons: [String] = [
		"house.fill",
		"bed.double.fill",
		"dumbbell",
		"book.fill",
		"paintpalette.fill",
		"leaf.fill",
		"wrench.and.screwdriver.fill",
		"music.note",
		"gamecontroller.fill",
		"laptopcomputer",
		"tv.fill",
		"car.fill",
		"cart.fill",
		"tent.fill",
		"pawprint.fill",
		"figure.walk",
		"tshirt.fill",
		"cup.and.saucer.fill",
		"square.grid.2x2",
	]

	// MARK: - Init

	init(
		interactor: OnboardingInteractor,
		router: OnboardingRouter,
		roomName: String
	) {
		self.interactor = interactor
		self.router = router
		self.roomName = roomName
	}

	// MARK: - Actions

	func onIconSelected(_ icon: String) {
		interactor.addCustomRoom(name: roomName, icon: icon)
		router.dismissScreen()
	}
}
