import Foundation

// MARK: - CoreInteractor

@MainActor
struct CoreInteractor {

    // MARK: - Properties

    private let container: DependencyContainer

    // MARK: - Init

    init(container: DependencyContainer) {
        self.container = container
    }
}