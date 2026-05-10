import FulhamKit
import SwiftUI

// MARK: - OnbAddCustomTaskSheet

struct OnbAddCustomTaskSheetView: View {
	// MARK: - Properties

	private enum Constants {
		static let charactersLimit = 40
	}

	@State var presenter: OnbAddCustomTaskSheetPresenter

	// MARK: - Body

	var body: some View {
		Form {
			Section {
				TextField("onb_custom_task.placeholder.task_name", text: $presenter.taskName)
					.autocorrectionDisabled()
					.withCharacterLimit($presenter.taskName, maxLength: Constants.charactersLimit)
			} header: {
				Text("onb_custom_task.label.task_name")
			} footer: {
				characterCountFooter(currentCount: presenter.taskName.count, maxLength: Constants.charactersLimit)
			}

			Section {
				Picker("onb_custom_task.label.frequency", selection: $presenter.selectedFrequency) {
					Text(Frequency.daily.displayName).tag(Frequency.daily)
					Text(Frequency.timesPerWeek(2).displayName).tag(Frequency.timesPerWeek(2))
					Text(Frequency.timesPerWeek(3).displayName).tag(Frequency.timesPerWeek(3))
					Text(Frequency.timesPerWeek(1).displayName).tag(Frequency.timesPerWeek(1))
					Text(Frequency.everyOtherWeek.displayName).tag(Frequency.everyOtherWeek)
					Text(Frequency.monthly.displayName).tag(Frequency.monthly)
				}
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
					presenter.onCancelButtonPressed()
				}
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("common.action.add") {
					FKHaptics.selection()
					presenter.onAddButtonPressed()
				}
				.disabled(!presenter.isTaskNameValid)
			}
		}
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
