import DeviceKitUI
import LocalNotificationKitDebugUI
import NavigationKit
import ReviewKit
import SwiftUI
import UserDefaultsKitUI

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
				title: String(localized: "tab.home"),
				systemImage: "square.grid.2x2.fill",
					screen: {
						RouterView { router in
							homeView(router: router)
						}
						.any()
					}
				),
			TabBarScreen(
				title: String(localized: "tab.rooms"),
				systemImage: "house.fill",
					screen: {
						RouterView { router in
							roomsView(router: router)
						}
						.any()
					}
				),
			TabBarScreen(
				title: String(localized: "tab.settings"),
				systemImage: "gearshape.fill",
					screen: {
						RouterView { router in
							settingsView(router: router)
						}
						.any()
					}
				),
			]
		)
	}

	// MARK: - Tab Views

	func homeView(router: Router) -> some View {
		HomeView(
			presenter: HomeViewPresenter(
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

	func userDefaultsDebugView() -> some View {
		UserDefaultsDevSettingsView(entries: [.bool(.init("showOnboarding", defaultValue: false), label: "showOnboarding")])
	}

	func reviewKitDebugView() -> some View {
		#if DEBUG
			ReviewKitDebugView()
		#else
			EmptyView()
		#endif
	}

	func localNotificationsDebugView() -> some View {
		NotificationDebugView()
	}

	func deviceDebugView() -> some View {
		DeviceInfoView()
	}
}
