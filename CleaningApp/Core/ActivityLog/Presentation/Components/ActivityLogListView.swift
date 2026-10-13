import FulhamKit
import SwiftUI

struct ActivityLogListView: View {
	// MARK: - Properties
	
	let completions: [CompletedTask]
	let onDeleteAction: (CompletedTask) -> Void
	let onEditAction: (CompletedTask) -> Void
	
	// MARK: - Body
	
	var body: some View {
		List(completions) { completion in
			ActivityLogListRowView(completedTask: completion)
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
	}
}

// MARK: - Preview

#Preview {
	ActivityLogListView(
			completions: CompletedTask.mocks,
			onDeleteAction: { _ in },
			onEditAction: { _ in }
		)
}
