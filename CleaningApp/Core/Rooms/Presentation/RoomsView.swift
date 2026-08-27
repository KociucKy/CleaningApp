import FulhamKit
import NavigationKit
import SwiftUI

struct RoomsView: View {
	// MARK: - Properties

	@State private var presenter: RoomsPresenter

	// MARK: - Init

	init(presenter: RoomsPresenter) {
		_presenter = State(initialValue: presenter)
	}

	// MARK: - Body

	var body: some View {
		Group {
			switch presenter.state {
			case .isLoading:
				ProgressView()
			case .loaded:
				RoomsGridView(rooms: presenter.rooms, cardView: roomCard(for:))
			case .error(let errorString):
				errorBanner(message: errorString)
			case .empty:
				emptyStateView
			}
		}
		.navigationTitle("rooms.nav_title")
		.navigationSubtitle("Manage your spaces")
		.navigationBarTitleDisplayMode(.large)
		.onAppear(perform: presenter.onAppearFetch)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(
					"Add",
					systemImage: "plus",
					role: .confirm,
					action: presenter.onAddButtonTapped
				)
			}
		}
		.toast($presenter.toast)
		.background(FKColor.Background.primary)
		.scrollEdgeEffectStyle(.soft, for: .all)
	}

	// MARK: - Views

	private func roomCard(for room: Room) -> some View {
		Button {
			FKHaptics.selection()
			presenter.onRoomCardTapped(room: room)
		} label: {
			RoomCardView(room: room)
		}
		.buttonStyle(.fkFade)
		.contextMenu {
			Button { } label: {
				Label("Edit", systemImage: "pencil")
			}

			Divider()

			Button(role: .destructive) { } label: {
				Label("Delete", systemImage: "trash")
			}
		}
	}

	private var emptyStateView: some View {
		FKEmptyStateView(
			icon: "house",
			title: "No rooms yet",
			message: "Rooms will appear here once you create them"
		)
	}

	private func errorBanner(message: String) -> some View {
		VStack {
			Text(message)
				.font(FKTypography.body)
				.foregroundStyle(Color(FKColor.Label.primary))
				.padding(FKSpacing.default)
				.frame(maxWidth: .infinity)
				.background(Color(FKColor.Background.canvas))
			Spacer()
		}
	}
}

// MARK: - Preview

#Preview("Normal state") {
	let container = DevPreview.shared.container
	container.register(RoomManager.self, service: RoomManager(repository: MockRoomRepository()))
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}

#Preview("Empty State") {
	let container = DevPreview.shared.container
	container.register(RoomManager.self, service: RoomManager(repository: MockRoomRepository(items: [])))
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}

#Preview("Error state") {
	let container = DevPreview.shared.container
	container.register(RoomManager.self, service: RoomManager(repository: MockRoomRepository(error: NSError(domain: "", code: 404))))
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}
