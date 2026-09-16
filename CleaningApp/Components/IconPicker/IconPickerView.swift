import SwiftUI
import FulhamKit

// MARK: - IconPickerView

@MainActor
struct IconPickerView: View {
	// MARK: - Properties

	private enum Constants {
		static let horizontalPadding: CGFloat = 24
	}

	@State var presenter: IconPickerPresenter

	// MARK: - Body

	var body: some View {
		ScrollView {
			IconPickerGridView(
				icons: presenter.icons,
				selectedIcon: presenter.selectedIcon,
				onIconSelected: presenter.onIconSelected
			)
			.padding(.horizontal, Constants.horizontalPadding)
			.padding(.top, 32)
		}
		.navigationTitle(LocalizedStringKey("onb_custom_room.icon_picker_title"))
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				Button("common.action.done") {
					presenter.onDoneButtonPressed()
				}
			}
		}
	}
}
