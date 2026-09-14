import SwiftUI

// MARK: - IconPickerView

@MainActor
struct IconPickerView: View {
	// MARK: - Properties

	@State var presenter: IconPickerPresenter

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVGrid(
				columns: [
					GridItem(.adaptive(minimum: 64, maximum: 72), spacing: 16),
				],
				spacing: 16
			) {
				ForEach(presenter.icons, id: \.self) { icon in
					IconPickerButton(
						iconName: icon,
						isSelected: presenter.selectedIcon == icon
					) {
						presenter.onIconSelected(icon)
					}
				}
			}
			.padding(.horizontal, 24)
		}
		.navigationTitle(LocalizedStringKey("onb_custom_room.icon_picker_title"))
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				Button("common.action.done") {
					presenter.onDoneButtonPressed()
				}
			}
		}
	}
}

// MARK: - IconPickerButton

@MainActor
private struct IconPickerButton: View {
	// MARK: - Properties

	let iconName: String
	let isSelected: Bool
	let action: () -> Void

	// MARK: - Body

	var body: some View {
		Button(action: action) {
			Image(systemName: iconName)
				.font(.system(size: 28))
				.foregroundStyle(.primary)
				.frame(width: 64, height: 64)
				.background(.quaternary)
				.clipShape(RoundedRectangle(cornerRadius: 12))
				.overlay {
					RoundedRectangle(cornerRadius: 12)
						.stroke(
							.tint,
							lineWidth: isSelected ? 3 : 0
						)
				}
		}
		.accessibilityLabel(String(localized: "onb_custom_room.icon_button \(iconName)"))
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}
