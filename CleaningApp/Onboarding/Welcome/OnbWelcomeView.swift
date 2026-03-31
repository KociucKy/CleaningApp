import FulhamKit
import SwiftUI

// MARK: - OnbWelcomeView

@MainActor
struct OnbWelcomeView: View {
	// MARK: - Properties

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
					.fill(Color.accentColor.opacity(0.12))
					.frame(width: 120, height: 120)
				Image(systemName: "sparkles")
					.font(.system(size: 52, weight: .light))
					.foregroundStyle(Color.accentColor)
			}
			.scaleEffect(presenter.heroVisible ? 1 : 0.6)
			.opacity(presenter.heroVisible ? 1 : 0)

			VStack(spacing: FKSpacing.small) {
				Text("Clean smarter,")
					.font(FKTypography.statValue)
					.foregroundStyle(FKColor.Label.primary)
				Text("not harder.")
					.font(FKTypography.statValue)
					.foregroundStyle(Color.accentColor)
			}
			.opacity(presenter.titleVisible ? 1 : 0)
			.offset(y: presenter.titleVisible ? 0 : 12)

			Text("A structured weekly plan so you always\nknow what to clean today — nothing more.")
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(FKColor.Label.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, FKSpacing.extraLarge)
				.opacity(presenter.titleVisible ? 1 : 0)
				.offset(y: presenter.titleVisible ? 0 : 8)
		}
	}

	// MARK: - Features Section

	private var featuresSection: some View {
		VStack(spacing: FKSpacing.medium) {
			featureRow(
				symbol: "calendar.badge.checkmark",
				title: "Daily plan",
				description: "Only what needs doing today — no overwhelming backlogs."
			)
			featureRow(
				symbol: "clock",
				title: "Time estimates",
				description: "Know upfront how long cleaning will take."
			)
			featureRow(
				symbol: "chart.bar.fill",
				title: "Balanced weeks",
				description: "Tasks spread evenly so no single day feels too heavy."
			)
			featureRow(
				symbol: "flame.fill",
				title: "Streaks & progress",
				description: "Stay motivated with daily streaks and a weekly activity overview."
			)
		}
		.padding(.horizontal, FKSpacing.large)
		.opacity(presenter.featuresVisible ? 1 : 0)
		.offset(y: presenter.featuresVisible ? 0 : 16)
	}

	// MARK: - Get Started Button

	private var getStartedButton: some View {
		Button {
			presenter.onGetStartedPressed()
		} label: {
			Text("Get started")
				.font(FKTypography.ctaLabel)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.frame(height: 45)
		}
		.buttonStyle(.glassProminent)
		.opacity(presenter.buttonVisible ? 1 : 0)
		.offset(y: presenter.buttonVisible ? 0 : 12)
	}

	// MARK: - Methods

	@ViewBuilder
	private func featureRow(symbol: String, title: String, description: String) -> some View {
		HStack(spacing: FKSpacing.large) {
			Image(systemName: symbol)
				.font(FKTypography.sectionHeader)
				.fontWeight(.regular)
				.foregroundStyle(Color.accentColor)
				.frame(width: 32)
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
		builder.welcomeView()
	}
}
