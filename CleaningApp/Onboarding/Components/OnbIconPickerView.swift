import SwiftUI

// MARK: - OnbIconPickerView

@MainActor
struct OnbIconPickerView: View {
	// MARK: - Properties

	private let onIconSelected: (String) -> Void

	private let icons: [String] = [
		"house.fill",
		"bed.double.fill",
		"dumbbell",
		"book.fill",
		"paintpalette.fill",
		"leaf.fill",
		"wrench.and.screwdriver.fill",
		"music.note",
		"gamecontroller.fill",
		"laptopcomputer",
		"tv.fill",
		"car.fill",
		"cart.fill",
		"tent.fill",
		"pawprint.fill",
		"figure.walk",
		"tshirt.fill",
		"cup.and.saucer.fill",
		"square.grid.2x2",
	]

	private let defaultIcon = "square.grid.2x2"

	// MARK: - Init

	init(onIconSelected: @escaping (String) -> Void) {
		self.onIconSelected = onIconSelected
	}

	// MARK: - Body

	var body: some View {
		VStack(spacing: 20) {
			Text(LocalizedStringKey("onb_custom_room.icon_title"))
				.font(.title2)
				.fontWeight(.semibold)
				.frame(maxWidth: .infinity, alignment: .leading)

			LazyVGrid(columns: [
				GridItem(.adaptive(minimum: 64, maximum: 72), spacing: 16),
			], spacing: 16) {
				ForEach(icons, id: \.self) { icon in
					IconButton(iconName: icon) {
						onIconSelected(icon)
					}
				}
			}
		}
		.padding(.horizontal, 24)
		.padding(.top, 32)
		.padding(.bottom, 48)
	}
}

// MARK: - IconButton

@MainActor
private struct IconButton: View {
	let iconName: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Image(systemName: iconName)
				.font(.system(size: 28))
				.foregroundStyle(.primary)
				.frame(width: 64, height: 64)
				.background(.quaternary)
				.clipShape(RoundedRectangle(cornerRadius: 12))
		}
	}
}

// MARK: - Preview

#Preview {
	OnbIconPickerView { icon in
		print("Selected icon: \(icon)")
	}
}
