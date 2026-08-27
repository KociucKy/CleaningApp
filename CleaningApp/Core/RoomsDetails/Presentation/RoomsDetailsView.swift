import FulhamKit
import SwiftUI

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
			
			Section {
				RoomsDetailsMetricsView(
					taskCount: presenter.totalTasksCount,
					totalDuration: presenter.totalDuration,
					completedTaskCount: presenter.completedTaskCount
				)
			}
			ForEach(presenter.frequencies, id: \.self) { frequency in
				if let tasks = presenter.tasksByFrequency[frequency], !tasks.isEmpty {
					Section(frequency.displayName) {
						ForEach(tasks) { task in
							Button {
								presenter.onTaskCompletionTapped(task)
							} label: {
								HStack {
									VStack(alignment: .leading, spacing: 4) {
										Text(task.name)
											.font(FKTypography.bodyBold)
										Text("\(task.estimatedDuration.rawValue) min")
											.font(FKTypography.caption)
											.foregroundStyle(.secondary)
									}
									Spacer()
								}
							}
							.buttonStyle(.plain)
						}
					}
				}
			}
		}
		.contentMargins(.top, 0, for: .scrollContent)
		.onAppear {
			presenter.onAppear(room: room)
		}
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
