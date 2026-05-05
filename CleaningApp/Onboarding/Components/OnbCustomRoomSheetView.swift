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
		Form {
			Section {
				TextField(
					LocalizedStringKey("onb_custom_room.name_placeholder"),
					text: $presenter.roomName
				)
				.font(.body)
				.focused($isTextFieldFocused)
				.accessibilityHint(LocalizedStringKey("onb_custom_room.name_hint"))
				.onChange(of: presenter.roomName) {
					presenter.limitNameLength()
				}
			} footer: {
				characterCountFooter
			}
		}
	}

	private var characterCountFooter: some View {
		HStack {
			if presenter.roomName.count == 30 {
				Text(LocalizedStringKey("onb_custom_room.character_limit_reached"))
					.font(.caption)
					.foregroundStyle(characterCountColor)
					.transition(.opacity.combined(with: .scale))
			}
			Spacer()
			Text("\(presenter.roomName.count)/30")
				.font(.caption)
				.foregroundStyle(characterCountColor)
				.contentTransition(.numericText())
		}
		.animation(.smooth, value: presenter.roomName.count)
	}

	private var characterCountColor: Color {
		let count = presenter.roomName.count
		switch count {
		case 28...:
			return .red
		case 25 ... 27:
			return .orange
		default:
			return .secondary
		}
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
