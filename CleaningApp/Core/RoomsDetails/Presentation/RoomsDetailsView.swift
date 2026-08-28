import FulhamKit
import SwiftUI

// MARK: - RoomsDetailsView

struct RoomsDetailsView: View {
	// MARK: - Properties

	@Environment(\.colorScheme) private var colorScheme
	@State var presenter: RoomsDetailsPresenter
	let room: Room

	// MARK: - Body

	var body: some View {
		List {
			RoomsDetailsHeaderView(
				symbol: room.customIcon ?? room.kind.symbolName,
				roomName: room.name
			)
			.frame(maxWidth: .infinity, alignment: .center)
			.opacity(presenter.animate ? 1 : 0)
			.offset(y: presenter.animate ? 0 : presenter.animationConfig.offset)
			.scaleEffect(presenter.animate ? 1 : presenter.animationConfig.scale)
			.animation(
				presenter.animationConfig.animation.delay(presenter.animationConfig.delay(for: 0)),
				value: presenter.animate
			)
			.onScrollVisibilityChange(threshold: 0.01) { isVisible in
				withAnimation(.easeInOut(duration: 0.2)) {
					presenter.isHeaderVisible = isVisible
				}
			}
			.removeListRowFormatting()
			Section {
				RoomsDetailsMetricsView(
					taskCount: presenter.totalTasksCount,
					totalDuration: presenter.totalDuration,
					completedTaskCount: presenter.completedTaskCount
				)
				.opacity(presenter.animate ? 1 : 0)
				.offset(y: presenter.animate ? 0 : presenter.animationConfig.offset)
				.scaleEffect(presenter.animate ? 1 : presenter.animationConfig.scale)
				.animation(
					presenter.animationConfig.animation.delay(presenter.animationConfig.delay(for: 1)),
					value: presenter.animate
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
					.opacity(presenter.animate ? 1 : 0)
					.offset(y: presenter.animate ? 0 : presenter.animationConfig.offset)
					.scaleEffect(presenter.animate ? 1 : presenter.animationConfig.scale)
					.animation(
						presenter.animationConfig.animation.delay(
							presenter.animationConfig.delay(for: index + 2)
						),
						value: presenter.animate
					)
				}
			}
		}
		.contentMargins(.top, 0, for: .scrollContent)
		.onAppear {
			presenter.onAppear(room: room)
			presenter.restartEntranceAnimation()
		}
		.navigationTitle(presenter.isHeaderVisible ? "" : room.name)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("", systemImage: "pencil") {}
			}
		}
		.scrollEdgeEffectStyle(.soft, for: .all)
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
