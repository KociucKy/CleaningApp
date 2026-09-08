import FulhamKit
import SwiftUI

// MARK: - CustomTaskSheetView

@MainActor
struct CustomTaskSheetView: View {
	// MARK: - Properties

	private enum Constants {
		static let charactersLimit = 40
	}

	@State var presenter: AddCustomTaskSheetPresenter
	@FocusState private var isTaskNameFocused: Bool

	// MARK: - Body

	var body: some View {
		Form {
			Section {
				TextField(
					"onb_custom_task.placeholder.task_name",
					text: $presenter.taskName
				)
				.autocorrectionDisabled()
				.focused($isTaskNameFocused)
				.withCharacterLimit($presenter.taskName, maxLength: Constants.charactersLimit)
			} header: {
				Text("onb_custom_task.label.task_name")
			} footer: {
				characterCountFooter(
					currentCount: presenter.taskName.count,
					maxLength: Constants.charactersLimit
				)
			}

			Section {
				Picker(
					"onb_custom_task.label.frequency",
					selection: $presenter.selectedFrequency
				) {
					ForEach(Frequency.allCases, id: \.displayName) { frequency in
						Text(frequency.displayName)
							.tag(frequency)
					}
				}
			} header: {
				Text("onb_custom_task.label.frequency")
			}
		}
		.scrollDismissesKeyboard(.interactively)
		.navigationTitle("onb_custom_task.title")
		.navigationBarTitleDisplayMode(.inline)
		.presentationDragIndicator(.visible)
		.onAppear {
			isTaskNameFocused = true
		}
		.onChange(of: presenter.selectedFrequency) {
			isTaskNameFocused = false
		}
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("common.action.cancel") {
					isTaskNameFocused = false
					presenter.onCancelButtonPressed()
				}
			}
			ToolbarItem(placement: .confirmationAction) {
				Button(presenter.isEditing ? "Edit" : "common.action.add") {
					FKHaptics.selection()
					isTaskNameFocused = false
					presenter.onSaveButtonPressed()
				}
				.disabled(!presenter.isTaskNameValid)
			}
		}
	}
}
