import FulhamKit
import SwiftUI

struct RoomsDetailsTaskListView: View {
	let frequencyTitle: String
	let tasks: [RoomTask]
	let completedTaskIDs: Set<UUID>
	let onCompleteTaskButtonTapped: (RoomTask) -> Void
	let onDeleteTaskButtonTapped: (RoomTask) -> Void
	let onEditTaskButtonTapped: (RoomTask) -> Void

	var body: some View {
		Section(frequencyTitle) {
			ForEach(tasks) { task in
				RoomsDetailsTaskListRowView(
					taskName: task.name,
					taskEstimatedDuration: task.estimatedDuration.rawValue,
					isCompleted: completedTaskIDs.contains(task.id),
					onCompleteButtonTapped: {
						onCompleteTaskButtonTapped(task)
					}
				)
				.swipeActions(allowsFullSwipe: false) {
					Button("Delete", systemImage: "trash") {
						onDeleteTaskButtonTapped(task)
					}
					.tint(.red)
					Button("Edit", systemImage: "pencil") {
						onEditTaskButtonTapped(task)
					}
					.tint(.orange)
					Button("Completed now", systemImage: "checkmark") {}
						.tint(.green)
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
			completedTaskIDs: [],
			onCompleteTaskButtonTapped: { _ in },
			onDeleteTaskButtonTapped: { _ in },
			onEditTaskButtonTapped: { _ in }
		)
	}
}
