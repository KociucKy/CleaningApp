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
		let notificationScheduler: any NotificationScheduling
		let onboardingState: OnboardingState
		let onboardingFlowState = OnboardingFlowState()
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
			#if MOCK
				notificationScheduler = MockNotificationScheduler()
			#else
				notificationScheduler = NotificationScheduler()
			#endif
			onboardingState = OnboardingState()
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
			notificationScheduler = NotificationScheduler()
			onboardingState = OnboardingState()
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
			notificationScheduler = NotificationScheduler()
			onboardingState = OnboardingState()
		}

		let dependencyContainer = DependencyContainer()
		dependencyContainer.register(RoomManager.self, service: roomManager)
		dependencyContainer.register(RoomTaskManager.self, service: roomTaskManager)
		dependencyContainer.register(CompletedTaskManager.self, service: completedTaskManager)
		dependencyContainer.register(SkippedTaskManager.self, service: skippedTaskManager)
		dependencyContainer.register(NotificationScheduling.self, service: notificationScheduler)
		dependencyContainer.register(OnboardingState.self, service: onboardingState)
		dependencyContainer.register(OnboardingFlowState.self, service: onboardingFlowState)
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
	let notificationScheduler: any NotificationScheduling
	let onboardingState: OnboardingState
	let onboardingFlowState: OnboardingFlowState

	var container: DependencyContainer {
		let container = DependencyContainer()
		container.register(RoomManager.self, service: roomManager)
		container.register(RoomTaskManager.self, service: roomTaskManager)
		container.register(CompletedTaskManager.self, service: completedTaskManager)
		container.register(SkippedTaskManager.self, service: skippedTaskManager)
		container.register(NotificationScheduling.self, service: notificationScheduler)
		container.register(OnboardingState.self, service: onboardingState)
		container.register(OnboardingFlowState.self, service: onboardingFlowState)
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
		#if MOCK
			notificationScheduler = MockNotificationScheduler()
		#else
			notificationScheduler = NotificationScheduler()
		#endif
		onboardingState = OnboardingState(showOnboarding: true)
		onboardingFlowState = OnboardingFlowState()
	}
}
