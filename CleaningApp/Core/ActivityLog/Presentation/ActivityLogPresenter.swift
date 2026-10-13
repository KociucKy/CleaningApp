import SwiftUI

// MARK: - ActivityLogPresenter

@Observable
@MainActor
final class ActivityLogPresenter {
	// MARK: - Properties

	private static let pageSize = 50

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
	private var hasMoreCompletions = false
	private var isLoadingMore = false
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
			let page = try fetchCompletionsPage(offset: 0)
			completions = page.completions
			hasMoreCompletions = page.hasMore
			state = completions.isEmpty ? .empty : .loaded
		} catch {
			state = .error(String(localized: "activity_log.error.load"))
		}
	}

	func onCompletionAppeared(_ completion: CompletedTask) {
		guard completion.id == completions.last?.id,
			  hasMoreCompletions,
			  !isLoadingMore else {
			return
		}

		isLoadingMore = true
		defer {
			isLoadingMore = false
		}

		do {
			let page = try fetchCompletionsPage(offset: completions.count)
			completions.append(contentsOf: page.completions)
			hasMoreCompletions = page.hasMore
		} catch {
			router.showAlert(
				.alert,
				title: String(localized: "activity_log.error.load"),
				subtitle: nil,
				buttons: nil
			)
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

	private func fetchCompletionsPage(offset: Int) throws -> (completions: [CompletedTask], hasMore: Bool) {
		let fetchedCompletions = try interactor.fetchCompletedTasks(
			forRoomId: room.id,
			limit: Self.pageSize + 1,
			offset: offset
		)

		return (
			Array(fetchedCompletions.prefix(Self.pageSize)),
			fetchedCompletions.count > Self.pageSize
		)
	}
}
