import Foundation
import SwiftData

// MARK: - BuildConfiguration

enum BuildConfiguration {
    case mock, dev, prod
}

// MARK: - Dependencies

@MainActor
struct Dependencies {

    // MARK: - Properties

    let dependencyContainer: DependencyContainer

    // MARK: - Init

    init(config: BuildConfiguration) {
        let modelContainer = try! ModelContainer(for: RoomEntity.self)
        let dependencyContainer = DependencyContainer()
        let roomManager: RoomManager

        switch config {
        case .mock:
            roomManager = RoomManager(
                repository: MockRoomRepository()
            )
        case .dev, .prod:
            roomManager = RoomManager(
                repository: SwiftDataRoomRepository(container: modelContainer)
            )
        }

        dependencyContainer.register(RoomManager.self, service: roomManager)
        self.dependencyContainer = dependencyContainer
    }
}

// MARK: - DevPreview

@MainActor
final class DevPreview {

    // MARK: - Shared

    static let shared = DevPreview()

    // MARK: - Properties

    let roomManager: RoomManager

    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(RoomManager.self, service: roomManager)
        return container
    }

    // MARK: - Init

    init() {
        self.roomManager = RoomManager(
            repository: MockRoomRepository()
        )
    }
}