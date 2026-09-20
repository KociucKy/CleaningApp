import SwiftUI

struct ActivityLogView: View {
	// MARK: - Properties

	@State private var presenter: ActivityLogPresenter

	// MARK: - Init

	init(presenter: ActivityLogPresenter) {
		_presenter = State(initialValue: presenter)
	}

	// MARK: - Body

	var body: some View {
		Text("Activity Log View")
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.activityLogView(router: router)
	}
}
