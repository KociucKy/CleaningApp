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

    @Test func deleteRoom_removesChildTasksAndTheirScheduledOccurrences() throws {
        let dependencies = Dependencies(config: .mock)
        let roomTaskManager = try #require(
            dependencies.dependencyContainer.resolve(RoomTaskManager.self)
        )
        let scheduledTaskManager = try #require(
            dependencies.dependencyContainer.resolve(ScheduledTaskManager.self)
        )
        let interactor = CoreInteractor(container: dependencies.dependencyContainer)
        let room = Room(name: "Kitchen", kind: .kitchen)
        let roomTask = RoomTask(
            name: "Clean counters",
            roomId: room.id,
            frequency: .daily,
            estimatedDuration: .fifteenMinutes
        )
        try interactor.saveRoom(room)
        try roomTaskManager.save(roomTask)
        try scheduledTaskManager.save(
            ScheduledTask(taskId: roomTask.id, scheduledDate: Date())
        )

        try interactor.deleteRoom(room)

        #expect(try roomTaskManager.fetchAll(for: room.id).isEmpty)
        #expect(try scheduledTaskManager.fetchAll(for: roomTask.id).isEmpty)
    }
}
