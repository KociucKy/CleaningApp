import FulhamKit
import SwiftUI

struct RoomsDetailsTaskListView: View {
	let frequencyTitle: String
	let tasks: [RoomTask]
	let onCompleteTaskButtonTapped: (RoomTask) -> Void
	let onDeleteTaskButtonTapped: (RoomTask) -> Void

	var body: some View {
		Section(frequencyTitle) {
			ForEach(tasks) { task in
				RoomsDetailsTaskListRowView(
					taskName: task.name,
					taskEstimatedDuration: task.estimatedDuration.rawValue,
					onCompleteButtonTapped: {
						onCompleteTaskButtonTapped(task)
					}
				)
				.swipeActions {
					Button(role: .destructive) {
						onDeleteTaskButtonTapped(task)
					}
				}
			}
		}
	}
}

#Preview {
	List {
		RoomsDetailsTaskListView(
			frequencyTitle: "Daily",
			tasks: RoomTask.mocks,
			onCompleteTaskButtonTapped: { _ in},
			onDeleteTaskButtonTapped: { _ in }
		)
	}
}
