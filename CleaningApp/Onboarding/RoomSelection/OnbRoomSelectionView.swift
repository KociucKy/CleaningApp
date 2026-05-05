import FulhamKit
import SwiftUI
import UtilitiesKit

struct OnbRoomSelectionView: View {
	// MARK: - Properties

	@State var presenter: OnbRoomSelectionPresenter
	@ScaledMetric private var roomSymbolSize: CGFloat = 32
	private let columns = [GridItem(.flexible()), GridItem(.flexible())]

	// MARK: - Body

	var body: some View {
		ScrollView {
			ScrollViewReader { proxy in
				LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
					// Predefined rooms (excluding .customRoom sentinel)
					ForEach(Array(RoomType.allCases.filter { $0 != .customRoom }.enumerated()), id: \.element) { index, room in
						roomCell(room, index: index)
					}

					// Custom rooms
					ForEach(Array(presenter.customRooms.enumerated()), id: \.element.id) { index, customRoom in
						let cellIndex = RoomType.allCases.count(where: { $0 != .customRoom }) + index
						customRoomCell(customRoom, index: cellIndex)
							.id(customRoom.id)
					}
				}
				.padding(.horizontal, FKSpacing.large)
				.padding(.top, FKSpacing.large)
				.onChange(of: presenter.customRooms.count) { oldCount, newCount in
					if newCount > oldCount, let lastRoom = presenter.customRooms.last {
						presenter.onCustomRoomAdded()
						presenter.scrollToNewCustomRoom(proxy, roomId: lastRoom.id)
					}
				}
			}
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
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					presenter.onAddCustomRoomPressed()
				} label: {
					Image(systemName: "plus")
				}
				.accessibilityLabel(LocalizedStringKey("onb_room_selection.add_custom_room_button"))
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
		roomCellView(
			icon: room.symbolName,
			name: room.localizedName,
			isSelected: presenter.isRoomSelected(room),
			index: index,
			action: { presenter.onRoomCardViewPressed(room: room) },
			accessibilityLabel: nil
		)
	}

	@ViewBuilder
	private func customRoomCell(_ customRoom: CustomRoomSelection, index: Int) -> some View {
		roomCellView(
			icon: customRoom.icon,
			name: customRoom.name,
			isSelected: presenter.isCustomRoomSelected(customRoom.id),
			index: index,
			action: { presenter.onCustomRoomCardPressed(id: customRoom.id) },
			accessibilityLabel: String(localized: "onb_room_selection.custom_room_label_\(customRoom.name)")
		)
	}

	@ViewBuilder
	private func roomCellView(
		icon: String,
		name: String,
		isSelected: Bool,
		index: Int,
		action: @escaping () -> Void,
		accessibilityLabel: String?
	) -> some View {
		let isVisible = index < presenter.visibleCellCount
		Button {
			FKHaptics.selection()
			action()
		} label: {
			FKCardView(showBorder: false) {
				VStack(spacing: FKSpacing.medium) {
					Image(systemName: icon)
						.font(.system(size: roomSymbolSize))
						.frame(height: 40)
						.symbolEffect(
							.bounce,
							options: .nonRepeating,
							isActive: isSelected
						)
						.accessibilityHidden(true)
					Text(name)
						.font(FKTypography.secondaryLabel)
						.multilineTextAlignment(.center)
						.bold(isSelected)
						.lineLimit(1)
						.minimumScaleFactor(0.75)
				}
				.frame(maxWidth: .infinity)
				.padding(.vertical, FKSpacing.extraLarge)
				.padding(.horizontal, FKSpacing.default)
				.foregroundStyle(isSelected ? Color.accentColor : Color.primary)
			}
			.fkBorder(
				cornerRadius: FKRadius.medium,
				lineWidth: isSelected ? FKBorder.medium : FKBorder.thin,
				color: isSelected ? .accentColor : Color(FKColor.Separator.default)
			)
		}
		.modifier(OptionalAccessibilityLabelModifier(label: accessibilityLabel))
		.accessibilityAddTraits(isSelected ? .isSelected : [])
		.buttonStyle(.fkPressable)
		.opacity(isVisible ? 1 : 0)
		.offset(y: isVisible ? 0 : 20)
		.animation(.interactiveSpring, value: isSelected)
	}
}

// MARK: - OptionalAccessibilityLabelModifier

private struct OptionalAccessibilityLabelModifier: ViewModifier {
	private let label: String?

	init(label: String?) {
		self.label = label
	}

	func body(content: Content) -> some View {
		if let label {
			content.accessibilityLabel(label)
		} else {
			content
		}
	}
}

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.roomSelectionView(router: router)
	}
}
