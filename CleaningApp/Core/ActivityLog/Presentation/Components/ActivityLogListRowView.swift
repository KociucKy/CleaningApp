import SwiftUI
import FulhamKit

struct ActivityLogListRowView: View {
	let taskName: String
	let completedAt: String

	var body: some View {
		VStack(alignment: .leading) {
			Text(taskName)
				.font(FKTypography.bodyBold)
			Text(completedAt)
				.font(FKTypography.footnoteEmphasis)
				.foregroundStyle(.secondary)
		}

	}
}

#Preview {
	ActivityLogListRowView(
		taskName: "Sweep the floor",
		completedAt: "26/08/2026, 17:12"
	)
}
