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
					}
				)
			case .empty:
				ContentUnavailableView(
					"activity_log.empty.title",
					systemImage: "checkmark.circle",
					description: Text("activity_log.empty.description")
				)
			case .error(let errorMessage):
				ContentUnavailableView(
					"activity_log.unavailable.title",
					systemImage: "exclamationmark.triangle",
					description: Text(errorMessage)
				)
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
