import SwiftUI

// MARK: - ActivityLogPresenter

@Observable
@MainActor
final class ActivityLogPresenter {
	// MARK: - Properties
	
	enum State {
		case isLoading
		case loaded
		case empty
		case error(String)
	}
	
	private let interactor: any ActivityLogInteractor
	private let router: any ActivityLogRouter
	let room: Room
	
	private(set) var tasks: [RoomTask] = []
	private(set) var completions: [CompletedTask] = []
	private(set) var state: State = .isLoading
	
	// MARK: - Init
	
	init(
		interactor: any ActivityLogInteractor,
		router: any ActivityLogRouter,
		room: Room
	) {
		self.interactor = interactor
		self.router = router
		self.room = room
	}
	
	// MARK: - Actions
	
	func onAppear() {
		guard case .isLoading = state else {
			return
		}
		
		do {
			tasks = try interactor.fetchAllRoomTasks(for: room.id)
			completions = try interactor.fetchAllCompletedTasks(forRoomId: room.id)
				.sorted { $0.completedAt > $1.completedAt }
			state = completions.isEmpty ? .empty : .loaded
		} catch {
			state = .error("Unable to load this room’s activity.")
		}
	}

	func onDeleteButtonTapped() {
		router.showAlert(
			.alert,
			title: "Are you sure you want to delete this record?",
			subtitle: nil,
			buttons: { @MainActor [weak self] in
				Group {
					Button("Delete", role: .destructive) {
						
					}
					Button("Cancel", role: .cancel) {
						self?.router.dismissAlert()
					}
				}.any()
			}
		)
	}
	
	func onCloseButtonTapped() {
		router.dismissScreen()
	}
}
