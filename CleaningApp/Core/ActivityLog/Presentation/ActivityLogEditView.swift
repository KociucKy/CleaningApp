import SwiftUI

// MARK: - ActivityLogEditView

@MainActor
struct ActivityLogEditView: View {
    // MARK: - Properties

    @State private var presenter: ActivityLogEditPresenter

    // MARK: - Init

    init(presenter: ActivityLogEditPresenter) {
        _presenter = State(initialValue: presenter)
    }

    // MARK: - Body

    var body: some View {
        DatePicker(
            "Completed at",
            selection: $presenter.completedAt,
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.graphical)
        .padding()
        .presentationSizing(.fitted)
        .navigationTitle("Edit activity")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: presenter.onCancelButtonTapped)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: presenter.onSaveButtonTapped)
            }
        }
    }
}
