import Foundation

// MARK: - ActivityLogPresenter

@Observable
@MainActor
final class ActivityLogPresenter {
    // MARK: - Properties

    private let interactor: any ActivityLogInteractor
    private let router: any ActivityLogRouter
    let room: Room

    private(set) var tasks: [RoomTask] = []
    private(set) var completions: [CompletedTask] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

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
        guard isLoading else {
            return
        }

        do {
            tasks = try interactor.fetchAllRoomTasks(for: room.id)
            completions = try interactor.fetchAllCompletedTasks(forRoomId: room.id)
                .sorted { $0.completedAt > $1.completedAt }
        } catch {
            errorMessage = "Unable to load this room’s activity."
        }

        isLoading = false
    }

    func onCloseButtonTapped() {
        router.dismissScreen()
    }
}
