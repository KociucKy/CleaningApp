import NavigationKit
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest
@testable import CleaningApp

// MARK: - SnapshotRouter

/// No-op Router used in snapshot tests to satisfy presenter dependencies
/// without triggering real navigation.
@MainActor
private struct SnapshotRouter: Router {
	func showScreen<T: View>(
		_: SegueOption,
		onDismiss _: (() -> Void)?,
		@ViewBuilder destination _: @escaping (any Router) -> T
	) {}

	func dismissScreen() {}
	func popToRoot() {}
	func dismissToRoot() {}

	func showAlert(
		_: AlertType,
		title _: String,
		subtitle _: String?,
		buttons _: (@Sendable () -> AnyView)?
	) {}

	func dismissAlert() {}

	func showModal(
		transition _: AnyTransition,
		backgroundColor _: Color,
		@ViewBuilder destination _: @escaping () -> some View
	) {}

	func dismissModal() {}
}

// MARK: - Helpers (free functions avoid capturing non-Sendable XCTestCase)

@MainActor
private func makeOnboardingInteractor(
	configuring configure: ((OnboardingFlowState) -> Void)? = nil
) -> OnboardingInteractor {
	let preview = DevPreview()
	configure?(preview.onboardingFlowState)
	return OnboardingInteractor(container: preview.container)
}

@MainActor
private func makeOnboardingRouter(for interactor: OnboardingInteractor) -> OnboardingRouter {
	OnboardingRouter(
		router: SnapshotRouter(),
		builder: OnboardingBuilder(interactor: interactor)
	)
}

/// Wraps a view so that all SwiftUI animations (including `withAnimation` blocks
/// triggered by `onAppear`) execute immediately with no interpolation, ensuring
/// snapshot tests capture the fully-visible final state.
@MainActor
private func snap(_ view: some View) -> AnyView {
	AnyView(
		view
			.transaction { $0.disablesAnimations = true }
			.preferredColorScheme(.light)
	)
}

// MARK: - OnboardingSnapshotTests

/// XCTest always runs test methods on the main thread.
/// @MainActor on the class prevents test discovery in Swift 6 — use MainActor.assumeIsolated instead.
final class OnboardingSnapshotTests: XCTestCase {
	// MARK: - OnbWelcomeView

	func test_welcomeView_defaultState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor()
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbWelcomePresenter(interactor: interactor, router: router)
			presenter.heroVisible = true
			presenter.titleVisible = true
			presenter.featuresVisible = true
			presenter.buttonVisible = true
			assertSnapshot(
				of: snap(OnbWelcomeView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	// MARK: - OnbRoomSelectionView

	func test_roomSelectionView_noSelection() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor()
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbRoomSelectionPresenter(interactor: interactor, router: router)
			presenter.visibleCellCount = RoomType.allCases.count
			presenter.buttonVisible = true
			assertSnapshot(
				of: snap(OnbRoomSelectionView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_roomSelectionView_withSelection() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor { flowState in
				flowState.toggleRoom(.kitchen)
				flowState.toggleRoom(.bedroom)
			}
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbRoomSelectionPresenter(interactor: interactor, router: router)
			presenter.visibleCellCount = RoomType.allCases.count
			presenter.buttonVisible = true
			assertSnapshot(
				of: snap(OnbRoomSelectionView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	// MARK: - OnbTaskSelectionView

	func test_taskSelectionView_defaultState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor { flowState in
				flowState.toggleRoom(.kitchen)
				flowState.toggleRoom(.bedroom)
				flowState.toggleRoom(.bathroom)
			}
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbTaskSelectionPresenter(interactor: interactor, router: router)
			presenter.visibleSectionCount = interactor.selectedRooms.count
			presenter.buttonVisible = true
			assertSnapshot(
				of: snap(OnbTaskSelectionView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	// MARK: - OnbNotificationView

	func test_notificationView_defaultState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor()
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbNotificationPresenter(interactor: interactor, router: router)
			presenter.iconVisible = true
			presenter.titleVisible = true
			presenter.benefitsVisible = true
			presenter.buttonVisible = true
			assertSnapshot(
				of: snap(OnbNotificationView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_notificationView_loadingState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor()
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbNotificationPresenter(interactor: interactor, router: router)
			presenter.iconVisible = true
			presenter.titleVisible = true
			presenter.benefitsVisible = true
			presenter.buttonVisible = true
			presenter.isRequestingPermission = true
			assertSnapshot(
				of: snap(OnbNotificationView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	// MARK: - OnbPaywallView

	func test_paywallView_defaultState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor()
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnbPaywallPresenter(interactor: interactor, router: router)
			assertSnapshot(
				of: snap(OnbPaywallView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	// MARK: - OnboardingCompletedView

	func test_completedView_defaultState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor { flowState in
				flowState.toggleRoom(.kitchen)
				flowState.toggleRoom(.bedroom)
			}
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)
			presenter.iconVisible = true
			presenter.titleVisible = true
			presenter.statsVisible = true
			presenter.buttonVisible = true
			assertSnapshot(
				of: snap(OnboardingCompletedView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_completedView_savingState() {
		MainActor.assumeIsolated {
			let interactor = makeOnboardingInteractor { flowState in
				flowState.toggleRoom(.kitchen)
			}
			let router = makeOnboardingRouter(for: interactor)
			let presenter = OnboardingCompletedPresenter(interactor: interactor, router: router)
			presenter.iconVisible = true
			presenter.titleVisible = true
			presenter.statsVisible = true
			presenter.buttonVisible = true
			presenter.isSaving = true
			assertSnapshot(
				of: snap(OnboardingCompletedView(presenter: presenter)),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	// MARK: - Components

	func test_heroIconView_visible() {
		MainActor.assumeIsolated {
			let view = OnbHeroIconView(systemName: "bubbles.and.sparkles.fill", iconVisible: true)
				.frame(width: 200, height: 200)
			assertSnapshot(
				of: snap(view),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_labelRowView_defaultState() {
		MainActor.assumeIsolated {
			let view = OnbLabelRowView(
				symbol: "bell.badge.fill",
				title: "onb_notification.benefit.reminders.title",
				description: "onb_notification.benefit.reminders.description"
			)
			.padding(.horizontal)
			assertSnapshot(
				of: snap(view),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_controlButtonsView_withSkipButton() {
		MainActor.assumeIsolated {
			let view = OnbControlButtonsView(
				buttonLabel: "common.action.next",
				showSkipButton: true,
				primaryAction: {},
				skipAction: {}
			)
			assertSnapshot(
				of: snap(view),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_controlButtonsView_primaryOnly() {
		MainActor.assumeIsolated {
			let view = OnbControlButtonsView(
				buttonLabel: "common.action.next",
				showSkipButton: false,
				primaryAction: {}
			)
			assertSnapshot(
				of: snap(view),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}

	func test_controlButtonsView_disabled() {
		MainActor.assumeIsolated {
			let view = OnbControlButtonsView(
				buttonLabel: "common.action.next",
				showSkipButton: true,
				isPrimaryButtonDisabled: true,
				primaryAction: {},
				skipAction: {}
			)
			assertSnapshot(
				of: snap(view),
				as: .image(layout: .device(config: .iPhone13Pro))
			)
		}
	}
}
