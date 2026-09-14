import FulhamKit
import SwiftUI

struct RoomsDetailsTaskListView: View {
	let frequencyTitle: String
	let tasks: [RoomTask]
	let onCompleteTaskButtonTapped: (RoomTask) -> Void
	let onDeleteTaskButtonTapped: (RoomTask) -> Void
	let onEditTaskButtonTapped: (RoomTask) -> Void

	private func taskPresentationID(for task: RoomTask) -> String {
		[
			task.id.uuidString,
			task.name,
			String(task.estimatedDuration.rawValue),
			task.frequency.displayName
		].joined(separator: "-")
	}

	private var taskListPresentationID: String {
		tasks
			.map(taskPresentationID(for:))
			.joined(separator: "|")
	}

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
				.id(taskPresentationID(for: task))
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
			.id(taskListPresentationID)
		}
	}

#Preview {
	List {
		RoomsDetailsTaskListView(
			frequencyTitle: "Daily",
			tasks: RoomTask.mocks,
			onCompleteTaskButtonTapped: { _ in },
			onDeleteTaskButtonTapped: { _ in },
			onEditTaskButtonTapped: { _ in }
		)
	}
}
