import FulhamKit
import SwiftUI

// MARK: - OnbAddCustomTaskSheet

@MainActor
struct OnbAddCustomTaskSheetView: View {
	// MARK: - Properties

	private enum Constants {
		static let charactersLimit = 40
	}

	@State var presenter: OnbAddCustomTaskSheetPresenter
	@FocusState private var isTaskNameFocused: Bool

	// MARK: - Body

	var body: some View {
		Form {
			Section {
				TextField("onb_custom_task.placeholder.task_name", text: $presenter.taskName)
					.focused($isTaskNameFocused)
					.withCharacterLimit($presenter.taskName, maxLength: Constants.charactersLimit)
			} header: {
				Text("onb_custom_task.label.task_name")
			} footer: {
				characterCountFooter(currentCount: presenter.taskName.count, maxLength: Constants.charactersLimit)
			}

			Section {
				FrequencyPickerView(
					selectedFrequency: $presenter.selectedFrequency,
					onInteraction: dismissKeyboard
				)
			} header: {
				Text("onb_custom_task.label.frequency")
			}
		}
		.navigationTitle("onb_custom_task.title")
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
				Button("common.action.add") {
					FKHaptics.selection()
					dismissKeyboard()
					presenter.onAddButtonPressed()
				}
				.disabled(!presenter.isTaskNameValid)
				.buttonStyle(.borderedProminent)
			}
		}
		.dismissesKeyboard(when: $isTaskNameFocused, using: dismissKeyboard)
	}

	// MARK: - Actions

	private func dismissKeyboard() {
		isTaskNameFocused = false
	}
}

// MARK: - Preview

#Preview {
	let devPreview = DevPreview()
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: devPreview.container))

	RouterView { router in
		builder.customTaskSheetView(router: router, roomType: .kitchen)
	}
}
