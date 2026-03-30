import Foundation
import SwiftData

@Model
final class SkippedTaskEntity {
	// MARK: - Properties

	var id: UUID
	var taskId: UUID
	var originalDate: Date
	var skippedAt: Date

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
