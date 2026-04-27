import FulhamKit
import SwiftUI

// MARK: - OnbCustomRoomSheetView

@MainActor
struct OnbCustomRoomSheetView: View {
	// MARK: - Properties

	@State var presenter: OnbCustomRoomSheetPresenter
	@FocusState private var isTextFieldFocused: Bool

	// MARK: - Body

	var body: some View {
		nameInputView
			.navigationTitle(LocalizedStringKey("onb_custom_room.sheet_title"))
			.navigationBarTitleDisplayMode(.inline)
			.presentationDragIndicator(.visible)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("common.action.cancel") {
						presenter.onCancelButtonPressed()
					}
				}
				ToolbarItem(placement: .primaryAction) {
					Button("onb_custom_room.button_next") {
						presenter.onNextButtonPressed()
					}
					.disabled(!presenter.isNameValid)
				}
			}
			.onAppear {
				isTextFieldFocused = true
			}
	}

	// MARK: - SubViews

	private var nameInputView: some View {
		VStack(spacing: FKSpacing.large) {
			TextField(
				LocalizedStringKey("onb_custom_room.name_placeholder"),
				text: $presenter.roomName
			)
			.textFieldStyle(.roundedBorder)
			.font(.body)
			.focused($isTextFieldFocused)
			.onChange(of: presenter.roomName) {
				presenter.limitNameLength()
			}

			Text("onb_custom_room.name_hint")
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)

			Spacer()
		}
		.padding(.horizontal, FKSpacing.large)
		.padding(.top, FKSpacing.extraLarge)
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let interactor = OnboardingInteractor(container: container)
	let builder = OnboardingBuilder(interactor: interactor)

	RouterView { router in
		builder.customRoomSheetView(router: router)
	}
}
