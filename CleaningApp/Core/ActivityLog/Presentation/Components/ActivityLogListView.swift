import SwiftUI

struct ActivityLogListView: View {
	// MARK: - Properties
	
	let completions: [CompletedTask]
	let onDeleteAction: (CompletedTask) -> Void
	let onEditAction: (CompletedTask) -> Void
	let onCompletionAppearAction: (CompletedTask) -> Void
	let onRefreshAction: () -> Void
	
	// MARK: - Body
	
	var body: some View {
		List(completions) { completion in
			ActivityLogListRowView(completedTask: completion)
				.onAppear {
					onCompletionAppearAction(completion)
				}
				.swipeActions {
					Button(
						"common.action.delete",
						systemImage: "trash",
						action: {
							onDeleteAction(completion)
						}
					)
					.tint(.red)
					Button("common.action.edit", systemImage: "pencil") {
							onEditAction(completion)
						}
						.tint(.orange)
			}
		}
		.refreshable {
			onRefreshAction()
		}
	}
}

// MARK: - Preview

#Preview {
	ActivityLogListView(
			completions: CompletedTask.mocks,
			onDeleteAction: { _ in },
			onEditAction: { _ in },
			onCompletionAppearAction: { _ in },
			onRefreshAction: {}
		)
}
