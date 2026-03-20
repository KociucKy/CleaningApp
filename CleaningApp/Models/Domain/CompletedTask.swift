import Foundation

struct CompletedTask: Identifiable {
	// MARK: - Properties

	let id: UUID
	let taskId: UUID
	let completedAt: Date
	var measuredDuration: Int?

	// MARK: - Init

	init(
		id: UUID = UUID(),
		taskId: UUID,
		completedAt: Date = Date(),
		measuredDuration: Int? = nil
	) {
		self.id = id
		self.taskId = taskId
		self.completedAt = completedAt
		self.measuredDuration = measuredDuration
	}
}
