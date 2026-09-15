import FulhamKit
import SwiftUI

// MARK: - IconPickerGridView

@MainActor
struct IconPickerGridView: View {
	// MARK: - Properties

	let icons: [String]
	let selectedIcon: String
	let onIconSelected: (String) -> Void

	// MARK: - Body

	var body: some View {
		VStack(spacing: FKSpacing.large) {
			ForEach(Array(stride(from: 0, to: icons.count, by: 4)), id: \.self) { startIndex in
				HStack(spacing: FKSpacing.large) {
					ForEach(Array(icons[startIndex ..< min(startIndex + 4, icons.count)]), id: \.self) { icon in
						IconPickerButton(
							iconName: icon,
							isSelected: selectedIcon == icon
						) {
							onIconSelected(icon)
						}
					}
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .center)
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
		.buttonStyle(.plain)
		.accessibilityLabel(String(localized: "onb_custom_room.icon_button \(iconName)"))
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}
