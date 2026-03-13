import SwiftUI

// MARK: - WelcomeView

struct WelcomeView: View {

    // MARK: - Properties

    @State var presenter: WelcomePresenter

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            titleSection
            Spacer()
            getStartedButton
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("CleaningApp")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("Get started to set up your profile.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Get Started Button

    private var getStartedButton: some View {
        Button {
            presenter.onGetStartedPressed()
        } label: {
            Text("Get started")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}