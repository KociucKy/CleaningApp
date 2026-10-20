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
