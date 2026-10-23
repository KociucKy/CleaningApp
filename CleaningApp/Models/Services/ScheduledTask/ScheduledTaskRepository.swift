import Foundation
import SwiftData

// MARK: - ScheduledTaskRepository

@MainActor
protocol ScheduledTaskRepository {
    func fetchAll() throws -> [ScheduledTaskEntity]
    func fetchAll(from startDate: Date, through endDate: Date) throws -> [ScheduledTaskEntity]
    func fetchAll(for taskId: UUID) throws -> [ScheduledTaskEntity]
    func fetchSingle(for id: UUID) throws -> ScheduledTaskEntity?
    func save(_ item: ScheduledTaskEntity) throws
    func update(_ item: ScheduledTaskEntity) throws
    func delete(_ item: ScheduledTaskEntity) throws
}

// MARK: - SwiftDataScheduledTaskRepository

@MainActor
final class SwiftDataScheduledTaskRepository: ScheduledTaskRepository {
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

    func fetchAll() throws -> [ScheduledTaskEntity] {
        let descriptor = FetchDescriptor<ScheduledTaskEntity>(
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        return try mainContext.fetch(descriptor)
    }

    func fetchAll(from startDate: Date, through endDate: Date) throws -> [ScheduledTaskEntity] {
        let descriptor = FetchDescriptor<ScheduledTaskEntity>(
            predicate: #Predicate {
                $0.scheduledDate >= startDate && $0.scheduledDate <= endDate
            },
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        return try mainContext.fetch(descriptor)
    }

    func fetchAll(for taskId: UUID) throws -> [ScheduledTaskEntity] {
        let descriptor = FetchDescriptor<ScheduledTaskEntity>(
            predicate: #Predicate { $0.taskId == taskId },
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        return try mainContext.fetch(descriptor)
    }

    func fetchSingle(for id: UUID) throws -> ScheduledTaskEntity? {
        let descriptor = FetchDescriptor<ScheduledTaskEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try mainContext.fetch(descriptor).first
    }

    func save(_ item: ScheduledTaskEntity) throws {
        mainContext.insert(item)
        try mainContext.save()
    }

    func update(_ item: ScheduledTaskEntity) throws {
        guard let existingEntity = try fetchSingle(for: item.id) else {
            return
        }

        existingEntity.taskId = item.taskId
        existingEntity.scheduledDate = item.scheduledDate
        existingEntity.originalScheduledDate = item.originalScheduledDate
        existingEntity.statusEncoded = item.statusEncoded
        existingEntity.sourceOccurrenceId = item.sourceOccurrenceId
        existingEntity.createdAt = item.createdAt
        existingEntity.updatedAt = item.updatedAt

        try mainContext.save()
    }

    func delete(_ item: ScheduledTaskEntity) throws {
        guard let existingEntity = try fetchSingle(for: item.id) else {
            return
        }

        mainContext.delete(existingEntity)
        try mainContext.save()
    }
}
