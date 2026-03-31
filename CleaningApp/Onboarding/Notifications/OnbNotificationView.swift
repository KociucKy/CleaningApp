import FulhamKit
import SwiftUI

// MARK: - OnbNotificationView

@MainActor
struct OnbNotificationView: View {
	// MARK: - Constants

	private enum Constants {
		static let iconCircleSize: CGFloat = 120
		static let lightIconCircleOpacity: CGFloat = 0.12
		static let darkIconCircleOpacity: CGFloat = 0.2
		static let iconSymbolSize: CGFloat = 52
		static let iconEntryScale: CGFloat = 0.6
		static let titleEntryOffset: CGFloat = 12
		static let benefitsEntryOffset: CGFloat = 16
		static let buttonHeight: CGFloat = 45
		static let benefitSymbolWidth: CGFloat = 32
	}

	// MARK: - Properties

	@Environment(\.colorScheme) private var colorScheme
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
			ZStack {
				Circle()
					.fill(
						Color.accentColor.opacity(colorScheme == .light ? Constants.lightIconCircleOpacity : Constants.darkIconCircleOpacity)
					)
					.frame(width: Constants.iconCircleSize, height: Constants.iconCircleSize)
				Image(systemName: "bell.badge.fill")
					.font(.system(size: Constants.iconSymbolSize, weight: .light))
					.foregroundStyle(Color.accentColor)
					.symbolEffect(.bounce, options: .nonRepeating, isActive: presenter.iconVisible)
			}
			.scaleEffect(presenter.iconVisible ? 1 : Constants.iconEntryScale)
			.opacity(presenter.iconVisible ? 1 : 0)

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
			benefitRow(
				symbol: "bell.fill",
				title: "onb_notification.benefit.reminders.title",
				description: "onb_notification.benefit.reminders.description"
			)
			benefitRow(
				symbol: "flame.fill",
				title: "onb_notification.benefit.streaks.title",
				description: "onb_notification.benefit.streaks.description"
			)
			benefitRow(
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

	// MARK: - Methods

	private func benefitRow(symbol: String, title: LocalizedStringKey, description: LocalizedStringKey) -> some View {
		HStack(spacing: FKSpacing.large) {
			Image(systemName: symbol)
				.font(FKTypography.sectionHeader)
				.fontWeight(.regular)
				.foregroundStyle(Color.accentColor)
				.frame(width: Constants.benefitSymbolWidth)
			VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
				Text(title)
					.font(FKTypography.bodyBold)
					.foregroundStyle(FKColor.Label.primary)
				Text(description)
					.font(FKTypography.caption)
					.foregroundStyle(FKColor.Label.secondary)
			}
			Spacer()
		}
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
