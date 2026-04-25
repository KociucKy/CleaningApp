import FulhamKit
import SwiftUI

// MARK: - OnbCustomRoomSheetView

@MainActor
struct OnbCustomRoomSheetView: View {
	// MARK: - Properties

	@State var presenter: OnbCustomRoomSheetPresenter
	@Environment(\.dismiss) private var dismiss
	@FocusState private var isTextFieldFocused: Bool

	// MARK: - Body

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				if presenter.showIconPicker {
					ScrollView {
						OnbIconPickerView { icon in
							presenter.onIconSelected(icon)
							dismiss()
						}
					}
				} else {
					nameInputView
				}
			}
			.navigationTitle(LocalizedStringKey("onb_custom_room.sheet_title"))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("common.action.cancel") {
						dismiss()
					}
				}
				if !presenter.showIconPicker {
					ToolbarItem(placement: .primaryAction) {
						Button("onb_custom_room.button_next") {
							presenter.onNextButtonPressed()
						}
						.disabled(!presenter.isNameValid)
					}
				}
			}
			.onAppear {
				isTextFieldFocused = true
			}
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
	OnbCustomRoomSheetView(
		presenter: OnbCustomRoomSheetPresenter { name, icon in
			print("Created room: \(name), icon: \(icon)")
		}
	)
}
