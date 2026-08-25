import FulhamKit
import NavigationKit
import SwiftUI

// MARK: - RoomsView

// TODO: - Error screen - raczej powinien być dodany do FulhamKita
// TODO: - Dodać action button do empty state'u
// TODO: - Switcher layoutu - coś jak w Inspiracjach, zapisywane do UserDefaults -> tutaj można by użyć protokołu Layout
// TODO: - W onboardingu dodać Progress Bar na górze i poprawić layout na ostatnim ekranie

struct RoomsView: View {
	// MARK: - Properties

	@State private var presenter: RoomsPresenter

	private let columns = [
		GridItem(.flexible(), spacing: FKSpacing.medium),
		GridItem(.flexible(), spacing: FKSpacing.medium)
	]
	private let disablesPreviewReordering: Bool

	// MARK: - Init

	init(presenter: RoomsPresenter, disablesPreviewReordering: Bool = false) {
		_presenter = State(initialValue: presenter)
		self.disablesPreviewReordering = disablesPreviewReordering
	}

	// MARK: - Body

	var body: some View {
		Group {
			if presenter.isLoading {
				ProgressView()
			} else {
				contentView
			}
		}
		.navigationTitle("rooms.nav_title")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(
					"Add",
					systemImage: "plus",
					role: .confirm,
					action: presenter.onAddButtonTapped
				)
			}
			if !presenter.isLoading && presenter.rooms.isNotEmpty && presenter.isReordering {
				ToolbarItem(placement: .topBarLeading) {
					Button("Done") {
						presenter.isReordering = false
					}
				}
			}
		}
		.toast($presenter.toast)
	}

	// MARK: - Views

	@ViewBuilder
	private var contentView: some View {
		if let errorMessage = presenter.errorMessage {
			errorBanner(message: errorMessage)
		} else if presenter.rooms.isEmpty {
			emptyStateView
		} else {
			roomGridView
		}
	}

	private var emptyStateView: some View {
		FKEmptyStateView(
			icon: "house",
			title: "No rooms yet",
			message: "Rooms will appear here once you create them"
		)
	}

	@ViewBuilder
	private var roomGridView: some View {
		if disablesPreviewReordering {
			ScrollView {
				LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
					ForEach(presenter.rooms) { room in
						roomCard(for: room)
					}
				}
				.padding(.horizontal, FKSpacing.large)
			}
		} else if #available(iOS 27.0, *) {
			ScrollView {
				LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
					ForEach(presenter.rooms) { room in
						roomCard(for: room)
					}
					.reorderable()
				}
				.padding(.horizontal, FKSpacing.large)
				.reorderContainer(
					for: Room.self,
					isEnabled: presenter.isReordering
				) { difference in
					withAnimation {
						presenter.onRoomsReordered(difference)
					}
				}
			}
		} else {
			ScrollView {
				LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
					ForEach(presenter.rooms) { room in
						roomCard(for: room)
					}
				}
				.padding(.horizontal, FKSpacing.large)
			}
		}
	}

	private func roomCardContent(for room: Room) -> some View {
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
			roomCardContent(for: room)
		}
		.buttonStyle(.fkFade)
		.contextMenu {
			Button { } label: {
				Label("Edit", systemImage: "pencil")
			}

			Button {
				presenter.isReordering.toggle()
			} label: {
				Label("Reorder", systemImage: "arrow.up.arrow.down")
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
		builder.roomsView(router: router, disablesPreviewReordering: true)
	}
}

#Preview("Empty State") {
	let container = DevPreview.shared.container
	container.register(RoomManager.self, service: RoomManager(repository: MockRoomRepository(items: [])))
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router, disablesPreviewReordering: true)
	}
}

#Preview("Error state") {
	let container = DevPreview.shared.container
	container.register(RoomManager.self, service: RoomManager(repository: MockRoomRepository(error: NSError(domain: "", code: 404))))
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router, disablesPreviewReordering: true)
	}
}
