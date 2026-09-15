import FulhamKit
import SwiftUI

// MARK: - CustomRoomSheetView

@MainActor
struct CustomRoomSheetView: View {
	// MARK: - Properties

	@State var presenter: CustomRoomSheetPresenter
	@FocusState private var isTextFieldFocused: Bool

	// MARK: - Body

	var body: some View {
		roomFormView
			.navigationTitle(LocalizedStringKey(presenter.isEditing ? "Edit room" : "onb_custom_room.sheet_title"))
			.navigationBarTitleDisplayMode(.inline)
			.presentationDragIndicator(.visible)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("common.action.cancel") {
						dismissKeyboard()
						presenter.onCancelButtonPressed()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(presenter.isEditing ? "Save" : "common.action.done") {
						dismissKeyboard()
						presenter.onSaveButtonPressed()
					}
					.disabled(!presenter.isNameValid)
					.buttonStyle(.borderedProminent)
				}
			}
			.onAppear {
				isTextFieldFocused = !presenter.isEditing
			}
			.dismissesKeyboard(when: $isTextFieldFocused, using: dismissKeyboard)
	}

	// MARK: - SubViews

	private var roomFormView: some View {
		Form {
			Section {
				TextField(
					LocalizedStringKey("onb_custom_room.name_placeholder"),
					text: $presenter.roomName
				)
				.font(FKTypography.body)
				.focused($isTextFieldFocused)
				.accessibilityHint(LocalizedStringKey("onb_custom_room.name_hint"))
				.withCharacterLimit($presenter.roomName)
			} footer: {
				characterCountFooter(currentCount: presenter.roomName.count)
			}

			if !presenter.isEditing {
				Section {
					IconPickerGridView(
						icons: presenter.icons,
						selectedIcon: presenter.selectedIcon,
						onIconSelected: { selectedIcon in
							isTextFieldFocused = false
							presenter.onIconSelected(selectedIcon)
						}
					)
					.padding(.vertical, FKSpacing.default) // To ommit List / Form styling
					.removeListRowFormatting()
				} header: {
					Text(LocalizedStringKey("onb_custom_room.icon_title"))
				}
			}
		}
	}

	// MARK: - Actions

	private func dismissKeyboard() {
		isTextFieldFocused = false
	}
}

#Preview {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.customRoomSheetView(router: router)
	}
}
