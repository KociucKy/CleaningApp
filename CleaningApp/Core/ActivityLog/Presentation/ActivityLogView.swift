import SwiftUI

// MARK: - ActivityLogView

struct ActivityLogView: View {
	// MARK: - Properties
	
	@State private var presenter: ActivityLogPresenter
	
	// MARK: - Init
	
	init(presenter: ActivityLogPresenter) {
		_presenter = State(initialValue: presenter)
	}
	
	// MARK: - Body
	
	var body: some View {
		Group {
			switch presenter.state {
			case .isLoading:
				ProgressView()
			case .loaded:
				ActivityLogListView(
					completions: presenter.completions,
					onDeleteAction: { completion in
						presenter.onDeleteButtonTapped(item: completion)
					},
					onEditAction: { completion in
						presenter.onEditButtonTapped(item: completion)
					},
					onCompletionAppearAction: { completion in
						presenter.onCompletionAppeared(completion)
					},
					onRefreshAction: presenter.reloadActivity
				)
			case .empty:
				ContentUnavailableView(
					"activity_log.empty.title",
					systemImage: "checkmark.circle",
					description: Text("activity_log.empty.description")
				)
			case .error(let errorMessage):
					ContentUnavailableView {
						Label("activity_log.unavailable.title", systemImage: "exclamationmark.triangle")
					} description: {
						Text(errorMessage)
					} actions: {
						Button("Retry", systemImage: "arrow.clockwise", action: presenter.onRetryButtonTapped)
							.buttonStyle(.borderedProminent)
					}
			}
		}
		.navigationTitle("activity_log.title")
		.toolbarTitleDisplayMode(.inline)
		.scrollEdgeEffectStyle(.soft, for: .top)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("common.action.close", action: presenter.onCloseButtonTapped)
			}
		}
		.onAppear {
			presenter.onAppear()
		}
	}
}

// MARK: - Preview

#Preview("Loaded") {
	let container = DevPreview.shared.container
	container.register(
		CompletedTaskManager.self,
		service: CompletedTaskManager(repository: MockCompletedTaskRepository())
	)
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)
	let room = Room.mock
	
	return RouterView { router in
		builder.activityLogView(
			router: router,
			room: room
		)
	}
}

#Preview("Paginated history") {
	let container = DevPreview.shared.container
	let room = Room.mock
	let completions = (0 ..< 75).map { index in
		CompletedTaskEntity(
			taskId: UUID(),
			roomId: room.id,
			roomName: room.name,
			taskName: "Task \(index + 1)",
			completedAt: .now.addingTimeInterval(-Double(index * 60))
		)
	}
	container.register(
		CompletedTaskManager.self,
		service: CompletedTaskManager(repository: MockCompletedTaskRepository(items: completions))
	)
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)

	return RouterView { router in
		builder.activityLogView(
			router: router,
			room: room
		)
	}
}

#Preview("Empty state") {
	let container = DevPreview.shared.container
	container.register(
		CompletedTaskManager.self,
		service: CompletedTaskManager(repository: MockCompletedTaskRepository(items: []))
	)
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)
	let room = Room.mock
	
	return RouterView { router in
		builder.activityLogView(
			router: router,
			room: room
		)
	}
}

#Preview("Error state") {
	let container = DevPreview.shared.container
	container.register(
		CompletedTaskManager.self,
		service: CompletedTaskManager(repository: MockCompletedTaskRepository(error: NSError(domain: "Error", code: 404)))
	)
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)
	let room = Room.mock
	
	return RouterView { router in
		builder.activityLogView(
			router: router,
			room: room
		)
	}
}
