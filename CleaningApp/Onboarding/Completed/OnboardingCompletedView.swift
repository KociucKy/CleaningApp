import FulhamKit
import SwiftUI

// MARK: - OnboardingCompletedView

@MainActor
struct OnboardingCompletedView: View {
	// MARK: - Constants

	private enum Constants {
		static let titleEntryOffset: CGFloat = 12
		static let statsEntryOffset: CGFloat = 16
		static let buttonHeight: CGFloat = 45
		static let statPillHorizontalPadding: CGFloat = 14
		static let statPillVerticalPadding: CGFloat = 8
		static let statPillCornerRadius: CGFloat = 12
	}

	// MARK: - Properties

	@State var presenter: OnboardingCompletedPresenter

	// MARK: - Body

	var body: some View {
		VStack(spacing: 0) {
			Spacer()
			heroSection
			Spacer()
			statsSection
			Spacer()
		}
		.navigationBarHidden(true)
		.safeAreaInset(edge: .bottom) {
			finishButton
				.padding(.horizontal, FKSpacing.large)
		}
		.onAppear(perform: presenter.animateEntrance)
	}

	// MARK: - Hero Section

	private var heroSection: some View {
		VStack(spacing: FKSpacing.medium) {
			OnbHeroIconView(
				systemName: "checkmark.seal.fill",
				iconVisible: presenter.iconVisible
			)
			VStack(spacing: FKSpacing.small) {
				Text("onb_completed.title")
					.font(FKTypography.statValue)
					.foregroundStyle(FKColor.Label.primary)
				Text("onb_completed.subtitle")
					.font(FKTypography.secondaryLabel)
					.foregroundStyle(FKColor.Label.secondary)
					.multilineTextAlignment(.center)
					.padding(.horizontal, FKSpacing.extraLarge)
			}
			.opacity(presenter.titleVisible ? 1 : 0)
			.offset(y: presenter.titleVisible ? 0 : Constants.titleEntryOffset)
		}
	}

	// MARK: - Stats Section

	private var statsSection: some View {
		HStack(spacing: FKSpacing.medium) {
			statPill(
				symbol: "door.left.hand.open",
				value: String.localizedStringWithFormat(
					String(localized: "onb_completed.rooms_count"),
					Int64(presenter.roomsCount)
				)
			)
			statPill(
				symbol: "checkmark.circle",
				value: String.localizedStringWithFormat(
					String(localized: "onb_completed.tasks_count"),
					Int64(presenter.tasksCount)
				)
			)
		}
		.opacity(presenter.statsVisible ? 1 : 0)
		.offset(y: presenter.statsVisible ? 0 : Constants.statsEntryOffset)
	}

	private func statPill(symbol: String, value: String) -> some View {
		HStack(spacing: FKSpacing.small) {
			Image(systemName: symbol)
				.font(FKTypography.bodyBold)
				.foregroundStyle(Color.accentColor)
			Text(value)
				.font(FKTypography.bodyBold)
				.foregroundStyle(FKColor.Label.primary)
		}
		.padding(.horizontal, Constants.statPillHorizontalPadding)
		.padding(.vertical, Constants.statPillVerticalPadding)
		.background(
			Color.accentColor.opacity(0.1),
			in: RoundedRectangle(cornerRadius: Constants.statPillCornerRadius)
		)
	}

	// MARK: - Finish Button

	private var finishButton: some View {
		Button {
			FKHaptics.impact(.medium)
			presenter.onFinishButtonPressed()
		} label: {
			Group {
				if presenter.isSaving {
					ProgressView()
						.tint(.white)
				} else {
					Text("common.action.finish")
						.font(FKTypography.ctaLabel)
						.foregroundStyle(.white)
				}
			}
			.frame(maxWidth: .infinity)
			.frame(height: Constants.buttonHeight)
		}
		.buttonStyle(.glassProminent)
		.disabled(presenter.isSaving)
		.opacity(presenter.buttonVisible ? 1 : 0)
		.offset(y: presenter.buttonVisible ? 0 : Constants.statsEntryOffset)
	}
}

// MARK: - Preview

#Preview {
	let devPreview = DevPreview()
	let _ = {
		devPreview.onboardingFlowState.toggleRoom(.kitchen)
		devPreview.onboardingFlowState.toggleRoom(.bedroom)
		devPreview.onboardingFlowState.toggleRoom(.bathroom)
	}()
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: devPreview.container))

	RouterView { router in
		builder.onboardingCompletedView(router: router)
	}
}
