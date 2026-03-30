import Foundation
import SwiftData

@MainActor
protocol SkippedTaskRepository {
	func fetchAll() throws -> [SkippedTaskEntity]
	func fetchAllForTaskId(_ id: UUID) throws -> [SkippedTaskEntity]
	func fetchSingle(for id: UUID) throws -> SkippedTaskEntity?
	func save(_ item: SkippedTaskEntity) throws
	func delete(_ item: SkippedTaskEntity) throws
}

@MainActor
final class SwiftDataSkippedTaskRepository: SkippedTaskRepository {
	// MARK: - Properties

	private let container: ModelContainer
	private var mainContext: ModelContext {
		container.mainContext
	}

	// MARK: - Init

	init(container: ModelContainer) {
		self.container = container
	}

	// MARK: - Methods

	func fetchAll() throws -> [SkippedTaskEntity] {
		let descriptor = FetchDescriptor<SkippedTaskEntity>(sortBy: [SortDescriptor(\.skippedAt)])
		return try mainContext.fetch(descriptor)
	}

	func fetchAllForTaskId(_ id: UUID) throws -> [SkippedTaskEntity] {
		let descriptor = FetchDescriptor<SkippedTaskEntity>(
			predicate: #Predicate { $0.taskId == id },
			sortBy: [SortDescriptor(\.skippedAt)]
		)
		return try mainContext.fetch(descriptor)
	}

	func fetchSingle(for id: UUID) throws -> SkippedTaskEntity? {
		let descriptor = FetchDescriptor<SkippedTaskEntity>(
			predicate: #Predicate { $0.id == id },
			sortBy: [SortDescriptor(\.skippedAt)]
		)
		return try mainContext.fetch(descriptor).first
	}

	func save(_ entity: SkippedTaskEntity) throws {
		mainContext.insert(entity)
		try mainContext.save()
	}

	func delete(_ entity: SkippedTaskEntity) throws {
		guard let existingEntity = try fetchSingle(for: entity.id) else {
			return
		}
		mainContext.delete(existingEntity)
		try mainContext.save()
	}
}
