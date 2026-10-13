import SwiftUI

struct ScheduleView: View {
	// MARK: - Properties

	@State private var presenter: SchedulePresenter

	// MARK: - Init

	init(presenter: SchedulePresenter) {
		_presenter = State(initialValue: presenter)
	}

	// MARK: - Body

	var body: some View {
		VStack {
			
		}
		.navigationTitle("Schedule")
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)

	return RouterView { router in
		builder.scheduleView(router: router)
	}
}
