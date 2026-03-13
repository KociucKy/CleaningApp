import SwiftUI
import NavigationKit

// MARK: - HomeView

struct HomeView: View {

    // MARK: - Properties

    @State var presenter: HomePresenter

    // MARK: - Body

    var body: some View {
        Text("Home")
            .navigationTitle("Home")
            .toolbar {
                #if DEV || MOCK
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        presenter.showDevSettings()
                    } label: {
                        Image(systemName: "hammer.fill")
                    }
                }
                #endif
            }
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