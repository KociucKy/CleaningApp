import FulhamKit
import SwiftUI

// MARK: - OnbWelcomeView

@MainActor
struct OnbWelcomeView: View {
	// MARK: - Constants

	private enum Constants {
		static let titleEntryOffset: CGFloat = 12
		static let subtitleEntryOffset: CGFloat = 8
		static let featuresSectionEntryOffset: CGFloat = 16
		static let buttonHeight: CGFloat = 45
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
			OnbHeroIconView(
				systemName: "bubbles.and.sparkles.fill",
				iconVisible: presenter.heroVisible
			)
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
			OnbLabelRowView(
				symbol: "calendar.badge.checkmark",
				title: "onb_welcome.feature.daily_plan.title",
				description: "onb_welcome.feature.daily_plan.description"
			)
			OnbLabelRowView(
				symbol: "clock",
				title: "onb_welcome.feature.time_estimates.title",
				description: "onb_welcome.feature.time_estimates.description"
			)
			OnbLabelRowView(
				symbol: "chart.bar.fill",
				title: "onb_welcome.feature.balanced_weeks.title",
				description: "onb_welcome.feature.balanced_weeks.description"
			)
			OnbLabelRowView(
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
		OnbControlButtonsView(
			buttonLabel: "onb_welcome.cta",
			primaryAction: presenter.onGetStartedPressed
		)
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
