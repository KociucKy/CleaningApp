import Foundation
import Testing
@testable import CleaningApp

// MARK: - CoreInteractorScheduleTests

@Suite(.tags(.home))
@MainActor
struct CoreInteractorScheduleTests {
    // MARK: - Tests

    @Test func deleteRoomTask_removesItsScheduledOccurrences() throws {
        let dependencies = Dependencies(config: .mock)
        let scheduledTaskManager = try #require(
            dependencies.dependencyContainer.resolve(ScheduledTaskManager.self)
        )
        let interactor = CoreInteractor(container: dependencies.dependencyContainer)
        let roomTask = RoomTask(
            name: "Clean counters",
            roomId: UUID(),
            frequency: .daily,
            estimatedDuration: .fifteenMinutes
        )
        let occurrence = ScheduledTask(taskId: roomTask.id, scheduledDate: Date())
        try scheduledTaskManager.save(occurrence)

        try interactor.deleteRoomTask(roomTask)

        #expect(try scheduledTaskManager.fetchAll(for: roomTask.id).isEmpty)
    }
}
