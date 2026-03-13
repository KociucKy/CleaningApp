import SwiftUI

// MARK: - OnboardingCompletedView

struct OnboardingCompletedView: View {

    // MARK: - Properties

    @State var presenter: OnboardingCompletedPresenter

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("You're all set and ready to go.")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .safeAreaInset(edge: .bottom) {
            finishButton
                .padding(24)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Finish Button

    private var finishButton: some View {
        Button {
            presenter.onFinishButtonPressed()
        } label: {
            Text("Finish")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}