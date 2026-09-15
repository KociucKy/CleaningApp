import Foundation
import NavigationKit
import SwiftUI
import Testing
@testable import CleaningApp

// MARK: - RoomsPresenterTests

@Suite(.tags(.rooms))
@MainActor
struct RoomsPresenterTests {
    // MARK: - State

    @Test func onAppearFetch_sortsRoomsNewestFirstAndLoads() throws {
        let older = Room(id: UUID(), name: "Older", kind: .bedroom, createdAt: Date(timeIntervalSince1970: 10))
        let newer = Room(id: UUID(), name: "Newer", kind: .kitchen, createdAt: Date(timeIntervalSince1970: 20))
        let interactor = TestInteractor(rooms: [older, newer])
        let presenter = RoomsPresenter(interactor: interactor, router: TestRouter())

        presenter.onAppearFetch()

        #expect(presenter.rooms == [newer, older])
        #expect(isLoaded(presenter.state))
    }

    @Test func onAppearFetch_setsEmptyStateWhenNoRoomsExist() {
        let presenter = RoomsPresenter(
            interactor: TestInteractor(rooms: []),
            router: TestRouter()
        )

        presenter.onAppearFetch()

        #expect(isEmpty(presenter.state))
    }

    @Test func onAppearFetch_setsErrorStateWhenLoadingFails() {
        let presenter = RoomsPresenter(
            interactor: TestInteractor(error: TestError.failed),
            router: TestRouter()
        )

        presenter.onAppearFetch()

        #expect(isError(presenter.state, message: "Failed to load rooms"))
    }

    @Test func increaseAnimationConfigurationRunID_incrementsRunID() {
        let presenter = RoomsPresenter(
            interactor: TestInteractor(rooms: []),
            router: TestRouter()
        )

        presenter.increaseAnimationConfigurationRunID()
        presenter.increaseAnimationConfigurationRunID()

        #expect(presenter.animationConfiguration.runID == 2)
    }

    // MARK: - Helpers

    private func isLoaded(_ state: RoomsPresenter.State) -> Bool {
        if case .loaded = state {
            return true
        }
        return false
    }

    private func isEmpty(_ state: RoomsPresenter.State) -> Bool {
        if case .empty = state {
            return true
        }
        return false
    }

    private func isError(_ state: RoomsPresenter.State, message: String) -> Bool {
        if case .error(message) = state {
            return true
        }
        return false
    }

    // MARK: - Test Doubles

    private enum TestError: Error {
        case failed
    }

    private final class TestInteractor: RoomsInteractor {
        let rooms: [Room]
        let error: Error?

        init(rooms: [Room] = [], error: Error? = nil) {
            self.rooms = rooms
            self.error = error
        }

        func fetchAllRooms() throws -> [Room] {
            if let error {
                throw error
            }
            return rooms
        }

        func deleteRoom(_ item: Room) throws {}
    }

    private final class TestRouter: RoomsRouter {
        func dismissScreen() {}

        func presentRoomsDetailsView(room: Room, namespace: Namespace.ID) {}

        func presentAddCustomRoomSheet(onDismiss: (() -> Void)?) {}

        func presentCustomRoomSheet(room: Room, onRoomSaved: @escaping (Room) -> Void) {}

        func showAlert(
            _ option: AlertType,
            title: String,
            subtitle: String?,
            buttons: (@MainActor @Sendable () -> AnyView)?
        ) {}

        func dismissAlert() {}
    }
}
