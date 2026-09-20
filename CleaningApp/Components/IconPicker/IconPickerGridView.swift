import FulhamKit
import SwiftUI

// MARK: - IconPickerGridView

@MainActor
struct IconPickerGridView: View {
	// MARK: - Properties

	private enum Constants {
		static let columnMinimumWidth: CGFloat = 64
		static let columnMaximumWidth: CGFloat = 68
	}

	let icons: [String]
	let selectedIcon: String
	let onIconSelected: (String) -> Void

	// MARK: - Body

	var body: some View {
		LazyVGrid(
			columns: [
				GridItem(.adaptive(minimum: Constants.columnMinimumWidth, maximum: Constants.columnMaximumWidth), spacing: FKSpacing.default),
			],
			spacing: FKSpacing.default
		) {
			ForEach(icons, id: \.self) { icon in
				IconPickerButton(
					iconName: icon,
					isSelected: selectedIcon == icon
				) {
					onIconSelected(icon)
				}
			}
		}
		.frame(maxWidth: .infinity)
	}
}

// MARK: - IconPickerButton

@MainActor
private struct IconPickerButton: View {
	// MARK: - Properties

	private enum Constants {
		static let buttonSize: CGFloat = 64
		static let iconSize: CGFloat = 28
		static let selectedLineWidth: CGFloat = 3
	}

	let iconName: String
	let isSelected: Bool
	let action: () -> Void

	// MARK: - Body

	var body: some View {
		Button(action: action) {
			Image(systemName: iconName)
				.symbolEffect(.bounce, options: .nonRepeating, isActive: isSelected)
				.font(.system(size: Constants.iconSize))
				.foregroundStyle(isSelected ? .accent : .primary)
				.frame(
					width: Constants.buttonSize,
					height: Constants.buttonSize
				)
				.background(FKColor.Background.canvas)
				.clipShape(RoundedRectangle(cornerRadius: FKRadius.medium))
				.overlay {
					RoundedRectangle(cornerRadius: FKRadius.medium)
						.stroke(
							.tint,
							lineWidth: isSelected ? Constants.selectedLineWidth : 0
						)
				}
		}
		.buttonStyle(.plain)
		.accessibilityLabel(String(localized: "onb_custom_room.icon_button \(iconName)"))
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}

#Preview {
	@Previewable @State var icon = ""

	IconPickerGridView(
		icons: IconPickerOptions.icons,
		selectedIcon: icon,
		onIconSelected: { selectedIcon in
			icon = selectedIcon
		}
	)
}
