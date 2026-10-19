import Foundation

struct SkippedTask: Identifiable {
	// MARK: - Properties

	let id: UUID
	let taskId: UUID
	let scheduledTaskId: UUID?
	let originalDate: Date
	let skippedAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		taskId: UUID,
		scheduledTaskId: UUID? = nil,
		originalDate: Date,
		skippedAt: Date = Date()
	) {
		self.id = id
		self.taskId = taskId
		self.scheduledTaskId = scheduledTaskId
		self.originalDate = originalDate
		self.skippedAt = skippedAt
	}
}
