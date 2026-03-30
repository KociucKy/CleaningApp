import Foundation
import SwiftData

@MainActor
protocol CompletedTaskRepository {
	func fetchAll() throws -> [CompletedTaskEntity]
	func fetchAllForTaskId(_ id: UUID) throws -> [CompletedTaskEntity]
	func fetchSingle(for id: UUID) throws -> CompletedTaskEntity?
	func save(_ item: CompletedTaskEntity) throws
	func delete(_ item: CompletedTaskEntity) throws
}

@MainActor
final class SwiftDataCompletedTaskRepository: CompletedTaskRepository {
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

	func fetchAll() throws -> [CompletedTaskEntity] {
		let descriptor = FetchDescriptor<CompletedTaskEntity>(sortBy: [SortDescriptor(\.completedAt)])
		return try mainContext.fetch(descriptor)
	}

	func fetchAllForTaskId(_ id: UUID) throws -> [CompletedTaskEntity] {
		let descriptor = FetchDescriptor<CompletedTaskEntity>(
			predicate: #Predicate { $0.taskId == id },
			sortBy: [SortDescriptor(
				\.completedAt
			)]
		)
		return try mainContext.fetch(descriptor)
	}

	func fetchSingle(for id: UUID) throws -> CompletedTaskEntity? {
		let descriptor = FetchDescriptor<CompletedTaskEntity>(
			predicate: #Predicate { $0.id == id },
			sortBy: [SortDescriptor(\.completedAt)]
		)
		return try mainContext.fetch(descriptor).first
	}

	func save(_ entity: CompletedTaskEntity) throws {
		mainContext.insert(entity)
		try mainContext.save()
	}

	func delete(_ entity: CompletedTaskEntity) throws {
		guard let existingEntity = try fetchSingle(for: entity.id) else {
			return
		}
		mainContext.delete(existingEntity)
		try mainContext.save()
	}
}
