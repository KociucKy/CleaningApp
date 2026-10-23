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
		let onboardingFlowState = OnboardingFlowState()
		let completionTrendService = CompletionTrendService()
		let schedulingService = SchedulingService()
		// swiftlint:disable:next force_try
		let modelContainer = try! ModelContainer(
			for: RoomEntity.self,
			RoomTaskEntity.self,
			ScheduledTaskEntity.self,
			SkippedTaskEntity.self,
			CompletedTaskEntity.self
		)
		let services = Self.makePersistenceServices(
			config: config,
			modelContainer: modelContainer
		)

		let cleaningScheduleCoordinator = CleaningScheduleCoordinator(
			roomTaskManager: services.roomTaskManager,
			scheduledTaskManager: services.scheduledTaskManager,
			completedTaskManager: services.completedTaskManager,
			skippedTaskManager: services.skippedTaskManager,
			schedulingService: schedulingService
		)

		let dependencyContainer = DependencyContainer()
		services.register(in: dependencyContainer)
		dependencyContainer.register(SchedulingService.self, service: schedulingService)
		dependencyContainer.register(CleaningScheduleCoordinator.self, service: cleaningScheduleCoordinator)
		dependencyContainer.register(CompletionTrendServicing.self, service: completionTrendService)
		dependencyContainer.register(OnboardingFlowState.self, service: onboardingFlowState)
		self.dependencyContainer = dependencyContainer
	}

	// MARK: - Private

	private static func makePersistenceServices(
		config: BuildConfiguration,
		modelContainer: ModelContainer
	) -> PersistenceServices {
		switch config {
		case .mock:
			let roomRepository = MockRoomRepository()
			return PersistenceServices(
				roomManager: RoomManager(repository: roomRepository),
				roomTaskManager: RoomTaskManager(
					taskRepository: MockRoomTaskRepository(),
					roomRepository: roomRepository
				),
				scheduledTaskManager: ScheduledTaskManager(
					repository: MockScheduledTaskRepository()
				),
				completedTaskManager: CompletedTaskManager(
					repository: MockCompletedTaskRepository()
				),
				skippedTaskManager: SkippedTaskManager(
					repository: MockSkippedTaskRepository()
				),
				notificationScheduler: mockNotificationScheduler,
				onboardingState: OnboardingState()
			)
		case .dev, .prod:
			let roomRepository = SwiftDataRoomRepository(container: modelContainer)
			return PersistenceServices(
				roomManager: RoomManager(repository: roomRepository),
				roomTaskManager: RoomTaskManager(
					taskRepository: SwiftDataRoomTaskRepository(container: modelContainer),
					roomRepository: roomRepository
				),
				scheduledTaskManager: ScheduledTaskManager(
					repository: SwiftDataScheduledTaskRepository(container: modelContainer)
				),
				completedTaskManager: CompletedTaskManager(
					repository: SwiftDataCompletedTaskRepository(container: modelContainer)
				),
				skippedTaskManager: SkippedTaskManager(
					repository: SwiftDataSkippedTaskRepository(container: modelContainer)
				),
				notificationScheduler: NotificationScheduler(),
				onboardingState: OnboardingState()
			)
		}
	}

	private static var mockNotificationScheduler: any NotificationScheduling {
		#if MOCK
			MockNotificationScheduler()
		#else
			NotificationScheduler()
		#endif
	}

	@MainActor
	private struct PersistenceServices {
		let roomManager: RoomManager
		let roomTaskManager: RoomTaskManager
		let scheduledTaskManager: ScheduledTaskManager
		let completedTaskManager: CompletedTaskManager
		let skippedTaskManager: SkippedTaskManager
		let notificationScheduler: any NotificationScheduling
		let onboardingState: OnboardingState

		func register(in container: DependencyContainer) {
			container.register(RoomManager.self, service: roomManager)
			container.register(RoomTaskManager.self, service: roomTaskManager)
			container.register(ScheduledTaskManager.self, service: scheduledTaskManager)
			container.register(CompletedTaskManager.self, service: completedTaskManager)
			container.register(SkippedTaskManager.self, service: skippedTaskManager)
			container.register(NotificationScheduling.self, service: notificationScheduler)
			container.register(OnboardingState.self, service: onboardingState)
		}
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
	let scheduledTaskManager: ScheduledTaskManager
	let completedTaskManager: CompletedTaskManager
	let skippedTaskManager: SkippedTaskManager
	let notificationScheduler: any NotificationScheduling
	let completionTrendService: CompletionTrendService
	let schedulingService: SchedulingService
	let cleaningScheduleCoordinator: CleaningScheduleCoordinator
	let onboardingState: OnboardingState
	let onboardingFlowState: OnboardingFlowState

	var container: DependencyContainer {
		let container = DependencyContainer()
		container.register(RoomManager.self, service: roomManager)
		container.register(RoomTaskManager.self, service: roomTaskManager)
		container.register(ScheduledTaskManager.self, service: scheduledTaskManager)
		container.register(CompletedTaskManager.self, service: completedTaskManager)
		container.register(SkippedTaskManager.self, service: skippedTaskManager)
		container.register(SchedulingService.self, service: schedulingService)
		container.register(CleaningScheduleCoordinator.self, service: cleaningScheduleCoordinator)
		container.register(NotificationScheduling.self, service: notificationScheduler)
		container.register(CompletionTrendServicing.self, service: completionTrendService)
		container.register(CompletionTrendServicing.self, service: completionTrendService)
		container.register(OnboardingState.self, service: onboardingState)
		container.register(OnboardingFlowState.self, service: onboardingFlowState)
		return container
	}

	// MARK: - Init

	init() {
		let roomRepository = MockRoomRepository()
		roomManager = RoomManager(
			repository: roomRepository
		)
		roomTaskManager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: roomRepository
		)
		scheduledTaskManager = ScheduledTaskManager(
			repository: MockScheduledTaskRepository()
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
		completionTrendService = CompletionTrendService()
		schedulingService = SchedulingService()
		cleaningScheduleCoordinator = CleaningScheduleCoordinator(
			roomTaskManager: roomTaskManager,
			scheduledTaskManager: scheduledTaskManager,
			completedTaskManager: completedTaskManager,
			skippedTaskManager: skippedTaskManager,
			schedulingService: schedulingService
		)
		onboardingState = OnboardingState(showOnboarding: true)
		onboardingFlowState = OnboardingFlowState()
	}
}
