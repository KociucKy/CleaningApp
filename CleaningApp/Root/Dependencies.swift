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
		let roomManager: RoomManager
		let roomTaskManager: RoomTaskManager
		let completedTaskManager: CompletedTaskManager
		let skippedTaskManager: SkippedTaskManager
		// swiftlint:disable:next force_try
		let modelContainer = try! ModelContainer(
			for: RoomEntity.self,
			RoomTaskEntity.self,
			SkippedTaskEntity.self,
			CompletedTaskEntity.self
		)

		switch config {
		case .mock:
			roomManager = RoomManager(
				repository: MockRoomRepository()
			)
			roomTaskManager = RoomTaskManager(
				taskRepository: MockRoomTaskRepository(),
				roomRepository: MockRoomRepository()
			)
			completedTaskManager = CompletedTaskManager(
				repository: MockCompletedTaskRepository()
			)
			skippedTaskManager = SkippedTaskManager(
				repository: MockSkippedTaskRepository()
			)
		case .dev:
			roomManager = RoomManager(
				repository: SwiftDataRoomRepository(container: modelContainer)
			)
			roomTaskManager = RoomTaskManager(
				taskRepository: SwiftDataRoomTaskRepository(container: modelContainer),
				roomRepository: SwiftDataRoomRepository(container: modelContainer)
			)
			completedTaskManager = CompletedTaskManager(
				repository: SwiftDataCompletedTaskRepository(container: modelContainer)
			)
			skippedTaskManager = SkippedTaskManager(
				repository: SwiftDataSkippedTaskRepository(container: modelContainer)
			)
		case .prod:
			roomManager = RoomManager(
				repository: SwiftDataRoomRepository(container: modelContainer)
			)
			roomTaskManager = RoomTaskManager(
				taskRepository: SwiftDataRoomTaskRepository(container: modelContainer),
				roomRepository: SwiftDataRoomRepository(container: modelContainer)
			)
			completedTaskManager = CompletedTaskManager(
				repository: SwiftDataCompletedTaskRepository(container: modelContainer)
			)
			skippedTaskManager = SkippedTaskManager(
				repository: SwiftDataSkippedTaskRepository(container: modelContainer)
			)
		}

		let dependencyContainer = DependencyContainer()
		dependencyContainer.register(RoomManager.self, service: roomManager)
		dependencyContainer.register(RoomTaskManager.self, service: roomTaskManager)
		dependencyContainer.register(CompletedTaskManager.self, service: completedTaskManager)
		dependencyContainer.register(SkippedTaskManager.self, service: skippedTaskManager)
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
	let roomTaskManager: RoomTaskManager
	let completedTaskManager: CompletedTaskManager
	let skippedTaskManager: SkippedTaskManager

	var container: DependencyContainer {
		let container = DependencyContainer()
		container.register(RoomManager.self, service: roomManager)
		container.register(RoomTaskManager.self, service: roomTaskManager)
		container.register(CompletedTaskManager.self, service: completedTaskManager)
		container.register(SkippedTaskManager.self, service: skippedTaskManager)
		return container
	}

	// MARK: - Init

	init() {
		roomManager = RoomManager(
			repository: MockRoomRepository()
		)
		roomTaskManager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		completedTaskManager = CompletedTaskManager(
			repository: MockCompletedTaskRepository()
		)
		skippedTaskManager = SkippedTaskManager(
			repository: MockSkippedTaskRepository()
		)
	}
}
