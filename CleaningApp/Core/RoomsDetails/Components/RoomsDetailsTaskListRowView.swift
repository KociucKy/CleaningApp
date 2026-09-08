import SwiftUI
import FulhamKit

struct RoomsDetailsTaskListRowView: View {
	let taskName: String
	let taskEstimatedDuration: Int
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
				Image(systemName: "checkmark.circle.fill")
					.font(.title2)
			}
		}
	}
}

#Preview {
	List {
		RoomsDetailsTaskListRowView(
			taskName: "Wipe the floor",
			taskEstimatedDuration: 12
		) {
			print("Completed")
		}
	}
}
