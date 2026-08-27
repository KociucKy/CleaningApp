import FulhamKit
import SwiftUI

// MARK: - RoomsDetailsView

struct RoomsDetailsView: View {
	// MARK: - Properties

	@Environment(\.colorScheme) private var colorScheme
	@State var presenter: RoomsDetailsPresenter
	@State private var isEntranceAnimationVisible = false
	private let entranceAnimationConfiguration = RoomsAnimationConfiguration()
	let room: Room

	// MARK: - Body

	var body: some View {
		List {
			RoomsDetailsHeaderView(
				symbol: room.customIcon ?? room.kind.symbolName,
				roomName: room.name
			)
			.frame(maxWidth: .infinity, alignment: .center)
			.opacity(isEntranceAnimationVisible ? 1 : 0)
			.offset(y: isEntranceAnimationVisible ? 0 : entranceAnimationConfiguration.offset)
			.scaleEffect(isEntranceAnimationVisible ? 1 : entranceAnimationConfiguration.scale)
			.animation(
				entranceAnimationConfiguration.animation.delay(entranceAnimationConfiguration.delay(for: 0)),
				value: isEntranceAnimationVisible
			)

			Section {
				RoomsDetailsMetricsView(
					taskCount: presenter.totalTasksCount,
					totalDuration: presenter.totalDuration,
					completedTaskCount: presenter.completedTaskCount
				)
				.opacity(isEntranceAnimationVisible ? 1 : 0)
				.offset(y: isEntranceAnimationVisible ? 0 : entranceAnimationConfiguration.offset)
				.scaleEffect(isEntranceAnimationVisible ? 1 : entranceAnimationConfiguration.scale)
				.animation(
					entranceAnimationConfiguration.animation.delay(entranceAnimationConfiguration.delay(for: 1)),
					value: isEntranceAnimationVisible
				)
			}

			ForEach(Array(presenter.frequencies.enumerated()), id: \.element) { index, frequency in
				if let tasks = presenter.tasksByFrequency[frequency], !tasks.isEmpty {
					RoomsDetailsTaskListView(
						frequencyTitle: frequency.displayName,
						tasks: tasks,
						onCompleteTaskButtonTapped: { task in
							FKHaptics.notification(.success)
							presenter.onTaskCompletionTapped(task)
						},
						onDeleteTaskButtonTapped: { task in
							FKHaptics.notification(.warning)
							presenter.onDeleteTaskButtonTapped(task, roomId: room.id)
						}
					)
					.opacity(isEntranceAnimationVisible ? 1 : 0)
					.offset(y: isEntranceAnimationVisible ? 0 : entranceAnimationConfiguration.offset)
					.scaleEffect(isEntranceAnimationVisible ? 1 : entranceAnimationConfiguration.scale)
					.animation(
						entranceAnimationConfiguration.animation.delay(
							entranceAnimationConfiguration.delay(for: index + 2)
						),
						value: isEntranceAnimationVisible
					)
				}
			}
		}
		.contentMargins(.top, 0, for: .scrollContent)
		.onAppear {
			presenter.onAppear(room: room)
			restartEntranceAnimation()
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("", systemImage: "pencil") {}
			}
		}
		.scrollEdgeEffectStyle(.soft, for: .all)
	}

	// MARK: - Animation

	private func restartEntranceAnimation() {
		var transaction = Transaction()
		transaction.animation = nil
		withTransaction(transaction) {
			isEntranceAnimationVisible = false
		}

		DispatchQueue.main.async {
			withAnimation(.easeOut(duration: entranceAnimationConfiguration.duration)) {
				isEntranceAnimationVisible = true
			}
		}
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	container.register(
		RoomTaskManager.self,
		service: RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
	)
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))
	let room = Room.mock
	return RouterView { router in
		builder.roomsDetailsView(router: router, room: room)
	}
}
