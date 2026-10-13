import FulhamKit
import SwiftUI

struct ActivityLogListRowView: View {
	let completedTask: CompletedTask

	var body: some View {
		VStack(alignment: .leading) {
			Text(completedTask.taskName ?? "No task name")
				.font(FKTypography.bodyBold)
			Text(completedTask.completedAt.formatted())
				.font(FKTypography.footnoteEmphasis)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	ActivityLogListRowView(
		completedTask: CompletedTask(
			taskId: UUID(),
			taskName: "Sweep the floor",
			completedAt: Date()
		)
	)
}
