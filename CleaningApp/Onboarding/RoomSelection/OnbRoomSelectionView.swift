import FulhamKit
import SwiftUI
import UtilitiesKit

struct OnbRoomSelectionView: View {
	// MARK: - Properties

	@State var presenter: OnbRoomSelectionPresenter
	private let columns = [GridItem(.flexible()), GridItem(.flexible())]

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
				ForEach(RoomIcon.allCases) { room in
					roomCell(room)
				}
			}
			.padding(.horizontal, FKSpacing.large)
			.padding(.top, FKSpacing.large)
		}
		.navigationTitle("onb_room_selection.nav_title")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden()
		.toolbar {
			if presenter.hasSelection {
				ToolbarItem(placement: .topBarLeading) {
					Button("common.action.clear", action: presenter.onClearButtonPressed)
				}
			}
		}
		.safeAreaBar(edge: .bottom) {
			controlButtonsView
		}
	}

	// MARK: - SubViews

	private var controlButtonsView: some View {
		VStack(spacing: FKSpacing.medium) {
			Button {
				FKHaptics.impact(.medium)
				presenter.onNextButtonPressed()
			} label: {
				Text("common.action.next")
					.font(FKTypography.ctaLabel)
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 50)
			}
			.buttonStyle(.glassProminent)
			.padding([.horizontal, .top], FKSpacing.large)
			.disabled(!presenter.hasSelection)
			Button("common.action.skip", action: presenter.onSkipButtonPressed)
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(FKColor.Label.secondary)
		}
	}

	@ViewBuilder
	private func roomCell(_ room: RoomIcon) -> some View {
		let isSelected = presenter.isRoomSelected(room)
		Button {
			FKHaptics.selection()
			presenter.onRoomCardViewPressed(room: room)
		} label: {
			FKCardView(showBorder: false) {
				VStack(spacing: FKSpacing.medium) {
					Image(systemName: room.symbolName)
						.font(.system(size: 32))
						.frame(height: 40)
						.symbolEffect(
							.bounce,
							options: .nonRepeating,
							isActive: isSelected
						)
					Text(room.rawValue)
						.font(FKTypography.secondaryLabel)
						.multilineTextAlignment(.center)
						.bold(isSelected)
				}
				.frame(maxWidth: .infinity)
				.padding(.vertical, FKSpacing.extraLarge)
				.foregroundStyle(isSelected ? Color.accentColor : Color.primary)
			}
			.fkBorder(
				cornerRadius: FKRadius.medium,
				lineWidth: isSelected ? FKBorder.medium : FKBorder.thin,
				color: isSelected ? .accentColor : Color(FKColor.Separator.default)
			)
		}
		.buttonStyle(.fkPressable)
		.animation(.interactiveSpring, value: isSelected)
	}
}

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.roomSelectionView(router: router)
	}
}
