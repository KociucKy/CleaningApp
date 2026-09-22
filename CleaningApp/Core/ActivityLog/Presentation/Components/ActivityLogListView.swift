import SwiftUI
import FulhamKit

struct ActivityLogListView: View {
	// MARK: - Properties

	let completions: [CompletedTask]

	// MARK: - Body

	var body: some View {
		List(completions) { completion in
			ActivityLogListRowView(
				taskName: completion.taskName ?? "No task name",
				completedAt: completion.completedAt.formatted()
			)
			.swipeActions {
				Button("Delete", systemImage: "trash", action: {})
					.tint(.red)
				Button("Edit", systemImage: "pencil", action: {})
					.tint(.orange)
			}
		}
	}
}

// MARK: - Preview

#Preview {
	ActivityLogListView(completions: CompletedTask.mocks)
}
