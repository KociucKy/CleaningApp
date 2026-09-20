import Foundation
import NavigationKit
import SwiftUI
import Testing
@testable import CleaningApp

// MARK: - RoomsDetailsPresenterTests

@Suite(.tags(.rooms))
@MainActor
struct RoomsDetailsPresenterTests {
    // MARK: - Loading

    @Test func onAppear_loadsSortedTasksAndDerivedValues() {
        let roomID = UUID()
        let firstTask = RoomTask(
            id: UUID(),
            name: "Dust shelves",
            roomId: roomID,
            frequency: .daily,
            estimatedDuration: .fiveMinutes
        )
        let secondTask = RoomTask(
            id: UUID(),
            name: "Vacuum floor",
            roomId: roomID,
            frequency: .daily,
            estimatedDuration: .fifteenMinutes
        )
        let completedTask = CompletedTask(taskId: firstTask.id)
        let unrelatedCompletion = CompletedTask(taskId: UUID())
        let interactor = TestInteractor(
            tasks: [secondTask, firstTask],
            completions: [
                firstTask.id: [completedTask],
                unrelatedCompletion.taskId: [unrelatedCompletion]
            ]
        )
        let presenter = makePresenter(room: Room(name: "Kitchen", kind: .kitchen), interactor: interactor)

        presenter.onAppear(roomId: roomID)

        #expect(presenter.tasks == [firstTask, secondTask])
        #expect(presenter.frequencies == [.daily])
        #expect(presenter.tasksByFrequency[.daily] == [firstTask, secondTask])
        #expect(presenter.completedTaskIDs == [firstTask.id])
        #expect(presenter.totalTasksCount == 2)
        #expect(presenter.totalDuration == 20)
        #expect(presenter.hasAnyCompletions)
        #expect(interactor.completedTasksFetchCount == 1)
        #expect(!presenter.isLoading)
        #expect(presenter.errorMessage == nil)
    }

    @Test func onAppear_doesNotReloadAfterInitialLoad() {
        let roomID = UUID()
        let interactor = TestInteractor(tasks: [])
        let presenter = makePresenter(room: Room(name: "Kitchen", kind: .kitchen), interactor: interactor)

        presenter.onAppear(roomId: roomID)
        interactor.tasks = [
            RoomTask(
                name: "New task",
                roomId: roomID,
                frequency: .everyXWeeks(1),
                estimatedDuration: .fiveMinutes
            )
        ]
        presenter.onAppear(roomId: roomID)

        #expect(presenter.tasks.isEmpty)
        #expect(interactor.fetchCount == 1)
    }

    @Test func reloadTasks_setsErrorAndStopsLoadingWhenLoadingFails() {
        let roomID = UUID()
        let interactor = TestInteractor(error: TestError.failed)
        let presenter = makePresenter(room: Room(name: "Kitchen", kind: .kitchen), interactor: interactor)

        presenter.reloadTasks(for: roomID)

        #expect(presenter.isLoading == false)
        #expect(presenter.errorMessage == "Unable to load this room’s tasks.")
    }

    // MARK: - Helpers

    private func makePresenter(
        room: Room,
        interactor: TestInteractor
    ) -> RoomsDetailsPresenter {
        RoomsDetailsPresenter(
            interactor: interactor,
            router: TestRouter(),
            room: room
        )
    }

    // MARK: - Test Doubles

    private enum TestError: Error {
        case failed
    }

    private final class TestInteractor: RoomsDetailsInteractor {
        var tasks: [RoomTask]
        let completions: [UUID: [CompletedTask]]
        let error: Error?
        private(set) var fetchCount = 0
        private(set) var completedTasksFetchCount = 0

        init(
            tasks: [RoomTask] = [],
            completions: [UUID: [CompletedTask]] = [:],
            error: Error? = nil
        ) {
            self.tasks = tasks
            self.completions = completions
            self.error = error
        }

        func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask] {
            fetchCount += 1
            if let error {
                throw error
            }
            return tasks.filter { $0.roomId == roomId }
        }

        func fetchAllCompletedTasks(forTaskIDs taskIDs: [UUID]) throws -> [CompletedTask] {
            if let error {
                throw error
            }
            completedTasksFetchCount += 1
            let taskIDSet = Set(taskIDs)
            return completions.values.flatMap { $0 }.filter { taskIDSet.contains($0.taskId) }
        }

        func makeCompletionTrend(
            from completedTasks: [CompletedTask],
            tasks: [RoomTask],
            range: CompletionTrendRange
        ) -> [CompletionChartDataPoint] {
            []
        }

        func saveCompletedTask(_ task: CompletedTask) throws {}

        func deleteCompletedTask(_ task: CompletedTask) throws {}

        func deleteRoom(_ item: Room) throws {}

        func deleteRoomTask(_ item: RoomTask) throws {}

        func updateRoomTask(_ item: RoomTask) throws {}
    }

    private final class TestRouter: RoomsDetailsRouter {
        func dismissScreen() {}

        func showAlert(
            _ option: AlertType,
            title: String,
            subtitle: String?,
            buttons: (@MainActor @Sendable () -> AnyView)?
        ) {}

        func dismissAlert() {}

        func presentRoomsDetailsTaskCompletionSheet(
            props: RoomsDetailsTaskCompletionProps,
            onDismiss: (() -> Void)?
        ) {}

        func presentCustomRoomSheet(
            room: Room,
            onRoomSaved: @escaping (Room) -> Void
        ) {}

        func presentIconPicker(
            room: Room,
            onRoomSaved: @escaping (Room) -> Void
        ) {}

        func presentCustomTaskSheet(
            roomId: UUID,
            task: RoomTask?,
            onTaskSaved: @escaping (RoomTask) -> Void
        ) {}
    }
}
