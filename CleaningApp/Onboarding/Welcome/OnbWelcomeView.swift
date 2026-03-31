import FulhamKit
import SwiftUI

// MARK: - OnbWelcomeView

@MainActor
struct OnbWelcomeView: View {
	// MARK: - Constants

	private enum Constants {
		static let heroCircleSize: CGFloat = 120
		static let lightHeroCircleOpacity: CGFloat = 0.12
		static let darkHeroCircleOpacity: CGFloat = 0.2
		static let heroSymbolSize: CGFloat = 52
		static let heroEntryScale: CGFloat = 0.6
		static let titleEntryOffset: CGFloat = 12
		static let subtitleEntryOffset: CGFloat = 8
		static let featuresSectionEntryOffset: CGFloat = 16
		static let buttonHeight: CGFloat = 45
		static let featureSymbolWidth: CGFloat = 32
	}

	// MARK: - Properties

	@Environment(\.colorScheme) private var colorScheme
	@State var presenter: OnbWelcomePresenter

	// MARK: - Body

	var body: some View {
		VStack(spacing: 0) {
			Spacer()
			heroSection
			Spacer()
			featuresSection
			Spacer()
		}
		.navigationBarHidden(true)
		.safeAreaInset(edge: .bottom) {
			getStartedButton
				.padding(.horizontal, FKSpacing.large)
		}
		.onAppear(perform: presenter.animateEntrance)
	}

	// MARK: - Hero Section

	private var heroSection: some View {
		VStack(spacing: FKSpacing.medium) {
			ZStack {
				Circle()
					.fill(
						Color.accentColor.opacity(colorScheme == .light ? Constants.lightHeroCircleOpacity : Constants.darkHeroCircleOpacity)
					)
					.frame(width: Constants.heroCircleSize, height: Constants.heroCircleSize)
				Image(systemName: "sparkles")
					.font(.system(size: Constants.heroSymbolSize, weight: .light))
					.foregroundStyle(Color.accentColor)
			}
			.scaleEffect(presenter.heroVisible ? 1 : Constants.heroEntryScale)
			.opacity(presenter.heroVisible ? 1 : 0)

			VStack(spacing: FKSpacing.small) {
				Text("onb_welcome.hero.title_line1")
					.font(FKTypography.statValue)
					.foregroundStyle(FKColor.Label.primary)
				Text("onb_welcome.hero.title_line2")
					.font(FKTypography.statValue)
					.foregroundStyle(Color.accentColor)
			}
			.opacity(presenter.titleVisible ? 1 : 0)
			.offset(y: presenter.titleVisible ? 0 : Constants.titleEntryOffset)

			Text("onb_welcome.hero.subtitle")
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(FKColor.Label.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, FKSpacing.extraLarge)
				.opacity(presenter.titleVisible ? 1 : 0)
				.offset(y: presenter.titleVisible ? 0 : Constants.subtitleEntryOffset)
		}
	}

	// MARK: - Features Section

	private var featuresSection: some View {
		VStack(spacing: FKSpacing.medium) {
			featureRow(
				symbol: "calendar.badge.checkmark",
				title: "onb_welcome.feature.daily_plan.title",
				description: "onb_welcome.feature.daily_plan.description"
			)
			featureRow(
				symbol: "clock",
				title: "onb_welcome.feature.time_estimates.title",
				description: "onb_welcome.feature.time_estimates.description"
			)
			featureRow(
				symbol: "chart.bar.fill",
				title: "onb_welcome.feature.balanced_weeks.title",
				description: "onb_welcome.feature.balanced_weeks.description"
			)
			featureRow(
				symbol: "flame.fill",
				title: "onb_welcome.feature.streaks.title",
				description: "onb_welcome.feature.streaks.description"
			)
		}
		.padding(.horizontal, FKSpacing.large)
		.opacity(presenter.featuresVisible ? 1 : 0)
		.offset(y: presenter.featuresVisible ? 0 : Constants.featuresSectionEntryOffset)
	}

	// MARK: - Get Started Button

	private var getStartedButton: some View {
		Button {
			FKHaptics.impact(.medium)
			presenter.onGetStartedPressed()
		} label: {
			Text("onb_welcome.cta")
				.font(FKTypography.ctaLabel)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.frame(height: Constants.buttonHeight)
		}
		.buttonStyle(.glassProminent)
	}

	// MARK: - Methods

	private func featureRow(symbol: String, title: LocalizedStringKey, description: LocalizedStringKey) -> some View {
		HStack(spacing: FKSpacing.large) {
			Image(systemName: symbol)
				.font(FKTypography.sectionHeader)
				.fontWeight(.regular)
				.foregroundStyle(Color.accentColor)
				.frame(width: Constants.featureSymbolWidth)
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

	RouterView { _ in
		builder.welcomeView()
	}
}
