import FulhamKit
import SwiftUI

// MARK: - OnbNotificationView

@MainActor
struct OnbNotificationView: View {
	// MARK: - Constants

	private enum Constants {
		static let titleEntryOffset: CGFloat = 12
		static let benefitsEntryOffset: CGFloat = 16
		static let buttonHeight: CGFloat = 45
	}

	// MARK: - Properties

	@State var presenter: OnbNotificationPresenter

	// MARK: - Body

	var body: some View {
		VStack(spacing: 0) {
			Spacer()
			iconSection
			Spacer()
			benefitsSection
			Spacer()
		}
		.navigationBarHidden(true)
		.safeAreaInset(edge: .bottom) {
			bottomBar
				.padding(.horizontal, FKSpacing.large)
		}
		.onAppear(perform: presenter.animateEntrance)
	}

	// MARK: - Icon Section

	private var iconSection: some View {
		VStack(spacing: FKSpacing.medium) {
			OnbHeroIconView(
				systemName: "bell.badge.fill",
				iconVisible: presenter.iconVisible
			)
			VStack(spacing: FKSpacing.small) {
				Text("onb_notification.hero.title")
					.font(FKTypography.statValue)
					.foregroundStyle(FKColor.Label.primary)
				Text("onb_notification.hero.subtitle")
					.font(FKTypography.secondaryLabel)
					.foregroundStyle(FKColor.Label.secondary)
					.multilineTextAlignment(.center)
					.padding(.horizontal, FKSpacing.extraLarge)
			}
			.opacity(presenter.titleVisible ? 1 : 0)
			.offset(y: presenter.titleVisible ? 0 : Constants.titleEntryOffset)
		}
	}

	// MARK: - Benefits Section

	private var benefitsSection: some View {
		VStack(spacing: FKSpacing.medium) {
			OnbLabelRowView(
				symbol: "bell.fill",
				title: "onb_notification.benefit.reminders.title",
				description: "onb_notification.benefit.reminders.description"
			)
			OnbLabelRowView(
				symbol: "flame.fill",
				title: "onb_notification.benefit.streaks.title",
				description: "onb_notification.benefit.streaks.description"
			)
			OnbLabelRowView(
				symbol: "calendar",
				title: "onb_notification.benefit.weekly.title",
				description: "onb_notification.benefit.weekly.description"
			)
		}
		.padding(.horizontal, FKSpacing.large)
		.opacity(presenter.benefitsVisible ? 1 : 0)
		.offset(y: presenter.benefitsVisible ? 0 : Constants.benefitsEntryOffset)
	}

	// MARK: - Bottom Bar

	private var bottomBar: some View {
		VStack(spacing: FKSpacing.medium) {
			allowButton
			Button("common.action.skip", action: presenter.onSkipPressed)
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(FKColor.Label.secondary)
		}
	}

	private var allowButton: some View {
		Button {
			FKHaptics.impact(.medium)
			presenter.onAllowNotificationsPressed()
		} label: {
			Group {
				if presenter.isRequestingPermission {
					ProgressView()
						.tint(.white)
				} else {
					Text("onb_notification.cta.allow")
						.font(FKTypography.ctaLabel)
						.foregroundStyle(.white)
				}
			}
			.frame(maxWidth: .infinity)
			.frame(height: Constants.buttonHeight)
		}
		.buttonStyle(.glassProminent)
		.disabled(presenter.isRequestingPermission)
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.notificationView(router: router)
	}
}
