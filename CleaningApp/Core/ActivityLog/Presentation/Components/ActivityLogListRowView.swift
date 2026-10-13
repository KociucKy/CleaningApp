import FulhamKit
import SwiftUI

struct ActivityLogListRowView: View {
	let completedTask: CompletedTask

	var body: some View {
		VStack(alignment: .leading) {
			Text(completedTask.taskName ?? String(localized: "activity_log.no_task_name"))
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
