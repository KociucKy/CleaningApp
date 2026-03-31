import NavigationKit
import SwiftUI

struct HomeView: View {
	// MARK: - Properties

	@State var presenter: HomeViewPresenter

	// MARK: - Body

	var body: some View {
		Text(String.localizedStringWithFormat(String(localized: "home.rooms_count"), Int64(presenter.rooms.count)))
			.navigationTitle("home.nav_title")
			.navigationBarTitleDisplayMode(.large)
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
