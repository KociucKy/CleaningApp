import SwiftUI

// MARK: - ScheduleProgressView

@MainActor
struct ScheduleProgressView: View {
    // MARK: - Properties

    let completedTaskCount: Int
    let total: Int

    private var progress: CGFloat {
        guard total > 0 else {
            return 0
        }

        return CGFloat(completedTaskCount) / CGFloat(total)
    }

    // MARK: - Body

    var body: some View {
        Capsule()
            .fill(.secondary.opacity(0.2))
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(.accent)
                    .scaleEffect(x: progress, anchor: .leading)
                    .animation(.smooth(duration: 0.35), value: progress)
            }
            .frame(height: 6)
            .accessibilityRepresentation {
                ProgressView(value: Double(completedTaskCount), total: Double(total))
            }
    }
}
