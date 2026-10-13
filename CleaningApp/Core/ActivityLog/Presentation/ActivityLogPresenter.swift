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
        reloadActivity()
    }

    func reloadActivity() {
        do {
            completions = try interactor.fetchAllCompletedTasks(forRoomId: room.id)
                .sorted { $0.completedAt > $1.completedAt }
            state = completions.isEmpty ? .empty : .loaded
        } catch {
            state = .error(String(localized: "activity_log.error.load"))
        }
    }

    func onDeleteButtonTapped(item: CompletedTask) {
        router.showAlert(
            .alert,
            title: String(localized: "activity_log.delete.confirmation"),
            subtitle: nil,
            buttons: { @MainActor [weak self] in
                Group {
                    Button("common.action.delete", role: .destructive) {
                        self?.deleteCompletedTask(item)
                    }
                    Button("common.action.cancel", role: .cancel) {
                        self?.router.dismissAlert()
                    }
                }.any()
            }
        )
    }

    func onEditButtonTapped(item: CompletedTask) {
        router.presentActivityLogEditView(
            completedTask: item,
            onDismiss: { [weak self] in
                self?.reloadActivity()
            }
        )
    }

    func onCloseButtonTapped() {
        router.dismissScreen()
    }

    // MARK: - Private

    private func deleteCompletedTask(_ item: CompletedTask) {
        router.dismissAlert()

        do {
            try interactor.deleteCompletedTask(item)
            reloadActivity()
        } catch {
            router.showAlert(
                .alert,
                title: String(localized: "activity_log.error.delete"),
                subtitle: nil,
                buttons: nil
            )
        }
    }
}
