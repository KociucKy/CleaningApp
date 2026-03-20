import Foundation
import SwiftData

@MainActor
protocol CompletedTaskRepository {
	func fetchAll() throws -> [CompletedTaskEntity]
	func fetchAll(for taskId: UUID) throws -> [CompletedTaskEntity]
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
		let entities = try mainContext.fetch(descriptor)
		return entities
	}

	func fetchAll(for id: UUID) throws -> [CompletedTaskEntity] {
		let descriptor = FetchDescriptor<CompletedTaskEntity>(
			predicate: #Predicate { $0.id == id },
			sortBy: [SortDescriptor(
				\.completedAt
			)])
		let entities = try mainContext.fetch(descriptor)
		return entities
	}

	func save(_ entity: CompletedTaskEntity) throws {
		mainContext.insert(entity)
		try mainContext.save()
	}

	func delete(_ entity: CompletedTaskEntity) throws {
		guard let existingEntity = try fetchAll(for: entity.id).first else {
			return
		}
		mainContext.delete(existingEntity)
		try mainContext.save()
	}
}
