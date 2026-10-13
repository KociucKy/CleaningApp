import SwiftUI

struct ScheduleView: View {
	var body: some View {
		VStack {
			
		}
		.navigationTitle("Schedule")
	}
}

#Preview {
	let container = DevPreview.shared.container
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)

	return RouterView { router in
		builder.scheduleView(router: router)
	}
}
