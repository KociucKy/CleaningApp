import Foundation

// MARK: - MockScheduledTaskRepository

@MainActor
final class MockScheduledTaskRepository: ScheduledTaskRepository {
    // MARK: - Properties

    var items: [ScheduledTaskEntity]

    // MARK: - Init

    init(items: [ScheduledTaskEntity] = []) {
        self.items = items
    }

    // MARK: - Methods

    func fetchAll() throws -> [ScheduledTaskEntity] {
        items.sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func fetchAll(from startDate: Date, through endDate: Date) throws -> [ScheduledTaskEntity] {
        items
            .filter { $0.scheduledDate >= startDate && $0.scheduledDate <= endDate }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func fetchAll(for taskId: UUID) throws -> [ScheduledTaskEntity] {
        items
            .filter { $0.taskId == taskId }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func fetchSingle(for id: UUID) throws -> ScheduledTaskEntity? {
        items.first { $0.id == id }
    }

    func save(_ item: ScheduledTaskEntity) throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func update(_ item: ScheduledTaskEntity) throws {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index] = item
    }

    func delete(_ item: ScheduledTaskEntity) throws {
        items.removeAll { $0.id == item.id }
    }
}
