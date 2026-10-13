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
            "activity_log_edit.completed_at",
            selection: completedAtBinding,
            in: ...Date.now,
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.graphical)
        .padding()
        .presentationSizing(.fitted)
        .navigationTitle("activity_log_edit.title")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.action.cancel", action: presenter.onCancelButtonTapped)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.action.save", action: presenter.onSaveButtonTapped)
            }
        }
    }

    // MARK: - Private

    private var completedAtBinding: Binding<Date> {
        Binding(
            get: { presenter.completedAt },
            set: { presenter.completedAt = min($0, .now) }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let completedTask = CompletedTask.mock

    return RouterView { router in
        builder.activityLogEditView(router: router, completedTask: completedTask)
    }
}
