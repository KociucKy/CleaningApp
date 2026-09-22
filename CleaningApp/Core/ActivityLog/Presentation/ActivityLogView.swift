import SwiftUI
import FulhamKit

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
				ActivityLogListView(completions: presenter.completions)
			case .empty:
				ContentUnavailableView(
					"No activity yet",
					systemImage: "checkmark.circle",
					description: Text("Complete a task in this room and it will appear here.")
				)
			case .error(let errorMessage):
				ContentUnavailableView(
					"Activity unavailable",
					systemImage: "exclamationmark.triangle",
					description: Text(errorMessage)
				)
				
			}
		}
		.navigationTitle("Activity")
		.toolbarTitleDisplayMode(.inline)
		.scrollEdgeEffectStyle(.soft, for: .top)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Close", action: presenter.onCloseButtonTapped)
			}
		}
		.onAppear {
			presenter.onAppear()
		}
	}
}

struct ActivityLogListView: View {
	let completions: [CompletedTask]

	var body: some View {
		List(completions) { completion in
			VStack(alignment: .leading) {
				Text(completion.taskName ?? "No task name")
					.font(FKTypography.bodyBold)
				Text(completion.completedAt.formatted())
					.font(FKTypography.footnoteEmphasis)
					.foregroundStyle(.secondary)
			}
		}
	}
}

// MARK: - Preview

#Preview("Loaded") {
	let container = DevPreview.shared.container
	container.register(CompletedTaskRepository.self, service: MockCompletedTaskRepository())
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
	container.register(CompletedTaskRepository.self, service: MockCompletedTaskRepository(items: []))
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
