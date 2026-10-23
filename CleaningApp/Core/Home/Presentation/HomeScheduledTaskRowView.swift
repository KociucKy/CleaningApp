import SwiftUI

// MARK: - HomeScheduledTaskRowView

@MainActor
struct HomeScheduledTaskRowView: View {
    // MARK: - Properties

    let row: HomeScheduledTaskRow

    // MARK: - Body

    var body: some View {
        HStack {
            Text(row.name)
            Spacer()
            Text("\(row.duration) min")
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.name), \(row.duration) minutes")
    }
}
