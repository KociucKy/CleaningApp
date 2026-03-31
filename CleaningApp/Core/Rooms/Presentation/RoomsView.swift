import NavigationKit
import SwiftUI

// MARK: - RoomsView

struct RoomsView: View {
	// MARK: - Properties

	@State var presenter: RoomsPresenter

	// MARK: - Body

	var body: some View {
		Text("rooms.nav_title")
			.navigationTitle("rooms.nav_title")
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.roomsView(router: router)
	}
}
