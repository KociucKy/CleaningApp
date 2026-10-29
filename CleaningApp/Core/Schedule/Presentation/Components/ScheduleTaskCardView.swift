import SwiftUI
import FulhamKit

// MARK: - ScheduleTaskCardView

@MainActor
struct ScheduleTaskCardView: View {
    // MARK: - Properties

    let task: ScheduleTaskRow
    let onUndoSkipButtonTapped: (ScheduleTaskRow) -> Void

    // MARK: - Body

    var body: some View {
        let isCompleted = task.status == .completed
        let isSkipped = task.status == .skipped
        let isInactive = isCompleted || isSkipped
        let accessibilityLabel = String(localized: .init(
            "schedule.task.accessibility_label",
            defaultValue: "\(task.name), \(task.roomName), \(task.duration) minutes"
        ))

        HStack(spacing: FKSpacing.large) {
            Image(systemName: task.symbolName)
                .font(FKTypography.sectionHeader)
                .foregroundStyle(isSkipped ? AnyShapeStyle(.secondary) : AnyShapeStyle(.accent.gradient))
                .padding(FKSpacing.default)
                .background((isSkipped ? Color.secondary : Color.accentColor).opacity(0.2), in: .circle)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
                Text(task.name)
                    .font(FKTypography.ctaLabel)
                    .strikethrough(isInactive, color: .secondary)
                    .foregroundStyle(isInactive ? .secondary : .primary)

                Text(String(localized: .init(
                    "schedule.task.detail",
                    defaultValue: "\(task.roomName) • \(task.duration) min"
                )))
                    .font(FKTypography.secondaryLabel)
                    .foregroundStyle(.secondary)

                if task.status != .planned {
                    Text(task.statusDescription)
                        .font(FKTypography.secondaryLabel)
                        .foregroundStyle(task.status == .postponed ? .orange : .secondary)
                }
            }

            Spacer()

            trailingAction
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(task.statusDescription)
    }

    // MARK: - Views

    @ViewBuilder
    private var trailingAction: some View {
        switch task.status {
        case .completed:
            Image(systemName: "checkmark")
                .font(FKTypography.sectionHeader)
                .foregroundStyle(.accent.gradient)

        case .skipped:
            Button(String(localized: .init(
                "schedule.action.undo_skip",
                defaultValue: "Undo Skip"
            ))) {
                onUndoSkipButtonTapped(task)
            }
            .buttonStyle(.borderless)

        case .planned, .postponed, .cancelled:
            Image(systemName: "circle")
                .font(FKTypography.sectionHeader)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    ScheduleTaskCardView(
        task: ScheduleTaskRow(
            id: UUID(),
            name: "Vacuum the floor",
            roomName: "Living Room",
            duration: 15,
            symbolName: "sofa.fill",
            status: .planned
        ),
        onUndoSkipButtonTapped: { _ in }
    )
}
