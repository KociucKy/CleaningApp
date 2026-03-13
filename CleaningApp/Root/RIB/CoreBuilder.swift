import NavigationKit
import SwiftUI
import ReviewKit

typealias RouterView = NavigationKit.RouterView

// MARK: - CoreBuilder

@MainActor
struct CoreBuilder: Builder {
	// MARK: - Properties

	let interactor: CoreInteractor

	// MARK: - Builder

	func build() -> AnyView {
		tabBarView().any()
	}

	// MARK: - Tab Bar

	func tabBarView() -> some View {
		TabBarView(
			tabs: [
				TabBarScreen(
					title: "Home",
					systemImage: "square.grid.2x2.fill",
					screen: {
						RouterView { router in
							homeView(router: router)
						}
						.any()
					}
				),
				TabBarScreen(
					title: "Rooms",
					systemImage: "house.fill",
					screen: {
						RouterView { router in
							roomsView(router: router)
						}
						.any()
					}
				),
				TabBarScreen(
					title: "Settings",
					systemImage: "gearshape.fill",
					screen: {
						RouterView { router in
							settingsView(router: router)
						}
						.any()
					}
				)
			]
		)
	}

	// MARK: - Tab Views

	func homeView(router: Router) -> some View {
		HomeView(
			presenter: HomePresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			)
		)
	}

	func roomsView(router: Router) -> some View {
		RoomsView(
			presenter: RoomsPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			)
		)
	}

	func settingsView(router: Router) -> some View {
		SettingsView(
			presenter: SettingsPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			)
		)
	}

	func devSettingsView(router: Router) -> some View {
		DevSettingsView(
			presenter: DevSettingsPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			)
		)
	}

//	func userDefaultsDebugView() -> some View {
//		UserDefaultsDevSettingsView()
//	}

	func reviewKitDebugView() -> some View {
		ReviewKitDebugView()
	}
}
