import SwiftUI
import FulhamKit

struct ActivityLogListView: View {
	// MARK: - Properties

	let completions: [CompletedTask]

	// MARK: - Body

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

#Preview {
	ActivityLogListView(completions: CompletedTask.mocks)
}
