import SwiftUI
import FulhamKit

// MARK: - ScheduleDaySummaryView

@MainActor
struct ScheduleDaySummaryView: View {
    // MARK: - Properties

    let summary: ScheduleDaySummary

    // MARK: - Body

    var body: some View {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FKSpacing.large)
        .background(FKColor.Background.canvas)
        .accessibilityElement(children: .combine)
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
            progressTotal: 4
        )
    )
}
