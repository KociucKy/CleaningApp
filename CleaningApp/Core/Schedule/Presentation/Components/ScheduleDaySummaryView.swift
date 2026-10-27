import SwiftUI
import FulhamKit

// MARK: - ScheduleDaySummaryView

@MainActor
struct ScheduleDaySummaryView: View {
	// MARK: - Properties
	
	let summary: ScheduleDaySummary
	
	// MARK: - Body
	
	var body: some View {
		if summary.showsEmptyState {
			ScheduleEmptyDayView(weekdayName: summary.weekdayName)
		} else {
			VStack(alignment: .leading, spacing: FKSpacing.default) {
				HStack(alignment: .firstTextBaseline) {
					Text(summary.weekdayName)
						.font(FKTypography.statValue)
					
					Spacer()
					
					Text(summary.completionText)
						.font(FKTypography.secondaryLabel)
						.fontWeight(.semibold)
						.foregroundStyle(.accent)
				}
				
				Text(summary.taskDescription)
					.font(FKTypography.secondaryLabel)
					.foregroundStyle(.secondary)
				
				ProgressView(
					value: Double(summary.completedTaskCount),
					total: Double(summary.progressTotal)
				)
				.tint(.accent)
				.animation(.bouncy, value: summary.completedTaskCount)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(FKSpacing.large)
			.background(FKColor.Background.canvas)
			.accessibilityElement(children: .combine)
		}
	}
}

// MARK: - Preview

#Preview {
	ScheduleDaySummaryView(
		summary: ScheduleDaySummary(
			weekdayName: "Monday",
			completionText: "2/4",
			taskDescription: "4 tasks • 35 min planned",
			completedTaskCount: 2,
			progressTotal: 4,
			showsEmptyState: false
		)
	)
}

#Preview("Empty") {
	ScheduleDaySummaryView(
		summary: ScheduleDaySummary(
			weekdayName: "Friday",
			completionText: "0/0",
			taskDescription: "A clear day — enjoy the space.",
			completedTaskCount: 0,
			progressTotal: 1,
			showsEmptyState: true
		)
	)
}
