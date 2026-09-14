import FulhamKit
import SwiftUI

// MARK: - OnbAddCustomTaskSheetView

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
                characterCountFooter(
                    currentCount: presenter.taskName.count,
                    maxLength: Constants.charactersLimit
                )
            }

            Section {
                TaskDurationStepperView(duration: $presenter.selectedDuration)
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
        .navigationTitle(presenter.isEditing ? "Edit Task" : "onb_custom_task.title")
        .navigationBarTitleDisplayMode(.inline)
        .presentationDragIndicator(.visible)
        .onAppear {
            isTaskNameFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.action.cancel") {
                    dismissKeyboard()
                    presenter.onCancelButtonPressed()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(presenter.isEditing ? "Edit" : "common.action.add") {
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
