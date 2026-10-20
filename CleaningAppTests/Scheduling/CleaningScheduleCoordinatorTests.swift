import Foundation
import Testing
@testable import CleaningApp

// MARK: - CleaningScheduleCoordinatorTests

@Suite(.tags(.home))
@MainActor
struct CleaningScheduleCoordinatorTests {
    // MARK: - Properties

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    // MARK: - Tests

    @Test func refresh_persistsScheduleMutation() throws {
        let today = try makeDate(day: 25)
        let room = RoomEntity(name: "Kitchen", icon: "fork.knife")
        let roomRepository = MockRoomRepository(items: [room])
        let roomTaskRepository = MockRoomTaskRepository(items: [])
        let scheduledTaskRepository = MockScheduledTaskRepository()
        let roomTaskManager = RoomTaskManager(
            taskRepository: roomTaskRepository,
            roomRepository: roomRepository
        )
        let scheduledTaskManager = ScheduledTaskManager(repository: scheduledTaskRepository)
        let task = RoomTask(
            name: "Clean counters",
            roomId: room.id,
            frequency: .daily,
            estimatedDuration: .fifteenMinutes,
            createdAt: try makeDate(day: 1)
        )
        try roomTaskManager.save(task)
        let coordinator = CleaningScheduleCoordinator(
            roomTaskManager: roomTaskManager,
            scheduledTaskManager: scheduledTaskManager,
            completedTaskManager: CompletedTaskManager(repository: MockCompletedTaskRepository()),
            skippedTaskManager: SkippedTaskManager(repository: MockSkippedTaskRepository()),
            calendar: calendar
        )

        let mutation = try coordinator.refresh(today: today, dailyLimit: 30)

        #expect(mutation.occurrencesToCreate.count == 1)
        #expect(try scheduledTaskManager.fetchAll().count == 1)
        #expect(try scheduledTaskManager.fetchAll().first?.taskId == task.id)
    }

    @Test func complete_updatesOccurrenceAndCreatesLinkedHistory() throws {
        let completedAt = try makeDate(day: 25)
        let room = RoomEntity(name: "Kitchen", icon: "fork.knife")
        let roomRepository = MockRoomRepository(items: [room])
        let roomTaskManager = RoomTaskManager(
            taskRepository: MockRoomTaskRepository(items: []),
            roomRepository: roomRepository
        )
        let scheduledTaskRepository = MockScheduledTaskRepository()
        let completedTaskRepository = MockCompletedTaskRepository(items: [])
        let scheduledTaskManager = ScheduledTaskManager(repository: scheduledTaskRepository)
        let completedTaskManager = CompletedTaskManager(repository: completedTaskRepository)
        let task = RoomTask(
            name: "Clean counters",
            roomId: room.id,
            frequency: .daily,
            estimatedDuration: .fifteenMinutes,
            createdAt: try makeDate(day: 1)
        )
        let occurrence = ScheduledTask(
            taskId: task.id,
            scheduledDate: completedAt,
            createdAt: completedAt,
            updatedAt: completedAt
        )
        try scheduledTaskManager.save(occurrence)
        let coordinator = CleaningScheduleCoordinator(
            roomTaskManager: roomTaskManager,
            scheduledTaskManager: scheduledTaskManager,
            completedTaskManager: completedTaskManager,
            skippedTaskManager: SkippedTaskManager(repository: MockSkippedTaskRepository()),
            calendar: calendar
        )

        try coordinator.complete(
            scheduledTaskId: occurrence.id,
            completedAt: completedAt,
            measuredDuration: 18
        )

        #expect(try scheduledTaskManager.fetchSingle(for: occurrence.id)?.status == .completed)
        let completedTasks = try completedTaskManager.fetchAll()
        #expect(completedTasks.count == 1)
        #expect(completedTasks.first?.taskId == task.id)
        #expect(completedTasks.first?.scheduledTaskId == occurrence.id)
        #expect(completedTasks.first?.completedAt == completedAt)
        #expect(completedTasks.first?.measuredDuration == 18)
    }

    @Test func skip_createsLinkedSuccessorNoEarlierThanTomorrow() throws {
        let skippedAt = try makeDate(day: 25)
        let expectedSuccessorDate = try makeDate(day: 26)
        let room = RoomEntity(name: "Kitchen", icon: "fork.knife")
        let roomRepository = MockRoomRepository(items: [room])
        let roomTaskManager = RoomTaskManager(
            taskRepository: MockRoomTaskRepository(items: []),
            roomRepository: roomRepository
        )
        let scheduledTaskManager = ScheduledTaskManager(repository: MockScheduledTaskRepository())
        let skippedTaskRepository = MockSkippedTaskRepository()
        skippedTaskRepository.items = []
        let skippedTaskManager = SkippedTaskManager(repository: skippedTaskRepository)
        let task = RoomTask(
            name: "Clean counters",
            roomId: room.id,
            frequency: .daily,
            estimatedDuration: .fifteenMinutes,
            createdAt: try makeDate(day: 1)
        )
        let occurrence = ScheduledTask(
            taskId: task.id,
            scheduledDate: skippedAt,
            createdAt: skippedAt,
            updatedAt: skippedAt
        )
        try roomTaskManager.save(task)
        try scheduledTaskManager.save(occurrence)
        let coordinator = CleaningScheduleCoordinator(
            roomTaskManager: roomTaskManager,
            scheduledTaskManager: scheduledTaskManager,
            completedTaskManager: CompletedTaskManager(repository: MockCompletedTaskRepository(items: [])),
            skippedTaskManager: skippedTaskManager,
            calendar: calendar
        )

        let mutation = try coordinator.skip(
            scheduledTaskId: occurrence.id,
            skippedAt: skippedAt,
            dailyLimit: 30
        )

        #expect(try scheduledTaskManager.fetchSingle(for: occurrence.id)?.status == .skipped)
        #expect(try skippedTaskManager.fetchAll().first?.scheduledTaskId == occurrence.id)
        #expect(mutation.occurrencesToCreate.count == 1)
        #expect(mutation.occurrencesToCreate.first?.status == .planned)
        #expect(mutation.occurrencesToCreate.first?.sourceOccurrenceId == occurrence.id)
        #expect(mutation.occurrencesToCreate.first?.scheduledDate == expectedSuccessorDate)
    }

    // MARK: - Private

    private func makeDate(day: Int) throws -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026,
            month: 10,
            day: day
        )
        return try #require(calendar.date(from: components))
    }
}
