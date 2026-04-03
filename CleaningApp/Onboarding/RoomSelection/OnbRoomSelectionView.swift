import FulhamKit
import SwiftUI
import UtilitiesKit

struct OnbRoomSelectionView: View {
	// MARK: - Properties

	@State var presenter: OnbRoomSelectionPresenter
	private let columns = [GridItem(.flexible()), GridItem(.flexible())]
	@ScaledMetric private var roomSymbolSize: CGFloat = 32

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
				ForEach(Array(RoomType.allCases.enumerated()), id: \.element) { index, room in
					roomCell(room, index: index)
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
				.opacity(presenter.buttonVisible ? 1 : 0)
				.offset(y: presenter.buttonVisible ? 0 : 16)
		}
		.onAppear {
			presenter.animateEntrance()
		}
	}

	// MARK: - SubViews

	private var controlButtonsView: some View {
		OnbControlButtonsView(
			buttonLabel: "common.action.next",
			showSkipButton: true,
			isPrimaryButtonDisabled: !presenter.hasSelection,
			primaryAction: presenter.onNextButtonPressed,
			skipAction: presenter.onSkipButtonPressed
		)
	}

	@ViewBuilder
	private func roomCell(_ room: RoomType, index: Int) -> some View {
		let isSelected = presenter.isRoomSelected(room)
		let isVisible = index < presenter.visibleCellCount
		Button {
			FKHaptics.selection()
			presenter.onRoomCardViewPressed(room: room)
		} label: {
			FKCardView(showBorder: false) {
				VStack(spacing: FKSpacing.medium) {
					Image(systemName: room.symbolName)
						.font(.system(size: roomSymbolSize))
						.frame(height: 40)
						.symbolEffect(
							.bounce,
							options: .nonRepeating,
							isActive: isSelected
						)
						.accessibilityHidden(true)
					Text(room.localizedName)
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
		.accessibilityAddTraits(isSelected ? .isSelected : [])
		.buttonStyle(.fkPressable)
		.opacity(isVisible ? 1 : 0)
		.offset(y: isVisible ? 0 : 20)
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
