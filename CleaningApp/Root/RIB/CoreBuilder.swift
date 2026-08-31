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
				)
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

	func roomsDetailsView(router: Router, room: Room) -> some View {
		RoomsDetailsView(
			presenter: RoomsDetailsPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			),
			room: room
		)
	}

	func roomsDetailsTaskCompletionView(
		router: Router,
		props: RoomsDetailsTaskCompletionProps
	) -> some View {
		RoomsDetailsTaskCompletionView(
			presenter: RoomsDetailsTaskCompletionPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			),
			props: props
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

	// MARK: - Custom Room Sheet (Rooms Context)

	func customRoomSheetView(router: Router) -> some View {
		CustomRoomSheetView(
			presenter: CustomRoomSheetPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self)
			)
		)
	}

	// MARK: - Custom Task Sheet

	func addCustomTaskSheetView(router: Router, roomId: UUID) -> some View {
		AddCustomTaskSheetView(
			presenter: AddCustomTaskSheetPresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: self),
				roomId: roomId
			)
		)
	}

	func iconPickerView(sheetRouter: CoreRouter, roomName: String) -> some View {
		IconPickerView(
			presenter: IconPickerPresenter(
				interactor: interactor,
				router: sheetRouter,
				roomName: roomName
			)
		)
	}
}
