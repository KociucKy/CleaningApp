import FulhamKit
import SwiftUI

struct RoomsDetailsMetricsView: View {
	let taskCount: Int
	let totalDuration: Int

	var body: some View {
		HStack {
			metricView(systemImage: "checklist", value: "\(taskCount)", label: "tasks")
			Divider()
			metricView(systemImage: "clock", value: "\(totalDuration) min", label: "estimated")
		}
	}

	private func metricView(systemImage: String, value: String, label: String) -> some View {
		VStack(spacing: FKSpacing.small) {
			HStack {
				Image(systemName: systemImage)
					.foregroundStyle(.tint)
				Text(value)
					.font(FKTypography.ctaLabel)
			}
			Text(label)
				.font(FKTypography.caption)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	RoomsDetailsMetricsView(
		taskCount: 12,
		totalDuration: 120
	)
}
