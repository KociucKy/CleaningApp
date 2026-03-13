import SwiftUI
import NavigationKit

// MARK: - HomeInteractor

@MainActor
protocol HomeInteractor {
    // TODO: Define Home interactor methods
}

extension CoreInteractor: HomeInteractor {}

// MARK: - HomeRouter

@MainActor
protocol HomeRouter {
    func dismissScreen()
}

extension CoreRouter: HomeRouter {}

// MARK: - HomePresenter

@Observable
@MainActor
final class HomePresenter {

    // MARK: - Properties

    private let interactor: any HomeInteractor
    private let router: any HomeRouter

    // MARK: - Init

    init(interactor: any HomeInteractor, router: any HomeRouter) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - HomeView

struct HomeView: View {

    // MARK: - Properties

    @State var presenter: HomePresenter

    // MARK: - Body

    var body: some View {
        Text("Home")
            .navigationTitle("Home")
    }
}

// MARK: - Preview

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.homeView(router: router)
    }
}