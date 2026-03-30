import NavigationKit
import SwiftUI

struct HomeView: View {
	// MARK: - Properties

	@State var presenter: HomeViewPresenter

	// MARK: - Body

	var body: some View {
		Text("Rooms count: \(presenter.rooms.count)")
			.navigationTitle("Home")
			.onAppear(perform: presenter.fetchAllRooms)
			.toolbar {
				#if DEV || MOCK
					ToolbarItem(placement: .topBarTrailing) {
						Button {
							presenter.showDevSettings()
						} label: {
							Image(systemName: "hammer.fill")
						}
					}
				#endif
			}
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.homeView(router: router)
	}
}
