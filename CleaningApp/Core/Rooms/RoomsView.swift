import SwiftUI
import NavigationKit

// MARK: - RoomsInteractor

@MainActor
protocol RoomsInteractor {
    // TODO: Define Rooms interactor methods
}

extension CoreInteractor: RoomsInteractor {}

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
    func dismissScreen()
}

extension CoreRouter: RoomsRouter {}

// MARK: - RoomsPresenter

@Observable
@MainActor
final class RoomsPresenter {

    // MARK: - Properties

    private let interactor: any RoomsInteractor
    private let router: any RoomsRouter

    // MARK: - Init

    init(interactor: any RoomsInteractor, router: any RoomsRouter) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - RoomsView

struct RoomsView: View {

    // MARK: - Properties

    @State var presenter: RoomsPresenter

    // MARK: - Body

    var body: some View {
        Text("Rooms")
            .navigationTitle("Rooms")
    }
}

// MARK: - Preview

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.roomsView(router: router)
    }
}