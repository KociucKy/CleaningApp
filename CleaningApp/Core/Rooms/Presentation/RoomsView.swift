import FulhamKit
import NavigationKit
import SwiftUI

// MARK: - RoomsView

// TODO: - Error screen - raczej powinien być dodany do FulhamKita
// TODO: - Ogarnąć Previewsy jak w AIChat
// TODO: - Ogarnąć szerokość itemów, może .containerRelativeFrame?
// TODO: - Dodać action button do empty state'u
// TODO: - Switcher layoutu - coś jak w Inspiracjach, zapisywane do UserDefaults -> tutaj można by użyć protokołu Layout
// TODO: - W onboardingu dodać Progress Bar na górze i poprawić layout na ostatnim ekranie

struct RoomsView: View {
	// MARK: - Properties

	@State var presenter: RoomsPresenter

	private let columns = [
		GridItem(.flexible(), spacing: FKSpacing.medium),
		GridItem(.flexible(), spacing: FKSpacing.medium)
	]

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

	private var roomGridView: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
				ForEach(presenter.rooms) { room in
					roomCard(for: room)
				}
			}
			.padding(.horizontal, FKSpacing.large)
		}
	}

	private func roomCard(for room: Room) -> some View {
		Button {
			FKHaptics.selection()
			// TODO: Navigate to room detail
		} label: {
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
			}
			.fkBorder(
				cornerRadius: FKRadius.medium,
				lineWidth: FKBorder.thin,
				color: Color(FKColor.Separator.default)
			)
		}
		.buttonStyle(.fkPressable)
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
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}

#Preview("Empty State") {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}

#Preview("Error state") {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}
