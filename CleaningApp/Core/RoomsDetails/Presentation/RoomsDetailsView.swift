import FulhamKit
import SwiftUI

// MARK: - RoomsDetailsView

struct RoomsDetailsView: View {
	// MARK: - Properties

	private enum Constants {
		static let emptyStateStrokeLineWidth: CGFloat = 2.0
		static let emptyStateStrokeDash: [CGFloat] = [13.0]
	}

	@Environment(\.colorScheme) private var colorScheme
	@State var presenter: RoomsDetailsPresenter

	// MARK: - Body

	var body: some View {
		List {
			RoomsDetailsHeaderView(
				symbol: presenter.room.customIcon ?? presenter.room.kind.symbolName,
				roomName: presenter.room.name
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
					totalDuration: presenter.totalDuration
				)
				.opacity(presenter.animate ? 1 : 0)
				.offset(y: presenter.animate ? 0 : presenter.animationConfig.offset)
				.scaleEffect(presenter.animate ? 1 : presenter.animationConfig.scale)
				.animation(
					presenter.animationConfig.animation.delay(presenter.animationConfig.delay(for: 1)),
					value: presenter.animate
				)
			}

			if presenter.hasAnyCompletions {
				Section {
					Picker(
						"Completion range",
						selection: Binding(
							get: { presenter.completionTrendRange },
							set: presenter.onCompletionTrendRangeChanged
						)
					) {
						ForEach(CompletionTrendRange.allCases, id: \.self) { range in
							Text(range.title).tag(range)
						}
					}
					.pickerStyle(.segmented)
					.labelsHidden()
					.accessibilityLabel("Completion range")
					.listRowSeparator(.hidden)

					if presenter.hasRecentCompletions {
						RoomsDetailsCompletionChartView(
							dataPoints: presenter.completionTrend,
							range: presenter.completionTrendRange
						)
						.opacity(presenter.animate ? 1 : 0)
						.offset(y: presenter.animate ? 0 : presenter.animationConfig.offset)
						.scaleEffect(presenter.animate ? 1 : presenter.animationConfig.scale)
						.animation(
							presenter.animationConfig.animation.delay(presenter.animationConfig.delay(for: 2)),
							value: presenter.animate
						)
					}
				}
			}

			if presenter.frequencies.isNotEmpty {
				listingView
			} else {
				emptyStateView
			}
		}
		.contentMargins(.top, 0, for: .scrollContent)
		.onAppear {
			presenter.onAppear(roomId: presenter.room.id)
			presenter.restartEntranceAnimation()
		}
		.navigationTitle(presenter.isHeaderVisible ? "" : presenter.room.name)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button("History", systemImage: "book.fill") {}
			}
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button("Add task", systemImage: "plus") {
						presenter.onAddTaskButtonTapped(roomId: presenter.room.id)
					}
					Button("Edit room", systemImage: "pencil") {
						presenter.onEditRoomButtonTapped()
					}
					Divider()
					Button("Delete room", systemImage: "trash", role: .destructive) {
						presenter.onDeleteRoomButtonTapped()
					}
				} label: {
					Image(systemName: "ellipsis")
				}
			}
		}
		.scrollEdgeEffectStyle(.soft, for: .all)
	}

	@ContentBuilder
	private var listingView: some View {
		ForEach(Array(presenter.frequencies.enumerated()), id: \.element) { index, frequency in
			if let tasks = presenter.tasksByFrequency[frequency], !tasks.isEmpty {
				RoomsDetailsTaskListView(
					frequencyTitle: frequency.displayName,
					tasks: tasks,
					onCompleteTaskButtonTapped: { task in
						presenter.onTaskCompletionTapped(task)
					},
					onDeleteTaskButtonTapped: { task in
						presenter.onDeleteTaskButtonTapped(task, roomId: presenter.room.id)
					},
					onEditTaskButtonTapped: { task in
						presenter.onEditTaskButtonTapped(task)
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

	private var emptyStateView: some View {
		VStack(spacing: 0) {
			FKEmptyStateView(
				icon: "list.bullet.clipboard.fill",
				title: "No tasks added"
			)
			Button("Add task") {
				presenter.onAddTaskButtonTapped(roomId: presenter.room.id)
			}
			.buttonStyle(.borderedProminent)
		}
		.opacity(presenter.animate ? 1 : 0)
		.offset(y: presenter.animate ? 0 : presenter.animationConfig.offset)
		.scaleEffect(presenter.animate ? 1 : presenter.animationConfig.scale)
		.animation(
			presenter.animationConfig.animation.delay(presenter.animationConfig.delay(for: 2)),
			value: presenter.animate
		)
	}
}

// MARK: - Previews

#Preview("Loaded state") {
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

#Preview("Empty state") {
	let container = DevPreview.shared.container
	container.register(
		RoomTaskManager.self,
		service: RoomTaskManager(
			taskRepository: MockRoomTaskRepository(items: []),
			roomRepository: MockRoomRepository()
		)
	)
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))
	let room = Room.mock
	return RouterView { router in
		builder.roomsDetailsView(router: router, room: room)
	}
}
