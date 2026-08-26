import SwiftUI

struct RoomsDetailsView: View {
	@State var presenter: RoomsDetailsPresenter

	var body: some View {
		Text("Hello, World!")
	}
}

#Preview {
	let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
	return RouterView { router in
		builder.roomsDetailsView(router: router)
	}
}
