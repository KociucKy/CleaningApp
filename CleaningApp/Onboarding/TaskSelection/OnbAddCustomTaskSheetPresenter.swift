import Foundation
import SwiftUI

// MARK: - OnbAddCustomTaskSheetPresenter

@Observable
@MainActor
final class OnbAddCustomTaskSheetPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter
	private let roomType: RoomType

	var taskName: String = ""
	var selectedFrequency: Frequency = .timesPerWeek(1)

	var isTaskNameValid: Bool {
		!taskName.trimmingCharacters(in: .whitespaces).isEmpty
	}

	// MARK: - Init

	init(
		interactor: OnboardingInteractor,
		router: OnboardingRouter,
		roomType: RoomType
	) {
		self.interactor = interactor
		self.router = router
		self.roomType = roomType
	}

	// MARK: - Actions

	func onCancelButtonPressed() {
		router.dismissScreen()
	}

	func onAddButtonPressed() {
		guard isTaskNameValid else { return }
		let task = RoomTask(
			name: taskName.trimmingCharacters(in: .whitespaces),
			roomId: UUID(), // Placeholder - will be set during save
			frequency: selectedFrequency,
			estimatedDuration: .fifteenMinutes
		)
		interactor.addCustomTask(task, for: roomType)
		router.dismissScreen()
	}
}
