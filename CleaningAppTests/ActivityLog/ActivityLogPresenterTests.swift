import Foundation
import Testing
@testable import CleaningApp

// MARK: - ActivityLogPresenterTests

@Suite(.tags(.activityLog))
@MainActor
struct ActivityLogPresenterTests {
    // MARK: - Loading

    @Test func onAppear_loadsFirstPageOfNewestCompletions() {
        let completions = makeCompletions(count: 55)
        let interactor = TestInteractor(completions: completions)
        let presenter = makePresenter(interactor: interactor)

        presenter.onAppear()

        #expect(presenter.completions.map(\.id) == completions.prefix(50).map(\.id))
        #expect(isLoaded(presenter.state))
        #expect(interactor.fetchOffsets == [0])
    }

    @Test func onCompletionAppeared_loadsNextPageWhenLastCompletionAppears() throws {
        let completions = makeCompletions(count: 55)
        let interactor = TestInteractor(completions: completions)
        let presenter = makePresenter(interactor: interactor)

        presenter.onAppear()
        let lastLoadedCompletion = try #require(presenter.completions.last)
        presenter.onCompletionAppeared(lastLoadedCompletion)

        #expect(presenter.completions.map(\.id) == completions.map(\.id))
        #expect(interactor.fetchOffsets == [0, 50])
    }

    @Test func onAppear_setsEmptyStateWhenNoCompletionsExist() {
        let presenter = makePresenter(interactor: TestInteractor())

        presenter.onAppear()

        #expect(presenter.completions.isEmpty)
        #expect(isEmpty(presenter.state))
    }

    @Test func onAppear_setsErrorStateWhenInitialLoadFails() {
        let router = TestRouter()
        let presenter = makePresenter(
            interactor: TestInteractor(fetchError: TestError.failed),
            router: router
        )

        presenter.onAppear()

        #expect(isError(presenter.state))
        #expect(router.errorMessages.isEmpty)
    }

    @Test func onRetryButtonTapped_reloadsAfterInitialLoadFailure() {
        let completions = makeCompletions(count: 1)
        let interactor = TestInteractor(completions: completions, fetchError: TestError.failed)
        let presenter = makePresenter(interactor: interactor)

        presenter.onAppear()
        interactor.fetchError = nil
        presenter.onRetryButtonTapped()

        #expect(presenter.completions.map(\.id) == completions.map(\.id))
        #expect(isLoaded(presenter.state))
    }

    @Test func reloadActivity_keepsVisibleCompletionsAndShowsErrorWhenRefreshFails() {
        let completions = makeCompletions(count: 1)
        let interactor = TestInteractor(completions: completions)
        let router = TestRouter()
        let presenter = makePresenter(interactor: interactor, router: router)

        presenter.onAppear()
        interactor.fetchError = TestError.failed
        presenter.reloadActivity()

        #expect(presenter.completions.map(\.id) == completions.map(\.id))
        #expect(isLoaded(presenter.state))
        #expect(router.errorMessages.count == 1)
    }

    @Test func onCompletionAppeared_keepsVisibleCompletionsAndShowsErrorWhenNextPageFails() throws {
        let completions = makeCompletions(count: 51)
        let interactor = TestInteractor(completions: completions)
        let router = TestRouter()
        let presenter = makePresenter(interactor: interactor, router: router)

        presenter.onAppear()
        interactor.fetchError = TestError.failed
        presenter.onCompletionAppeared(try #require(presenter.completions.last))

        #expect(presenter.completions.count == 50)
        #expect(isLoaded(presenter.state))
        #expect(router.errorMessages.count == 1)
    }

    // MARK: - Deletion

    @Test func onDeleteButtonTapped_deletesCompletionAfterConfirmation() throws {
        let completion = makeCompletions(count: 1)[0]
        let interactor = TestInteractor(completions: [completion])
        let router = TestRouter()
        let presenter = makePresenter(interactor: interactor, router: router)

        presenter.onAppear()
        presenter.onDeleteButtonTapped(item: completion)
        let onConfirm = try #require(router.deleteConfirmation)
        onConfirm()

        #expect(interactor.deletedCompletionIDs == [completion.id])
        #expect(presenter.completions.isEmpty)
        #expect(isEmpty(presenter.state))
    }

    @Test func onDeleteButtonTapped_keepsVisibleCompletionsAndShowsErrorWhenDeletionFails() throws {
        let completion = makeCompletions(count: 1)[0]
        let interactor = TestInteractor(completions: [completion], deleteError: TestError.failed)
        let router = TestRouter()
        let presenter = makePresenter(interactor: interactor, router: router)

        presenter.onAppear()
        presenter.onDeleteButtonTapped(item: completion)
        let onConfirm = try #require(router.deleteConfirmation)
        onConfirm()

        #expect(presenter.completions.map(\.id) == [completion.id])
        #expect(isLoaded(presenter.state))
        #expect(router.errorMessages.count == 1)
    }

    // MARK: - Helpers

    private func makePresenter(
        interactor: TestInteractor,
        router: TestRouter = TestRouter()
    ) -> ActivityLogPresenter {
        ActivityLogPresenter(
            interactor: interactor,
            router: router,
            room: Room(name: "Living Room", kind: .livingRoom)
        )
    }

    private func makeCompletions(count: Int) -> [CompletedTask] {
        (0 ..< count).map { index in
            CompletedTask(
                id: UUID(),
                taskId: UUID(),
                completedAt: .now.addingTimeInterval(-Double(index * 60))
            )
        }
    }

    private func isLoaded(_ state: ActivityLogPresenter.State) -> Bool {
        if case .loaded = state {
            return true
        }
        return false
    }

    private func isEmpty(_ state: ActivityLogPresenter.State) -> Bool {
        if case .empty = state {
            return true
        }
        return false
    }

    private func isError(_ state: ActivityLogPresenter.State) -> Bool {
        if case .error = state {
            return true
        }
        return false
    }

    // MARK: - Test Doubles

    private enum TestError: Error {
        case failed
    }

    private final class TestInteractor: ActivityLogInteractor {
        var completions: [CompletedTask]
        var fetchError: Error?
        var deleteError: Error?
        private(set) var fetchOffsets: [Int] = []
        private(set) var deletedCompletionIDs: [UUID] = []

        init(
            completions: [CompletedTask] = [],
            fetchError: Error? = nil,
            deleteError: Error? = nil
        ) {
            self.completions = completions
            self.fetchError = fetchError
            self.deleteError = deleteError
        }

        func fetchCompletedTasks(
            forRoomId _: UUID,
            limit: Int,
            offset: Int
        ) throws -> [CompletedTask] {
            if let fetchError {
                throw fetchError
            }

            fetchOffsets.append(offset)
            return Array(completions.dropFirst(offset).prefix(limit))
        }

        func updateCompletedTask(_: CompletedTask) throws {}

        func deleteCompletedTask(_ item: CompletedTask) throws {
            if let deleteError {
                throw deleteError
            }

            deletedCompletionIDs.append(item.id)
            completions.removeAll { $0.id == item.id }
        }
    }

    private final class TestRouter: ActivityLogRouter {
        var deleteConfirmation: (@MainActor @Sendable () -> Void)?
        private(set) var errorMessages: [String] = []

        func dismissScreen() {}

        func showDeleteConfirmation(onConfirm: @escaping @MainActor @Sendable () -> Void) {
            deleteConfirmation = onConfirm
        }

        func showError(message: String) {
            errorMessages.append(message)
        }

        func presentActivityLogEditView(
            completedTask _: CompletedTask,
            onDismiss _: (() -> Void)?
        ) {}
    }
}
