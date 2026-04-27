import NavigationKit
import SwiftUI

// MARK: - OnboardingBuilder

@MainActor
struct OnboardingBuilder: Builder {
	// MARK: - Properties

	let interactor: OnboardingInteractor

	// MARK: - Builder

	func build() -> AnyView {
		welcomeView().any()
	}

	// MARK: - Views

	func welcomeView() -> some View {
		RouterView { router in
			OnbWelcomeView(
				presenter: OnbWelcomePresenter(
					interactor: interactor,
					router: OnboardingRouter(router: router, builder: self)
				)
			)
		}
	}

	func roomSelectionView(router: Router) -> some View {
		OnbRoomSelectionView(
			presenter: OnbRoomSelectionPresenter(
				interactor: interactor,
				router: OnboardingRouter(router: router, builder: self)
			)
		)
	}

	func taskSelectionView(router: Router) -> some View {
		OnbTaskSelectionView(
			presenter: OnbTaskSelectionPresenter(
				interactor: interactor,
				router: OnboardingRouter(router: router, builder: self)
			)
		)
	}

	func notificationView(router: Router) -> some View {
		OnbNotificationView(
			presenter: OnbNotificationPresenter(
				interactor: interactor,
				router: OnboardingRouter(router: router, builder: self)
			)
		)
	}

	func paywallView(router: Router) -> some View {
		OnbPaywallView(
			presenter: OnbPaywallPresenter(
				interactor: interactor,
				router: OnboardingRouter(router: router, builder: self)
			)
		)
	}

	func onboardingCompletedView(router: Router) -> some View {
		OnboardingCompletedView(
			presenter: OnboardingCompletedPresenter(
				interactor: interactor,
				router: OnboardingRouter(router: router, builder: self)
			)
		)
	}

	func customRoomSheetView(router: Router) -> some View {
		OnbCustomRoomSheetView(
			presenter: OnbCustomRoomSheetPresenter(
				interactor: interactor,
				router: OnboardingRouter(router: router, builder: self)
			)
		)
	}

	func iconPickerView(sheetRouter: OnboardingRouter, roomName: String) -> some View {
		OnbIconPickerView(
			presenter: OnbIconPickerPresenter(
				interactor: interactor,
				router: sheetRouter,
				roomName: roomName
			)
		)
	}
}
