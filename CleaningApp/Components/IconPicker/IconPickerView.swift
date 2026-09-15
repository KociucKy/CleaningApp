import SwiftUI

// MARK: - IconPickerView

@MainActor
struct IconPickerView: View {
    // MARK: - Properties

    @State var presenter: IconPickerPresenter

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(LocalizedStringKey("onb_custom_room.icon_title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                IconPickerGridView(
                    icons: presenter.icons,
                    selectedIcon: presenter.selectedIcon,
                    onIconSelected: presenter.onIconSelected
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 48)
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
