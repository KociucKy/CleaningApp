import FulhamKit
import NavigationKit
import SwiftUI

// MARK: - RoomsView

struct RoomsView: View {
	// MARK: - Properties

	@Environment(\.tabBarSelection) private var tabBarSelection
	@State private var presenter: RoomsPresenter
	#if DEV || MOCK
	@State private var isShowingAnimationControls = false
	#endif

	private var roomsTabIsActive: Bool {
		tabBarSelection == nil || tabBarSelection == String(localized: "tab.rooms")
	}

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
				RoomsGridView(
					rooms: presenter.rooms,
					animationConfiguration: presenter.animationConfiguration,
					isActive: roomsTabIsActive,
					cardView: roomCard(for:)
				)
				.id(roomsTabIsActive)
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
			#if DEV || MOCK
			ToolbarItem(placement: .primaryAction) {
				Button("Animation controls", systemImage: "slider.horizontal.3") {
					isShowingAnimationControls.toggle()
				}
				.accessibilityLabel(
					isShowingAnimationControls ? "Hide animation controls" : "Show animation controls"
				)
			}
			#endif
		}
		.toast($presenter.toast)
		.background(FKColor.Background.primary)
		.scrollEdgeEffectStyle(.soft, for: .all)
		#if DEV || MOCK
			.overlay(alignment: .bottomTrailing) {
				if isShowingAnimationControls {
					RoomsAnimationControlsView(configuration: $presenter.animationConfiguration) {
						presenter.increaseAnimationConfigurationRunID()
					}
					.transition(.move(edge: .bottom).combined(with: .opacity))
				}
			}
			.animation(.easeOut(duration: 0.2), value: isShowingAnimationControls)
		#endif
	}

	// MARK: - Views

	private func roomCard(for room: Room) -> some View {
		Button {
			FKHaptics.selection()
			presenter.onRoomCardTapped(room: room)
		} label: {
			RoomCardView(
				room: room,
				deleteAction: {
					presenter.deleteRoom(room: room)
				}
			)
		}
		.buttonStyle(.fkFade)
		.contextMenu {
			Button {} label: {
				Label("Edit", systemImage: "pencil")
			}

			Divider()

			Button(role: .destructive) {} label: {
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
