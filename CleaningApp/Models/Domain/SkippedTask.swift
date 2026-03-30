import Foundation

struct SkippedTask: Identifiable {
	// MARK: - Properties

	let id: UUID
	let taskId: UUID
	let originalDate: Date
	let skippedAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		taskId: UUID,
		originalDate: Date,
		skippedAt: Date = Date()
	) {
		self.id = id
		self.taskId = taskId
		self.originalDate = originalDate
		self.skippedAt = skippedAt
	}
}
