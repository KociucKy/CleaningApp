import FulhamKit
import NavigationKit
import SwiftUI

// TODO: - Error screen - raczej powinien być dodany do FulhamKita
// TODO: - Dodać action button do empty state'u
// TODO: - Switcher layoutu - coś jak w Inspiracjach, zapisywane do UserDefaults -> tutaj można by użyć protokołu Layout
// TODO: - W onboardingu dodać Progress Bar na górze i poprawić layout na ostatnim ekranie

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
	}

	// MARK: - Views

	private var emptyStateView: some View {
		FKEmptyStateView(
			icon: "house",
			title: "No rooms yet",
			message: "Rooms will appear here once you create them"
		)
	}


	private func deprecatedRoomCardContent(for room: Room) -> some View {
		FKCardView(showBorder: false) {
			VStack(spacing: FKSpacing.medium) {
				Image(systemName: room.customIcon ?? room.kind.symbolName)
					.font(.system(size: 32))

				Text(room.name)
					.font(FKTypography.secondaryLabel)
			}
			.padding(.vertical, FKSpacing.extraLarge)
			.padding(.horizontal, FKSpacing.default)
			.foregroundStyle(Color(FKColor.Label.primary))
			.frame(maxWidth: .infinity)
		}
		.fkBorder(
			cornerRadius: FKRadius.medium,
			lineWidth: FKBorder.thin,
			color: Color(FKColor.Separator.default)
		)
		.frame(maxWidth: .infinity)
	}

	private func roomCard(for room: Room) -> some View {
		Button {
			FKHaptics.selection()
			// TODO: Navigate to room detail
			print("Navigated to \\(room.name)")
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
