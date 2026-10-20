import Foundation

// MARK: - ScheduledTaskManager

@MainActor
final class ScheduledTaskManager {
    // MARK: - Properties

    private let repository: any ScheduledTaskRepository
    private let mapper: ScheduledTaskMapper

    // MARK: - Init

    init(
        repository: any ScheduledTaskRepository,
        mapper: ScheduledTaskMapper = ScheduledTaskMapper()
    ) {
        self.repository = repository
        self.mapper = mapper
    }

    // MARK: - Methods

    func fetchAll() throws -> [ScheduledTask] {
        let entities = try repository.fetchAll()
        return entities.map(mapper.toDomain)
    }

    func fetchAll(from startDate: Date, through endDate: Date) throws -> [ScheduledTask] {
        let entities = try repository.fetchAll(from: startDate, through: endDate)
        return entities.map(mapper.toDomain)
    }

    func fetchAll(for taskId: UUID) throws -> [ScheduledTask] {
        let entities = try repository.fetchAll(for: taskId)
        return entities.map(mapper.toDomain)
    }

    func fetchActiveOccurrences(for taskId: UUID) throws -> [ScheduledTask] {
        try fetchAll(for: taskId).filter {
            $0.status == .planned || $0.status == .postponed
        }
    }

    func fetchSuccessors(for sourceOccurrenceId: UUID) throws -> [ScheduledTask] {
        try fetchAll().filter { $0.sourceOccurrenceId == sourceOccurrenceId }
    }

    func fetchSingle(for id: UUID) throws -> ScheduledTask? {
        guard let entity = try repository.fetchSingle(for: id) else {
            return nil
        }
        return mapper.toDomain(entity)
    }

    func save(_ item: ScheduledTask) throws {
        try repository.save(mapper.toEntity(item))
    }

    func update(_ item: ScheduledTask) throws {
        try repository.update(mapper.toEntity(item))
    }

    func delete(_ item: ScheduledTask) throws {
        try repository.delete(mapper.toEntity(item))
    }
}
