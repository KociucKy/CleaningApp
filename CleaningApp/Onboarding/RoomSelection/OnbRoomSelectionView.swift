import FulhamKit
import SwiftUI
import UtilitiesKit

struct OnbRoomSelectionView: View {
	// MARK: - Properties
	@Environment(\.colorScheme) private var colorScheme
	@State private var selectedRooms: Set<RoomIcon> = []

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
		.navigationTitle("Select rooms")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button("Skip") {}
			}
			if selectedRooms.isNotEmpty {
				ToolbarItem(placement: .topBarLeading) {
					Button("Clear") {
						selectedRooms = []
					}
				}
			}
		}
		.safeAreaBar(edge: .bottom) {
			controlButtonsView
		}
	}

	private var controlButtonsView: some View {
		VStack {
			Button {} label: {
				Text("Next")
					.font(FKTypography.ctaLabel)
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 55)
			}
			.buttonStyle(.glassProminent)
		}
		.padding([.horizontal, .top], FKSpacing.large)
	}

	// MARK: - Actions

	private func toggleSelection(for room: RoomIcon) {
		if selectedRooms.contains(room) {
			selectedRooms.remove(room)
		} else {
			selectedRooms.insert(room)
		}
		FKHaptics.selection()
	}

	// MARK: - Methods

	@ViewBuilder
	private func roomCell(_ room: RoomIcon) -> some View {
		let isSelected = selectedRooms.contains(room)
		Button {
			toggleSelection(for: room)
		} label: {
			FKCardView(showBorder: false) {
				VStack(spacing: FKSpacing.medium) {
					Image(systemName: room.symbolName)
						.font(.system(size: 32))
						.frame(height: 40)
						.symbolEffect(
							.bounce,
							options: .nonRepeating,
							isActive: selectedRooms.contains(room)
						)
					Text(room.rawValue.capitalized)
						.font(FKTypography.secondaryLabel)
						.multilineTextAlignment(.center)
						.bold(selectedRooms.contains(room))
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

	RouterView { _ in
		builder.roomSelectionView()
	}
}
