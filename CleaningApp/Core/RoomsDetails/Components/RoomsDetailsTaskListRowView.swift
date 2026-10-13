import FulhamKit
import SwiftUI

struct RoomsDetailsTaskListRowView: View {
	let taskName: String
	let taskEstimatedDuration: Int
	let isCompleted: Bool
	let onCompleteButtonTapped: () -> Void

	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
				Text(taskName)
					.font(FKTypography.bodyBold)
				Text("\(taskEstimatedDuration) min")
					.font(FKTypography.caption)
					.foregroundStyle(.secondary)
			}
			Spacer()
			Button {
				onCompleteButtonTapped()
			} label: {
				Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
					.font(.title2)
					.foregroundStyle(isCompleted ? .green : .secondary)
					.accessibilityLabel(isCompleted ? "Completed" : "Mark as completed")
			}
		}
	}
}

#Preview {
	List {
		RoomsDetailsTaskListRowView(
			taskName: "Wipe the floor",
			taskEstimatedDuration: 12,
			isCompleted: true
		) {
			print("Completed")
		}
	}
}
