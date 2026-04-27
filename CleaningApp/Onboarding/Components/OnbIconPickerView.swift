import SwiftUI

// MARK: - OnbIconPickerView

@MainActor
struct OnbIconPickerView: View {
	// MARK: - Properties

	@State var presenter: OnbIconPickerPresenter

	// MARK: - Body

	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				Text(LocalizedStringKey("onb_custom_room.icon_title"))
					.font(.title2)
					.fontWeight(.semibold)
					.frame(maxWidth: .infinity, alignment: .leading)

				LazyVGrid(columns: [
					GridItem(.adaptive(minimum: 64, maximum: 72), spacing: 16)
				], spacing: 16) {
					ForEach(presenter.icons, id: \.self) { icon in
						IconButton(iconName: icon) {
							presenter.onIconSelected(icon)
						}
					}
				}
			}
			.padding(.horizontal, 24)
			.padding(.top, 32)
			.padding(.bottom, 48)
		}
		.navigationTitle(LocalizedStringKey("onb_custom_room.icon_picker_title"))
		.navigationBarTitleDisplayMode(.inline)
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
		.accessibilityLabel(String(localized: "onb_custom_room.icon_button_\(iconName)"))
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let interactor = OnboardingInteractor(container: container)
	let builder = OnboardingBuilder(interactor: interactor)

	RouterView { router in
		NavigationStack {
			builder.iconPickerView(sheetRouter: OnboardingRouter(router: router, builder: builder), roomName: "My Custom Room")
		}
	}
}
